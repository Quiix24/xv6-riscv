
user/_chmod:     file format elf64-littleriscv


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
  if(argc < 3){
   8:	4789                	li	a5,2
   a:	04a7d163          	bge	a5,a0,4c <main+0x4c>
   e:	e426                	sd	s1,8(sp)
  10:	84ae                	mv	s1,a1
  }

  // Convert octal mode string to integer
  // chmod 755 /config -> mode=0755 (octal)
  int mode = 0;
  char *s = argv[1];
  12:	6594                	ld	a3,8(a1)
  
  while(*s){
  14:	0006c783          	lbu	a5,0(a3)
  18:	cfb9                	beqz	a5,76 <main+0x76>
  int mode = 0;
  1a:	4581                	li	a1,0
    if(*s >= '0' && *s <= '7'){
  1c:	461d                	li	a2,7
  1e:	fd07871b          	addiw	a4,a5,-48
  22:	0ff77713          	zext.b	a4,a4
  26:	02e66e63          	bltu	a2,a4,62 <main+0x62>
      mode = (mode << 3) | (*s - '0');
  2a:	0035959b          	slliw	a1,a1,0x3
  2e:	fd07879b          	addiw	a5,a5,-48
  32:	8ddd                	or	a1,a1,a5
      s++;
  34:	0685                	addi	a3,a3,1
  while(*s){
  36:	0006c783          	lbu	a5,0(a3)
  3a:	f3f5                	bnez	a5,1e <main+0x1e>
      fprintf(2, "chmod: mode must be octal (0-7)\n");
      exit(1);
    }
  }

  if(chmod(argv[2], mode) < 0){
  3c:	6888                	ld	a0,16(s1)
  3e:	3d0000ef          	jal	40e <chmod>
  42:	02054c63          	bltz	a0,7a <main+0x7a>
    fprintf(2, "chmod: cannot change %s\n", argv[2]);
    exit(1);
  }
  
  exit(0);
  46:	4501                	li	a0,0
  48:	2fe000ef          	jal	346 <exit>
  4c:	e426                	sd	s1,8(sp)
    fprintf(2, "Usage: chmod <mode> <file>\n");
  4e:	00001597          	auipc	a1,0x1
  52:	93258593          	addi	a1,a1,-1742 # 980 <malloc+0xfc>
  56:	853e                	mv	a0,a5
  58:	74a000ef          	jal	7a2 <fprintf>
    exit(1);
  5c:	4505                	li	a0,1
  5e:	2e8000ef          	jal	346 <exit>
      fprintf(2, "chmod: mode must be octal (0-7)\n");
  62:	00001597          	auipc	a1,0x1
  66:	93e58593          	addi	a1,a1,-1730 # 9a0 <malloc+0x11c>
  6a:	4509                	li	a0,2
  6c:	736000ef          	jal	7a2 <fprintf>
      exit(1);
  70:	4505                	li	a0,1
  72:	2d4000ef          	jal	346 <exit>
  int mode = 0;
  76:	4581                	li	a1,0
  78:	b7d1                	j	3c <main+0x3c>
    fprintf(2, "chmod: cannot change %s\n", argv[2]);
  7a:	6890                	ld	a2,16(s1)
  7c:	00001597          	auipc	a1,0x1
  80:	94c58593          	addi	a1,a1,-1716 # 9c8 <malloc+0x144>
  84:	4509                	li	a0,2
  86:	71c000ef          	jal	7a2 <fprintf>
    exit(1);
  8a:	4505                	li	a0,1
  8c:	2ba000ef          	jal	346 <exit>

0000000000000090 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  90:	1141                	addi	sp,sp,-16
  92:	e406                	sd	ra,8(sp)
  94:	e022                	sd	s0,0(sp)
  96:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  98:	f69ff0ef          	jal	0 <main>
  exit(r);
  9c:	2aa000ef          	jal	346 <exit>

00000000000000a0 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  a0:	1141                	addi	sp,sp,-16
  a2:	e406                	sd	ra,8(sp)
  a4:	e022                	sd	s0,0(sp)
  a6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  a8:	87aa                	mv	a5,a0
  aa:	0585                	addi	a1,a1,1
  ac:	0785                	addi	a5,a5,1
  ae:	fff5c703          	lbu	a4,-1(a1)
  b2:	fee78fa3          	sb	a4,-1(a5)
  b6:	fb75                	bnez	a4,aa <strcpy+0xa>
    ;
  return os;
}
  b8:	60a2                	ld	ra,8(sp)
  ba:	6402                	ld	s0,0(sp)
  bc:	0141                	addi	sp,sp,16
  be:	8082                	ret

00000000000000c0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  c0:	1141                	addi	sp,sp,-16
  c2:	e406                	sd	ra,8(sp)
  c4:	e022                	sd	s0,0(sp)
  c6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  c8:	00054783          	lbu	a5,0(a0)
  cc:	cb91                	beqz	a5,e0 <strcmp+0x20>
  ce:	0005c703          	lbu	a4,0(a1)
  d2:	00f71763          	bne	a4,a5,e0 <strcmp+0x20>
    p++, q++;
  d6:	0505                	addi	a0,a0,1
  d8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  da:	00054783          	lbu	a5,0(a0)
  de:	fbe5                	bnez	a5,ce <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  e0:	0005c503          	lbu	a0,0(a1)
}
  e4:	40a7853b          	subw	a0,a5,a0
  e8:	60a2                	ld	ra,8(sp)
  ea:	6402                	ld	s0,0(sp)
  ec:	0141                	addi	sp,sp,16
  ee:	8082                	ret

00000000000000f0 <strlen>:

