#include "kernel/types.h"
#include "user/user.h"

int
main(void)
{
  int uid = whoami();
  if(uid < 0) {
    printf("whoami: error getting uid\n");
    exit(1);
  }
  
  const char *role;
  switch(uid) {
    case 0: role = "ADMIN"; break;
    case 1: role = "PATIENT"; break;
    case 2: role = "DOCTOR"; break;
    default: role = "UNKNOWN"; break;
  }

  printf("Current UID: %d (Role: %s)\n", uid, role);
  exit(0);
}
