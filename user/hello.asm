
user/_hello:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(void) {
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    printf("Hello from xv6! Security project initialized.\n");
   8:	00001517          	auipc	a0,0x1
   c:	91850513          	addi	a0,a0,-1768 # 920 <malloc+0x100>
  10:	758000ef          	jal	768 <printf>
    printf("PID: %d\n", getpid());
  14:	34e000ef          	jal	362 <getpid>
  18:	85aa                	mv	a1,a0
  1a:	00001517          	auipc	a0,0x1
  1e:	93650513          	addi	a0,a0,-1738 # 950 <malloc+0x130>
  22:	746000ef          	jal	768 <printf>
    exit(0);
  26:	4501                	li	a0,0
  28:	2ba000ef          	jal	2e2 <exit>

000000000000002c <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  2c:	1141                	addi	sp,sp,-16
  2e:	e406                	sd	ra,8(sp)
  30:	e022                	sd	s0,0(sp)
  32:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  34:	fcdff0ef          	jal	0 <main>
  exit(r);
  38:	2aa000ef          	jal	2e2 <exit>

000000000000003c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  3c:	1141                	addi	sp,sp,-16
  3e:	e406                	sd	ra,8(sp)
  40:	e022                	sd	s0,0(sp)
  42:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  44:	87aa                	mv	a5,a0
  46:	0585                	addi	a1,a1,1
  48:	0785                	addi	a5,a5,1
  4a:	fff5c703          	lbu	a4,-1(a1)
  4e:	fee78fa3          	sb	a4,-1(a5)
  52:	fb75                	bnez	a4,46 <strcpy+0xa>
    ;
  return os;
}
  54:	60a2                	ld	ra,8(sp)
  56:	6402                	ld	s0,0(sp)
  58:	0141                	addi	sp,sp,16
  5a:	8082                	ret

000000000000005c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  5c:	1141                	addi	sp,sp,-16
  5e:	e406                	sd	ra,8(sp)
  60:	e022                	sd	s0,0(sp)
  62:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  64:	00054783          	lbu	a5,0(a0)
  68:	cb91                	beqz	a5,7c <strcmp+0x20>
  6a:	0005c703          	lbu	a4,0(a1)
  6e:	00f71763          	bne	a4,a5,7c <strcmp+0x20>
    p++, q++;
  72:	0505                	addi	a0,a0,1
  74:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  76:	00054783          	lbu	a5,0(a0)
  7a:	fbe5                	bnez	a5,6a <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  7c:	0005c503          	lbu	a0,0(a1)
}
  80:	40a7853b          	subw	a0,a5,a0
  84:	60a2                	ld	ra,8(sp)
  86:	6402                	ld	s0,0(sp)
  88:	0141                	addi	sp,sp,16
  8a:	8082                	ret

000000000000008c <strlen>:

uint
strlen(const char *s)
{
  8c:	1141                	addi	sp,sp,-16
  8e:	e406                	sd	ra,8(sp)
  90:	e022                	sd	s0,0(sp)
  92:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  94:	00054783          	lbu	a5,0(a0)
  98:	cf91                	beqz	a5,b4 <strlen+0x28>
  9a:	00150793          	addi	a5,a0,1
  9e:	86be                	mv	a3,a5
  a0:	0785                	addi	a5,a5,1
  a2:	fff7c703          	lbu	a4,-1(a5)
  a6:	ff65                	bnez	a4,9e <strlen+0x12>
  a8:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
  ac:	60a2                	ld	ra,8(sp)
  ae:	6402                	ld	s0,0(sp)
  b0:	0141                	addi	sp,sp,16
  b2:	8082                	ret
  for(n = 0; s[n]; n++)
  b4:	4501                	li	a0,0
  b6:	bfdd                	j	ac <strlen+0x20>

00000000000000b8 <memset>:

void*
memset(void *dst, int c, uint n)
{
  b8:	1141                	addi	sp,sp,-16
  ba:	e406                	sd	ra,8(sp)
  bc:	e022                	sd	s0,0(sp)
  be:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  c0:	ca19                	beqz	a2,d6 <memset+0x1e>
  c2:	87aa                	mv	a5,a0
  c4:	1602                	slli	a2,a2,0x20
  c6:	9201                	srli	a2,a2,0x20
  c8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  cc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  d0:	0785                	addi	a5,a5,1
  d2:	fee79de3          	bne	a5,a4,cc <memset+0x14>
  }
  return dst;
}
  d6:	60a2                	ld	ra,8(sp)
  d8:	6402                	ld	s0,0(sp)
  da:	0141                	addi	sp,sp,16
  dc:	8082                	ret

00000000000000de <strchr>:

char*
strchr(const char *s, char c)
{
  de:	1141                	addi	sp,sp,-16
  e0:	e406                	sd	ra,8(sp)
  e2:	e022                	sd	s0,0(sp)
  e4:	0800                	addi	s0,sp,16
  for(; *s; s++)
  e6:	00054783          	lbu	a5,0(a0)
  ea:	cf81                	beqz	a5,102 <strchr+0x24>
    if(*s == c)
  ec:	00f58763          	beq	a1,a5,fa <strchr+0x1c>
  for(; *s; s++)
  f0:	0505                	addi	a0,a0,1
  f2:	00054783          	lbu	a5,0(a0)
  f6:	fbfd                	bnez	a5,ec <strchr+0xe>
      return (char*)s;
  return 0;
  f8:	4501                	li	a0,0
}
  fa:	60a2                	ld	ra,8(sp)
  fc:	6402                	ld	s0,0(sp)
  fe:	0141                	addi	sp,sp,16
 100:	8082                	ret
  return 0;
 102:	4501                	li	a0,0
 104:	bfdd                	j	fa <strchr+0x1c>

