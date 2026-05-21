// sysauth.c — Authentication-related system call implementations
// All checks happen in kernel mode (Ring 0) — PoLP enforced here

#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "spinlock.h"
#include "proc.h"
#include "auth.h"
#include "syscall.h"

extern struct user_table g_users;

// =============================================================
// sys_login — Authenticate user, set proc credentials
// Called by login shell; transitions process from uid=-1 to real uid
// =============================================================
uint64
sys_login(void)
{
    char username[32], password[32];

    // Safely copy arguments from user space
    // argstr validates the pointer is in user address space
    if (argstr(0, username, 32) < 0 ||
        argstr(1, password, 32) < 0)
        return -1;

    int uid = auth_verify(username, password);
    if (uid < 0) {
        // Log failed attempt — security audit trail
        audit_log_event(myproc()->pid, -1, SYS_login, "FAIL:bad_credentials");
        return -1;
    }

    // Set credentials on the calling process
    struct proc *p = myproc();
    acquire(&p->lock);
    p->creds.uid           = uid;
    p->creds.gid           = uid;   // gid mirrors uid for this project
    p->creds.role          = uid;
    p->creds.authenticated = 1;
    safestrcpy(p->creds.username, username, 32);
    // Initialize stack canary (simplified — production uses random value)
    p->stack_canary = 0xDEADBEEFCAFEBABE;
    
    // DEBUG: Verify credential was set
    int verify_uid = p->creds.uid;
    release(&p->lock);

    printf("DEBUG: sys_login called for %s, pid=%d, setting uid=%d, verify=%d\n", username, p->pid, uid, verify_uid);
    audit_log_event(p->pid, uid, SYS_login, "SUCCESS:login");
    return uid;
}

// =============================================================
// sys_whoami — Return current UID to user space
// =============================================================
uint64
sys_whoami(void)
{
    struct proc *p = myproc();
    return p->creds.uid;
}

// =============================================================
// sys_useradd — Add user (ADMIN only)
// Demonstrates PoLP: only uid=0 can create new accounts
// =============================================================
uint64
sys_useradd(void)
{
    struct proc *p = myproc();

    // ENFORCE: Only admin can add users
    if (p->creds.uid != ROLE_ADMIN) {
        audit_log_event(p->pid, p->creds.uid, SYS_useradd, "DENIED:not_admin");
        return -1;
    }

    char username[32], password[32];
    int  uid, gid;

    if (argstr(0, username, 32) < 0 ||
        argstr(1, password, 32) < 0 ||
        argint(2, &uid)         < 0 ||
        argint(3, &gid)         < 0)
        return -1;

    int result = auth_add_user(username, password, uid, gid);
    audit_log_event(p->pid, p->creds.uid, SYS_useradd,
                    result == 0 ? "SUCCESS:useradd" : "FAIL:useradd");
    return result;
}

// =============================================================
// sys_userdel — Delete user (ADMIN only)
// =============================================================
uint64
sys_userdel(void)
{
    struct proc *p = myproc();

    if (p->creds.uid != ROLE_ADMIN) {
        audit_log_event(p->pid, p->creds.uid, SYS_userdel, "DENIED:not_admin");
        return -1;
    }

    char username[32];
    if (argstr(0, username, 32) < 0)
        return -1;

    // Prevent deleting own account — safety guard
    if (strncmp(username, p->creds.username, 32) == 0)
        return -1;

    return auth_del_user(username);
}

// =============================================================
// sys_passwd — Change password (own account, or admin for any)
// =============================================================
uint64
sys_passwd(void)
{
    struct proc *p = myproc();
    char username[32], old_pw[32], new_pw[32];

    if (argstr(0, username, 32) < 0 ||
        argstr(1, old_pw,   32) < 0 ||
        argstr(2, new_pw,   32) < 0)
        return -1;

    // Non-admin can only change their own password
    if (p->creds.uid != ROLE_ADMIN &&
        strncmp(username, p->creds.username, 32) != 0) {
        audit_log_event(p->pid, p->creds.uid, SYS_passwd, "DENIED:wrong_user");
        return -1;
    }

    // Verify old password (skip for admin)
    if (p->creds.uid != ROLE_ADMIN) {
        if (auth_verify(username, old_pw) < 0) {
            audit_log_event(p->pid, p->creds.uid, SYS_passwd, "FAIL:wrong_password");
            return -1;
        }
    }

    // Update hash in user table
    acquire(&g_users.lock);
    for (int i = 0; i < AUTH_MAX_USERS; i++) {
        if (g_users.entries[i].valid &&
            strncmp(g_users.entries[i].username, username, 32) == 0) {
            hash_password(new_pw, g_users.entries[i].passhash);
            release(&g_users.lock);
            audit_log_event(p->pid, p->creds.uid, SYS_passwd, "SUCCESS:passwd_changed");
            return 0;
        }
    }
    release(&g_users.lock);
    return -1;
}

// =============================================================
// sys_chmod — Placeholder for Phase 2
// =============================================================
uint64
sys_chmod(void)
{
    return 0; // Success placeholder
}

// =============================================================
// sys_chown — Placeholder for Phase 2
// =============================================================
uint64
sys_chown(void)
{
    return 0; // Success placeholder
}