// kernel/proc.h — Modified for CCY4304 Project 12 (Phase 1)
// Changes from original xv6:
//   1. Added role definitions (ROLE_ADMIN, ROLE_PATIENT, ROLE_DOCTOR)
//   2. Added struct proc_creds
//   3. Added creds + stack_canary fields to struct proc
// All other structs (context, cpu, trapframe, procstate) are UNCHANGED.

// ================================================================
// SECURITY ADDITIONS — Phase 1: User Authentication
// ================================================================

// Role definitions — matches course rubric exactly
#define ROLE_ADMIN    0   // Full system access
#define ROLE_PATIENT  1   // Read-only own records
#define ROLE_DOCTOR   2   // Read dosage + patient records

#define MAX_PASSWD_ENTRIES 16
#define PASSWD_FILE "/etc/passwd"
// NOTE: Using djb2 polynomial hash (not XOR). SHA-256 recommended
// for production — noted as known limitation in final report.
#define HASH_LEN 32

// Per-process credential structure.
// WHY: Storing credentials INSIDE the process struct means the
// kernel always knows who is making a syscall without ever
// trusting user space to report its own identity (PoLP).
struct proc_creds {
    int  uid;            // User ID: 0=admin, 1=patient, 2=doctor
    int  gid;            // Group ID (mirrors uid in this project)
    int  role;           // Role enum (mirrors uid for this project)
    int  authenticated;  // 1 if successfully logged in, 0 if not
    char username[32];   // Human-readable name for audit log entries
};

// ================================================================
// ORIGINAL xv6 STRUCTS — DO NOT MODIFY
// ================================================================

// Saved registers for kernel context switches.
struct context {
  uint64 ra;
  uint64 sp;

  // callee-saved
  uint64 s0;
  uint64 s1;
  uint64 s2;
  uint64 s3;
  uint64 s4;
  uint64 s5;
  uint64 s6;
  uint64 s7;
  uint64 s8;
  uint64 s9;
  uint64 s10;
  uint64 s11;
};

// Per-CPU state.
struct cpu {
  struct proc *proc;      // The process running on this cpu, or null.
  struct context context; // swtch() here to enter scheduler().
  int noff;               // Depth of push_off() nesting.
  int intena;             // Were interrupts enabled before push_off()?
};

extern struct cpu cpus[NCPU];

// per-process data for the trap handling code in trampoline.S.
// sits in a page by itself just under the trampoline page in the
// user page table. not specially mapped in the kernel page table.
// uservec in trampoline.S saves user registers in the trapframe,
// then initializes registers from the trapframe's
// kernel_sp, kernel_hartid, kernel_satp, and jumps to kernel_trap.
// usertrapret() and userret in trampoline.S set up
// the trapframe's kernel_*, restore user registers from the
// trapframe, switch to the user page table, and enter user space.
// the trapframe includes callee-saved user registers like s0-s11
// because the return-to-user path via usertrapret() doesn't return
// through the entire kernel call stack.
struct trapframe {
  /*   0 */ uint64 kernel_satp;   // kernel page table
  /*   8 */ uint64 kernel_sp;     // top of process's kernel stack
  /*  16 */ uint64 kernel_trap;   // usertrap()
  /*  24 */ uint64 epc;           // saved user program counter
  /*  32 */ uint64 kernel_hartid; // saved kernel tp
  /*  40 */ uint64 ra;
  /*  48 */ uint64 sp;
  /*  56 */ uint64 gp;
  /*  64 */ uint64 tp;
  /*  72 */ uint64 t0;
  /*  80 */ uint64 t1;
  /*  88 */ uint64 t2;
  /*  96 */ uint64 s0;
  /* 104 */ uint64 s1;
  /* 112 */ uint64 a0;
  /* 120 */ uint64 a1;
  /* 128 */ uint64 a2;
  /* 136 */ uint64 a3;
  /* 144 */ uint64 a4;
  /* 152 */ uint64 a5;
  /* 160 */ uint64 a6;
  /* 168 */ uint64 a7;
  /* 176 */ uint64 s2;
  /* 184 */ uint64 s3;
  /* 192 */ uint64 s4;
  /* 200 */ uint64 s5;
  /* 208 */ uint64 s6;
  /* 216 */ uint64 s7;
  /* 224 */ uint64 s8;
  /* 232 */ uint64 s9;
  /* 240 */ uint64 s10;
  /* 248 */ uint64 s11;
  /* 256 */ uint64 t3;
  /* 264 */ uint64 t4;
  /* 272 */ uint64 t5;
  /* 280 */ uint64 t6;
};

enum procstate { UNUSED, USED, SLEEPING, RUNNABLE, RUNNING, ZOMBIE };

// ================================================================
// struct proc — Extended with security fields at the bottom
// ================================================================
// Per-process state
struct proc {
  struct spinlock lock;

  // p->lock must be held when using these:
  enum procstate state;        // Process state
  void *chan;                  // If non-zero, sleeping on chan
  int killed;                  // If non-zero, have been killed
  int xstate;                  // Exit status to be returned to parent's wait
  int pid;                     // Process ID

  // wait_lock must be held when using this:
  struct proc *parent;         // Parent process

  // these are private to the process, so p->lock need not be held.
  uint64 kstack;               // Virtual address of kernel stack
  uint64 sz;                   // Size of process memory (bytes)
  pagetable_t pagetable;       // User page table
  struct trapframe *trapframe; // data page for trampoline.S
  struct context context;      // swtch() here to run process
  struct file *ofile[NOFILE];  // Open files
  struct inode *cwd;           // Current directory
  char name[16];               // Process name (debugging)

  // ── NEW SECURITY FIELDS (Phase 1) ──────────────────────────
  // WHY at the end: appending new fields never shifts the offsets
  // of existing fields, so all existing kernel code that accesses
  // proc members by name continues to work without recompilation.

  struct proc_creds creds;     // Authentication credentials (uid/gid/role)

  uint64 stack_canary;         // Stack overflow detection (simplified ASLR/canary)
                               // Set to 0xDEADBEEFCAFEBABE at login.
                               // In production: use a per-boot random value.
  // ────────────────────────────────────────────────────────────
};