0000000000000106 <gets>:

char*
gets(char *buf, int max)
{
 106:	711d                	addi	sp,sp,-96
 108:	ec86                	sd	ra,88(sp)
 10a:	e8a2                	sd	s0,80(sp)
 10c:	e4a6                	sd	s1,72(sp)
 10e:	e0ca                	sd	s2,64(sp)
 110:	fc4e                	sd	s3,56(sp)
 112:	f852                	sd	s4,48(sp)
 114:	f456                	sd	s5,40(sp)
 116:	f05a                	sd	s6,32(sp)
 118:	ec5e                	sd	s7,24(sp)
 11a:	e862                	sd	s8,16(sp)
 11c:	1080                	addi	s0,sp,96
 11e:	8baa                	mv	s7,a0
 120:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 122:	892a                	mv	s2,a0
 124:	4481                	li	s1,0
    cc = read(0, &c, 1);
 126:	faf40b13          	addi	s6,s0,-81
 12a:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 12c:	8c26                	mv	s8,s1
 12e:	0014899b          	addiw	s3,s1,1
 132:	84ce                	mv	s1,s3
 134:	0349d463          	bge	s3,s4,15c <gets+0x56>
    cc = read(0, &c, 1);
 138:	8656                	mv	a2,s5
 13a:	85da                	mv	a1,s6
 13c:	4501                	li	a0,0
 13e:	1bc000ef          	jal	2fa <read>
    if(cc < 1)
 142:	00a05d63          	blez	a0,15c <gets+0x56>
      break;
    buf[i++] = c;
 146:	faf44783          	lbu	a5,-81(s0)
 14a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 14e:	0905                	addi	s2,s2,1
 150:	ff678713          	addi	a4,a5,-10
 154:	c319                	beqz	a4,15a <gets+0x54>
 156:	17cd                	addi	a5,a5,-13
 158:	fbf1                	bnez	a5,12c <gets+0x26>
    buf[i++] = c;
 15a:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 15c:	9c5e                	add	s8,s8,s7
 15e:	000c0023          	sb	zero,0(s8)
  return buf;
}
 162:	855e                	mv	a0,s7
 164:	60e6                	ld	ra,88(sp)
 166:	6446                	ld	s0,80(sp)
 168:	64a6                	ld	s1,72(sp)
 16a:	6906                	ld	s2,64(sp)
 16c:	79e2                	ld	s3,56(sp)
 16e:	7a42                	ld	s4,48(sp)
 170:	7aa2                	ld	s5,40(sp)
 172:	7b02                	ld	s6,32(sp)
 174:	6be2                	ld	s7,24(sp)
 176:	6c42                	ld	s8,16(sp)
 178:	6125                	addi	sp,sp,96
 17a:	8082                	ret

000000000000017c <stat>:

int
stat(const char *n, struct stat *st)
{
 17c:	1101                	addi	sp,sp,-32
 17e:	ec06                	sd	ra,24(sp)
 180:	e822                	sd	s0,16(sp)
 182:	e04a                	sd	s2,0(sp)
 184:	1000                	addi	s0,sp,32
 186:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 188:	4581                	li	a1,0
 18a:	198000ef          	jal	322 <open>
  if(fd < 0)
 18e:	02054263          	bltz	a0,1b2 <stat+0x36>
 192:	e426                	sd	s1,8(sp)
 194:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 196:	85ca                	mv	a1,s2
 198:	1a2000ef          	jal	33a <fstat>
 19c:	892a                	mv	s2,a0
  close(fd);
 19e:	8526                	mv	a0,s1
 1a0:	16a000ef          	jal	30a <close>
  return r;
 1a4:	64a2                	ld	s1,8(sp)
}
 1a6:	854a                	mv	a0,s2
 1a8:	60e2                	ld	ra,24(sp)
 1aa:	6442                	ld	s0,16(sp)
 1ac:	6902                	ld	s2,0(sp)
 1ae:	6105                	addi	sp,sp,32
 1b0:	8082                	ret
    return -1;
 1b2:	57fd                	li	a5,-1
 1b4:	893e                	mv	s2,a5
 1b6:	bfc5                	j	1a6 <stat+0x2a>

00000000000001b8 <atoi>:

int
atoi(const char *s)
{
 1b8:	1141                	addi	sp,sp,-16
 1ba:	e406                	sd	ra,8(sp)
 1bc:	e022                	sd	s0,0(sp)
 1be:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1c0:	00054683          	lbu	a3,0(a0)
 1c4:	fd06879b          	addiw	a5,a3,-48
 1c8:	0ff7f793          	zext.b	a5,a5
 1cc:	4625                	li	a2,9
 1ce:	02f66963          	bltu	a2,a5,200 <atoi+0x48>
 1d2:	872a                	mv	a4,a0
  n = 0;
 1d4:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1d6:	0705                	addi	a4,a4,1
 1d8:	0025179b          	slliw	a5,a0,0x2
 1dc:	9fa9                	addw	a5,a5,a0
 1de:	0017979b          	slliw	a5,a5,0x1
 1e2:	9fb5                	addw	a5,a5,a3
 1e4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1e8:	00074683          	lbu	a3,0(a4)
 1ec:	fd06879b          	addiw	a5,a3,-48
 1f0:	0ff7f793          	zext.b	a5,a5
 1f4:	fef671e3          	bgeu	a2,a5,1d6 <atoi+0x1e>
  return n;
}
 1f8:	60a2                	ld	ra,8(sp)
 1fa:	6402                	ld	s0,0(sp)
 1fc:	0141                	addi	sp,sp,16
 1fe:	8082                	ret
  n = 0;
 200:	4501                	li	a0,0
 202:	bfdd                	j	1f8 <atoi+0x40>

