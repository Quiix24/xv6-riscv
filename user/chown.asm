
user/_chown:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
  if(argc < 4){
   8:	478d                	li	a5,3
   a:	06a7de63          	bge	a5,a0,86 <main+0x86>
   e:	e426                	sd	s1,8(sp)
  10:	84ae                	mv	s1,a1
    exit(1);
  }

  // Simple decimal parsing for uid
  int uid = 0;
  char *s = argv[1];
  12:	6594                	ld	a3,8(a1)
  while(*s){
  14:	0006c783          	lbu	a5,0(a3)
  18:	cfc1                	beqz	a5,b0 <main+0xb0>
  int uid = 0;
  1a:	4581                	li	a1,0
    if(*s >= '0' && *s <= '9'){
  1c:	4625                	li	a2,9
  1e:	fd07871b          	addiw	a4,a5,-48
  22:	0ff77713          	zext.b	a4,a4
  26:	06e66b63          	bltu	a2,a4,9c <main+0x9c>
      uid = uid * 10 + (*s - '0');
  2a:	0025971b          	slliw	a4,a1,0x2
  2e:	9f2d                	addw	a4,a4,a1
  30:	0017171b          	slliw	a4,a4,0x1
  34:	fd07879b          	addiw	a5,a5,-48
  38:	00e785bb          	addw	a1,a5,a4
      s++;
  3c:	0685                	addi	a3,a3,1
  while(*s){
  3e:	0006c783          	lbu	a5,0(a3)
  42:	fff1                	bnez	a5,1e <main+0x1e>
    }
  }

  // Simple decimal parsing for gid
  int gid = 0;
  s = argv[2];
  44:	6894                	ld	a3,16(s1)
  while(*s){
  46:	0006c783          	lbu	a5,0(a3)
  4a:	cfbd                	beqz	a5,c8 <main+0xc8>
  int gid = 0;
  4c:	4601                	li	a2,0
    if(*s >= '0' && *s <= '9'){
  4e:	4525                	li	a0,9
  50:	fd07871b          	addiw	a4,a5,-48
  54:	0ff77713          	zext.b	a4,a4
  58:	04e56e63          	bltu	a0,a4,b4 <main+0xb4>
      gid = gid * 10 + (*s - '0');
  5c:	0026171b          	slliw	a4,a2,0x2
  60:	9f31                	addw	a4,a4,a2
  62:	0017171b          	slliw	a4,a4,0x1
  66:	fd07879b          	addiw	a5,a5,-48
  6a:	00e7863b          	addw	a2,a5,a4
      s++;
  6e:	0685                	addi	a3,a3,1
  while(*s){
  70:	0006c783          	lbu	a5,0(a3)
  74:	fff1                	bnez	a5,50 <main+0x50>
      fprintf(2, "chown: gid must be numeric\n");
      exit(1);
    }
  }

  if(chown(argv[3], uid, gid) < 0){
  76:	6c88                	ld	a0,24(s1)
  78:	3f0000ef          	jal	468 <chown>
  7c:	04054863          	bltz	a0,cc <main+0xcc>
    fprintf(2, "chown: cannot change %s\n", argv[3]);
    exit(1);
  }
  
  exit(0);
  80:	4501                	li	a0,0
  82:	316000ef          	jal	398 <exit>
  86:	e426                	sd	s1,8(sp)
    fprintf(2, "Usage: chown <uid> <gid> <file>\n");
  88:	00001597          	auipc	a1,0x1
  8c:	94858593          	addi	a1,a1,-1720 # 9d0 <malloc+0xfa>
  90:	4509                	li	a0,2
  92:	762000ef          	jal	7f4 <fprintf>
    exit(1);
  96:	4505                	li	a0,1
  98:	300000ef          	jal	398 <exit>
      fprintf(2, "chown: uid must be numeric\n");
  9c:	00001597          	auipc	a1,0x1
  a0:	95c58593          	addi	a1,a1,-1700 # 9f8 <malloc+0x122>
  a4:	4509                	li	a0,2
  a6:	74e000ef          	jal	7f4 <fprintf>
      exit(1);
  aa:	4505                	li	a0,1
  ac:	2ec000ef          	jal	398 <exit>
  int uid = 0;
  b0:	4581                	li	a1,0
  b2:	bf49                	j	44 <main+0x44>
      fprintf(2, "chown: gid must be numeric\n");
  b4:	00001597          	auipc	a1,0x1
  b8:	96458593          	addi	a1,a1,-1692 # a18 <malloc+0x142>
  bc:	4509                	li	a0,2
  be:	736000ef          	jal	7f4 <fprintf>
      exit(1);
  c2:	4505                	li	a0,1
  c4:	2d4000ef          	jal	398 <exit>
  int gid = 0;
  c8:	4601                	li	a2,0
  ca:	b775                	j	76 <main+0x76>
    fprintf(2, "chown: cannot change %s\n", argv[3]);
  cc:	6c90                	ld	a2,24(s1)
  ce:	00001597          	auipc	a1,0x1
  d2:	96a58593          	addi	a1,a1,-1686 # a38 <malloc+0x162>
  d6:	4509                	li	a0,2
  d8:	71c000ef          	jal	7f4 <fprintf>
    exit(1);
  dc:	4505                	li	a0,1
  de:	2ba000ef          	jal	398 <exit>

00000000000000e2 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  e2:	1141                	addi	sp,sp,-16
  e4:	e406                	sd	ra,8(sp)
  e6:	e022                	sd	s0,0(sp)
  e8:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  ea:	f17ff0ef          	jal	0 <main>
  exit(r);
  ee:	2aa000ef          	jal	398 <exit>

00000000000000f2 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  f2:	1141                	addi	sp,sp,-16
  f4:	e406                	sd	ra,8(sp)
  f6:	e022                	sd	s0,0(sp)
  f8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  fa:	87aa                	mv	a5,a0
  fc:	0585                	addi	a1,a1,1
  fe:	0785                	addi	a5,a5,1
 100:	fff5c703          	lbu	a4,-1(a1)
 104:	fee78fa3          	sb	a4,-1(a5)
 108:	fb75                	bnez	a4,fc <strcpy+0xa>
    ;
  return os;
}
 10a:	60a2                	ld	ra,8(sp)
 10c:	6402                	ld	s0,0(sp)
 10e:	0141                	addi	sp,sp,16
 110:	8082                	ret

0000000000000112 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 112:	1141                	addi	sp,sp,-16
 114:	e406                	sd	ra,8(sp)
 116:	e022                	sd	s0,0(sp)
 118:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 11a:	00054783          	lbu	a5,0(a0)
 11e:	cb91                	beqz	a5,132 <strcmp+0x20>
 120:	0005c703          	lbu	a4,0(a1)
 124:	00f71763          	bne	a4,a5,132 <strcmp+0x20>
    p++, q++;
 128:	0505                	addi	a0,a0,1
 12a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 12c:	00054783          	lbu	a5,0(a0)
 130:	fbe5                	bnez	a5,120 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 132:	0005c503          	lbu	a0,0(a1)
}
 136:	40a7853b          	subw	a0,a5,a0
 13a:	60a2                	ld	ra,8(sp)
 13c:	6402                	ld	s0,0(sp)
 13e:	0141                	addi	sp,sp,16
 140:	8082                	ret