uint
strlen(const char *s)
{
  f0:	1141                	addi	sp,sp,-16
  f2:	e406                	sd	ra,8(sp)
  f4:	e022                	sd	s0,0(sp)
  f6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  f8:	00054783          	lbu	a5,0(a0)
  fc:	cf91                	beqz	a5,118 <strlen+0x28>
  fe:	00150793          	addi	a5,a0,1
 102:	86be                	mv	a3,a5
 104:	0785                	addi	a5,a5,1
 106:	fff7c703          	lbu	a4,-1(a5)
 10a:	ff65                	bnez	a4,102 <strlen+0x12>
 10c:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 110:	60a2                	ld	ra,8(sp)
 112:	6402                	ld	s0,0(sp)
 114:	0141                	addi	sp,sp,16
 116:	8082                	ret
  for(n = 0; s[n]; n++)
 118:	4501                	li	a0,0
 11a:	bfdd                	j	110 <strlen+0x20>

000000000000011c <memset>:

void*
memset(void *dst, int c, uint n)
{
 11c:	1141                	addi	sp,sp,-16
 11e:	e406                	sd	ra,8(sp)
 120:	e022                	sd	s0,0(sp)
 122:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 124:	ca19                	beqz	a2,13a <memset+0x1e>
 126:	87aa                	mv	a5,a0
 128:	1602                	slli	a2,a2,0x20
 12a:	9201                	srli	a2,a2,0x20
 12c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 130:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 134:	0785                	addi	a5,a5,1
 136:	fee79de3          	bne	a5,a4,130 <memset+0x14>
  }
  return dst;
}
 13a:	60a2                	ld	ra,8(sp)
 13c:	6402                	ld	s0,0(sp)
 13e:	0141                	addi	sp,sp,16
 140:	8082                	ret

0000000000000142 <strchr>:

char*
strchr(const char *s, char c)
{
 142:	1141                	addi	sp,sp,-16
 144:	e406                	sd	ra,8(sp)
 146:	e022                	sd	s0,0(sp)
 148:	0800                	addi	s0,sp,16
  for(; *s; s++)
 14a:	00054783          	lbu	a5,0(a0)
 14e:	cf81                	beqz	a5,166 <strchr+0x24>
    if(*s == c)
 150:	00f58763          	beq	a1,a5,15e <strchr+0x1c>
  for(; *s; s++)
 154:	0505                	addi	a0,a0,1
 156:	00054783          	lbu	a5,0(a0)
 15a:	fbfd                	bnez	a5,150 <strchr+0xe>
      return (char*)s;
  return 0;
 15c:	4501                	li	a0,0
}
 15e:	60a2                	ld	ra,8(sp)
 160:	6402                	ld	s0,0(sp)
 162:	0141                	addi	sp,sp,16
 164:	8082                	ret
  return 0;
 166:	4501                	li	a0,0
 168:	bfdd                	j	15e <strchr+0x1c>

000000000000016a <gets>:

char*
gets(char *buf, int max)
{
 16a:	711d                	addi	sp,sp,-96
 16c:	ec86                	sd	ra,88(sp)
 16e:	e8a2                	sd	s0,80(sp)
 170:	e4a6                	sd	s1,72(sp)
 172:	e0ca                	sd	s2,64(sp)
 174:	fc4e                	sd	s3,56(sp)
 176:	f852                	sd	s4,48(sp)
 178:	f456                	sd	s5,40(sp)
 17a:	f05a                	sd	s6,32(sp)
 17c:	ec5e                	sd	s7,24(sp)
 17e:	e862                	sd	s8,16(sp)
 180:	1080                	addi	s0,sp,96
 182:	8baa                	mv	s7,a0
 184:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 186:	892a                	mv	s2,a0
 188:	4481                	li	s1,0
    cc = read(0, &c, 1);
 18a:	faf40b13          	addi	s6,s0,-81
 18e:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 190:	8c26                	mv	s8,s1
 192:	0014899b          	addiw	s3,s1,1
 196:	84ce                	mv	s1,s3
 198:	0349d463          	bge	s3,s4,1c0 <gets+0x56>
    cc = read(0, &c, 1);
 19c:	8656                	mv	a2,s5
 19e:	85da                	mv	a1,s6
 1a0:	4501                	li	a0,0
 1a2:	1bc000ef          	jal	35e <read>
    if(cc < 1)
 1a6:	00a05d63          	blez	a0,1c0 <gets+0x56>
      break;
    buf[i++] = c;
 1aa:	faf44783          	lbu	a5,-81(s0)
 1ae:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1b2:	0905                	addi	s2,s2,1
 1b4:	ff678713          	addi	a4,a5,-10
 1b8:	c319                	beqz	a4,1be <gets+0x54>
 1ba:	17cd                	addi	a5,a5,-13
 1bc:	fbf1                	bnez	a5,190 <gets+0x26>
    buf[i++] = c;
 1be:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 1c0:	9c5e                	add	s8,s8,s7
 1c2:	000c0023          	sb	zero,0(s8)
  return buf;
}
 1c6:	855e                	mv	a0,s7
 1c8:	60e6                	ld	ra,88(sp)
 1ca:	6446                	ld	s0,80(sp)
 1cc:	64a6                	ld	s1,72(sp)
 1ce:	6906                	ld	s2,64(sp)
 1d0:	79e2                	ld	s3,56(sp)
 1d2:	7a42                	ld	s4,48(sp)
 1d4:	7aa2                	ld	s5,40(sp)
 1d6:	7b02                	ld	s6,32(sp)
 1d8:	6be2                	ld	s7,24(sp)
 1da:	6c42                	ld	s8,16(sp)
 1dc:	6125                	addi	sp,sp,96
 1de:	8082                	ret

00000000000001e0 <stat>:

