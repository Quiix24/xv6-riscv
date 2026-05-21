
user/_logout:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  exit(0);
   8:	4501                	li	a0,0
   a:	2ba000ef          	jal	2c4 <exit>

000000000000000e <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
   e:	1141                	addi	sp,sp,-16
  10:	e406                	sd	ra,8(sp)
  12:	e022                	sd	s0,0(sp)
  14:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  16:	febff0ef          	jal	0 <main>
  exit(r);
  1a:	2aa000ef          	jal	2c4 <exit>

000000000000001e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  1e:	1141                	addi	sp,sp,-16
  20:	e406                	sd	ra,8(sp)
  22:	e022                	sd	s0,0(sp)
  24:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  26:	87aa                	mv	a5,a0
  28:	0585                	addi	a1,a1,1
  2a:	0785                	addi	a5,a5,1
  2c:	fff5c703          	lbu	a4,-1(a1)
  30:	fee78fa3          	sb	a4,-1(a5)
  34:	fb75                	bnez	a4,28 <strcpy+0xa>
    ;
  return os;
}
  36:	60a2                	ld	ra,8(sp)
  38:	6402                	ld	s0,0(sp)
  3a:	0141                	addi	sp,sp,16
  3c:	8082                	ret

000000000000003e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  3e:	1141                	addi	sp,sp,-16
  40:	e406                	sd	ra,8(sp)
  42:	e022                	sd	s0,0(sp)
  44:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  46:	00054783          	lbu	a5,0(a0)
  4a:	cb91                	beqz	a5,5e <strcmp+0x20>
  4c:	0005c703          	lbu	a4,0(a1)
  50:	00f71763          	bne	a4,a5,5e <strcmp+0x20>
    p++, q++;
  54:	0505                	addi	a0,a0,1
  56:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  58:	00054783          	lbu	a5,0(a0)
  5c:	fbe5                	bnez	a5,4c <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  5e:	0005c503          	lbu	a0,0(a1)
}
  62:	40a7853b          	subw	a0,a5,a0
  66:	60a2                	ld	ra,8(sp)
  68:	6402                	ld	s0,0(sp)
  6a:	0141                	addi	sp,sp,16
  6c:	8082                	ret

000000000000006e <strlen>:

uint
strlen(const char *s)
{
  6e:	1141                	addi	sp,sp,-16
  70:	e406                	sd	ra,8(sp)
  72:	e022                	sd	s0,0(sp)
  74:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  76:	00054783          	lbu	a5,0(a0)
  7a:	cf91                	beqz	a5,96 <strlen+0x28>
  7c:	00150793          	addi	a5,a0,1
  80:	86be                	mv	a3,a5
  82:	0785                	addi	a5,a5,1
  84:	fff7c703          	lbu	a4,-1(a5)
  88:	ff65                	bnez	a4,80 <strlen+0x12>
  8a:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
  8e:	60a2                	ld	ra,8(sp)
  90:	6402                	ld	s0,0(sp)
  92:	0141                	addi	sp,sp,16
  94:	8082                	ret
  for(n = 0; s[n]; n++)
  96:	4501                	li	a0,0
  98:	bfdd                	j	8e <strlen+0x20>

000000000000009a <memset>:

void*
memset(void *dst, int c, uint n)
{
  9a:	1141                	addi	sp,sp,-16
  9c:	e406                	sd	ra,8(sp)
  9e:	e022                	sd	s0,0(sp)
  a0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  a2:	ca19                	beqz	a2,b8 <memset+0x1e>
  a4:	87aa                	mv	a5,a0
  a6:	1602                	slli	a2,a2,0x20
  a8:	9201                	srli	a2,a2,0x20
  aa:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  ae:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  b2:	0785                	addi	a5,a5,1
  b4:	fee79de3          	bne	a5,a4,ae <memset+0x14>
  }
  return dst;
}
  b8:	60a2                	ld	ra,8(sp)
  ba:	6402                	ld	s0,0(sp)
  bc:	0141                	addi	sp,sp,16
  be:	8082                	ret

00000000000000c0 <strchr>:

char*
strchr(const char *s, char c)
{
  c0:	1141                	addi	sp,sp,-16
  c2:	e406                	sd	ra,8(sp)
  c4:	e022                	sd	s0,0(sp)
  c6:	0800                	addi	s0,sp,16
  for(; *s; s++)
  c8:	00054783          	lbu	a5,0(a0)
  cc:	cf81                	beqz	a5,e4 <strchr+0x24>
    if(*s == c)
  ce:	00f58763          	beq	a1,a5,dc <strchr+0x1c>
  for(; *s; s++)
  d2:	0505                	addi	a0,a0,1
  d4:	00054783          	lbu	a5,0(a0)
  d8:	fbfd                	bnez	a5,ce <strchr+0xe>
      return (char*)s;
  return 0;
  da:	4501                	li	a0,0
}
  dc:	60a2                	ld	ra,8(sp)
  de:	6402                	ld	s0,0(sp)
  e0:	0141                	addi	sp,sp,16
  e2:	8082                	ret
  return 0;
  e4:	4501                	li	a0,0
  e6:	bfdd                	j	dc <strchr+0x1c>

00000000000000e8 <gets>:

char*
gets(char *buf, int max)
{
  e8:	711d                	addi	sp,sp,-96
  ea:	ec86                	sd	ra,88(sp)
  ec:	e8a2                	sd	s0,80(sp)
  ee:	e4a6                	sd	s1,72(sp)
  f0:	e0ca                	sd	s2,64(sp)
  f2:	fc4e                	sd	s3,56(sp)
  f4:	f852                	sd	s4,48(sp)
  f6:	f456                	sd	s5,40(sp)
  f8:	f05a                	sd	s6,32(sp)
  fa:	ec5e                	sd	s7,24(sp)
  fc:	e862                	sd	s8,16(sp)
  fe:	1080                	addi	s0,sp,96
 100:	8baa                	mv	s7,a0
 102:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 104:	892a                	mv	s2,a0
 106:	4481                	li	s1,0
    cc = read(0, &c, 1);
 108:	faf40b13          	addi	s6,s0,-81
 10c:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 10e:	8c26                	mv	s8,s1
 110:	0014899b          	addiw	s3,s1,1
 114:	84ce                	mv	s1,s3
 116:	0349d463          	bge	s3,s4,13e <gets+0x56>
    cc = read(0, &c, 1);
 11a:	8656                	mv	a2,s5
 11c:	85da                	mv	a1,s6
 11e:	4501                	li	a0,0
 120:	1bc000ef          	jal	2dc <read>
    if(cc < 1)
 124:	00a05d63          	blez	a0,13e <gets+0x56>
      break;
    buf[i++] = c;
 128:	faf44783          	lbu	a5,-81(s0)
 12c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 130:	0905                	addi	s2,s2,1
 132:	ff678713          	addi	a4,a5,-10
 136:	c319                	beqz	a4,13c <gets+0x54>
 138:	17cd                	addi	a5,a5,-13
 13a:	fbf1                	bnez	a5,10e <gets+0x26>
    buf[i++] = c;
 13c:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 13e:	9c5e                	add	s8,s8,s7
 140:	000c0023          	sb	zero,0(s8)
  return buf;
}
 144:	855e                	mv	a0,s7
 146:	60e6                	ld	ra,88(sp)
 148:	6446                	ld	s0,80(sp)
 14a:	64a6                	ld	s1,72(sp)
 14c:	6906                	ld	s2,64(sp)
 14e:	79e2                	ld	s3,56(sp)
 150:	7a42                	ld	s4,48(sp)
 152:	7aa2                	ld	s5,40(sp)
 154:	7b02                	ld	s6,32(sp)
 156:	6be2                	ld	s7,24(sp)
 158:	6c42                	ld	s8,16(sp)
 15a:	6125                	addi	sp,sp,96
 15c:	8082                	ret

000000000000015e <stat>:

int
stat(const char *n, struct stat *st)
{
 15e:	1101                	addi	sp,sp,-32
 160:	ec06                	sd	ra,24(sp)
 162:	e822                	sd	s0,16(sp)
 164:	e04a                	sd	s2,0(sp)
 166:	1000                	addi	s0,sp,32
 168:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 16a:	4581                	li	a1,0
 16c:	198000ef          	jal	304 <open>
  if(fd < 0)
 170:	02054263          	bltz	a0,194 <stat+0x36>
 174:	e426                	sd	s1,8(sp)
 176:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 178:	85ca                	mv	a1,s2
 17a:	1a2000ef          	jal	31c <fstat>
 17e:	892a                	mv	s2,a0
  close(fd);
 180:	8526                	mv	a0,s1
 182:	16a000ef          	jal	2ec <close>
  return r;
 186:	64a2                	ld	s1,8(sp)
}
 188:	854a                	mv	a0,s2
 18a:	60e2                	ld	ra,24(sp)
 18c:	6442                	ld	s0,16(sp)
 18e:	6902                	ld	s2,0(sp)
 190:	6105                	addi	sp,sp,32
 192:	8082                	ret
    return -1;
 194:	57fd                	li	a5,-1
 196:	893e                	mv	s2,a5
 198:	bfc5                	j	188 <stat+0x2a>

000000000000019a <atoi>:

int
atoi(const char *s)
{
 19a:	1141                	addi	sp,sp,-16
 19c:	e406                	sd	ra,8(sp)
 19e:	e022                	sd	s0,0(sp)
 1a0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1a2:	00054683          	lbu	a3,0(a0)
 1a6:	fd06879b          	addiw	a5,a3,-48
 1aa:	0ff7f793          	zext.b	a5,a5
 1ae:	4625                	li	a2,9
 1b0:	02f66963          	bltu	a2,a5,1e2 <atoi+0x48>
 1b4:	872a                	mv	a4,a0
  n = 0;
 1b6:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1b8:	0705                	addi	a4,a4,1
 1ba:	0025179b          	slliw	a5,a0,0x2
 1be:	9fa9                	addw	a5,a5,a0
 1c0:	0017979b          	slliw	a5,a5,0x1
 1c4:	9fb5                	addw	a5,a5,a3
 1c6:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1ca:	00074683          	lbu	a3,0(a4)
 1ce:	fd06879b          	addiw	a5,a3,-48
 1d2:	0ff7f793          	zext.b	a5,a5
 1d6:	fef671e3          	bgeu	a2,a5,1b8 <atoi+0x1e>
  return n;
}
 1da:	60a2                	ld	ra,8(sp)
 1dc:	6402                	ld	s0,0(sp)
 1de:	0141                	addi	sp,sp,16
 1e0:	8082                	ret
  n = 0;
 1e2:	4501                	li	a0,0
 1e4:	bfdd                	j	1da <atoi+0x40>

