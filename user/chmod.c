#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  if(argc < 3){
    fprintf(2, "Usage: chmod <mode> <file>\n");
    exit(1);
  }

  // Convert octal mode string to integer
  // chmod 755 /config -> mode=0755 (octal)
  int mode = 0;
  char *s = argv[1];
  
  while(*s){
    if(*s >= '0' && *s <= '7'){
      mode = (mode << 3) | (*s - '0');
      s++;
    } else {
      fprintf(2, "chmod: mode must be octal (0-7)\n");
      exit(1);
    }
  }

  if(chmod(argv[2], mode) < 0){
    fprintf(2, "chmod: cannot change %s\n", argv[2]);
    exit(1);
  }
  
  exit(0);
}
