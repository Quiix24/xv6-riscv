#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "proc.h"
#include "audit.h"
#include "syscall.h"
#include "fs.h"
#include "file.h"

// Global ring buffer — lives in kernel BSS segment
struct audit_ring g_audit;

// Syscall number to name mapping
// WHY named mapping: Raw numbers in logs are useless for a compliance report;
// human-readable names make the audit log directly actionable
static const char *syscall_names[] = {
    [SYS_fork]       = "fork",
    [SYS_exit]       = "exit",
    [SYS_wait]       = "wait",
    [SYS_pipe]       = "pipe",
    [SYS_read]       = "read",
    [SYS_kill]       = "kill",
    [SYS_exec]       = "exec",
    [SYS_fstat]      = "fstat",
    [SYS_chdir]      = "chdir",
    [SYS_dup]        = "dup",
    [SYS_getpid]     = "getpid",
    [SYS_sbrk]       = "sbrk",
    [SYS_pause]      = "pause",
    [SYS_uptime]     = "uptime",
    [SYS_open]       = "open",
    [SYS_write]      = "write",
    [SYS_mknod]      = "mknod",
    [SYS_unlink]     = "unlink",
    [SYS_link]       = "link",
    [SYS_mkdir]      = "mkdir",
    [SYS_close]      = "close",
    [SYS_login]      = "login",
    [SYS_useradd]    = "useradd",
    [SYS_userdel]    = "userdel",
    [SYS_passwd]     = "passwd",
    [SYS_whoami]     = "whoami",
    [SYS_chmod]      = "chmod",
    [SYS_chown]      = "chown",
    [SYS_audit_read] = "audit_read",
};
#define NUM_SYSCALLS (sizeof(syscall_names)/sizeof(syscall_names[0]))

// =============================================================
// audit_init — Called from main() at boot
// =============================================================
void
audit_init(void)
{
    initlock(&g_audit.lock, "audit");
    g_audit.head  = 0;
    g_audit.tail  = 0;
    g_audit.count = 0;
    // Clear buffer
    for (int i = 0; i < AUDIT_MAX; i++)
        g_audit.buf[i].valid = 0;
}

// =============================================================
// audit_write_to_file — Write a log line to /audit/syscall.log
// Simple persistent logging - appends text to file
// =============================================================
static void
audit_write_to_file(int pid, int uid, int syscall_num, 
                   const char *syscall_name, const char *message)
{
    // Build log line in buffer
    char line[128];
    int off = 0;
    
    // Format: PID|UID|SYSCALL_NUM|NAME|MSG
    // Since xv6 lacks snprintf, manually build string
    
    // PID (simple)
    if (pid < 10) line[off++] = '0' + pid;
    else {
        line[off++] = '0' + (pid / 10);
        line[off++] = '0' + (pid % 10);
    }
    line[off++] = '|';
    
    // UID
    if (uid < 10) line[off++] = '0' + uid;
    else {
        line[off++] = '0' + (uid / 10);
        line[off++] = '0' + (uid % 10);
    }
    line[off++] = '|';
    
    // SYSCALL_NUM
    if (syscall_num < 10) line[off++] = '0' + syscall_num;
    else {
        line[off++] = '0' + (syscall_num / 10);
        line[off++] = '0' + (syscall_num % 10);
    }
    line[off++] = '|';
    
    // Syscall name
    for (int i = 0; syscall_name[i] && off < 100; i++)
        line[off++] = syscall_name[i];
    line[off++] = '|';
    
    // Message  
    for (int i = 0; message[i] && off < 118; i++)
        line[off++] = message[i];
    line[off++] = '\n';
    
    // Open and append to file (file is in root as syscall.log)
    struct inode *ip = namei("syscall.log");
    if (!ip) return;
    
    // Filesystem writes must be wrapped in transaction
    begin_op();
    ilock(ip);
    
    // Write at end of file
    // writei(inode*, user_src, src_buffer, offset, nbytes)
    if (writei(ip, 0, (uint64)line, ip->size, off) > 0) {
        ip->size += off;  // Update size
    }
    
    iunlock(ip);
    end_op();
    iput(ip);
}