00000000000001e6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1e6:	1141                	addi	sp,sp,-16
 1e8:	e406                	sd	ra,8(sp)
 1ea:	e022                	sd	s0,0(sp)
 1ec:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1ee:	02b57563          	bgeu	a0,a1,218 <memmove+0x32>
    while(n-- > 0)
 1f2:	00c05f63          	blez	a2,210 <memmove+0x2a>
 1f6:	1602                	slli	a2,a2,0x20
 1f8:	9201                	srli	a2,a2,0x20
 1fa:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 1fe:	872a                	mv	a4,a0
      *dst++ = *src++;
 200:	0585                	addi	a1,a1,1
 202:	0705                	addi	a4,a4,1
 204:	fff5c683          	lbu	a3,-1(a1)
 208:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 20c:	fee79ae3          	bne	a5,a4,200 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 210:	60a2                	ld	ra,8(sp)
 212:	6402                	ld	s0,0(sp)
 214:	0141                	addi	sp,sp,16
 216:	8082                	ret
    while(n-- > 0)
 218:	fec05ce3          	blez	a2,210 <memmove+0x2a>
    dst += n;
 21c:	00c50733          	add	a4,a0,a2
    src += n;
 220:	95b2                	add	a1,a1,a2
 222:	fff6079b          	addiw	a5,a2,-1
 226:	1782                	slli	a5,a5,0x20
 228:	9381                	srli	a5,a5,0x20
 22a:	fff7c793          	not	a5,a5
 22e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 230:	15fd                	addi	a1,a1,-1
 232:	177d                	addi	a4,a4,-1
 234:	0005c683          	lbu	a3,0(a1)
 238:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 23c:	fef71ae3          	bne	a4,a5,230 <memmove+0x4a>
 240:	bfc1                	j	210 <memmove+0x2a>

0000000000000242 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 242:	1141                	addi	sp,sp,-16
 244:	e406                	sd	ra,8(sp)
 246:	e022                	sd	s0,0(sp)
 248:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 24a:	c61d                	beqz	a2,278 <memcmp+0x36>
 24c:	1602                	slli	a2,a2,0x20
 24e:	9201                	srli	a2,a2,0x20
 250:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 254:	00054783          	lbu	a5,0(a0)
 258:	0005c703          	lbu	a4,0(a1)
 25c:	00e79863          	bne	a5,a4,26c <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 260:	0505                	addi	a0,a0,1
    p2++;
 262:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 264:	fed518e3          	bne	a0,a3,254 <memcmp+0x12>
  }
  return 0;
 268:	4501                	li	a0,0
 26a:	a019                	j	270 <memcmp+0x2e>
      return *p1 - *p2;
 26c:	40e7853b          	subw	a0,a5,a4
}
 270:	60a2                	ld	ra,8(sp)
 272:	6402                	ld	s0,0(sp)
 274:	0141                	addi	sp,sp,16
 276:	8082                	ret
  return 0;
 278:	4501                	li	a0,0
 27a:	bfdd                	j	270 <memcmp+0x2e>

000000000000027c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 27c:	1141                	addi	sp,sp,-16
 27e:	e406                	sd	ra,8(sp)
 280:	e022                	sd	s0,0(sp)
 282:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 284:	f63ff0ef          	jal	1e6 <memmove>
}
 288:	60a2                	ld	ra,8(sp)
 28a:	6402                	ld	s0,0(sp)
 28c:	0141                	addi	sp,sp,16
 28e:	8082                	ret

0000000000000290 <sbrk>:

char *
sbrk(int n) {
 290:	1141                	addi	sp,sp,-16
 292:	e406                	sd	ra,8(sp)
 294:	e022                	sd	s0,0(sp)
 296:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 298:	4585                	li	a1,1
 29a:	0b2000ef          	jal	34c <sys_sbrk>
}
 29e:	60a2                	ld	ra,8(sp)
 2a0:	6402                	ld	s0,0(sp)
 2a2:	0141                	addi	sp,sp,16
 2a4:	8082                	ret

00000000000002a6 <sbrklazy>:

char *
sbrklazy(int n) {
 2a6:	1141                	addi	sp,sp,-16
 2a8:	e406                	sd	ra,8(sp)
 2aa:	e022                	sd	s0,0(sp)
 2ac:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2ae:	4589                	li	a1,2
 2b0:	09c000ef          	jal	34c <sys_sbrk>
}
 2b4:	60a2                	ld	ra,8(sp)
 2b6:	6402                	ld	s0,0(sp)
 2b8:	0141                	addi	sp,sp,16
 2ba:	8082                	ret

00000000000002bc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2bc:	4885                	li	a7,1
 ecall
 2be:	00000073          	ecall
 ret
 2c2:	8082                	ret

00000000000002c4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2c4:	4889                	li	a7,2
 ecall
 2c6:	00000073          	ecall
 ret
 2ca:	8082                	ret

00000000000002cc <wait>:
.global wait
wait:
 li a7, SYS_wait
 2cc:	488d                	li	a7,3
 ecall
 2ce:	00000073          	ecall
 ret
 2d2:	8082                	ret

00000000000002d4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2d4:	4891                	li	a7,4
 ecall
 2d6:	00000073          	ecall
 ret
 2da:	8082                	ret

00000000000002dc <read>:
.global read
read:
 li a7, SYS_read
 2dc:	4895                	li	a7,5
 ecall
 2de:	00000073          	ecall
 ret
 2e2:	8082                	ret

00000000000002e4 <write>:
.global write
write:
 li a7, SYS_write
 2e4:	48c1                	li	a7,16
 ecall
 2e6:	00000073          	ecall
 ret
 2ea:	8082                	ret

00000000000002ec <close>:
.global close
close:
 li a7, SYS_close
 2ec:	48d5                	li	a7,21
 ecall
 2ee:	00000073          	ecall
 ret
 2f2:	8082                	ret

00000000000002f4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2f4:	4899                	li	a7,6
 ecall
 2f6:	00000073          	ecall
 ret
 2fa:	8082                	ret

00000000000002fc <exec>:
.global exec
exec:
 li a7, SYS_exec
 2fc:	489d                	li	a7,7
 ecall
 2fe:	00000073          	ecall
 ret
 302:	8082                	ret