0000000000000204 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 204:	1141                	addi	sp,sp,-16
 206:	e406                	sd	ra,8(sp)
 208:	e022                	sd	s0,0(sp)
 20a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 20c:	02b57563          	bgeu	a0,a1,236 <memmove+0x32>
    while(n-- > 0)
 210:	00c05f63          	blez	a2,22e <memmove+0x2a>
 214:	1602                	slli	a2,a2,0x20
 216:	9201                	srli	a2,a2,0x20
 218:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 21c:	872a                	mv	a4,a0
      *dst++ = *src++;
 21e:	0585                	addi	a1,a1,1
 220:	0705                	addi	a4,a4,1
 222:	fff5c683          	lbu	a3,-1(a1)
 226:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 22a:	fee79ae3          	bne	a5,a4,21e <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 22e:	60a2                	ld	ra,8(sp)
 230:	6402                	ld	s0,0(sp)
 232:	0141                	addi	sp,sp,16
 234:	8082                	ret
    while(n-- > 0)
 236:	fec05ce3          	blez	a2,22e <memmove+0x2a>
    dst += n;
 23a:	00c50733          	add	a4,a0,a2
    src += n;
 23e:	95b2                	add	a1,a1,a2
 240:	fff6079b          	addiw	a5,a2,-1
 244:	1782                	slli	a5,a5,0x20
 246:	9381                	srli	a5,a5,0x20
 248:	fff7c793          	not	a5,a5
 24c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 24e:	15fd                	addi	a1,a1,-1
 250:	177d                	addi	a4,a4,-1
 252:	0005c683          	lbu	a3,0(a1)
 256:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 25a:	fef71ae3          	bne	a4,a5,24e <memmove+0x4a>
 25e:	bfc1                	j	22e <memmove+0x2a>

0000000000000260 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 260:	1141                	addi	sp,sp,-16
 262:	e406                	sd	ra,8(sp)
 264:	e022                	sd	s0,0(sp)
 266:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 268:	c61d                	beqz	a2,296 <memcmp+0x36>
 26a:	1602                	slli	a2,a2,0x20
 26c:	9201                	srli	a2,a2,0x20
 26e:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 272:	00054783          	lbu	a5,0(a0)
 276:	0005c703          	lbu	a4,0(a1)
 27a:	00e79863          	bne	a5,a4,28a <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 27e:	0505                	addi	a0,a0,1
    p2++;
 280:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 282:	fed518e3          	bne	a0,a3,272 <memcmp+0x12>
  }
  return 0;
 286:	4501                	li	a0,0
 288:	a019                	j	28e <memcmp+0x2e>
      return *p1 - *p2;
 28a:	40e7853b          	subw	a0,a5,a4
}
 28e:	60a2                	ld	ra,8(sp)
 290:	6402                	ld	s0,0(sp)
 292:	0141                	addi	sp,sp,16
 294:	8082                	ret
  return 0;
 296:	4501                	li	a0,0
 298:	bfdd                	j	28e <memcmp+0x2e>

000000000000029a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 29a:	1141                	addi	sp,sp,-16
 29c:	e406                	sd	ra,8(sp)
 29e:	e022                	sd	s0,0(sp)
 2a0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2a2:	f63ff0ef          	jal	204 <memmove>
}
 2a6:	60a2                	ld	ra,8(sp)
 2a8:	6402                	ld	s0,0(sp)
 2aa:	0141                	addi	sp,sp,16
 2ac:	8082                	ret

00000000000002ae <sbrk>:

char *
sbrk(int n) {
 2ae:	1141                	addi	sp,sp,-16
 2b0:	e406                	sd	ra,8(sp)
 2b2:	e022                	sd	s0,0(sp)
 2b4:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2b6:	4585                	li	a1,1
 2b8:	0b2000ef          	jal	36a <sys_sbrk>
}
 2bc:	60a2                	ld	ra,8(sp)
 2be:	6402                	ld	s0,0(sp)
 2c0:	0141                	addi	sp,sp,16
 2c2:	8082                	ret

00000000000002c4 <sbrklazy>:

char *
sbrklazy(int n) {
 2c4:	1141                	addi	sp,sp,-16
 2c6:	e406                	sd	ra,8(sp)
 2c8:	e022                	sd	s0,0(sp)
 2ca:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2cc:	4589                	li	a1,2
 2ce:	09c000ef          	jal	36a <sys_sbrk>
}
 2d2:	60a2                	ld	ra,8(sp)
 2d4:	6402                	ld	s0,0(sp)
 2d6:	0141                	addi	sp,sp,16
 2d8:	8082                	ret

00000000000002da <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2da:	4885                	li	a7,1
 ecall
 2dc:	00000073          	ecall
 ret
 2e0:	8082                	ret