0000000000000142 <strlen>:

uint
strlen(const char *s)
{
 142:	1141                	addi	sp,sp,-16
 144:	e406                	sd	ra,8(sp)
 146:	e022                	sd	s0,0(sp)
 148:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 14a:	00054783          	lbu	a5,0(a0)
 14e:	cf91                	beqz	a5,16a <strlen+0x28>
 150:	00150793          	addi	a5,a0,1
 154:	86be                	mv	a3,a5
 156:	0785                	addi	a5,a5,1
 158:	fff7c703          	lbu	a4,-1(a5)
 15c:	ff65                	bnez	a4,154 <strlen+0x12>
 15e:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 162:	60a2                	ld	ra,8(sp)
 164:	6402                	ld	s0,0(sp)
 166:	0141                	addi	sp,sp,16
 168:	8082                	ret
  for(n = 0; s[n]; n++)
 16a:	4501                	li	a0,0
 16c:	bfdd                	j	162 <strlen+0x20>

000000000000016e <memset>:

void*
memset(void *dst, int c, uint n)
{
 16e:	1141                	addi	sp,sp,-16
 170:	e406                	sd	ra,8(sp)
 172:	e022                	sd	s0,0(sp)
 174:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 176:	ca19                	beqz	a2,18c <memset+0x1e>
 178:	87aa                	mv	a5,a0
 17a:	1602                	slli	a2,a2,0x20
 17c:	9201                	srli	a2,a2,0x20
 17e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 182:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 186:	0785                	addi	a5,a5,1
 188:	fee79de3          	bne	a5,a4,182 <memset+0x14>
  }
  return dst;
}
 18c:	60a2                	ld	ra,8(sp)
 18e:	6402                	ld	s0,0(sp)
 190:	0141                	addi	sp,sp,16
 192:	8082                	ret

0000000000000194 <strchr>:

char*
strchr(const char *s, char c)
{
 194:	1141                	addi	sp,sp,-16
 196:	e406                	sd	ra,8(sp)
 198:	e022                	sd	s0,0(sp)
 19a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 19c:	00054783          	lbu	a5,0(a0)
 1a0:	cf81                	beqz	a5,1b8 <strchr+0x24>
    if(*s == c)
 1a2:	00f58763          	beq	a1,a5,1b0 <strchr+0x1c>
  for(; *s; s++)
 1a6:	0505                	addi	a0,a0,1
 1a8:	00054783          	lbu	a5,0(a0)
 1ac:	fbfd                	bnez	a5,1a2 <strchr+0xe>
      return (char*)s;
  return 0;
 1ae:	4501                	li	a0,0
}
 1b0:	60a2                	ld	ra,8(sp)
 1b2:	6402                	ld	s0,0(sp)
 1b4:	0141                	addi	sp,sp,16
 1b6:	8082                	ret
  return 0;
 1b8:	4501                	li	a0,0
 1ba:	bfdd                	j	1b0 <strchr+0x1c>

00000000000001bc <gets>:

char*
gets(char *buf, int max)
{
 1bc:	711d                	addi	sp,sp,-96
 1be:	ec86                	sd	ra,88(sp)
 1c0:	e8a2                	sd	s0,80(sp)
 1c2:	e4a6                	sd	s1,72(sp)
 1c4:	e0ca                	sd	s2,64(sp)
 1c6:	fc4e                	sd	s3,56(sp)
 1c8:	f852                	sd	s4,48(sp)
 1ca:	f456                	sd	s5,40(sp)
 1cc:	f05a                	sd	s6,32(sp)
 1ce:	ec5e                	sd	s7,24(sp)
 1d0:	e862                	sd	s8,16(sp)
 1d2:	1080                	addi	s0,sp,96
 1d4:	8baa                	mv	s7,a0
 1d6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d8:	892a                	mv	s2,a0
 1da:	4481                	li	s1,0
    cc = read(0, &c, 1);
 1dc:	faf40b13          	addi	s6,s0,-81
 1e0:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 1e2:	8c26                	mv	s8,s1
 1e4:	0014899b          	addiw	s3,s1,1
 1e8:	84ce                	mv	s1,s3
 1ea:	0349d463          	bge	s3,s4,212 <gets+0x56>
    cc = read(0, &c, 1);
 1ee:	8656                	mv	a2,s5
 1f0:	85da                	mv	a1,s6
 1f2:	4501                	li	a0,0
 1f4:	1bc000ef          	jal	3b0 <read>
    if(cc < 1)
 1f8:	00a05d63          	blez	a0,212 <gets+0x56>
      break;
    buf[i++] = c;
 1fc:	faf44783          	lbu	a5,-81(s0)
 200:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 204:	0905                	addi	s2,s2,1
 206:	ff678713          	addi	a4,a5,-10
 20a:	c319                	beqz	a4,210 <gets+0x54>
 20c:	17cd                	addi	a5,a5,-13
 20e:	fbf1                	bnez	a5,1e2 <gets+0x26>
    buf[i++] = c;
 210:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 212:	9c5e                	add	s8,s8,s7
 214:	000c0023          	sb	zero,0(s8)
  return buf;
}
 218:	855e                	mv	a0,s7
 21a:	60e6                	ld	ra,88(sp)
 21c:	6446                	ld	s0,80(sp)
 21e:	64a6                	ld	s1,72(sp)
 220:	6906                	ld	s2,64(sp)
 222:	79e2                	ld	s3,56(sp)
 224:	7a42                	ld	s4,48(sp)
 226:	7aa2                	ld	s5,40(sp)
 228:	7b02                	ld	s6,32(sp)
 22a:	6be2                	ld	s7,24(sp)
 22c:	6c42                	ld	s8,16(sp)
 22e:	6125                	addi	sp,sp,96
 230:	8082                	ret