0000000000000304 <open>:
.global open
open:
 li a7, SYS_open
 304:	48bd                	li	a7,15
 ecall
 306:	00000073          	ecall
 ret
 30a:	8082                	ret

000000000000030c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 30c:	48c5                	li	a7,17
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 314:	48c9                	li	a7,18
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 31c:	48a1                	li	a7,8
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <link>:
.global link
link:
 li a7, SYS_link
 324:	48cd                	li	a7,19
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 32c:	48d1                	li	a7,20
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 334:	48a5                	li	a7,9
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <dup>:
.global dup
dup:
 li a7, SYS_dup
 33c:	48a9                	li	a7,10
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 344:	48ad                	li	a7,11
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 34c:	48b1                	li	a7,12
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <pause>:
.global pause
pause:
 li a7, SYS_pause
 354:	48b5                	li	a7,13
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 35c:	48b9                	li	a7,14
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <login>:
.global login
login:
 li a7, SYS_login
 364:	48d9                	li	a7,22
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <useradd>:
.global useradd
useradd:
 li a7, SYS_useradd
 36c:	48dd                	li	a7,23
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <userdel>:
.global userdel
userdel:
 li a7, SYS_userdel
 374:	48e1                	li	a7,24
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <passwd>:
.global passwd
passwd:
 li a7, SYS_passwd
 37c:	48e5                	li	a7,25
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <whoami>:
.global whoami
whoami:
 li a7, SYS_whoami
 384:	48e9                	li	a7,26
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <chmod>:
.global chmod
chmod:
 li a7, SYS_chmod
 38c:	48ed                	li	a7,27
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <chown>:
.global chown
chown:
 li a7, SYS_chown
 394:	48f1                	li	a7,28
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <audit_read>:
.global audit_read
audit_read:
 li a7, SYS_audit_read
 39c:	48f5                	li	a7,29
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3a4:	1101                	addi	sp,sp,-32
 3a6:	ec06                	sd	ra,24(sp)
 3a8:	e822                	sd	s0,16(sp)
 3aa:	1000                	addi	s0,sp,32
 3ac:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3b0:	4605                	li	a2,1
 3b2:	fef40593          	addi	a1,s0,-17
 3b6:	f2fff0ef          	jal	2e4 <write>
}
 3ba:	60e2                	ld	ra,24(sp)
 3bc:	6442                	ld	s0,16(sp)
 3be:	6105                	addi	sp,sp,32
 3c0:	8082                	ret

00000000000003c2 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3c2:	715d                	addi	sp,sp,-80
 3c4:	e486                	sd	ra,72(sp)
 3c6:	e0a2                	sd	s0,64(sp)
 3c8:	f84a                	sd	s2,48(sp)
 3ca:	f44e                	sd	s3,40(sp)
 3cc:	0880                	addi	s0,sp,80
 3ce:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 3d0:	c6d1                	beqz	a3,45c <printint+0x9a>
 3d2:	0805d563          	bgez	a1,45c <printint+0x9a>
    neg = 1;
    x = -xx;
 3d6:	40b005b3          	neg	a1,a1
    neg = 1;
 3da:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 3dc:	fb840993          	addi	s3,s0,-72
  neg = 0;
 3e0:	86ce                	mv	a3,s3
  i = 0;
 3e2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3e4:	00000817          	auipc	a6,0x0
 3e8:	52480813          	addi	a6,a6,1316 # 908 <digits>
 3ec:	88ba                	mv	a7,a4
 3ee:	0017051b          	addiw	a0,a4,1
 3f2:	872a                	mv	a4,a0
 3f4:	02c5f7b3          	remu	a5,a1,a2
 3f8:	97c2                	add	a5,a5,a6
 3fa:	0007c783          	lbu	a5,0(a5)
 3fe:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 402:	87ae                	mv	a5,a1
 404:	02c5d5b3          	divu	a1,a1,a2
 408:	0685                	addi	a3,a3,1
 40a:	fec7f1e3          	bgeu	a5,a2,3ec <printint+0x2a>
  if(neg)
 40e:	00030c63          	beqz	t1,426 <printint+0x64>
    buf[i++] = '-';
 412:	fd050793          	addi	a5,a0,-48
 416:	00878533          	add	a0,a5,s0
 41a:	02d00793          	li	a5,45
 41e:	fef50423          	sb	a5,-24(a0)
 422:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 426:	02e05563          	blez	a4,450 <printint+0x8e>
 42a:	fc26                	sd	s1,56(sp)
 42c:	377d                	addiw	a4,a4,-1
 42e:	00e984b3          	add	s1,s3,a4
 432:	19fd                	addi	s3,s3,-1
 434:	99ba                	add	s3,s3,a4
 436:	1702                	slli	a4,a4,0x20
 438:	9301                	srli	a4,a4,0x20
 43a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 43e:	0004c583          	lbu	a1,0(s1)
 442:	854a                	mv	a0,s2
 444:	f61ff0ef          	jal	3a4 <putc>
  while(--i >= 0)
 448:	14fd                	addi	s1,s1,-1
 44a:	ff349ae3          	bne	s1,s3,43e <printint+0x7c>
 44e:	74e2                	ld	s1,56(sp)
}
 450:	60a6                	ld	ra,72(sp)
 452:	6406                	ld	s0,64(sp)
 454:	7942                	ld	s2,48(sp)
 456:	79a2                	ld	s3,40(sp)
 458:	6161                	addi	sp,sp,80
 45a:	8082                	ret
  neg = 0;
 45c:	4301                	li	t1,0
 45e:	bfbd                	j	3dc <printint+0x1a>

