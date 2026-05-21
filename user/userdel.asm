
user/_userdel:     file format elf64-littleriscv


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
  if(argc != 2){
   8:	4789                	li	a5,2
   a:	00f50c63          	beq	a0,a5,22 <main+0x22>
    fprintf(2, "Usage: userdel username\n");
   e:	00001597          	auipc	a1,0x1
  12:	92258593          	addi	a1,a1,-1758 # 930 <malloc+0xf6>
  16:	853e                	mv	a0,a5
  18:	740000ef          	jal	758 <fprintf>
    exit(1);
  1c:	4505                	li	a0,1
  1e:	2de000ef          	jal	2fc <exit>
  }

  if(userdel(argv[1]) < 0){
  22:	6588                	ld	a0,8(a1)
  24:	388000ef          	jal	3ac <userdel>
  28:	00054563          	bltz	a0,32 <main+0x32>
    fprintf(2, "userdel failed\n");
    exit(1);
  }

  exit(0);
  2c:	4501                	li	a0,0
  2e:	2ce000ef          	jal	2fc <exit>
    fprintf(2, "userdel failed\n");
  32:	00001597          	auipc	a1,0x1
  36:	91e58593          	addi	a1,a1,-1762 # 950 <malloc+0x116>
  3a:	4509                	li	a0,2
  3c:	71c000ef          	jal	758 <fprintf>
    exit(1);
  40:	4505                	li	a0,1
  42:	2ba000ef          	jal	2fc <exit>

0000000000000046 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  46:	1141                	addi	sp,sp,-16
  48:	e406                	sd	ra,8(sp)
  4a:	e022                	sd	s0,0(sp)
  4c:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  4e:	fb3ff0ef          	jal	0 <main>
  exit(r);
  52:	2aa000ef          	jal	2fc <exit>

0000000000000056 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  56:	1141                	addi	sp,sp,-16
  58:	e406                	sd	ra,8(sp)
  5a:	e022                	sd	s0,0(sp)
  5c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  5e:	87aa                	mv	a5,a0
  60:	0585                	addi	a1,a1,1
  62:	0785                	addi	a5,a5,1
  64:	fff5c703          	lbu	a4,-1(a1)
  68:	fee78fa3          	sb	a4,-1(a5)
  6c:	fb75                	bnez	a4,60 <strcpy+0xa>
    ;
  return os;
}
  6e:	60a2                	ld	ra,8(sp)
  70:	6402                	ld	s0,0(sp)
  72:	0141                	addi	sp,sp,16
  74:	8082                	ret

0000000000000076 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  76:	1141                	addi	sp,sp,-16
  78:	e406                	sd	ra,8(sp)
  7a:	e022                	sd	s0,0(sp)
  7c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  7e:	00054783          	lbu	a5,0(a0)
  82:	cb91                	beqz	a5,96 <strcmp+0x20>
  84:	0005c703          	lbu	a4,0(a1)
  88:	00f71763          	bne	a4,a5,96 <strcmp+0x20>
    p++, q++;
  8c:	0505                	addi	a0,a0,1
  8e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  90:	00054783          	lbu	a5,0(a0)
  94:	fbe5                	bnez	a5,84 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  96:	0005c503          	lbu	a0,0(a1)
}
  9a:	40a7853b          	subw	a0,a5,a0
  9e:	60a2                	ld	ra,8(sp)
  a0:	6402                	ld	s0,0(sp)
  a2:	0141                	addi	sp,sp,16
  a4:	8082                	ret

00000000000000a6 <strlen>:

uint
strlen(const char *s)
{
  a6:	1141                	addi	sp,sp,-16
  a8:	e406                	sd	ra,8(sp)
  aa:	e022                	sd	s0,0(sp)
  ac:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  ae:	00054783          	lbu	a5,0(a0)
  b2:	cf91                	beqz	a5,ce <strlen+0x28>
  b4:	00150793          	addi	a5,a0,1
  b8:	86be                	mv	a3,a5
  ba:	0785                	addi	a5,a5,1
  bc:	fff7c703          	lbu	a4,-1(a5)
  c0:	ff65                	bnez	a4,b8 <strlen+0x12>
  c2:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
  c6:	60a2                	ld	ra,8(sp)
  c8:	6402                	ld	s0,0(sp)
  ca:	0141                	addi	sp,sp,16
  cc:	8082                	ret
  for(n = 0; s[n]; n++)
  ce:	4501                	li	a0,0
  d0:	bfdd                	j	c6 <strlen+0x20>

00000000000000d2 <memset>:

void*
memset(void *dst, int c, uint n)
{
  d2:	1141                	addi	sp,sp,-16
  d4:	e406                	sd	ra,8(sp)
  d6:	e022                	sd	s0,0(sp)
  d8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  da:	ca19                	beqz	a2,f0 <memset+0x1e>
  dc:	87aa                	mv	a5,a0
  de:	1602                	slli	a2,a2,0x20
  e0:	9201                	srli	a2,a2,0x20
  e2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  e6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  ea:	0785                	addi	a5,a5,1
  ec:	fee79de3          	bne	a5,a4,e6 <memset+0x14>
  }
  return dst;
}
  f0:	60a2                	ld	ra,8(sp)
  f2:	6402                	ld	s0,0(sp)
  f4:	0141                	addi	sp,sp,16
  f6:	8082                	ret

00000000000000f8 <strchr>:

char*
strchr(const char *s, char c)
{
  f8:	1141                	addi	sp,sp,-16
  fa:	e406                	sd	ra,8(sp)
  fc:	e022                	sd	s0,0(sp)
  fe:	0800                	addi	s0,sp,16
  for(; *s; s++)
 100:	00054783          	lbu	a5,0(a0)
 104:	cf81                	beqz	a5,11c <strchr+0x24>
    if(*s == c)
 106:	00f58763          	beq	a1,a5,114 <strchr+0x1c>
  for(; *s; s++)
 10a:	0505                	addi	a0,a0,1
 10c:	00054783          	lbu	a5,0(a0)
 110:	fbfd                	bnez	a5,106 <strchr+0xe>
      return (char*)s;
  return 0;
 112:	4501                	li	a0,0
}
 114:	60a2                	ld	ra,8(sp)
 116:	6402                	ld	s0,0(sp)
 118:	0141                	addi	sp,sp,16
 11a:	8082                	ret
  return 0;
 11c:	4501                	li	a0,0
 11e:	bfdd                	j	114 <strchr+0x1c>

0000000000000120 <gets>:

char*
gets(char *buf, int max)
{
 120:	711d                	addi	sp,sp,-96
 122:	ec86                	sd	ra,88(sp)
 124:	e8a2                	sd	s0,80(sp)
 126:	e4a6                	sd	s1,72(sp)
 128:	e0ca                	sd	s2,64(sp)
 12a:	fc4e                	sd	s3,56(sp)
 12c:	f852                	sd	s4,48(sp)
 12e:	f456                	sd	s5,40(sp)
 130:	f05a                	sd	s6,32(sp)
 132:	ec5e                	sd	s7,24(sp)
 134:	e862                	sd	s8,16(sp)
 136:	1080                	addi	s0,sp,96
 138:	8baa                	mv	s7,a0
 13a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 13c:	892a                	mv	s2,a0
 13e:	4481                	li	s1,0
    cc = read(0, &c, 1);
 140:	faf40b13          	addi	s6,s0,-81
 144:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 146:	8c26                	mv	s8,s1
 148:	0014899b          	addiw	s3,s1,1
 14c:	84ce                	mv	s1,s3
 14e:	0349d463          	bge	s3,s4,176 <gets+0x56>
    cc = read(0, &c, 1);
 152:	8656                	mv	a2,s5
 154:	85da                	mv	a1,s6
 156:	4501                	li	a0,0
 158:	1bc000ef          	jal	314 <read>
    if(cc < 1)
 15c:	00a05d63          	blez	a0,176 <gets+0x56>
      break;
    buf[i++] = c;
 160:	faf44783          	lbu	a5,-81(s0)
 164:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 168:	0905                	addi	s2,s2,1
 16a:	ff678713          	addi	a4,a5,-10
 16e:	c319                	beqz	a4,174 <gets+0x54>
 170:	17cd                	addi	a5,a5,-13
 172:	fbf1                	bnez	a5,146 <gets+0x26>
    buf[i++] = c;
 174:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 176:	9c5e                	add	s8,s8,s7
 178:	000c0023          	sb	zero,0(s8)
  return buf;
}
 17c:	855e                	mv	a0,s7
 17e:	60e6                	ld	ra,88(sp)
 180:	6446                	ld	s0,80(sp)
 182:	64a6                	ld	s1,72(sp)
 184:	6906                	ld	s2,64(sp)
 186:	79e2                	ld	s3,56(sp)
 188:	7a42                	ld	s4,48(sp)
 18a:	7aa2                	ld	s5,40(sp)
 18c:	7b02                	ld	s6,32(sp)
 18e:	6be2                	ld	s7,24(sp)
 190:	6c42                	ld	s8,16(sp)
 192:	6125                	addi	sp,sp,96
 194:	8082                	ret

0000000000000196 <stat>:

int
stat(const char *n, struct stat *st)
{
 196:	1101                	addi	sp,sp,-32
 198:	ec06                	sd	ra,24(sp)
 19a:	e822                	sd	s0,16(sp)
 19c:	e04a                	sd	s2,0(sp)
 19e:	1000                	addi	s0,sp,32
 1a0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1a2:	4581                	li	a1,0
 1a4:	198000ef          	jal	33c <open>
  if(fd < 0)
 1a8:	02054263          	bltz	a0,1cc <stat+0x36>
 1ac:	e426                	sd	s1,8(sp)
 1ae:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1b0:	85ca                	mv	a1,s2
 1b2:	1a2000ef          	jal	354 <fstat>
 1b6:	892a                	mv	s2,a0
  close(fd);
 1b8:	8526                	mv	a0,s1
 1ba:	16a000ef          	jal	324 <close>
  return r;
 1be:	64a2                	ld	s1,8(sp)
}
 1c0:	854a                	mv	a0,s2
 1c2:	60e2                	ld	ra,24(sp)
 1c4:	6442                	ld	s0,16(sp)
 1c6:	6902                	ld	s2,0(sp)
 1c8:	6105                	addi	sp,sp,32
 1ca:	8082                	ret
    return -1;
 1cc:	57fd                	li	a5,-1
 1ce:	893e                	mv	s2,a5
 1d0:	bfc5                	j	1c0 <stat+0x2a>

00000000000001d2 <atoi>:

int
atoi(const char *s)
{
 1d2:	1141                	addi	sp,sp,-16
 1d4:	e406                	sd	ra,8(sp)
 1d6:	e022                	sd	s0,0(sp)
 1d8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1da:	00054683          	lbu	a3,0(a0)
 1de:	fd06879b          	addiw	a5,a3,-48
 1e2:	0ff7f793          	zext.b	a5,a5
 1e6:	4625                	li	a2,9
 1e8:	02f66963          	bltu	a2,a5,21a <atoi+0x48>
 1ec:	872a                	mv	a4,a0
  n = 0;
 1ee:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1f0:	0705                	addi	a4,a4,1
 1f2:	0025179b          	slliw	a5,a0,0x2
 1f6:	9fa9                	addw	a5,a5,a0
 1f8:	0017979b          	slliw	a5,a5,0x1
 1fc:	9fb5                	addw	a5,a5,a3
 1fe:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 202:	00074683          	lbu	a3,0(a4)
 206:	fd06879b          	addiw	a5,a3,-48
 20a:	0ff7f793          	zext.b	a5,a5
 20e:	fef671e3          	bgeu	a2,a5,1f0 <atoi+0x1e>
  return n;
}
 212:	60a2                	ld	ra,8(sp)
 214:	6402                	ld	s0,0(sp)
 216:	0141                	addi	sp,sp,16
 218:	8082                	ret
  n = 0;
 21a:	4501                	li	a0,0
 21c:	bfdd                	j	212 <atoi+0x40>