0000000000000232 <stat>:

int
stat(const char *n, struct stat *st)
{
 232:	1101                	addi	sp,sp,-32
 234:	ec06                	sd	ra,24(sp)
 236:	e822                	sd	s0,16(sp)
 238:	e04a                	sd	s2,0(sp)
 23a:	1000                	addi	s0,sp,32
 23c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 23e:	4581                	li	a1,0
 240:	198000ef          	jal	3d8 <open>
  if(fd < 0)
 244:	02054263          	bltz	a0,268 <stat+0x36>
 248:	e426                	sd	s1,8(sp)
 24a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 24c:	85ca                	mv	a1,s2
 24e:	1a2000ef          	jal	3f0 <fstat>
 252:	892a                	mv	s2,a0
  close(fd);
 254:	8526                	mv	a0,s1
 256:	16a000ef          	jal	3c0 <close>
  return r;
 25a:	64a2                	ld	s1,8(sp)
}
 25c:	854a                	mv	a0,s2
 25e:	60e2                	ld	ra,24(sp)
 260:	6442                	ld	s0,16(sp)
 262:	6902                	ld	s2,0(sp)
 264:	6105                	addi	sp,sp,32
 266:	8082                	ret
    return -1;
 268:	57fd                	li	a5,-1
 26a:	893e                	mv	s2,a5
 26c:	bfc5                	j	25c <stat+0x2a>

000000000000026e <atoi>:

int
atoi(const char *s)
{
 26e:	1141                	addi	sp,sp,-16
 270:	e406                	sd	ra,8(sp)
 272:	e022                	sd	s0,0(sp)
 274:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 276:	00054683          	lbu	a3,0(a0)
 27a:	fd06879b          	addiw	a5,a3,-48
 27e:	0ff7f793          	zext.b	a5,a5
 282:	4625                	li	a2,9
 284:	02f66963          	bltu	a2,a5,2b6 <atoi+0x48>
 288:	872a                	mv	a4,a0
  n = 0;
 28a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 28c:	0705                	addi	a4,a4,1
 28e:	0025179b          	slliw	a5,a0,0x2
 292:	9fa9                	addw	a5,a5,a0
 294:	0017979b          	slliw	a5,a5,0x1
 298:	9fb5                	addw	a5,a5,a3
 29a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 29e:	00074683          	lbu	a3,0(a4)
 2a2:	fd06879b          	addiw	a5,a3,-48
 2a6:	0ff7f793          	zext.b	a5,a5
 2aa:	fef671e3          	bgeu	a2,a5,28c <atoi+0x1e>
  return n;
}
 2ae:	60a2                	ld	ra,8(sp)
 2b0:	6402                	ld	s0,0(sp)
 2b2:	0141                	addi	sp,sp,16
 2b4:	8082                	ret
  n = 0;
 2b6:	4501                	li	a0,0
 2b8:	bfdd                	j	2ae <atoi+0x40>

00000000000002ba <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2ba:	1141                	addi	sp,sp,-16
 2bc:	e406                	sd	ra,8(sp)
 2be:	e022                	sd	s0,0(sp)
 2c0:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2c2:	02b57563          	bgeu	a0,a1,2ec <memmove+0x32>
    while(n-- > 0)
 2c6:	00c05f63          	blez	a2,2e4 <memmove+0x2a>
 2ca:	1602                	slli	a2,a2,0x20
 2cc:	9201                	srli	a2,a2,0x20
 2ce:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2d2:	872a                	mv	a4,a0
      *dst++ = *src++;
 2d4:	0585                	addi	a1,a1,1
 2d6:	0705                	addi	a4,a4,1
 2d8:	fff5c683          	lbu	a3,-1(a1)
 2dc:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2e0:	fee79ae3          	bne	a5,a4,2d4 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2e4:	60a2                	ld	ra,8(sp)
 2e6:	6402                	ld	s0,0(sp)
 2e8:	0141                	addi	sp,sp,16
 2ea:	8082                	ret
    while(n-- > 0)
 2ec:	fec05ce3          	blez	a2,2e4 <memmove+0x2a>
    dst += n;
 2f0:	00c50733          	add	a4,a0,a2
    src += n;
 2f4:	95b2                	add	a1,a1,a2
 2f6:	fff6079b          	addiw	a5,a2,-1
 2fa:	1782                	slli	a5,a5,0x20
 2fc:	9381                	srli	a5,a5,0x20
 2fe:	fff7c793          	not	a5,a5
 302:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 304:	15fd                	addi	a1,a1,-1
 306:	177d                	addi	a4,a4,-1
 308:	0005c683          	lbu	a3,0(a1)
 30c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 310:	fef71ae3          	bne	a4,a5,304 <memmove+0x4a>
 314:	bfc1                	j	2e4 <memmove+0x2a>

0000000000000316 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 316:	1141                	addi	sp,sp,-16
 318:	e406                	sd	ra,8(sp)
 31a:	e022                	sd	s0,0(sp)
 31c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 31e:	c61d                	beqz	a2,34c <memcmp+0x36>
 320:	1602                	slli	a2,a2,0x20
 322:	9201                	srli	a2,a2,0x20
 324:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 328:	00054783          	lbu	a5,0(a0)
 32c:	0005c703          	lbu	a4,0(a1)
 330:	00e79863          	bne	a5,a4,340 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 334:	0505                	addi	a0,a0,1
    p2++;
 336:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 338:	fed518e3          	bne	a0,a3,328 <memcmp+0x12>
  }
  return 0;
 33c:	4501                	li	a0,0
 33e:	a019                	j	344 <memcmp+0x2e>
      return *p1 - *p2;
 340:	40e7853b          	subw	a0,a5,a4
}
 344:	60a2                	ld	ra,8(sp)
 346:	6402                	ld	s0,0(sp)
 348:	0141                	addi	sp,sp,16
 34a:	8082                	ret
  return 0;
 34c:	4501                	li	a0,0
 34e:	bfdd                	j	344 <memcmp+0x2e>

