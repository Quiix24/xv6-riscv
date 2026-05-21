
user/_init:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

char *sh_argv[] = { "sh", 0 };

int
main(void)
{
   0:	7171                	addi	sp,sp,-176
   2:	f506                	sd	ra,168(sp)
   4:	f122                	sd	s0,160(sp)
   6:	ed26                	sd	s1,152(sp)
   8:	e94a                	sd	s2,144(sp)
   a:	e54e                	sd	s3,136(sp)
   c:	e152                	sd	s4,128(sp)
   e:	fcd6                	sd	s5,120(sp)
  10:	f8da                	sd	s6,112(sp)
  12:	f4de                	sd	s7,104(sp)
  14:	f0e2                	sd	s8,96(sp)
  16:	ece6                	sd	s9,88(sp)
  18:	e8ea                	sd	s10,80(sp)
  1a:	e4ee                	sd	s11,72(sp)
  1c:	1900                	addi	s0,sp,176
    int pid, wpid;

    // Standard init setup — open console
    if (open("console", O_RDWR) < 0) {
  1e:	4589                	li	a1,2
  20:	00001517          	auipc	a0,0x1
  24:	ae050513          	addi	a0,a0,-1312 # b00 <malloc+0x114>
  28:	4c6000ef          	jal	4ee <open>
  2c:	06054e63          	bltz	a0,a8 <main+0xa8>
        mknod("console", CONSOLE, 0);
        open("console", O_RDWR);
    }
    dup(0);  // stdout
  30:	4501                	li	a0,0
  32:	4f4000ef          	jal	526 <dup>
    dup(0);  // stderr
  36:	4501                	li	a0,0
  38:	4ee000ef          	jal	526 <dup>
    printf("\n");
  3c:	00001d97          	auipc	s11,0x1
  40:	accd8d93          	addi	s11,s11,-1332 # b08 <malloc+0x11c>
    printf("╔══════════════════════════════════════╗\n");
  44:	00001d17          	auipc	s10,0x1
  48:	accd0d13          	addi	s10,s10,-1332 # b10 <malloc+0x124>
    printf("║  xv6 Medical Device Security System  ║\n");
  4c:	00001c97          	auipc	s9,0x1
  50:	b44c8c93          	addi	s9,s9,-1212 # b90 <malloc+0x1a4>
            if (username[i] == '\n') { username[i] = '\0'; break; }
  54:	44a9                	li	s1,10
    printf("\n");
  56:	856e                	mv	a0,s11
  58:	0dd000ef          	jal	934 <printf>
    printf("╔══════════════════════════════════════╗\n");
  5c:	856a                	mv	a0,s10
  5e:	0d7000ef          	jal	934 <printf>
    printf("║  xv6 Medical Device Security System  ║\n");
  62:	8566                	mv	a0,s9
  64:	0d1000ef          	jal	934 <printf>
    printf("║  Authorized Access Only              ║\n");
  68:	00001517          	auipc	a0,0x1
  6c:	b5850513          	addi	a0,a0,-1192 # bc0 <malloc+0x1d4>
  70:	0c5000ef          	jal	934 <printf>
    printf("╚══════════════════════════════════════╝\n\n");
  74:	00001517          	auipc	a0,0x1
  78:	b7c50513          	addi	a0,a0,-1156 # bf0 <malloc+0x204>
  7c:	0b9000ef          	jal	934 <printf>
  80:	4909                	li	s2,2
        printf("login: ");
  82:	00001b97          	auipc	s7,0x1
  86:	beeb8b93          	addi	s7,s7,-1042 # c70 <malloc+0x284>
        gets(username, 32);
  8a:	f5040a93          	addi	s5,s0,-176
  8e:	02000a13          	li	s4,32
        printf("password: ");
  92:	00001b17          	auipc	s6,0x1
  96:	be6b0b13          	addi	s6,s6,-1050 # c78 <malloc+0x28c>
        gets(password, 32);
  9a:	f7040993          	addi	s3,s0,-144
        printf("Authentication failed. %d attempt(s) remaining.\n\n",
  9e:	00001c17          	auipc	s8,0x1
  a2:	c32c0c13          	addi	s8,s8,-974 # cd0 <malloc+0x2e4>
  a6:	a041                	j	126 <main+0x126>
        mknod("console", CONSOLE, 0);
  a8:	4601                	li	a2,0
  aa:	4585                	li	a1,1
  ac:	00001517          	auipc	a0,0x1
  b0:	a5450513          	addi	a0,a0,-1452 # b00 <malloc+0x114>
  b4:	442000ef          	jal	4f6 <mknod>
        open("console", O_RDWR);
  b8:	4589                	li	a1,2
  ba:	00001517          	auipc	a0,0x1
  be:	a4650513          	addi	a0,a0,-1466 # b00 <malloc+0x114>
  c2:	42c000ef          	jal	4ee <open>
  c6:	b7ad                	j	30 <main+0x30>
            if (username[i] == '\n') { username[i] = '\0'; break; }
  c8:	f9068793          	addi	a5,a3,-112
  cc:	008786b3          	add	a3,a5,s0
  d0:	fc068023          	sb	zero,-64(a3)
        printf("password: ");
  d4:	855a                	mv	a0,s6
  d6:	05f000ef          	jal	934 <printf>
        gets(password, 32);
  da:	85d2                	mv	a1,s4
  dc:	854e                	mv	a0,s3
  de:	1f4000ef          	jal	2d2 <gets>
        for (int i = 0; password[i]; i++) {
  e2:	f7044783          	lbu	a5,-144(s0)
  e6:	c395                	beqz	a5,10a <main+0x10a>
  e8:	f7140713          	addi	a4,s0,-143
  ec:	4681                	li	a3,0
            if (password[i] == '\n') { password[i] = '\0'; break; }
  ee:	00978863          	beq	a5,s1,fe <main+0xfe>
        for (int i = 0; password[i]; i++) {
  f2:	2685                	addiw	a3,a3,1
  f4:	0705                	addi	a4,a4,1
  f6:	fff74783          	lbu	a5,-1(a4)
  fa:	fbf5                	bnez	a5,ee <main+0xee>
  fc:	a039                	j	10a <main+0x10a>
            if (password[i] == '\n') { password[i] = '\0'; break; }
  fe:	f9068793          	addi	a5,a3,-112
 102:	008786b3          	add	a3,a5,s0
 106:	fe068023          	sb	zero,-32(a3)
        uid = login(username, password);
 10a:	85ce                	mv	a1,s3
 10c:	8556                	mv	a0,s5
 10e:	440000ef          	jal	54e <login>
        if (uid >= 0) {
 112:	02055f63          	bgez	a0,150 <main+0x150>
        printf("Authentication failed. %d attempt(s) remaining.\n\n",
 116:	85ca                	mv	a1,s2
 118:	8562                	mv	a0,s8
 11a:	01b000ef          	jal	934 <printf>
    while (attempts < max_attempts) {
 11e:	397d                	addiw	s2,s2,-1
 120:	57fd                	li	a5,-1
 122:	08f90863          	beq	s2,a5,1b2 <main+0x1b2>
        printf("login: ");
 126:	855e                	mv	a0,s7
 128:	00d000ef          	jal	934 <printf>
        gets(username, 32);
 12c:	85d2                	mv	a1,s4
 12e:	8556                	mv	a0,s5
 130:	1a2000ef          	jal	2d2 <gets>
        for (int i = 0; username[i]; i++) {
 134:	f5044783          	lbu	a5,-176(s0)
 138:	dfd1                	beqz	a5,d4 <main+0xd4>
 13a:	f5140713          	addi	a4,s0,-175
 13e:	4681                	li	a3,0
            if (username[i] == '\n') { username[i] = '\0'; break; }
 140:	f89784e3          	beq	a5,s1,c8 <main+0xc8>
        for (int i = 0; username[i]; i++) {
 144:	2685                	addiw	a3,a3,1
 146:	0705                	addi	a4,a4,1
 148:	fff74783          	lbu	a5,-1(a4)
 14c:	fbf5                	bnez	a5,140 <main+0x140>
 14e:	b759                	j	d4 <main+0xd4>
            printf("\nWelcome, %s! Role: %s\n",
 150:	00001617          	auipc	a2,0x1
 154:	99060613          	addi	a2,a2,-1648 # ae0 <malloc+0xf4>
 158:	c901                	beqz	a0,168 <main+0x168>
                   uid == 1 ? "PATIENT" : "DOCTOR");
 15a:	4785                	li	a5,1
            printf("\nWelcome, %s! Role: %s\n",
 15c:	00001617          	auipc	a2,0x1
 160:	99c60613          	addi	a2,a2,-1636 # af8 <malloc+0x10c>
                   uid == 1 ? "PATIENT" : "DOCTOR");
 164:	04f50263          	beq	a0,a5,1a8 <main+0x1a8>
            printf("\nWelcome, %s! Role: %s\n",
 168:	f5040593          	addi	a1,s0,-176
 16c:	00001517          	auipc	a0,0x1
 170:	b1c50513          	addi	a0,a0,-1252 # c88 <malloc+0x29c>
 174:	7c0000ef          	jal	934 <printf>
            printf("Session authenticated. Launching shell...\n\n");
 178:	00001517          	auipc	a0,0x1
 17c:	b2850513          	addi	a0,a0,-1240 # ca0 <malloc+0x2b4>
 180:	7b4000ef          	jal	934 <printf>
    // === AUTHENTICATION GATE ===
    // Loop ensures the shell is only spawned post-authentication
    for (;;) {
        do_login();  // Blocks until valid credentials

        pid = fork();
 184:	322000ef          	jal	4a6 <fork>
 188:	892a                	mv	s2,a0
        if (pid < 0) {
 18a:	02054b63          	bltz	a0,1c0 <main+0x1c0>
            printf("init: fork failed\n");
            exit(1);
        }

        if (pid == 0) {
 18e:	c131                	beqz	a0,1d2 <main+0x1d2>
            exit(1);
        }

        // Parent: wait for shell to exit, then re-prompt login
        for (;;) {
            wpid = wait((int*)0);
 190:	4501                	li	a0,0
 192:	324000ef          	jal	4b6 <wait>
            if (wpid == pid) {
 196:	fea91de3          	bne	s2,a0,190 <main+0x190>
                // Shell exited — go back to login prompt
                printf("\nSession ended. Please log in again.\n");
 19a:	00001517          	auipc	a0,0x1
 19e:	bd650513          	addi	a0,a0,-1066 # d70 <malloc+0x384>
 1a2:	792000ef          	jal	934 <printf>
        do_login();  // Blocks until valid credentials
 1a6:	bd45                	j	56 <main+0x56>
            printf("\nWelcome, %s! Role: %s\n",
 1a8:	00001617          	auipc	a2,0x1
 1ac:	94860613          	addi	a2,a2,-1720 # af0 <malloc+0x104>
 1b0:	bf65                	j	168 <main+0x168>
    printf("Maximum attempts exceeded. System locked.\n");
 1b2:	00001517          	auipc	a0,0x1
 1b6:	b5650513          	addi	a0,a0,-1194 # d08 <malloc+0x31c>
 1ba:	77a000ef          	jal	934 <printf>
    for (;;) {
 1be:	a001                	j	1be <main+0x1be>
            printf("init: fork failed\n");
 1c0:	00001517          	auipc	a0,0x1
 1c4:	b7850513          	addi	a0,a0,-1160 # d38 <malloc+0x34c>
 1c8:	76c000ef          	jal	934 <printf>
            exit(1);
 1cc:	4505                	li	a0,1
 1ce:	2e0000ef          	jal	4ae <exit>
            exec("sh", sh_argv);
 1d2:	00001597          	auipc	a1,0x1
 1d6:	e2e58593          	addi	a1,a1,-466 # 1000 <sh_argv>
 1da:	00001517          	auipc	a0,0x1
 1de:	b7650513          	addi	a0,a0,-1162 # d50 <malloc+0x364>
 1e2:	304000ef          	jal	4e6 <exec>
            printf("init: exec sh failed\n");
 1e6:	00001517          	auipc	a0,0x1
 1ea:	b7250513          	addi	a0,a0,-1166 # d58 <malloc+0x36c>
 1ee:	746000ef          	jal	934 <printf>
            exit(1);
 1f2:	4505                	li	a0,1
 1f4:	2ba000ef          	jal	4ae <exit>

00000000000001f8 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 1f8:	1141                	addi	sp,sp,-16
 1fa:	e406                	sd	ra,8(sp)
 1fc:	e022                	sd	s0,0(sp)
 1fe:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 200:	e01ff0ef          	jal	0 <main>
  exit(r);
 204:	2aa000ef          	jal	4ae <exit>

0000000000000208 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 208:	1141                	addi	sp,sp,-16
 20a:	e406                	sd	ra,8(sp)
 20c:	e022                	sd	s0,0(sp)
 20e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 210:	87aa                	mv	a5,a0
 212:	0585                	addi	a1,a1,1
 214:	0785                	addi	a5,a5,1
 216:	fff5c703          	lbu	a4,-1(a1)
 21a:	fee78fa3          	sb	a4,-1(a5)
 21e:	fb75                	bnez	a4,212 <strcpy+0xa>
    ;
  return os;
}
 220:	60a2                	ld	ra,8(sp)
 222:	6402                	ld	s0,0(sp)
 224:	0141                	addi	sp,sp,16
 226:	8082                	ret

0000000000000228 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 228:	1141                	addi	sp,sp,-16
 22a:	e406                	sd	ra,8(sp)
 22c:	e022                	sd	s0,0(sp)
 22e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 230:	00054783          	lbu	a5,0(a0)
 234:	cb91                	beqz	a5,248 <strcmp+0x20>
 236:	0005c703          	lbu	a4,0(a1)
 23a:	00f71763          	bne	a4,a5,248 <strcmp+0x20>
    p++, q++;
 23e:	0505                	addi	a0,a0,1
 240:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 242:	00054783          	lbu	a5,0(a0)
 246:	fbe5                	bnez	a5,236 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 248:	0005c503          	lbu	a0,0(a1)
}
 24c:	40a7853b          	subw	a0,a5,a0
 250:	60a2                	ld	ra,8(sp)
 252:	6402                	ld	s0,0(sp)
 254:	0141                	addi	sp,sp,16
 256:	8082                	ret

0000000000000258 <strlen>:

uint
strlen(const char *s)
{
 258:	1141                	addi	sp,sp,-16
 25a:	e406                	sd	ra,8(sp)
 25c:	e022                	sd	s0,0(sp)
 25e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 260:	00054783          	lbu	a5,0(a0)
 264:	cf91                	beqz	a5,280 <strlen+0x28>
 266:	00150793          	addi	a5,a0,1
 26a:	86be                	mv	a3,a5
 26c:	0785                	addi	a5,a5,1
 26e:	fff7c703          	lbu	a4,-1(a5)
 272:	ff65                	bnez	a4,26a <strlen+0x12>
 274:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 278:	60a2                	ld	ra,8(sp)
 27a:	6402                	ld	s0,0(sp)
 27c:	0141                	addi	sp,sp,16
 27e:	8082                	ret
  for(n = 0; s[n]; n++)
 280:	4501                	li	a0,0
 282:	bfdd                	j	278 <strlen+0x20>

0000000000000284 <memset>:

void*
memset(void *dst, int c, uint n)
{
 284:	1141                	addi	sp,sp,-16
 286:	e406                	sd	ra,8(sp)
 288:	e022                	sd	s0,0(sp)
 28a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 28c:	ca19                	beqz	a2,2a2 <memset+0x1e>
 28e:	87aa                	mv	a5,a0
 290:	1602                	slli	a2,a2,0x20
 292:	9201                	srli	a2,a2,0x20
 294:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 298:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 29c:	0785                	addi	a5,a5,1
 29e:	fee79de3          	bne	a5,a4,298 <memset+0x14>
  }
  return dst;
}
 2a2:	60a2                	ld	ra,8(sp)
 2a4:	6402                	ld	s0,0(sp)
 2a6:	0141                	addi	sp,sp,16
 2a8:	8082                	ret

00000000000002aa <strchr>:

char*
strchr(const char *s, char c)
{
 2aa:	1141                	addi	sp,sp,-16
 2ac:	e406                	sd	ra,8(sp)
 2ae:	e022                	sd	s0,0(sp)
 2b0:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2b2:	00054783          	lbu	a5,0(a0)
 2b6:	cf81                	beqz	a5,2ce <strchr+0x24>
    if(*s == c)
 2b8:	00f58763          	beq	a1,a5,2c6 <strchr+0x1c>
  for(; *s; s++)
 2bc:	0505                	addi	a0,a0,1
 2be:	00054783          	lbu	a5,0(a0)
 2c2:	fbfd                	bnez	a5,2b8 <strchr+0xe>
      return (char*)s;
  return 0;
 2c4:	4501                	li	a0,0
}
 2c6:	60a2                	ld	ra,8(sp)
 2c8:	6402                	ld	s0,0(sp)
 2ca:	0141                	addi	sp,sp,16
 2cc:	8082                	ret
  return 0;
 2ce:	4501                	li	a0,0
 2d0:	bfdd                	j	2c6 <strchr+0x1c>

00000000000002d2 <gets>:

char*
gets(char *buf, int max)
{
 2d2:	711d                	addi	sp,sp,-96
 2d4:	ec86                	sd	ra,88(sp)
 2d6:	e8a2                	sd	s0,80(sp)
 2d8:	e4a6                	sd	s1,72(sp)
 2da:	e0ca                	sd	s2,64(sp)
 2dc:	fc4e                	sd	s3,56(sp)
 2de:	f852                	sd	s4,48(sp)
 2e0:	f456                	sd	s5,40(sp)
 2e2:	f05a                	sd	s6,32(sp)
 2e4:	ec5e                	sd	s7,24(sp)
 2e6:	e862                	sd	s8,16(sp)
 2e8:	1080                	addi	s0,sp,96
 2ea:	8baa                	mv	s7,a0
 2ec:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2ee:	892a                	mv	s2,a0
 2f0:	4481                	li	s1,0
    cc = read(0, &c, 1);
 2f2:	faf40b13          	addi	s6,s0,-81
 2f6:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 2f8:	8c26                	mv	s8,s1
 2fa:	0014899b          	addiw	s3,s1,1
 2fe:	84ce                	mv	s1,s3
 300:	0349d463          	bge	s3,s4,328 <gets+0x56>
    cc = read(0, &c, 1);
 304:	8656                	mv	a2,s5
 306:	85da                	mv	a1,s6
 308:	4501                	li	a0,0
 30a:	1bc000ef          	jal	4c6 <read>
    if(cc < 1)
 30e:	00a05d63          	blez	a0,328 <gets+0x56>
      break;
    buf[i++] = c;
 312:	faf44783          	lbu	a5,-81(s0)
 316:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 31a:	0905                	addi	s2,s2,1
 31c:	ff678713          	addi	a4,a5,-10
 320:	c319                	beqz	a4,326 <gets+0x54>
 322:	17cd                	addi	a5,a5,-13
 324:	fbf1                	bnez	a5,2f8 <gets+0x26>
    buf[i++] = c;
 326:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 328:	9c5e                	add	s8,s8,s7
 32a:	000c0023          	sb	zero,0(s8)
  return buf;
}
 32e:	855e                	mv	a0,s7
 330:	60e6                	ld	ra,88(sp)
 332:	6446                	ld	s0,80(sp)
 334:	64a6                	ld	s1,72(sp)
 336:	6906                	ld	s2,64(sp)
 338:	79e2                	ld	s3,56(sp)
 33a:	7a42                	ld	s4,48(sp)
 33c:	7aa2                	ld	s5,40(sp)
 33e:	7b02                	ld	s6,32(sp)
 340:	6be2                	ld	s7,24(sp)
 342:	6c42                	ld	s8,16(sp)
 344:	6125                	addi	sp,sp,96
 346:	8082                	ret

0000000000000348 <stat>:

int
stat(const char *n, struct stat *st)
{
 348:	1101                	addi	sp,sp,-32
 34a:	ec06                	sd	ra,24(sp)
 34c:	e822                	sd	s0,16(sp)
 34e:	e04a                	sd	s2,0(sp)
 350:	1000                	addi	s0,sp,32
 352:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 354:	4581                	li	a1,0
 356:	198000ef          	jal	4ee <open>
  if(fd < 0)
 35a:	02054263          	bltz	a0,37e <stat+0x36>
 35e:	e426                	sd	s1,8(sp)
 360:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 362:	85ca                	mv	a1,s2
 364:	1a2000ef          	jal	506 <fstat>
 368:	892a                	mv	s2,a0
  close(fd);
 36a:	8526                	mv	a0,s1
 36c:	16a000ef          	jal	4d6 <close>
  return r;
 370:	64a2                	ld	s1,8(sp)
}
 372:	854a                	mv	a0,s2
 374:	60e2                	ld	ra,24(sp)
 376:	6442                	ld	s0,16(sp)
 378:	6902                	ld	s2,0(sp)
 37a:	6105                	addi	sp,sp,32
 37c:	8082                	ret
    return -1;
 37e:	57fd                	li	a5,-1
 380:	893e                	mv	s2,a5
 382:	bfc5                	j	372 <stat+0x2a>

0000000000000384 <atoi>:

int
atoi(const char *s)
{
 384:	1141                	addi	sp,sp,-16
 386:	e406                	sd	ra,8(sp)
 388:	e022                	sd	s0,0(sp)
 38a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 38c:	00054683          	lbu	a3,0(a0)
 390:	fd06879b          	addiw	a5,a3,-48
 394:	0ff7f793          	zext.b	a5,a5
 398:	4625                	li	a2,9
 39a:	02f66963          	bltu	a2,a5,3cc <atoi+0x48>
 39e:	872a                	mv	a4,a0
  n = 0;
 3a0:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3a2:	0705                	addi	a4,a4,1
 3a4:	0025179b          	slliw	a5,a0,0x2
 3a8:	9fa9                	addw	a5,a5,a0
 3aa:	0017979b          	slliw	a5,a5,0x1
 3ae:	9fb5                	addw	a5,a5,a3
 3b0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3b4:	00074683          	lbu	a3,0(a4)
 3b8:	fd06879b          	addiw	a5,a3,-48
 3bc:	0ff7f793          	zext.b	a5,a5
 3c0:	fef671e3          	bgeu	a2,a5,3a2 <atoi+0x1e>
  return n;
}
 3c4:	60a2                	ld	ra,8(sp)
 3c6:	6402                	ld	s0,0(sp)
 3c8:	0141                	addi	sp,sp,16
 3ca:	8082                	ret
  n = 0;
 3cc:	4501                	li	a0,0
 3ce:	bfdd                	j	3c4 <atoi+0x40>

00000000000003d0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3d0:	1141                	addi	sp,sp,-16
 3d2:	e406                	sd	ra,8(sp)
 3d4:	e022                	sd	s0,0(sp)
 3d6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3d8:	02b57563          	bgeu	a0,a1,402 <memmove+0x32>
    while(n-- > 0)
 3dc:	00c05f63          	blez	a2,3fa <memmove+0x2a>
 3e0:	1602                	slli	a2,a2,0x20
 3e2:	9201                	srli	a2,a2,0x20
 3e4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3e8:	872a                	mv	a4,a0
      *dst++ = *src++;
 3ea:	0585                	addi	a1,a1,1
 3ec:	0705                	addi	a4,a4,1
 3ee:	fff5c683          	lbu	a3,-1(a1)
 3f2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3f6:	fee79ae3          	bne	a5,a4,3ea <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3fa:	60a2                	ld	ra,8(sp)
 3fc:	6402                	ld	s0,0(sp)
 3fe:	0141                	addi	sp,sp,16
 400:	8082                	ret
    while(n-- > 0)
 402:	fec05ce3          	blez	a2,3fa <memmove+0x2a>
    dst += n;
 406:	00c50733          	add	a4,a0,a2
    src += n;
 40a:	95b2                	add	a1,a1,a2
 40c:	fff6079b          	addiw	a5,a2,-1
 410:	1782                	slli	a5,a5,0x20
 412:	9381                	srli	a5,a5,0x20
 414:	fff7c793          	not	a5,a5
 418:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 41a:	15fd                	addi	a1,a1,-1
 41c:	177d                	addi	a4,a4,-1
 41e:	0005c683          	lbu	a3,0(a1)
 422:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 426:	fef71ae3          	bne	a4,a5,41a <memmove+0x4a>
 42a:	bfc1                	j	3fa <memmove+0x2a>

000000000000042c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 42c:	1141                	addi	sp,sp,-16
 42e:	e406                	sd	ra,8(sp)
 430:	e022                	sd	s0,0(sp)
 432:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 434:	c61d                	beqz	a2,462 <memcmp+0x36>
 436:	1602                	slli	a2,a2,0x20
 438:	9201                	srli	a2,a2,0x20
 43a:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 43e:	00054783          	lbu	a5,0(a0)
 442:	0005c703          	lbu	a4,0(a1)
 446:	00e79863          	bne	a5,a4,456 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 44a:	0505                	addi	a0,a0,1
    p2++;
 44c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 44e:	fed518e3          	bne	a0,a3,43e <memcmp+0x12>
  }
  return 0;
 452:	4501                	li	a0,0
 454:	a019                	j	45a <memcmp+0x2e>
      return *p1 - *p2;
 456:	40e7853b          	subw	a0,a5,a4
}
 45a:	60a2                	ld	ra,8(sp)
 45c:	6402                	ld	s0,0(sp)
 45e:	0141                	addi	sp,sp,16
 460:	8082                	ret
  return 0;
 462:	4501                	li	a0,0
 464:	bfdd                	j	45a <memcmp+0x2e>

0000000000000466 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 466:	1141                	addi	sp,sp,-16
 468:	e406                	sd	ra,8(sp)
 46a:	e022                	sd	s0,0(sp)
 46c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 46e:	f63ff0ef          	jal	3d0 <memmove>
}
 472:	60a2                	ld	ra,8(sp)
 474:	6402                	ld	s0,0(sp)
 476:	0141                	addi	sp,sp,16
 478:	8082                	ret

000000000000047a <sbrk>:

char *
sbrk(int n) {
 47a:	1141                	addi	sp,sp,-16
 47c:	e406                	sd	ra,8(sp)
 47e:	e022                	sd	s0,0(sp)
 480:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 482:	4585                	li	a1,1
 484:	0b2000ef          	jal	536 <sys_sbrk>
}
 488:	60a2                	ld	ra,8(sp)
 48a:	6402                	ld	s0,0(sp)
 48c:	0141                	addi	sp,sp,16
 48e:	8082                	ret

0000000000000490 <sbrklazy>:

char *
sbrklazy(int n) {
 490:	1141                	addi	sp,sp,-16
 492:	e406                	sd	ra,8(sp)
 494:	e022                	sd	s0,0(sp)
 496:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 498:	4589                	li	a1,2
 49a:	09c000ef          	jal	536 <sys_sbrk>
}
 49e:	60a2                	ld	ra,8(sp)
 4a0:	6402                	ld	s0,0(sp)
 4a2:	0141                	addi	sp,sp,16
 4a4:	8082                	ret

00000000000004a6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4a6:	4885                	li	a7,1
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <exit>:
.global exit
exit:
 li a7, SYS_exit
 4ae:	4889                	li	a7,2
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 4b6:	488d                	li	a7,3
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4be:	4891                	li	a7,4
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <read>:
.global read
read:
 li a7, SYS_read
 4c6:	4895                	li	a7,5
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <write>:
.global write
write:
 li a7, SYS_write
 4ce:	48c1                	li	a7,16
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <close>:
.global close
close:
 li a7, SYS_close
 4d6:	48d5                	li	a7,21
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <kill>:
.global kill
kill:
 li a7, SYS_kill
 4de:	4899                	li	a7,6
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4e6:	489d                	li	a7,7
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <open>:
.global open
open:
 li a7, SYS_open
 4ee:	48bd                	li	a7,15
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4f6:	48c5                	li	a7,17
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4fe:	48c9                	li	a7,18
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 506:	48a1                	li	a7,8
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <link>:
.global link
link:
 li a7, SYS_link
 50e:	48cd                	li	a7,19
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 516:	48d1                	li	a7,20
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 51e:	48a5                	li	a7,9
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <dup>:
.global dup
dup:
 li a7, SYS_dup
 526:	48a9                	li	a7,10
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 52e:	48ad                	li	a7,11
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 536:	48b1                	li	a7,12
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <pause>:
.global pause
pause:
 li a7, SYS_pause
 53e:	48b5                	li	a7,13
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 546:	48b9                	li	a7,14
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <login>:
.global login
login:
 li a7, SYS_login
 54e:	48d9                	li	a7,22
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <useradd>:
.global useradd
useradd:
 li a7, SYS_useradd
 556:	48dd                	li	a7,23
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <userdel>:
.global userdel
userdel:
 li a7, SYS_userdel
 55e:	48e1                	li	a7,24
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <passwd>:
.global passwd
passwd:
 li a7, SYS_passwd
 566:	48e5                	li	a7,25
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <whoami>:
.global whoami
whoami:
 li a7, SYS_whoami
 56e:	48e9                	li	a7,26
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <chmod>:
.global chmod
chmod:
 li a7, SYS_chmod
 576:	48ed                	li	a7,27
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <chown>:
.global chown
chown:
 li a7, SYS_chown
 57e:	48f1                	li	a7,28
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <audit_read>:
.global audit_read
audit_read:
 li a7, SYS_audit_read
 586:	48f5                	li	a7,29
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 58e:	1101                	addi	sp,sp,-32
 590:	ec06                	sd	ra,24(sp)
 592:	e822                	sd	s0,16(sp)
 594:	1000                	addi	s0,sp,32
 596:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 59a:	4605                	li	a2,1
 59c:	fef40593          	addi	a1,s0,-17
 5a0:	f2fff0ef          	jal	4ce <write>
}
 5a4:	60e2                	ld	ra,24(sp)
 5a6:	6442                	ld	s0,16(sp)
 5a8:	6105                	addi	sp,sp,32
 5aa:	8082                	ret

00000000000005ac <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 5ac:	715d                	addi	sp,sp,-80
 5ae:	e486                	sd	ra,72(sp)
 5b0:	e0a2                	sd	s0,64(sp)
 5b2:	f84a                	sd	s2,48(sp)
 5b4:	f44e                	sd	s3,40(sp)
 5b6:	0880                	addi	s0,sp,80
 5b8:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 5ba:	c6d1                	beqz	a3,646 <printint+0x9a>
 5bc:	0805d563          	bgez	a1,646 <printint+0x9a>
    neg = 1;
    x = -xx;
 5c0:	40b005b3          	neg	a1,a1
    neg = 1;
 5c4:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 5c6:	fb840993          	addi	s3,s0,-72
  neg = 0;
 5ca:	86ce                	mv	a3,s3
  i = 0;
 5cc:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5ce:	00000817          	auipc	a6,0x0
 5d2:	7d280813          	addi	a6,a6,2002 # da0 <digits>
 5d6:	88ba                	mv	a7,a4
 5d8:	0017051b          	addiw	a0,a4,1
 5dc:	872a                	mv	a4,a0
 5de:	02c5f7b3          	remu	a5,a1,a2
 5e2:	97c2                	add	a5,a5,a6
 5e4:	0007c783          	lbu	a5,0(a5)
 5e8:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5ec:	87ae                	mv	a5,a1
 5ee:	02c5d5b3          	divu	a1,a1,a2
 5f2:	0685                	addi	a3,a3,1
 5f4:	fec7f1e3          	bgeu	a5,a2,5d6 <printint+0x2a>
  if(neg)
 5f8:	00030c63          	beqz	t1,610 <printint+0x64>
    buf[i++] = '-';
 5fc:	fd050793          	addi	a5,a0,-48
 600:	00878533          	add	a0,a5,s0
 604:	02d00793          	li	a5,45
 608:	fef50423          	sb	a5,-24(a0)
 60c:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 610:	02e05563          	blez	a4,63a <printint+0x8e>
 614:	fc26                	sd	s1,56(sp)
 616:	377d                	addiw	a4,a4,-1
 618:	00e984b3          	add	s1,s3,a4
 61c:	19fd                	addi	s3,s3,-1
 61e:	99ba                	add	s3,s3,a4
 620:	1702                	slli	a4,a4,0x20
 622:	9301                	srli	a4,a4,0x20
 624:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 628:	0004c583          	lbu	a1,0(s1)
 62c:	854a                	mv	a0,s2
 62e:	f61ff0ef          	jal	58e <putc>
  while(--i >= 0)
 632:	14fd                	addi	s1,s1,-1
 634:	ff349ae3          	bne	s1,s3,628 <printint+0x7c>
 638:	74e2                	ld	s1,56(sp)
}
 63a:	60a6                	ld	ra,72(sp)
 63c:	6406                	ld	s0,64(sp)
 63e:	7942                	ld	s2,48(sp)
 640:	79a2                	ld	s3,40(sp)
 642:	6161                	addi	sp,sp,80
 644:	8082                	ret
  neg = 0;
 646:	4301                	li	t1,0
 648:	bfbd                	j	5c6 <printint+0x1a>

000000000000064a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 64a:	711d                	addi	sp,sp,-96
 64c:	ec86                	sd	ra,88(sp)
 64e:	e8a2                	sd	s0,80(sp)
 650:	e4a6                	sd	s1,72(sp)
 652:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 654:	0005c483          	lbu	s1,0(a1)
 658:	22048363          	beqz	s1,87e <vprintf+0x234>
 65c:	e0ca                	sd	s2,64(sp)
 65e:	fc4e                	sd	s3,56(sp)
 660:	f852                	sd	s4,48(sp)
 662:	f456                	sd	s5,40(sp)
 664:	f05a                	sd	s6,32(sp)
 666:	ec5e                	sd	s7,24(sp)
 668:	e862                	sd	s8,16(sp)
 66a:	8b2a                	mv	s6,a0
 66c:	8a2e                	mv	s4,a1
 66e:	8bb2                	mv	s7,a2
  state = 0;
 670:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 672:	4901                	li	s2,0
 674:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 676:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 67a:	06400c13          	li	s8,100
 67e:	a00d                	j	6a0 <vprintf+0x56>
        putc(fd, c0);
 680:	85a6                	mv	a1,s1
 682:	855a                	mv	a0,s6
 684:	f0bff0ef          	jal	58e <putc>
 688:	a019                	j	68e <vprintf+0x44>
    } else if(state == '%'){
 68a:	03598363          	beq	s3,s5,6b0 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 68e:	0019079b          	addiw	a5,s2,1
 692:	893e                	mv	s2,a5
 694:	873e                	mv	a4,a5
 696:	97d2                	add	a5,a5,s4
 698:	0007c483          	lbu	s1,0(a5)
 69c:	1c048a63          	beqz	s1,870 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 6a0:	0004879b          	sext.w	a5,s1
    if(state == 0){
 6a4:	fe0993e3          	bnez	s3,68a <vprintf+0x40>
      if(c0 == '%'){
 6a8:	fd579ce3          	bne	a5,s5,680 <vprintf+0x36>
        state = '%';
 6ac:	89be                	mv	s3,a5
 6ae:	b7c5                	j	68e <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 6b0:	00ea06b3          	add	a3,s4,a4
 6b4:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 6b8:	1c060863          	beqz	a2,888 <vprintf+0x23e>
      if(c0 == 'd'){
 6bc:	03878763          	beq	a5,s8,6ea <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 6c0:	f9478693          	addi	a3,a5,-108
 6c4:	0016b693          	seqz	a3,a3
 6c8:	f9c60593          	addi	a1,a2,-100
 6cc:	e99d                	bnez	a1,702 <vprintf+0xb8>
 6ce:	ca95                	beqz	a3,702 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6d0:	008b8493          	addi	s1,s7,8
 6d4:	4685                	li	a3,1
 6d6:	4629                	li	a2,10
 6d8:	000bb583          	ld	a1,0(s7)
 6dc:	855a                	mv	a0,s6
 6de:	ecfff0ef          	jal	5ac <printint>
        i += 1;
 6e2:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6e4:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 6e6:	4981                	li	s3,0
 6e8:	b75d                	j	68e <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 6ea:	008b8493          	addi	s1,s7,8
 6ee:	4685                	li	a3,1
 6f0:	4629                	li	a2,10
 6f2:	000ba583          	lw	a1,0(s7)
 6f6:	855a                	mv	a0,s6
 6f8:	eb5ff0ef          	jal	5ac <printint>
 6fc:	8ba6                	mv	s7,s1
      state = 0;
 6fe:	4981                	li	s3,0
 700:	b779                	j	68e <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 702:	9752                	add	a4,a4,s4
 704:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 708:	f9460713          	addi	a4,a2,-108
 70c:	00173713          	seqz	a4,a4
 710:	8f75                	and	a4,a4,a3
 712:	f9c58513          	addi	a0,a1,-100
 716:	18051363          	bnez	a0,89c <vprintf+0x252>
 71a:	18070163          	beqz	a4,89c <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 71e:	008b8493          	addi	s1,s7,8
 722:	4685                	li	a3,1
 724:	4629                	li	a2,10
 726:	000bb583          	ld	a1,0(s7)
 72a:	855a                	mv	a0,s6
 72c:	e81ff0ef          	jal	5ac <printint>
        i += 2;
 730:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 732:	8ba6                	mv	s7,s1
      state = 0;
 734:	4981                	li	s3,0
        i += 2;
 736:	bfa1                	j	68e <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 738:	008b8493          	addi	s1,s7,8
 73c:	4681                	li	a3,0
 73e:	4629                	li	a2,10
 740:	000be583          	lwu	a1,0(s7)
 744:	855a                	mv	a0,s6
 746:	e67ff0ef          	jal	5ac <printint>
 74a:	8ba6                	mv	s7,s1
      state = 0;
 74c:	4981                	li	s3,0
 74e:	b781                	j	68e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 750:	008b8493          	addi	s1,s7,8
 754:	4681                	li	a3,0
 756:	4629                	li	a2,10
 758:	000bb583          	ld	a1,0(s7)
 75c:	855a                	mv	a0,s6
 75e:	e4fff0ef          	jal	5ac <printint>
        i += 1;
 762:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 764:	8ba6                	mv	s7,s1
      state = 0;
 766:	4981                	li	s3,0
 768:	b71d                	j	68e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 76a:	008b8493          	addi	s1,s7,8
 76e:	4681                	li	a3,0
 770:	4629                	li	a2,10
 772:	000bb583          	ld	a1,0(s7)
 776:	855a                	mv	a0,s6
 778:	e35ff0ef          	jal	5ac <printint>
        i += 2;
 77c:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 77e:	8ba6                	mv	s7,s1
      state = 0;
 780:	4981                	li	s3,0
        i += 2;
 782:	b731                	j	68e <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 784:	008b8493          	addi	s1,s7,8
 788:	4681                	li	a3,0
 78a:	4641                	li	a2,16
 78c:	000be583          	lwu	a1,0(s7)
 790:	855a                	mv	a0,s6
 792:	e1bff0ef          	jal	5ac <printint>
 796:	8ba6                	mv	s7,s1
      state = 0;
 798:	4981                	li	s3,0
 79a:	bdd5                	j	68e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 79c:	008b8493          	addi	s1,s7,8
 7a0:	4681                	li	a3,0
 7a2:	4641                	li	a2,16
 7a4:	000bb583          	ld	a1,0(s7)
 7a8:	855a                	mv	a0,s6
 7aa:	e03ff0ef          	jal	5ac <printint>
        i += 1;
 7ae:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 7b0:	8ba6                	mv	s7,s1
      state = 0;
 7b2:	4981                	li	s3,0
 7b4:	bde9                	j	68e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7b6:	008b8493          	addi	s1,s7,8
 7ba:	4681                	li	a3,0
 7bc:	4641                	li	a2,16
 7be:	000bb583          	ld	a1,0(s7)
 7c2:	855a                	mv	a0,s6
 7c4:	de9ff0ef          	jal	5ac <printint>
        i += 2;
 7c8:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 7ca:	8ba6                	mv	s7,s1
      state = 0;
 7cc:	4981                	li	s3,0
        i += 2;
 7ce:	b5c1                	j	68e <vprintf+0x44>
 7d0:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 7d2:	008b8793          	addi	a5,s7,8
 7d6:	8cbe                	mv	s9,a5
 7d8:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 7dc:	03000593          	li	a1,48
 7e0:	855a                	mv	a0,s6
 7e2:	dadff0ef          	jal	58e <putc>
  putc(fd, 'x');
 7e6:	07800593          	li	a1,120
 7ea:	855a                	mv	a0,s6
 7ec:	da3ff0ef          	jal	58e <putc>
 7f0:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7f2:	00000b97          	auipc	s7,0x0
 7f6:	5aeb8b93          	addi	s7,s7,1454 # da0 <digits>
 7fa:	03c9d793          	srli	a5,s3,0x3c
 7fe:	97de                	add	a5,a5,s7
 800:	0007c583          	lbu	a1,0(a5)
 804:	855a                	mv	a0,s6
 806:	d89ff0ef          	jal	58e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 80a:	0992                	slli	s3,s3,0x4
 80c:	34fd                	addiw	s1,s1,-1
 80e:	f4f5                	bnez	s1,7fa <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 810:	8be6                	mv	s7,s9
      state = 0;
 812:	4981                	li	s3,0
 814:	6ca2                	ld	s9,8(sp)
 816:	bda5                	j	68e <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 818:	008b8493          	addi	s1,s7,8
 81c:	000bc583          	lbu	a1,0(s7)
 820:	855a                	mv	a0,s6
 822:	d6dff0ef          	jal	58e <putc>
 826:	8ba6                	mv	s7,s1
      state = 0;
 828:	4981                	li	s3,0
 82a:	b595                	j	68e <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 82c:	008b8993          	addi	s3,s7,8
 830:	000bb483          	ld	s1,0(s7)
 834:	cc91                	beqz	s1,850 <vprintf+0x206>
        for(; *s; s++)
 836:	0004c583          	lbu	a1,0(s1)
 83a:	c985                	beqz	a1,86a <vprintf+0x220>
          putc(fd, *s);
 83c:	855a                	mv	a0,s6
 83e:	d51ff0ef          	jal	58e <putc>
        for(; *s; s++)
 842:	0485                	addi	s1,s1,1
 844:	0004c583          	lbu	a1,0(s1)
 848:	f9f5                	bnez	a1,83c <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 84a:	8bce                	mv	s7,s3
      state = 0;
 84c:	4981                	li	s3,0
 84e:	b581                	j	68e <vprintf+0x44>
          s = "(null)";
 850:	00000497          	auipc	s1,0x0
 854:	54848493          	addi	s1,s1,1352 # d98 <malloc+0x3ac>
        for(; *s; s++)
 858:	02800593          	li	a1,40
 85c:	b7c5                	j	83c <vprintf+0x1f2>
        putc(fd, '%');
 85e:	85be                	mv	a1,a5
 860:	855a                	mv	a0,s6
 862:	d2dff0ef          	jal	58e <putc>
      state = 0;
 866:	4981                	li	s3,0
 868:	b51d                	j	68e <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 86a:	8bce                	mv	s7,s3
      state = 0;
 86c:	4981                	li	s3,0
 86e:	b505                	j	68e <vprintf+0x44>
 870:	6906                	ld	s2,64(sp)
 872:	79e2                	ld	s3,56(sp)
 874:	7a42                	ld	s4,48(sp)
 876:	7aa2                	ld	s5,40(sp)
 878:	7b02                	ld	s6,32(sp)
 87a:	6be2                	ld	s7,24(sp)
 87c:	6c42                	ld	s8,16(sp)
    }
  }
}
 87e:	60e6                	ld	ra,88(sp)
 880:	6446                	ld	s0,80(sp)
 882:	64a6                	ld	s1,72(sp)
 884:	6125                	addi	sp,sp,96
 886:	8082                	ret
      if(c0 == 'd'){
 888:	06400713          	li	a4,100
 88c:	e4e78fe3          	beq	a5,a4,6ea <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 890:	f9478693          	addi	a3,a5,-108
 894:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 898:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 89a:	4701                	li	a4,0
      } else if(c0 == 'u'){
 89c:	07500513          	li	a0,117
 8a0:	e8a78ce3          	beq	a5,a0,738 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 8a4:	f8b60513          	addi	a0,a2,-117
 8a8:	e119                	bnez	a0,8ae <vprintf+0x264>
 8aa:	ea0693e3          	bnez	a3,750 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 8ae:	f8b58513          	addi	a0,a1,-117
 8b2:	e119                	bnez	a0,8b8 <vprintf+0x26e>
 8b4:	ea071be3          	bnez	a4,76a <vprintf+0x120>
      } else if(c0 == 'x'){
 8b8:	07800513          	li	a0,120
 8bc:	eca784e3          	beq	a5,a0,784 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 8c0:	f8860613          	addi	a2,a2,-120
 8c4:	e219                	bnez	a2,8ca <vprintf+0x280>
 8c6:	ec069be3          	bnez	a3,79c <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 8ca:	f8858593          	addi	a1,a1,-120
 8ce:	e199                	bnez	a1,8d4 <vprintf+0x28a>
 8d0:	ee0713e3          	bnez	a4,7b6 <vprintf+0x16c>
      } else if(c0 == 'p'){
 8d4:	07000713          	li	a4,112
 8d8:	eee78ce3          	beq	a5,a4,7d0 <vprintf+0x186>
      } else if(c0 == 'c'){
 8dc:	06300713          	li	a4,99
 8e0:	f2e78ce3          	beq	a5,a4,818 <vprintf+0x1ce>
      } else if(c0 == 's'){
 8e4:	07300713          	li	a4,115
 8e8:	f4e782e3          	beq	a5,a4,82c <vprintf+0x1e2>
      } else if(c0 == '%'){
 8ec:	02500713          	li	a4,37
 8f0:	f6e787e3          	beq	a5,a4,85e <vprintf+0x214>
        putc(fd, '%');
 8f4:	02500593          	li	a1,37
 8f8:	855a                	mv	a0,s6
 8fa:	c95ff0ef          	jal	58e <putc>
        putc(fd, c0);
 8fe:	85a6                	mv	a1,s1
 900:	855a                	mv	a0,s6
 902:	c8dff0ef          	jal	58e <putc>
      state = 0;
 906:	4981                	li	s3,0
 908:	b359                	j	68e <vprintf+0x44>

000000000000090a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 90a:	715d                	addi	sp,sp,-80
 90c:	ec06                	sd	ra,24(sp)
 90e:	e822                	sd	s0,16(sp)
 910:	1000                	addi	s0,sp,32
 912:	e010                	sd	a2,0(s0)
 914:	e414                	sd	a3,8(s0)
 916:	e818                	sd	a4,16(s0)
 918:	ec1c                	sd	a5,24(s0)
 91a:	03043023          	sd	a6,32(s0)
 91e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 922:	8622                	mv	a2,s0
 924:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 928:	d23ff0ef          	jal	64a <vprintf>
}
 92c:	60e2                	ld	ra,24(sp)
 92e:	6442                	ld	s0,16(sp)
 930:	6161                	addi	sp,sp,80
 932:	8082                	ret

0000000000000934 <printf>:

void
printf(const char *fmt, ...)
{
 934:	711d                	addi	sp,sp,-96
 936:	ec06                	sd	ra,24(sp)
 938:	e822                	sd	s0,16(sp)
 93a:	1000                	addi	s0,sp,32
 93c:	e40c                	sd	a1,8(s0)
 93e:	e810                	sd	a2,16(s0)
 940:	ec14                	sd	a3,24(s0)
 942:	f018                	sd	a4,32(s0)
 944:	f41c                	sd	a5,40(s0)
 946:	03043823          	sd	a6,48(s0)
 94a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 94e:	00840613          	addi	a2,s0,8
 952:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 956:	85aa                	mv	a1,a0
 958:	4505                	li	a0,1
 95a:	cf1ff0ef          	jal	64a <vprintf>
}
 95e:	60e2                	ld	ra,24(sp)
 960:	6442                	ld	s0,16(sp)
 962:	6125                	addi	sp,sp,96
 964:	8082                	ret

0000000000000966 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 966:	1141                	addi	sp,sp,-16
 968:	e406                	sd	ra,8(sp)
 96a:	e022                	sd	s0,0(sp)
 96c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 96e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 972:	00000797          	auipc	a5,0x0
 976:	69e7b783          	ld	a5,1694(a5) # 1010 <freep>
 97a:	a039                	j	988 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 97c:	6398                	ld	a4,0(a5)
 97e:	00e7e463          	bltu	a5,a4,986 <free+0x20>
 982:	00e6ea63          	bltu	a3,a4,996 <free+0x30>
{
 986:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 988:	fed7fae3          	bgeu	a5,a3,97c <free+0x16>
 98c:	6398                	ld	a4,0(a5)
 98e:	00e6e463          	bltu	a3,a4,996 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 992:	fee7eae3          	bltu	a5,a4,986 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 996:	ff852583          	lw	a1,-8(a0)
 99a:	6390                	ld	a2,0(a5)
 99c:	02059813          	slli	a6,a1,0x20
 9a0:	01c85713          	srli	a4,a6,0x1c
 9a4:	9736                	add	a4,a4,a3
 9a6:	02e60563          	beq	a2,a4,9d0 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 9aa:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 9ae:	4790                	lw	a2,8(a5)
 9b0:	02061593          	slli	a1,a2,0x20
 9b4:	01c5d713          	srli	a4,a1,0x1c
 9b8:	973e                	add	a4,a4,a5
 9ba:	02e68263          	beq	a3,a4,9de <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 9be:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 9c0:	00000717          	auipc	a4,0x0
 9c4:	64f73823          	sd	a5,1616(a4) # 1010 <freep>
}
 9c8:	60a2                	ld	ra,8(sp)
 9ca:	6402                	ld	s0,0(sp)
 9cc:	0141                	addi	sp,sp,16
 9ce:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 9d0:	4618                	lw	a4,8(a2)
 9d2:	9f2d                	addw	a4,a4,a1
 9d4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9d8:	6398                	ld	a4,0(a5)
 9da:	6310                	ld	a2,0(a4)
 9dc:	b7f9                	j	9aa <free+0x44>
    p->s.size += bp->s.size;
 9de:	ff852703          	lw	a4,-8(a0)
 9e2:	9f31                	addw	a4,a4,a2
 9e4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 9e6:	ff053683          	ld	a3,-16(a0)
 9ea:	bfd1                	j	9be <free+0x58>

00000000000009ec <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9ec:	7139                	addi	sp,sp,-64
 9ee:	fc06                	sd	ra,56(sp)
 9f0:	f822                	sd	s0,48(sp)
 9f2:	f04a                	sd	s2,32(sp)
 9f4:	ec4e                	sd	s3,24(sp)
 9f6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9f8:	02051993          	slli	s3,a0,0x20
 9fc:	0209d993          	srli	s3,s3,0x20
 a00:	09bd                	addi	s3,s3,15
 a02:	0049d993          	srli	s3,s3,0x4
 a06:	2985                	addiw	s3,s3,1
 a08:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 a0a:	00000517          	auipc	a0,0x0
 a0e:	60653503          	ld	a0,1542(a0) # 1010 <freep>
 a12:	c905                	beqz	a0,a42 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a14:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a16:	4798                	lw	a4,8(a5)
 a18:	09377663          	bgeu	a4,s3,aa4 <malloc+0xb8>
 a1c:	f426                	sd	s1,40(sp)
 a1e:	e852                	sd	s4,16(sp)
 a20:	e456                	sd	s5,8(sp)
 a22:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 a24:	8a4e                	mv	s4,s3
 a26:	6705                	lui	a4,0x1
 a28:	00e9f363          	bgeu	s3,a4,a2e <malloc+0x42>
 a2c:	6a05                	lui	s4,0x1
 a2e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a32:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a36:	00000497          	auipc	s1,0x0
 a3a:	5da48493          	addi	s1,s1,1498 # 1010 <freep>
  if(p == SBRK_ERROR)
 a3e:	5afd                	li	s5,-1
 a40:	a83d                	j	a7e <malloc+0x92>
 a42:	f426                	sd	s1,40(sp)
 a44:	e852                	sd	s4,16(sp)
 a46:	e456                	sd	s5,8(sp)
 a48:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a4a:	00000797          	auipc	a5,0x0
 a4e:	5d678793          	addi	a5,a5,1494 # 1020 <base>
 a52:	00000717          	auipc	a4,0x0
 a56:	5af73f23          	sd	a5,1470(a4) # 1010 <freep>
 a5a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a5c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a60:	b7d1                	j	a24 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 a62:	6398                	ld	a4,0(a5)
 a64:	e118                	sd	a4,0(a0)
 a66:	a899                	j	abc <malloc+0xd0>
  hp->s.size = nu;
 a68:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a6c:	0541                	addi	a0,a0,16
 a6e:	ef9ff0ef          	jal	966 <free>
  return freep;
 a72:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 a74:	c125                	beqz	a0,ad4 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a76:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a78:	4798                	lw	a4,8(a5)
 a7a:	03277163          	bgeu	a4,s2,a9c <malloc+0xb0>
    if(p == freep)
 a7e:	6098                	ld	a4,0(s1)
 a80:	853e                	mv	a0,a5
 a82:	fef71ae3          	bne	a4,a5,a76 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 a86:	8552                	mv	a0,s4
 a88:	9f3ff0ef          	jal	47a <sbrk>
  if(p == SBRK_ERROR)
 a8c:	fd551ee3          	bne	a0,s5,a68 <malloc+0x7c>
        return 0;
 a90:	4501                	li	a0,0
 a92:	74a2                	ld	s1,40(sp)
 a94:	6a42                	ld	s4,16(sp)
 a96:	6aa2                	ld	s5,8(sp)
 a98:	6b02                	ld	s6,0(sp)
 a9a:	a03d                	j	ac8 <malloc+0xdc>
 a9c:	74a2                	ld	s1,40(sp)
 a9e:	6a42                	ld	s4,16(sp)
 aa0:	6aa2                	ld	s5,8(sp)
 aa2:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 aa4:	fae90fe3          	beq	s2,a4,a62 <malloc+0x76>
        p->s.size -= nunits;
 aa8:	4137073b          	subw	a4,a4,s3
 aac:	c798                	sw	a4,8(a5)
        p += p->s.size;
 aae:	02071693          	slli	a3,a4,0x20
 ab2:	01c6d713          	srli	a4,a3,0x1c
 ab6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 ab8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 abc:	00000717          	auipc	a4,0x0
 ac0:	54a73a23          	sd	a0,1364(a4) # 1010 <freep>
      return (void*)(p + 1);
 ac4:	01078513          	addi	a0,a5,16
  }
}
 ac8:	70e2                	ld	ra,56(sp)
 aca:	7442                	ld	s0,48(sp)
 acc:	7902                	ld	s2,32(sp)
 ace:	69e2                	ld	s3,24(sp)
 ad0:	6121                	addi	sp,sp,64
 ad2:	8082                	ret
 ad4:	74a2                	ld	s1,40(sp)
 ad6:	6a42                	ld	s4,16(sp)
 ad8:	6aa2                	ld	s5,8(sp)
 ada:	6b02                	ld	s6,0(sp)
 adc:	b7f5                	j	ac8 <malloc+0xdc>
