#  xv6-riscv Medical Device Security

**CCY4304 — Project 12**
**Ahmed Mohamed (221003440) / Belal Walid (2210102080)**
**Dr. Ayman Adel | Eng. Abdelrahman Soliman**

---

##  What is This Project?

This project turns the educational xv6-riscv operating system into a secure medical device OS. We added three major security layers on top of the vanilla kernel:

1. **User Authentication (RBAC)** — you must log in before you can do anything
2. **File Access Control (Unix Permissions)** — each file has an owner and permissions
3. **Syscall Audit Log** — every security-relevant action is recorded in the kernel

All security logic lives in the kernel (Ring 0). User-space programs can never bypass it.

---

##  Project Structure

```
xv6-riscv/
├── kernel/
│   ├── auth.h / auth.c       # Credential storage & password hashing
│   ├── sysauth.c             # Login, useradd, userdel, passwd, whoami syscalls
│   ├── audit.h / audit.c     # Ring buffer audit log
│   ├── proc.h                # Extended with security fields (creds, stack_canary)
│   ├── fs.h / fs.c           # Extended inodes with mode/uid/gid
│   ├── file.h / file.c       # Permission checks (check_permission)
│   ├── sysfile.c             # open() with permission enforcement
│   ├── trap.c                # Audit hook before every security syscall
│   ├── syscall.c             # Dispatch table (8 new syscalls registered)
│   └── defs.h                # Function prototypes for auth & audit
├── user/
│   ├── init.c                # Login gate before shell spawns
│   ├── login.c               # Login user program
│   ├── sectest.c             # Automated test suite (12 test cases)
│   ├── usys.pl               # RISC-V syscall stubs (8 new entries)
│   └── user.h                # Syscall declarations for user programs
└── screenshoots/
    ├── phase-1/              # Screenshots 11–20
    ├── phase-2/              # Screenshots 21–31
    ├── phase-3/              # Screenshots 32–36
    └── bonus/                # Screenshots 37–38
```

---

##  Phase 1 — User Authentication (RBAC)

Every process must prove its identity before the shell starts. Credentials are stored **inside the kernel** (`struct proc`) — invisible to user space. No login, no shell. Period.

### How the login flow works

![Authentication Flow Architecture](screenshoots/phase-1/11.png)

> The `login.c` user program can only pass a username and password string — it never sees the hash table and never makes the auth decision. The kernel's `sys_login()` calls `auth_verify()` in Ring 0, sets `proc->creds`, and logs the result. User space trusts nothing; kernel decides everything.

---

### `struct proc` — Extended with security fields

![struct proc with security fields](screenshoots/phase-1/12.png)

> `struct proc_creds creds` and `uint64 stack_canary` are appended at the **end** of `struct proc`. Adding at the end means existing field offsets are untouched — the scheduler, trap handler, and memory manager all access `struct proc` by name and would silently break if offsets shifted. The stack canary (`0xDEADBEEFCAFEBABE`) detects buffer overflows in new syscall handlers.

---

### `kernel/auth.h` — Credential storage structures

![auth.h credential structures](screenshoots/phase-1/13.png)

> `struct passwd_entry` holds username, password hash, uid, gid, role, and a valid flag — mirroring `/etc/passwd`. A `spinlock` protects the table because multiple processes could try to log in concurrently on multi-core RISC-V. Without it, two processes could both read "user not found" at the same time and both try to add the same user — a classic race condition.

---

### `kernel/auth.c` — Password hashing (djb2)

![hash_password using djb2](screenshoots/phase-1/14.png)

> The djb2 polynomial hash (`h = h * 33 + c`) is used because xv6 has no crypto library. This is a **known limitation** — production medical systems must use bcrypt or Argon2 with a per-user random salt to prevent rainbow table attacks.

---

### `kernel/sysauth.c` — `sys_login()` syscall

![sys_login implementation](screenshoots/phase-1/15.png)

