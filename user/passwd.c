#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  if(argc != 4){
    fprintf(2, "Usage: passwd username old_pw new_pw\n");
    exit(1);
  }

  if(passwd(argv[1], argv[2], argv[3]) < 0){
    fprintf(2, "passwd failed\n");
    exit(1);
  }

  exit(0);
}
