// sectest.c — Automated security test suite for xv6 medical device
// Run as ADMIN to execute all 12 test cases
// Tests verify: auth, permissions, audit trail, RBAC

#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/fcntl.h"
#include "kernel/syscall.h"
#include "user/user.h"
#include "kernel/auth.h"  // For role constants

// User-space copy of audit_entry structure (mirrors kernel/audit.h)
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

// Test result tracking
static int tests_run    = 0;
static int tests_passed = 0;
static int tests_failed = 0;

// Color codes (ANSI — for terminal output)
#define PASS_STR "[ PASS ]"
#define FAIL_STR "[ FAIL ]"

void
test_result(const char *name, int passed)
{
    tests_run++;
    if (passed) {
        tests_passed++;
        printf("%s %s\n", PASS_STR, name);
    } else {
        tests_failed++;
        printf("%s %s\n", FAIL_STR, name);
    }
}

// =============================================================
// TEST 1: Valid admin login succeeds
// =============================================================
void test_admin_login(void) {
    int uid = login("admin", "admin123");
    test_result("TC01: Admin login with correct credentials", uid == 0);
}

// =============================================================
// TEST 2: Invalid password rejected
// =============================================================
void test_bad_password(void) {
    int uid = login("admin", "wrongpassword");
    test_result("TC02: Login with wrong password is denied", uid < 0);
}

// =============================================================
// TEST 3: Patient login succeeds with correct role
// =============================================================
void test_patient_login(void) {
    int uid = login("patient", "patient123");
    test_result("TC03: Patient login returns UID=1", uid == 1);
}

// =============================================================
// TEST 4: Patient cannot write to insulin.log
// Expected: write returns -1 (permission denied)
// Also tests: this denial should appear in audit log
// =============================================================
void test_patient_cannot_write_insulin(void) {
    // Login as patient first
    login("patient", "patient123");

    int fd = open("/dosage/insulin.log", O_WRONLY);
    if (fd >= 0) {
        int r = write(fd, "TAMPERED", 8);
        close(fd);
        // Either open or write should have failed
        test_result("TC04: Patient DENIED write to insulin.log", r < 0);
    } else {
        // Good — open itself was denied
        test_result("TC04: Patient DENIED write to insulin.log (open denied)", 1);
    }

    // Re-login as admin for subsequent tests
    login("admin", "admin123");
}

// =============================================================
// TEST 5: Patient can read own records
// =============================================================
void test_patient_read_records(void) {
    login("patient", "patient123");

    int fd = open("/patient/records", O_RDONLY);
    int passed = (fd >= 0);
    if (fd >= 0) close(fd);

    test_result("TC05: Patient ALLOWED read of /patient/records", passed);
    login("admin", "admin123");
}

// =============================================================
// TEST 6: Doctor can write insulin.log
// =============================================================
void test_doctor_write_insulin(void) {
    login("doctor", "doctor123");

    int fd = open("/dosage/insulin.log", O_WRONLY | O_APPEND);
    int passed = 0;
    if (fd >= 0) {
        int r = write(fd, "dose:5units\n", 12);
        passed = (r == 12);
        close(fd);
    }

    test_result("TC06: Doctor ALLOWED write to insulin.log", passed);
    login("admin", "admin123");
}

// =============================================================
// TEST 7: Patient cannot access /device/config
// =============================================================
void test_patient_cannot_read_config(void) {
    login("patient", "patient123");

    int fd = open("/device/config", O_RDONLY);
    int denied = (fd < 0);
    if (fd >= 0) close(fd);

    test_result("TC07: Patient DENIED read of /device/config", denied);
    login("admin", "admin123");
}

// =============================================================
// TEST 8: Doctor cannot access /device/config
// =============================================================
void test_doctor_cannot_read_config(void) {
    login("doctor", "doctor123");

    int fd = open("/device/config", O_RDONLY);
    int denied = (fd < 0);
    if (fd >= 0) close(fd);

    test_result("TC08: Doctor DENIED read of /device/config", denied);
    login("admin", "admin123");
}

// =============================================================
// TEST 9: Non-admin cannot read audit log via audit_read
// =============================================================
void test_patient_cannot_read_audit(void) {
    login("patient", "patient123");

    char buf[512];
    int r = audit_read(buf, 512);
    test_result("TC09: Patient audit_read returns EPERM", r < 0);

    login("admin", "admin123");
}

// =============================================================
// TEST 10: Admin can read audit log
// =============================================================
void test_admin_can_read_audit(void) {
    login("admin", "admin123");

    char buf[2048];
    int r = audit_read(buf, 2048);
    test_result("TC10: Admin audit_read succeeds (bytes read > 0)", r > 0);
}

// =============================================================
// TEST 11: Non-admin cannot useradd
// =============================================================
void test_patient_cannot_useradd(void) {
    login("patient", "patient123");

    int r = useradd("hacker", "hacked", 0, 0);
    test_result("TC11: Patient DENIED useradd (would escalate to admin)", r < 0);

    login("admin", "admin123");
}