0000000000000350 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 350:	1141                	addi	sp,sp,-16
 352:	e406                	sd	ra,8(sp)
 354:	e022                	sd	s0,0(sp)
 356:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 358:	f63ff0ef          	jal	2ba <memmove>
}
 35c:	60a2                	ld	ra,8(sp)
 35e:	6402                	ld	s0,0(sp)
 360:	0141                	addi	sp,sp,16
 362:	8082                	ret

0000000000000364 <sbrk>:

char *
sbrk(int n) {
 364:	1141                	addi	sp,sp,-16
 366:	e406                	sd	ra,8(sp)
 368:	e022                	sd	s0,0(sp)
 36a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 36c:	4585                	li	a1,1
 36e:	0b2000ef          	jal	420 <sys_sbrk>
}
 372:	60a2                	ld	ra,8(sp)
 374:	6402                	ld	s0,0(sp)
 376:	0141                	addi	sp,sp,16
 378:	8082                	ret

000000000000037a <sbrklazy>:

char *
sbrklazy(int n) {
 37a:	1141                	addi	sp,sp,-16
 37c:	e406                	sd	ra,8(sp)
 37e:	e022                	sd	s0,0(sp)
 380:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 382:	4589                	li	a1,2
 384:	09c000ef          	jal	420 <sys_sbrk>
}
 388:	60a2                	ld	ra,8(sp)
 38a:	6402                	ld	s0,0(sp)
 38c:	0141                	addi	sp,sp,16
 38e:	8082                	ret

0000000000000390 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 390:	4885                	li	a7,1
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <exit>:
.global exit
exit:
 li a7, SYS_exit
 398:	4889                	li	a7,2
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3a0:	488d                	li	a7,3
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3a8:	4891                	li	a7,4
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <read>:
.global read
read:
 li a7, SYS_read
 3b0:	4895                	li	a7,5
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <write>:
.global write
write:
 li a7, SYS_write
 3b8:	48c1                	li	a7,16
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <close>:
.global close
close:
 li a7, SYS_close
 3c0:	48d5                	li	a7,21
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3c8:	4899                	li	a7,6
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3d0:	489d                	li	a7,7
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <open>:
.global open
open:
 li a7, SYS_open
 3d8:	48bd                	li	a7,15
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3e0:	48c5                	li	a7,17
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3e8:	48c9                	li	a7,18
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3f0:	48a1                	li	a7,8
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <link>:
.global link
link:
 li a7, SYS_link
 3f8:	48cd                	li	a7,19
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 400:	48d1                	li	a7,20
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 408:	48a5                	li	a7,9
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <dup>:
.global dup
dup:
 li a7, SYS_dup
 410:	48a9                	li	a7,10
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 418:	48ad                	li	a7,11
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 420:	48b1                	li	a7,12
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <pause>:
.global pause
pause:
 li a7, SYS_pause
 428:	48b5                	li	a7,13
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 430:	48b9                	li	a7,14
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <login>:
.global login
login:
 li a7, SYS_login
 438:	48d9                	li	a7,22
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <useradd>:
.global useradd
useradd:
 li a7, SYS_useradd
 440:	48dd                	li	a7,23
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <userdel>:
.global userdel
userdel:
 li a7, SYS_userdel
 448:	48e1                	li	a7,24
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <passwd>:
.global passwd
passwd:
 li a7, SYS_passwd
 450:	48e5                	li	a7,25
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <whoami>:
.global whoami
whoami:
 li a7, SYS_whoami
 458:	48e9                	li	a7,26
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <chmod>:
.global chmod
chmod:
 li a7, SYS_chmod
 460:	48ed                	li	a7,27
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <chown>:
.global chown
chown:
 li a7, SYS_chown
 468:	48f1                	li	a7,28
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <audit_read>:
.global audit_read
audit_read:
 li a7, SYS_audit_read
 470:	48f5                	li	a7,29
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 478:	1101                	addi	sp,sp,-32
 47a:	ec06                	sd	ra,24(sp)
 47c:	e822                	sd	s0,16(sp)
 47e:	1000                	addi	s0,sp,32
 480:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 484:	4605                	li	a2,1
 486:	fef40593          	addi	a1,s0,-17
 48a:	f2fff0ef          	jal	3b8 <write>
}
 48e:	60e2                	ld	ra,24(sp)
 490:	6442                	ld	s0,16(sp)
 492:	6105                	addi	sp,sp,32
 494:	8082                	ret