> `sys_login()` uses `argstr()` to safely copy the username/password from user-space memory. Direct pointer dereference would be a security hole — a malicious process could pass a kernel address. `argstr()` validates the pointer lies within the process's own mapped pages before copying. On success, it atomically sets `proc->creds` under the process lock.

---

### `kernel/syscall.c` — 8 new syscalls registered

![syscall dispatch table](screenshoots/phase-1/16.png)

> Eight new handlers (`sys_login`, `sys_useradd`, `sys_userdel`, `sys_passwd`, `sys_whoami`, `sys_chmod`, `sys_chown`, `sys_audit_read`) are added to the dispatch table. This connects the syscall number from register `a7` to the actual handler function.

---

### `user/usys.pl` — RISC-V assembly stubs

![usys.pl syscall stubs](screenshoots/phase-1/17.png)

> Eight new `entry()` calls generate RISC-V assembly stubs. Each stub loads the syscall number into register `a7` and executes the `ecall` instruction — the bridge that turns a normal C function call into a Ring 3 → Ring 0 transition.

---

### `user/user.h` — Syscall declarations

![user.h function declarations](screenshoots/phase-1/18.png)

> C function declarations for all 8 new syscalls. Without these, user programs like `init.c` and `sectest.c` would not know the function signatures and the compiler would reject calls to them.

---

### `user/init.c` — Login gate before shell

![init.c login gate](screenshoots/phase-1/19.png)

> `do_login()` loops up to 3 times and only returns on success. The shell (`sh`) is forked **only after** authentication passes. Because `init` is PID 1 — the parent of every process in xv6 — there is no code path that spawns a shell without first passing through `auth_verify()`. An attacker cannot bypass it without a kernel exploit.

---

###  Live Demo — Boot → Login → Shell

![Live terminal: boot and login](screenshoots/phase-1/20.png)

> The system boots and immediately shows `xv6 Medical Device Security System / Authorized Access Only`. A wrong password is rejected: `Authentication failed. 2 attempt(s) remaining.` The correct password succeeds: `Welcome, admin! Role: ADMIN`. Running `whoami` confirms: `Current UID: 0 (Role: ADMIN)`. **Phase 1 is fully operational.**

---

##  Phase 2 — File Access Control (Unix Permissions)

Phase 2 enforces **who can read, write, and execute each file**. Permissions are stored on-disk in inodes (ACL) and compared against the authenticated uid/gid from Phase 1 (Capability List in RAM). All checks happen inside the kernel **before any data is transferred**.

### Architecture — ACL on Disk + Capability List in RAM

![Hybrid security architecture](screenshoots/phase-2/21.png)

> On-disk ACL (`struct dinode`: mode/uid/gid) provides **persistence** — permissions survive reboots. In-RAM capability (`proc->creds.uid` from Phase 1 login) provides **performance** — no disk I/O per access check. The `check_permission()` function combines both: reads inode permissions (loaded by `ilock`) and compares against `proc->creds`. This exactly matches the "ACL on disk + Capability List in RAM" model.

---

### `kernel/fs.h` — Extended `struct dinode`

![fs.h with mode/uid/gid](screenshoots/phase-2/22.png)

> Three `uint` fields (`mode`, `uid`, `gid`) added after the existing `addrs[]` array in `struct dinode`. UNIX permission macros `S_IRUSR` (0400) through `S_IXOTH` (0001) defined below. Using `uint` ensures 4-byte alignment with no silent padding holes — mixing `short` and `uint` would corrupt the inode layout on disk.

---

### `kernel/file.h` — Extended in-memory `struct inode`

![file.h with mode/uid/gid](screenshoots/phase-2/23.png)

> The same three fields added to the in-memory inode cache. When `ilock()` loads a file from disk, it copies `mode/uid/gid` into this fast in-memory copy. `check_permission()` reads from here — never directly from disk during permission checks.

---

### `kernel/fs.c` — Loading permissions from disk

![ilock loading permissions](screenshoots/phase-2/24.png)

> Three lines inside the `ip->valid == 0` block copy `dip->mode/uid/gid` into the in-memory inode. This block only runs on a cache miss (first time the inode is loaded from disk), so permissions are always populated before any caller can use the inode.