00000000000002e2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2e2:	4889                	li	a7,2
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <wait>:
.global wait
wait:
 li a7, SYS_wait
 2ea:	488d                	li	a7,3
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2f2:	4891                	li	a7,4
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <read>:
.global read
read:
 li a7, SYS_read
 2fa:	4895                	li	a7,5
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <write>:
.global write
write:
 li a7, SYS_write
 302:	48c1                	li	a7,16
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <close>:
.global close
close:
 li a7, SYS_close
 30a:	48d5                	li	a7,21
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <kill>:
.global kill
kill:
 li a7, SYS_kill
 312:	4899                	li	a7,6
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <exec>:
.global exec
exec:
 li a7, SYS_exec
 31a:	489d                	li	a7,7
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <open>:
.global open
open:
 li a7, SYS_open
 322:	48bd                	li	a7,15
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 32a:	48c5                	li	a7,17
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 332:	48c9                	li	a7,18
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 33a:	48a1                	li	a7,8
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <link>:
.global link
link:
 li a7, SYS_link
 342:	48cd                	li	a7,19
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 34a:	48d1                	li	a7,20
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 352:	48a5                	li	a7,9
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <dup>:
.global dup
dup:
 li a7, SYS_dup
 35a:	48a9                	li	a7,10
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 362:	48ad                	li	a7,11
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 36a:	48b1                	li	a7,12
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <pause>:
.global pause
pause:
 li a7, SYS_pause
 372:	48b5                	li	a7,13
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 37a:	48b9                	li	a7,14
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <login>:
.global login
login:
 li a7, SYS_login
 382:	48d9                	li	a7,22
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <useradd>:
.global useradd
useradd:
 li a7, SYS_useradd
 38a:	48dd                	li	a7,23
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <userdel>:
.global userdel
userdel:
 li a7, SYS_userdel
 392:	48e1                	li	a7,24
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <passwd>:
.global passwd
passwd:
 li a7, SYS_passwd
 39a:	48e5                	li	a7,25
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <whoami>:
.global whoami
whoami:
 li a7, SYS_whoami
 3a2:	48e9                	li	a7,26
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <chmod>:
.global chmod
chmod:
 li a7, SYS_chmod
 3aa:	48ed                	li	a7,27
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <chown>:
.global chown
chown:
 li a7, SYS_chown
 3b2:	48f1                	li	a7,28
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <audit_read>:
.global audit_read
audit_read:
 li a7, SYS_audit_read
 3ba:	48f5                	li	a7,29
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3c2:	1101                	addi	sp,sp,-32
 3c4:	ec06                	sd	ra,24(sp)
 3c6:	e822                	sd	s0,16(sp)
 3c8:	1000                	addi	s0,sp,32
 3ca:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3ce:	4605                	li	a2,1
 3d0:	fef40593          	addi	a1,s0,-17
 3d4:	f2fff0ef          	jal	302 <write>
}
 3d8:	60e2                	ld	ra,24(sp)
 3da:	6442                	ld	s0,16(sp)
 3dc:	6105                	addi	sp,sp,32
 3de:	8082                	ret

00000000000003e0 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3e0:	715d                	addi	sp,sp,-80
 3e2:	e486                	sd	ra,72(sp)
 3e4:	e0a2                	sd	s0,64(sp)
 3e6:	f84a                	sd	s2,48(sp)
 3e8:	f44e                	sd	s3,40(sp)
 3ea:	0880                	addi	s0,sp,80
 3ec:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 3ee:	c6d1                	beqz	a3,47a <printint+0x9a>
 3f0:	0805d563          	bgez	a1,47a <printint+0x9a>
    neg = 1;
    x = -xx;
 3f4:	40b005b3          	neg	a1,a1
    neg = 1;
 3f8:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 3fa:	fb840993          	addi	s3,s0,-72
  neg = 0;
 3fe:	86ce                	mv	a3,s3
  i = 0;
 400:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 402:	00000817          	auipc	a6,0x0
 406:	56680813          	addi	a6,a6,1382 # 968 <digits>
 40a:	88ba                	mv	a7,a4
 40c:	0017051b          	addiw	a0,a4,1
 410:	872a                	mv	a4,a0
 412:	02c5f7b3          	remu	a5,a1,a2
 416:	97c2                	add	a5,a5,a6
 418:	0007c783          	lbu	a5,0(a5)
 41c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 420:	87ae                	mv	a5,a1
 422:	02c5d5b3          	divu	a1,a1,a2
 426:	0685                	addi	a3,a3,1
 428:	fec7f1e3          	bgeu	a5,a2,40a <printint+0x2a>
  if(neg)
 42c:	00030c63          	beqz	t1,444 <printint+0x64>
    buf[i++] = '-';
 430:	fd050793          	addi	a5,a0,-48
 434:	00878533          	add	a0,a5,s0
 438:	02d00793          	li	a5,45
 43c:	fef50423          	sb	a5,-24(a0)
 440:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 444:	02e05563          	blez	a4,46e <printint+0x8e>
 448:	fc26                	sd	s1,56(sp)
 44a:	377d                	addiw	a4,a4,-1
 44c:	00e984b3          	add	s1,s3,a4
 450:	19fd                	addi	s3,s3,-1
 452:	99ba                	add	s3,s3,a4
 454:	1702                	slli	a4,a4,0x20
 456:	9301                	srli	a4,a4,0x20
 458:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 45c:	0004c583          	lbu	a1,0(s1)
 460:	854a                	mv	a0,s2
 462:	f61ff0ef          	jal	3c2 <putc>
  while(--i >= 0)
 466:	14fd                	addi	s1,s1,-1
 468:	ff349ae3          	bne	s1,s3,45c <printint+0x7c>
 46c:	74e2                	ld	s1,56(sp)
}
 46e:	60a6                	ld	ra,72(sp)
 470:	6406                	ld	s0,64(sp)
 472:	7942                	ld	s2,48(sp)
 474:	79a2                	ld	s3,40(sp)
 476:	6161                	addi	sp,sp,80
 478:	8082                	ret
  neg = 0;
 47a:	4301                	li	t1,0
 47c:	bfbd                	j	3fa <printint+0x1a>

