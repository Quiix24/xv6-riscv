#ifndef AUDIT_H
#define AUDIT_H

#define AUDIT_MAX        256          // Ring buffer capacity
#define AUDIT_MSG_LEN    128          // Max message length per entry
#define AUDIT_FILE       "/audit/syscall.log"

struct audit_entry {
    int   pid;                        // Process ID
    int   uid;                        // User ID at time of call
    int   syscall_num;                // Which syscall was called
    char  syscall_name[32];           // Human-readable name
    char  message[AUDIT_MSG_LEN];     // Event details
    uint  timestamp;                  // Kernel tick count
    int   valid;                      // Slot occupied?
};

struct audit_ring {
    struct audit_entry buf[AUDIT_MAX];
    int    head;                      // Write pointer
    int    tail;                      // Read pointer
    int    count;                     // Entries in buffer
    struct spinlock lock;
};

#endif
