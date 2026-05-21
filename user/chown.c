#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  if(argc < 4){
    fprintf(2, "Usage: chown <uid> <gid> <file>\n");
    exit(1);
  }

  // Simple decimal parsing for uid
  int uid = 0;
  char *s = argv[1];
  while(*s){
    if(*s >= '0' && *s <= '9'){
      uid = uid * 10 + (*s - '0');
      s++;
    } else {
      fprintf(2, "chown: uid must be numeric\n");
      exit(1);
    }
  }

  // Simple decimal parsing for gid
  int gid = 0;
  s = argv[2];
  while(*s){
    if(*s >= '0' && *s <= '9'){
      gid = gid * 10 + (*s - '0');
      s++;
    } else {
      fprintf(2, "chown: gid must be numeric\n");
      exit(1);
    }
  }

  if(chown(argv[3], uid, gid) < 0){
    fprintf(2, "chown: cannot change %s\n", argv[3]);
    exit(1);
  }
  
  exit(0);
}