// =============================================================
// audit_log_event — Write an event to ring buffer AND disk file
// Called from anywhere in the kernel (interrupt-safe via spinlock)
// =============================================================
void
audit_log_event(int pid, int uid, int syscall_num, const char *message)
{
    acquire(&g_audit.lock);

    struct audit_entry *e = &g_audit.buf[g_audit.head];

    e->pid         = pid;
    e->uid         = uid;
    e->syscall_num = syscall_num;

    // Resolve syscall name
    if (syscall_num >= 0 && syscall_num < (int)NUM_SYSCALLS &&
        syscall_names[syscall_num]) {
        safestrcpy(e->syscall_name, syscall_names[syscall_num], 32);
    } else {
        safestrcpy(e->syscall_name, "unknown", 32);
    }

    safestrcpy(e->message, message ? message : "", AUDIT_MSG_LEN);
    e->timestamp = ticks;  // Kernel tick counter (defined in trap.c)
    e->valid     = 1;

    // Advance write pointer (wrap around — ring buffer)
    g_audit.head = (g_audit.head + 1) % AUDIT_MAX;

    // If buffer is full, overwrite oldest (tail advances too)
    // WHY: We prefer losing old entries over dropping current events
    if (g_audit.count < AUDIT_MAX) {
        g_audit.count++;
    } else {
        // Overwrite: advance tail to discard oldest
        g_audit.tail = (g_audit.tail + 1) % AUDIT_MAX;
        printf("audit: WARNING: ring buffer full, oldest entry dropped\n");
    }

    release(&g_audit.lock);
    
    // ALSO write to disk file (outside lock to avoid holding lock during I/O)
    audit_write_to_file(pid, uid, syscall_num, e->syscall_name, message);
}

// =============================================================
// sys_audit_read — Export audit log to user space (ADMIN only)
// Returns -1 (EPERM) if caller is not uid=0
// =============================================================
uint64
sys_audit_read(void)
{
    struct proc *p = myproc();

    // WHY hard block on non-admin: audit logs contain sensitive
    // operational data; a patient or doctor reading it could learn
    // timing patterns about the insulin pump's behavior
    if (p->creds.uid != ROLE_ADMIN) {
        audit_log_event(p->pid, p->creds.uid, SYS_audit_read,
                        "DENIED:audit_read_eperm");
        return -1;  // EPERM
    }

    // Arguments: user buffer pointer, max bytes to copy
    uint64 user_buf;
    int    max_bytes;
    if (argaddr(0, &user_buf) < 0 || argint(1, &max_bytes) < 0)
        return -1;

    // Serialize ring buffer into text format for user space
    // WHY text format: easier for user-space to display/parse;
    // binary format would require matching structs
    int  written = 0;

    acquire(&g_audit.lock);

    int idx   = g_audit.tail;
    int count = g_audit.count;

    for (int i = 0; i < count && written < max_bytes - 1; i++) {
        struct audit_entry *e = &g_audit.buf[idx];
        if (e->valid) {
            // Format: [tick] PID=X UID=X SYSCALL=name | message
            // In real implementation use snprintf; xv6 lacks it,
            // so we construct manually or use a simple formatter
            // We output raw struct and format in user space for simplicity
            // Copy one entry at a time
            if (written + (int)sizeof(struct audit_entry) <= max_bytes) {
                if (copyout(p->pagetable, user_buf + written,
                            (char*)e, sizeof(struct audit_entry)) < 0)
                    break;
                written += sizeof(struct audit_entry);
            }
        }
        idx = (idx + 1) % AUDIT_MAX;
    }

    release(&g_audit.lock);
    return written;
}