000000000000021e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 21e:	1141                	addi	sp,sp,-16
 220:	e406                	sd	ra,8(sp)
 222:	e022                	sd	s0,0(sp)
 224:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 226:	02b57563          	bgeu	a0,a1,250 <memmove+0x32>
    while(n-- > 0)
 22a:	00c05f63          	blez	a2,248 <memmove+0x2a>
 22e:	1602                	slli	a2,a2,0x20
 230:	9201                	srli	a2,a2,0x20
 232:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 236:	872a                	mv	a4,a0
      *dst++ = *src++;
 238:	0585                	addi	a1,a1,1
 23a:	0705                	addi	a4,a4,1
 23c:	fff5c683          	lbu	a3,-1(a1)
 240:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 244:	fee79ae3          	bne	a5,a4,238 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 248:	60a2                	ld	ra,8(sp)
 24a:	6402                	ld	s0,0(sp)
 24c:	0141                	addi	sp,sp,16
 24e:	8082                	ret
    while(n-- > 0)
 250:	fec05ce3          	blez	a2,248 <memmove+0x2a>
    dst += n;
 254:	00c50733          	add	a4,a0,a2
    src += n;
 258:	95b2                	add	a1,a1,a2
 25a:	fff6079b          	addiw	a5,a2,-1
 25e:	1782                	slli	a5,a5,0x20
 260:	9381                	srli	a5,a5,0x20
 262:	fff7c793          	not	a5,a5
 266:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 268:	15fd                	addi	a1,a1,-1
 26a:	177d                	addi	a4,a4,-1
 26c:	0005c683          	lbu	a3,0(a1)
 270:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 274:	fef71ae3          	bne	a4,a5,268 <memmove+0x4a>
 278:	bfc1                	j	248 <memmove+0x2a>

000000000000027a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 27a:	1141                	addi	sp,sp,-16
 27c:	e406                	sd	ra,8(sp)
 27e:	e022                	sd	s0,0(sp)
 280:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 282:	c61d                	beqz	a2,2b0 <memcmp+0x36>
 284:	1602                	slli	a2,a2,0x20
 286:	9201                	srli	a2,a2,0x20
 288:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 28c:	00054783          	lbu	a5,0(a0)
 290:	0005c703          	lbu	a4,0(a1)
 294:	00e79863          	bne	a5,a4,2a4 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 298:	0505                	addi	a0,a0,1
    p2++;
 29a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 29c:	fed518e3          	bne	a0,a3,28c <memcmp+0x12>
  }
  return 0;
 2a0:	4501                	li	a0,0
 2a2:	a019                	j	2a8 <memcmp+0x2e>
      return *p1 - *p2;
 2a4:	40e7853b          	subw	a0,a5,a4
}
 2a8:	60a2                	ld	ra,8(sp)
 2aa:	6402                	ld	s0,0(sp)
 2ac:	0141                	addi	sp,sp,16
 2ae:	8082                	ret
  return 0;
 2b0:	4501                	li	a0,0
 2b2:	bfdd                	j	2a8 <memcmp+0x2e>

00000000000002b4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2b4:	1141                	addi	sp,sp,-16
 2b6:	e406                	sd	ra,8(sp)
 2b8:	e022                	sd	s0,0(sp)
 2ba:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2bc:	f63ff0ef          	jal	21e <memmove>
}
 2c0:	60a2                	ld	ra,8(sp)
 2c2:	6402                	ld	s0,0(sp)
 2c4:	0141                	addi	sp,sp,16
 2c6:	8082                	ret

00000000000002c8 <sbrk>:

char *
sbrk(int n) {
 2c8:	1141                	addi	sp,sp,-16
 2ca:	e406                	sd	ra,8(sp)
 2cc:	e022                	sd	s0,0(sp)
 2ce:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2d0:	4585                	li	a1,1
 2d2:	0b2000ef          	jal	384 <sys_sbrk>
}
 2d6:	60a2                	ld	ra,8(sp)
 2d8:	6402                	ld	s0,0(sp)
 2da:	0141                	addi	sp,sp,16
 2dc:	8082                	ret

00000000000002de <sbrklazy>:

char *
sbrklazy(int n) {
 2de:	1141                	addi	sp,sp,-16
 2e0:	e406                	sd	ra,8(sp)
 2e2:	e022                	sd	s0,0(sp)
 2e4:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2e6:	4589                	li	a1,2
 2e8:	09c000ef          	jal	384 <sys_sbrk>
}
 2ec:	60a2                	ld	ra,8(sp)
 2ee:	6402                	ld	s0,0(sp)
 2f0:	0141                	addi	sp,sp,16
 2f2:	8082                	ret

00000000000002f4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2f4:	4885                	li	a7,1
 ecall
 2f6:	00000073          	ecall
 ret
 2fa:	8082                	ret

00000000000002fc <exit>:
.global exit
exit:
 li a7, SYS_exit
 2fc:	4889                	li	a7,2
 ecall
 2fe:	00000073          	ecall
 ret
 302:	8082                	ret

0000000000000304 <wait>:
.global wait
wait:
 li a7, SYS_wait
 304:	488d                	li	a7,3
 ecall
 306:	00000073          	ecall
 ret
 30a:	8082                	ret