0000000000000496 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 496:	715d                	addi	sp,sp,-80
 498:	e486                	sd	ra,72(sp)
 49a:	e0a2                	sd	s0,64(sp)
 49c:	f84a                	sd	s2,48(sp)
 49e:	f44e                	sd	s3,40(sp)
 4a0:	0880                	addi	s0,sp,80
 4a2:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4a4:	c6d1                	beqz	a3,530 <printint+0x9a>
 4a6:	0805d563          	bgez	a1,530 <printint+0x9a>
    neg = 1;
    x = -xx;
 4aa:	40b005b3          	neg	a1,a1
    neg = 1;
 4ae:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 4b0:	fb840993          	addi	s3,s0,-72
  neg = 0;
 4b4:	86ce                	mv	a3,s3
  i = 0;
 4b6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4b8:	00000817          	auipc	a6,0x0
 4bc:	5a880813          	addi	a6,a6,1448 # a60 <digits>
 4c0:	88ba                	mv	a7,a4
 4c2:	0017051b          	addiw	a0,a4,1
 4c6:	872a                	mv	a4,a0
 4c8:	02c5f7b3          	remu	a5,a1,a2
 4cc:	97c2                	add	a5,a5,a6
 4ce:	0007c783          	lbu	a5,0(a5)
 4d2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4d6:	87ae                	mv	a5,a1
 4d8:	02c5d5b3          	divu	a1,a1,a2
 4dc:	0685                	addi	a3,a3,1
 4de:	fec7f1e3          	bgeu	a5,a2,4c0 <printint+0x2a>
  if(neg)
 4e2:	00030c63          	beqz	t1,4fa <printint+0x64>
    buf[i++] = '-';
 4e6:	fd050793          	addi	a5,a0,-48
 4ea:	00878533          	add	a0,a5,s0
 4ee:	02d00793          	li	a5,45
 4f2:	fef50423          	sb	a5,-24(a0)
 4f6:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 4fa:	02e05563          	blez	a4,524 <printint+0x8e>
 4fe:	fc26                	sd	s1,56(sp)
 500:	377d                	addiw	a4,a4,-1
 502:	00e984b3          	add	s1,s3,a4
 506:	19fd                	addi	s3,s3,-1
 508:	99ba                	add	s3,s3,a4
 50a:	1702                	slli	a4,a4,0x20
 50c:	9301                	srli	a4,a4,0x20
 50e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 512:	0004c583          	lbu	a1,0(s1)
 516:	854a                	mv	a0,s2
 518:	f61ff0ef          	jal	478 <putc>
  while(--i >= 0)
 51c:	14fd                	addi	s1,s1,-1
 51e:	ff349ae3          	bne	s1,s3,512 <printint+0x7c>
 522:	74e2                	ld	s1,56(sp)
}
 524:	60a6                	ld	ra,72(sp)
 526:	6406                	ld	s0,64(sp)
 528:	7942                	ld	s2,48(sp)
 52a:	79a2                	ld	s3,40(sp)
 52c:	6161                	addi	sp,sp,80
 52e:	8082                	ret
  neg = 0;
 530:	4301                	li	t1,0
 532:	bfbd                	j	4b0 <printint+0x1a>

