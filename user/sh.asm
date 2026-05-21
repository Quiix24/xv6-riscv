
user/_sh:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <getcmd>:
  exit(0);
}

int
getcmd(char *buf, int nbuf)
{
       0:	1101                	addi	sp,sp,-32
       2:	ec06                	sd	ra,24(sp)
       4:	e822                	sd	s0,16(sp)
       6:	e426                	sd	s1,8(sp)
       8:	e04a                	sd	s2,0(sp)
       a:	1000                	addi	s0,sp,32
       c:	84aa                	mv	s1,a0
       e:	892e                	mv	s2,a1
  write(2, "$ ", 2);
      10:	4609                	li	a2,2
      12:	00001597          	auipc	a1,0x1
      16:	2ce58593          	addi	a1,a1,718 # 12e0 <malloc+0xf2>
      1a:	8532                	mv	a0,a2
      1c:	4b5000ef          	jal	cd0 <write>
  memset(buf, 0, nbuf);
      20:	864a                	mv	a2,s2
      22:	4581                	li	a1,0
      24:	8526                	mv	a0,s1
      26:	261000ef          	jal	a86 <memset>
  gets(buf, nbuf);
      2a:	85ca                	mv	a1,s2
      2c:	8526                	mv	a0,s1
      2e:	2a7000ef          	jal	ad4 <gets>
  if(buf[0] == 0) // EOF
      32:	0004c503          	lbu	a0,0(s1)
      36:	00153513          	seqz	a0,a0
    return -1;
  return 0;
}
      3a:	40a0053b          	negw	a0,a0
      3e:	60e2                	ld	ra,24(sp)
      40:	6442                	ld	s0,16(sp)
      42:	64a2                	ld	s1,8(sp)
      44:	6902                	ld	s2,0(sp)
      46:	6105                	addi	sp,sp,32
      48:	8082                	ret

000000000000004a <panic>:
  exit(0);
}

void
panic(char *s)
{
      4a:	1141                	addi	sp,sp,-16
      4c:	e406                	sd	ra,8(sp)
      4e:	e022                	sd	s0,0(sp)
      50:	0800                	addi	s0,sp,16
      52:	862a                	mv	a2,a0
  fprintf(2, "%s\n", s);
      54:	00001597          	auipc	a1,0x1
      58:	29c58593          	addi	a1,a1,668 # 12f0 <malloc+0x102>
      5c:	4509                	li	a0,2
      5e:	0ae010ef          	jal	110c <fprintf>
  exit(1);
      62:	4505                	li	a0,1
      64:	44d000ef          	jal	cb0 <exit>

0000000000000068 <fork1>:
}

int
fork1(void)
{
      68:	1141                	addi	sp,sp,-16
      6a:	e406                	sd	ra,8(sp)
      6c:	e022                	sd	s0,0(sp)
      6e:	0800                	addi	s0,sp,16
  int pid;

  pid = fork();
      70:	439000ef          	jal	ca8 <fork>
  if(pid == -1)
      74:	57fd                	li	a5,-1
      76:	00f50663          	beq	a0,a5,82 <fork1+0x1a>
    panic("fork");
  return pid;
}
      7a:	60a2                	ld	ra,8(sp)
      7c:	6402                	ld	s0,0(sp)
      7e:	0141                	addi	sp,sp,16
      80:	8082                	ret
    panic("fork");
      82:	00001517          	auipc	a0,0x1
      86:	27650513          	addi	a0,a0,630 # 12f8 <malloc+0x10a>
      8a:	fc1ff0ef          	jal	4a <panic>

000000000000008e <runcmd>:
{
      8e:	7179                	addi	sp,sp,-48
      90:	f406                	sd	ra,40(sp)
      92:	f022                	sd	s0,32(sp)
      94:	1800                	addi	s0,sp,48
  if(cmd == 0)
      96:	c115                	beqz	a0,ba <runcmd+0x2c>
      98:	ec26                	sd	s1,24(sp)
      9a:	84aa                	mv	s1,a0
  switch(cmd->type){
      9c:	4118                	lw	a4,0(a0)
      9e:	4795                	li	a5,5
      a0:	02e7e163          	bltu	a5,a4,c2 <runcmd+0x34>
      a4:	00056783          	lwu	a5,0(a0)
      a8:	078a                	slli	a5,a5,0x2
      aa:	00001717          	auipc	a4,0x1
      ae:	35e70713          	addi	a4,a4,862 # 1408 <malloc+0x21a>
      b2:	97ba                	add	a5,a5,a4
      b4:	439c                	lw	a5,0(a5)
      b6:	97ba                	add	a5,a5,a4
      b8:	8782                	jr	a5
      ba:	ec26                	sd	s1,24(sp)
    exit(1);
      bc:	4505                	li	a0,1
      be:	3f3000ef          	jal	cb0 <exit>
    panic("runcmd");
      c2:	00001517          	auipc	a0,0x1
      c6:	23e50513          	addi	a0,a0,574 # 1300 <malloc+0x112>
      ca:	f81ff0ef          	jal	4a <panic>
    if(ecmd->argv[0] == 0)
      ce:	6508                	ld	a0,8(a0)
      d0:	c105                	beqz	a0,f0 <runcmd+0x62>
    exec(ecmd->argv[0], ecmd->argv);
      d2:	00848593          	addi	a1,s1,8
      d6:	413000ef          	jal	ce8 <exec>
    fprintf(2, "exec %s failed\n", ecmd->argv[0]);
      da:	6490                	ld	a2,8(s1)
      dc:	00001597          	auipc	a1,0x1
      e0:	22c58593          	addi	a1,a1,556 # 1308 <malloc+0x11a>
      e4:	4509                	li	a0,2
      e6:	026010ef          	jal	110c <fprintf>
  exit(0);
      ea:	4501                	li	a0,0
      ec:	3c5000ef          	jal	cb0 <exit>
      exit(1);
      f0:	4505                	li	a0,1
      f2:	3bf000ef          	jal	cb0 <exit>
    close(rcmd->fd);
      f6:	5148                	lw	a0,36(a0)
      f8:	3e1000ef          	jal	cd8 <close>
    if(open(rcmd->file, rcmd->mode) < 0){
      fc:	508c                	lw	a1,32(s1)
      fe:	6888                	ld	a0,16(s1)
     100:	3f1000ef          	jal	cf0 <open>
     104:	00054563          	bltz	a0,10e <runcmd+0x80>
    runcmd(rcmd->cmd);
     108:	6488                	ld	a0,8(s1)
     10a:	f85ff0ef          	jal	8e <runcmd>
      fprintf(2, "open %s failed\n", rcmd->file);
     10e:	6890                	ld	a2,16(s1)
     110:	00001597          	auipc	a1,0x1
     114:	20858593          	addi	a1,a1,520 # 1318 <malloc+0x12a>
     118:	4509                	li	a0,2
     11a:	7f3000ef          	jal	110c <fprintf>
      exit(1);
     11e:	4505                	li	a0,1
     120:	391000ef          	jal	cb0 <exit>
    if(fork1() == 0)
     124:	f45ff0ef          	jal	68 <fork1>
     128:	e501                	bnez	a0,130 <runcmd+0xa2>
      runcmd(lcmd->left);
     12a:	6488                	ld	a0,8(s1)
     12c:	f63ff0ef          	jal	8e <runcmd>
    wait(0);
     130:	4501                	li	a0,0
     132:	387000ef          	jal	cb8 <wait>
    runcmd(lcmd->right);
     136:	6888                	ld	a0,16(s1)
     138:	f57ff0ef          	jal	8e <runcmd>
    if(pipe(p) < 0)
     13c:	fd840513          	addi	a0,s0,-40
     140:	381000ef          	jal	cc0 <pipe>
     144:	02054763          	bltz	a0,172 <runcmd+0xe4>
    if(fork1() == 0){
     148:	f21ff0ef          	jal	68 <fork1>
     14c:	e90d                	bnez	a0,17e <runcmd+0xf0>
      close(1);
     14e:	4505                	li	a0,1
     150:	389000ef          	jal	cd8 <close>
      dup(p[1]);
     154:	fdc42503          	lw	a0,-36(s0)
     158:	3d1000ef          	jal	d28 <dup>
      close(p[0]);
     15c:	fd842503          	lw	a0,-40(s0)
     160:	379000ef          	jal	cd8 <close>
      close(p[1]);
     164:	fdc42503          	lw	a0,-36(s0)
     168:	371000ef          	jal	cd8 <close>
      runcmd(pcmd->left);
     16c:	6488                	ld	a0,8(s1)
     16e:	f21ff0ef          	jal	8e <runcmd>
      panic("pipe");
     172:	00001517          	auipc	a0,0x1
     176:	1b650513          	addi	a0,a0,438 # 1328 <malloc+0x13a>
     17a:	ed1ff0ef          	jal	4a <panic>
    if(fork1() == 0){
     17e:	eebff0ef          	jal	68 <fork1>
     182:	e115                	bnez	a0,1a6 <runcmd+0x118>
      close(0);
     184:	355000ef          	jal	cd8 <close>
      dup(p[0]);
     188:	fd842503          	lw	a0,-40(s0)
     18c:	39d000ef          	jal	d28 <dup>
      close(p[0]);
     190:	fd842503          	lw	a0,-40(s0)
     194:	345000ef          	jal	cd8 <close>
      close(p[1]);
     198:	fdc42503          	lw	a0,-36(s0)
     19c:	33d000ef          	jal	cd8 <close>
      runcmd(pcmd->right);
     1a0:	6888                	ld	a0,16(s1)
     1a2:	eedff0ef          	jal	8e <runcmd>
    close(p[0]);
     1a6:	fd842503          	lw	a0,-40(s0)
     1aa:	32f000ef          	jal	cd8 <close>
    close(p[1]);
     1ae:	fdc42503          	lw	a0,-36(s0)
     1b2:	327000ef          	jal	cd8 <close>
    wait(0);
     1b6:	4501                	li	a0,0
     1b8:	301000ef          	jal	cb8 <wait>
    wait(0);
     1bc:	4501                	li	a0,0
     1be:	2fb000ef          	jal	cb8 <wait>
    break;
     1c2:	b725                	j	ea <runcmd+0x5c>
    if(fork1() == 0)
     1c4:	ea5ff0ef          	jal	68 <fork1>
     1c8:	f20511e3          	bnez	a0,ea <runcmd+0x5c>
      runcmd(bcmd->cmd);
     1cc:	6488                	ld	a0,8(s1)
     1ce:	ec1ff0ef          	jal	8e <runcmd>

00000000000001d2 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     1d2:	1101                	addi	sp,sp,-32
     1d4:	ec06                	sd	ra,24(sp)
     1d6:	e822                	sd	s0,16(sp)
     1d8:	e426                	sd	s1,8(sp)
     1da:	1000                	addi	s0,sp,32
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     1dc:	0a800513          	li	a0,168
     1e0:	00e010ef          	jal	11ee <malloc>
     1e4:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     1e6:	0a800613          	li	a2,168
     1ea:	4581                	li	a1,0
     1ec:	09b000ef          	jal	a86 <memset>
  cmd->type = EXEC;
     1f0:	4785                	li	a5,1
     1f2:	c09c                	sw	a5,0(s1)
  return (struct cmd*)cmd;
}
     1f4:	8526                	mv	a0,s1
     1f6:	60e2                	ld	ra,24(sp)
     1f8:	6442                	ld	s0,16(sp)
     1fa:	64a2                	ld	s1,8(sp)
     1fc:	6105                	addi	sp,sp,32
     1fe:	8082                	ret

0000000000000200 <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     200:	7139                	addi	sp,sp,-64
     202:	fc06                	sd	ra,56(sp)
     204:	f822                	sd	s0,48(sp)
     206:	f426                	sd	s1,40(sp)
     208:	f04a                	sd	s2,32(sp)
     20a:	ec4e                	sd	s3,24(sp)
     20c:	e852                	sd	s4,16(sp)
     20e:	e456                	sd	s5,8(sp)
     210:	e05a                	sd	s6,0(sp)
     212:	0080                	addi	s0,sp,64
     214:	892a                	mv	s2,a0
     216:	89ae                	mv	s3,a1
     218:	8a32                	mv	s4,a2
     21a:	8ab6                	mv	s5,a3
     21c:	8b3a                	mv	s6,a4
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     21e:	02800513          	li	a0,40
     222:	7cd000ef          	jal	11ee <malloc>
     226:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     228:	02800613          	li	a2,40
     22c:	4581                	li	a1,0
     22e:	059000ef          	jal	a86 <memset>
  cmd->type = REDIR;
     232:	4789                	li	a5,2
     234:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     236:	0124b423          	sd	s2,8(s1)
  cmd->file = file;
     23a:	0134b823          	sd	s3,16(s1)
  cmd->efile = efile;
     23e:	0144bc23          	sd	s4,24(s1)
  cmd->mode = mode;
     242:	0354a023          	sw	s5,32(s1)
  cmd->fd = fd;
     246:	0364a223          	sw	s6,36(s1)
  return (struct cmd*)cmd;
}
     24a:	8526                	mv	a0,s1
     24c:	70e2                	ld	ra,56(sp)
     24e:	7442                	ld	s0,48(sp)
     250:	74a2                	ld	s1,40(sp)
     252:	7902                	ld	s2,32(sp)
     254:	69e2                	ld	s3,24(sp)
     256:	6a42                	ld	s4,16(sp)
     258:	6aa2                	ld	s5,8(sp)
     25a:	6b02                	ld	s6,0(sp)
     25c:	6121                	addi	sp,sp,64
     25e:	8082                	ret

0000000000000260 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     260:	7179                	addi	sp,sp,-48
     262:	f406                	sd	ra,40(sp)
     264:	f022                	sd	s0,32(sp)
     266:	ec26                	sd	s1,24(sp)
     268:	e84a                	sd	s2,16(sp)
     26a:	e44e                	sd	s3,8(sp)
     26c:	1800                	addi	s0,sp,48
     26e:	892a                	mv	s2,a0
     270:	89ae                	mv	s3,a1
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     272:	4561                	li	a0,24
     274:	77b000ef          	jal	11ee <malloc>
     278:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     27a:	4661                	li	a2,24
     27c:	4581                	li	a1,0
     27e:	009000ef          	jal	a86 <memset>
  cmd->type = PIPE;
     282:	478d                	li	a5,3
     284:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     286:	0124b423          	sd	s2,8(s1)
  cmd->right = right;
     28a:	0134b823          	sd	s3,16(s1)
  return (struct cmd*)cmd;
}
     28e:	8526                	mv	a0,s1
     290:	70a2                	ld	ra,40(sp)
     292:	7402                	ld	s0,32(sp)
     294:	64e2                	ld	s1,24(sp)
     296:	6942                	ld	s2,16(sp)
     298:	69a2                	ld	s3,8(sp)
     29a:	6145                	addi	sp,sp,48
     29c:	8082                	ret

000000000000029e <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     29e:	7179                	addi	sp,sp,-48
     2a0:	f406                	sd	ra,40(sp)
     2a2:	f022                	sd	s0,32(sp)
     2a4:	ec26                	sd	s1,24(sp)
     2a6:	e84a                	sd	s2,16(sp)
     2a8:	e44e                	sd	s3,8(sp)
     2aa:	1800                	addi	s0,sp,48
     2ac:	892a                	mv	s2,a0
     2ae:	89ae                	mv	s3,a1
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     2b0:	4561                	li	a0,24
     2b2:	73d000ef          	jal	11ee <malloc>
     2b6:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     2b8:	4661                	li	a2,24
     2ba:	4581                	li	a1,0
     2bc:	7ca000ef          	jal	a86 <memset>
  cmd->type = LIST;
     2c0:	4791                	li	a5,4
     2c2:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     2c4:	0124b423          	sd	s2,8(s1)
  cmd->right = right;
     2c8:	0134b823          	sd	s3,16(s1)
  return (struct cmd*)cmd;
}
     2cc:	8526                	mv	a0,s1
     2ce:	70a2                	ld	ra,40(sp)
     2d0:	7402                	ld	s0,32(sp)
     2d2:	64e2                	ld	s1,24(sp)
     2d4:	6942                	ld	s2,16(sp)
     2d6:	69a2                	ld	s3,8(sp)
     2d8:	6145                	addi	sp,sp,48
     2da:	8082                	ret

00000000000002dc <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     2dc:	1101                	addi	sp,sp,-32
     2de:	ec06                	sd	ra,24(sp)
     2e0:	e822                	sd	s0,16(sp)
     2e2:	e426                	sd	s1,8(sp)
     2e4:	e04a                	sd	s2,0(sp)
     2e6:	1000                	addi	s0,sp,32
     2e8:	892a                	mv	s2,a0
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     2ea:	4541                	li	a0,16
     2ec:	703000ef          	jal	11ee <malloc>
     2f0:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     2f2:	4641                	li	a2,16
     2f4:	4581                	li	a1,0
     2f6:	790000ef          	jal	a86 <memset>
  cmd->type = BACK;
     2fa:	4795                	li	a5,5
     2fc:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     2fe:	0124b423          	sd	s2,8(s1)
  return (struct cmd*)cmd;
}
     302:	8526                	mv	a0,s1
     304:	60e2                	ld	ra,24(sp)
     306:	6442                	ld	s0,16(sp)
     308:	64a2                	ld	s1,8(sp)
     30a:	6902                	ld	s2,0(sp)
     30c:	6105                	addi	sp,sp,32
     30e:	8082                	ret

