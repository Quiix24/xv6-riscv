// init.c — Modified to enforce authentication before shell access
// WHY: init is PID 1; making it the gatekeeper ensures no process
// can reach a shell without passing through our auth layer.

#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/spinlock.h"
#include "kernel/sleeplock.h"
#include "kernel/fs.h"
#include "kernel/file.h"
#include "user/user.h"
#include "kernel/fcntl.h"

// === NEW: Login prompt function ===
// Returns the authenticated UID, loops until success
static int
do_login(void)
{
    char username[32];
    char password[32];
    int  uid;
    int  attempts = 0;
    int  max_attempts = 3;  // Lockout after 3 failures (PoLP)

    printf("\n");
    printf("╔══════════════════════════════════════╗\n");
    printf("║  xv6 Medical Device Security System  ║\n");
    printf("║  Authorized Access Only              ║\n");
    printf("╚══════════════════════════════════════╝\n\n");

    while (attempts < max_attempts) {
        printf("login: ");
        // Read username — gets() is safe here since we control the buffer size
        gets(username, 32);
        // Strip newline
        for (int i = 0; username[i]; i++) {
            if (username[i] == '\n') { username[i] = '\0'; break; }
        }

        printf("password: ");
        // Note: In a real system, disable echo here via termios
        // xv6 doesn't support full termios, so password is visible
        gets(password, 32);
        for (int i = 0; password[i]; i++) {
            if (password[i] == '\n') { password[i] = '\0'; break; }
        }

        uid = login(username, password);

        if (uid >= 0) {
            printf("\nWelcome, %s! Role: %s\n",
                   username,
                   uid == 0 ? "ADMIN" :
                   uid == 1 ? "PATIENT" : "DOCTOR");
            printf("Session authenticated. Launching shell...\n\n");
            return uid;
        }

        attempts++;
        printf("Authentication failed. %d attempt(s) remaining.\n\n",
               max_attempts - attempts);

        // Progressive delay would go here (requires sleep syscall)
    }

    printf("Maximum attempts exceeded. System locked.\n");
    // In production: trigger alert, power off, or watchdog reset
    for (;;) {
        // Spin forever — device locked
    }
}

char *sh_argv[] = { "sh", 0 };

int
main(void)
{
    int pid, wpid;

    // Standard init setup — open console
    if (open("console", O_RDWR) < 0) {
        mknod("console", CONSOLE, 0);
        open("console", O_RDWR);
    }
    dup(0);  // stdout
    dup(0);  // stderr

    // === AUTHENTICATION GATE ===
    // Loop ensures the shell is only spawned post-authentication
    for (;;) {
        int auth_uid = do_login();  // Blocks until valid credentials
        printf("[INIT] Authenticated as uid=%d, about to fork\n", auth_uid);

        pid = fork();
        printf("[INIT] fork() returned pid=%d\n", pid);
        if (pid < 0) {
            printf("init: fork failed\n");
            exit(1);
        }

        if (pid == 0) {
            // Child: the authenticated shell inherits parent's uid
            // because fork() copies struct proc including creds
            printf("[CHILD] Child process, about to exec sh\n");
            exec("sh", sh_argv);
            printf("init: exec sh failed\n");
            exit(1);
        }

        // Parent: wait for shell to exit, then re-prompt login
        for (;;) {
            wpid = wait((int*)0);
            if (wpid == pid) {
                // Shell exited — go back to login prompt
                printf("\nSession ended. Please log in again.\n");
                break;
            }
        }
    }
}

