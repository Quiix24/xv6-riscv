
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
  24:	b1050513          	addi	a0,a0,-1264 # b30 <malloc+0x11a>
  28:	4f0000ef          	jal	518 <open>
  2c:	06054d63          	bltz	a0,a6 <main+0xa6>
        mknod("console", CONSOLE, 0);
        open("console", O_RDWR);
    }
    dup(0);  // stdout
  30:	4501                	li	a0,0
  32:	51e000ef          	jal	550 <dup>
    dup(0);  // stderr
  36:	4501                	li	a0,0
  38:	518000ef          	jal	550 <dup>
    printf("\n");
  3c:	00001d97          	auipc	s11,0x1
  40:	afcd8d93          	addi	s11,s11,-1284 # b38 <malloc+0x122>
    printf("╔══════════════════════════════════════╗\n");
  44:	00001d17          	auipc	s10,0x1
  48:	afcd0d13          	addi	s10,s10,-1284 # b40 <malloc+0x12a>
            if (username[i] == '\n') { username[i] = '\0'; break; }
  4c:	44a9                	li	s1,10
    printf("\n");
  4e:	856e                	mv	a0,s11
  50:	10f000ef          	jal	95e <printf>
    printf("╔══════════════════════════════════════╗\n");
  54:	856a                	mv	a0,s10
  56:	109000ef          	jal	95e <printf>
    printf("║  xv6 Medical Device Security System  ║\n");
  5a:	00001517          	auipc	a0,0x1
  5e:	b6650513          	addi	a0,a0,-1178 # bc0 <malloc+0x1aa>
  62:	0fd000ef          	jal	95e <printf>
    printf("║  Authorized Access Only              ║\n");
  66:	00001517          	auipc	a0,0x1
  6a:	b8a50513          	addi	a0,a0,-1142 # bf0 <malloc+0x1da>
  6e:	0f1000ef          	jal	95e <printf>
    printf("╚══════════════════════════════════════╝\n\n");
  72:	00001517          	auipc	a0,0x1
  76:	bae50513          	addi	a0,a0,-1106 # c20 <malloc+0x20a>
  7a:	0e5000ef          	jal	95e <printf>
  7e:	4909                	li	s2,2
        printf("login: ");
  80:	00001c17          	auipc	s8,0x1
  84:	c20c0c13          	addi	s8,s8,-992 # ca0 <malloc+0x28a>
        gets(username, 32);
  88:	f5040b13          	addi	s6,s0,-176
  8c:	02000a93          	li	s5,32
        printf("password: ");
  90:	00001b97          	auipc	s7,0x1
  94:	c18b8b93          	addi	s7,s7,-1000 # ca8 <malloc+0x292>
        gets(password, 32);
  98:	f7040a13          	addi	s4,s0,-144
        printf("Authentication failed. %d attempt(s) remaining.\n\n",
  9c:	00001c97          	auipc	s9,0x1
  a0:	cb4c8c93          	addi	s9,s9,-844 # d50 <malloc+0x33a>
  a4:	a049                	j	126 <main+0x126>
        mknod("console", CONSOLE, 0);
  a6:	4601                	li	a2,0
  a8:	4585                	li	a1,1
  aa:	00001517          	auipc	a0,0x1
  ae:	a8650513          	addi	a0,a0,-1402 # b30 <malloc+0x11a>
  b2:	46e000ef          	jal	520 <mknod>
        open("console", O_RDWR);
  b6:	4589                	li	a1,2
  b8:	00001517          	auipc	a0,0x1
  bc:	a7850513          	addi	a0,a0,-1416 # b30 <malloc+0x11a>
  c0:	458000ef          	jal	518 <open>
  c4:	b7b5                	j	30 <main+0x30>
            if (username[i] == '\n') { username[i] = '\0'; break; }
  c6:	f9068793          	addi	a5,a3,-112
  ca:	008786b3          	add	a3,a5,s0
  ce:	fc068023          	sb	zero,-64(a3)
        printf("password: ");
  d2:	855e                	mv	a0,s7
  d4:	08b000ef          	jal	95e <printf>
        gets(password, 32);
  d8:	85d6                	mv	a1,s5
  da:	8552                	mv	a0,s4
  dc:	220000ef          	jal	2fc <gets>
        for (int i = 0; password[i]; i++) {
  e0:	f7044783          	lbu	a5,-144(s0)
  e4:	c395                	beqz	a5,108 <main+0x108>
  e6:	f7140713          	addi	a4,s0,-143
  ea:	4681                	li	a3,0
            if (password[i] == '\n') { password[i] = '\0'; break; }
  ec:	00978863          	beq	a5,s1,fc <main+0xfc>
        for (int i = 0; password[i]; i++) {
  f0:	2685                	addiw	a3,a3,1
  f2:	0705                	addi	a4,a4,1
  f4:	fff74783          	lbu	a5,-1(a4)
  f8:	fbf5                	bnez	a5,ec <main+0xec>
  fa:	a039                	j	108 <main+0x108>
            if (password[i] == '\n') { password[i] = '\0'; break; }
  fc:	f9068793          	addi	a5,a3,-112
 100:	008786b3          	add	a3,a5,s0
 104:	fe068023          	sb	zero,-32(a3)
        uid = login(username, password);
 108:	85d2                	mv	a1,s4
 10a:	855a                	mv	a0,s6
 10c:	46c000ef          	jal	578 <login>
 110:	89aa                	mv	s3,a0
        if (uid >= 0) {
 112:	02055f63          	bgez	a0,150 <main+0x150>
        printf("Authentication failed. %d attempt(s) remaining.\n\n",
 116:	85ca                	mv	a1,s2
 118:	8566                	mv	a0,s9
 11a:	045000ef          	jal	95e <printf>
    while (attempts < max_attempts) {
 11e:	397d                	addiw	s2,s2,-1
 120:	57fd                	li	a5,-1
 122:	0af90763          	beq	s2,a5,1d0 <main+0x1d0>
        printf("login: ");
 126:	8562                	mv	a0,s8
 128:	037000ef          	jal	95e <printf>
        gets(username, 32);
 12c:	85d6                	mv	a1,s5
 12e:	855a                	mv	a0,s6
 130:	1cc000ef          	jal	2fc <gets>
        for (int i = 0; username[i]; i++) {
 134:	f5044783          	lbu	a5,-176(s0)
 138:	dfc9                	beqz	a5,d2 <main+0xd2>
 13a:	f5140713          	addi	a4,s0,-175
 13e:	4681                	li	a3,0
            if (username[i] == '\n') { username[i] = '\0'; break; }
 140:	f89783e3          	beq	a5,s1,c6 <main+0xc6>
        for (int i = 0; username[i]; i++) {
 144:	2685                	addiw	a3,a3,1
 146:	0705                	addi	a4,a4,1
 148:	fff74783          	lbu	a5,-1(a4)
 14c:	fbf5                	bnez	a5,140 <main+0x140>
 14e:	b751                	j	d2 <main+0xd2>
            printf("\nWelcome, %s! Role: %s\n",
 150:	00001617          	auipc	a2,0x1
 154:	9c060613          	addi	a2,a2,-1600 # b10 <malloc+0xfa>
 158:	c901                	beqz	a0,168 <main+0x168>
                   uid == 1 ? "PATIENT" : "DOCTOR");
 15a:	4785                	li	a5,1
            printf("\nWelcome, %s! Role: %s\n",
 15c:	00001617          	auipc	a2,0x1
 160:	9cc60613          	addi	a2,a2,-1588 # b28 <malloc+0x112>
                   uid == 1 ? "PATIENT" : "DOCTOR");
 164:	06f50163          	beq	a0,a5,1c6 <main+0x1c6>
            printf("\nWelcome, %s! Role: %s\n",
 168:	f5040593          	addi	a1,s0,-176
 16c:	00001517          	auipc	a0,0x1
 170:	b4c50513          	addi	a0,a0,-1204 # cb8 <malloc+0x2a2>
 174:	7ea000ef          	jal	95e <printf>
            printf("Session authenticated. Launching shell...\n\n");
 178:	00001517          	auipc	a0,0x1
 17c:	b5850513          	addi	a0,a0,-1192 # cd0 <malloc+0x2ba>
 180:	7de000ef          	jal	95e <printf>

    // === AUTHENTICATION GATE ===
    // Loop ensures the shell is only spawned post-authentication
    for (;;) {
        int auth_uid = do_login();  // Blocks until valid credentials
        printf("[INIT] Authenticated as uid=%d, about to fork\n", auth_uid);
 184:	85ce                	mv	a1,s3
 186:	00001517          	auipc	a0,0x1
 18a:	b7a50513          	addi	a0,a0,-1158 # d00 <malloc+0x2ea>
 18e:	7d0000ef          	jal	95e <printf>

        pid = fork();
 192:	33e000ef          	jal	4d0 <fork>
 196:	892a                	mv	s2,a0
        printf("[INIT] fork() returned pid=%d\n", pid);
 198:	85aa                	mv	a1,a0
 19a:	00001517          	auipc	a0,0x1
 19e:	b9650513          	addi	a0,a0,-1130 # d30 <malloc+0x31a>
 1a2:	7bc000ef          	jal	95e <printf>
        if (pid < 0) {
 1a6:	02094c63          	bltz	s2,1de <main+0x1de>
            printf("init: fork failed\n");
            exit(1);
        }

        if (pid == 0) {
 1aa:	04090363          	beqz	s2,1f0 <main+0x1f0>
            exit(1);
        }

        // Parent: wait for shell to exit, then re-prompt login
        for (;;) {
            wpid = wait((int*)0);
 1ae:	4501                	li	a0,0
 1b0:	330000ef          	jal	4e0 <wait>
            if (wpid == pid) {
 1b4:	fea91de3          	bne	s2,a0,1ae <main+0x1ae>
                // Shell exited — go back to login prompt
                printf("\nSession ended. Please log in again.\n");
 1b8:	00001517          	auipc	a0,0x1
 1bc:	c6850513          	addi	a0,a0,-920 # e20 <malloc+0x40a>
 1c0:	79e000ef          	jal	95e <printf>
    for (;;) {
 1c4:	b569                	j	4e <main+0x4e>
            printf("\nWelcome, %s! Role: %s\n",
 1c6:	00001617          	auipc	a2,0x1
 1ca:	95a60613          	addi	a2,a2,-1702 # b20 <malloc+0x10a>
 1ce:	bf69                	j	168 <main+0x168>
    printf("Maximum attempts exceeded. System locked.\n");
 1d0:	00001517          	auipc	a0,0x1
 1d4:	bb850513          	addi	a0,a0,-1096 # d88 <malloc+0x372>
 1d8:	786000ef          	jal	95e <printf>
    for (;;) {
 1dc:	a001                	j	1dc <main+0x1dc>
            printf("init: fork failed\n");
 1de:	00001517          	auipc	a0,0x1
 1e2:	bda50513          	addi	a0,a0,-1062 # db8 <malloc+0x3a2>
 1e6:	778000ef          	jal	95e <printf>
            exit(1);
 1ea:	4505                	li	a0,1
 1ec:	2ec000ef          	jal	4d8 <exit>
            printf("[CHILD] Child process, about to exec sh\n");
 1f0:	00001517          	auipc	a0,0x1
 1f4:	be050513          	addi	a0,a0,-1056 # dd0 <malloc+0x3ba>
 1f8:	766000ef          	jal	95e <printf>
            exec("sh", sh_argv);
 1fc:	00001597          	auipc	a1,0x1
 200:	e0458593          	addi	a1,a1,-508 # 1000 <sh_argv>
 204:	00001517          	auipc	a0,0x1
 208:	bfc50513          	addi	a0,a0,-1028 # e00 <malloc+0x3ea>
 20c:	304000ef          	jal	510 <exec>
            printf("init: exec sh failed\n");
 210:	00001517          	auipc	a0,0x1
 214:	bf850513          	addi	a0,a0,-1032 # e08 <malloc+0x3f2>
 218:	746000ef          	jal	95e <printf>
            exit(1);
 21c:	4505                	li	a0,1
 21e:	2ba000ef          	jal	4d8 <exit>

0000000000000222 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 222:	1141                	addi	sp,sp,-16
 224:	e406                	sd	ra,8(sp)
 226:	e022                	sd	s0,0(sp)
 228:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 22a:	dd7ff0ef          	jal	0 <main>
  exit(r);
 22e:	2aa000ef          	jal	4d8 <exit>

0000000000000232 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 232:	1141                	addi	sp,sp,-16
 234:	e406                	sd	ra,8(sp)
 236:	e022                	sd	s0,0(sp)
 238:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 23a:	87aa                	mv	a5,a0
 23c:	0585                	addi	a1,a1,1
 23e:	0785                	addi	a5,a5,1
 240:	fff5c703          	lbu	a4,-1(a1)
 244:	fee78fa3          	sb	a4,-1(a5)
 248:	fb75                	bnez	a4,23c <strcpy+0xa>
    ;
  return os;
}
 24a:	60a2                	ld	ra,8(sp)
 24c:	6402                	ld	s0,0(sp)
 24e:	0141                	addi	sp,sp,16
 250:	8082                	ret

0000000000000252 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 252:	1141                	addi	sp,sp,-16
 254:	e406                	sd	ra,8(sp)
 256:	e022                	sd	s0,0(sp)
 258:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 25a:	00054783          	lbu	a5,0(a0)
 25e:	cb91                	beqz	a5,272 <strcmp+0x20>
 260:	0005c703          	lbu	a4,0(a1)
 264:	00f71763          	bne	a4,a5,272 <strcmp+0x20>
    p++, q++;
 268:	0505                	addi	a0,a0,1
 26a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 26c:	00054783          	lbu	a5,0(a0)
 270:	fbe5                	bnez	a5,260 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 272:	0005c503          	lbu	a0,0(a1)
}
 276:	40a7853b          	subw	a0,a5,a0
 27a:	60a2                	ld	ra,8(sp)
 27c:	6402                	ld	s0,0(sp)
 27e:	0141                	addi	sp,sp,16
 280:	8082                	ret

0000000000000282 <strlen>:

uint
strlen(const char *s)
{
 282:	1141                	addi	sp,sp,-16
 284:	e406                	sd	ra,8(sp)
 286:	e022                	sd	s0,0(sp)
 288:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 28a:	00054783          	lbu	a5,0(a0)
 28e:	cf91                	beqz	a5,2aa <strlen+0x28>
 290:	00150793          	addi	a5,a0,1
 294:	86be                	mv	a3,a5
 296:	0785                	addi	a5,a5,1
 298:	fff7c703          	lbu	a4,-1(a5)
 29c:	ff65                	bnez	a4,294 <strlen+0x12>
 29e:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 2a2:	60a2                	ld	ra,8(sp)
 2a4:	6402                	ld	s0,0(sp)
 2a6:	0141                	addi	sp,sp,16
 2a8:	8082                	ret
  for(n = 0; s[n]; n++)
 2aa:	4501                	li	a0,0
 2ac:	bfdd                	j	2a2 <strlen+0x20>

00000000000002ae <memset>:

void*
memset(void *dst, int c, uint n)
{
 2ae:	1141                	addi	sp,sp,-16
 2b0:	e406                	sd	ra,8(sp)
 2b2:	e022                	sd	s0,0(sp)
 2b4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2b6:	ca19                	beqz	a2,2cc <memset+0x1e>
 2b8:	87aa                	mv	a5,a0
 2ba:	1602                	slli	a2,a2,0x20
 2bc:	9201                	srli	a2,a2,0x20
 2be:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2c2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2c6:	0785                	addi	a5,a5,1
 2c8:	fee79de3          	bne	a5,a4,2c2 <memset+0x14>
  }
  return dst;
}
 2cc:	60a2                	ld	ra,8(sp)
 2ce:	6402                	ld	s0,0(sp)
 2d0:	0141                	addi	sp,sp,16
 2d2:	8082                	ret

00000000000002d4 <strchr>:

char*
strchr(const char *s, char c)
{
 2d4:	1141                	addi	sp,sp,-16
 2d6:	e406                	sd	ra,8(sp)
 2d8:	e022                	sd	s0,0(sp)
 2da:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2dc:	00054783          	lbu	a5,0(a0)
 2e0:	cf81                	beqz	a5,2f8 <strchr+0x24>
    if(*s == c)
 2e2:	00f58763          	beq	a1,a5,2f0 <strchr+0x1c>
  for(; *s; s++)
 2e6:	0505                	addi	a0,a0,1
 2e8:	00054783          	lbu	a5,0(a0)
 2ec:	fbfd                	bnez	a5,2e2 <strchr+0xe>
      return (char*)s;
  return 0;
 2ee:	4501                	li	a0,0
}
 2f0:	60a2                	ld	ra,8(sp)
 2f2:	6402                	ld	s0,0(sp)
 2f4:	0141                	addi	sp,sp,16
 2f6:	8082                	ret
  return 0;
 2f8:	4501                	li	a0,0
 2fa:	bfdd                	j	2f0 <strchr+0x1c>

00000000000002fc <gets>:

char*
gets(char *buf, int max)
{
 2fc:	711d                	addi	sp,sp,-96
 2fe:	ec86                	sd	ra,88(sp)
 300:	e8a2                	sd	s0,80(sp)
 302:	e4a6                	sd	s1,72(sp)
 304:	e0ca                	sd	s2,64(sp)
 306:	fc4e                	sd	s3,56(sp)
 308:	f852                	sd	s4,48(sp)
 30a:	f456                	sd	s5,40(sp)
 30c:	f05a                	sd	s6,32(sp)
 30e:	ec5e                	sd	s7,24(sp)
 310:	e862                	sd	s8,16(sp)
 312:	1080                	addi	s0,sp,96
 314:	8baa                	mv	s7,a0
 316:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 318:	892a                	mv	s2,a0
 31a:	4481                	li	s1,0
    cc = read(0, &c, 1);
 31c:	faf40b13          	addi	s6,s0,-81
 320:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 322:	8c26                	mv	s8,s1
 324:	0014899b          	addiw	s3,s1,1
 328:	84ce                	mv	s1,s3
 32a:	0349d463          	bge	s3,s4,352 <gets+0x56>
    cc = read(0, &c, 1);
 32e:	8656                	mv	a2,s5
 330:	85da                	mv	a1,s6
 332:	4501                	li	a0,0
 334:	1bc000ef          	jal	4f0 <read>
    if(cc < 1)
 338:	00a05d63          	blez	a0,352 <gets+0x56>
      break;
    buf[i++] = c;
 33c:	faf44783          	lbu	a5,-81(s0)
 340:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 344:	0905                	addi	s2,s2,1
 346:	ff678713          	addi	a4,a5,-10
 34a:	c319                	beqz	a4,350 <gets+0x54>
 34c:	17cd                	addi	a5,a5,-13
 34e:	fbf1                	bnez	a5,322 <gets+0x26>
    buf[i++] = c;
 350:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 352:	9c5e                	add	s8,s8,s7
 354:	000c0023          	sb	zero,0(s8)
  return buf;
}
 358:	855e                	mv	a0,s7
 35a:	60e6                	ld	ra,88(sp)
 35c:	6446                	ld	s0,80(sp)
 35e:	64a6                	ld	s1,72(sp)
 360:	6906                	ld	s2,64(sp)
 362:	79e2                	ld	s3,56(sp)
 364:	7a42                	ld	s4,48(sp)
 366:	7aa2                	ld	s5,40(sp)
 368:	7b02                	ld	s6,32(sp)
 36a:	6be2                	ld	s7,24(sp)
 36c:	6c42                	ld	s8,16(sp)
 36e:	6125                	addi	sp,sp,96
 370:	8082                	ret

0000000000000372 <stat>:

int
stat(const char *n, struct stat *st)
{
 372:	1101                	addi	sp,sp,-32
 374:	ec06                	sd	ra,24(sp)
 376:	e822                	sd	s0,16(sp)
 378:	e04a                	sd	s2,0(sp)
 37a:	1000                	addi	s0,sp,32
 37c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 37e:	4581                	li	a1,0
 380:	198000ef          	jal	518 <open>
  if(fd < 0)
 384:	02054263          	bltz	a0,3a8 <stat+0x36>
 388:	e426                	sd	s1,8(sp)
 38a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 38c:	85ca                	mv	a1,s2
 38e:	1a2000ef          	jal	530 <fstat>
 392:	892a                	mv	s2,a0
  close(fd);
 394:	8526                	mv	a0,s1
 396:	16a000ef          	jal	500 <close>
  return r;
 39a:	64a2                	ld	s1,8(sp)
}
 39c:	854a                	mv	a0,s2
 39e:	60e2                	ld	ra,24(sp)
 3a0:	6442                	ld	s0,16(sp)
 3a2:	6902                	ld	s2,0(sp)
 3a4:	6105                	addi	sp,sp,32
 3a6:	8082                	ret
    return -1;
 3a8:	57fd                	li	a5,-1
 3aa:	893e                	mv	s2,a5
 3ac:	bfc5                	j	39c <stat+0x2a>

00000000000003ae <atoi>:

int
atoi(const char *s)
{
 3ae:	1141                	addi	sp,sp,-16
 3b0:	e406                	sd	ra,8(sp)
 3b2:	e022                	sd	s0,0(sp)
 3b4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3b6:	00054683          	lbu	a3,0(a0)
 3ba:	fd06879b          	addiw	a5,a3,-48
 3be:	0ff7f793          	zext.b	a5,a5
 3c2:	4625                	li	a2,9
 3c4:	02f66963          	bltu	a2,a5,3f6 <atoi+0x48>
 3c8:	872a                	mv	a4,a0
  n = 0;
 3ca:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3cc:	0705                	addi	a4,a4,1
 3ce:	0025179b          	slliw	a5,a0,0x2
 3d2:	9fa9                	addw	a5,a5,a0
 3d4:	0017979b          	slliw	a5,a5,0x1
 3d8:	9fb5                	addw	a5,a5,a3
 3da:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3de:	00074683          	lbu	a3,0(a4)
 3e2:	fd06879b          	addiw	a5,a3,-48
 3e6:	0ff7f793          	zext.b	a5,a5
 3ea:	fef671e3          	bgeu	a2,a5,3cc <atoi+0x1e>
  return n;
}
 3ee:	60a2                	ld	ra,8(sp)
 3f0:	6402                	ld	s0,0(sp)
 3f2:	0141                	addi	sp,sp,16
 3f4:	8082                	ret
  n = 0;
 3f6:	4501                	li	a0,0
 3f8:	bfdd                	j	3ee <atoi+0x40>

00000000000003fa <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3fa:	1141                	addi	sp,sp,-16
 3fc:	e406                	sd	ra,8(sp)
 3fe:	e022                	sd	s0,0(sp)
 400:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 402:	02b57563          	bgeu	a0,a1,42c <memmove+0x32>
    while(n-- > 0)
 406:	00c05f63          	blez	a2,424 <memmove+0x2a>
 40a:	1602                	slli	a2,a2,0x20
 40c:	9201                	srli	a2,a2,0x20
 40e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 412:	872a                	mv	a4,a0
      *dst++ = *src++;
 414:	0585                	addi	a1,a1,1
 416:	0705                	addi	a4,a4,1
 418:	fff5c683          	lbu	a3,-1(a1)
 41c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 420:	fee79ae3          	bne	a5,a4,414 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 424:	60a2                	ld	ra,8(sp)
 426:	6402                	ld	s0,0(sp)
 428:	0141                	addi	sp,sp,16
 42a:	8082                	ret
    while(n-- > 0)
 42c:	fec05ce3          	blez	a2,424 <memmove+0x2a>
    dst += n;
 430:	00c50733          	add	a4,a0,a2
    src += n;
 434:	95b2                	add	a1,a1,a2
 436:	fff6079b          	addiw	a5,a2,-1
 43a:	1782                	slli	a5,a5,0x20
 43c:	9381                	srli	a5,a5,0x20
 43e:	fff7c793          	not	a5,a5
 442:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 444:	15fd                	addi	a1,a1,-1
 446:	177d                	addi	a4,a4,-1
 448:	0005c683          	lbu	a3,0(a1)
 44c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 450:	fef71ae3          	bne	a4,a5,444 <memmove+0x4a>
 454:	bfc1                	j	424 <memmove+0x2a>

0000000000000456 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 456:	1141                	addi	sp,sp,-16
 458:	e406                	sd	ra,8(sp)
 45a:	e022                	sd	s0,0(sp)
 45c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 45e:	c61d                	beqz	a2,48c <memcmp+0x36>
 460:	1602                	slli	a2,a2,0x20
 462:	9201                	srli	a2,a2,0x20
 464:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 468:	00054783          	lbu	a5,0(a0)
 46c:	0005c703          	lbu	a4,0(a1)
 470:	00e79863          	bne	a5,a4,480 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 474:	0505                	addi	a0,a0,1
    p2++;
 476:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 478:	fed518e3          	bne	a0,a3,468 <memcmp+0x12>
  }
  return 0;
 47c:	4501                	li	a0,0
 47e:	a019                	j	484 <memcmp+0x2e>
      return *p1 - *p2;
 480:	40e7853b          	subw	a0,a5,a4
}
 484:	60a2                	ld	ra,8(sp)
 486:	6402                	ld	s0,0(sp)
 488:	0141                	addi	sp,sp,16
 48a:	8082                	ret
  return 0;
 48c:	4501                	li	a0,0
 48e:	bfdd                	j	484 <memcmp+0x2e>

0000000000000490 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 490:	1141                	addi	sp,sp,-16
 492:	e406                	sd	ra,8(sp)
 494:	e022                	sd	s0,0(sp)
 496:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 498:	f63ff0ef          	jal	3fa <memmove>
}
 49c:	60a2                	ld	ra,8(sp)
 49e:	6402                	ld	s0,0(sp)
 4a0:	0141                	addi	sp,sp,16
 4a2:	8082                	ret

00000000000004a4 <sbrk>:

char *
sbrk(int n) {
 4a4:	1141                	addi	sp,sp,-16
 4a6:	e406                	sd	ra,8(sp)
 4a8:	e022                	sd	s0,0(sp)
 4aa:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 4ac:	4585                	li	a1,1
 4ae:	0b2000ef          	jal	560 <sys_sbrk>
}
 4b2:	60a2                	ld	ra,8(sp)
 4b4:	6402                	ld	s0,0(sp)
 4b6:	0141                	addi	sp,sp,16
 4b8:	8082                	ret

00000000000004ba <sbrklazy>:

char *
sbrklazy(int n) {
 4ba:	1141                	addi	sp,sp,-16
 4bc:	e406                	sd	ra,8(sp)
 4be:	e022                	sd	s0,0(sp)
 4c0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 4c2:	4589                	li	a1,2
 4c4:	09c000ef          	jal	560 <sys_sbrk>
}
 4c8:	60a2                	ld	ra,8(sp)
 4ca:	6402                	ld	s0,0(sp)
 4cc:	0141                	addi	sp,sp,16
 4ce:	8082                	ret

00000000000004d0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4d0:	4885                	li	a7,1
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4d8:	4889                	li	a7,2
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 4e0:	488d                	li	a7,3
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4e8:	4891                	li	a7,4
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <read>:
.global read
read:
 li a7, SYS_read
 4f0:	4895                	li	a7,5
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <write>:
.global write
write:
 li a7, SYS_write
 4f8:	48c1                	li	a7,16
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <close>:
.global close
close:
 li a7, SYS_close
 500:	48d5                	li	a7,21
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <kill>:
.global kill
kill:
 li a7, SYS_kill
 508:	4899                	li	a7,6
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <exec>:
.global exec
exec:
 li a7, SYS_exec
 510:	489d                	li	a7,7
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <open>:
.global open
open:
 li a7, SYS_open
 518:	48bd                	li	a7,15
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 520:	48c5                	li	a7,17
 ecall
 522:	00000073          	ecall
 ret
 526:	8082                	ret

0000000000000528 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 528:	48c9                	li	a7,18
 ecall
 52a:	00000073          	ecall
 ret
 52e:	8082                	ret

0000000000000530 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 530:	48a1                	li	a7,8
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <link>:
.global link
link:
 li a7, SYS_link
 538:	48cd                	li	a7,19
 ecall
 53a:	00000073          	ecall
 ret
 53e:	8082                	ret

0000000000000540 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 540:	48d1                	li	a7,20
 ecall
 542:	00000073          	ecall
 ret
 546:	8082                	ret

0000000000000548 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 548:	48a5                	li	a7,9
 ecall
 54a:	00000073          	ecall
 ret
 54e:	8082                	ret

0000000000000550 <dup>:
.global dup
dup:
 li a7, SYS_dup
 550:	48a9                	li	a7,10
 ecall
 552:	00000073          	ecall
 ret
 556:	8082                	ret

0000000000000558 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 558:	48ad                	li	a7,11
 ecall
 55a:	00000073          	ecall
 ret
 55e:	8082                	ret

0000000000000560 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 560:	48b1                	li	a7,12
 ecall
 562:	00000073          	ecall
 ret
 566:	8082                	ret

0000000000000568 <pause>:
.global pause
pause:
 li a7, SYS_pause
 568:	48b5                	li	a7,13
 ecall
 56a:	00000073          	ecall
 ret
 56e:	8082                	ret

0000000000000570 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 570:	48b9                	li	a7,14
 ecall
 572:	00000073          	ecall
 ret
 576:	8082                	ret

0000000000000578 <login>:
.global login
login:
 li a7, SYS_login
 578:	48d9                	li	a7,22
 ecall
 57a:	00000073          	ecall
 ret
 57e:	8082                	ret

0000000000000580 <useradd>:
.global useradd
useradd:
 li a7, SYS_useradd
 580:	48dd                	li	a7,23
 ecall
 582:	00000073          	ecall
 ret
 586:	8082                	ret

0000000000000588 <userdel>:
.global userdel
userdel:
 li a7, SYS_userdel
 588:	48e1                	li	a7,24
 ecall
 58a:	00000073          	ecall
 ret
 58e:	8082                	ret

0000000000000590 <passwd>:
.global passwd
passwd:
 li a7, SYS_passwd
 590:	48e5                	li	a7,25
 ecall
 592:	00000073          	ecall
 ret
 596:	8082                	ret

0000000000000598 <whoami>:
.global whoami
whoami:
 li a7, SYS_whoami
 598:	48e9                	li	a7,26
 ecall
 59a:	00000073          	ecall
 ret
 59e:	8082                	ret

00000000000005a0 <chmod>:
.global chmod
chmod:
 li a7, SYS_chmod
 5a0:	48ed                	li	a7,27
 ecall
 5a2:	00000073          	ecall
 ret
 5a6:	8082                	ret

00000000000005a8 <chown>:
.global chown
chown:
 li a7, SYS_chown
 5a8:	48f1                	li	a7,28
 ecall
 5aa:	00000073          	ecall
 ret
 5ae:	8082                	ret

00000000000005b0 <audit_read>:
.global audit_read
audit_read:
 li a7, SYS_audit_read
 5b0:	48f5                	li	a7,29
 ecall
 5b2:	00000073          	ecall
 ret
 5b6:	8082                	ret

00000000000005b8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5b8:	1101                	addi	sp,sp,-32
 5ba:	ec06                	sd	ra,24(sp)
 5bc:	e822                	sd	s0,16(sp)
 5be:	1000                	addi	s0,sp,32
 5c0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5c4:	4605                	li	a2,1
 5c6:	fef40593          	addi	a1,s0,-17
 5ca:	f2fff0ef          	jal	4f8 <write>
}
 5ce:	60e2                	ld	ra,24(sp)
 5d0:	6442                	ld	s0,16(sp)
 5d2:	6105                	addi	sp,sp,32
 5d4:	8082                	ret

00000000000005d6 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 5d6:	715d                	addi	sp,sp,-80
 5d8:	e486                	sd	ra,72(sp)
 5da:	e0a2                	sd	s0,64(sp)
 5dc:	f84a                	sd	s2,48(sp)
 5de:	f44e                	sd	s3,40(sp)
 5e0:	0880                	addi	s0,sp,80
 5e2:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 5e4:	c6d1                	beqz	a3,670 <printint+0x9a>
 5e6:	0805d563          	bgez	a1,670 <printint+0x9a>
    neg = 1;
    x = -xx;
 5ea:	40b005b3          	neg	a1,a1
    neg = 1;
 5ee:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 5f0:	fb840993          	addi	s3,s0,-72
  neg = 0;
 5f4:	86ce                	mv	a3,s3
  i = 0;
 5f6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5f8:	00001817          	auipc	a6,0x1
 5fc:	85880813          	addi	a6,a6,-1960 # e50 <digits>
 600:	88ba                	mv	a7,a4
 602:	0017051b          	addiw	a0,a4,1
 606:	872a                	mv	a4,a0
 608:	02c5f7b3          	remu	a5,a1,a2
 60c:	97c2                	add	a5,a5,a6
 60e:	0007c783          	lbu	a5,0(a5)
 612:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 616:	87ae                	mv	a5,a1
 618:	02c5d5b3          	divu	a1,a1,a2
 61c:	0685                	addi	a3,a3,1
 61e:	fec7f1e3          	bgeu	a5,a2,600 <printint+0x2a>
  if(neg)
 622:	00030c63          	beqz	t1,63a <printint+0x64>
    buf[i++] = '-';
 626:	fd050793          	addi	a5,a0,-48
 62a:	00878533          	add	a0,a5,s0
 62e:	02d00793          	li	a5,45
 632:	fef50423          	sb	a5,-24(a0)
 636:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 63a:	02e05563          	blez	a4,664 <printint+0x8e>
 63e:	fc26                	sd	s1,56(sp)
 640:	377d                	addiw	a4,a4,-1
 642:	00e984b3          	add	s1,s3,a4
 646:	19fd                	addi	s3,s3,-1
 648:	99ba                	add	s3,s3,a4
 64a:	1702                	slli	a4,a4,0x20
 64c:	9301                	srli	a4,a4,0x20
 64e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 652:	0004c583          	lbu	a1,0(s1)
 656:	854a                	mv	a0,s2
 658:	f61ff0ef          	jal	5b8 <putc>
  while(--i >= 0)
 65c:	14fd                	addi	s1,s1,-1
 65e:	ff349ae3          	bne	s1,s3,652 <printint+0x7c>
 662:	74e2                	ld	s1,56(sp)
}
 664:	60a6                	ld	ra,72(sp)
 666:	6406                	ld	s0,64(sp)
 668:	7942                	ld	s2,48(sp)
 66a:	79a2                	ld	s3,40(sp)
 66c:	6161                	addi	sp,sp,80
 66e:	8082                	ret
  neg = 0;
 670:	4301                	li	t1,0
 672:	bfbd                	j	5f0 <printint+0x1a>

0000000000000674 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 674:	711d                	addi	sp,sp,-96
 676:	ec86                	sd	ra,88(sp)
 678:	e8a2                	sd	s0,80(sp)
 67a:	e4a6                	sd	s1,72(sp)
 67c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 67e:	0005c483          	lbu	s1,0(a1)
 682:	22048363          	beqz	s1,8a8 <vprintf+0x234>
 686:	e0ca                	sd	s2,64(sp)
 688:	fc4e                	sd	s3,56(sp)
 68a:	f852                	sd	s4,48(sp)
 68c:	f456                	sd	s5,40(sp)
 68e:	f05a                	sd	s6,32(sp)
 690:	ec5e                	sd	s7,24(sp)
 692:	e862                	sd	s8,16(sp)
 694:	8b2a                	mv	s6,a0
 696:	8a2e                	mv	s4,a1
 698:	8bb2                	mv	s7,a2
  state = 0;
 69a:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 69c:	4901                	li	s2,0
 69e:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 6a0:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 6a4:	06400c13          	li	s8,100
 6a8:	a00d                	j	6ca <vprintf+0x56>
        putc(fd, c0);
 6aa:	85a6                	mv	a1,s1
 6ac:	855a                	mv	a0,s6
 6ae:	f0bff0ef          	jal	5b8 <putc>
 6b2:	a019                	j	6b8 <vprintf+0x44>
    } else if(state == '%'){
 6b4:	03598363          	beq	s3,s5,6da <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 6b8:	0019079b          	addiw	a5,s2,1
 6bc:	893e                	mv	s2,a5
 6be:	873e                	mv	a4,a5
 6c0:	97d2                	add	a5,a5,s4
 6c2:	0007c483          	lbu	s1,0(a5)
 6c6:	1c048a63          	beqz	s1,89a <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 6ca:	0004879b          	sext.w	a5,s1
    if(state == 0){
 6ce:	fe0993e3          	bnez	s3,6b4 <vprintf+0x40>
      if(c0 == '%'){
 6d2:	fd579ce3          	bne	a5,s5,6aa <vprintf+0x36>
        state = '%';
 6d6:	89be                	mv	s3,a5
 6d8:	b7c5                	j	6b8 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 6da:	00ea06b3          	add	a3,s4,a4
 6de:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 6e2:	1c060863          	beqz	a2,8b2 <vprintf+0x23e>
      if(c0 == 'd'){
 6e6:	03878763          	beq	a5,s8,714 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 6ea:	f9478693          	addi	a3,a5,-108
 6ee:	0016b693          	seqz	a3,a3
 6f2:	f9c60593          	addi	a1,a2,-100
 6f6:	e99d                	bnez	a1,72c <vprintf+0xb8>
 6f8:	ca95                	beqz	a3,72c <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6fa:	008b8493          	addi	s1,s7,8
 6fe:	4685                	li	a3,1
 700:	4629                	li	a2,10
 702:	000bb583          	ld	a1,0(s7)
 706:	855a                	mv	a0,s6
 708:	ecfff0ef          	jal	5d6 <printint>
        i += 1;
 70c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 70e:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 710:	4981                	li	s3,0
 712:	b75d                	j	6b8 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 714:	008b8493          	addi	s1,s7,8
 718:	4685                	li	a3,1
 71a:	4629                	li	a2,10
 71c:	000ba583          	lw	a1,0(s7)
 720:	855a                	mv	a0,s6
 722:	eb5ff0ef          	jal	5d6 <printint>
 726:	8ba6                	mv	s7,s1
      state = 0;
 728:	4981                	li	s3,0
 72a:	b779                	j	6b8 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 72c:	9752                	add	a4,a4,s4
 72e:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 732:	f9460713          	addi	a4,a2,-108
 736:	00173713          	seqz	a4,a4
 73a:	8f75                	and	a4,a4,a3
 73c:	f9c58513          	addi	a0,a1,-100
 740:	18051363          	bnez	a0,8c6 <vprintf+0x252>
 744:	18070163          	beqz	a4,8c6 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 748:	008b8493          	addi	s1,s7,8
 74c:	4685                	li	a3,1
 74e:	4629                	li	a2,10
 750:	000bb583          	ld	a1,0(s7)
 754:	855a                	mv	a0,s6
 756:	e81ff0ef          	jal	5d6 <printint>
        i += 2;
 75a:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 75c:	8ba6                	mv	s7,s1
      state = 0;
 75e:	4981                	li	s3,0
        i += 2;
 760:	bfa1                	j	6b8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 762:	008b8493          	addi	s1,s7,8
 766:	4681                	li	a3,0
 768:	4629                	li	a2,10
 76a:	000be583          	lwu	a1,0(s7)
 76e:	855a                	mv	a0,s6
 770:	e67ff0ef          	jal	5d6 <printint>
 774:	8ba6                	mv	s7,s1
      state = 0;
 776:	4981                	li	s3,0
 778:	b781                	j	6b8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 77a:	008b8493          	addi	s1,s7,8
 77e:	4681                	li	a3,0
 780:	4629                	li	a2,10
 782:	000bb583          	ld	a1,0(s7)
 786:	855a                	mv	a0,s6
 788:	e4fff0ef          	jal	5d6 <printint>
        i += 1;
 78c:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 78e:	8ba6                	mv	s7,s1
      state = 0;
 790:	4981                	li	s3,0
 792:	b71d                	j	6b8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 794:	008b8493          	addi	s1,s7,8
 798:	4681                	li	a3,0
 79a:	4629                	li	a2,10
 79c:	000bb583          	ld	a1,0(s7)
 7a0:	855a                	mv	a0,s6
 7a2:	e35ff0ef          	jal	5d6 <printint>
        i += 2;
 7a6:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 7a8:	8ba6                	mv	s7,s1
      state = 0;
 7aa:	4981                	li	s3,0
        i += 2;
 7ac:	b731                	j	6b8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 7ae:	008b8493          	addi	s1,s7,8
 7b2:	4681                	li	a3,0
 7b4:	4641                	li	a2,16
 7b6:	000be583          	lwu	a1,0(s7)
 7ba:	855a                	mv	a0,s6
 7bc:	e1bff0ef          	jal	5d6 <printint>
 7c0:	8ba6                	mv	s7,s1
      state = 0;
 7c2:	4981                	li	s3,0
 7c4:	bdd5                	j	6b8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7c6:	008b8493          	addi	s1,s7,8
 7ca:	4681                	li	a3,0
 7cc:	4641                	li	a2,16
 7ce:	000bb583          	ld	a1,0(s7)
 7d2:	855a                	mv	a0,s6
 7d4:	e03ff0ef          	jal	5d6 <printint>
        i += 1;
 7d8:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 7da:	8ba6                	mv	s7,s1
      state = 0;
 7dc:	4981                	li	s3,0
 7de:	bde9                	j	6b8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7e0:	008b8493          	addi	s1,s7,8
 7e4:	4681                	li	a3,0
 7e6:	4641                	li	a2,16
 7e8:	000bb583          	ld	a1,0(s7)
 7ec:	855a                	mv	a0,s6
 7ee:	de9ff0ef          	jal	5d6 <printint>
        i += 2;
 7f2:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 7f4:	8ba6                	mv	s7,s1
      state = 0;
 7f6:	4981                	li	s3,0
        i += 2;
 7f8:	b5c1                	j	6b8 <vprintf+0x44>
 7fa:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 7fc:	008b8793          	addi	a5,s7,8
 800:	8cbe                	mv	s9,a5
 802:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 806:	03000593          	li	a1,48
 80a:	855a                	mv	a0,s6
 80c:	dadff0ef          	jal	5b8 <putc>
  putc(fd, 'x');
 810:	07800593          	li	a1,120
 814:	855a                	mv	a0,s6
 816:	da3ff0ef          	jal	5b8 <putc>
 81a:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 81c:	00000b97          	auipc	s7,0x0
 820:	634b8b93          	addi	s7,s7,1588 # e50 <digits>
 824:	03c9d793          	srli	a5,s3,0x3c
 828:	97de                	add	a5,a5,s7
 82a:	0007c583          	lbu	a1,0(a5)
 82e:	855a                	mv	a0,s6
 830:	d89ff0ef          	jal	5b8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 834:	0992                	slli	s3,s3,0x4
 836:	34fd                	addiw	s1,s1,-1
 838:	f4f5                	bnez	s1,824 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 83a:	8be6                	mv	s7,s9
      state = 0;
 83c:	4981                	li	s3,0
 83e:	6ca2                	ld	s9,8(sp)
 840:	bda5                	j	6b8 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 842:	008b8493          	addi	s1,s7,8
 846:	000bc583          	lbu	a1,0(s7)
 84a:	855a                	mv	a0,s6
 84c:	d6dff0ef          	jal	5b8 <putc>
 850:	8ba6                	mv	s7,s1
      state = 0;
 852:	4981                	li	s3,0
 854:	b595                	j	6b8 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 856:	008b8993          	addi	s3,s7,8
 85a:	000bb483          	ld	s1,0(s7)
 85e:	cc91                	beqz	s1,87a <vprintf+0x206>
        for(; *s; s++)
 860:	0004c583          	lbu	a1,0(s1)
 864:	c985                	beqz	a1,894 <vprintf+0x220>
          putc(fd, *s);
 866:	855a                	mv	a0,s6
 868:	d51ff0ef          	jal	5b8 <putc>
        for(; *s; s++)
 86c:	0485                	addi	s1,s1,1
 86e:	0004c583          	lbu	a1,0(s1)
 872:	f9f5                	bnez	a1,866 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 874:	8bce                	mv	s7,s3
      state = 0;
 876:	4981                	li	s3,0
 878:	b581                	j	6b8 <vprintf+0x44>
          s = "(null)";
 87a:	00000497          	auipc	s1,0x0
 87e:	5ce48493          	addi	s1,s1,1486 # e48 <malloc+0x432>
        for(; *s; s++)
 882:	02800593          	li	a1,40
 886:	b7c5                	j	866 <vprintf+0x1f2>
        putc(fd, '%');
 888:	85be                	mv	a1,a5
 88a:	855a                	mv	a0,s6
 88c:	d2dff0ef          	jal	5b8 <putc>
      state = 0;
 890:	4981                	li	s3,0
 892:	b51d                	j	6b8 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 894:	8bce                	mv	s7,s3
      state = 0;
 896:	4981                	li	s3,0
 898:	b505                	j	6b8 <vprintf+0x44>
 89a:	6906                	ld	s2,64(sp)
 89c:	79e2                	ld	s3,56(sp)
 89e:	7a42                	ld	s4,48(sp)
 8a0:	7aa2                	ld	s5,40(sp)
 8a2:	7b02                	ld	s6,32(sp)
 8a4:	6be2                	ld	s7,24(sp)
 8a6:	6c42                	ld	s8,16(sp)
    }
  }
}
 8a8:	60e6                	ld	ra,88(sp)
 8aa:	6446                	ld	s0,80(sp)
 8ac:	64a6                	ld	s1,72(sp)
 8ae:	6125                	addi	sp,sp,96
 8b0:	8082                	ret
      if(c0 == 'd'){
 8b2:	06400713          	li	a4,100
 8b6:	e4e78fe3          	beq	a5,a4,714 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 8ba:	f9478693          	addi	a3,a5,-108
 8be:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 8c2:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 8c4:	4701                	li	a4,0
      } else if(c0 == 'u'){
 8c6:	07500513          	li	a0,117
 8ca:	e8a78ce3          	beq	a5,a0,762 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 8ce:	f8b60513          	addi	a0,a2,-117
 8d2:	e119                	bnez	a0,8d8 <vprintf+0x264>
 8d4:	ea0693e3          	bnez	a3,77a <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 8d8:	f8b58513          	addi	a0,a1,-117
 8dc:	e119                	bnez	a0,8e2 <vprintf+0x26e>
 8de:	ea071be3          	bnez	a4,794 <vprintf+0x120>
      } else if(c0 == 'x'){
 8e2:	07800513          	li	a0,120
 8e6:	eca784e3          	beq	a5,a0,7ae <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 8ea:	f8860613          	addi	a2,a2,-120
 8ee:	e219                	bnez	a2,8f4 <vprintf+0x280>
 8f0:	ec069be3          	bnez	a3,7c6 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 8f4:	f8858593          	addi	a1,a1,-120
 8f8:	e199                	bnez	a1,8fe <vprintf+0x28a>
 8fa:	ee0713e3          	bnez	a4,7e0 <vprintf+0x16c>
      } else if(c0 == 'p'){
 8fe:	07000713          	li	a4,112
 902:	eee78ce3          	beq	a5,a4,7fa <vprintf+0x186>
      } else if(c0 == 'c'){
 906:	06300713          	li	a4,99
 90a:	f2e78ce3          	beq	a5,a4,842 <vprintf+0x1ce>
      } else if(c0 == 's'){
 90e:	07300713          	li	a4,115
 912:	f4e782e3          	beq	a5,a4,856 <vprintf+0x1e2>
      } else if(c0 == '%'){
 916:	02500713          	li	a4,37
 91a:	f6e787e3          	beq	a5,a4,888 <vprintf+0x214>
        putc(fd, '%');
 91e:	02500593          	li	a1,37
 922:	855a                	mv	a0,s6
 924:	c95ff0ef          	jal	5b8 <putc>
        putc(fd, c0);
 928:	85a6                	mv	a1,s1
 92a:	855a                	mv	a0,s6
 92c:	c8dff0ef          	jal	5b8 <putc>
      state = 0;
 930:	4981                	li	s3,0
 932:	b359                	j	6b8 <vprintf+0x44>

0000000000000934 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 934:	715d                	addi	sp,sp,-80
 936:	ec06                	sd	ra,24(sp)
 938:	e822                	sd	s0,16(sp)
 93a:	1000                	addi	s0,sp,32
 93c:	e010                	sd	a2,0(s0)
 93e:	e414                	sd	a3,8(s0)
 940:	e818                	sd	a4,16(s0)
 942:	ec1c                	sd	a5,24(s0)
 944:	03043023          	sd	a6,32(s0)
 948:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 94c:	8622                	mv	a2,s0
 94e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 952:	d23ff0ef          	jal	674 <vprintf>
}
 956:	60e2                	ld	ra,24(sp)
 958:	6442                	ld	s0,16(sp)
 95a:	6161                	addi	sp,sp,80
 95c:	8082                	ret

000000000000095e <printf>:

void
printf(const char *fmt, ...)
{
 95e:	711d                	addi	sp,sp,-96
 960:	ec06                	sd	ra,24(sp)
 962:	e822                	sd	s0,16(sp)
 964:	1000                	addi	s0,sp,32
 966:	e40c                	sd	a1,8(s0)
 968:	e810                	sd	a2,16(s0)
 96a:	ec14                	sd	a3,24(s0)
 96c:	f018                	sd	a4,32(s0)
 96e:	f41c                	sd	a5,40(s0)
 970:	03043823          	sd	a6,48(s0)
 974:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 978:	00840613          	addi	a2,s0,8
 97c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 980:	85aa                	mv	a1,a0
 982:	4505                	li	a0,1
 984:	cf1ff0ef          	jal	674 <vprintf>
}
 988:	60e2                	ld	ra,24(sp)
 98a:	6442                	ld	s0,16(sp)
 98c:	6125                	addi	sp,sp,96
 98e:	8082                	ret

0000000000000990 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 990:	1141                	addi	sp,sp,-16
 992:	e406                	sd	ra,8(sp)
 994:	e022                	sd	s0,0(sp)
 996:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 998:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 99c:	00000797          	auipc	a5,0x0
 9a0:	6747b783          	ld	a5,1652(a5) # 1010 <freep>
 9a4:	a039                	j	9b2 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9a6:	6398                	ld	a4,0(a5)
 9a8:	00e7e463          	bltu	a5,a4,9b0 <free+0x20>
 9ac:	00e6ea63          	bltu	a3,a4,9c0 <free+0x30>
{
 9b0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9b2:	fed7fae3          	bgeu	a5,a3,9a6 <free+0x16>
 9b6:	6398                	ld	a4,0(a5)
 9b8:	00e6e463          	bltu	a3,a4,9c0 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9bc:	fee7eae3          	bltu	a5,a4,9b0 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 9c0:	ff852583          	lw	a1,-8(a0)
 9c4:	6390                	ld	a2,0(a5)
 9c6:	02059813          	slli	a6,a1,0x20
 9ca:	01c85713          	srli	a4,a6,0x1c
 9ce:	9736                	add	a4,a4,a3
 9d0:	02e60563          	beq	a2,a4,9fa <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 9d4:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 9d8:	4790                	lw	a2,8(a5)
 9da:	02061593          	slli	a1,a2,0x20
 9de:	01c5d713          	srli	a4,a1,0x1c
 9e2:	973e                	add	a4,a4,a5
 9e4:	02e68263          	beq	a3,a4,a08 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 9e8:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 9ea:	00000717          	auipc	a4,0x0
 9ee:	62f73323          	sd	a5,1574(a4) # 1010 <freep>
}
 9f2:	60a2                	ld	ra,8(sp)
 9f4:	6402                	ld	s0,0(sp)
 9f6:	0141                	addi	sp,sp,16
 9f8:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 9fa:	4618                	lw	a4,8(a2)
 9fc:	9f2d                	addw	a4,a4,a1
 9fe:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a02:	6398                	ld	a4,0(a5)
 a04:	6310                	ld	a2,0(a4)
 a06:	b7f9                	j	9d4 <free+0x44>
    p->s.size += bp->s.size;
 a08:	ff852703          	lw	a4,-8(a0)
 a0c:	9f31                	addw	a4,a4,a2
 a0e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 a10:	ff053683          	ld	a3,-16(a0)
 a14:	bfd1                	j	9e8 <free+0x58>

0000000000000a16 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a16:	7139                	addi	sp,sp,-64
 a18:	fc06                	sd	ra,56(sp)
 a1a:	f822                	sd	s0,48(sp)
 a1c:	f04a                	sd	s2,32(sp)
 a1e:	ec4e                	sd	s3,24(sp)
 a20:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a22:	02051993          	slli	s3,a0,0x20
 a26:	0209d993          	srli	s3,s3,0x20
 a2a:	09bd                	addi	s3,s3,15
 a2c:	0049d993          	srli	s3,s3,0x4
 a30:	2985                	addiw	s3,s3,1
 a32:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 a34:	00000517          	auipc	a0,0x0
 a38:	5dc53503          	ld	a0,1500(a0) # 1010 <freep>
 a3c:	c905                	beqz	a0,a6c <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a3e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a40:	4798                	lw	a4,8(a5)
 a42:	09377663          	bgeu	a4,s3,ace <malloc+0xb8>
 a46:	f426                	sd	s1,40(sp)
 a48:	e852                	sd	s4,16(sp)
 a4a:	e456                	sd	s5,8(sp)
 a4c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 a4e:	8a4e                	mv	s4,s3
 a50:	6705                	lui	a4,0x1
 a52:	00e9f363          	bgeu	s3,a4,a58 <malloc+0x42>
 a56:	6a05                	lui	s4,0x1
 a58:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a5c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a60:	00000497          	auipc	s1,0x0
 a64:	5b048493          	addi	s1,s1,1456 # 1010 <freep>
  if(p == SBRK_ERROR)
 a68:	5afd                	li	s5,-1
 a6a:	a83d                	j	aa8 <malloc+0x92>
 a6c:	f426                	sd	s1,40(sp)
 a6e:	e852                	sd	s4,16(sp)
 a70:	e456                	sd	s5,8(sp)
 a72:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a74:	00000797          	auipc	a5,0x0
 a78:	5ac78793          	addi	a5,a5,1452 # 1020 <base>
 a7c:	00000717          	auipc	a4,0x0
 a80:	58f73a23          	sd	a5,1428(a4) # 1010 <freep>
 a84:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a86:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a8a:	b7d1                	j	a4e <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 a8c:	6398                	ld	a4,0(a5)
 a8e:	e118                	sd	a4,0(a0)
 a90:	a899                	j	ae6 <malloc+0xd0>
  hp->s.size = nu;
 a92:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a96:	0541                	addi	a0,a0,16
 a98:	ef9ff0ef          	jal	990 <free>
  return freep;
 a9c:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 a9e:	c125                	beqz	a0,afe <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aa0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 aa2:	4798                	lw	a4,8(a5)
 aa4:	03277163          	bgeu	a4,s2,ac6 <malloc+0xb0>
    if(p == freep)
 aa8:	6098                	ld	a4,0(s1)
 aaa:	853e                	mv	a0,a5
 aac:	fef71ae3          	bne	a4,a5,aa0 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 ab0:	8552                	mv	a0,s4
 ab2:	9f3ff0ef          	jal	4a4 <sbrk>
  if(p == SBRK_ERROR)
 ab6:	fd551ee3          	bne	a0,s5,a92 <malloc+0x7c>
        return 0;
 aba:	4501                	li	a0,0
 abc:	74a2                	ld	s1,40(sp)
 abe:	6a42                	ld	s4,16(sp)
 ac0:	6aa2                	ld	s5,8(sp)
 ac2:	6b02                	ld	s6,0(sp)
 ac4:	a03d                	j	af2 <malloc+0xdc>
 ac6:	74a2                	ld	s1,40(sp)
 ac8:	6a42                	ld	s4,16(sp)
 aca:	6aa2                	ld	s5,8(sp)
 acc:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 ace:	fae90fe3          	beq	s2,a4,a8c <malloc+0x76>
        p->s.size -= nunits;
 ad2:	4137073b          	subw	a4,a4,s3
 ad6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 ad8:	02071693          	slli	a3,a4,0x20
 adc:	01c6d713          	srli	a4,a3,0x1c
 ae0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 ae2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 ae6:	00000717          	auipc	a4,0x0
 aea:	52a73523          	sd	a0,1322(a4) # 1010 <freep>
      return (void*)(p + 1);
 aee:	01078513          	addi	a0,a5,16
  }
}
 af2:	70e2                	ld	ra,56(sp)
 af4:	7442                	ld	s0,48(sp)
 af6:	7902                	ld	s2,32(sp)
 af8:	69e2                	ld	s3,24(sp)
 afa:	6121                	addi	sp,sp,64
 afc:	8082                	ret
 afe:	74a2                	ld	s1,40(sp)
 b00:	6a42                	ld	s4,16(sp)
 b02:	6aa2                	ld	s5,8(sp)
 b04:	6b02                	ld	s6,0(sp)
 b06:	b7f5                	j	af2 <malloc+0xdc>
