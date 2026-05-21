#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  if(argc != 5){
    fprintf(2, "Usage: useradd username password uid gid\n");
    exit(1);
  }

  if(useradd(argv[1], argv[2], atoi(argv[3]), atoi(argv[4])) < 0){
    fprintf(2, "useradd failed\n");
    exit(1);
  }

  exit(0);
}