0000000000000310 <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     310:	7139                	addi	sp,sp,-64
     312:	fc06                	sd	ra,56(sp)
     314:	f822                	sd	s0,48(sp)
     316:	f426                	sd	s1,40(sp)
     318:	f04a                	sd	s2,32(sp)
     31a:	ec4e                	sd	s3,24(sp)
     31c:	e852                	sd	s4,16(sp)
     31e:	e456                	sd	s5,8(sp)
     320:	e05a                	sd	s6,0(sp)
     322:	0080                	addi	s0,sp,64
     324:	8a2a                	mv	s4,a0
     326:	892e                	mv	s2,a1
     328:	8ab2                	mv	s5,a2
     32a:	8b36                	mv	s6,a3
  char *s;
  int ret;

  s = *ps;
     32c:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     32e:	00002997          	auipc	s3,0x2
     332:	cda98993          	addi	s3,s3,-806 # 2008 <whitespace>
     336:	00b4fc63          	bgeu	s1,a1,34e <gettoken+0x3e>
     33a:	0004c583          	lbu	a1,0(s1)
     33e:	854e                	mv	a0,s3
     340:	76c000ef          	jal	aac <strchr>
     344:	c509                	beqz	a0,34e <gettoken+0x3e>
    s++;
     346:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     348:	fe9919e3          	bne	s2,s1,33a <gettoken+0x2a>
     34c:	84ca                	mv	s1,s2
  if(q)
     34e:	000a8463          	beqz	s5,356 <gettoken+0x46>
    *q = s;
     352:	009ab023          	sd	s1,0(s5)
  ret = *s;
     356:	0004c783          	lbu	a5,0(s1)
     35a:	00078a9b          	sext.w	s5,a5
  switch(*s){
     35e:	03c00713          	li	a4,60
     362:	06f76463          	bltu	a4,a5,3ca <gettoken+0xba>
     366:	03a00713          	li	a4,58
     36a:	00f76e63          	bltu	a4,a5,386 <gettoken+0x76>
     36e:	cf89                	beqz	a5,388 <gettoken+0x78>
     370:	02600713          	li	a4,38
     374:	00e78963          	beq	a5,a4,386 <gettoken+0x76>
     378:	fd87879b          	addiw	a5,a5,-40
     37c:	0ff7f793          	zext.b	a5,a5
     380:	4705                	li	a4,1
     382:	06f76563          	bltu	a4,a5,3ec <gettoken+0xdc>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     386:	0485                	addi	s1,s1,1
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
  }
  if(eq)
     388:	000b0463          	beqz	s6,390 <gettoken+0x80>
    *eq = s;
     38c:	009b3023          	sd	s1,0(s6)

  while(s < es && strchr(whitespace, *s))
     390:	00002997          	auipc	s3,0x2
     394:	c7898993          	addi	s3,s3,-904 # 2008 <whitespace>
     398:	0124fc63          	bgeu	s1,s2,3b0 <gettoken+0xa0>
     39c:	0004c583          	lbu	a1,0(s1)
     3a0:	854e                	mv	a0,s3
     3a2:	70a000ef          	jal	aac <strchr>
     3a6:	c509                	beqz	a0,3b0 <gettoken+0xa0>
    s++;
     3a8:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     3aa:	fe9919e3          	bne	s2,s1,39c <gettoken+0x8c>
     3ae:	84ca                	mv	s1,s2
  *ps = s;
     3b0:	009a3023          	sd	s1,0(s4)
  return ret;
}
     3b4:	8556                	mv	a0,s5
     3b6:	70e2                	ld	ra,56(sp)
     3b8:	7442                	ld	s0,48(sp)
     3ba:	74a2                	ld	s1,40(sp)
     3bc:	7902                	ld	s2,32(sp)
     3be:	69e2                	ld	s3,24(sp)
     3c0:	6a42                	ld	s4,16(sp)
     3c2:	6aa2                	ld	s5,8(sp)
     3c4:	6b02                	ld	s6,0(sp)
     3c6:	6121                	addi	sp,sp,64
     3c8:	8082                	ret
  switch(*s){
     3ca:	03e00713          	li	a4,62
     3ce:	00e79b63          	bne	a5,a4,3e4 <gettoken+0xd4>
    if(*s == '>'){
     3d2:	0014c703          	lbu	a4,1(s1)
     3d6:	03e00793          	li	a5,62
     3da:	04f70863          	beq	a4,a5,42a <gettoken+0x11a>
    s++;
     3de:	0485                	addi	s1,s1,1
  ret = *s;
     3e0:	8abe                	mv	s5,a5
     3e2:	b75d                	j	388 <gettoken+0x78>
  switch(*s){
     3e4:	07c00713          	li	a4,124
     3e8:	f8e78fe3          	beq	a5,a4,386 <gettoken+0x76>
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     3ec:	00002997          	auipc	s3,0x2
     3f0:	c1c98993          	addi	s3,s3,-996 # 2008 <whitespace>
     3f4:	00002a97          	auipc	s5,0x2
     3f8:	c0ca8a93          	addi	s5,s5,-1012 # 2000 <symbols>
     3fc:	0524f163          	bgeu	s1,s2,43e <gettoken+0x12e>
     400:	0004c583          	lbu	a1,0(s1)
     404:	854e                	mv	a0,s3
     406:	6a6000ef          	jal	aac <strchr>
     40a:	e51d                	bnez	a0,438 <gettoken+0x128>
     40c:	0004c583          	lbu	a1,0(s1)
     410:	8556                	mv	a0,s5
     412:	69a000ef          	jal	aac <strchr>
     416:	ed11                	bnez	a0,432 <gettoken+0x122>
      s++;
     418:	0485                	addi	s1,s1,1
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     41a:	fe9913e3          	bne	s2,s1,400 <gettoken+0xf0>
  if(eq)
     41e:	84ca                	mv	s1,s2
    ret = 'a';
     420:	06100a93          	li	s5,97
  if(eq)
     424:	f60b14e3          	bnez	s6,38c <gettoken+0x7c>
     428:	b761                	j	3b0 <gettoken+0xa0>
      s++;
     42a:	0489                	addi	s1,s1,2
      ret = '+';
     42c:	02b00a93          	li	s5,43
     430:	bfa1                	j	388 <gettoken+0x78>
    ret = 'a';
     432:	06100a93          	li	s5,97
     436:	bf89                	j	388 <gettoken+0x78>
     438:	06100a93          	li	s5,97
     43c:	b7b1                	j	388 <gettoken+0x78>
     43e:	06100a93          	li	s5,97
  if(eq)
     442:	f40b15e3          	bnez	s6,38c <gettoken+0x7c>
     446:	b7ad                	j	3b0 <gettoken+0xa0>

0000000000000448 <peek>:

int
peek(char **ps, char *es, char *toks)
{
     448:	7139                	addi	sp,sp,-64
     44a:	fc06                	sd	ra,56(sp)
     44c:	f822                	sd	s0,48(sp)
     44e:	f426                	sd	s1,40(sp)
     450:	f04a                	sd	s2,32(sp)
     452:	ec4e                	sd	s3,24(sp)
     454:	e852                	sd	s4,16(sp)
     456:	e456                	sd	s5,8(sp)
     458:	0080                	addi	s0,sp,64
     45a:	8a2a                	mv	s4,a0
     45c:	892e                	mv	s2,a1
     45e:	8ab2                	mv	s5,a2
  char *s;

  s = *ps;
     460:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     462:	00002997          	auipc	s3,0x2
     466:	ba698993          	addi	s3,s3,-1114 # 2008 <whitespace>
     46a:	00b4fc63          	bgeu	s1,a1,482 <peek+0x3a>
     46e:	0004c583          	lbu	a1,0(s1)
     472:	854e                	mv	a0,s3
     474:	638000ef          	jal	aac <strchr>
     478:	c509                	beqz	a0,482 <peek+0x3a>
    s++;
     47a:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     47c:	fe9919e3          	bne	s2,s1,46e <peek+0x26>
     480:	84ca                	mv	s1,s2
  *ps = s;
     482:	009a3023          	sd	s1,0(s4)
  return *s && strchr(toks, *s);
     486:	0004c583          	lbu	a1,0(s1)
     48a:	4501                	li	a0,0
     48c:	e991                	bnez	a1,4a0 <peek+0x58>
}
     48e:	70e2                	ld	ra,56(sp)
     490:	7442                	ld	s0,48(sp)
     492:	74a2                	ld	s1,40(sp)
     494:	7902                	ld	s2,32(sp)
     496:	69e2                	ld	s3,24(sp)
     498:	6a42                	ld	s4,16(sp)
     49a:	6aa2                	ld	s5,8(sp)
     49c:	6121                	addi	sp,sp,64
     49e:	8082                	ret
  return *s && strchr(toks, *s);
     4a0:	8556                	mv	a0,s5
     4a2:	60a000ef          	jal	aac <strchr>
     4a6:	00a03533          	snez	a0,a0
     4aa:	b7d5                	j	48e <peek+0x46>

00000000000004ac <parseredirs>:
  return cmd;
}

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     4ac:	7159                	addi	sp,sp,-112
     4ae:	f486                	sd	ra,104(sp)
     4b0:	f0a2                	sd	s0,96(sp)
     4b2:	eca6                	sd	s1,88(sp)
     4b4:	e8ca                	sd	s2,80(sp)
     4b6:	e4ce                	sd	s3,72(sp)
     4b8:	e0d2                	sd	s4,64(sp)
     4ba:	fc56                	sd	s5,56(sp)
     4bc:	f85a                	sd	s6,48(sp)
     4be:	f45e                	sd	s7,40(sp)
     4c0:	f062                	sd	s8,32(sp)
     4c2:	ec66                	sd	s9,24(sp)
     4c4:	1880                	addi	s0,sp,112
     4c6:	8a2a                	mv	s4,a0
     4c8:	89ae                	mv	s3,a1
     4ca:	8932                	mv	s2,a2
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     4cc:	00001b17          	auipc	s6,0x1
     4d0:	e84b0b13          	addi	s6,s6,-380 # 1350 <malloc+0x162>
    tok = gettoken(ps, es, 0, 0);
    if(gettoken(ps, es, &q, &eq) != 'a')
     4d4:	f9040c93          	addi	s9,s0,-112
     4d8:	f9840c13          	addi	s8,s0,-104
     4dc:	06100b93          	li	s7,97
  while(peek(ps, es, "<>")){
     4e0:	a00d                	j	502 <parseredirs+0x56>
      panic("missing file for redirection");
     4e2:	00001517          	auipc	a0,0x1
     4e6:	e4e50513          	addi	a0,a0,-434 # 1330 <malloc+0x142>
     4ea:	b61ff0ef          	jal	4a <panic>
    switch(tok){
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     4ee:	4701                	li	a4,0
     4f0:	4681                	li	a3,0
     4f2:	f9043603          	ld	a2,-112(s0)
     4f6:	f9843583          	ld	a1,-104(s0)
     4fa:	8552                	mv	a0,s4
     4fc:	d05ff0ef          	jal	200 <redircmd>
     500:	8a2a                	mv	s4,a0
    switch(tok){
     502:	03c00a93          	li	s5,60
  while(peek(ps, es, "<>")){
     506:	865a                	mv	a2,s6
     508:	85ca                	mv	a1,s2
     50a:	854e                	mv	a0,s3
     50c:	f3dff0ef          	jal	448 <peek>
     510:	c135                	beqz	a0,574 <parseredirs+0xc8>
    tok = gettoken(ps, es, 0, 0);
     512:	4681                	li	a3,0
     514:	4601                	li	a2,0
     516:	85ca                	mv	a1,s2
     518:	854e                	mv	a0,s3
     51a:	df7ff0ef          	jal	310 <gettoken>
     51e:	84aa                	mv	s1,a0
    if(gettoken(ps, es, &q, &eq) != 'a')
     520:	86e6                	mv	a3,s9
     522:	8662                	mv	a2,s8
     524:	85ca                	mv	a1,s2
     526:	854e                	mv	a0,s3
     528:	de9ff0ef          	jal	310 <gettoken>
     52c:	fb751be3          	bne	a0,s7,4e2 <parseredirs+0x36>
    switch(tok){
     530:	fb548fe3          	beq	s1,s5,4ee <parseredirs+0x42>
     534:	03e00793          	li	a5,62
     538:	02f48263          	beq	s1,a5,55c <parseredirs+0xb0>
     53c:	02b00793          	li	a5,43
     540:	fcf493e3          	bne	s1,a5,506 <parseredirs+0x5a>
      break;
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
      break;
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     544:	4705                	li	a4,1
     546:	20100693          	li	a3,513
     54a:	f9043603          	ld	a2,-112(s0)
     54e:	f9843583          	ld	a1,-104(s0)
     552:	8552                	mv	a0,s4
     554:	cadff0ef          	jal	200 <redircmd>
     558:	8a2a                	mv	s4,a0
      break;
     55a:	b765                	j	502 <parseredirs+0x56>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
     55c:	4705                	li	a4,1
     55e:	60100693          	li	a3,1537
     562:	f9043603          	ld	a2,-112(s0)
     566:	f9843583          	ld	a1,-104(s0)
     56a:	8552                	mv	a0,s4
     56c:	c95ff0ef          	jal	200 <redircmd>
     570:	8a2a                	mv	s4,a0
      break;
     572:	bf41                	j	502 <parseredirs+0x56>
    }
  }
  return cmd;
}
     574:	8552                	mv	a0,s4
     576:	70a6                	ld	ra,104(sp)
     578:	7406                	ld	s0,96(sp)
     57a:	64e6                	ld	s1,88(sp)
     57c:	6946                	ld	s2,80(sp)
     57e:	69a6                	ld	s3,72(sp)
     580:	6a06                	ld	s4,64(sp)
     582:	7ae2                	ld	s5,56(sp)
     584:	7b42                	ld	s6,48(sp)
     586:	7ba2                	ld	s7,40(sp)
     588:	7c02                	ld	s8,32(sp)
     58a:	6ce2                	ld	s9,24(sp)
     58c:	6165                	addi	sp,sp,112
     58e:	8082                	ret

0000000000000590 <parseexec>:
  return cmd;
}

struct cmd*
parseexec(char **ps, char *es)
{
     590:	7119                	addi	sp,sp,-128
     592:	fc86                	sd	ra,120(sp)
     594:	f8a2                	sd	s0,112(sp)
     596:	f4a6                	sd	s1,104(sp)
     598:	e8d2                	sd	s4,80(sp)
     59a:	e4d6                	sd	s5,72(sp)
     59c:	0100                	addi	s0,sp,128
     59e:	8a2a                	mv	s4,a0
     5a0:	8aae                	mv	s5,a1
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
     5a2:	00001617          	auipc	a2,0x1
     5a6:	db660613          	addi	a2,a2,-586 # 1358 <malloc+0x16a>
     5aa:	e9fff0ef          	jal	448 <peek>
     5ae:	e121                	bnez	a0,5ee <parseexec+0x5e>
     5b0:	f0ca                	sd	s2,96(sp)
     5b2:	ecce                	sd	s3,88(sp)
     5b4:	e0da                	sd	s6,64(sp)
     5b6:	fc5e                	sd	s7,56(sp)
     5b8:	f862                	sd	s8,48(sp)
     5ba:	f466                	sd	s9,40(sp)
     5bc:	f06a                	sd	s10,32(sp)
     5be:	ec6e                	sd	s11,24(sp)
     5c0:	892a                	mv	s2,a0
    return parseblock(ps, es);

  ret = execcmd();
     5c2:	c11ff0ef          	jal	1d2 <execcmd>
     5c6:	89aa                	mv	s3,a0
     5c8:	8daa                	mv	s11,a0
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
     5ca:	8656                	mv	a2,s5
     5cc:	85d2                	mv	a1,s4
     5ce:	edfff0ef          	jal	4ac <parseredirs>
     5d2:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     5d4:	09a1                	addi	s3,s3,8
     5d6:	00001b17          	auipc	s6,0x1
     5da:	da2b0b13          	addi	s6,s6,-606 # 1378 <malloc+0x18a>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     5de:	f8040c13          	addi	s8,s0,-128
     5e2:	f8840b93          	addi	s7,s0,-120
      break;
    if(tok != 'a')
     5e6:	06100d13          	li	s10,97
      panic("syntax");
    cmd->argv[argc] = q;
    cmd->eargv[argc] = eq;
    argc++;
    if(argc >= MAXARGS)
     5ea:	4ca9                	li	s9,10
  while(!peek(ps, es, "|)&;")){
     5ec:	a81d                	j	622 <parseexec+0x92>
    return parseblock(ps, es);
     5ee:	85d6                	mv	a1,s5
     5f0:	8552                	mv	a0,s4
     5f2:	178000ef          	jal	76a <parseblock>
     5f6:	84aa                	mv	s1,a0
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
  cmd->eargv[argc] = 0;
  return ret;
}
     5f8:	8526                	mv	a0,s1
     5fa:	70e6                	ld	ra,120(sp)
     5fc:	7446                	ld	s0,112(sp)
     5fe:	74a6                	ld	s1,104(sp)
     600:	6a46                	ld	s4,80(sp)
     602:	6aa6                	ld	s5,72(sp)
     604:	6109                	addi	sp,sp,128
     606:	8082                	ret
      panic("syntax");
     608:	00001517          	auipc	a0,0x1
     60c:	d5850513          	addi	a0,a0,-680 # 1360 <malloc+0x172>
     610:	a3bff0ef          	jal	4a <panic>
    if(argc >= MAXARGS)
     614:	09a1                	addi	s3,s3,8
    ret = parseredirs(ret, ps, es);
     616:	8656                	mv	a2,s5
     618:	85d2                	mv	a1,s4
     61a:	8526                	mv	a0,s1
     61c:	e91ff0ef          	jal	4ac <parseredirs>
     620:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     622:	865a                	mv	a2,s6
     624:	85d6                	mv	a1,s5
     626:	8552                	mv	a0,s4
     628:	e21ff0ef          	jal	448 <peek>
     62c:	e91d                	bnez	a0,662 <parseexec+0xd2>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     62e:	86e2                	mv	a3,s8
     630:	865e                	mv	a2,s7
     632:	85d6                	mv	a1,s5
     634:	8552                	mv	a0,s4
     636:	cdbff0ef          	jal	310 <gettoken>
     63a:	c505                	beqz	a0,662 <parseexec+0xd2>
    if(tok != 'a')
     63c:	fda516e3          	bne	a0,s10,608 <parseexec+0x78>
    cmd->argv[argc] = q;
     640:	f8843783          	ld	a5,-120(s0)
     644:	00f9b023          	sd	a5,0(s3)
    cmd->eargv[argc] = eq;
     648:	f8043783          	ld	a5,-128(s0)
     64c:	04f9b823          	sd	a5,80(s3)
    argc++;
     650:	2905                	addiw	s2,s2,1
    if(argc >= MAXARGS)
     652:	fd9911e3          	bne	s2,s9,614 <parseexec+0x84>
      panic("too many args");
     656:	00001517          	auipc	a0,0x1
     65a:	d1250513          	addi	a0,a0,-750 # 1368 <malloc+0x17a>
     65e:	9edff0ef          	jal	4a <panic>
  cmd->argv[argc] = 0;
     662:	090e                	slli	s2,s2,0x3
     664:	012d87b3          	add	a5,s11,s2
     668:	0007b423          	sd	zero,8(a5)
  cmd->eargv[argc] = 0;
     66c:	0407bc23          	sd	zero,88(a5)
     670:	7906                	ld	s2,96(sp)
     672:	69e6                	ld	s3,88(sp)
     674:	6b06                	ld	s6,64(sp)
     676:	7be2                	ld	s7,56(sp)
     678:	7c42                	ld	s8,48(sp)
     67a:	7ca2                	ld	s9,40(sp)
     67c:	7d02                	ld	s10,32(sp)
     67e:	6de2                	ld	s11,24(sp)
  return ret;
     680:	bfa5                	j	5f8 <parseexec+0x68>

0000000000000682 <parsepipe>:
{
     682:	7179                	addi	sp,sp,-48
     684:	f406                	sd	ra,40(sp)
     686:	f022                	sd	s0,32(sp)
     688:	ec26                	sd	s1,24(sp)
     68a:	e84a                	sd	s2,16(sp)
     68c:	e44e                	sd	s3,8(sp)
     68e:	e052                	sd	s4,0(sp)
     690:	1800                	addi	s0,sp,48
     692:	892a                	mv	s2,a0
     694:	8a2a                	mv	s4,a0
     696:	84ae                	mv	s1,a1
  cmd = parseexec(ps, es);
     698:	ef9ff0ef          	jal	590 <parseexec>
     69c:	89aa                	mv	s3,a0
  if(peek(ps, es, "|")){
     69e:	00001617          	auipc	a2,0x1
     6a2:	ce260613          	addi	a2,a2,-798 # 1380 <malloc+0x192>
     6a6:	85a6                	mv	a1,s1
     6a8:	854a                	mv	a0,s2
     6aa:	d9fff0ef          	jal	448 <peek>
     6ae:	e911                	bnez	a0,6c2 <parsepipe+0x40>
}
     6b0:	854e                	mv	a0,s3
     6b2:	70a2                	ld	ra,40(sp)
     6b4:	7402                	ld	s0,32(sp)
     6b6:	64e2                	ld	s1,24(sp)
     6b8:	6942                	ld	s2,16(sp)
     6ba:	69a2                	ld	s3,8(sp)
     6bc:	6a02                	ld	s4,0(sp)
     6be:	6145                	addi	sp,sp,48
     6c0:	8082                	ret
    gettoken(ps, es, 0, 0);
     6c2:	4681                	li	a3,0
     6c4:	4601                	li	a2,0
     6c6:	85a6                	mv	a1,s1
     6c8:	8552                	mv	a0,s4
     6ca:	c47ff0ef          	jal	310 <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     6ce:	85a6                	mv	a1,s1
     6d0:	8552                	mv	a0,s4
     6d2:	fb1ff0ef          	jal	682 <parsepipe>
     6d6:	85aa                	mv	a1,a0
     6d8:	854e                	mv	a0,s3
     6da:	b87ff0ef          	jal	260 <pipecmd>
     6de:	89aa                	mv	s3,a0
  return cmd;
     6e0:	bfc1                	j	6b0 <parsepipe+0x2e>

00000000000006e2 <parseline>:
{
     6e2:	7179                	addi	sp,sp,-48
     6e4:	f406                	sd	ra,40(sp)
     6e6:	f022                	sd	s0,32(sp)
     6e8:	ec26                	sd	s1,24(sp)
     6ea:	e84a                	sd	s2,16(sp)
     6ec:	e44e                	sd	s3,8(sp)
     6ee:	e052                	sd	s4,0(sp)
     6f0:	1800                	addi	s0,sp,48
     6f2:	892a                	mv	s2,a0
     6f4:	89ae                	mv	s3,a1
  cmd = parsepipe(ps, es);
     6f6:	f8dff0ef          	jal	682 <parsepipe>
     6fa:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     6fc:	00001a17          	auipc	s4,0x1
     700:	c8ca0a13          	addi	s4,s4,-884 # 1388 <malloc+0x19a>
     704:	a819                	j	71a <parseline+0x38>
    gettoken(ps, es, 0, 0);
     706:	4681                	li	a3,0
     708:	4601                	li	a2,0
     70a:	85ce                	mv	a1,s3
     70c:	854a                	mv	a0,s2
     70e:	c03ff0ef          	jal	310 <gettoken>
    cmd = backcmd(cmd);
     712:	8526                	mv	a0,s1
     714:	bc9ff0ef          	jal	2dc <backcmd>
     718:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     71a:	8652                	mv	a2,s4
     71c:	85ce                	mv	a1,s3
     71e:	854a                	mv	a0,s2
     720:	d29ff0ef          	jal	448 <peek>
     724:	f16d                	bnez	a0,706 <parseline+0x24>
  if(peek(ps, es, ";")){
     726:	00001617          	auipc	a2,0x1
     72a:	c6a60613          	addi	a2,a2,-918 # 1390 <malloc+0x1a2>
     72e:	85ce                	mv	a1,s3
     730:	854a                	mv	a0,s2
     732:	d17ff0ef          	jal	448 <peek>
     736:	e911                	bnez	a0,74a <parseline+0x68>
}
     738:	8526                	mv	a0,s1
     73a:	70a2                	ld	ra,40(sp)
     73c:	7402                	ld	s0,32(sp)
     73e:	64e2                	ld	s1,24(sp)
     740:	6942                	ld	s2,16(sp)
     742:	69a2                	ld	s3,8(sp)
     744:	6a02                	ld	s4,0(sp)
     746:	6145                	addi	sp,sp,48
     748:	8082                	ret
    gettoken(ps, es, 0, 0);
     74a:	4681                	li	a3,0
     74c:	4601                	li	a2,0
     74e:	85ce                	mv	a1,s3
     750:	854a                	mv	a0,s2
     752:	bbfff0ef          	jal	310 <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     756:	85ce                	mv	a1,s3
     758:	854a                	mv	a0,s2
     75a:	f89ff0ef          	jal	6e2 <parseline>
     75e:	85aa                	mv	a1,a0
     760:	8526                	mv	a0,s1
     762:	b3dff0ef          	jal	29e <listcmd>
     766:	84aa                	mv	s1,a0
  return cmd;
     768:	bfc1                	j	738 <parseline+0x56>

000000000000076a <parseblock>:
{
     76a:	7179                	addi	sp,sp,-48
     76c:	f406                	sd	ra,40(sp)
     76e:	f022                	sd	s0,32(sp)
     770:	ec26                	sd	s1,24(sp)
     772:	e84a                	sd	s2,16(sp)
     774:	e44e                	sd	s3,8(sp)
     776:	1800                	addi	s0,sp,48
     778:	84aa                	mv	s1,a0
     77a:	892e                	mv	s2,a1
  if(!peek(ps, es, "("))
     77c:	00001617          	auipc	a2,0x1
     780:	bdc60613          	addi	a2,a2,-1060 # 1358 <malloc+0x16a>
     784:	cc5ff0ef          	jal	448 <peek>
     788:	c539                	beqz	a0,7d6 <parseblock+0x6c>
  gettoken(ps, es, 0, 0);
     78a:	4681                	li	a3,0
     78c:	4601                	li	a2,0
     78e:	85ca                	mv	a1,s2
     790:	8526                	mv	a0,s1
     792:	b7fff0ef          	jal	310 <gettoken>
  cmd = parseline(ps, es);
     796:	85ca                	mv	a1,s2
     798:	8526                	mv	a0,s1
     79a:	f49ff0ef          	jal	6e2 <parseline>
     79e:	89aa                	mv	s3,a0
  if(!peek(ps, es, ")"))
     7a0:	00001617          	auipc	a2,0x1
     7a4:	c0860613          	addi	a2,a2,-1016 # 13a8 <malloc+0x1ba>
     7a8:	85ca                	mv	a1,s2
     7aa:	8526                	mv	a0,s1
     7ac:	c9dff0ef          	jal	448 <peek>
     7b0:	c90d                	beqz	a0,7e2 <parseblock+0x78>
  gettoken(ps, es, 0, 0);
     7b2:	4681                	li	a3,0
     7b4:	4601                	li	a2,0
     7b6:	85ca                	mv	a1,s2
     7b8:	8526                	mv	a0,s1
     7ba:	b57ff0ef          	jal	310 <gettoken>
  cmd = parseredirs(cmd, ps, es);
     7be:	864a                	mv	a2,s2
     7c0:	85a6                	mv	a1,s1
     7c2:	854e                	mv	a0,s3
     7c4:	ce9ff0ef          	jal	4ac <parseredirs>
}
     7c8:	70a2                	ld	ra,40(sp)
     7ca:	7402                	ld	s0,32(sp)
     7cc:	64e2                	ld	s1,24(sp)
     7ce:	6942                	ld	s2,16(sp)
     7d0:	69a2                	ld	s3,8(sp)
     7d2:	6145                	addi	sp,sp,48
     7d4:	8082                	ret
    panic("parseblock");
     7d6:	00001517          	auipc	a0,0x1
     7da:	bc250513          	addi	a0,a0,-1086 # 1398 <malloc+0x1aa>
     7de:	86dff0ef          	jal	4a <panic>
    panic("syntax - missing )");
     7e2:	00001517          	auipc	a0,0x1
     7e6:	bce50513          	addi	a0,a0,-1074 # 13b0 <malloc+0x1c2>
     7ea:	861ff0ef          	jal	4a <panic>

00000000000007ee <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     7ee:	1101                	addi	sp,sp,-32
     7f0:	ec06                	sd	ra,24(sp)
     7f2:	e822                	sd	s0,16(sp)
     7f4:	e426                	sd	s1,8(sp)
     7f6:	1000                	addi	s0,sp,32
     7f8:	84aa                	mv	s1,a0
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     7fa:	c131                	beqz	a0,83e <nulterminate+0x50>
    return 0;

  switch(cmd->type){
     7fc:	4118                	lw	a4,0(a0)
     7fe:	4795                	li	a5,5
     800:	02e7ef63          	bltu	a5,a4,83e <nulterminate+0x50>
     804:	00056783          	lwu	a5,0(a0)
     808:	078a                	slli	a5,a5,0x2
     80a:	00001717          	auipc	a4,0x1
     80e:	c1670713          	addi	a4,a4,-1002 # 1420 <malloc+0x232>
     812:	97ba                	add	a5,a5,a4
     814:	439c                	lw	a5,0(a5)
     816:	97ba                	add	a5,a5,a4
     818:	8782                	jr	a5
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     81a:	651c                	ld	a5,8(a0)
     81c:	c38d                	beqz	a5,83e <nulterminate+0x50>
     81e:	01050793          	addi	a5,a0,16
      *ecmd->eargv[i] = 0;
     822:	67b8                	ld	a4,72(a5)
     824:	00070023          	sb	zero,0(a4)
    for(i=0; ecmd->argv[i]; i++)
     828:	07a1                	addi	a5,a5,8
     82a:	ff87b703          	ld	a4,-8(a5)
     82e:	fb75                	bnez	a4,822 <nulterminate+0x34>
     830:	a039                	j	83e <nulterminate+0x50>
    break;

  case REDIR:
    rcmd = (struct redircmd*)cmd;
    nulterminate(rcmd->cmd);
     832:	6508                	ld	a0,8(a0)
     834:	fbbff0ef          	jal	7ee <nulterminate>
    *rcmd->efile = 0;
     838:	6c9c                	ld	a5,24(s1)
     83a:	00078023          	sb	zero,0(a5)
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
    break;
  }
  return cmd;
}
     83e:	8526                	mv	a0,s1
     840:	60e2                	ld	ra,24(sp)
     842:	6442                	ld	s0,16(sp)
     844:	64a2                	ld	s1,8(sp)
     846:	6105                	addi	sp,sp,32
     848:	8082                	ret
    nulterminate(pcmd->left);
     84a:	6508                	ld	a0,8(a0)
     84c:	fa3ff0ef          	jal	7ee <nulterminate>
    nulterminate(pcmd->right);
     850:	6888                	ld	a0,16(s1)
     852:	f9dff0ef          	jal	7ee <nulterminate>
    break;
     856:	b7e5                	j	83e <nulterminate+0x50>
    nulterminate(lcmd->left);
     858:	6508                	ld	a0,8(a0)
     85a:	f95ff0ef          	jal	7ee <nulterminate>
    nulterminate(lcmd->right);
     85e:	6888                	ld	a0,16(s1)
     860:	f8fff0ef          	jal	7ee <nulterminate>
    break;
     864:	bfe9                	j	83e <nulterminate+0x50>
    nulterminate(bcmd->cmd);
     866:	6508                	ld	a0,8(a0)
     868:	f87ff0ef          	jal	7ee <nulterminate>
    break;
     86c:	bfc9                	j	83e <nulterminate+0x50>

000000000000086e <parsecmd>:
{
     86e:	7139                	addi	sp,sp,-64
     870:	fc06                	sd	ra,56(sp)
     872:	f822                	sd	s0,48(sp)
     874:	f426                	sd	s1,40(sp)
     876:	f04a                	sd	s2,32(sp)
     878:	ec4e                	sd	s3,24(sp)
     87a:	0080                	addi	s0,sp,64
     87c:	fca43423          	sd	a0,-56(s0)
  es = s + strlen(s);
     880:	84aa                	mv	s1,a0
     882:	1d8000ef          	jal	a5a <strlen>
     886:	1502                	slli	a0,a0,0x20
     888:	9101                	srli	a0,a0,0x20
     88a:	94aa                	add	s1,s1,a0
  cmd = parseline(&s, es);
     88c:	fc840913          	addi	s2,s0,-56
     890:	85a6                	mv	a1,s1
     892:	854a                	mv	a0,s2
     894:	e4fff0ef          	jal	6e2 <parseline>
     898:	89aa                	mv	s3,a0
  peek(&s, es, "");
     89a:	00001617          	auipc	a2,0x1
     89e:	a4e60613          	addi	a2,a2,-1458 # 12e8 <malloc+0xfa>
     8a2:	85a6                	mv	a1,s1
     8a4:	854a                	mv	a0,s2
     8a6:	ba3ff0ef          	jal	448 <peek>
  if(s != es){
     8aa:	fc843603          	ld	a2,-56(s0)
     8ae:	00961d63          	bne	a2,s1,8c8 <parsecmd+0x5a>
  nulterminate(cmd);
     8b2:	854e                	mv	a0,s3
     8b4:	f3bff0ef          	jal	7ee <nulterminate>
}
     8b8:	854e                	mv	a0,s3
     8ba:	70e2                	ld	ra,56(sp)
     8bc:	7442                	ld	s0,48(sp)
     8be:	74a2                	ld	s1,40(sp)
     8c0:	7902                	ld	s2,32(sp)
     8c2:	69e2                	ld	s3,24(sp)
     8c4:	6121                	addi	sp,sp,64
     8c6:	8082                	ret
    fprintf(2, "leftovers: %s\n", s);
     8c8:	00001597          	auipc	a1,0x1
     8cc:	b0058593          	addi	a1,a1,-1280 # 13c8 <malloc+0x1da>
     8d0:	4509                	li	a0,2
     8d2:	03b000ef          	jal	110c <fprintf>
    panic("syntax");
     8d6:	00001517          	auipc	a0,0x1
     8da:	a8a50513          	addi	a0,a0,-1398 # 1360 <malloc+0x172>
     8de:	f6cff0ef          	jal	4a <panic>

00000000000008e2 <main>:
{
     8e2:	715d                	addi	sp,sp,-80
     8e4:	e486                	sd	ra,72(sp)
     8e6:	e0a2                	sd	s0,64(sp)
     8e8:	fc26                	sd	s1,56(sp)
     8ea:	f84a                	sd	s2,48(sp)
     8ec:	f44e                	sd	s3,40(sp)
     8ee:	f052                	sd	s4,32(sp)
     8f0:	ec56                	sd	s5,24(sp)
     8f2:	e85a                	sd	s6,16(sp)
     8f4:	e45e                	sd	s7,8(sp)
     8f6:	0880                	addi	s0,sp,80
  while((fd = open("console", O_RDWR)) >= 0){
     8f8:	4489                	li	s1,2
     8fa:	00001917          	auipc	s2,0x1
     8fe:	ade90913          	addi	s2,s2,-1314 # 13d8 <malloc+0x1ea>
     902:	85a6                	mv	a1,s1
     904:	854a                	mv	a0,s2
     906:	3ea000ef          	jal	cf0 <open>
     90a:	00054663          	bltz	a0,916 <main+0x34>
    if(fd >= 3){
     90e:	fea4dae3          	bge	s1,a0,902 <main+0x20>
      close(fd);
     912:	3c6000ef          	jal	cd8 <close>
  while(getcmd(buf, sizeof(buf)) >= 0){
     916:	06400993          	li	s3,100
     91a:	00001917          	auipc	s2,0x1
     91e:	70690913          	addi	s2,s2,1798 # 2020 <buf.0>
    if (*cmd == '\n') // is a blank command
     922:	4a29                	li	s4,10
    if(cmd[0] == 'c' && cmd[1] == 'd' && cmd[2] == ' '){
     924:	06300a93          	li	s5,99
    } else if(strcmp(cmd, "exit\n") == 0 || strcmp(cmd, "logout\n") == 0){
     928:	00001b17          	auipc	s6,0x1
     92c:	ac8b0b13          	addi	s6,s6,-1336 # 13f0 <malloc+0x202>
     930:	00001b97          	auipc	s7,0x1
     934:	ac8b8b93          	addi	s7,s7,-1336 # 13f8 <malloc+0x20a>
     938:	a00d                	j	95a <main+0x78>
     93a:	85da                	mv	a1,s6
     93c:	8526                	mv	a0,s1
     93e:	0ec000ef          	jal	a2a <strcmp>
     942:	c155                	beqz	a0,9e6 <main+0x104>
     944:	85de                	mv	a1,s7
     946:	8526                	mv	a0,s1
     948:	0e2000ef          	jal	a2a <strcmp>
     94c:	cd49                	beqz	a0,9e6 <main+0x104>
      if(fork1() == 0)
     94e:	f1aff0ef          	jal	68 <fork1>
     952:	cd41                	beqz	a0,9ea <main+0x108>
      wait(0);
     954:	4501                	li	a0,0
     956:	362000ef          	jal	cb8 <wait>
  while(getcmd(buf, sizeof(buf)) >= 0){
     95a:	85ce                	mv	a1,s3
     95c:	854a                	mv	a0,s2
     95e:	ea2ff0ef          	jal	0 <getcmd>
     962:	08054963          	bltz	a0,9f4 <main+0x112>
    while (*cmd == ' ' || *cmd == '\t')
     966:	00094783          	lbu	a5,0(s2)
     96a:	fe078713          	addi	a4,a5,-32
     96e:	cb01                	beqz	a4,97e <main+0x9c>
     970:	ff778713          	addi	a4,a5,-9
    char *cmd = buf;
     974:	00001497          	auipc	s1,0x1
     978:	6ac48493          	addi	s1,s1,1708 # 2020 <buf.0>
    while (*cmd == ' ' || *cmd == '\t')
     97c:	ef11                	bnez	a4,998 <main+0xb6>
    char *cmd = buf;
     97e:	00001497          	auipc	s1,0x1
     982:	6a248493          	addi	s1,s1,1698 # 2020 <buf.0>
      cmd++;
     986:	0485                	addi	s1,s1,1
    while (*cmd == ' ' || *cmd == '\t')
     988:	0004c783          	lbu	a5,0(s1)
     98c:	fe078713          	addi	a4,a5,-32
     990:	db7d                	beqz	a4,986 <main+0xa4>
     992:	ff778713          	addi	a4,a5,-9
     996:	db65                	beqz	a4,986 <main+0xa4>
    if (*cmd == '\n') // is a blank command
     998:	fd4781e3          	beq	a5,s4,95a <main+0x78>
    if(cmd[0] == 'c' && cmd[1] == 'd' && cmd[2] == ' '){
     99c:	f9579fe3          	bne	a5,s5,93a <main+0x58>
     9a0:	0014c783          	lbu	a5,1(s1)
     9a4:	f9379be3          	bne	a5,s3,93a <main+0x58>
     9a8:	0024c703          	lbu	a4,2(s1)
     9ac:	02000793          	li	a5,32
     9b0:	f8f715e3          	bne	a4,a5,93a <main+0x58>
      cmd[strlen(cmd)-1] = 0;  // chop \n
     9b4:	8526                	mv	a0,s1
     9b6:	0a4000ef          	jal	a5a <strlen>
     9ba:	fff5079b          	addiw	a5,a0,-1
     9be:	1782                	slli	a5,a5,0x20
     9c0:	9381                	srli	a5,a5,0x20
     9c2:	97a6                	add	a5,a5,s1
     9c4:	00078023          	sb	zero,0(a5)
      if(chdir(cmd+3) < 0)
     9c8:	048d                	addi	s1,s1,3
     9ca:	8526                	mv	a0,s1
     9cc:	354000ef          	jal	d20 <chdir>
     9d0:	f80555e3          	bgez	a0,95a <main+0x78>
        fprintf(2, "cannot cd %s\n", cmd+3);
     9d4:	8626                	mv	a2,s1
     9d6:	00001597          	auipc	a1,0x1
     9da:	a0a58593          	addi	a1,a1,-1526 # 13e0 <malloc+0x1f2>
     9de:	4509                	li	a0,2
     9e0:	72c000ef          	jal	110c <fprintf>
     9e4:	bf9d                	j	95a <main+0x78>
      exit(0);
     9e6:	2ca000ef          	jal	cb0 <exit>
        runcmd(parsecmd(cmd));
     9ea:	8526                	mv	a0,s1
     9ec:	e83ff0ef          	jal	86e <parsecmd>
     9f0:	e9eff0ef          	jal	8e <runcmd>
  exit(0);
     9f4:	4501                	li	a0,0
     9f6:	2ba000ef          	jal	cb0 <exit>

00000000000009fa <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
     9fa:	1141                	addi	sp,sp,-16
     9fc:	e406                	sd	ra,8(sp)
     9fe:	e022                	sd	s0,0(sp)
     a00:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
     a02:	ee1ff0ef          	jal	8e2 <main>
  exit(r);
     a06:	2aa000ef          	jal	cb0 <exit>

0000000000000a0a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     a0a:	1141                	addi	sp,sp,-16
     a0c:	e406                	sd	ra,8(sp)
     a0e:	e022                	sd	s0,0(sp)
     a10:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     a12:	87aa                	mv	a5,a0
     a14:	0585                	addi	a1,a1,1
     a16:	0785                	addi	a5,a5,1
     a18:	fff5c703          	lbu	a4,-1(a1)
     a1c:	fee78fa3          	sb	a4,-1(a5)
     a20:	fb75                	bnez	a4,a14 <strcpy+0xa>
    ;
  return os;
}
     a22:	60a2                	ld	ra,8(sp)
     a24:	6402                	ld	s0,0(sp)
     a26:	0141                	addi	sp,sp,16
     a28:	8082                	ret

0000000000000a2a <strcmp>:

int
strcmp(const char *p, const char *q)
{
     a2a:	1141                	addi	sp,sp,-16
     a2c:	e406                	sd	ra,8(sp)
     a2e:	e022                	sd	s0,0(sp)
     a30:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     a32:	00054783          	lbu	a5,0(a0)
     a36:	cb91                	beqz	a5,a4a <strcmp+0x20>
     a38:	0005c703          	lbu	a4,0(a1)
     a3c:	00f71763          	bne	a4,a5,a4a <strcmp+0x20>
    p++, q++;
     a40:	0505                	addi	a0,a0,1
     a42:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     a44:	00054783          	lbu	a5,0(a0)
     a48:	fbe5                	bnez	a5,a38 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
     a4a:	0005c503          	lbu	a0,0(a1)
}
     a4e:	40a7853b          	subw	a0,a5,a0
     a52:	60a2                	ld	ra,8(sp)
     a54:	6402                	ld	s0,0(sp)
     a56:	0141                	addi	sp,sp,16
     a58:	8082                	ret

0000000000000a5a <strlen>:

uint
strlen(const char *s)
{
     a5a:	1141                	addi	sp,sp,-16
     a5c:	e406                	sd	ra,8(sp)
     a5e:	e022                	sd	s0,0(sp)
     a60:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     a62:	00054783          	lbu	a5,0(a0)
     a66:	cf91                	beqz	a5,a82 <strlen+0x28>
     a68:	00150793          	addi	a5,a0,1
     a6c:	86be                	mv	a3,a5
     a6e:	0785                	addi	a5,a5,1
     a70:	fff7c703          	lbu	a4,-1(a5)
     a74:	ff65                	bnez	a4,a6c <strlen+0x12>
     a76:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
     a7a:	60a2                	ld	ra,8(sp)
     a7c:	6402                	ld	s0,0(sp)
     a7e:	0141                	addi	sp,sp,16
     a80:	8082                	ret
  for(n = 0; s[n]; n++)
     a82:	4501                	li	a0,0
     a84:	bfdd                	j	a7a <strlen+0x20>

0000000000000a86 <memset>:

void*
memset(void *dst, int c, uint n)
{
     a86:	1141                	addi	sp,sp,-16
     a88:	e406                	sd	ra,8(sp)
     a8a:	e022                	sd	s0,0(sp)
     a8c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     a8e:	ca19                	beqz	a2,aa4 <memset+0x1e>
     a90:	87aa                	mv	a5,a0
     a92:	1602                	slli	a2,a2,0x20
     a94:	9201                	srli	a2,a2,0x20
     a96:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     a9a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     a9e:	0785                	addi	a5,a5,1
     aa0:	fee79de3          	bne	a5,a4,a9a <memset+0x14>
  }
  return dst;
}
     aa4:	60a2                	ld	ra,8(sp)
     aa6:	6402                	ld	s0,0(sp)
     aa8:	0141                	addi	sp,sp,16
     aaa:	8082                	ret

0000000000000aac <strchr>:

char*
strchr(const char *s, char c)
{
     aac:	1141                	addi	sp,sp,-16
     aae:	e406                	sd	ra,8(sp)
     ab0:	e022                	sd	s0,0(sp)
     ab2:	0800                	addi	s0,sp,16
  for(; *s; s++)
     ab4:	00054783          	lbu	a5,0(a0)
     ab8:	cf81                	beqz	a5,ad0 <strchr+0x24>
    if(*s == c)
     aba:	00f58763          	beq	a1,a5,ac8 <strchr+0x1c>
  for(; *s; s++)
     abe:	0505                	addi	a0,a0,1
     ac0:	00054783          	lbu	a5,0(a0)
     ac4:	fbfd                	bnez	a5,aba <strchr+0xe>
      return (char*)s;
  return 0;
     ac6:	4501                	li	a0,0
}
     ac8:	60a2                	ld	ra,8(sp)
     aca:	6402                	ld	s0,0(sp)
     acc:	0141                	addi	sp,sp,16
     ace:	8082                	ret
  return 0;
     ad0:	4501                	li	a0,0
     ad2:	bfdd                	j	ac8 <strchr+0x1c>

0000000000000ad4 <gets>:

char*
gets(char *buf, int max)
{
     ad4:	711d                	addi	sp,sp,-96
     ad6:	ec86                	sd	ra,88(sp)
     ad8:	e8a2                	sd	s0,80(sp)
     ada:	e4a6                	sd	s1,72(sp)
     adc:	e0ca                	sd	s2,64(sp)
     ade:	fc4e                	sd	s3,56(sp)
     ae0:	f852                	sd	s4,48(sp)
     ae2:	f456                	sd	s5,40(sp)
     ae4:	f05a                	sd	s6,32(sp)
     ae6:	ec5e                	sd	s7,24(sp)
     ae8:	e862                	sd	s8,16(sp)
     aea:	1080                	addi	s0,sp,96
     aec:	8baa                	mv	s7,a0
     aee:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     af0:	892a                	mv	s2,a0
     af2:	4481                	li	s1,0
    cc = read(0, &c, 1);
     af4:	faf40b13          	addi	s6,s0,-81
     af8:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
     afa:	8c26                	mv	s8,s1
     afc:	0014899b          	addiw	s3,s1,1
     b00:	84ce                	mv	s1,s3
     b02:	0349d463          	bge	s3,s4,b2a <gets+0x56>
    cc = read(0, &c, 1);
     b06:	8656                	mv	a2,s5
     b08:	85da                	mv	a1,s6
     b0a:	4501                	li	a0,0
     b0c:	1bc000ef          	jal	cc8 <read>
    if(cc < 1)
     b10:	00a05d63          	blez	a0,b2a <gets+0x56>
      break;
    buf[i++] = c;
     b14:	faf44783          	lbu	a5,-81(s0)
     b18:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     b1c:	0905                	addi	s2,s2,1
     b1e:	ff678713          	addi	a4,a5,-10
     b22:	c319                	beqz	a4,b28 <gets+0x54>
     b24:	17cd                	addi	a5,a5,-13
     b26:	fbf1                	bnez	a5,afa <gets+0x26>
    buf[i++] = c;
     b28:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
     b2a:	9c5e                	add	s8,s8,s7
     b2c:	000c0023          	sb	zero,0(s8)
  return buf;
}
     b30:	855e                	mv	a0,s7
     b32:	60e6                	ld	ra,88(sp)
     b34:	6446                	ld	s0,80(sp)
     b36:	64a6                	ld	s1,72(sp)
     b38:	6906                	ld	s2,64(sp)
     b3a:	79e2                	ld	s3,56(sp)
     b3c:	7a42                	ld	s4,48(sp)
     b3e:	7aa2                	ld	s5,40(sp)
     b40:	7b02                	ld	s6,32(sp)
     b42:	6be2                	ld	s7,24(sp)
     b44:	6c42                	ld	s8,16(sp)
     b46:	6125                	addi	sp,sp,96
     b48:	8082                	ret

0000000000000b4a <stat>:

int
stat(const char *n, struct stat *st)
{
     b4a:	1101                	addi	sp,sp,-32
     b4c:	ec06                	sd	ra,24(sp)
     b4e:	e822                	sd	s0,16(sp)
     b50:	e04a                	sd	s2,0(sp)
     b52:	1000                	addi	s0,sp,32
     b54:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     b56:	4581                	li	a1,0
     b58:	198000ef          	jal	cf0 <open>
  if(fd < 0)
     b5c:	02054263          	bltz	a0,b80 <stat+0x36>
     b60:	e426                	sd	s1,8(sp)
     b62:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     b64:	85ca                	mv	a1,s2
     b66:	1a2000ef          	jal	d08 <fstat>
     b6a:	892a                	mv	s2,a0
  close(fd);
     b6c:	8526                	mv	a0,s1
     b6e:	16a000ef          	jal	cd8 <close>
  return r;
     b72:	64a2                	ld	s1,8(sp)
}
     b74:	854a                	mv	a0,s2
     b76:	60e2                	ld	ra,24(sp)
     b78:	6442                	ld	s0,16(sp)
     b7a:	6902                	ld	s2,0(sp)
     b7c:	6105                	addi	sp,sp,32
     b7e:	8082                	ret
    return -1;
     b80:	57fd                	li	a5,-1
     b82:	893e                	mv	s2,a5
     b84:	bfc5                	j	b74 <stat+0x2a>

0000000000000b86 <atoi>:

int
atoi(const char *s)
{
     b86:	1141                	addi	sp,sp,-16
     b88:	e406                	sd	ra,8(sp)
     b8a:	e022                	sd	s0,0(sp)
     b8c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     b8e:	00054683          	lbu	a3,0(a0)
     b92:	fd06879b          	addiw	a5,a3,-48
     b96:	0ff7f793          	zext.b	a5,a5
     b9a:	4625                	li	a2,9
     b9c:	02f66963          	bltu	a2,a5,bce <atoi+0x48>
     ba0:	872a                	mv	a4,a0
  n = 0;
     ba2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     ba4:	0705                	addi	a4,a4,1
     ba6:	0025179b          	slliw	a5,a0,0x2
     baa:	9fa9                	addw	a5,a5,a0
     bac:	0017979b          	slliw	a5,a5,0x1
     bb0:	9fb5                	addw	a5,a5,a3
     bb2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     bb6:	00074683          	lbu	a3,0(a4)
     bba:	fd06879b          	addiw	a5,a3,-48
     bbe:	0ff7f793          	zext.b	a5,a5
     bc2:	fef671e3          	bgeu	a2,a5,ba4 <atoi+0x1e>
  return n;
}
     bc6:	60a2                	ld	ra,8(sp)
     bc8:	6402                	ld	s0,0(sp)
     bca:	0141                	addi	sp,sp,16
     bcc:	8082                	ret
  n = 0;
     bce:	4501                	li	a0,0
     bd0:	bfdd                	j	bc6 <atoi+0x40>

0000000000000bd2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     bd2:	1141                	addi	sp,sp,-16
     bd4:	e406                	sd	ra,8(sp)
     bd6:	e022                	sd	s0,0(sp)
     bd8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     bda:	02b57563          	bgeu	a0,a1,c04 <memmove+0x32>
    while(n-- > 0)
     bde:	00c05f63          	blez	a2,bfc <memmove+0x2a>
     be2:	1602                	slli	a2,a2,0x20
     be4:	9201                	srli	a2,a2,0x20
     be6:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     bea:	872a                	mv	a4,a0
      *dst++ = *src++;
     bec:	0585                	addi	a1,a1,1
     bee:	0705                	addi	a4,a4,1
     bf0:	fff5c683          	lbu	a3,-1(a1)
     bf4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     bf8:	fee79ae3          	bne	a5,a4,bec <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     bfc:	60a2                	ld	ra,8(sp)
     bfe:	6402                	ld	s0,0(sp)
     c00:	0141                	addi	sp,sp,16
     c02:	8082                	ret
    while(n-- > 0)
     c04:	fec05ce3          	blez	a2,bfc <memmove+0x2a>
    dst += n;
     c08:	00c50733          	add	a4,a0,a2
    src += n;
     c0c:	95b2                	add	a1,a1,a2
     c0e:	fff6079b          	addiw	a5,a2,-1
     c12:	1782                	slli	a5,a5,0x20
     c14:	9381                	srli	a5,a5,0x20
     c16:	fff7c793          	not	a5,a5
     c1a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     c1c:	15fd                	addi	a1,a1,-1
     c1e:	177d                	addi	a4,a4,-1
     c20:	0005c683          	lbu	a3,0(a1)
     c24:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     c28:	fef71ae3          	bne	a4,a5,c1c <memmove+0x4a>
     c2c:	bfc1                	j	bfc <memmove+0x2a>

0000000000000c2e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     c2e:	1141                	addi	sp,sp,-16
     c30:	e406                	sd	ra,8(sp)
     c32:	e022                	sd	s0,0(sp)
     c34:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     c36:	c61d                	beqz	a2,c64 <memcmp+0x36>
     c38:	1602                	slli	a2,a2,0x20
     c3a:	9201                	srli	a2,a2,0x20
     c3c:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
     c40:	00054783          	lbu	a5,0(a0)
     c44:	0005c703          	lbu	a4,0(a1)
     c48:	00e79863          	bne	a5,a4,c58 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
     c4c:	0505                	addi	a0,a0,1
    p2++;
     c4e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     c50:	fed518e3          	bne	a0,a3,c40 <memcmp+0x12>
  }
  return 0;
     c54:	4501                	li	a0,0
     c56:	a019                	j	c5c <memcmp+0x2e>
      return *p1 - *p2;
     c58:	40e7853b          	subw	a0,a5,a4
}
     c5c:	60a2                	ld	ra,8(sp)
     c5e:	6402                	ld	s0,0(sp)
     c60:	0141                	addi	sp,sp,16
     c62:	8082                	ret
  return 0;
     c64:	4501                	li	a0,0
     c66:	bfdd                	j	c5c <memcmp+0x2e>

0000000000000c68 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     c68:	1141                	addi	sp,sp,-16
     c6a:	e406                	sd	ra,8(sp)
     c6c:	e022                	sd	s0,0(sp)
     c6e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     c70:	f63ff0ef          	jal	bd2 <memmove>
}
     c74:	60a2                	ld	ra,8(sp)
     c76:	6402                	ld	s0,0(sp)
     c78:	0141                	addi	sp,sp,16
     c7a:	8082                	ret

0000000000000c7c <sbrk>:

char *
sbrk(int n) {
     c7c:	1141                	addi	sp,sp,-16
     c7e:	e406                	sd	ra,8(sp)
     c80:	e022                	sd	s0,0(sp)
     c82:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
     c84:	4585                	li	a1,1
     c86:	0b2000ef          	jal	d38 <sys_sbrk>
}
     c8a:	60a2                	ld	ra,8(sp)
     c8c:	6402                	ld	s0,0(sp)
     c8e:	0141                	addi	sp,sp,16
     c90:	8082                	ret

0000000000000c92 <sbrklazy>:

char *
sbrklazy(int n) {
     c92:	1141                	addi	sp,sp,-16
     c94:	e406                	sd	ra,8(sp)
     c96:	e022                	sd	s0,0(sp)
     c98:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
     c9a:	4589                	li	a1,2
     c9c:	09c000ef          	jal	d38 <sys_sbrk>
}
     ca0:	60a2                	ld	ra,8(sp)
     ca2:	6402                	ld	s0,0(sp)
     ca4:	0141                	addi	sp,sp,16
     ca6:	8082                	ret

0000000000000ca8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     ca8:	4885                	li	a7,1
 ecall
     caa:	00000073          	ecall
 ret
     cae:	8082                	ret

0000000000000cb0 <exit>:
.global exit
exit:
 li a7, SYS_exit
     cb0:	4889                	li	a7,2
 ecall
     cb2:	00000073          	ecall
 ret
     cb6:	8082                	ret

0000000000000cb8 <wait>:
.global wait
wait:
 li a7, SYS_wait
     cb8:	488d                	li	a7,3
 ecall
     cba:	00000073          	ecall
 ret
     cbe:	8082                	ret

0000000000000cc0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     cc0:	4891                	li	a7,4
 ecall
     cc2:	00000073          	ecall
 ret
     cc6:	8082                	ret

0000000000000cc8 <read>:
.global read
read:
 li a7, SYS_read
     cc8:	4895                	li	a7,5
 ecall
     cca:	00000073          	ecall
 ret
     cce:	8082                	ret

0000000000000cd0 <write>:
.global write
write:
 li a7, SYS_write
     cd0:	48c1                	li	a7,16
 ecall
     cd2:	00000073          	ecall
 ret
     cd6:	8082                	ret

0000000000000cd8 <close>:
.global close
close:
 li a7, SYS_close
     cd8:	48d5                	li	a7,21
 ecall
     cda:	00000073          	ecall
 ret
     cde:	8082                	ret

0000000000000ce0 <kill>:
.global kill
kill:
 li a7, SYS_kill
     ce0:	4899                	li	a7,6
 ecall
     ce2:	00000073          	ecall
 ret
     ce6:	8082                	ret

0000000000000ce8 <exec>:
.global exec
exec:
 li a7, SYS_exec
     ce8:	489d                	li	a7,7
 ecall
     cea:	00000073          	ecall
 ret
     cee:	8082                	ret

0000000000000cf0 <open>:
.global open
open:
 li a7, SYS_open
     cf0:	48bd                	li	a7,15
 ecall
     cf2:	00000073          	ecall
 ret
     cf6:	8082                	ret

0000000000000cf8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     cf8:	48c5                	li	a7,17
 ecall
     cfa:	00000073          	ecall
 ret
     cfe:	8082                	ret

0000000000000d00 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     d00:	48c9                	li	a7,18
 ecall
     d02:	00000073          	ecall
 ret
     d06:	8082                	ret

0000000000000d08 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     d08:	48a1                	li	a7,8
 ecall
     d0a:	00000073          	ecall
 ret
     d0e:	8082                	ret

0000000000000d10 <link>:
.global link
link:
 li a7, SYS_link
     d10:	48cd                	li	a7,19
 ecall
     d12:	00000073          	ecall
 ret
     d16:	8082                	ret

0000000000000d18 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     d18:	48d1                	li	a7,20
 ecall
     d1a:	00000073          	ecall
 ret
     d1e:	8082                	ret

0000000000000d20 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     d20:	48a5                	li	a7,9
 ecall
     d22:	00000073          	ecall
 ret
     d26:	8082                	ret

0000000000000d28 <dup>:
.global dup
dup:
 li a7, SYS_dup
     d28:	48a9                	li	a7,10
 ecall
     d2a:	00000073          	ecall
 ret
     d2e:	8082                	ret

0000000000000d30 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     d30:	48ad                	li	a7,11
 ecall
     d32:	00000073          	ecall
 ret
     d36:	8082                	ret

0000000000000d38 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
     d38:	48b1                	li	a7,12
 ecall
     d3a:	00000073          	ecall
 ret
     d3e:	8082                	ret

0000000000000d40 <pause>:
.global pause
pause:
 li a7, SYS_pause
     d40:	48b5                	li	a7,13
 ecall
     d42:	00000073          	ecall
 ret
     d46:	8082                	ret

0000000000000d48 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     d48:	48b9                	li	a7,14
 ecall
     d4a:	00000073          	ecall
 ret
     d4e:	8082                	ret

0000000000000d50 <login>:
.global login
login:
 li a7, SYS_login
     d50:	48d9                	li	a7,22
 ecall
     d52:	00000073          	ecall
 ret
     d56:	8082                	ret

0000000000000d58 <useradd>:
.global useradd
useradd:
 li a7, SYS_useradd
     d58:	48dd                	li	a7,23
 ecall
     d5a:	00000073          	ecall
 ret
     d5e:	8082                	ret

0000000000000d60 <userdel>:
.global userdel
userdel:
 li a7, SYS_userdel
     d60:	48e1                	li	a7,24
 ecall
     d62:	00000073          	ecall
 ret
     d66:	8082                	ret

0000000000000d68 <passwd>:
.global passwd
passwd:
 li a7, SYS_passwd
     d68:	48e5                	li	a7,25
 ecall
     d6a:	00000073          	ecall
 ret
     d6e:	8082                	ret

0000000000000d70 <whoami>:
.global whoami
whoami:
 li a7, SYS_whoami
     d70:	48e9                	li	a7,26
 ecall
     d72:	00000073          	ecall
 ret
     d76:	8082                	ret

0000000000000d78 <chmod>:
.global chmod
chmod:
 li a7, SYS_chmod
     d78:	48ed                	li	a7,27
 ecall
     d7a:	00000073          	ecall
 ret
     d7e:	8082                	ret

0000000000000d80 <chown>:
.global chown
chown:
 li a7, SYS_chown
     d80:	48f1                	li	a7,28
 ecall
     d82:	00000073          	ecall
 ret
     d86:	8082                	ret

0000000000000d88 <audit_read>:
.global audit_read
audit_read:
 li a7, SYS_audit_read
     d88:	48f5                	li	a7,29
 ecall
     d8a:	00000073          	ecall
 ret
     d8e:	8082                	ret

0000000000000d90 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     d90:	1101                	addi	sp,sp,-32
     d92:	ec06                	sd	ra,24(sp)
     d94:	e822                	sd	s0,16(sp)
     d96:	1000                	addi	s0,sp,32
     d98:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     d9c:	4605                	li	a2,1
     d9e:	fef40593          	addi	a1,s0,-17
     da2:	f2fff0ef          	jal	cd0 <write>
}
     da6:	60e2                	ld	ra,24(sp)
     da8:	6442                	ld	s0,16(sp)
     daa:	6105                	addi	sp,sp,32
     dac:	8082                	ret

0000000000000dae <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
     dae:	715d                	addi	sp,sp,-80
     db0:	e486                	sd	ra,72(sp)
     db2:	e0a2                	sd	s0,64(sp)
     db4:	f84a                	sd	s2,48(sp)
     db6:	f44e                	sd	s3,40(sp)
     db8:	0880                	addi	s0,sp,80
     dba:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
     dbc:	c6d1                	beqz	a3,e48 <printint+0x9a>
     dbe:	0805d563          	bgez	a1,e48 <printint+0x9a>
    neg = 1;
    x = -xx;
     dc2:	40b005b3          	neg	a1,a1
    neg = 1;
     dc6:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
     dc8:	fb840993          	addi	s3,s0,-72
  neg = 0;
     dcc:	86ce                	mv	a3,s3
  i = 0;
     dce:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     dd0:	00000817          	auipc	a6,0x0
     dd4:	66880813          	addi	a6,a6,1640 # 1438 <digits>
     dd8:	88ba                	mv	a7,a4
     dda:	0017051b          	addiw	a0,a4,1
     dde:	872a                	mv	a4,a0
     de0:	02c5f7b3          	remu	a5,a1,a2
     de4:	97c2                	add	a5,a5,a6
     de6:	0007c783          	lbu	a5,0(a5)
     dea:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     dee:	87ae                	mv	a5,a1
     df0:	02c5d5b3          	divu	a1,a1,a2
     df4:	0685                	addi	a3,a3,1
     df6:	fec7f1e3          	bgeu	a5,a2,dd8 <printint+0x2a>
  if(neg)
     dfa:	00030c63          	beqz	t1,e12 <printint+0x64>
    buf[i++] = '-';
     dfe:	fd050793          	addi	a5,a0,-48
     e02:	00878533          	add	a0,a5,s0
     e06:	02d00793          	li	a5,45
     e0a:	fef50423          	sb	a5,-24(a0)
     e0e:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
     e12:	02e05563          	blez	a4,e3c <printint+0x8e>
     e16:	fc26                	sd	s1,56(sp)
     e18:	377d                	addiw	a4,a4,-1
     e1a:	00e984b3          	add	s1,s3,a4
     e1e:	19fd                	addi	s3,s3,-1
     e20:	99ba                	add	s3,s3,a4
     e22:	1702                	slli	a4,a4,0x20
     e24:	9301                	srli	a4,a4,0x20
     e26:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     e2a:	0004c583          	lbu	a1,0(s1)
     e2e:	854a                	mv	a0,s2
     e30:	f61ff0ef          	jal	d90 <putc>
  while(--i >= 0)
     e34:	14fd                	addi	s1,s1,-1
     e36:	ff349ae3          	bne	s1,s3,e2a <printint+0x7c>
     e3a:	74e2                	ld	s1,56(sp)
}
     e3c:	60a6                	ld	ra,72(sp)
     e3e:	6406                	ld	s0,64(sp)
     e40:	7942                	ld	s2,48(sp)
     e42:	79a2                	ld	s3,40(sp)
     e44:	6161                	addi	sp,sp,80
     e46:	8082                	ret
  neg = 0;
     e48:	4301                	li	t1,0
     e4a:	bfbd                	j	dc8 <printint+0x1a>

0000000000000e4c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     e4c:	711d                	addi	sp,sp,-96
     e4e:	ec86                	sd	ra,88(sp)
     e50:	e8a2                	sd	s0,80(sp)
     e52:	e4a6                	sd	s1,72(sp)
     e54:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     e56:	0005c483          	lbu	s1,0(a1)
     e5a:	22048363          	beqz	s1,1080 <vprintf+0x234>
     e5e:	e0ca                	sd	s2,64(sp)
     e60:	fc4e                	sd	s3,56(sp)
     e62:	f852                	sd	s4,48(sp)
     e64:	f456                	sd	s5,40(sp)
     e66:	f05a                	sd	s6,32(sp)
     e68:	ec5e                	sd	s7,24(sp)
     e6a:	e862                	sd	s8,16(sp)
     e6c:	8b2a                	mv	s6,a0
     e6e:	8a2e                	mv	s4,a1
     e70:	8bb2                	mv	s7,a2
  state = 0;
     e72:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
     e74:	4901                	li	s2,0
     e76:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
     e78:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
     e7c:	06400c13          	li	s8,100
     e80:	a00d                	j	ea2 <vprintf+0x56>
        putc(fd, c0);
     e82:	85a6                	mv	a1,s1
     e84:	855a                	mv	a0,s6
     e86:	f0bff0ef          	jal	d90 <putc>
     e8a:	a019                	j	e90 <vprintf+0x44>
    } else if(state == '%'){
     e8c:	03598363          	beq	s3,s5,eb2 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
     e90:	0019079b          	addiw	a5,s2,1
     e94:	893e                	mv	s2,a5
     e96:	873e                	mv	a4,a5
     e98:	97d2                	add	a5,a5,s4
     e9a:	0007c483          	lbu	s1,0(a5)
     e9e:	1c048a63          	beqz	s1,1072 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
     ea2:	0004879b          	sext.w	a5,s1
    if(state == 0){
     ea6:	fe0993e3          	bnez	s3,e8c <vprintf+0x40>
      if(c0 == '%'){
     eaa:	fd579ce3          	bne	a5,s5,e82 <vprintf+0x36>
        state = '%';
     eae:	89be                	mv	s3,a5
     eb0:	b7c5                	j	e90 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
     eb2:	00ea06b3          	add	a3,s4,a4
     eb6:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
     eba:	1c060863          	beqz	a2,108a <vprintf+0x23e>
      if(c0 == 'd'){
     ebe:	03878763          	beq	a5,s8,eec <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
     ec2:	f9478693          	addi	a3,a5,-108
     ec6:	0016b693          	seqz	a3,a3
     eca:	f9c60593          	addi	a1,a2,-100
     ece:	e99d                	bnez	a1,f04 <vprintf+0xb8>
     ed0:	ca95                	beqz	a3,f04 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
     ed2:	008b8493          	addi	s1,s7,8
     ed6:	4685                	li	a3,1
     ed8:	4629                	li	a2,10
     eda:	000bb583          	ld	a1,0(s7)
     ede:	855a                	mv	a0,s6
     ee0:	ecfff0ef          	jal	dae <printint>
        i += 1;
     ee4:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
     ee6:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
     ee8:	4981                	li	s3,0
     eea:	b75d                	j	e90 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
     eec:	008b8493          	addi	s1,s7,8
     ef0:	4685                	li	a3,1
     ef2:	4629                	li	a2,10
     ef4:	000ba583          	lw	a1,0(s7)
     ef8:	855a                	mv	a0,s6
     efa:	eb5ff0ef          	jal	dae <printint>
     efe:	8ba6                	mv	s7,s1
      state = 0;
     f00:	4981                	li	s3,0
     f02:	b779                	j	e90 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
     f04:	9752                	add	a4,a4,s4
     f06:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     f0a:	f9460713          	addi	a4,a2,-108
     f0e:	00173713          	seqz	a4,a4
     f12:	8f75                	and	a4,a4,a3
     f14:	f9c58513          	addi	a0,a1,-100
     f18:	18051363          	bnez	a0,109e <vprintf+0x252>
     f1c:	18070163          	beqz	a4,109e <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
     f20:	008b8493          	addi	s1,s7,8
     f24:	4685                	li	a3,1
     f26:	4629                	li	a2,10
     f28:	000bb583          	ld	a1,0(s7)
     f2c:	855a                	mv	a0,s6
     f2e:	e81ff0ef          	jal	dae <printint>
        i += 2;
     f32:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
     f34:	8ba6                	mv	s7,s1
      state = 0;
     f36:	4981                	li	s3,0
        i += 2;
     f38:	bfa1                	j	e90 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
     f3a:	008b8493          	addi	s1,s7,8
     f3e:	4681                	li	a3,0
     f40:	4629                	li	a2,10
     f42:	000be583          	lwu	a1,0(s7)
     f46:	855a                	mv	a0,s6
     f48:	e67ff0ef          	jal	dae <printint>
     f4c:	8ba6                	mv	s7,s1
      state = 0;
     f4e:	4981                	li	s3,0
     f50:	b781                	j	e90 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
     f52:	008b8493          	addi	s1,s7,8
     f56:	4681                	li	a3,0
     f58:	4629                	li	a2,10
     f5a:	000bb583          	ld	a1,0(s7)
     f5e:	855a                	mv	a0,s6
     f60:	e4fff0ef          	jal	dae <printint>
        i += 1;
     f64:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
     f66:	8ba6                	mv	s7,s1
      state = 0;
     f68:	4981                	li	s3,0
     f6a:	b71d                	j	e90 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
     f6c:	008b8493          	addi	s1,s7,8
     f70:	4681                	li	a3,0
     f72:	4629                	li	a2,10
     f74:	000bb583          	ld	a1,0(s7)
     f78:	855a                	mv	a0,s6
     f7a:	e35ff0ef          	jal	dae <printint>
        i += 2;
     f7e:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
     f80:	8ba6                	mv	s7,s1
      state = 0;
     f82:	4981                	li	s3,0
        i += 2;
     f84:	b731                	j	e90 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
     f86:	008b8493          	addi	s1,s7,8
     f8a:	4681                	li	a3,0
     f8c:	4641                	li	a2,16
     f8e:	000be583          	lwu	a1,0(s7)
     f92:	855a                	mv	a0,s6
     f94:	e1bff0ef          	jal	dae <printint>
     f98:	8ba6                	mv	s7,s1
      state = 0;
     f9a:	4981                	li	s3,0
     f9c:	bdd5                	j	e90 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
     f9e:	008b8493          	addi	s1,s7,8
     fa2:	4681                	li	a3,0
     fa4:	4641                	li	a2,16
     fa6:	000bb583          	ld	a1,0(s7)
     faa:	855a                	mv	a0,s6
     fac:	e03ff0ef          	jal	dae <printint>
        i += 1;
     fb0:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
     fb2:	8ba6                	mv	s7,s1
      state = 0;
     fb4:	4981                	li	s3,0
     fb6:	bde9                	j	e90 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
     fb8:	008b8493          	addi	s1,s7,8
     fbc:	4681                	li	a3,0
     fbe:	4641                	li	a2,16
     fc0:	000bb583          	ld	a1,0(s7)
     fc4:	855a                	mv	a0,s6
     fc6:	de9ff0ef          	jal	dae <printint>
        i += 2;
     fca:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
     fcc:	8ba6                	mv	s7,s1
      state = 0;
     fce:	4981                	li	s3,0
        i += 2;
     fd0:	b5c1                	j	e90 <vprintf+0x44>
     fd2:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
     fd4:	008b8793          	addi	a5,s7,8
     fd8:	8cbe                	mv	s9,a5
     fda:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
     fde:	03000593          	li	a1,48
     fe2:	855a                	mv	a0,s6
     fe4:	dadff0ef          	jal	d90 <putc>
  putc(fd, 'x');
     fe8:	07800593          	li	a1,120
     fec:	855a                	mv	a0,s6
     fee:	da3ff0ef          	jal	d90 <putc>
     ff2:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     ff4:	00000b97          	auipc	s7,0x0
     ff8:	444b8b93          	addi	s7,s7,1092 # 1438 <digits>
     ffc:	03c9d793          	srli	a5,s3,0x3c
    1000:	97de                	add	a5,a5,s7
    1002:	0007c583          	lbu	a1,0(a5)
    1006:	855a                	mv	a0,s6
    1008:	d89ff0ef          	jal	d90 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    100c:	0992                	slli	s3,s3,0x4
    100e:	34fd                	addiw	s1,s1,-1
    1010:	f4f5                	bnez	s1,ffc <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
    1012:	8be6                	mv	s7,s9
      state = 0;
    1014:	4981                	li	s3,0
    1016:	6ca2                	ld	s9,8(sp)
    1018:	bda5                	j	e90 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
    101a:	008b8493          	addi	s1,s7,8
    101e:	000bc583          	lbu	a1,0(s7)
    1022:	855a                	mv	a0,s6
    1024:	d6dff0ef          	jal	d90 <putc>
    1028:	8ba6                	mv	s7,s1
      state = 0;
    102a:	4981                	li	s3,0
    102c:	b595                	j	e90 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
    102e:	008b8993          	addi	s3,s7,8
    1032:	000bb483          	ld	s1,0(s7)
    1036:	cc91                	beqz	s1,1052 <vprintf+0x206>
        for(; *s; s++)
    1038:	0004c583          	lbu	a1,0(s1)
    103c:	c985                	beqz	a1,106c <vprintf+0x220>
          putc(fd, *s);
    103e:	855a                	mv	a0,s6
    1040:	d51ff0ef          	jal	d90 <putc>
        for(; *s; s++)
    1044:	0485                	addi	s1,s1,1
    1046:	0004c583          	lbu	a1,0(s1)
    104a:	f9f5                	bnez	a1,103e <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
    104c:	8bce                	mv	s7,s3
      state = 0;
    104e:	4981                	li	s3,0
    1050:	b581                	j	e90 <vprintf+0x44>
          s = "(null)";
    1052:	00000497          	auipc	s1,0x0
    1056:	3ae48493          	addi	s1,s1,942 # 1400 <malloc+0x212>
        for(; *s; s++)
    105a:	02800593          	li	a1,40
    105e:	b7c5                	j	103e <vprintf+0x1f2>
        putc(fd, '%');
    1060:	85be                	mv	a1,a5
    1062:	855a                	mv	a0,s6
    1064:	d2dff0ef          	jal	d90 <putc>
      state = 0;
    1068:	4981                	li	s3,0
    106a:	b51d                	j	e90 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
    106c:	8bce                	mv	s7,s3
      state = 0;
    106e:	4981                	li	s3,0
    1070:	b505                	j	e90 <vprintf+0x44>
    1072:	6906                	ld	s2,64(sp)
    1074:	79e2                	ld	s3,56(sp)
    1076:	7a42                	ld	s4,48(sp)
    1078:	7aa2                	ld	s5,40(sp)
    107a:	7b02                	ld	s6,32(sp)
    107c:	6be2                	ld	s7,24(sp)
    107e:	6c42                	ld	s8,16(sp)
    }
  }
}
    1080:	60e6                	ld	ra,88(sp)
    1082:	6446                	ld	s0,80(sp)
    1084:	64a6                	ld	s1,72(sp)
    1086:	6125                	addi	sp,sp,96
    1088:	8082                	ret
      if(c0 == 'd'){
    108a:	06400713          	li	a4,100
    108e:	e4e78fe3          	beq	a5,a4,eec <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
    1092:	f9478693          	addi	a3,a5,-108
    1096:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
    109a:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    109c:	4701                	li	a4,0
      } else if(c0 == 'u'){
    109e:	07500513          	li	a0,117
    10a2:	e8a78ce3          	beq	a5,a0,f3a <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
    10a6:	f8b60513          	addi	a0,a2,-117
    10aa:	e119                	bnez	a0,10b0 <vprintf+0x264>
    10ac:	ea0693e3          	bnez	a3,f52 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    10b0:	f8b58513          	addi	a0,a1,-117
    10b4:	e119                	bnez	a0,10ba <vprintf+0x26e>
    10b6:	ea071be3          	bnez	a4,f6c <vprintf+0x120>
      } else if(c0 == 'x'){
    10ba:	07800513          	li	a0,120
    10be:	eca784e3          	beq	a5,a0,f86 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
    10c2:	f8860613          	addi	a2,a2,-120
    10c6:	e219                	bnez	a2,10cc <vprintf+0x280>
    10c8:	ec069be3          	bnez	a3,f9e <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    10cc:	f8858593          	addi	a1,a1,-120
    10d0:	e199                	bnez	a1,10d6 <vprintf+0x28a>
    10d2:	ee0713e3          	bnez	a4,fb8 <vprintf+0x16c>
      } else if(c0 == 'p'){
    10d6:	07000713          	li	a4,112
    10da:	eee78ce3          	beq	a5,a4,fd2 <vprintf+0x186>
      } else if(c0 == 'c'){
    10de:	06300713          	li	a4,99
    10e2:	f2e78ce3          	beq	a5,a4,101a <vprintf+0x1ce>
      } else if(c0 == 's'){
    10e6:	07300713          	li	a4,115
    10ea:	f4e782e3          	beq	a5,a4,102e <vprintf+0x1e2>
      } else if(c0 == '%'){
    10ee:	02500713          	li	a4,37
    10f2:	f6e787e3          	beq	a5,a4,1060 <vprintf+0x214>
        putc(fd, '%');
    10f6:	02500593          	li	a1,37
    10fa:	855a                	mv	a0,s6
    10fc:	c95ff0ef          	jal	d90 <putc>
        putc(fd, c0);
    1100:	85a6                	mv	a1,s1
    1102:	855a                	mv	a0,s6
    1104:	c8dff0ef          	jal	d90 <putc>
      state = 0;
    1108:	4981                	li	s3,0
    110a:	b359                	j	e90 <vprintf+0x44>

000000000000110c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    110c:	715d                	addi	sp,sp,-80
    110e:	ec06                	sd	ra,24(sp)
    1110:	e822                	sd	s0,16(sp)
    1112:	1000                	addi	s0,sp,32
    1114:	e010                	sd	a2,0(s0)
    1116:	e414                	sd	a3,8(s0)
    1118:	e818                	sd	a4,16(s0)
    111a:	ec1c                	sd	a5,24(s0)
    111c:	03043023          	sd	a6,32(s0)
    1120:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1124:	8622                	mv	a2,s0
    1126:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    112a:	d23ff0ef          	jal	e4c <vprintf>
}
    112e:	60e2                	ld	ra,24(sp)
    1130:	6442                	ld	s0,16(sp)
    1132:	6161                	addi	sp,sp,80
    1134:	8082                	ret

0000000000001136 <printf>:

void
printf(const char *fmt, ...)
{
    1136:	711d                	addi	sp,sp,-96
    1138:	ec06                	sd	ra,24(sp)
    113a:	e822                	sd	s0,16(sp)
    113c:	1000                	addi	s0,sp,32
    113e:	e40c                	sd	a1,8(s0)
    1140:	e810                	sd	a2,16(s0)
    1142:	ec14                	sd	a3,24(s0)
    1144:	f018                	sd	a4,32(s0)
    1146:	f41c                	sd	a5,40(s0)
    1148:	03043823          	sd	a6,48(s0)
    114c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    1150:	00840613          	addi	a2,s0,8
    1154:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    1158:	85aa                	mv	a1,a0
    115a:	4505                	li	a0,1
    115c:	cf1ff0ef          	jal	e4c <vprintf>
}
    1160:	60e2                	ld	ra,24(sp)
    1162:	6442                	ld	s0,16(sp)
    1164:	6125                	addi	sp,sp,96
    1166:	8082                	ret

0000000000001168 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1168:	1141                	addi	sp,sp,-16
    116a:	e406                	sd	ra,8(sp)
    116c:	e022                	sd	s0,0(sp)
    116e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1170:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1174:	00001797          	auipc	a5,0x1
    1178:	e9c7b783          	ld	a5,-356(a5) # 2010 <freep>
    117c:	a039                	j	118a <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    117e:	6398                	ld	a4,0(a5)
    1180:	00e7e463          	bltu	a5,a4,1188 <free+0x20>
    1184:	00e6ea63          	bltu	a3,a4,1198 <free+0x30>
{
    1188:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    118a:	fed7fae3          	bgeu	a5,a3,117e <free+0x16>
    118e:	6398                	ld	a4,0(a5)
    1190:	00e6e463          	bltu	a3,a4,1198 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1194:	fee7eae3          	bltu	a5,a4,1188 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
    1198:	ff852583          	lw	a1,-8(a0)
    119c:	6390                	ld	a2,0(a5)
    119e:	02059813          	slli	a6,a1,0x20
    11a2:	01c85713          	srli	a4,a6,0x1c
    11a6:	9736                	add	a4,a4,a3
    11a8:	02e60563          	beq	a2,a4,11d2 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
    11ac:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    11b0:	4790                	lw	a2,8(a5)
    11b2:	02061593          	slli	a1,a2,0x20
    11b6:	01c5d713          	srli	a4,a1,0x1c
    11ba:	973e                	add	a4,a4,a5
    11bc:	02e68263          	beq	a3,a4,11e0 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
    11c0:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    11c2:	00001717          	auipc	a4,0x1
    11c6:	e4f73723          	sd	a5,-434(a4) # 2010 <freep>
}
    11ca:	60a2                	ld	ra,8(sp)
    11cc:	6402                	ld	s0,0(sp)
    11ce:	0141                	addi	sp,sp,16
    11d0:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
    11d2:	4618                	lw	a4,8(a2)
    11d4:	9f2d                	addw	a4,a4,a1
    11d6:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    11da:	6398                	ld	a4,0(a5)
    11dc:	6310                	ld	a2,0(a4)
    11de:	b7f9                	j	11ac <free+0x44>
    p->s.size += bp->s.size;
    11e0:	ff852703          	lw	a4,-8(a0)
    11e4:	9f31                	addw	a4,a4,a2
    11e6:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    11e8:	ff053683          	ld	a3,-16(a0)
    11ec:	bfd1                	j	11c0 <free+0x58>

00000000000011ee <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    11ee:	7139                	addi	sp,sp,-64
    11f0:	fc06                	sd	ra,56(sp)
    11f2:	f822                	sd	s0,48(sp)
    11f4:	f04a                	sd	s2,32(sp)
    11f6:	ec4e                	sd	s3,24(sp)
    11f8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    11fa:	02051993          	slli	s3,a0,0x20
    11fe:	0209d993          	srli	s3,s3,0x20
    1202:	09bd                	addi	s3,s3,15
    1204:	0049d993          	srli	s3,s3,0x4
    1208:	2985                	addiw	s3,s3,1
    120a:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
    120c:	00001517          	auipc	a0,0x1
    1210:	e0453503          	ld	a0,-508(a0) # 2010 <freep>
    1214:	c905                	beqz	a0,1244 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1216:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1218:	4798                	lw	a4,8(a5)
    121a:	09377663          	bgeu	a4,s3,12a6 <malloc+0xb8>
    121e:	f426                	sd	s1,40(sp)
    1220:	e852                	sd	s4,16(sp)
    1222:	e456                	sd	s5,8(sp)
    1224:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    1226:	8a4e                	mv	s4,s3
    1228:	6705                	lui	a4,0x1
    122a:	00e9f363          	bgeu	s3,a4,1230 <malloc+0x42>
    122e:	6a05                	lui	s4,0x1
    1230:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    1234:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    1238:	00001497          	auipc	s1,0x1
    123c:	dd848493          	addi	s1,s1,-552 # 2010 <freep>
  if(p == SBRK_ERROR)
    1240:	5afd                	li	s5,-1
    1242:	a83d                	j	1280 <malloc+0x92>
    1244:	f426                	sd	s1,40(sp)
    1246:	e852                	sd	s4,16(sp)
    1248:	e456                	sd	s5,8(sp)
    124a:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    124c:	00001797          	auipc	a5,0x1
    1250:	e3c78793          	addi	a5,a5,-452 # 2088 <base>
    1254:	00001717          	auipc	a4,0x1
    1258:	daf73e23          	sd	a5,-580(a4) # 2010 <freep>
    125c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    125e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    1262:	b7d1                	j	1226 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
    1264:	6398                	ld	a4,0(a5)
    1266:	e118                	sd	a4,0(a0)
    1268:	a899                	j	12be <malloc+0xd0>
  hp->s.size = nu;
    126a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    126e:	0541                	addi	a0,a0,16
    1270:	ef9ff0ef          	jal	1168 <free>
  return freep;
    1274:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
    1276:	c125                	beqz	a0,12d6 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1278:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    127a:	4798                	lw	a4,8(a5)
    127c:	03277163          	bgeu	a4,s2,129e <malloc+0xb0>
    if(p == freep)
    1280:	6098                	ld	a4,0(s1)
    1282:	853e                	mv	a0,a5
    1284:	fef71ae3          	bne	a4,a5,1278 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
    1288:	8552                	mv	a0,s4
    128a:	9f3ff0ef          	jal	c7c <sbrk>
  if(p == SBRK_ERROR)
    128e:	fd551ee3          	bne	a0,s5,126a <malloc+0x7c>
        return 0;
    1292:	4501                	li	a0,0
    1294:	74a2                	ld	s1,40(sp)
    1296:	6a42                	ld	s4,16(sp)
    1298:	6aa2                	ld	s5,8(sp)
    129a:	6b02                	ld	s6,0(sp)
    129c:	a03d                	j	12ca <malloc+0xdc>
    129e:	74a2                	ld	s1,40(sp)
    12a0:	6a42                	ld	s4,16(sp)
    12a2:	6aa2                	ld	s5,8(sp)
    12a4:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    12a6:	fae90fe3          	beq	s2,a4,1264 <malloc+0x76>
        p->s.size -= nunits;
    12aa:	4137073b          	subw	a4,a4,s3
    12ae:	c798                	sw	a4,8(a5)
        p += p->s.size;
    12b0:	02071693          	slli	a3,a4,0x20
    12b4:	01c6d713          	srli	a4,a3,0x1c
    12b8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    12ba:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    12be:	00001717          	auipc	a4,0x1
    12c2:	d4a73923          	sd	a0,-686(a4) # 2010 <freep>
      return (void*)(p + 1);
    12c6:	01078513          	addi	a0,a5,16
  }
}
    12ca:	70e2                	ld	ra,56(sp)
    12cc:	7442                	ld	s0,48(sp)
    12ce:	7902                	ld	s2,32(sp)
    12d0:	69e2                	ld	s3,24(sp)
    12d2:	6121                	addi	sp,sp,64
    12d4:	8082                	ret
    12d6:	74a2                	ld	s1,40(sp)
    12d8:	6a42                	ld	s4,16(sp)
    12da:	6aa2                	ld	s5,8(sp)
    12dc:	6b02                	ld	s6,0(sp)
    12de:	b7f5                	j	12ca <malloc+0xdc>