---

### `kernel/fs.c` — Persisting permissions to disk

![iupdate persisting permissions](screenshoots/phase-2/25.png)

> Three lines in `iupdate()` write the in-memory inode back to the on-disk dinode. Without these, `chmod()` and `chown()` would update RAM but the changes would be lost on reboot — the disk copy would still have the old permissions.

---

### `kernel/file.c` — `check_permission()` — The single enforcement point

![check_permission function](screenshoots/phase-2/26.png)

> Checks in order: (1) `caller_uid == 0` → ADMIN bypass, (2) owner bits, (3) group bits, (4) other bits. Returns 0 (allow) or -1 (deny). **Centralizing this in one function** means a single fix if a vulnerability is found. Duplicating the logic across `fileread`, `filewrite`, `sys_open`, and `sys_exec` would risk one copy being patched while another isn't.

---

### `kernel/file.c` — `fileread()` with permission check

![fileread with permission enforcement](screenshoots/phase-2/27.png)

> The permission check happens **before** `readi()` — denied users never see any bytes, not even partial data. The `ilock/iunlock` pair is balanced on both the denial path and the success path, preventing deadlock.

---

### `kernel/sysfile.c` — `sys_open()` with permission check

![sys_open permission check](screenshoots/phase-2/28.png)

> Checking at `open()` time means a process that cannot open a file never gets a file descriptor. This also prevents **file descriptor passing attacks** — where a privileged process opens a file and passes the fd to an unprivileged one.

---

###  Live Demo — Doctor Role Access Test

![Doctor role file access test](screenshoots/phase-2/29.png)

> Doctor (uid=2, gid=2) logs in. `cat records` → ✅ allowed (gid matches). `cat insulin.log` → ✅ allowed (doctor owns it). `cat config` → ❌ **CORRECTLY DENIED** (config is uid=0 mode=0600, doctor has no access).

---

###  Live Demo — Admin Role Access Test

![Admin role file access test](screenshoots/phase-2/30.png)

> Admin (uid=0) can read **all three files** regardless of ownership — the `uid==0` bypass in `check_permission()` returns 0 immediately. This is the `CAP_DAC_OVERRIDE` equivalent behavior.

---

###  Live Demo — Patient Role Access Test

![Patient role file access test](screenshoots/phase-2/31.png)

> Patient (uid=1, gid=1): `cat records` → ✅ (patient owns it, mode=0440). `cat insulin.log` → ✅ (gid=1 matches, mode=0640 group-read). `cat config` → ❌ **CORRECTLY DENIED**. Patient can see their own records and dosage but cannot touch device configuration.

---

##  Phase 3 — Syscall Audit Log

Phase 3 is the **accountability** layer — the third pillar of the AAA security model (Authentication, Authorization, Accountability). Every security-relevant syscall is recorded in a kernel ring buffer. Only the admin can read the log. Even if an attacker succeeds, their actions are recorded and **cannot be erased from user space**.

### Audit Log Architecture

![Audit log architecture](screenshoots/phase-3/32.png)

> Logging at the **trap level** (before syscall dispatch) means every attempt is recorded — even calls the handler immediately rejects. A patient calling `audit_read()` gets both `EPERM` returned AND an audit entry recording the attempt. The ring buffer lives in kernel BSS (not user-accessible RAM).

---

### `kernel/audit.c` — Syscall name mapping

![syscall_names array](screenshoots/phase-3/33.png)

> A static array maps every syscall number to its name string. A compliance report showing `[SYS_22] DENIED` is useless. One showing `[login] FAIL:bad_credentials pid=5 uid=-1` is immediately actionable. Named mappings turn raw numbers into forensic evidence.

---

### `kernel/audit.h` — Ring buffer structures

![audit ring buffer structures](screenshoots/phase-3/34.png)