000000000000030c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 30c:	4891                	li	a7,4
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <read>:
.global read
read:
 li a7, SYS_read
 314:	4895                	li	a7,5
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <write>:
.global write
write:
 li a7, SYS_write
 31c:	48c1                	li	a7,16
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <close>:
.global close
close:
 li a7, SYS_close
 324:	48d5                	li	a7,21
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <kill>:
.global kill
kill:
 li a7, SYS_kill
 32c:	4899                	li	a7,6
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <exec>:
.global exec
exec:
 li a7, SYS_exec
 334:	489d                	li	a7,7
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <open>:
.global open
open:
 li a7, SYS_open
 33c:	48bd                	li	a7,15
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 344:	48c5                	li	a7,17
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 34c:	48c9                	li	a7,18
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 354:	48a1                	li	a7,8
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <link>:
.global link
link:
 li a7, SYS_link
 35c:	48cd                	li	a7,19
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 364:	48d1                	li	a7,20
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 36c:	48a5                	li	a7,9
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <dup>:
.global dup
dup:
 li a7, SYS_dup
 374:	48a9                	li	a7,10
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 37c:	48ad                	li	a7,11
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 384:	48b1                	li	a7,12
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <pause>:
.global pause
pause:
 li a7, SYS_pause
 38c:	48b5                	li	a7,13
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 394:	48b9                	li	a7,14
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <login>:
.global login
login:
 li a7, SYS_login
 39c:	48d9                	li	a7,22
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <useradd>:
.global useradd
useradd:
 li a7, SYS_useradd
 3a4:	48dd                	li	a7,23
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <userdel>:
.global userdel
userdel:
 li a7, SYS_userdel
 3ac:	48e1                	li	a7,24
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <passwd>:
.global passwd
passwd:
 li a7, SYS_passwd
 3b4:	48e5                	li	a7,25
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <whoami>:
.global whoami
whoami:
 li a7, SYS_whoami
 3bc:	48e9                	li	a7,26
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <chmod>:
.global chmod
chmod:
 li a7, SYS_chmod
 3c4:	48ed                	li	a7,27
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <chown>:
.global chown
chown:
 li a7, SYS_chown
 3cc:	48f1                	li	a7,28
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <audit_read>:
.global audit_read
audit_read:
 li a7, SYS_audit_read
 3d4:	48f5                	li	a7,29
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3dc:	1101                	addi	sp,sp,-32
 3de:	ec06                	sd	ra,24(sp)
 3e0:	e822                	sd	s0,16(sp)
 3e2:	1000                	addi	s0,sp,32
 3e4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3e8:	4605                	li	a2,1
 3ea:	fef40593          	addi	a1,s0,-17
 3ee:	f2fff0ef          	jal	31c <write>
}
 3f2:	60e2                	ld	ra,24(sp)
 3f4:	6442                	ld	s0,16(sp)
 3f6:	6105                	addi	sp,sp,32
 3f8:	8082                	ret

00000000000003fa <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3fa:	715d                	addi	sp,sp,-80
 3fc:	e486                	sd	ra,72(sp)
 3fe:	e0a2                	sd	s0,64(sp)
 400:	f84a                	sd	s2,48(sp)
 402:	f44e                	sd	s3,40(sp)
 404:	0880                	addi	s0,sp,80
 406:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 408:	c6d1                	beqz	a3,494 <printint+0x9a>
 40a:	0805d563          	bgez	a1,494 <printint+0x9a>
    neg = 1;
    x = -xx;
 40e:	40b005b3          	neg	a1,a1
    neg = 1;
 412:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 414:	fb840993          	addi	s3,s0,-72
  neg = 0;
 418:	86ce                	mv	a3,s3
  i = 0;
 41a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 41c:	00000817          	auipc	a6,0x0
 420:	54c80813          	addi	a6,a6,1356 # 968 <digits>
 424:	88ba                	mv	a7,a4
 426:	0017051b          	addiw	a0,a4,1
 42a:	872a                	mv	a4,a0
 42c:	02c5f7b3          	remu	a5,a1,a2
 430:	97c2                	add	a5,a5,a6
 432:	0007c783          	lbu	a5,0(a5)
 436:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 43a:	87ae                	mv	a5,a1
 43c:	02c5d5b3          	divu	a1,a1,a2
 440:	0685                	addi	a3,a3,1
 442:	fec7f1e3          	bgeu	a5,a2,424 <printint+0x2a>
  if(neg)
 446:	00030c63          	beqz	t1,45e <printint+0x64>
    buf[i++] = '-';
 44a:	fd050793          	addi	a5,a0,-48
 44e:	00878533          	add	a0,a5,s0
 452:	02d00793          	li	a5,45
 456:	fef50423          	sb	a5,-24(a0)
 45a:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 45e:	02e05563          	blez	a4,488 <printint+0x8e>
 462:	fc26                	sd	s1,56(sp)
 464:	377d                	addiw	a4,a4,-1
 466:	00e984b3          	add	s1,s3,a4
 46a:	19fd                	addi	s3,s3,-1
 46c:	99ba                	add	s3,s3,a4
 46e:	1702                	slli	a4,a4,0x20
 470:	9301                	srli	a4,a4,0x20
 472:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 476:	0004c583          	lbu	a1,0(s1)
 47a:	854a                	mv	a0,s2
 47c:	f61ff0ef          	jal	3dc <putc>
  while(--i >= 0)
 480:	14fd                	addi	s1,s1,-1
 482:	ff349ae3          	bne	s1,s3,476 <printint+0x7c>
 486:	74e2                	ld	s1,56(sp)
}
 488:	60a6                	ld	ra,72(sp)
 48a:	6406                	ld	s0,64(sp)
 48c:	7942                	ld	s2,48(sp)
 48e:	79a2                	ld	s3,40(sp)
 490:	6161                	addi	sp,sp,80
 492:	8082                	ret
  neg = 0;
 494:	4301                	li	t1,0
 496:	bfbd                	j	414 <printint+0x1a>

