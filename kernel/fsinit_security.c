// fsinit_security.c — Set hardcoded permissions for medical device files
// Called from fsinit() after the filesystem is mounted
// WHY hardcoded: Critical paths must have known-safe permissions at boot;
// relying on user-space setup risks a window where files are unprotected

#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "fs.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "file.h"
#include "proc.h"

// Helper: set permissions on a path (must be called with no locks held)
static void
secure_path(char *path, uint uid, uint gid, uint mode)
{
    struct inode *ip = namei(path);
    if (ip == 0) {
        printf("fsinit_security: warning: %s not found\n", path);
        return;
    }
    ilock(ip);
    ip->uid  = uid;
    ip->gid  = gid;
    ip->mode = mode;
    iupdate(ip);
    iunlock(ip);

    iput(ip);
}

void
fsinit_security(void)
{
    // WHY these specific permissions (course rubric + PoLP):
    //
    // /records:
    //   uid=1 (PATIENT) read-only → mode=0400
    //   DOCTOR also needs read → use group bits: mode=0440, gid=2
    begin_op();
    secure_path("/records",
                ROLE_PATIENT /*uid*/,
                ROLE_DOCTOR  /*gid*/,
                0440 /*r--r-----*/);

    // /insulin.log:
    //   uid=2 (DOCTOR) Write, uid=1 (PATIENT) Read
    secure_path("/insulin.log",
                ROLE_DOCTOR  /*uid*/,
                ROLE_PATIENT /*gid*/,
                0640 /*rw-r-----*/);

    // /config:
    //   UID 0 (ADMIN) only → mode=0600
    secure_path("/config",
                ROLE_ADMIN, ROLE_ADMIN,
                0600 /*rw-------*/);

    // /syscall.log:
    //   UID 0 (ADMIN) only → mode=0600 (read-write for persistent logging)
    secure_path("/syscall.log",
                ROLE_ADMIN, ROLE_ADMIN,
                0600 /*rw-------*/);
    end_op();

    printf("fsinit_security: medical device file permissions applied\n");
}