000000000000047e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 47e:	711d                	addi	sp,sp,-96
 480:	ec86                	sd	ra,88(sp)
 482:	e8a2                	sd	s0,80(sp)
 484:	e4a6                	sd	s1,72(sp)
 486:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 488:	0005c483          	lbu	s1,0(a1)
 48c:	22048363          	beqz	s1,6b2 <vprintf+0x234>
 490:	e0ca                	sd	s2,64(sp)
 492:	fc4e                	sd	s3,56(sp)
 494:	f852                	sd	s4,48(sp)
 496:	f456                	sd	s5,40(sp)
 498:	f05a                	sd	s6,32(sp)
 49a:	ec5e                	sd	s7,24(sp)
 49c:	e862                	sd	s8,16(sp)
 49e:	8b2a                	mv	s6,a0
 4a0:	8a2e                	mv	s4,a1
 4a2:	8bb2                	mv	s7,a2
  state = 0;
 4a4:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4a6:	4901                	li	s2,0
 4a8:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4aa:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4ae:	06400c13          	li	s8,100
 4b2:	a00d                	j	4d4 <vprintf+0x56>
        putc(fd, c0);
 4b4:	85a6                	mv	a1,s1
 4b6:	855a                	mv	a0,s6
 4b8:	f0bff0ef          	jal	3c2 <putc>
 4bc:	a019                	j	4c2 <vprintf+0x44>
    } else if(state == '%'){
 4be:	03598363          	beq	s3,s5,4e4 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 4c2:	0019079b          	addiw	a5,s2,1
 4c6:	893e                	mv	s2,a5
 4c8:	873e                	mv	a4,a5
 4ca:	97d2                	add	a5,a5,s4
 4cc:	0007c483          	lbu	s1,0(a5)
 4d0:	1c048a63          	beqz	s1,6a4 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 4d4:	0004879b          	sext.w	a5,s1
    if(state == 0){
 4d8:	fe0993e3          	bnez	s3,4be <vprintf+0x40>
      if(c0 == '%'){
 4dc:	fd579ce3          	bne	a5,s5,4b4 <vprintf+0x36>
        state = '%';
 4e0:	89be                	mv	s3,a5
 4e2:	b7c5                	j	4c2 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 4e4:	00ea06b3          	add	a3,s4,a4
 4e8:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 4ec:	1c060863          	beqz	a2,6bc <vprintf+0x23e>
      if(c0 == 'd'){
 4f0:	03878763          	beq	a5,s8,51e <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4f4:	f9478693          	addi	a3,a5,-108
 4f8:	0016b693          	seqz	a3,a3
 4fc:	f9c60593          	addi	a1,a2,-100
 500:	e99d                	bnez	a1,536 <vprintf+0xb8>
 502:	ca95                	beqz	a3,536 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 504:	008b8493          	addi	s1,s7,8
 508:	4685                	li	a3,1
 50a:	4629                	li	a2,10
 50c:	000bb583          	ld	a1,0(s7)
 510:	855a                	mv	a0,s6
 512:	ecfff0ef          	jal	3e0 <printint>
        i += 1;
 516:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 518:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 51a:	4981                	li	s3,0
 51c:	b75d                	j	4c2 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 51e:	008b8493          	addi	s1,s7,8
 522:	4685                	li	a3,1
 524:	4629                	li	a2,10
 526:	000ba583          	lw	a1,0(s7)
 52a:	855a                	mv	a0,s6
 52c:	eb5ff0ef          	jal	3e0 <printint>
 530:	8ba6                	mv	s7,s1
      state = 0;
 532:	4981                	li	s3,0
 534:	b779                	j	4c2 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 536:	9752                	add	a4,a4,s4
 538:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 53c:	f9460713          	addi	a4,a2,-108
 540:	00173713          	seqz	a4,a4
 544:	8f75                	and	a4,a4,a3
 546:	f9c58513          	addi	a0,a1,-100
 54a:	18051363          	bnez	a0,6d0 <vprintf+0x252>
 54e:	18070163          	beqz	a4,6d0 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 552:	008b8493          	addi	s1,s7,8
 556:	4685                	li	a3,1
 558:	4629                	li	a2,10
 55a:	000bb583          	ld	a1,0(s7)
 55e:	855a                	mv	a0,s6
 560:	e81ff0ef          	jal	3e0 <printint>
        i += 2;
 564:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 566:	8ba6                	mv	s7,s1
      state = 0;
 568:	4981                	li	s3,0
        i += 2;
 56a:	bfa1                	j	4c2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 56c:	008b8493          	addi	s1,s7,8
 570:	4681                	li	a3,0
 572:	4629                	li	a2,10
 574:	000be583          	lwu	a1,0(s7)
 578:	855a                	mv	a0,s6
 57a:	e67ff0ef          	jal	3e0 <printint>
 57e:	8ba6                	mv	s7,s1
      state = 0;
 580:	4981                	li	s3,0
 582:	b781                	j	4c2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 584:	008b8493          	addi	s1,s7,8
 588:	4681                	li	a3,0
 58a:	4629                	li	a2,10
 58c:	000bb583          	ld	a1,0(s7)
 590:	855a                	mv	a0,s6
 592:	e4fff0ef          	jal	3e0 <printint>
        i += 1;
 596:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 598:	8ba6                	mv	s7,s1
      state = 0;
 59a:	4981                	li	s3,0
 59c:	b71d                	j	4c2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 59e:	008b8493          	addi	s1,s7,8
 5a2:	4681                	li	a3,0
 5a4:	4629                	li	a2,10
 5a6:	000bb583          	ld	a1,0(s7)
 5aa:	855a                	mv	a0,s6
 5ac:	e35ff0ef          	jal	3e0 <printint>
        i += 2;
 5b0:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5b2:	8ba6                	mv	s7,s1
      state = 0;
 5b4:	4981                	li	s3,0
        i += 2;
 5b6:	b731                	j	4c2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 5b8:	008b8493          	addi	s1,s7,8
 5bc:	4681                	li	a3,0
 5be:	4641                	li	a2,16
 5c0:	000be583          	lwu	a1,0(s7)
 5c4:	855a                	mv	a0,s6
 5c6:	e1bff0ef          	jal	3e0 <printint>
 5ca:	8ba6                	mv	s7,s1
      state = 0;
 5cc:	4981                	li	s3,0
 5ce:	bdd5                	j	4c2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5d0:	008b8493          	addi	s1,s7,8
 5d4:	4681                	li	a3,0
 5d6:	4641                	li	a2,16
 5d8:	000bb583          	ld	a1,0(s7)
 5dc:	855a                	mv	a0,s6
 5de:	e03ff0ef          	jal	3e0 <printint>
        i += 1;
 5e2:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 5e4:	8ba6                	mv	s7,s1
      state = 0;
 5e6:	4981                	li	s3,0
 5e8:	bde9                	j	4c2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5ea:	008b8493          	addi	s1,s7,8
 5ee:	4681                	li	a3,0
 5f0:	4641                	li	a2,16
 5f2:	000bb583          	ld	a1,0(s7)
 5f6:	855a                	mv	a0,s6
 5f8:	de9ff0ef          	jal	3e0 <printint>
        i += 2;
 5fc:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5fe:	8ba6                	mv	s7,s1
      state = 0;
 600:	4981                	li	s3,0
        i += 2;
 602:	b5c1                	j	4c2 <vprintf+0x44>
 604:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 606:	008b8793          	addi	a5,s7,8
 60a:	8cbe                	mv	s9,a5
 60c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 610:	03000593          	li	a1,48
 614:	855a                	mv	a0,s6
 616:	dadff0ef          	jal	3c2 <putc>
  putc(fd, 'x');
 61a:	07800593          	li	a1,120
 61e:	855a                	mv	a0,s6
 620:	da3ff0ef          	jal	3c2 <putc>
 624:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 626:	00000b97          	auipc	s7,0x0
 62a:	342b8b93          	addi	s7,s7,834 # 968 <digits>
 62e:	03c9d793          	srli	a5,s3,0x3c
 632:	97de                	add	a5,a5,s7
 634:	0007c583          	lbu	a1,0(a5)
 638:	855a                	mv	a0,s6
 63a:	d89ff0ef          	jal	3c2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 63e:	0992                	slli	s3,s3,0x4
 640:	34fd                	addiw	s1,s1,-1
 642:	f4f5                	bnez	s1,62e <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 644:	8be6                	mv	s7,s9
      state = 0;
 646:	4981                	li	s3,0
 648:	6ca2                	ld	s9,8(sp)
 64a:	bda5                	j	4c2 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 64c:	008b8493          	addi	s1,s7,8
 650:	000bc583          	lbu	a1,0(s7)
 654:	855a                	mv	a0,s6
 656:	d6dff0ef          	jal	3c2 <putc>
 65a:	8ba6                	mv	s7,s1
      state = 0;
 65c:	4981                	li	s3,0
 65e:	b595                	j	4c2 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 660:	008b8993          	addi	s3,s7,8
 664:	000bb483          	ld	s1,0(s7)
 668:	cc91                	beqz	s1,684 <vprintf+0x206>
        for(; *s; s++)
 66a:	0004c583          	lbu	a1,0(s1)
 66e:	c985                	beqz	a1,69e <vprintf+0x220>
          putc(fd, *s);
 670:	855a                	mv	a0,s6
 672:	d51ff0ef          	jal	3c2 <putc>
        for(; *s; s++)
 676:	0485                	addi	s1,s1,1
 678:	0004c583          	lbu	a1,0(s1)
 67c:	f9f5                	bnez	a1,670 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 67e:	8bce                	mv	s7,s3
      state = 0;
 680:	4981                	li	s3,0
 682:	b581                	j	4c2 <vprintf+0x44>
          s = "(null)";
 684:	00000497          	auipc	s1,0x0
 688:	2dc48493          	addi	s1,s1,732 # 960 <malloc+0x140>
        for(; *s; s++)
 68c:	02800593          	li	a1,40
 690:	b7c5                	j	670 <vprintf+0x1f2>
        putc(fd, '%');
 692:	85be                	mv	a1,a5
 694:	855a                	mv	a0,s6
 696:	d2dff0ef          	jal	3c2 <putc>
      state = 0;
 69a:	4981                	li	s3,0
 69c:	b51d                	j	4c2 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 69e:	8bce                	mv	s7,s3
      state = 0;
 6a0:	4981                	li	s3,0
 6a2:	b505                	j	4c2 <vprintf+0x44>
 6a4:	6906                	ld	s2,64(sp)
 6a6:	79e2                	ld	s3,56(sp)
 6a8:	7a42                	ld	s4,48(sp)
 6aa:	7aa2                	ld	s5,40(sp)
 6ac:	7b02                	ld	s6,32(sp)
 6ae:	6be2                	ld	s7,24(sp)
 6b0:	6c42                	ld	s8,16(sp)
    }
  }
}
 6b2:	60e6                	ld	ra,88(sp)
 6b4:	6446                	ld	s0,80(sp)
 6b6:	64a6                	ld	s1,72(sp)
 6b8:	6125                	addi	sp,sp,96
 6ba:	8082                	ret
      if(c0 == 'd'){
 6bc:	06400713          	li	a4,100
 6c0:	e4e78fe3          	beq	a5,a4,51e <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 6c4:	f9478693          	addi	a3,a5,-108
 6c8:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 6cc:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6ce:	4701                	li	a4,0
      } else if(c0 == 'u'){
 6d0:	07500513          	li	a0,117
 6d4:	e8a78ce3          	beq	a5,a0,56c <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 6d8:	f8b60513          	addi	a0,a2,-117
 6dc:	e119                	bnez	a0,6e2 <vprintf+0x264>
 6de:	ea0693e3          	bnez	a3,584 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6e2:	f8b58513          	addi	a0,a1,-117
 6e6:	e119                	bnez	a0,6ec <vprintf+0x26e>
 6e8:	ea071be3          	bnez	a4,59e <vprintf+0x120>
      } else if(c0 == 'x'){
 6ec:	07800513          	li	a0,120
 6f0:	eca784e3          	beq	a5,a0,5b8 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 6f4:	f8860613          	addi	a2,a2,-120
 6f8:	e219                	bnez	a2,6fe <vprintf+0x280>
 6fa:	ec069be3          	bnez	a3,5d0 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6fe:	f8858593          	addi	a1,a1,-120
 702:	e199                	bnez	a1,708 <vprintf+0x28a>
 704:	ee0713e3          	bnez	a4,5ea <vprintf+0x16c>
      } else if(c0 == 'p'){
 708:	07000713          	li	a4,112
 70c:	eee78ce3          	beq	a5,a4,604 <vprintf+0x186>
      } else if(c0 == 'c'){
 710:	06300713          	li	a4,99
 714:	f2e78ce3          	beq	a5,a4,64c <vprintf+0x1ce>
      } else if(c0 == 's'){
 718:	07300713          	li	a4,115
 71c:	f4e782e3          	beq	a5,a4,660 <vprintf+0x1e2>
      } else if(c0 == '%'){
 720:	02500713          	li	a4,37
 724:	f6e787e3          	beq	a5,a4,692 <vprintf+0x214>
        putc(fd, '%');
 728:	02500593          	li	a1,37
 72c:	855a                	mv	a0,s6
 72e:	c95ff0ef          	jal	3c2 <putc>
        putc(fd, c0);
 732:	85a6                	mv	a1,s1
 734:	855a                	mv	a0,s6
 736:	c8dff0ef          	jal	3c2 <putc>
      state = 0;
 73a:	4981                	li	s3,0
 73c:	b359                	j	4c2 <vprintf+0x44>

000000000000073e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 73e:	715d                	addi	sp,sp,-80
 740:	ec06                	sd	ra,24(sp)
 742:	e822                	sd	s0,16(sp)
 744:	1000                	addi	s0,sp,32
 746:	e010                	sd	a2,0(s0)
 748:	e414                	sd	a3,8(s0)
 74a:	e818                	sd	a4,16(s0)
 74c:	ec1c                	sd	a5,24(s0)
 74e:	03043023          	sd	a6,32(s0)
 752:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 756:	8622                	mv	a2,s0
 758:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 75c:	d23ff0ef          	jal	47e <vprintf>
}
 760:	60e2                	ld	ra,24(sp)
 762:	6442                	ld	s0,16(sp)
 764:	6161                	addi	sp,sp,80
 766:	8082                	ret

0000000000000768 <printf>:

void
printf(const char *fmt, ...)
{
 768:	711d                	addi	sp,sp,-96
 76a:	ec06                	sd	ra,24(sp)
 76c:	e822                	sd	s0,16(sp)
 76e:	1000                	addi	s0,sp,32
 770:	e40c                	sd	a1,8(s0)
 772:	e810                	sd	a2,16(s0)
 774:	ec14                	sd	a3,24(s0)
 776:	f018                	sd	a4,32(s0)
 778:	f41c                	sd	a5,40(s0)
 77a:	03043823          	sd	a6,48(s0)
 77e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 782:	00840613          	addi	a2,s0,8
 786:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 78a:	85aa                	mv	a1,a0
 78c:	4505                	li	a0,1
 78e:	cf1ff0ef          	jal	47e <vprintf>
}
 792:	60e2                	ld	ra,24(sp)
 794:	6442                	ld	s0,16(sp)
 796:	6125                	addi	sp,sp,96
 798:	8082                	ret

000000000000079a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 79a:	1141                	addi	sp,sp,-16
 79c:	e406                	sd	ra,8(sp)
 79e:	e022                	sd	s0,0(sp)
 7a0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7a2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a6:	00001797          	auipc	a5,0x1
 7aa:	85a7b783          	ld	a5,-1958(a5) # 1000 <freep>
 7ae:	a039                	j	7bc <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7b0:	6398                	ld	a4,0(a5)
 7b2:	00e7e463          	bltu	a5,a4,7ba <free+0x20>
 7b6:	00e6ea63          	bltu	a3,a4,7ca <free+0x30>
{
 7ba:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7bc:	fed7fae3          	bgeu	a5,a3,7b0 <free+0x16>
 7c0:	6398                	ld	a4,0(a5)
 7c2:	00e6e463          	bltu	a3,a4,7ca <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c6:	fee7eae3          	bltu	a5,a4,7ba <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 7ca:	ff852583          	lw	a1,-8(a0)
 7ce:	6390                	ld	a2,0(a5)
 7d0:	02059813          	slli	a6,a1,0x20
 7d4:	01c85713          	srli	a4,a6,0x1c
 7d8:	9736                	add	a4,a4,a3
 7da:	02e60563          	beq	a2,a4,804 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 7de:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 7e2:	4790                	lw	a2,8(a5)
 7e4:	02061593          	slli	a1,a2,0x20
 7e8:	01c5d713          	srli	a4,a1,0x1c
 7ec:	973e                	add	a4,a4,a5
 7ee:	02e68263          	beq	a3,a4,812 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 7f2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7f4:	00001717          	auipc	a4,0x1
 7f8:	80f73623          	sd	a5,-2036(a4) # 1000 <freep>
}
 7fc:	60a2                	ld	ra,8(sp)
 7fe:	6402                	ld	s0,0(sp)
 800:	0141                	addi	sp,sp,16
 802:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 804:	4618                	lw	a4,8(a2)
 806:	9f2d                	addw	a4,a4,a1
 808:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 80c:	6398                	ld	a4,0(a5)
 80e:	6310                	ld	a2,0(a4)
 810:	b7f9                	j	7de <free+0x44>
    p->s.size += bp->s.size;
 812:	ff852703          	lw	a4,-8(a0)
 816:	9f31                	addw	a4,a4,a2
 818:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 81a:	ff053683          	ld	a3,-16(a0)
 81e:	bfd1                	j	7f2 <free+0x58>

0000000000000820 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 820:	7139                	addi	sp,sp,-64
 822:	fc06                	sd	ra,56(sp)
 824:	f822                	sd	s0,48(sp)
 826:	f04a                	sd	s2,32(sp)
 828:	ec4e                	sd	s3,24(sp)
 82a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 82c:	02051993          	slli	s3,a0,0x20
 830:	0209d993          	srli	s3,s3,0x20
 834:	09bd                	addi	s3,s3,15
 836:	0049d993          	srli	s3,s3,0x4
 83a:	2985                	addiw	s3,s3,1
 83c:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 83e:	00000517          	auipc	a0,0x0
 842:	7c253503          	ld	a0,1986(a0) # 1000 <freep>
 846:	c905                	beqz	a0,876 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 848:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 84a:	4798                	lw	a4,8(a5)
 84c:	09377663          	bgeu	a4,s3,8d8 <malloc+0xb8>
 850:	f426                	sd	s1,40(sp)
 852:	e852                	sd	s4,16(sp)
 854:	e456                	sd	s5,8(sp)
 856:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 858:	8a4e                	mv	s4,s3
 85a:	6705                	lui	a4,0x1
 85c:	00e9f363          	bgeu	s3,a4,862 <malloc+0x42>
 860:	6a05                	lui	s4,0x1
 862:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 866:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 86a:	00000497          	auipc	s1,0x0
 86e:	79648493          	addi	s1,s1,1942 # 1000 <freep>
  if(p == SBRK_ERROR)
 872:	5afd                	li	s5,-1
 874:	a83d                	j	8b2 <malloc+0x92>
 876:	f426                	sd	s1,40(sp)
 878:	e852                	sd	s4,16(sp)
 87a:	e456                	sd	s5,8(sp)
 87c:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 87e:	00000797          	auipc	a5,0x0
 882:	79278793          	addi	a5,a5,1938 # 1010 <base>
 886:	00000717          	auipc	a4,0x0
 88a:	76f73d23          	sd	a5,1914(a4) # 1000 <freep>
 88e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 890:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 894:	b7d1                	j	858 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 896:	6398                	ld	a4,0(a5)
 898:	e118                	sd	a4,0(a0)
 89a:	a899                	j	8f0 <malloc+0xd0>
  hp->s.size = nu;
 89c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8a0:	0541                	addi	a0,a0,16
 8a2:	ef9ff0ef          	jal	79a <free>
  return freep;
 8a6:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 8a8:	c125                	beqz	a0,908 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8aa:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8ac:	4798                	lw	a4,8(a5)
 8ae:	03277163          	bgeu	a4,s2,8d0 <malloc+0xb0>
    if(p == freep)
 8b2:	6098                	ld	a4,0(s1)
 8b4:	853e                	mv	a0,a5
 8b6:	fef71ae3          	bne	a4,a5,8aa <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 8ba:	8552                	mv	a0,s4
 8bc:	9f3ff0ef          	jal	2ae <sbrk>
  if(p == SBRK_ERROR)
 8c0:	fd551ee3          	bne	a0,s5,89c <malloc+0x7c>
        return 0;
 8c4:	4501                	li	a0,0
 8c6:	74a2                	ld	s1,40(sp)
 8c8:	6a42                	ld	s4,16(sp)
 8ca:	6aa2                	ld	s5,8(sp)
 8cc:	6b02                	ld	s6,0(sp)
 8ce:	a03d                	j	8fc <malloc+0xdc>
 8d0:	74a2                	ld	s1,40(sp)
 8d2:	6a42                	ld	s4,16(sp)
 8d4:	6aa2                	ld	s5,8(sp)
 8d6:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8d8:	fae90fe3          	beq	s2,a4,896 <malloc+0x76>
        p->s.size -= nunits;
 8dc:	4137073b          	subw	a4,a4,s3
 8e0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8e2:	02071693          	slli	a3,a4,0x20
 8e6:	01c6d713          	srli	a4,a3,0x1c
 8ea:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8ec:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8f0:	00000717          	auipc	a4,0x0
 8f4:	70a73823          	sd	a0,1808(a4) # 1000 <freep>
      return (void*)(p + 1);
 8f8:	01078513          	addi	a0,a5,16
  }
}
 8fc:	70e2                	ld	ra,56(sp)
 8fe:	7442                	ld	s0,48(sp)
 900:	7902                	ld	s2,32(sp)
 902:	69e2                	ld	s3,24(sp)
 904:	6121                	addi	sp,sp,64
 906:	8082                	ret
 908:	74a2                	ld	s1,40(sp)
 90a:	6a42                	ld	s4,16(sp)
 90c:	6aa2                	ld	s5,8(sp)
 90e:	6b02                	ld	s6,0(sp)
 910:	b7f5                	j	8fc <malloc+0xdc>