0000000000000534 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 534:	711d                	addi	sp,sp,-96
 536:	ec86                	sd	ra,88(sp)
 538:	e8a2                	sd	s0,80(sp)
 53a:	e4a6                	sd	s1,72(sp)
 53c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 53e:	0005c483          	lbu	s1,0(a1)
 542:	22048363          	beqz	s1,768 <vprintf+0x234>
 546:	e0ca                	sd	s2,64(sp)
 548:	fc4e                	sd	s3,56(sp)
 54a:	f852                	sd	s4,48(sp)
 54c:	f456                	sd	s5,40(sp)
 54e:	f05a                	sd	s6,32(sp)
 550:	ec5e                	sd	s7,24(sp)
 552:	e862                	sd	s8,16(sp)
 554:	8b2a                	mv	s6,a0
 556:	8a2e                	mv	s4,a1
 558:	8bb2                	mv	s7,a2
  state = 0;
 55a:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 55c:	4901                	li	s2,0
 55e:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 560:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 564:	06400c13          	li	s8,100
 568:	a00d                	j	58a <vprintf+0x56>
        putc(fd, c0);
 56a:	85a6                	mv	a1,s1
 56c:	855a                	mv	a0,s6
 56e:	f0bff0ef          	jal	478 <putc>
 572:	a019                	j	578 <vprintf+0x44>
    } else if(state == '%'){
 574:	03598363          	beq	s3,s5,59a <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 578:	0019079b          	addiw	a5,s2,1
 57c:	893e                	mv	s2,a5
 57e:	873e                	mv	a4,a5
 580:	97d2                	add	a5,a5,s4
 582:	0007c483          	lbu	s1,0(a5)
 586:	1c048a63          	beqz	s1,75a <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 58a:	0004879b          	sext.w	a5,s1
    if(state == 0){
 58e:	fe0993e3          	bnez	s3,574 <vprintf+0x40>
      if(c0 == '%'){
 592:	fd579ce3          	bne	a5,s5,56a <vprintf+0x36>
        state = '%';
 596:	89be                	mv	s3,a5
 598:	b7c5                	j	578 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 59a:	00ea06b3          	add	a3,s4,a4
 59e:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 5a2:	1c060863          	beqz	a2,772 <vprintf+0x23e>
      if(c0 == 'd'){
 5a6:	03878763          	beq	a5,s8,5d4 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5aa:	f9478693          	addi	a3,a5,-108
 5ae:	0016b693          	seqz	a3,a3
 5b2:	f9c60593          	addi	a1,a2,-100
 5b6:	e99d                	bnez	a1,5ec <vprintf+0xb8>
 5b8:	ca95                	beqz	a3,5ec <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ba:	008b8493          	addi	s1,s7,8
 5be:	4685                	li	a3,1
 5c0:	4629                	li	a2,10
 5c2:	000bb583          	ld	a1,0(s7)
 5c6:	855a                	mv	a0,s6
 5c8:	ecfff0ef          	jal	496 <printint>
        i += 1;
 5cc:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ce:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5d0:	4981                	li	s3,0
 5d2:	b75d                	j	578 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 5d4:	008b8493          	addi	s1,s7,8
 5d8:	4685                	li	a3,1
 5da:	4629                	li	a2,10
 5dc:	000ba583          	lw	a1,0(s7)
 5e0:	855a                	mv	a0,s6
 5e2:	eb5ff0ef          	jal	496 <printint>
 5e6:	8ba6                	mv	s7,s1
      state = 0;
 5e8:	4981                	li	s3,0
 5ea:	b779                	j	578 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 5ec:	9752                	add	a4,a4,s4
 5ee:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5f2:	f9460713          	addi	a4,a2,-108
 5f6:	00173713          	seqz	a4,a4
 5fa:	8f75                	and	a4,a4,a3
 5fc:	f9c58513          	addi	a0,a1,-100
 600:	18051363          	bnez	a0,786 <vprintf+0x252>
 604:	18070163          	beqz	a4,786 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 608:	008b8493          	addi	s1,s7,8
 60c:	4685                	li	a3,1
 60e:	4629                	li	a2,10
 610:	000bb583          	ld	a1,0(s7)
 614:	855a                	mv	a0,s6
 616:	e81ff0ef          	jal	496 <printint>
        i += 2;
 61a:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 61c:	8ba6                	mv	s7,s1
      state = 0;
 61e:	4981                	li	s3,0
        i += 2;
 620:	bfa1                	j	578 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 622:	008b8493          	addi	s1,s7,8
 626:	4681                	li	a3,0
 628:	4629                	li	a2,10
 62a:	000be583          	lwu	a1,0(s7)
 62e:	855a                	mv	a0,s6
 630:	e67ff0ef          	jal	496 <printint>
 634:	8ba6                	mv	s7,s1
      state = 0;
 636:	4981                	li	s3,0
 638:	b781                	j	578 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 63a:	008b8493          	addi	s1,s7,8
 63e:	4681                	li	a3,0
 640:	4629                	li	a2,10
 642:	000bb583          	ld	a1,0(s7)
 646:	855a                	mv	a0,s6
 648:	e4fff0ef          	jal	496 <printint>
        i += 1;
 64c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 64e:	8ba6                	mv	s7,s1
      state = 0;
 650:	4981                	li	s3,0
 652:	b71d                	j	578 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 654:	008b8493          	addi	s1,s7,8
 658:	4681                	li	a3,0
 65a:	4629                	li	a2,10
 65c:	000bb583          	ld	a1,0(s7)
 660:	855a                	mv	a0,s6
 662:	e35ff0ef          	jal	496 <printint>
        i += 2;
 666:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 668:	8ba6                	mv	s7,s1
      state = 0;
 66a:	4981                	li	s3,0
        i += 2;
 66c:	b731                	j	578 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 66e:	008b8493          	addi	s1,s7,8
 672:	4681                	li	a3,0
 674:	4641                	li	a2,16
 676:	000be583          	lwu	a1,0(s7)
 67a:	855a                	mv	a0,s6
 67c:	e1bff0ef          	jal	496 <printint>
 680:	8ba6                	mv	s7,s1
      state = 0;
 682:	4981                	li	s3,0
 684:	bdd5                	j	578 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 686:	008b8493          	addi	s1,s7,8
 68a:	4681                	li	a3,0
 68c:	4641                	li	a2,16
 68e:	000bb583          	ld	a1,0(s7)
 692:	855a                	mv	a0,s6
 694:	e03ff0ef          	jal	496 <printint>
        i += 1;
 698:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 69a:	8ba6                	mv	s7,s1
      state = 0;
 69c:	4981                	li	s3,0
 69e:	bde9                	j	578 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6a0:	008b8493          	addi	s1,s7,8
 6a4:	4681                	li	a3,0
 6a6:	4641                	li	a2,16
 6a8:	000bb583          	ld	a1,0(s7)
 6ac:	855a                	mv	a0,s6
 6ae:	de9ff0ef          	jal	496 <printint>
        i += 2;
 6b2:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6b4:	8ba6                	mv	s7,s1
      state = 0;
 6b6:	4981                	li	s3,0
        i += 2;
 6b8:	b5c1                	j	578 <vprintf+0x44>
 6ba:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 6bc:	008b8793          	addi	a5,s7,8
 6c0:	8cbe                	mv	s9,a5
 6c2:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6c6:	03000593          	li	a1,48
 6ca:	855a                	mv	a0,s6
 6cc:	dadff0ef          	jal	478 <putc>
  putc(fd, 'x');
 6d0:	07800593          	li	a1,120
 6d4:	855a                	mv	a0,s6
 6d6:	da3ff0ef          	jal	478 <putc>
 6da:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6dc:	00000b97          	auipc	s7,0x0
 6e0:	384b8b93          	addi	s7,s7,900 # a60 <digits>
 6e4:	03c9d793          	srli	a5,s3,0x3c
 6e8:	97de                	add	a5,a5,s7
 6ea:	0007c583          	lbu	a1,0(a5)
 6ee:	855a                	mv	a0,s6
 6f0:	d89ff0ef          	jal	478 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6f4:	0992                	slli	s3,s3,0x4
 6f6:	34fd                	addiw	s1,s1,-1
 6f8:	f4f5                	bnez	s1,6e4 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 6fa:	8be6                	mv	s7,s9
      state = 0;
 6fc:	4981                	li	s3,0
 6fe:	6ca2                	ld	s9,8(sp)
 700:	bda5                	j	578 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 702:	008b8493          	addi	s1,s7,8
 706:	000bc583          	lbu	a1,0(s7)
 70a:	855a                	mv	a0,s6
 70c:	d6dff0ef          	jal	478 <putc>
 710:	8ba6                	mv	s7,s1
      state = 0;
 712:	4981                	li	s3,0
 714:	b595                	j	578 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 716:	008b8993          	addi	s3,s7,8
 71a:	000bb483          	ld	s1,0(s7)
 71e:	cc91                	beqz	s1,73a <vprintf+0x206>
        for(; *s; s++)
 720:	0004c583          	lbu	a1,0(s1)
 724:	c985                	beqz	a1,754 <vprintf+0x220>
          putc(fd, *s);
 726:	855a                	mv	a0,s6
 728:	d51ff0ef          	jal	478 <putc>
        for(; *s; s++)
 72c:	0485                	addi	s1,s1,1
 72e:	0004c583          	lbu	a1,0(s1)
 732:	f9f5                	bnez	a1,726 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 734:	8bce                	mv	s7,s3
      state = 0;
 736:	4981                	li	s3,0
 738:	b581                	j	578 <vprintf+0x44>
          s = "(null)";
 73a:	00000497          	auipc	s1,0x0
 73e:	31e48493          	addi	s1,s1,798 # a58 <malloc+0x182>
        for(; *s; s++)
 742:	02800593          	li	a1,40
 746:	b7c5                	j	726 <vprintf+0x1f2>
        putc(fd, '%');
 748:	85be                	mv	a1,a5
 74a:	855a                	mv	a0,s6
 74c:	d2dff0ef          	jal	478 <putc>
      state = 0;
 750:	4981                	li	s3,0
 752:	b51d                	j	578 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 754:	8bce                	mv	s7,s3
      state = 0;
 756:	4981                	li	s3,0
 758:	b505                	j	578 <vprintf+0x44>
 75a:	6906                	ld	s2,64(sp)
 75c:	79e2                	ld	s3,56(sp)
 75e:	7a42                	ld	s4,48(sp)
 760:	7aa2                	ld	s5,40(sp)
 762:	7b02                	ld	s6,32(sp)
 764:	6be2                	ld	s7,24(sp)
 766:	6c42                	ld	s8,16(sp)
    }
  }
}
 768:	60e6                	ld	ra,88(sp)
 76a:	6446                	ld	s0,80(sp)
 76c:	64a6                	ld	s1,72(sp)
 76e:	6125                	addi	sp,sp,96
 770:	8082                	ret
      if(c0 == 'd'){
 772:	06400713          	li	a4,100
 776:	e4e78fe3          	beq	a5,a4,5d4 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 77a:	f9478693          	addi	a3,a5,-108
 77e:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 782:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 784:	4701                	li	a4,0
      } else if(c0 == 'u'){
 786:	07500513          	li	a0,117
 78a:	e8a78ce3          	beq	a5,a0,622 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 78e:	f8b60513          	addi	a0,a2,-117
 792:	e119                	bnez	a0,798 <vprintf+0x264>
 794:	ea0693e3          	bnez	a3,63a <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 798:	f8b58513          	addi	a0,a1,-117
 79c:	e119                	bnez	a0,7a2 <vprintf+0x26e>
 79e:	ea071be3          	bnez	a4,654 <vprintf+0x120>
      } else if(c0 == 'x'){
 7a2:	07800513          	li	a0,120
 7a6:	eca784e3          	beq	a5,a0,66e <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 7aa:	f8860613          	addi	a2,a2,-120
 7ae:	e219                	bnez	a2,7b4 <vprintf+0x280>
 7b0:	ec069be3          	bnez	a3,686 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 7b4:	f8858593          	addi	a1,a1,-120
 7b8:	e199                	bnez	a1,7be <vprintf+0x28a>
 7ba:	ee0713e3          	bnez	a4,6a0 <vprintf+0x16c>
      } else if(c0 == 'p'){
 7be:	07000713          	li	a4,112
 7c2:	eee78ce3          	beq	a5,a4,6ba <vprintf+0x186>
      } else if(c0 == 'c'){
 7c6:	06300713          	li	a4,99
 7ca:	f2e78ce3          	beq	a5,a4,702 <vprintf+0x1ce>
      } else if(c0 == 's'){
 7ce:	07300713          	li	a4,115
 7d2:	f4e782e3          	beq	a5,a4,716 <vprintf+0x1e2>
      } else if(c0 == '%'){
 7d6:	02500713          	li	a4,37
 7da:	f6e787e3          	beq	a5,a4,748 <vprintf+0x214>
        putc(fd, '%');
 7de:	02500593          	li	a1,37
 7e2:	855a                	mv	a0,s6
 7e4:	c95ff0ef          	jal	478 <putc>
        putc(fd, c0);
 7e8:	85a6                	mv	a1,s1
 7ea:	855a                	mv	a0,s6
 7ec:	c8dff0ef          	jal	478 <putc>
      state = 0;
 7f0:	4981                	li	s3,0
 7f2:	b359                	j	578 <vprintf+0x44>

00000000000007f4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7f4:	715d                	addi	sp,sp,-80
 7f6:	ec06                	sd	ra,24(sp)
 7f8:	e822                	sd	s0,16(sp)
 7fa:	1000                	addi	s0,sp,32
 7fc:	e010                	sd	a2,0(s0)
 7fe:	e414                	sd	a3,8(s0)
 800:	e818                	sd	a4,16(s0)
 802:	ec1c                	sd	a5,24(s0)
 804:	03043023          	sd	a6,32(s0)
 808:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 80c:	8622                	mv	a2,s0
 80e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 812:	d23ff0ef          	jal	534 <vprintf>
}
 816:	60e2                	ld	ra,24(sp)
 818:	6442                	ld	s0,16(sp)
 81a:	6161                	addi	sp,sp,80
 81c:	8082                	ret

000000000000081e <printf>:

void
printf(const char *fmt, ...)
{
 81e:	711d                	addi	sp,sp,-96
 820:	ec06                	sd	ra,24(sp)
 822:	e822                	sd	s0,16(sp)
 824:	1000                	addi	s0,sp,32
 826:	e40c                	sd	a1,8(s0)
 828:	e810                	sd	a2,16(s0)
 82a:	ec14                	sd	a3,24(s0)
 82c:	f018                	sd	a4,32(s0)
 82e:	f41c                	sd	a5,40(s0)
 830:	03043823          	sd	a6,48(s0)
 834:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 838:	00840613          	addi	a2,s0,8
 83c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 840:	85aa                	mv	a1,a0
 842:	4505                	li	a0,1
 844:	cf1ff0ef          	jal	534 <vprintf>
}
 848:	60e2                	ld	ra,24(sp)
 84a:	6442                	ld	s0,16(sp)
 84c:	6125                	addi	sp,sp,96
 84e:	8082                	ret

0000000000000850 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 850:	1141                	addi	sp,sp,-16
 852:	e406                	sd	ra,8(sp)
 854:	e022                	sd	s0,0(sp)
 856:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 858:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 85c:	00000797          	auipc	a5,0x0
 860:	7a47b783          	ld	a5,1956(a5) # 1000 <freep>
 864:	a039                	j	872 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 866:	6398                	ld	a4,0(a5)
 868:	00e7e463          	bltu	a5,a4,870 <free+0x20>
 86c:	00e6ea63          	bltu	a3,a4,880 <free+0x30>
{
 870:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 872:	fed7fae3          	bgeu	a5,a3,866 <free+0x16>
 876:	6398                	ld	a4,0(a5)
 878:	00e6e463          	bltu	a3,a4,880 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 87c:	fee7eae3          	bltu	a5,a4,870 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 880:	ff852583          	lw	a1,-8(a0)
 884:	6390                	ld	a2,0(a5)
 886:	02059813          	slli	a6,a1,0x20
 88a:	01c85713          	srli	a4,a6,0x1c
 88e:	9736                	add	a4,a4,a3
 890:	02e60563          	beq	a2,a4,8ba <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 894:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 898:	4790                	lw	a2,8(a5)
 89a:	02061593          	slli	a1,a2,0x20
 89e:	01c5d713          	srli	a4,a1,0x1c
 8a2:	973e                	add	a4,a4,a5
 8a4:	02e68263          	beq	a3,a4,8c8 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 8a8:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8aa:	00000717          	auipc	a4,0x0
 8ae:	74f73b23          	sd	a5,1878(a4) # 1000 <freep>
}
 8b2:	60a2                	ld	ra,8(sp)
 8b4:	6402                	ld	s0,0(sp)
 8b6:	0141                	addi	sp,sp,16
 8b8:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 8ba:	4618                	lw	a4,8(a2)
 8bc:	9f2d                	addw	a4,a4,a1
 8be:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8c2:	6398                	ld	a4,0(a5)
 8c4:	6310                	ld	a2,0(a4)
 8c6:	b7f9                	j	894 <free+0x44>
    p->s.size += bp->s.size;
 8c8:	ff852703          	lw	a4,-8(a0)
 8cc:	9f31                	addw	a4,a4,a2
 8ce:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8d0:	ff053683          	ld	a3,-16(a0)
 8d4:	bfd1                	j	8a8 <free+0x58>

00000000000008d6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8d6:	7139                	addi	sp,sp,-64
 8d8:	fc06                	sd	ra,56(sp)
 8da:	f822                	sd	s0,48(sp)
 8dc:	f04a                	sd	s2,32(sp)
 8de:	ec4e                	sd	s3,24(sp)
 8e0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8e2:	02051993          	slli	s3,a0,0x20
 8e6:	0209d993          	srli	s3,s3,0x20
 8ea:	09bd                	addi	s3,s3,15
 8ec:	0049d993          	srli	s3,s3,0x4
 8f0:	2985                	addiw	s3,s3,1
 8f2:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 8f4:	00000517          	auipc	a0,0x0
 8f8:	70c53503          	ld	a0,1804(a0) # 1000 <freep>
 8fc:	c905                	beqz	a0,92c <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8fe:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 900:	4798                	lw	a4,8(a5)
 902:	09377663          	bgeu	a4,s3,98e <malloc+0xb8>
 906:	f426                	sd	s1,40(sp)
 908:	e852                	sd	s4,16(sp)
 90a:	e456                	sd	s5,8(sp)
 90c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 90e:	8a4e                	mv	s4,s3
 910:	6705                	lui	a4,0x1
 912:	00e9f363          	bgeu	s3,a4,918 <malloc+0x42>
 916:	6a05                	lui	s4,0x1
 918:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 91c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 920:	00000497          	auipc	s1,0x0
 924:	6e048493          	addi	s1,s1,1760 # 1000 <freep>
  if(p == SBRK_ERROR)
 928:	5afd                	li	s5,-1
 92a:	a83d                	j	968 <malloc+0x92>
 92c:	f426                	sd	s1,40(sp)
 92e:	e852                	sd	s4,16(sp)
 930:	e456                	sd	s5,8(sp)
 932:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 934:	00000797          	auipc	a5,0x0
 938:	6dc78793          	addi	a5,a5,1756 # 1010 <base>
 93c:	00000717          	auipc	a4,0x0
 940:	6cf73223          	sd	a5,1732(a4) # 1000 <freep>
 944:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 946:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 94a:	b7d1                	j	90e <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 94c:	6398                	ld	a4,0(a5)
 94e:	e118                	sd	a4,0(a0)
 950:	a899                	j	9a6 <malloc+0xd0>
  hp->s.size = nu;
 952:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 956:	0541                	addi	a0,a0,16
 958:	ef9ff0ef          	jal	850 <free>
  return freep;
 95c:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 95e:	c125                	beqz	a0,9be <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 960:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 962:	4798                	lw	a4,8(a5)
 964:	03277163          	bgeu	a4,s2,986 <malloc+0xb0>
    if(p == freep)
 968:	6098                	ld	a4,0(s1)
 96a:	853e                	mv	a0,a5
 96c:	fef71ae3          	bne	a4,a5,960 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 970:	8552                	mv	a0,s4
 972:	9f3ff0ef          	jal	364 <sbrk>
  if(p == SBRK_ERROR)
 976:	fd551ee3          	bne	a0,s5,952 <malloc+0x7c>
        return 0;
 97a:	4501                	li	a0,0
 97c:	74a2                	ld	s1,40(sp)
 97e:	6a42                	ld	s4,16(sp)
 980:	6aa2                	ld	s5,8(sp)
 982:	6b02                	ld	s6,0(sp)
 984:	a03d                	j	9b2 <malloc+0xdc>
 986:	74a2                	ld	s1,40(sp)
 988:	6a42                	ld	s4,16(sp)
 98a:	6aa2                	ld	s5,8(sp)
 98c:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 98e:	fae90fe3          	beq	s2,a4,94c <malloc+0x76>
        p->s.size -= nunits;
 992:	4137073b          	subw	a4,a4,s3
 996:	c798                	sw	a4,8(a5)
        p += p->s.size;
 998:	02071693          	slli	a3,a4,0x20
 99c:	01c6d713          	srli	a4,a3,0x1c
 9a0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9a2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9a6:	00000717          	auipc	a4,0x0
 9aa:	64a73d23          	sd	a0,1626(a4) # 1000 <freep>
      return (void*)(p + 1);
 9ae:	01078513          	addi	a0,a5,16
  }
}
 9b2:	70e2                	ld	ra,56(sp)
 9b4:	7442                	ld	s0,48(sp)
 9b6:	7902                	ld	s2,32(sp)
 9b8:	69e2                	ld	s3,24(sp)
 9ba:	6121                	addi	sp,sp,64
 9bc:	8082                	ret
 9be:	74a2                	ld	s1,40(sp)
 9c0:	6a42                	ld	s4,16(sp)
 9c2:	6aa2                	ld	s5,8(sp)
 9c4:	6b02                	ld	s6,0(sp)
 9c6:	b7f5                	j	9b2 <malloc+0xdc>