0000000000000498 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 498:	711d                	addi	sp,sp,-96
 49a:	ec86                	sd	ra,88(sp)
 49c:	e8a2                	sd	s0,80(sp)
 49e:	e4a6                	sd	s1,72(sp)
 4a0:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4a2:	0005c483          	lbu	s1,0(a1)
 4a6:	22048363          	beqz	s1,6cc <vprintf+0x234>
 4aa:	e0ca                	sd	s2,64(sp)
 4ac:	fc4e                	sd	s3,56(sp)
 4ae:	f852                	sd	s4,48(sp)
 4b0:	f456                	sd	s5,40(sp)
 4b2:	f05a                	sd	s6,32(sp)
 4b4:	ec5e                	sd	s7,24(sp)
 4b6:	e862                	sd	s8,16(sp)
 4b8:	8b2a                	mv	s6,a0
 4ba:	8a2e                	mv	s4,a1
 4bc:	8bb2                	mv	s7,a2
  state = 0;
 4be:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4c0:	4901                	li	s2,0
 4c2:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4c4:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4c8:	06400c13          	li	s8,100
 4cc:	a00d                	j	4ee <vprintf+0x56>
        putc(fd, c0);
 4ce:	85a6                	mv	a1,s1
 4d0:	855a                	mv	a0,s6
 4d2:	f0bff0ef          	jal	3dc <putc>
 4d6:	a019                	j	4dc <vprintf+0x44>
    } else if(state == '%'){
 4d8:	03598363          	beq	s3,s5,4fe <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 4dc:	0019079b          	addiw	a5,s2,1
 4e0:	893e                	mv	s2,a5
 4e2:	873e                	mv	a4,a5
 4e4:	97d2                	add	a5,a5,s4
 4e6:	0007c483          	lbu	s1,0(a5)
 4ea:	1c048a63          	beqz	s1,6be <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 4ee:	0004879b          	sext.w	a5,s1
    if(state == 0){
 4f2:	fe0993e3          	bnez	s3,4d8 <vprintf+0x40>
      if(c0 == '%'){
 4f6:	fd579ce3          	bne	a5,s5,4ce <vprintf+0x36>
        state = '%';
 4fa:	89be                	mv	s3,a5
 4fc:	b7c5                	j	4dc <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 4fe:	00ea06b3          	add	a3,s4,a4
 502:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 506:	1c060863          	beqz	a2,6d6 <vprintf+0x23e>
      if(c0 == 'd'){
 50a:	03878763          	beq	a5,s8,538 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 50e:	f9478693          	addi	a3,a5,-108
 512:	0016b693          	seqz	a3,a3
 516:	f9c60593          	addi	a1,a2,-100
 51a:	e99d                	bnez	a1,550 <vprintf+0xb8>
 51c:	ca95                	beqz	a3,550 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 51e:	008b8493          	addi	s1,s7,8
 522:	4685                	li	a3,1
 524:	4629                	li	a2,10
 526:	000bb583          	ld	a1,0(s7)
 52a:	855a                	mv	a0,s6
 52c:	ecfff0ef          	jal	3fa <printint>
        i += 1;
 530:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 532:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 534:	4981                	li	s3,0
 536:	b75d                	j	4dc <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 538:	008b8493          	addi	s1,s7,8
 53c:	4685                	li	a3,1
 53e:	4629                	li	a2,10
 540:	000ba583          	lw	a1,0(s7)
 544:	855a                	mv	a0,s6
 546:	eb5ff0ef          	jal	3fa <printint>
 54a:	8ba6                	mv	s7,s1
      state = 0;
 54c:	4981                	li	s3,0
 54e:	b779                	j	4dc <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 550:	9752                	add	a4,a4,s4
 552:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 556:	f9460713          	addi	a4,a2,-108
 55a:	00173713          	seqz	a4,a4
 55e:	8f75                	and	a4,a4,a3
 560:	f9c58513          	addi	a0,a1,-100
 564:	18051363          	bnez	a0,6ea <vprintf+0x252>
 568:	18070163          	beqz	a4,6ea <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 56c:	008b8493          	addi	s1,s7,8
 570:	4685                	li	a3,1
 572:	4629                	li	a2,10
 574:	000bb583          	ld	a1,0(s7)
 578:	855a                	mv	a0,s6
 57a:	e81ff0ef          	jal	3fa <printint>
        i += 2;
 57e:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 580:	8ba6                	mv	s7,s1
      state = 0;
 582:	4981                	li	s3,0
        i += 2;
 584:	bfa1                	j	4dc <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 586:	008b8493          	addi	s1,s7,8
 58a:	4681                	li	a3,0
 58c:	4629                	li	a2,10
 58e:	000be583          	lwu	a1,0(s7)
 592:	855a                	mv	a0,s6
 594:	e67ff0ef          	jal	3fa <printint>
 598:	8ba6                	mv	s7,s1
      state = 0;
 59a:	4981                	li	s3,0
 59c:	b781                	j	4dc <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 59e:	008b8493          	addi	s1,s7,8
 5a2:	4681                	li	a3,0
 5a4:	4629                	li	a2,10
 5a6:	000bb583          	ld	a1,0(s7)
 5aa:	855a                	mv	a0,s6
 5ac:	e4fff0ef          	jal	3fa <printint>
        i += 1;
 5b0:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5b2:	8ba6                	mv	s7,s1
      state = 0;
 5b4:	4981                	li	s3,0
 5b6:	b71d                	j	4dc <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5b8:	008b8493          	addi	s1,s7,8
 5bc:	4681                	li	a3,0
 5be:	4629                	li	a2,10
 5c0:	000bb583          	ld	a1,0(s7)
 5c4:	855a                	mv	a0,s6
 5c6:	e35ff0ef          	jal	3fa <printint>
        i += 2;
 5ca:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5cc:	8ba6                	mv	s7,s1
      state = 0;
 5ce:	4981                	li	s3,0
        i += 2;
 5d0:	b731                	j	4dc <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 5d2:	008b8493          	addi	s1,s7,8
 5d6:	4681                	li	a3,0
 5d8:	4641                	li	a2,16
 5da:	000be583          	lwu	a1,0(s7)
 5de:	855a                	mv	a0,s6
 5e0:	e1bff0ef          	jal	3fa <printint>
 5e4:	8ba6                	mv	s7,s1
      state = 0;
 5e6:	4981                	li	s3,0
 5e8:	bdd5                	j	4dc <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5ea:	008b8493          	addi	s1,s7,8
 5ee:	4681                	li	a3,0
 5f0:	4641                	li	a2,16
 5f2:	000bb583          	ld	a1,0(s7)
 5f6:	855a                	mv	a0,s6
 5f8:	e03ff0ef          	jal	3fa <printint>
        i += 1;
 5fc:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 5fe:	8ba6                	mv	s7,s1
      state = 0;
 600:	4981                	li	s3,0
 602:	bde9                	j	4dc <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 604:	008b8493          	addi	s1,s7,8
 608:	4681                	li	a3,0
 60a:	4641                	li	a2,16
 60c:	000bb583          	ld	a1,0(s7)
 610:	855a                	mv	a0,s6
 612:	de9ff0ef          	jal	3fa <printint>
        i += 2;
 616:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 618:	8ba6                	mv	s7,s1
      state = 0;
 61a:	4981                	li	s3,0
        i += 2;
 61c:	b5c1                	j	4dc <vprintf+0x44>
 61e:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 620:	008b8793          	addi	a5,s7,8
 624:	8cbe                	mv	s9,a5
 626:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 62a:	03000593          	li	a1,48
 62e:	855a                	mv	a0,s6
 630:	dadff0ef          	jal	3dc <putc>
  putc(fd, 'x');
 634:	07800593          	li	a1,120
 638:	855a                	mv	a0,s6
 63a:	da3ff0ef          	jal	3dc <putc>
 63e:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 640:	00000b97          	auipc	s7,0x0
 644:	328b8b93          	addi	s7,s7,808 # 968 <digits>
 648:	03c9d793          	srli	a5,s3,0x3c
 64c:	97de                	add	a5,a5,s7
 64e:	0007c583          	lbu	a1,0(a5)
 652:	855a                	mv	a0,s6
 654:	d89ff0ef          	jal	3dc <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 658:	0992                	slli	s3,s3,0x4
 65a:	34fd                	addiw	s1,s1,-1
 65c:	f4f5                	bnez	s1,648 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 65e:	8be6                	mv	s7,s9
      state = 0;
 660:	4981                	li	s3,0
 662:	6ca2                	ld	s9,8(sp)
 664:	bda5                	j	4dc <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 666:	008b8493          	addi	s1,s7,8
 66a:	000bc583          	lbu	a1,0(s7)
 66e:	855a                	mv	a0,s6
 670:	d6dff0ef          	jal	3dc <putc>
 674:	8ba6                	mv	s7,s1
      state = 0;
 676:	4981                	li	s3,0
 678:	b595                	j	4dc <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 67a:	008b8993          	addi	s3,s7,8
 67e:	000bb483          	ld	s1,0(s7)
 682:	cc91                	beqz	s1,69e <vprintf+0x206>
        for(; *s; s++)
 684:	0004c583          	lbu	a1,0(s1)
 688:	c985                	beqz	a1,6b8 <vprintf+0x220>
          putc(fd, *s);
 68a:	855a                	mv	a0,s6
 68c:	d51ff0ef          	jal	3dc <putc>
        for(; *s; s++)
 690:	0485                	addi	s1,s1,1
 692:	0004c583          	lbu	a1,0(s1)
 696:	f9f5                	bnez	a1,68a <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 698:	8bce                	mv	s7,s3
      state = 0;
 69a:	4981                	li	s3,0
 69c:	b581                	j	4dc <vprintf+0x44>
          s = "(null)";
 69e:	00000497          	auipc	s1,0x0
 6a2:	2c248493          	addi	s1,s1,706 # 960 <malloc+0x126>
        for(; *s; s++)
 6a6:	02800593          	li	a1,40
 6aa:	b7c5                	j	68a <vprintf+0x1f2>
        putc(fd, '%');
 6ac:	85be                	mv	a1,a5
 6ae:	855a                	mv	a0,s6
 6b0:	d2dff0ef          	jal	3dc <putc>
      state = 0;
 6b4:	4981                	li	s3,0
 6b6:	b51d                	j	4dc <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 6b8:	8bce                	mv	s7,s3
      state = 0;
 6ba:	4981                	li	s3,0
 6bc:	b505                	j	4dc <vprintf+0x44>
 6be:	6906                	ld	s2,64(sp)
 6c0:	79e2                	ld	s3,56(sp)
 6c2:	7a42                	ld	s4,48(sp)
 6c4:	7aa2                	ld	s5,40(sp)
 6c6:	7b02                	ld	s6,32(sp)
 6c8:	6be2                	ld	s7,24(sp)
 6ca:	6c42                	ld	s8,16(sp)
    }
  }
}
 6cc:	60e6                	ld	ra,88(sp)
 6ce:	6446                	ld	s0,80(sp)
 6d0:	64a6                	ld	s1,72(sp)
 6d2:	6125                	addi	sp,sp,96
 6d4:	8082                	ret
      if(c0 == 'd'){
 6d6:	06400713          	li	a4,100
 6da:	e4e78fe3          	beq	a5,a4,538 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 6de:	f9478693          	addi	a3,a5,-108
 6e2:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 6e6:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6e8:	4701                	li	a4,0
      } else if(c0 == 'u'){
 6ea:	07500513          	li	a0,117
 6ee:	e8a78ce3          	beq	a5,a0,586 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 6f2:	f8b60513          	addi	a0,a2,-117
 6f6:	e119                	bnez	a0,6fc <vprintf+0x264>
 6f8:	ea0693e3          	bnez	a3,59e <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6fc:	f8b58513          	addi	a0,a1,-117
 700:	e119                	bnez	a0,706 <vprintf+0x26e>
 702:	ea071be3          	bnez	a4,5b8 <vprintf+0x120>
      } else if(c0 == 'x'){
 706:	07800513          	li	a0,120
 70a:	eca784e3          	beq	a5,a0,5d2 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 70e:	f8860613          	addi	a2,a2,-120
 712:	e219                	bnez	a2,718 <vprintf+0x280>
 714:	ec069be3          	bnez	a3,5ea <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 718:	f8858593          	addi	a1,a1,-120
 71c:	e199                	bnez	a1,722 <vprintf+0x28a>
 71e:	ee0713e3          	bnez	a4,604 <vprintf+0x16c>
      } else if(c0 == 'p'){
 722:	07000713          	li	a4,112
 726:	eee78ce3          	beq	a5,a4,61e <vprintf+0x186>
      } else if(c0 == 'c'){
 72a:	06300713          	li	a4,99
 72e:	f2e78ce3          	beq	a5,a4,666 <vprintf+0x1ce>
      } else if(c0 == 's'){
 732:	07300713          	li	a4,115
 736:	f4e782e3          	beq	a5,a4,67a <vprintf+0x1e2>
      } else if(c0 == '%'){
 73a:	02500713          	li	a4,37
 73e:	f6e787e3          	beq	a5,a4,6ac <vprintf+0x214>
        putc(fd, '%');
 742:	02500593          	li	a1,37
 746:	855a                	mv	a0,s6
 748:	c95ff0ef          	jal	3dc <putc>
        putc(fd, c0);
 74c:	85a6                	mv	a1,s1
 74e:	855a                	mv	a0,s6
 750:	c8dff0ef          	jal	3dc <putc>
      state = 0;
 754:	4981                	li	s3,0
 756:	b359                	j	4dc <vprintf+0x44>

0000000000000758 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 758:	715d                	addi	sp,sp,-80
 75a:	ec06                	sd	ra,24(sp)
 75c:	e822                	sd	s0,16(sp)
 75e:	1000                	addi	s0,sp,32
 760:	e010                	sd	a2,0(s0)
 762:	e414                	sd	a3,8(s0)
 764:	e818                	sd	a4,16(s0)
 766:	ec1c                	sd	a5,24(s0)
 768:	03043023          	sd	a6,32(s0)
 76c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 770:	8622                	mv	a2,s0
 772:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 776:	d23ff0ef          	jal	498 <vprintf>
}
 77a:	60e2                	ld	ra,24(sp)
 77c:	6442                	ld	s0,16(sp)
 77e:	6161                	addi	sp,sp,80
 780:	8082                	ret

0000000000000782 <printf>:

void
printf(const char *fmt, ...)
{
 782:	711d                	addi	sp,sp,-96
 784:	ec06                	sd	ra,24(sp)
 786:	e822                	sd	s0,16(sp)
 788:	1000                	addi	s0,sp,32
 78a:	e40c                	sd	a1,8(s0)
 78c:	e810                	sd	a2,16(s0)
 78e:	ec14                	sd	a3,24(s0)
 790:	f018                	sd	a4,32(s0)
 792:	f41c                	sd	a5,40(s0)
 794:	03043823          	sd	a6,48(s0)
 798:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 79c:	00840613          	addi	a2,s0,8
 7a0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7a4:	85aa                	mv	a1,a0
 7a6:	4505                	li	a0,1
 7a8:	cf1ff0ef          	jal	498 <vprintf>
}
 7ac:	60e2                	ld	ra,24(sp)
 7ae:	6442                	ld	s0,16(sp)
 7b0:	6125                	addi	sp,sp,96
 7b2:	8082                	ret

00000000000007b4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7b4:	1141                	addi	sp,sp,-16
 7b6:	e406                	sd	ra,8(sp)
 7b8:	e022                	sd	s0,0(sp)
 7ba:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7bc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c0:	00001797          	auipc	a5,0x1
 7c4:	8407b783          	ld	a5,-1984(a5) # 1000 <freep>
 7c8:	a039                	j	7d6 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ca:	6398                	ld	a4,0(a5)
 7cc:	00e7e463          	bltu	a5,a4,7d4 <free+0x20>
 7d0:	00e6ea63          	bltu	a3,a4,7e4 <free+0x30>
{
 7d4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d6:	fed7fae3          	bgeu	a5,a3,7ca <free+0x16>
 7da:	6398                	ld	a4,0(a5)
 7dc:	00e6e463          	bltu	a3,a4,7e4 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e0:	fee7eae3          	bltu	a5,a4,7d4 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 7e4:	ff852583          	lw	a1,-8(a0)
 7e8:	6390                	ld	a2,0(a5)
 7ea:	02059813          	slli	a6,a1,0x20
 7ee:	01c85713          	srli	a4,a6,0x1c
 7f2:	9736                	add	a4,a4,a3
 7f4:	02e60563          	beq	a2,a4,81e <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 7f8:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 7fc:	4790                	lw	a2,8(a5)
 7fe:	02061593          	slli	a1,a2,0x20
 802:	01c5d713          	srli	a4,a1,0x1c
 806:	973e                	add	a4,a4,a5
 808:	02e68263          	beq	a3,a4,82c <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 80c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 80e:	00000717          	auipc	a4,0x0
 812:	7ef73923          	sd	a5,2034(a4) # 1000 <freep>
}
 816:	60a2                	ld	ra,8(sp)
 818:	6402                	ld	s0,0(sp)
 81a:	0141                	addi	sp,sp,16
 81c:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 81e:	4618                	lw	a4,8(a2)
 820:	9f2d                	addw	a4,a4,a1
 822:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 826:	6398                	ld	a4,0(a5)
 828:	6310                	ld	a2,0(a4)
 82a:	b7f9                	j	7f8 <free+0x44>
    p->s.size += bp->s.size;
 82c:	ff852703          	lw	a4,-8(a0)
 830:	9f31                	addw	a4,a4,a2
 832:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 834:	ff053683          	ld	a3,-16(a0)
 838:	bfd1                	j	80c <free+0x58>

000000000000083a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 83a:	7139                	addi	sp,sp,-64
 83c:	fc06                	sd	ra,56(sp)
 83e:	f822                	sd	s0,48(sp)
 840:	f04a                	sd	s2,32(sp)
 842:	ec4e                	sd	s3,24(sp)
 844:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 846:	02051993          	slli	s3,a0,0x20
 84a:	0209d993          	srli	s3,s3,0x20
 84e:	09bd                	addi	s3,s3,15
 850:	0049d993          	srli	s3,s3,0x4
 854:	2985                	addiw	s3,s3,1
 856:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 858:	00000517          	auipc	a0,0x0
 85c:	7a853503          	ld	a0,1960(a0) # 1000 <freep>
 860:	c905                	beqz	a0,890 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 862:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 864:	4798                	lw	a4,8(a5)
 866:	09377663          	bgeu	a4,s3,8f2 <malloc+0xb8>
 86a:	f426                	sd	s1,40(sp)
 86c:	e852                	sd	s4,16(sp)
 86e:	e456                	sd	s5,8(sp)
 870:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 872:	8a4e                	mv	s4,s3
 874:	6705                	lui	a4,0x1
 876:	00e9f363          	bgeu	s3,a4,87c <malloc+0x42>
 87a:	6a05                	lui	s4,0x1
 87c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 880:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 884:	00000497          	auipc	s1,0x0
 888:	77c48493          	addi	s1,s1,1916 # 1000 <freep>
  if(p == SBRK_ERROR)
 88c:	5afd                	li	s5,-1
 88e:	a83d                	j	8cc <malloc+0x92>
 890:	f426                	sd	s1,40(sp)
 892:	e852                	sd	s4,16(sp)
 894:	e456                	sd	s5,8(sp)
 896:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 898:	00000797          	auipc	a5,0x0
 89c:	77878793          	addi	a5,a5,1912 # 1010 <base>
 8a0:	00000717          	auipc	a4,0x0
 8a4:	76f73023          	sd	a5,1888(a4) # 1000 <freep>
 8a8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8aa:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8ae:	b7d1                	j	872 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 8b0:	6398                	ld	a4,0(a5)
 8b2:	e118                	sd	a4,0(a0)
 8b4:	a899                	j	90a <malloc+0xd0>
  hp->s.size = nu;
 8b6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8ba:	0541                	addi	a0,a0,16
 8bc:	ef9ff0ef          	jal	7b4 <free>
  return freep;
 8c0:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 8c2:	c125                	beqz	a0,922 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8c6:	4798                	lw	a4,8(a5)
 8c8:	03277163          	bgeu	a4,s2,8ea <malloc+0xb0>
    if(p == freep)
 8cc:	6098                	ld	a4,0(s1)
 8ce:	853e                	mv	a0,a5
 8d0:	fef71ae3          	bne	a4,a5,8c4 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 8d4:	8552                	mv	a0,s4
 8d6:	9f3ff0ef          	jal	2c8 <sbrk>
  if(p == SBRK_ERROR)
 8da:	fd551ee3          	bne	a0,s5,8b6 <malloc+0x7c>
        return 0;
 8de:	4501                	li	a0,0
 8e0:	74a2                	ld	s1,40(sp)
 8e2:	6a42                	ld	s4,16(sp)
 8e4:	6aa2                	ld	s5,8(sp)
 8e6:	6b02                	ld	s6,0(sp)
 8e8:	a03d                	j	916 <malloc+0xdc>
 8ea:	74a2                	ld	s1,40(sp)
 8ec:	6a42                	ld	s4,16(sp)
 8ee:	6aa2                	ld	s5,8(sp)
 8f0:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8f2:	fae90fe3          	beq	s2,a4,8b0 <malloc+0x76>
        p->s.size -= nunits;
 8f6:	4137073b          	subw	a4,a4,s3
 8fa:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8fc:	02071693          	slli	a3,a4,0x20
 900:	01c6d713          	srli	a4,a3,0x1c
 904:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 906:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 90a:	00000717          	auipc	a4,0x0
 90e:	6ea73b23          	sd	a0,1782(a4) # 1000 <freep>
      return (void*)(p + 1);
 912:	01078513          	addi	a0,a5,16
  }
}
 916:	70e2                	ld	ra,56(sp)
 918:	7442                	ld	s0,48(sp)
 91a:	7902                	ld	s2,32(sp)
 91c:	69e2                	ld	s3,24(sp)
 91e:	6121                	addi	sp,sp,64
 920:	8082                	ret
 922:	74a2                	ld	s1,40(sp)
 924:	6a42                	ld	s4,16(sp)
 926:	6aa2                	ld	s5,8(sp)
 928:	6b02                	ld	s6,0(sp)
 92a:	b7f5                	j	916 <malloc+0xdc>
