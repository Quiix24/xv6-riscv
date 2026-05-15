#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(void) {
    printf("Hello from xv6! Security project initialized.\n");
    printf("PID: %d\n", getpid());
    exit(0);
}
