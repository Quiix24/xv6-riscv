// audit_read.c — User-space tool to read and display audit log
// Usage: audit_read
// ADMIN only — displays all audit entries in the ring buffer

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/syscall.h"

// User-space mirror of kernel audit_entry struct
#define AUDIT_MSG_LEN 128
struct audit_entry {
    int   pid;                        // Process ID
    int   uid;                        // User ID at time of call
    int   syscall_num;                // Which syscall was called
    char  syscall_name[32];           // Human-readable name
    char  message[AUDIT_MSG_LEN];     // Event details
    uint  timestamp;                  // Kernel tick count
    int   valid;                      // Slot occupied?
};

// Static buffer (not on stack)
static char buf[4096];

int
main(void)
{
    // Call sys_audit_read syscall
    int n = audit_read(buf, 4096);
    
    if (n < 0) {
        printf("audit_read: ERROR — permission denied (admin only)\n");
        exit(1);
    }
    
    if (n == 0) {
        printf("audit_read: No entries in audit log\n");
        exit(0);
    }
    
    // Parse and display entries
    struct audit_entry *entries = (struct audit_entry *)buf;
    int num_entries = n / sizeof(struct audit_entry);
    
    printf("\n");
    printf("════════════════════════════════════════════════════════════\n");
    printf("                    AUDIT LOG DUMP                           \n");
    printf("════════════════════════════════════════════════════════════\n");
    printf("Total entries: %d bytes (%d entries)\n\n", n, num_entries);
    printf("PID | UID | SYSCALL | SYSCALL_NAME | MESSAGE\n");
    printf("──────────────────────────────────────────────────────────────\n");
    
    for (int i = 0; i < num_entries; i++) {
        struct audit_entry *e = &entries[i];
        if (!e->valid) continue;
        
        printf("%d | %d | %d | %s | %s\n",
               e->pid,
               e->uid,
               e->syscall_num,
               e->syscall_name,
               e->message);
    }
    
    printf("════════════════════════════════════════════════════════════\n\n");
    
    exit(0);
}