0000000000000460 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 460:	711d                	addi	sp,sp,-96
 462:	ec86                	sd	ra,88(sp)
 464:	e8a2                	sd	s0,80(sp)
 466:	e4a6                	sd	s1,72(sp)
 468:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 46a:	0005c483          	lbu	s1,0(a1)
 46e:	22048363          	beqz	s1,694 <vprintf+0x234>
 472:	e0ca                	sd	s2,64(sp)
 474:	fc4e                	sd	s3,56(sp)
 476:	f852                	sd	s4,48(sp)
 478:	f456                	sd	s5,40(sp)
 47a:	f05a                	sd	s6,32(sp)
 47c:	ec5e                	sd	s7,24(sp)
 47e:	e862                	sd	s8,16(sp)
 480:	8b2a                	mv	s6,a0
 482:	8a2e                	mv	s4,a1
 484:	8bb2                	mv	s7,a2
  state = 0;
 486:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 488:	4901                	li	s2,0
 48a:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 48c:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 490:	06400c13          	li	s8,100
 494:	a00d                	j	4b6 <vprintf+0x56>
        putc(fd, c0);
 496:	85a6                	mv	a1,s1
 498:	855a                	mv	a0,s6
 49a:	f0bff0ef          	jal	3a4 <putc>
 49e:	a019                	j	4a4 <vprintf+0x44>
    } else if(state == '%'){
 4a0:	03598363          	beq	s3,s5,4c6 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 4a4:	0019079b          	addiw	a5,s2,1
 4a8:	893e                	mv	s2,a5
 4aa:	873e                	mv	a4,a5
 4ac:	97d2                	add	a5,a5,s4
 4ae:	0007c483          	lbu	s1,0(a5)
 4b2:	1c048a63          	beqz	s1,686 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 4b6:	0004879b          	sext.w	a5,s1
    if(state == 0){
 4ba:	fe0993e3          	bnez	s3,4a0 <vprintf+0x40>
      if(c0 == '%'){
 4be:	fd579ce3          	bne	a5,s5,496 <vprintf+0x36>
        state = '%';
 4c2:	89be                	mv	s3,a5
 4c4:	b7c5                	j	4a4 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 4c6:	00ea06b3          	add	a3,s4,a4
 4ca:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 4ce:	1c060863          	beqz	a2,69e <vprintf+0x23e>
      if(c0 == 'd'){
 4d2:	03878763          	beq	a5,s8,500 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4d6:	f9478693          	addi	a3,a5,-108
 4da:	0016b693          	seqz	a3,a3
 4de:	f9c60593          	addi	a1,a2,-100
 4e2:	e99d                	bnez	a1,518 <vprintf+0xb8>
 4e4:	ca95                	beqz	a3,518 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 4e6:	008b8493          	addi	s1,s7,8
 4ea:	4685                	li	a3,1
 4ec:	4629                	li	a2,10
 4ee:	000bb583          	ld	a1,0(s7)
 4f2:	855a                	mv	a0,s6
 4f4:	ecfff0ef          	jal	3c2 <printint>
        i += 1;
 4f8:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 4fa:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 4fc:	4981                	li	s3,0
 4fe:	b75d                	j	4a4 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 500:	008b8493          	addi	s1,s7,8
 504:	4685                	li	a3,1
 506:	4629                	li	a2,10
 508:	000ba583          	lw	a1,0(s7)
 50c:	855a                	mv	a0,s6
 50e:	eb5ff0ef          	jal	3c2 <printint>
 512:	8ba6                	mv	s7,s1
      state = 0;
 514:	4981                	li	s3,0
 516:	b779                	j	4a4 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 518:	9752                	add	a4,a4,s4
 51a:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 51e:	f9460713          	addi	a4,a2,-108
 522:	00173713          	seqz	a4,a4
 526:	8f75                	and	a4,a4,a3
 528:	f9c58513          	addi	a0,a1,-100
 52c:	18051363          	bnez	a0,6b2 <vprintf+0x252>
 530:	18070163          	beqz	a4,6b2 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 534:	008b8493          	addi	s1,s7,8
 538:	4685                	li	a3,1
 53a:	4629                	li	a2,10
 53c:	000bb583          	ld	a1,0(s7)
 540:	855a                	mv	a0,s6
 542:	e81ff0ef          	jal	3c2 <printint>
        i += 2;
 546:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 548:	8ba6                	mv	s7,s1
      state = 0;
 54a:	4981                	li	s3,0
        i += 2;
 54c:	bfa1                	j	4a4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 54e:	008b8493          	addi	s1,s7,8
 552:	4681                	li	a3,0
 554:	4629                	li	a2,10
 556:	000be583          	lwu	a1,0(s7)
 55a:	855a                	mv	a0,s6
 55c:	e67ff0ef          	jal	3c2 <printint>
 560:	8ba6                	mv	s7,s1
      state = 0;
 562:	4981                	li	s3,0
 564:	b781                	j	4a4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 566:	008b8493          	addi	s1,s7,8
 56a:	4681                	li	a3,0
 56c:	4629                	li	a2,10
 56e:	000bb583          	ld	a1,0(s7)
 572:	855a                	mv	a0,s6
 574:	e4fff0ef          	jal	3c2 <printint>
        i += 1;
 578:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 57a:	8ba6                	mv	s7,s1
      state = 0;
 57c:	4981                	li	s3,0
 57e:	b71d                	j	4a4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 580:	008b8493          	addi	s1,s7,8
 584:	4681                	li	a3,0
 586:	4629                	li	a2,10
 588:	000bb583          	ld	a1,0(s7)
 58c:	855a                	mv	a0,s6
 58e:	e35ff0ef          	jal	3c2 <printint>
        i += 2;
 592:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 594:	8ba6                	mv	s7,s1
      state = 0;
 596:	4981                	li	s3,0
        i += 2;
 598:	b731                	j	4a4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 59a:	008b8493          	addi	s1,s7,8
 59e:	4681                	li	a3,0
 5a0:	4641                	li	a2,16
 5a2:	000be583          	lwu	a1,0(s7)
 5a6:	855a                	mv	a0,s6
 5a8:	e1bff0ef          	jal	3c2 <printint>
 5ac:	8ba6                	mv	s7,s1
      state = 0;
 5ae:	4981                	li	s3,0
 5b0:	bdd5                	j	4a4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5b2:	008b8493          	addi	s1,s7,8
 5b6:	4681                	li	a3,0
 5b8:	4641                	li	a2,16
 5ba:	000bb583          	ld	a1,0(s7)
 5be:	855a                	mv	a0,s6
 5c0:	e03ff0ef          	jal	3c2 <printint>
        i += 1;
 5c4:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 5c6:	8ba6                	mv	s7,s1
      state = 0;
 5c8:	4981                	li	s3,0
 5ca:	bde9                	j	4a4 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5cc:	008b8493          	addi	s1,s7,8
 5d0:	4681                	li	a3,0
 5d2:	4641                	li	a2,16
 5d4:	000bb583          	ld	a1,0(s7)
 5d8:	855a                	mv	a0,s6
 5da:	de9ff0ef          	jal	3c2 <printint>
        i += 2;
 5de:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5e0:	8ba6                	mv	s7,s1
      state = 0;
 5e2:	4981                	li	s3,0
        i += 2;
 5e4:	b5c1                	j	4a4 <vprintf+0x44>
 5e6:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 5e8:	008b8793          	addi	a5,s7,8
 5ec:	8cbe                	mv	s9,a5
 5ee:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5f2:	03000593          	li	a1,48
 5f6:	855a                	mv	a0,s6
 5f8:	dadff0ef          	jal	3a4 <putc>
  putc(fd, 'x');
 5fc:	07800593          	li	a1,120
 600:	855a                	mv	a0,s6
 602:	da3ff0ef          	jal	3a4 <putc>
 606:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 608:	00000b97          	auipc	s7,0x0
 60c:	300b8b93          	addi	s7,s7,768 # 908 <digits>
 610:	03c9d793          	srli	a5,s3,0x3c
 614:	97de                	add	a5,a5,s7
 616:	0007c583          	lbu	a1,0(a5)
 61a:	855a                	mv	a0,s6
 61c:	d89ff0ef          	jal	3a4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 620:	0992                	slli	s3,s3,0x4
 622:	34fd                	addiw	s1,s1,-1
 624:	f4f5                	bnez	s1,610 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 626:	8be6                	mv	s7,s9
      state = 0;
 628:	4981                	li	s3,0
 62a:	6ca2                	ld	s9,8(sp)
 62c:	bda5                	j	4a4 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 62e:	008b8493          	addi	s1,s7,8
 632:	000bc583          	lbu	a1,0(s7)
 636:	855a                	mv	a0,s6
 638:	d6dff0ef          	jal	3a4 <putc>
 63c:	8ba6                	mv	s7,s1
      state = 0;
 63e:	4981                	li	s3,0
 640:	b595                	j	4a4 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 642:	008b8993          	addi	s3,s7,8
 646:	000bb483          	ld	s1,0(s7)
 64a:	cc91                	beqz	s1,666 <vprintf+0x206>
        for(; *s; s++)
 64c:	0004c583          	lbu	a1,0(s1)
 650:	c985                	beqz	a1,680 <vprintf+0x220>
          putc(fd, *s);
 652:	855a                	mv	a0,s6
 654:	d51ff0ef          	jal	3a4 <putc>
        for(; *s; s++)
 658:	0485                	addi	s1,s1,1
 65a:	0004c583          	lbu	a1,0(s1)
 65e:	f9f5                	bnez	a1,652 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 660:	8bce                	mv	s7,s3
      state = 0;
 662:	4981                	li	s3,0
 664:	b581                	j	4a4 <vprintf+0x44>
          s = "(null)";
 666:	00000497          	auipc	s1,0x0
 66a:	29a48493          	addi	s1,s1,666 # 900 <malloc+0xfe>
        for(; *s; s++)
 66e:	02800593          	li	a1,40
 672:	b7c5                	j	652 <vprintf+0x1f2>
        putc(fd, '%');
 674:	85be                	mv	a1,a5
 676:	855a                	mv	a0,s6
 678:	d2dff0ef          	jal	3a4 <putc>
      state = 0;
 67c:	4981                	li	s3,0
 67e:	b51d                	j	4a4 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 680:	8bce                	mv	s7,s3
      state = 0;
 682:	4981                	li	s3,0
 684:	b505                	j	4a4 <vprintf+0x44>
 686:	6906                	ld	s2,64(sp)
 688:	79e2                	ld	s3,56(sp)
 68a:	7a42                	ld	s4,48(sp)
 68c:	7aa2                	ld	s5,40(sp)
 68e:	7b02                	ld	s6,32(sp)
 690:	6be2                	ld	s7,24(sp)
 692:	6c42                	ld	s8,16(sp)
    }
  }
}
 694:	60e6                	ld	ra,88(sp)
 696:	6446                	ld	s0,80(sp)
 698:	64a6                	ld	s1,72(sp)
 69a:	6125                	addi	sp,sp,96
 69c:	8082                	ret
      if(c0 == 'd'){
 69e:	06400713          	li	a4,100
 6a2:	e4e78fe3          	beq	a5,a4,500 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 6a6:	f9478693          	addi	a3,a5,-108
 6aa:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 6ae:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6b0:	4701                	li	a4,0
      } else if(c0 == 'u'){
 6b2:	07500513          	li	a0,117
 6b6:	e8a78ce3          	beq	a5,a0,54e <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 6ba:	f8b60513          	addi	a0,a2,-117
 6be:	e119                	bnez	a0,6c4 <vprintf+0x264>
 6c0:	ea0693e3          	bnez	a3,566 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6c4:	f8b58513          	addi	a0,a1,-117
 6c8:	e119                	bnez	a0,6ce <vprintf+0x26e>
 6ca:	ea071be3          	bnez	a4,580 <vprintf+0x120>
      } else if(c0 == 'x'){
 6ce:	07800513          	li	a0,120
 6d2:	eca784e3          	beq	a5,a0,59a <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 6d6:	f8860613          	addi	a2,a2,-120
 6da:	e219                	bnez	a2,6e0 <vprintf+0x280>
 6dc:	ec069be3          	bnez	a3,5b2 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6e0:	f8858593          	addi	a1,a1,-120
 6e4:	e199                	bnez	a1,6ea <vprintf+0x28a>
 6e6:	ee0713e3          	bnez	a4,5cc <vprintf+0x16c>
      } else if(c0 == 'p'){
 6ea:	07000713          	li	a4,112
 6ee:	eee78ce3          	beq	a5,a4,5e6 <vprintf+0x186>
      } else if(c0 == 'c'){
 6f2:	06300713          	li	a4,99
 6f6:	f2e78ce3          	beq	a5,a4,62e <vprintf+0x1ce>
      } else if(c0 == 's'){
 6fa:	07300713          	li	a4,115
 6fe:	f4e782e3          	beq	a5,a4,642 <vprintf+0x1e2>
      } else if(c0 == '%'){
 702:	02500713          	li	a4,37
 706:	f6e787e3          	beq	a5,a4,674 <vprintf+0x214>
        putc(fd, '%');
 70a:	02500593          	li	a1,37
 70e:	855a                	mv	a0,s6
 710:	c95ff0ef          	jal	3a4 <putc>
        putc(fd, c0);
 714:	85a6                	mv	a1,s1
 716:	855a                	mv	a0,s6
 718:	c8dff0ef          	jal	3a4 <putc>
      state = 0;
 71c:	4981                	li	s3,0
 71e:	b359                	j	4a4 <vprintf+0x44>

0000000000000720 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 720:	715d                	addi	sp,sp,-80
 722:	ec06                	sd	ra,24(sp)
 724:	e822                	sd	s0,16(sp)
 726:	1000                	addi	s0,sp,32
 728:	e010                	sd	a2,0(s0)
 72a:	e414                	sd	a3,8(s0)
 72c:	e818                	sd	a4,16(s0)
 72e:	ec1c                	sd	a5,24(s0)
 730:	03043023          	sd	a6,32(s0)
 734:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 738:	8622                	mv	a2,s0
 73a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 73e:	d23ff0ef          	jal	460 <vprintf>
}
 742:	60e2                	ld	ra,24(sp)
 744:	6442                	ld	s0,16(sp)
 746:	6161                	addi	sp,sp,80
 748:	8082                	ret

000000000000074a <printf>:

void
printf(const char *fmt, ...)
{
 74a:	711d                	addi	sp,sp,-96
 74c:	ec06                	sd	ra,24(sp)
 74e:	e822                	sd	s0,16(sp)
 750:	1000                	addi	s0,sp,32
 752:	e40c                	sd	a1,8(s0)
 754:	e810                	sd	a2,16(s0)
 756:	ec14                	sd	a3,24(s0)
 758:	f018                	sd	a4,32(s0)
 75a:	f41c                	sd	a5,40(s0)
 75c:	03043823          	sd	a6,48(s0)
 760:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 764:	00840613          	addi	a2,s0,8
 768:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 76c:	85aa                	mv	a1,a0
 76e:	4505                	li	a0,1
 770:	cf1ff0ef          	jal	460 <vprintf>
}
 774:	60e2                	ld	ra,24(sp)
 776:	6442                	ld	s0,16(sp)
 778:	6125                	addi	sp,sp,96
 77a:	8082                	ret

000000000000077c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 77c:	1141                	addi	sp,sp,-16
 77e:	e406                	sd	ra,8(sp)
 780:	e022                	sd	s0,0(sp)
 782:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 784:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 788:	00001797          	auipc	a5,0x1
 78c:	8787b783          	ld	a5,-1928(a5) # 1000 <freep>
 790:	a039                	j	79e <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 792:	6398                	ld	a4,0(a5)
 794:	00e7e463          	bltu	a5,a4,79c <free+0x20>
 798:	00e6ea63          	bltu	a3,a4,7ac <free+0x30>
{
 79c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 79e:	fed7fae3          	bgeu	a5,a3,792 <free+0x16>
 7a2:	6398                	ld	a4,0(a5)
 7a4:	00e6e463          	bltu	a3,a4,7ac <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7a8:	fee7eae3          	bltu	a5,a4,79c <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 7ac:	ff852583          	lw	a1,-8(a0)
 7b0:	6390                	ld	a2,0(a5)
 7b2:	02059813          	slli	a6,a1,0x20
 7b6:	01c85713          	srli	a4,a6,0x1c
 7ba:	9736                	add	a4,a4,a3
 7bc:	02e60563          	beq	a2,a4,7e6 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 7c0:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 7c4:	4790                	lw	a2,8(a5)
 7c6:	02061593          	slli	a1,a2,0x20
 7ca:	01c5d713          	srli	a4,a1,0x1c
 7ce:	973e                	add	a4,a4,a5
 7d0:	02e68263          	beq	a3,a4,7f4 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 7d4:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7d6:	00001717          	auipc	a4,0x1
 7da:	82f73523          	sd	a5,-2006(a4) # 1000 <freep>
}
 7de:	60a2                	ld	ra,8(sp)
 7e0:	6402                	ld	s0,0(sp)
 7e2:	0141                	addi	sp,sp,16
 7e4:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 7e6:	4618                	lw	a4,8(a2)
 7e8:	9f2d                	addw	a4,a4,a1
 7ea:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7ee:	6398                	ld	a4,0(a5)
 7f0:	6310                	ld	a2,0(a4)
 7f2:	b7f9                	j	7c0 <free+0x44>
    p->s.size += bp->s.size;
 7f4:	ff852703          	lw	a4,-8(a0)
 7f8:	9f31                	addw	a4,a4,a2
 7fa:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7fc:	ff053683          	ld	a3,-16(a0)
 800:	bfd1                	j	7d4 <free+0x58>

0000000000000802 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 802:	7139                	addi	sp,sp,-64
 804:	fc06                	sd	ra,56(sp)
 806:	f822                	sd	s0,48(sp)
 808:	f04a                	sd	s2,32(sp)
 80a:	ec4e                	sd	s3,24(sp)
 80c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 80e:	02051993          	slli	s3,a0,0x20
 812:	0209d993          	srli	s3,s3,0x20
 816:	09bd                	addi	s3,s3,15
 818:	0049d993          	srli	s3,s3,0x4
 81c:	2985                	addiw	s3,s3,1
 81e:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 820:	00000517          	auipc	a0,0x0
 824:	7e053503          	ld	a0,2016(a0) # 1000 <freep>
 828:	c905                	beqz	a0,858 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 82a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 82c:	4798                	lw	a4,8(a5)
 82e:	09377663          	bgeu	a4,s3,8ba <malloc+0xb8>
 832:	f426                	sd	s1,40(sp)
 834:	e852                	sd	s4,16(sp)
 836:	e456                	sd	s5,8(sp)
 838:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 83a:	8a4e                	mv	s4,s3
 83c:	6705                	lui	a4,0x1
 83e:	00e9f363          	bgeu	s3,a4,844 <malloc+0x42>
 842:	6a05                	lui	s4,0x1
 844:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 848:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 84c:	00000497          	auipc	s1,0x0
 850:	7b448493          	addi	s1,s1,1972 # 1000 <freep>
  if(p == SBRK_ERROR)
 854:	5afd                	li	s5,-1
 856:	a83d                	j	894 <malloc+0x92>
 858:	f426                	sd	s1,40(sp)
 85a:	e852                	sd	s4,16(sp)
 85c:	e456                	sd	s5,8(sp)
 85e:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 860:	00000797          	auipc	a5,0x0
 864:	7b078793          	addi	a5,a5,1968 # 1010 <base>
 868:	00000717          	auipc	a4,0x0
 86c:	78f73c23          	sd	a5,1944(a4) # 1000 <freep>
 870:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 872:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 876:	b7d1                	j	83a <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 878:	6398                	ld	a4,0(a5)
 87a:	e118                	sd	a4,0(a0)
 87c:	a899                	j	8d2 <malloc+0xd0>
  hp->s.size = nu;
 87e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 882:	0541                	addi	a0,a0,16
 884:	ef9ff0ef          	jal	77c <free>
  return freep;
 888:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 88a:	c125                	beqz	a0,8ea <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 88c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 88e:	4798                	lw	a4,8(a5)
 890:	03277163          	bgeu	a4,s2,8b2 <malloc+0xb0>
    if(p == freep)
 894:	6098                	ld	a4,0(s1)
 896:	853e                	mv	a0,a5
 898:	fef71ae3          	bne	a4,a5,88c <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 89c:	8552                	mv	a0,s4
 89e:	9f3ff0ef          	jal	290 <sbrk>
  if(p == SBRK_ERROR)
 8a2:	fd551ee3          	bne	a0,s5,87e <malloc+0x7c>
        return 0;
 8a6:	4501                	li	a0,0
 8a8:	74a2                	ld	s1,40(sp)
 8aa:	6a42                	ld	s4,16(sp)
 8ac:	6aa2                	ld	s5,8(sp)
 8ae:	6b02                	ld	s6,0(sp)
 8b0:	a03d                	j	8de <malloc+0xdc>
 8b2:	74a2                	ld	s1,40(sp)
 8b4:	6a42                	ld	s4,16(sp)
 8b6:	6aa2                	ld	s5,8(sp)
 8b8:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8ba:	fae90fe3          	beq	s2,a4,878 <malloc+0x76>
        p->s.size -= nunits;
 8be:	4137073b          	subw	a4,a4,s3
 8c2:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8c4:	02071693          	slli	a3,a4,0x20
 8c8:	01c6d713          	srli	a4,a3,0x1c
 8cc:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8ce:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8d2:	00000717          	auipc	a4,0x0
 8d6:	72a73723          	sd	a0,1838(a4) # 1000 <freep>
      return (void*)(p + 1);
 8da:	01078513          	addi	a0,a5,16
  }
}
 8de:	70e2                	ld	ra,56(sp)
 8e0:	7442                	ld	s0,48(sp)
 8e2:	7902                	ld	s2,32(sp)
 8e4:	69e2                	ld	s3,24(sp)
 8e6:	6121                	addi	sp,sp,64
 8e8:	8082                	ret
 8ea:	74a2                	ld	s1,40(sp)
 8ec:	6a42                	ld	s4,16(sp)
 8ee:	6aa2                	ld	s5,8(sp)
 8f0:	6b02                	ld	s6,0(sp)
 8f2:	b7f5                	j	8de <malloc+0xdc>