int
stat(const char *n, struct stat *st)
{
 1e0:	1101                	addi	sp,sp,-32
 1e2:	ec06                	sd	ra,24(sp)
 1e4:	e822                	sd	s0,16(sp)
 1e6:	e04a                	sd	s2,0(sp)
 1e8:	1000                	addi	s0,sp,32
 1ea:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1ec:	4581                	li	a1,0
 1ee:	198000ef          	jal	386 <open>
  if(fd < 0)
 1f2:	02054263          	bltz	a0,216 <stat+0x36>
 1f6:	e426                	sd	s1,8(sp)
 1f8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1fa:	85ca                	mv	a1,s2
 1fc:	1a2000ef          	jal	39e <fstat>
 200:	892a                	mv	s2,a0
  close(fd);
 202:	8526                	mv	a0,s1
 204:	16a000ef          	jal	36e <close>
  return r;
 208:	64a2                	ld	s1,8(sp)
}
 20a:	854a                	mv	a0,s2
 20c:	60e2                	ld	ra,24(sp)
 20e:	6442                	ld	s0,16(sp)
 210:	6902                	ld	s2,0(sp)
 212:	6105                	addi	sp,sp,32
 214:	8082                	ret
    return -1;
 216:	57fd                	li	a5,-1
 218:	893e                	mv	s2,a5
 21a:	bfc5                	j	20a <stat+0x2a>

000000000000021c <atoi>:

int
atoi(const char *s)
{
 21c:	1141                	addi	sp,sp,-16
 21e:	e406                	sd	ra,8(sp)
 220:	e022                	sd	s0,0(sp)
 222:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 224:	00054683          	lbu	a3,0(a0)
 228:	fd06879b          	addiw	a5,a3,-48
 22c:	0ff7f793          	zext.b	a5,a5
 230:	4625                	li	a2,9
 232:	02f66963          	bltu	a2,a5,264 <atoi+0x48>
 236:	872a                	mv	a4,a0
  n = 0;
 238:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 23a:	0705                	addi	a4,a4,1
 23c:	0025179b          	slliw	a5,a0,0x2
 240:	9fa9                	addw	a5,a5,a0
 242:	0017979b          	slliw	a5,a5,0x1
 246:	9fb5                	addw	a5,a5,a3
 248:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 24c:	00074683          	lbu	a3,0(a4)
 250:	fd06879b          	addiw	a5,a3,-48
 254:	0ff7f793          	zext.b	a5,a5
 258:	fef671e3          	bgeu	a2,a5,23a <atoi+0x1e>
  return n;
}
 25c:	60a2                	ld	ra,8(sp)
 25e:	6402                	ld	s0,0(sp)
 260:	0141                	addi	sp,sp,16
 262:	8082                	ret
  n = 0;
 264:	4501                	li	a0,0
 266:	bfdd                	j	25c <atoi+0x40>

0000000000000268 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 268:	1141                	addi	sp,sp,-16
 26a:	e406                	sd	ra,8(sp)
 26c:	e022                	sd	s0,0(sp)
 26e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 270:	02b57563          	bgeu	a0,a1,29a <memmove+0x32>
    while(n-- > 0)
 274:	00c05f63          	blez	a2,292 <memmove+0x2a>
 278:	1602                	slli	a2,a2,0x20
 27a:	9201                	srli	a2,a2,0x20
 27c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 280:	872a                	mv	a4,a0
      *dst++ = *src++;
 282:	0585                	addi	a1,a1,1
 284:	0705                	addi	a4,a4,1
 286:	fff5c683          	lbu	a3,-1(a1)
 28a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 28e:	fee79ae3          	bne	a5,a4,282 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 292:	60a2                	ld	ra,8(sp)
 294:	6402                	ld	s0,0(sp)
 296:	0141                	addi	sp,sp,16
 298:	8082                	ret
    while(n-- > 0)
 29a:	fec05ce3          	blez	a2,292 <memmove+0x2a>
    dst += n;
 29e:	00c50733          	add	a4,a0,a2
    src += n;
 2a2:	95b2                	add	a1,a1,a2
 2a4:	fff6079b          	addiw	a5,a2,-1
 2a8:	1782                	slli	a5,a5,0x20
 2aa:	9381                	srli	a5,a5,0x20
 2ac:	fff7c793          	not	a5,a5
 2b0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2b2:	15fd                	addi	a1,a1,-1
 2b4:	177d                	addi	a4,a4,-1
 2b6:	0005c683          	lbu	a3,0(a1)
 2ba:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2be:	fef71ae3          	bne	a4,a5,2b2 <memmove+0x4a>
 2c2:	bfc1                	j	292 <memmove+0x2a>

00000000000002c4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2c4:	1141                	addi	sp,sp,-16
 2c6:	e406                	sd	ra,8(sp)
 2c8:	e022                	sd	s0,0(sp)
 2ca:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2cc:	c61d                	beqz	a2,2fa <memcmp+0x36>
 2ce:	1602                	slli	a2,a2,0x20
 2d0:	9201                	srli	a2,a2,0x20
 2d2:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 2d6:	00054783          	lbu	a5,0(a0)
 2da:	0005c703          	lbu	a4,0(a1)
 2de:	00e79863          	bne	a5,a4,2ee <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 2e2:	0505                	addi	a0,a0,1
    p2++;
 2e4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2e6:	fed518e3          	bne	a0,a3,2d6 <memcmp+0x12>
  }
  return 0;
 2ea:	4501                	li	a0,0
 2ec:	a019                	j	2f2 <memcmp+0x2e>
      return *p1 - *p2;
 2ee:	40e7853b          	subw	a0,a5,a4
}
 2f2:	60a2                	ld	ra,8(sp)
 2f4:	6402                	ld	s0,0(sp)
 2f6:	0141                	addi	sp,sp,16
 2f8:	8082                	ret
  return 0;
 2fa:	4501                	li	a0,0
 2fc:	bfdd                	j	2f2 <memcmp+0x2e>

00000000000002fe <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2fe:	1141                	addi	sp,sp,-16
 300:	e406                	sd	ra,8(sp)
 302:	e022                	sd	s0,0(sp)
 304:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 306:	f63ff0ef          	jal	268 <memmove>
}
 30a:	60a2                	ld	ra,8(sp)
 30c:	6402                	ld	s0,0(sp)
 30e:	0141                	addi	sp,sp,16
 310:	8082                	ret

0000000000000312 <sbrk>:

char *
sbrk(int n) {
 312:	1141                	addi	sp,sp,-16
 314:	e406                	sd	ra,8(sp)
 316:	e022                	sd	s0,0(sp)
 318:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 31a:	4585                	li	a1,1
 31c:	0b2000ef          	jal	3ce <sys_sbrk>
}
 320:	60a2                	ld	ra,8(sp)
 322:	6402                	ld	s0,0(sp)
 324:	0141                	addi	sp,sp,16
 326:	8082                	ret

0000000000000328 <sbrklazy>:

char *
sbrklazy(int n) {
 328:	1141                	addi	sp,sp,-16
 32a:	e406                	sd	ra,8(sp)
 32c:	e022                	sd	s0,0(sp)
 32e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 330:	4589                	li	a1,2
 332:	09c000ef          	jal	3ce <sys_sbrk>
}
 336:	60a2                	ld	ra,8(sp)
 338:	6402                	ld	s0,0(sp)
 33a:	0141                	addi	sp,sp,16
 33c:	8082                	ret

000000000000033e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 33e:	4885                	li	a7,1
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <exit>:
.global exit
exit:
 li a7, SYS_exit
 346:	4889                	li	a7,2
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <wait>:
.global wait
wait:
 li a7, SYS_wait
 34e:	488d                	li	a7,3
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 356:	4891                	li	a7,4
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <read>:
.global read
read:
 li a7, SYS_read
 35e:	4895                	li	a7,5
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <write>:
.global write
write:
 li a7, SYS_write
 366:	48c1                	li	a7,16
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <close>:
.global close
close:
 li a7, SYS_close
 36e:	48d5                	li	a7,21
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <kill>:
.global kill
kill:
 li a7, SYS_kill
 376:	4899                	li	a7,6
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <exec>:
.global exec
exec:
 li a7, SYS_exec
 37e:	489d                	li	a7,7
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <open>:
.global open
open:
 li a7, SYS_open
 386:	48bd                	li	a7,15
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 38e:	48c5                	li	a7,17
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 396:	48c9                	li	a7,18
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 39e:	48a1                	li	a7,8
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <link>:
.global link
link:
 li a7, SYS_link
 3a6:	48cd                	li	a7,19
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3ae:	48d1                	li	a7,20
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3b6:	48a5                	li	a7,9
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <dup>:
.global dup
dup:
 li a7, SYS_dup
 3be:	48a9                	li	a7,10
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3c6:	48ad                	li	a7,11
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3ce:	48b1                	li	a7,12
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3d6:	48b5                	li	a7,13
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3de:	48b9                	li	a7,14
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <login>:
.global login
login:
 li a7, SYS_login
 3e6:	48d9                	li	a7,22
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <useradd>:
.global useradd
useradd:
 li a7, SYS_useradd
 3ee:	48dd                	li	a7,23
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <userdel>:
.global userdel
userdel:
 li a7, SYS_userdel
 3f6:	48e1                	li	a7,24
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <passwd>:
.global passwd
passwd:
 li a7, SYS_passwd
 3fe:	48e5                	li	a7,25
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <whoami>:
.global whoami
whoami:
 li a7, SYS_whoami
 406:	48e9                	li	a7,26
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <chmod>:
.global chmod
chmod:
 li a7, SYS_chmod
 40e:	48ed                	li	a7,27
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <chown>:
.global chown
chown:
 li a7, SYS_chown
 416:	48f1                	li	a7,28
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <audit_read>:
.global audit_read
audit_read:
 li a7, SYS_audit_read
 41e:	48f5                	li	a7,29
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 426:	1101                	addi	sp,sp,-32
 428:	ec06                	sd	ra,24(sp)
 42a:	e822                	sd	s0,16(sp)
 42c:	1000                	addi	s0,sp,32
 42e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 432:	4605                	li	a2,1
 434:	fef40593          	addi	a1,s0,-17
 438:	f2fff0ef          	jal	366 <write>
}
 43c:	60e2                	ld	ra,24(sp)
 43e:	6442                	ld	s0,16(sp)
 440:	6105                	addi	sp,sp,32
 442:	8082                	ret

0000000000000444 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 444:	715d                	addi	sp,sp,-80
 446:	e486                	sd	ra,72(sp)
 448:	e0a2                	sd	s0,64(sp)
 44a:	f84a                	sd	s2,48(sp)
 44c:	f44e                	sd	s3,40(sp)
 44e:	0880                	addi	s0,sp,80
 450:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 452:	c6d1                	beqz	a3,4de <printint+0x9a>
 454:	0805d563          	bgez	a1,4de <printint+0x9a>
    neg = 1;
    x = -xx;
 458:	40b005b3          	neg	a1,a1
    neg = 1;
 45c:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 45e:	fb840993          	addi	s3,s0,-72
  neg = 0;
 462:	86ce                	mv	a3,s3
  i = 0;
 464:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 466:	00000817          	auipc	a6,0x0
 46a:	58a80813          	addi	a6,a6,1418 # 9f0 <digits>
 46e:	88ba                	mv	a7,a4
 470:	0017051b          	addiw	a0,a4,1
 474:	872a                	mv	a4,a0
 476:	02c5f7b3          	remu	a5,a1,a2
 47a:	97c2                	add	a5,a5,a6
 47c:	0007c783          	lbu	a5,0(a5)
 480:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 484:	87ae                	mv	a5,a1
 486:	02c5d5b3          	divu	a1,a1,a2
 48a:	0685                	addi	a3,a3,1
 48c:	fec7f1e3          	bgeu	a5,a2,46e <printint+0x2a>
  if(neg)
 490:	00030c63          	beqz	t1,4a8 <printint+0x64>
    buf[i++] = '-';
 494:	fd050793          	addi	a5,a0,-48
 498:	00878533          	add	a0,a5,s0
 49c:	02d00793          	li	a5,45
 4a0:	fef50423          	sb	a5,-24(a0)
 4a4:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 4a8:	02e05563          	blez	a4,4d2 <printint+0x8e>
 4ac:	fc26                	sd	s1,56(sp)
 4ae:	377d                	addiw	a4,a4,-1
 4b0:	00e984b3          	add	s1,s3,a4
 4b4:	19fd                	addi	s3,s3,-1
 4b6:	99ba                	add	s3,s3,a4
 4b8:	1702                	slli	a4,a4,0x20
 4ba:	9301                	srli	a4,a4,0x20
 4bc:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4c0:	0004c583          	lbu	a1,0(s1)
 4c4:	854a                	mv	a0,s2
 4c6:	f61ff0ef          	jal	426 <putc>
  while(--i >= 0)
 4ca:	14fd                	addi	s1,s1,-1
 4cc:	ff349ae3          	bne	s1,s3,4c0 <printint+0x7c>
 4d0:	74e2                	ld	s1,56(sp)
}
 4d2:	60a6                	ld	ra,72(sp)
 4d4:	6406                	ld	s0,64(sp)
 4d6:	7942                	ld	s2,48(sp)
 4d8:	79a2                	ld	s3,40(sp)
 4da:	6161                	addi	sp,sp,80
 4dc:	8082                	ret
  neg = 0;
 4de:	4301                	li	t1,0
 4e0:	bfbd                	j	45e <printint+0x1a>

