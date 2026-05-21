#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "fs.h"
#include "file.h"
#include "proc.h"
#include "auth.h"

// Global in-memory user table — the "capability list in RAM"
struct user_table g_users;

// =============================================================
// Simple password hashing
// WHY: Real systems use bcrypt/scrypt. xv6 lacks crypto libs,
// so we use a polynomial hash. Note this in your report as a
// known limitation with a recommendation to use SHA-256.
// =============================================================
void
hash_password(const char *password, char *out_hash)
{
    uint64 h = 5381;
    int c;
    const char *p = password;

    while ((c = *p++) != 0) {
        h = ((h << 5) + h) + c;  // h * 33 + c (djb2)
    }

    // Encode as 16-char hex string
    // In production: replace with proper cryptographic hash
    char hex[] = "0123456789abcdef";
    for (int i = 0; i < 16; i++) {
        out_hash[i * 2]     = hex[(h >> (60 - i * 4)) & 0xF];
        out_hash[i * 2 + 1] = hex[(h >> (56 - i * 4)) & 0xF];
    }
    out_hash[32] = '\0';
}

// =============================================================
// auth_init — Called from main() during boot
// Populates the in-memory user table with default credentials
// =============================================================
void
auth_init(void)
{
    initlock(&g_users.lock, "auth");
    g_users.count = 0;

    // Seed default users — in production these come from /etc/passwd
    // ADMIN user
    struct passwd_entry *e = &g_users.entries[g_users.count++];
    safestrcpy(e->username, "admin", AUTH_NAME_LEN);
    hash_password("admin123", e->passhash);
    e->uid   = ROLE_ADMIN;
    e->gid   = 0;
    e->role  = ROLE_ADMIN;
    e->valid = 1;

    // PATIENT user
    e = &g_users.entries[g_users.count++];
    safestrcpy(e->username, "patient", AUTH_NAME_LEN);
    hash_password("patient123", e->passhash);
    e->uid   = ROLE_PATIENT;
    e->gid   = 1;
    e->role  = ROLE_PATIENT;
    e->valid = 1;

    // DOCTOR user
    e = &g_users.entries[g_users.count++];
    safestrcpy(e->username, "doctor", AUTH_NAME_LEN);
    hash_password("doctor123", e->passhash);
    e->uid   = ROLE_DOCTOR;
    e->gid   = 2;
    e->role  = ROLE_DOCTOR;
    e->valid = 1;
}

// =============================================================
// auth_verify — Check username + password, return uid or -1
// WHY kernel-side: user space must NEVER see the hash table
// directly — that would allow brute-force without audit trails
// =============================================================
int
auth_verify(const char *username, const char *password)
{
    char attempt_hash[AUTH_HASH_LEN];
    hash_password(password, attempt_hash);

    acquire(&g_users.lock);
    for (int i = 0; i < AUTH_MAX_USERS; i++) {
        struct passwd_entry *e = &g_users.entries[i];
        if (!e->valid) continue;
        if (strncmp(e->username, username, AUTH_NAME_LEN) == 0) {
            if (strncmp(e->passhash, attempt_hash, AUTH_HASH_LEN) == 0) {
                int uid = e->uid;
                release(&g_users.lock);
                return uid;  // Success
            }
            break;  // Username matched, password wrong
        }
    }
    release(&g_users.lock);
    return -1;  // Authentication failed
}

// =============================================================
// auth_add_user — Add a new user (ADMIN only, enforced by caller)
// =============================================================
int
auth_add_user(const char *username, const char *password, int uid, int gid)
{
    acquire(&g_users.lock);

    if (g_users.count >= AUTH_MAX_USERS) {
        release(&g_users.lock);
        return -1;  // Table full
    }

    // Check for duplicate username
    for (int i = 0; i < AUTH_MAX_USERS; i++) {
        if (g_users.entries[i].valid &&
            strncmp(g_users.entries[i].username, username, AUTH_NAME_LEN) == 0) {
            release(&g_users.lock);
            return -1;  // User exists
        }
    }

    // Find empty slot
    for (int i = 0; i < AUTH_MAX_USERS; i++) {
        if (!g_users.entries[i].valid) {
            safestrcpy(g_users.entries[i].username, username, AUTH_NAME_LEN);
            hash_password(password, g_users.entries[i].passhash);
            g_users.entries[i].uid   = uid;
            g_users.entries[i].gid   = gid;
            g_users.entries[i].role  = uid;  // role mirrors uid
            g_users.entries[i].valid = 1;
            g_users.count++;
            release(&g_users.lock);
            return 0;
        }
    }

    release(&g_users.lock);
    return -1;
}

// =============================================================
// auth_del_user — Remove user (ADMIN only)
// =============================================================
int
auth_del_user(const char *username)
{
    acquire(&g_users.lock);
    for (int i = 0; i < AUTH_MAX_USERS; i++) {
        if (g_users.entries[i].valid &&
            strncmp(g_users.entries[i].username, username, AUTH_NAME_LEN) == 0) {
            g_users.entries[i].valid = 0;
            g_users.count--;
            release(&g_users.lock);
            return 0;
        }
    }
    release(&g_users.lock);
    return -1;  // User not found
}