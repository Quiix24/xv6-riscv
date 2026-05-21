// auth.h — Credential storage format for xv6 security project
// Why separate file: separation of concerns, easier to audit

#ifndef AUTH_H
#define AUTH_H

#include "spinlock.h"

#define AUTH_MAX_USERS   8
#define AUTH_NAME_LEN   32
#define AUTH_HASH_LEN   64

// On-disk password entry format
// Mirrors /etc/passwd philosophy: structured, one user per line
// Format: username:hash:uid:gid:role
struct passwd_entry {
    char username[AUTH_NAME_LEN];
    char passhash[AUTH_HASH_LEN];  // Stored as hex string
    int  uid;
    int  gid;
    int  role;
    int  valid;                    // 1 if slot is in use
};

// In-memory user table (capability list in RAM — per rubric requirement)
// Why RAM copy: disk I/O on every auth check would be too slow;
// this is the "capability list" component of the hybrid ACL approach
struct user_table {
    struct passwd_entry entries[AUTH_MAX_USERS];
    int count;
    struct spinlock lock;
};

#endif