> `struct audit_entry` stores pid, uid, syscall name, message, timestamp, and valid flag. `struct audit_ring` wraps 256 entries with head/tail pointers and a spinlock. 256 entries × ~200 bytes ≈ 50KB of kernel memory — acceptable for a medical device. The **ring (circular) design** means the buffer never fills up and blocks: oldest entries are overwritten. The spinlock allows safe calls from interrupt context.

---

### `kernel/defs.h` — Function prototypes

![defs.h new prototypes](screenshoots/phase-3/35.png)

> Prototypes for `auth.c` and `audit.c` added to `defs.h`, which is included by virtually every kernel file. Any kernel file can now call `audit_log_event()` or `auth_verify()` without extra includes — keeping the include graph clean.

---

### `kernel/trap.c` — Audit hook in `usertrap()`

![trap.c audit hook](screenshoots/phase-3/36.png)

> Lines added in `usertrap()`: after confirming `r_scause()==8` (RISC-V ecall) and **before** calling `syscall()`, if the syscall number matches any security-relevant call (`SYS_open`, `SYS_read`, `SYS_login`, `SYS_chmod`, etc.), `audit_log_event()` is called. Logging **before** the handler runs means even a panicking handler leaves an audit trail.

---

##  Bonus — Automated Test Suite (sectest)

### `user/sectest.c` — All 12 test cases

![sectest main() with all 12 test calls](screenshoots/bonus/37.png)

> The `sectest` program calls all 12 test functions in sequence: TC01–TC03 test authentication, TC04–TC08 test file permissions for all three roles, TC09–TC10 test audit log access control, TC11–TC12 test RBAC privilege restriction. Manual testing of 12 scenarios across 3 roles would be error-prone and hard to reproduce — the automated suite provides repeatable, documented proof of each security property.

---

###  Live Demo — sectest Results

![sectest running all 12 test cases](screenshoots/bonus/38.png)

> **Result: 9/12 PASS, 3 FAIL**
>
> **Passing (9):** TC01 Admin login ✅, TC02 Bad password denied ✅, TC03 Patient login ✅, TC04 Patient write insulin denied ✅, TC07 Patient config denied ✅, TC08 Doctor config denied ✅, TC09 Patient `audit_read` EPERM ✅, TC10 Admin `audit_read` succeeds ✅, TC11 Patient `useradd` denied ✅
>
> **Failing (3 — TC05, TC06, TC12):** These fail because `fsinit_security()` sets permissions on files before `mkfs` creates them in the test environment. The permission **logic is correct** (proven by the live terminal tests in screenshots 29–31). Fix: ensure files exist before `fsinit_security()` runs.

---

##  New Syscalls Summary

| Syscall | Number | Description |
|---|---|---|
| `login(user, pass)` | SYS_22 | Authenticate and set `proc->creds` |
| `useradd(user, pass, role)` | SYS_23 | Add a new user (admin only) |
| `userdel(user)` | SYS_24 | Remove a user (admin only) |
| `passwd(user, newpass)` | SYS_25 | Change password |
| `whoami()` | SYS_26 | Print current uid and role |
| `chmod(path, mode)` | SYS_27 | Change file permissions |
| `chown(path, uid, gid)` | SYS_28 | Change file ownership |
| `audit_read(buf, n)` | SYS_29 | Read audit log (admin only) |

---

##  Roles

| Role | UID | Access |
|---|---|---|
| Admin | 0 | Full access to everything (CAP_DAC_OVERRIDE) |
| Patient | 1 | Own records + own dosage (read-only) |
| Doctor | 2 | Patient records + device logs |

---

##  Running the Project

```bash
# Clone and build
git clone https://github.com/Quiix24/xv6-riscv
cd xv6-riscv
make qemu

# At the login prompt
Username: admin
Password: admin123

# Run the automated test suite
$ sectest
```

---

##  Known Limitations

- Password hashing uses **djb2** (not bcrypt/Argon2) — acceptable for an educational kernel, not for production.
- No per-user salt — susceptible to rainbow table attacks.
- 3 test cases (TC05, TC06, TC12) fail due to a filesystem init ordering issue in the test environment only. Core permission logic is correct.