00000000000004e2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4e2:	711d                	addi	sp,sp,-96
 4e4:	ec86                	sd	ra,88(sp)
 4e6:	e8a2                	sd	s0,80(sp)
 4e8:	e4a6                	sd	s1,72(sp)
 4ea:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4ec:	0005c483          	lbu	s1,0(a1)
 4f0:	22048363          	beqz	s1,716 <vprintf+0x234>
 4f4:	e0ca                	sd	s2,64(sp)
 4f6:	fc4e                	sd	s3,56(sp)
 4f8:	f852                	sd	s4,48(sp)
 4fa:	f456                	sd	s5,40(sp)
 4fc:	f05a                	sd	s6,32(sp)
 4fe:	ec5e                	sd	s7,24(sp)
 500:	e862                	sd	s8,16(sp)
 502:	8b2a                	mv	s6,a0
 504:	8a2e                	mv	s4,a1
 506:	8bb2                	mv	s7,a2
  state = 0;
 508:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 50a:	4901                	li	s2,0
 50c:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 50e:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 512:	06400c13          	li	s8,100
 516:	a00d                	j	538 <vprintf+0x56>
        putc(fd, c0);
 518:	85a6                	mv	a1,s1
 51a:	855a                	mv	a0,s6
 51c:	f0bff0ef          	jal	426 <putc>
 520:	a019                	j	526 <vprintf+0x44>
    } else if(state == '%'){
 522:	03598363          	beq	s3,s5,548 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 526:	0019079b          	addiw	a5,s2,1
 52a:	893e                	mv	s2,a5
 52c:	873e                	mv	a4,a5
 52e:	97d2                	add	a5,a5,s4
 530:	0007c483          	lbu	s1,0(a5)
 534:	1c048a63          	beqz	s1,708 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 538:	0004879b          	sext.w	a5,s1
    if(state == 0){
 53c:	fe0993e3          	bnez	s3,522 <vprintf+0x40>
      if(c0 == '%'){
 540:	fd579ce3          	bne	a5,s5,518 <vprintf+0x36>
        state = '%';
 544:	89be                	mv	s3,a5
 546:	b7c5                	j	526 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 548:	00ea06b3          	add	a3,s4,a4
 54c:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 550:	1c060863          	beqz	a2,720 <vprintf+0x23e>
      if(c0 == 'd'){
 554:	03878763          	beq	a5,s8,582 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 558:	f9478693          	addi	a3,a5,-108
 55c:	0016b693          	seqz	a3,a3
 560:	f9c60593          	addi	a1,a2,-100
 564:	e99d                	bnez	a1,59a <vprintf+0xb8>
 566:	ca95                	beqz	a3,59a <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 568:	008b8493          	addi	s1,s7,8
 56c:	4685                	li	a3,1
 56e:	4629                	li	a2,10
 570:	000bb583          	ld	a1,0(s7)
 574:	855a                	mv	a0,s6
 576:	ecfff0ef          	jal	444 <printint>
        i += 1;
 57a:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 57c:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 57e:	4981                	li	s3,0
 580:	b75d                	j	526 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 582:	008b8493          	addi	s1,s7,8
 586:	4685                	li	a3,1
 588:	4629                	li	a2,10
 58a:	000ba583          	lw	a1,0(s7)
 58e:	855a                	mv	a0,s6
 590:	eb5ff0ef          	jal	444 <printint>
 594:	8ba6                	mv	s7,s1
      state = 0;
 596:	4981                	li	s3,0
 598:	b779                	j	526 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 59a:	9752                	add	a4,a4,s4
 59c:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5a0:	f9460713          	addi	a4,a2,-108
 5a4:	00173713          	seqz	a4,a4
 5a8:	8f75                	and	a4,a4,a3
 5aa:	f9c58513          	addi	a0,a1,-100
 5ae:	18051363          	bnez	a0,734 <vprintf+0x252>
 5b2:	18070163          	beqz	a4,734 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5b6:	008b8493          	addi	s1,s7,8
 5ba:	4685                	li	a3,1
 5bc:	4629                	li	a2,10
 5be:	000bb583          	ld	a1,0(s7)
 5c2:	855a                	mv	a0,s6
 5c4:	e81ff0ef          	jal	444 <printint>
        i += 2;
 5c8:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ca:	8ba6                	mv	s7,s1
      state = 0;
 5cc:	4981                	li	s3,0
        i += 2;
 5ce:	bfa1                	j	526 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5d0:	008b8493          	addi	s1,s7,8
 5d4:	4681                	li	a3,0
 5d6:	4629                	li	a2,10
 5d8:	000be583          	lwu	a1,0(s7)
 5dc:	855a                	mv	a0,s6
 5de:	e67ff0ef          	jal	444 <printint>
 5e2:	8ba6                	mv	s7,s1
      state = 0;
 5e4:	4981                	li	s3,0
 5e6:	b781                	j	526 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5e8:	008b8493          	addi	s1,s7,8
 5ec:	4681                	li	a3,0
 5ee:	4629                	li	a2,10
 5f0:	000bb583          	ld	a1,0(s7)
 5f4:	855a                	mv	a0,s6
 5f6:	e4fff0ef          	jal	444 <printint>
        i += 1;
 5fa:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5fc:	8ba6                	mv	s7,s1
      state = 0;
 5fe:	4981                	li	s3,0
 600:	b71d                	j	526 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 602:	008b8493          	addi	s1,s7,8
 606:	4681                	li	a3,0
 608:	4629                	li	a2,10
 60a:	000bb583          	ld	a1,0(s7)
 60e:	855a                	mv	a0,s6
 610:	e35ff0ef          	jal	444 <printint>
        i += 2;
 614:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 616:	8ba6                	mv	s7,s1
      state = 0;
 618:	4981                	li	s3,0
        i += 2;
 61a:	b731                	j	526 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 61c:	008b8493          	addi	s1,s7,8
 620:	4681                	li	a3,0
 622:	4641                	li	a2,16
 624:	000be583          	lwu	a1,0(s7)
 628:	855a                	mv	a0,s6
 62a:	e1bff0ef          	jal	444 <printint>
 62e:	8ba6                	mv	s7,s1
      state = 0;
 630:	4981                	li	s3,0
 632:	bdd5                	j	526 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 634:	008b8493          	addi	s1,s7,8
 638:	4681                	li	a3,0
 63a:	4641                	li	a2,16
 63c:	000bb583          	ld	a1,0(s7)
 640:	855a                	mv	a0,s6
 642:	e03ff0ef          	jal	444 <printint>
        i += 1;
 646:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 648:	8ba6                	mv	s7,s1
      state = 0;
 64a:	4981                	li	s3,0
 64c:	bde9                	j	526 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 64e:	008b8493          	addi	s1,s7,8
 652:	4681                	li	a3,0
 654:	4641                	li	a2,16
 656:	000bb583          	ld	a1,0(s7)
 65a:	855a                	mv	a0,s6
 65c:	de9ff0ef          	jal	444 <printint>
        i += 2;
 660:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 662:	8ba6                	mv	s7,s1
      state = 0;
 664:	4981                	li	s3,0
        i += 2;
 666:	b5c1                	j	526 <vprintf+0x44>
 668:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 66a:	008b8793          	addi	a5,s7,8
 66e:	8cbe                	mv	s9,a5
 670:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 674:	03000593          	li	a1,48
 678:	855a                	mv	a0,s6
 67a:	dadff0ef          	jal	426 <putc>
  putc(fd, 'x');
 67e:	07800593          	li	a1,120
 682:	855a                	mv	a0,s6
 684:	da3ff0ef          	jal	426 <putc>
 688:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 68a:	00000b97          	auipc	s7,0x0
 68e:	366b8b93          	addi	s7,s7,870 # 9f0 <digits>
 692:	03c9d793          	srli	a5,s3,0x3c
 696:	97de                	add	a5,a5,s7
 698:	0007c583          	lbu	a1,0(a5)
 69c:	855a                	mv	a0,s6
 69e:	d89ff0ef          	jal	426 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6a2:	0992                	slli	s3,s3,0x4
 6a4:	34fd                	addiw	s1,s1,-1
 6a6:	f4f5                	bnez	s1,692 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 6a8:	8be6                	mv	s7,s9
      state = 0;
 6aa:	4981                	li	s3,0
 6ac:	6ca2                	ld	s9,8(sp)
 6ae:	bda5                	j	526 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 6b0:	008b8493          	addi	s1,s7,8
 6b4:	000bc583          	lbu	a1,0(s7)
 6b8:	855a                	mv	a0,s6
 6ba:	d6dff0ef          	jal	426 <putc>
 6be:	8ba6                	mv	s7,s1
      state = 0;
 6c0:	4981                	li	s3,0
 6c2:	b595                	j	526 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 6c4:	008b8993          	addi	s3,s7,8
 6c8:	000bb483          	ld	s1,0(s7)
 6cc:	cc91                	beqz	s1,6e8 <vprintf+0x206>
        for(; *s; s++)
 6ce:	0004c583          	lbu	a1,0(s1)
 6d2:	c985                	beqz	a1,702 <vprintf+0x220>
          putc(fd, *s);
 6d4:	855a                	mv	a0,s6
 6d6:	d51ff0ef          	jal	426 <putc>
        for(; *s; s++)
 6da:	0485                	addi	s1,s1,1
 6dc:	0004c583          	lbu	a1,0(s1)
 6e0:	f9f5                	bnez	a1,6d4 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 6e2:	8bce                	mv	s7,s3
      state = 0;
 6e4:	4981                	li	s3,0
 6e6:	b581                	j	526 <vprintf+0x44>
          s = "(null)";
 6e8:	00000497          	auipc	s1,0x0
 6ec:	30048493          	addi	s1,s1,768 # 9e8 <malloc+0x164>
        for(; *s; s++)
 6f0:	02800593          	li	a1,40
 6f4:	b7c5                	j	6d4 <vprintf+0x1f2>
        putc(fd, '%');
 6f6:	85be                	mv	a1,a5
 6f8:	855a                	mv	a0,s6
 6fa:	d2dff0ef          	jal	426 <putc>
      state = 0;
 6fe:	4981                	li	s3,0
 700:	b51d                	j	526 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 702:	8bce                	mv	s7,s3
      state = 0;
 704:	4981                	li	s3,0
 706:	b505                	j	526 <vprintf+0x44>
 708:	6906                	ld	s2,64(sp)
 70a:	79e2                	ld	s3,56(sp)
 70c:	7a42                	ld	s4,48(sp)
 70e:	7aa2                	ld	s5,40(sp)
 710:	7b02                	ld	s6,32(sp)
 712:	6be2                	ld	s7,24(sp)
 714:	6c42                	ld	s8,16(sp)
    }
  }
}
 716:	60e6                	ld	ra,88(sp)
 718:	6446                	ld	s0,80(sp)
 71a:	64a6                	ld	s1,72(sp)
 71c:	6125                	addi	sp,sp,96
 71e:	8082                	ret
      if(c0 == 'd'){
 720:	06400713          	li	a4,100
 724:	e4e78fe3          	beq	a5,a4,582 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 728:	f9478693          	addi	a3,a5,-108
 72c:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 730:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 732:	4701                	li	a4,0
      } else if(c0 == 'u'){
 734:	07500513          	li	a0,117
 738:	e8a78ce3          	beq	a5,a0,5d0 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 73c:	f8b60513          	addi	a0,a2,-117
 740:	e119                	bnez	a0,746 <vprintf+0x264>
 742:	ea0693e3          	bnez	a3,5e8 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 746:	f8b58513          	addi	a0,a1,-117
 74a:	e119                	bnez	a0,750 <vprintf+0x26e>
 74c:	ea071be3          	bnez	a4,602 <vprintf+0x120>
      } else if(c0 == 'x'){
 750:	07800513          	li	a0,120
 754:	eca784e3          	beq	a5,a0,61c <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 758:	f8860613          	addi	a2,a2,-120
 75c:	e219                	bnez	a2,762 <vprintf+0x280>
 75e:	ec069be3          	bnez	a3,634 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 762:	f8858593          	addi	a1,a1,-120
 766:	e199                	bnez	a1,76c <vprintf+0x28a>
 768:	ee0713e3          	bnez	a4,64e <vprintf+0x16c>
      } else if(c0 == 'p'){
 76c:	07000713          	li	a4,112
 770:	eee78ce3          	beq	a5,a4,668 <vprintf+0x186>
      } else if(c0 == 'c'){
 774:	06300713          	li	a4,99
 778:	f2e78ce3          	beq	a5,a4,6b0 <vprintf+0x1ce>
      } else if(c0 == 's'){
 77c:	07300713          	li	a4,115
 780:	f4e782e3          	beq	a5,a4,6c4 <vprintf+0x1e2>
      } else if(c0 == '%'){
 784:	02500713          	li	a4,37
 788:	f6e787e3          	beq	a5,a4,6f6 <vprintf+0x214>
        putc(fd, '%');
 78c:	02500593          	li	a1,37
 790:	855a                	mv	a0,s6
 792:	c95ff0ef          	jal	426 <putc>
        putc(fd, c0);
 796:	85a6                	mv	a1,s1
 798:	855a                	mv	a0,s6
 79a:	c8dff0ef          	jal	426 <putc>
      state = 0;
 79e:	4981                	li	s3,0
 7a0:	b359                	j	526 <vprintf+0x44>

00000000000007a2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7a2:	715d                	addi	sp,sp,-80
 7a4:	ec06                	sd	ra,24(sp)
 7a6:	e822                	sd	s0,16(sp)
 7a8:	1000                	addi	s0,sp,32
 7aa:	e010                	sd	a2,0(s0)
 7ac:	e414                	sd	a3,8(s0)
 7ae:	e818                	sd	a4,16(s0)
 7b0:	ec1c                	sd	a5,24(s0)
 7b2:	03043023          	sd	a6,32(s0)
 7b6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7ba:	8622                	mv	a2,s0
 7bc:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7c0:	d23ff0ef          	jal	4e2 <vprintf>
}
 7c4:	60e2                	ld	ra,24(sp)
 7c6:	6442                	ld	s0,16(sp)
 7c8:	6161                	addi	sp,sp,80
 7ca:	8082                	ret

00000000000007cc <printf>:

void
printf(const char *fmt, ...)
{
 7cc:	711d                	addi	sp,sp,-96
 7ce:	ec06                	sd	ra,24(sp)
 7d0:	e822                	sd	s0,16(sp)
 7d2:	1000                	addi	s0,sp,32
 7d4:	e40c                	sd	a1,8(s0)
 7d6:	e810                	sd	a2,16(s0)
 7d8:	ec14                	sd	a3,24(s0)
 7da:	f018                	sd	a4,32(s0)
 7dc:	f41c                	sd	a5,40(s0)
 7de:	03043823          	sd	a6,48(s0)
 7e2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7e6:	00840613          	addi	a2,s0,8
 7ea:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7ee:	85aa                	mv	a1,a0
 7f0:	4505                	li	a0,1
 7f2:	cf1ff0ef          	jal	4e2 <vprintf>
}
 7f6:	60e2                	ld	ra,24(sp)
 7f8:	6442                	ld	s0,16(sp)
 7fa:	6125                	addi	sp,sp,96
 7fc:	8082                	ret

00000000000007fe <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7fe:	1141                	addi	sp,sp,-16
 800:	e406                	sd	ra,8(sp)
 802:	e022                	sd	s0,0(sp)
 804:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 806:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 80a:	00000797          	auipc	a5,0x0
 80e:	7f67b783          	ld	a5,2038(a5) # 1000 <freep>
 812:	a039                	j	820 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 814:	6398                	ld	a4,0(a5)
 816:	00e7e463          	bltu	a5,a4,81e <free+0x20>
 81a:	00e6ea63          	bltu	a3,a4,82e <free+0x30>
{
 81e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 820:	fed7fae3          	bgeu	a5,a3,814 <free+0x16>
 824:	6398                	ld	a4,0(a5)
 826:	00e6e463          	bltu	a3,a4,82e <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 82a:	fee7eae3          	bltu	a5,a4,81e <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 82e:	ff852583          	lw	a1,-8(a0)
 832:	6390                	ld	a2,0(a5)
 834:	02059813          	slli	a6,a1,0x20
 838:	01c85713          	srli	a4,a6,0x1c
 83c:	9736                	add	a4,a4,a3
 83e:	02e60563          	beq	a2,a4,868 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 842:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 846:	4790                	lw	a2,8(a5)
 848:	02061593          	slli	a1,a2,0x20
 84c:	01c5d713          	srli	a4,a1,0x1c
 850:	973e                	add	a4,a4,a5
 852:	02e68263          	beq	a3,a4,876 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 856:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 858:	00000717          	auipc	a4,0x0
 85c:	7af73423          	sd	a5,1960(a4) # 1000 <freep>
}
 860:	60a2                	ld	ra,8(sp)
 862:	6402                	ld	s0,0(sp)
 864:	0141                	addi	sp,sp,16
 866:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 868:	4618                	lw	a4,8(a2)
 86a:	9f2d                	addw	a4,a4,a1
 86c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 870:	6398                	ld	a4,0(a5)
 872:	6310                	ld	a2,0(a4)
 874:	b7f9                	j	842 <free+0x44>
    p->s.size += bp->s.size;
 876:	ff852703          	lw	a4,-8(a0)
 87a:	9f31                	addw	a4,a4,a2
 87c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 87e:	ff053683          	ld	a3,-16(a0)
 882:	bfd1                	j	856 <free+0x58>

0000000000000884 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 884:	7139                	addi	sp,sp,-64
 886:	fc06                	sd	ra,56(sp)
 888:	f822                	sd	s0,48(sp)
 88a:	f04a                	sd	s2,32(sp)
 88c:	ec4e                	sd	s3,24(sp)
 88e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 890:	02051993          	slli	s3,a0,0x20
 894:	0209d993          	srli	s3,s3,0x20
 898:	09bd                	addi	s3,s3,15
 89a:	0049d993          	srli	s3,s3,0x4
 89e:	2985                	addiw	s3,s3,1
 8a0:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 8a2:	00000517          	auipc	a0,0x0
 8a6:	75e53503          	ld	a0,1886(a0) # 1000 <freep>
 8aa:	c905                	beqz	a0,8da <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ac:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8ae:	4798                	lw	a4,8(a5)
 8b0:	09377663          	bgeu	a4,s3,93c <malloc+0xb8>
 8b4:	f426                	sd	s1,40(sp)
 8b6:	e852                	sd	s4,16(sp)
 8b8:	e456                	sd	s5,8(sp)
 8ba:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8bc:	8a4e                	mv	s4,s3
 8be:	6705                	lui	a4,0x1
 8c0:	00e9f363          	bgeu	s3,a4,8c6 <malloc+0x42>
 8c4:	6a05                	lui	s4,0x1
 8c6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8ca:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8ce:	00000497          	auipc	s1,0x0
 8d2:	73248493          	addi	s1,s1,1842 # 1000 <freep>
  if(p == SBRK_ERROR)
 8d6:	5afd                	li	s5,-1
 8d8:	a83d                	j	916 <malloc+0x92>
 8da:	f426                	sd	s1,40(sp)
 8dc:	e852                	sd	s4,16(sp)
 8de:	e456                	sd	s5,8(sp)
 8e0:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8e2:	00000797          	auipc	a5,0x0
 8e6:	72e78793          	addi	a5,a5,1838 # 1010 <base>
 8ea:	00000717          	auipc	a4,0x0
 8ee:	70f73b23          	sd	a5,1814(a4) # 1000 <freep>
 8f2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8f4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8f8:	b7d1                	j	8bc <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 8fa:	6398                	ld	a4,0(a5)
 8fc:	e118                	sd	a4,0(a0)
 8fe:	a899                	j	954 <malloc+0xd0>
  hp->s.size = nu;
 900:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 904:	0541                	addi	a0,a0,16
 906:	ef9ff0ef          	jal	7fe <free>
  return freep;
 90a:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 90c:	c125                	beqz	a0,96c <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 90e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 910:	4798                	lw	a4,8(a5)
 912:	03277163          	bgeu	a4,s2,934 <malloc+0xb0>
    if(p == freep)
 916:	6098                	ld	a4,0(s1)
 918:	853e                	mv	a0,a5
 91a:	fef71ae3          	bne	a4,a5,90e <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 91e:	8552                	mv	a0,s4
 920:	9f3ff0ef          	jal	312 <sbrk>
  if(p == SBRK_ERROR)
 924:	fd551ee3          	bne	a0,s5,900 <malloc+0x7c>
        return 0;
 928:	4501                	li	a0,0
 92a:	74a2                	ld	s1,40(sp)
 92c:	6a42                	ld	s4,16(sp)
 92e:	6aa2                	ld	s5,8(sp)
 930:	6b02                	ld	s6,0(sp)
 932:	a03d                	j	960 <malloc+0xdc>
 934:	74a2                	ld	s1,40(sp)
 936:	6a42                	ld	s4,16(sp)
 938:	6aa2                	ld	s5,8(sp)
 93a:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 93c:	fae90fe3          	beq	s2,a4,8fa <malloc+0x76>
        p->s.size -= nunits;
 940:	4137073b          	subw	a4,a4,s3
 944:	c798                	sw	a4,8(a5)
        p += p->s.size;
 946:	02071693          	slli	a3,a4,0x20
 94a:	01c6d713          	srli	a4,a3,0x1c
 94e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 950:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 954:	00000717          	auipc	a4,0x0
 958:	6aa73623          	sd	a0,1708(a4) # 1000 <freep>
      return (void*)(p + 1);
 95c:	01078513          	addi	a0,a5,16
  }
}
 960:	70e2                	ld	ra,56(sp)
 962:	7442                	ld	s0,48(sp)
 964:	7902                	ld	s2,32(sp)
 966:	69e2                	ld	s3,24(sp)
 968:	6121                	addi	sp,sp,64
 96a:	8082                	ret
 96c:	74a2                	ld	s1,40(sp)
 96e:	6a42                	ld	s4,16(sp)
 970:	6aa2                	ld	s5,8(sp)
 972:	6b02                	ld	s6,0(sp)
 974:	b7f5                	j	960 <malloc+0xdc>