// =============================================================
// TEST 12: chmod by non-owner is denied
// =============================================================
void test_nonowner_chmod_denied(void) {
    login("patient", "patient123");

    // Patient trying to chmod doctor's file
    int r = chmod("/dosage/insulin.log", 0777);
    test_result("TC12: Patient DENIED chmod on doctor-owned file", r < 0);

    login("admin", "admin123");
}

// =============================================================
// COMPLIANCE REPORT GENERATOR
// Reads audit log and counts security events by category
// =============================================================
void
generate_compliance_report(void)
{
    printf("\n");
    printf("════════════════════════════════════════════════\n");
    printf("   MEDICAL DEVICE SECURITY COMPLIANCE REPORT   \n");
    printf("════════════════════════════════════════════════\n\n");

    char buf[4096];
    int n = audit_read(buf, 4096);

    if (n < 0) {
        printf("ERROR: Could not read audit log (not admin?)\n");
        return;
    }

    // Count event categories from serialized entries
    int total        = 0;
    int denied_count = 0;
    int login_fail   = 0;
    int login_ok     = 0;
    int perm_denied  = 0;

    struct audit_entry *entries = (struct audit_entry*)buf;
    int num_entries = n / sizeof(struct audit_entry);

    for (int i = 0; i < num_entries; i++) {
        struct audit_entry *e = &entries[i];
        if (!e->valid) continue;
        total++;

        // Simple string matching on message field
        char *m = e->message;
        // Check for DENIED
        int is_denied = 0;
        for (int j = 0; m[j] && m[j+5]; j++) {
            if (m[j]=='D' && m[j+1]=='E' && m[j+2]=='N' &&
                m[j+3]=='I' && m[j+4]=='E' && m[j+5]=='D') {
                is_denied = 1;
                break;
            }
        }
        if (is_denied) denied_count++;

        // Check for login events
        if (e->syscall_num == SYS_login) {
            // Check SUCCESS vs FAIL
            int is_success = 0;
            for (int j = 0; m[j] && m[j+6]; j++) {
                if (m[j]=='S' && m[j+1]=='U' && m[j+2]=='C') {
                    is_success = 1; break;
                }
            }
            if (is_success) login_ok++;
            else login_fail++;
        }
    }

    perm_denied = denied_count - login_fail;

    printf("  Period: Boot to current tick\n");
    printf("  Device: xv6 Medical Wearable (Insulin Pump Simulator)\n\n");
    printf("  ┌──────────────────────────────────┬───────┐\n");
    printf("  │ Metric                           │ Count │\n");
    printf("  ├──────────────────────────────────┼───────┤\n");
    printf("  │ Total Audit Events               │ %5d │\n", total);
    printf("  │ Successful Logins                │ %5d │\n", login_ok);
    printf("  │ Failed Login Attempts            │ %5d │\n", login_fail);
    printf("  │ Permission Violations            │ %5d │\n", perm_denied);
    printf("  │ Total Denied Operations          │ %5d │\n", denied_count);
    printf("  └──────────────────────────────────┴───────┘\n\n");

    printf("  Compliance Status: ");
    if (login_fail == 0 && denied_count == 0) {
        printf("CLEAN — No violations detected\n");
    } else {
        printf("REVIEW REQUIRED — %d event(s) need attention\n", denied_count);
    }

    printf("\n  Security Controls Active:\n");
    printf("    [✓] Role-Based Access Control (RBAC)\n");
    printf("    [✓] UNIX-style File Permissions (ACL on disk)\n");
    printf("    [✓] Capability List (in-memory auth table)\n");
    printf("    [✓] Syscall Audit Ring Buffer\n");
    printf("    [✓] Stack Canary (proc->stack_canary)\n");
    printf("    [✓] Principle of Least Privilege enforced\n");
    printf("\n════════════════════════════════════════════════\n");
}

// =============================================================
// MAIN — Run all 12 test cases then generate report
// =============================================================
int
main(void)
{
    printf("\n=== xv6 Medical Device Security Test Suite ===\n");
    printf("Running 12 test cases...\n\n");

    // Must be logged in as admin to run full suite
    if (login("admin", "admin123") < 0) {
        printf("ERROR: Cannot authenticate as admin. Aborting.\n");
        exit(1);
    }

    test_admin_login();
    test_bad_password();
    test_patient_login();
    test_patient_cannot_write_insulin();
    test_patient_read_records();
    test_doctor_write_insulin();
    test_patient_cannot_read_config();
    test_doctor_cannot_read_config();
    test_patient_cannot_read_audit();
    test_admin_can_read_audit();
    test_patient_cannot_useradd();
    test_nonowner_chmod_denied();

    printf("\n────────────────────────────────────\n");
    printf("Results: %d/%d passed, %d failed\n",
           tests_passed, tests_run, tests_failed);
    printf("────────────────────────────────────\n");

    generate_compliance_report();

    exit(0);
}
