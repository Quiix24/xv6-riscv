
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	00009117          	auipc	sp,0x9
    80000004:	d8010113          	addi	sp,sp,-640 # 80008d80 <stack0>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	04e000ef          	jal	80000064 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000024:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000028:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002c:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80000030:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000034:	577d                	li	a4,-1
    80000036:	177e                	slli	a4,a4,0x3f
    80000038:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    8000003a:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003e:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000042:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000046:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    8000004a:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004e:	000f4737          	lui	a4,0xf4
    80000052:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000056:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000058:	14d79073          	csrw	stimecmp,a5
}
    8000005c:	60a2                	ld	ra,8(sp)
    8000005e:	6402                	ld	s0,0(sp)
    80000060:	0141                	addi	sp,sp,16
    80000062:	8082                	ret

0000000080000064 <start>:
{
    80000064:	1141                	addi	sp,sp,-16
    80000066:	e406                	sd	ra,8(sp)
    80000068:	e022                	sd	s0,0(sp)
    8000006a:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006c:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000070:	7779                	lui	a4,0xffffe
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd001f>
    80000076:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000078:	6705                	lui	a4,0x1
    8000007a:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000080:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000084:	00001797          	auipc	a5,0x1
    80000088:	e2a78793          	addi	a5,a5,-470 # 80000eae <main>
    8000008c:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80000090:	4781                	li	a5,0
    80000092:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000096:	67c1                	lui	a5,0x10
    80000098:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000009a:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009e:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000a2:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a6:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800000aa:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000ae:	57fd                	li	a5,-1
    800000b0:	83a9                	srli	a5,a5,0xa
    800000b2:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b6:	47bd                	li	a5,15
    800000b8:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000bc:	f61ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000c0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c4:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c8:	30200073          	mret
}
    800000cc:	60a2                	ld	ra,8(sp)
    800000ce:	6402                	ld	s0,0(sp)
    800000d0:	0141                	addi	sp,sp,16
    800000d2:	8082                	ret

00000000800000d4 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d4:	7119                	addi	sp,sp,-128
    800000d6:	fc86                	sd	ra,120(sp)
    800000d8:	f8a2                	sd	s0,112(sp)
    800000da:	f4a6                	sd	s1,104(sp)
    800000dc:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while(i < n){
    800000de:	06c05b63          	blez	a2,80000154 <consolewrite+0x80>
    800000e2:	f0ca                	sd	s2,96(sp)
    800000e4:	ecce                	sd	s3,88(sp)
    800000e6:	e8d2                	sd	s4,80(sp)
    800000e8:	e4d6                	sd	s5,72(sp)
    800000ea:	e0da                	sd	s6,64(sp)
    800000ec:	fc5e                	sd	s7,56(sp)
    800000ee:	f862                	sd	s8,48(sp)
    800000f0:	f466                	sd	s9,40(sp)
    800000f2:	f06a                	sd	s10,32(sp)
    800000f4:	8b2a                	mv	s6,a0
    800000f6:	8bae                	mv	s7,a1
    800000f8:	8a32                	mv	s4,a2
  int i = 0;
    800000fa:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    800000fc:	02000c93          	li	s9,32
    80000100:	02000d13          	li	s10,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000104:	f8040a93          	addi	s5,s0,-128
    80000108:	5c7d                	li	s8,-1
    8000010a:	a025                	j	80000132 <consolewrite+0x5e>
    if(nn > n - i)
    8000010c:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000110:	86ce                	mv	a3,s3
    80000112:	01748633          	add	a2,s1,s7
    80000116:	85da                	mv	a1,s6
    80000118:	8556                	mv	a0,s5
    8000011a:	21c020ef          	jal	80002336 <either_copyin>
    8000011e:	03850d63          	beq	a0,s8,80000158 <consolewrite+0x84>
      break;
    uartwrite(buf, nn);
    80000122:	85ce                	mv	a1,s3
    80000124:	8556                	mv	a0,s5
    80000126:	7b4000ef          	jal	800008da <uartwrite>
    i += nn;
    8000012a:	009904bb          	addw	s1,s2,s1
  while(i < n){
    8000012e:	0144d963          	bge	s1,s4,80000140 <consolewrite+0x6c>
    if(nn > n - i)
    80000132:	409a07bb          	subw	a5,s4,s1
    80000136:	893e                	mv	s2,a5
    80000138:	fcfcdae3          	bge	s9,a5,8000010c <consolewrite+0x38>
    8000013c:	896a                	mv	s2,s10
    8000013e:	b7f9                	j	8000010c <consolewrite+0x38>
    80000140:	7906                	ld	s2,96(sp)
    80000142:	69e6                	ld	s3,88(sp)
    80000144:	6a46                	ld	s4,80(sp)
    80000146:	6aa6                	ld	s5,72(sp)
    80000148:	6b06                	ld	s6,64(sp)
    8000014a:	7be2                	ld	s7,56(sp)
    8000014c:	7c42                	ld	s8,48(sp)
    8000014e:	7ca2                	ld	s9,40(sp)
    80000150:	7d02                	ld	s10,32(sp)
    80000152:	a821                	j	8000016a <consolewrite+0x96>
  int i = 0;
    80000154:	4481                	li	s1,0
    80000156:	a811                	j	8000016a <consolewrite+0x96>
    80000158:	7906                	ld	s2,96(sp)
    8000015a:	69e6                	ld	s3,88(sp)
    8000015c:	6a46                	ld	s4,80(sp)
    8000015e:	6aa6                	ld	s5,72(sp)
    80000160:	6b06                	ld	s6,64(sp)
    80000162:	7be2                	ld	s7,56(sp)
    80000164:	7c42                	ld	s8,48(sp)
    80000166:	7ca2                	ld	s9,40(sp)
    80000168:	7d02                	ld	s10,32(sp)
  }

  return i;
}
    8000016a:	8526                	mv	a0,s1
    8000016c:	70e6                	ld	ra,120(sp)
    8000016e:	7446                	ld	s0,112(sp)
    80000170:	74a6                	ld	s1,104(sp)
    80000172:	6109                	addi	sp,sp,128
    80000174:	8082                	ret

0000000080000176 <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000176:	711d                	addi	sp,sp,-96
    80000178:	ec86                	sd	ra,88(sp)
    8000017a:	e8a2                	sd	s0,80(sp)
    8000017c:	e4a6                	sd	s1,72(sp)
    8000017e:	e0ca                	sd	s2,64(sp)
    80000180:	fc4e                	sd	s3,56(sp)
    80000182:	f852                	sd	s4,48(sp)
    80000184:	f05a                	sd	s6,32(sp)
    80000186:	ec5e                	sd	s7,24(sp)
    80000188:	1080                	addi	s0,sp,96
    8000018a:	8b2a                	mv	s6,a0
    8000018c:	8a2e                	mv	s4,a1
    8000018e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000190:	8bb2                	mv	s7,a2
  acquire(&cons.lock);
    80000192:	00011517          	auipc	a0,0x11
    80000196:	bee50513          	addi	a0,a0,-1042 # 80010d80 <cons>
    8000019a:	28f000ef          	jal	80000c28 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019e:	00011497          	auipc	s1,0x11
    800001a2:	be248493          	addi	s1,s1,-1054 # 80010d80 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a6:	00011917          	auipc	s2,0x11
    800001aa:	c7290913          	addi	s2,s2,-910 # 80010e18 <cons+0x98>
  while(n > 0){
    800001ae:	0b305b63          	blez	s3,80000264 <consoleread+0xee>
    while(cons.r == cons.w){
    800001b2:	0984a783          	lw	a5,152(s1)
    800001b6:	09c4a703          	lw	a4,156(s1)
    800001ba:	0af71063          	bne	a4,a5,8000025a <consoleread+0xe4>
      if(killed(myproc())){
    800001be:	778010ef          	jal	80001936 <myproc>
    800001c2:	00c020ef          	jal	800021ce <killed>
    800001c6:	e12d                	bnez	a0,80000228 <consoleread+0xb2>
      sleep(&cons.r, &cons.lock);
    800001c8:	85a6                	mv	a1,s1
    800001ca:	854a                	mv	a0,s2
    800001cc:	5c7010ef          	jal	80001f92 <sleep>
    while(cons.r == cons.w){
    800001d0:	0984a783          	lw	a5,152(s1)
    800001d4:	09c4a703          	lw	a4,156(s1)
    800001d8:	fef703e3          	beq	a4,a5,800001be <consoleread+0x48>
    800001dc:	f456                	sd	s5,40(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00011717          	auipc	a4,0x11
    800001e2:	ba270713          	addi	a4,a4,-1118 # 80010d80 <cons>
    800001e6:	0017869b          	addiw	a3,a5,1
    800001ea:	08d72c23          	sw	a3,152(a4)
    800001ee:	07f7f693          	andi	a3,a5,127
    800001f2:	9736                	add	a4,a4,a3
    800001f4:	01874703          	lbu	a4,24(a4)
    800001f8:	00070a9b          	sext.w	s5,a4

    if(c == C('D')){  // end-of-file
    800001fc:	4691                	li	a3,4
    800001fe:	04da8663          	beq	s5,a3,8000024a <consoleread+0xd4>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000202:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	faf40613          	addi	a2,s0,-81
    8000020c:	85d2                	mv	a1,s4
    8000020e:	855a                	mv	a0,s6
    80000210:	0dc020ef          	jal	800022ec <either_copyout>
    80000214:	57fd                	li	a5,-1
    80000216:	04f50663          	beq	a0,a5,80000262 <consoleread+0xec>
      break;

    dst++;
    8000021a:	0a05                	addi	s4,s4,1
    --n;
    8000021c:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    8000021e:	47a9                	li	a5,10
    80000220:	04fa8b63          	beq	s5,a5,80000276 <consoleread+0x100>
    80000224:	7aa2                	ld	s5,40(sp)
    80000226:	b761                	j	800001ae <consoleread+0x38>
        release(&cons.lock);
    80000228:	00011517          	auipc	a0,0x11
    8000022c:	b5850513          	addi	a0,a0,-1192 # 80010d80 <cons>
    80000230:	28d000ef          	jal	80000cbc <release>
        return -1;
    80000234:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000236:	60e6                	ld	ra,88(sp)
    80000238:	6446                	ld	s0,80(sp)
    8000023a:	64a6                	ld	s1,72(sp)
    8000023c:	6906                	ld	s2,64(sp)
    8000023e:	79e2                	ld	s3,56(sp)
    80000240:	7a42                	ld	s4,48(sp)
    80000242:	7b02                	ld	s6,32(sp)
    80000244:	6be2                	ld	s7,24(sp)
    80000246:	6125                	addi	sp,sp,96
    80000248:	8082                	ret
      if(n < target){
    8000024a:	0179fa63          	bgeu	s3,s7,8000025e <consoleread+0xe8>
        cons.r--;
    8000024e:	00011717          	auipc	a4,0x11
    80000252:	bcf72523          	sw	a5,-1078(a4) # 80010e18 <cons+0x98>
    80000256:	7aa2                	ld	s5,40(sp)
    80000258:	a031                	j	80000264 <consoleread+0xee>
    8000025a:	f456                	sd	s5,40(sp)
    8000025c:	b749                	j	800001de <consoleread+0x68>
    8000025e:	7aa2                	ld	s5,40(sp)
    80000260:	a011                	j	80000264 <consoleread+0xee>
    80000262:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000264:	00011517          	auipc	a0,0x11
    80000268:	b1c50513          	addi	a0,a0,-1252 # 80010d80 <cons>
    8000026c:	251000ef          	jal	80000cbc <release>
  return target - n;
    80000270:	413b853b          	subw	a0,s7,s3
    80000274:	b7c9                	j	80000236 <consoleread+0xc0>
    80000276:	7aa2                	ld	s5,40(sp)
    80000278:	b7f5                	j	80000264 <consoleread+0xee>

000000008000027a <consputc>:
{
    8000027a:	1141                	addi	sp,sp,-16
    8000027c:	e406                	sd	ra,8(sp)
    8000027e:	e022                	sd	s0,0(sp)
    80000280:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000282:	10000793          	li	a5,256
    80000286:	00f50863          	beq	a0,a5,80000296 <consputc+0x1c>
    uartputc_sync(c);
    8000028a:	6e4000ef          	jal	8000096e <uartputc_sync>
}
    8000028e:	60a2                	ld	ra,8(sp)
    80000290:	6402                	ld	s0,0(sp)
    80000292:	0141                	addi	sp,sp,16
    80000294:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000296:	4521                	li	a0,8
    80000298:	6d6000ef          	jal	8000096e <uartputc_sync>
    8000029c:	02000513          	li	a0,32
    800002a0:	6ce000ef          	jal	8000096e <uartputc_sync>
    800002a4:	4521                	li	a0,8
    800002a6:	6c8000ef          	jal	8000096e <uartputc_sync>
    800002aa:	b7d5                	j	8000028e <consputc+0x14>

00000000800002ac <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ac:	1101                	addi	sp,sp,-32
    800002ae:	ec06                	sd	ra,24(sp)
    800002b0:	e822                	sd	s0,16(sp)
    800002b2:	e426                	sd	s1,8(sp)
    800002b4:	1000                	addi	s0,sp,32
    800002b6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b8:	00011517          	auipc	a0,0x11
    800002bc:	ac850513          	addi	a0,a0,-1336 # 80010d80 <cons>
    800002c0:	169000ef          	jal	80000c28 <acquire>

  switch(c){
    800002c4:	47d5                	li	a5,21
    800002c6:	08f48d63          	beq	s1,a5,80000360 <consoleintr+0xb4>
    800002ca:	0297c563          	blt	a5,s1,800002f4 <consoleintr+0x48>
    800002ce:	47a1                	li	a5,8
    800002d0:	0ef48263          	beq	s1,a5,800003b4 <consoleintr+0x108>
    800002d4:	47c1                	li	a5,16
    800002d6:	10f49363          	bne	s1,a5,800003dc <consoleintr+0x130>
  case C('P'):  // Print process list.
    procdump();
    800002da:	0a6020ef          	jal	80002380 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002de:	00011517          	auipc	a0,0x11
    800002e2:	aa250513          	addi	a0,a0,-1374 # 80010d80 <cons>
    800002e6:	1d7000ef          	jal	80000cbc <release>
}
    800002ea:	60e2                	ld	ra,24(sp)
    800002ec:	6442                	ld	s0,16(sp)
    800002ee:	64a2                	ld	s1,8(sp)
    800002f0:	6105                	addi	sp,sp,32
    800002f2:	8082                	ret
  switch(c){
    800002f4:	07f00793          	li	a5,127
    800002f8:	0af48e63          	beq	s1,a5,800003b4 <consoleintr+0x108>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002fc:	00011717          	auipc	a4,0x11
    80000300:	a8470713          	addi	a4,a4,-1404 # 80010d80 <cons>
    80000304:	0a072783          	lw	a5,160(a4)
    80000308:	09872703          	lw	a4,152(a4)
    8000030c:	9f99                	subw	a5,a5,a4
    8000030e:	07f00713          	li	a4,127
    80000312:	fcf766e3          	bltu	a4,a5,800002de <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000316:	47b5                	li	a5,13
    80000318:	0cf48563          	beq	s1,a5,800003e2 <consoleintr+0x136>
      consputc(c);
    8000031c:	8526                	mv	a0,s1
    8000031e:	f5dff0ef          	jal	8000027a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000322:	00011717          	auipc	a4,0x11
    80000326:	a5e70713          	addi	a4,a4,-1442 # 80010d80 <cons>
    8000032a:	0a072683          	lw	a3,160(a4)
    8000032e:	0016879b          	addiw	a5,a3,1
    80000332:	863e                	mv	a2,a5
    80000334:	0af72023          	sw	a5,160(a4)
    80000338:	07f6f693          	andi	a3,a3,127
    8000033c:	9736                	add	a4,a4,a3
    8000033e:	00970c23          	sb	s1,24(a4)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000342:	ff648713          	addi	a4,s1,-10
    80000346:	c371                	beqz	a4,8000040a <consoleintr+0x15e>
    80000348:	14f1                	addi	s1,s1,-4
    8000034a:	c0e1                	beqz	s1,8000040a <consoleintr+0x15e>
    8000034c:	00011717          	auipc	a4,0x11
    80000350:	acc72703          	lw	a4,-1332(a4) # 80010e18 <cons+0x98>
    80000354:	9f99                	subw	a5,a5,a4
    80000356:	08000713          	li	a4,128
    8000035a:	f8e792e3          	bne	a5,a4,800002de <consoleintr+0x32>
    8000035e:	a075                	j	8000040a <consoleintr+0x15e>
    80000360:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000362:	00011717          	auipc	a4,0x11
    80000366:	a1e70713          	addi	a4,a4,-1506 # 80010d80 <cons>
    8000036a:	0a072783          	lw	a5,160(a4)
    8000036e:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000372:	00011497          	auipc	s1,0x11
    80000376:	a0e48493          	addi	s1,s1,-1522 # 80010d80 <cons>
    while(cons.e != cons.w &&
    8000037a:	4929                	li	s2,10
    8000037c:	02f70863          	beq	a4,a5,800003ac <consoleintr+0x100>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000380:	37fd                	addiw	a5,a5,-1
    80000382:	07f7f713          	andi	a4,a5,127
    80000386:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000388:	01874703          	lbu	a4,24(a4)
    8000038c:	03270263          	beq	a4,s2,800003b0 <consoleintr+0x104>
      cons.e--;
    80000390:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000394:	10000513          	li	a0,256
    80000398:	ee3ff0ef          	jal	8000027a <consputc>
    while(cons.e != cons.w &&
    8000039c:	0a04a783          	lw	a5,160(s1)
    800003a0:	09c4a703          	lw	a4,156(s1)
    800003a4:	fcf71ee3          	bne	a4,a5,80000380 <consoleintr+0xd4>
    800003a8:	6902                	ld	s2,0(sp)
    800003aa:	bf15                	j	800002de <consoleintr+0x32>
    800003ac:	6902                	ld	s2,0(sp)
    800003ae:	bf05                	j	800002de <consoleintr+0x32>
    800003b0:	6902                	ld	s2,0(sp)
    800003b2:	b735                	j	800002de <consoleintr+0x32>
    if(cons.e != cons.w){
    800003b4:	00011717          	auipc	a4,0x11
    800003b8:	9cc70713          	addi	a4,a4,-1588 # 80010d80 <cons>
    800003bc:	0a072783          	lw	a5,160(a4)
    800003c0:	09c72703          	lw	a4,156(a4)
    800003c4:	f0f70de3          	beq	a4,a5,800002de <consoleintr+0x32>
      cons.e--;
    800003c8:	37fd                	addiw	a5,a5,-1
    800003ca:	00011717          	auipc	a4,0x11
    800003ce:	a4f72b23          	sw	a5,-1450(a4) # 80010e20 <cons+0xa0>
      consputc(BACKSPACE);
    800003d2:	10000513          	li	a0,256
    800003d6:	ea5ff0ef          	jal	8000027a <consputc>
    800003da:	b711                	j	800002de <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003dc:	f00481e3          	beqz	s1,800002de <consoleintr+0x32>
    800003e0:	bf31                	j	800002fc <consoleintr+0x50>
      consputc(c);
    800003e2:	4529                	li	a0,10
    800003e4:	e97ff0ef          	jal	8000027a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003e8:	00011797          	auipc	a5,0x11
    800003ec:	99878793          	addi	a5,a5,-1640 # 80010d80 <cons>
    800003f0:	0a07a703          	lw	a4,160(a5)
    800003f4:	0017069b          	addiw	a3,a4,1
    800003f8:	8636                	mv	a2,a3
    800003fa:	0ad7a023          	sw	a3,160(a5)
    800003fe:	07f77713          	andi	a4,a4,127
    80000402:	97ba                	add	a5,a5,a4
    80000404:	4729                	li	a4,10
    80000406:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000040a:	00011797          	auipc	a5,0x11
    8000040e:	a0c7a923          	sw	a2,-1518(a5) # 80010e1c <cons+0x9c>
        wakeup(&cons.r);
    80000412:	00011517          	auipc	a0,0x11
    80000416:	a0650513          	addi	a0,a0,-1530 # 80010e18 <cons+0x98>
    8000041a:	3c5010ef          	jal	80001fde <wakeup>
    8000041e:	b5c1                	j	800002de <consoleintr+0x32>

0000000080000420 <consoleinit>:

void
consoleinit(void)
{
    80000420:	1141                	addi	sp,sp,-16
    80000422:	e406                	sd	ra,8(sp)
    80000424:	e022                	sd	s0,0(sp)
    80000426:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000428:	00008597          	auipc	a1,0x8
    8000042c:	be858593          	addi	a1,a1,-1048 # 80008010 <etext+0x10>
    80000430:	00011517          	auipc	a0,0x11
    80000434:	95050513          	addi	a0,a0,-1712 # 80010d80 <cons>
    80000438:	766000ef          	jal	80000b9e <initlock>

  uartinit();
    8000043c:	448000ef          	jal	80000884 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000440:	00022797          	auipc	a5,0x22
    80000444:	a4078793          	addi	a5,a5,-1472 # 80021e80 <devsw>
    80000448:	00000717          	auipc	a4,0x0
    8000044c:	d2e70713          	addi	a4,a4,-722 # 80000176 <consoleread>
    80000450:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000452:	00000717          	auipc	a4,0x0
    80000456:	c8270713          	addi	a4,a4,-894 # 800000d4 <consolewrite>
    8000045a:	ef98                	sd	a4,24(a5)
}
    8000045c:	60a2                	ld	ra,8(sp)
    8000045e:	6402                	ld	s0,0(sp)
    80000460:	0141                	addi	sp,sp,16
    80000462:	8082                	ret

0000000080000464 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000464:	7139                	addi	sp,sp,-64
    80000466:	fc06                	sd	ra,56(sp)
    80000468:	f822                	sd	s0,48(sp)
    8000046a:	f04a                	sd	s2,32(sp)
    8000046c:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    8000046e:	c219                	beqz	a2,80000474 <printint+0x10>
    80000470:	08054163          	bltz	a0,800004f2 <printint+0x8e>
    x = -xx;
  else
    x = xx;
    80000474:	4301                	li	t1,0

  i = 0;
    80000476:	fc840913          	addi	s2,s0,-56
    x = xx;
    8000047a:	86ca                	mv	a3,s2
  i = 0;
    8000047c:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    8000047e:	00008817          	auipc	a6,0x8
    80000482:	67a80813          	addi	a6,a6,1658 # 80008af8 <digits>
    80000486:	88ba                	mv	a7,a4
    80000488:	0017061b          	addiw	a2,a4,1
    8000048c:	8732                	mv	a4,a2
    8000048e:	02b577b3          	remu	a5,a0,a1
    80000492:	97c2                	add	a5,a5,a6
    80000494:	0007c783          	lbu	a5,0(a5)
    80000498:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    8000049c:	87aa                	mv	a5,a0
    8000049e:	02b55533          	divu	a0,a0,a1
    800004a2:	0685                	addi	a3,a3,1
    800004a4:	feb7f1e3          	bgeu	a5,a1,80000486 <printint+0x22>

  if(sign)
    800004a8:	00030c63          	beqz	t1,800004c0 <printint+0x5c>
    buf[i++] = '-';
    800004ac:	fe060793          	addi	a5,a2,-32
    800004b0:	00878633          	add	a2,a5,s0
    800004b4:	02d00793          	li	a5,45
    800004b8:	fef60423          	sb	a5,-24(a2)
    800004bc:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
    800004c0:	02e05463          	blez	a4,800004e8 <printint+0x84>
    800004c4:	f426                	sd	s1,40(sp)
    800004c6:	377d                	addiw	a4,a4,-1
    800004c8:	00e904b3          	add	s1,s2,a4
    800004cc:	197d                	addi	s2,s2,-1
    800004ce:	993a                	add	s2,s2,a4
    800004d0:	1702                	slli	a4,a4,0x20
    800004d2:	9301                	srli	a4,a4,0x20
    800004d4:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    800004d8:	0004c503          	lbu	a0,0(s1)
    800004dc:	d9fff0ef          	jal	8000027a <consputc>
  while(--i >= 0)
    800004e0:	14fd                	addi	s1,s1,-1
    800004e2:	ff249be3          	bne	s1,s2,800004d8 <printint+0x74>
    800004e6:	74a2                	ld	s1,40(sp)
}
    800004e8:	70e2                	ld	ra,56(sp)
    800004ea:	7442                	ld	s0,48(sp)
    800004ec:	7902                	ld	s2,32(sp)
    800004ee:	6121                	addi	sp,sp,64
    800004f0:	8082                	ret
    x = -xx;
    800004f2:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004f6:	4305                	li	t1,1
    x = -xx;
    800004f8:	bfbd                	j	80000476 <printint+0x12>

00000000800004fa <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004fa:	7131                	addi	sp,sp,-192
    800004fc:	fc86                	sd	ra,120(sp)
    800004fe:	f8a2                	sd	s0,112(sp)
    80000500:	f0ca                	sd	s2,96(sp)
    80000502:	0100                	addi	s0,sp,128
    80000504:	892a                	mv	s2,a0
    80000506:	e40c                	sd	a1,8(s0)
    80000508:	e810                	sd	a2,16(s0)
    8000050a:	ec14                	sd	a3,24(s0)
    8000050c:	f018                	sd	a4,32(s0)
    8000050e:	f41c                	sd	a5,40(s0)
    80000510:	03043823          	sd	a6,48(s0)
    80000514:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    80000518:	00009797          	auipc	a5,0x9
    8000051c:	83c7a783          	lw	a5,-1988(a5) # 80008d54 <panicking>
    80000520:	cf9d                	beqz	a5,8000055e <printf+0x64>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000522:	00840793          	addi	a5,s0,8
    80000526:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000052a:	00094503          	lbu	a0,0(s2)
    8000052e:	22050663          	beqz	a0,8000075a <printf+0x260>
    80000532:	f4a6                	sd	s1,104(sp)
    80000534:	ecce                	sd	s3,88(sp)
    80000536:	e8d2                	sd	s4,80(sp)
    80000538:	e4d6                	sd	s5,72(sp)
    8000053a:	e0da                	sd	s6,64(sp)
    8000053c:	fc5e                	sd	s7,56(sp)
    8000053e:	f862                	sd	s8,48(sp)
    80000540:	f06a                	sd	s10,32(sp)
    80000542:	ec6e                	sd	s11,24(sp)
    80000544:	4a01                	li	s4,0
    if(cx != '%'){
    80000546:	02500993          	li	s3,37
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000054a:	07500c13          	li	s8,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    8000054e:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000552:	07000d93          	li	s11,112
      printint(va_arg(ap, uint64), 10, 0);
    80000556:	4b29                	li	s6,10
    if(c0 == 'd'){
    80000558:	06400b93          	li	s7,100
    8000055c:	a015                	j	80000580 <printf+0x86>
    acquire(&pr.lock);
    8000055e:	00011517          	auipc	a0,0x11
    80000562:	8ca50513          	addi	a0,a0,-1846 # 80010e28 <pr>
    80000566:	6c2000ef          	jal	80000c28 <acquire>
    8000056a:	bf65                	j	80000522 <printf+0x28>
      consputc(cx);
    8000056c:	d0fff0ef          	jal	8000027a <consputc>
      continue;
    80000570:	84d2                	mv	s1,s4
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000572:	2485                	addiw	s1,s1,1
    80000574:	8a26                	mv	s4,s1
    80000576:	94ca                	add	s1,s1,s2
    80000578:	0004c503          	lbu	a0,0(s1)
    8000057c:	1c050663          	beqz	a0,80000748 <printf+0x24e>
    if(cx != '%'){
    80000580:	ff3516e3          	bne	a0,s3,8000056c <printf+0x72>
    i++;
    80000584:	001a079b          	addiw	a5,s4,1
    80000588:	84be                	mv	s1,a5
    c0 = fmt[i+0] & 0xff;
    8000058a:	00f90733          	add	a4,s2,a5
    8000058e:	00074a83          	lbu	s5,0(a4)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000592:	200a8963          	beqz	s5,800007a4 <printf+0x2aa>
    80000596:	00174683          	lbu	a3,1(a4)
    if(c1) c2 = fmt[i+2] & 0xff;
    8000059a:	1e068c63          	beqz	a3,80000792 <printf+0x298>
    if(c0 == 'd'){
    8000059e:	037a8863          	beq	s5,s7,800005ce <printf+0xd4>
    } else if(c0 == 'l' && c1 == 'd'){
    800005a2:	f94a8713          	addi	a4,s5,-108
    800005a6:	00173713          	seqz	a4,a4
    800005aa:	f9c68613          	addi	a2,a3,-100
    800005ae:	ee05                	bnez	a2,800005e6 <printf+0xec>
    800005b0:	cb1d                	beqz	a4,800005e6 <printf+0xec>
      printint(va_arg(ap, uint64), 10, 1);
    800005b2:	f8843783          	ld	a5,-120(s0)
    800005b6:	00878713          	addi	a4,a5,8
    800005ba:	f8e43423          	sd	a4,-120(s0)
    800005be:	4605                	li	a2,1
    800005c0:	85da                	mv	a1,s6
    800005c2:	6388                	ld	a0,0(a5)
    800005c4:	ea1ff0ef          	jal	80000464 <printint>
      i += 1;
    800005c8:	002a049b          	addiw	s1,s4,2
    800005cc:	b75d                	j	80000572 <printf+0x78>
      printint(va_arg(ap, int), 10, 1);
    800005ce:	f8843783          	ld	a5,-120(s0)
    800005d2:	00878713          	addi	a4,a5,8
    800005d6:	f8e43423          	sd	a4,-120(s0)
    800005da:	4605                	li	a2,1
    800005dc:	85da                	mv	a1,s6
    800005de:	4388                	lw	a0,0(a5)
    800005e0:	e85ff0ef          	jal	80000464 <printint>
    800005e4:	b779                	j	80000572 <printf+0x78>
    if(c1) c2 = fmt[i+2] & 0xff;
    800005e6:	97ca                	add	a5,a5,s2
    800005e8:	8636                	mv	a2,a3
    800005ea:	0027c683          	lbu	a3,2(a5)
    800005ee:	a2c9                	j	800007b0 <printf+0x2b6>
      printint(va_arg(ap, uint64), 10, 1);
    800005f0:	f8843783          	ld	a5,-120(s0)
    800005f4:	00878713          	addi	a4,a5,8
    800005f8:	f8e43423          	sd	a4,-120(s0)
    800005fc:	4605                	li	a2,1
    800005fe:	45a9                	li	a1,10
    80000600:	6388                	ld	a0,0(a5)
    80000602:	e63ff0ef          	jal	80000464 <printint>
      i += 2;
    80000606:	003a049b          	addiw	s1,s4,3
    8000060a:	b7a5                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint32), 10, 0);
    8000060c:	f8843783          	ld	a5,-120(s0)
    80000610:	00878713          	addi	a4,a5,8
    80000614:	f8e43423          	sd	a4,-120(s0)
    80000618:	4601                	li	a2,0
    8000061a:	85da                	mv	a1,s6
    8000061c:	0007e503          	lwu	a0,0(a5)
    80000620:	e45ff0ef          	jal	80000464 <printint>
    80000624:	b7b9                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 10, 0);
    80000626:	f8843783          	ld	a5,-120(s0)
    8000062a:	00878713          	addi	a4,a5,8
    8000062e:	f8e43423          	sd	a4,-120(s0)
    80000632:	4601                	li	a2,0
    80000634:	85da                	mv	a1,s6
    80000636:	6388                	ld	a0,0(a5)
    80000638:	e2dff0ef          	jal	80000464 <printint>
      i += 1;
    8000063c:	002a049b          	addiw	s1,s4,2
    80000640:	bf0d                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 10, 0);
    80000642:	f8843783          	ld	a5,-120(s0)
    80000646:	00878713          	addi	a4,a5,8
    8000064a:	f8e43423          	sd	a4,-120(s0)
    8000064e:	4601                	li	a2,0
    80000650:	45a9                	li	a1,10
    80000652:	6388                	ld	a0,0(a5)
    80000654:	e11ff0ef          	jal	80000464 <printint>
      i += 2;
    80000658:	003a049b          	addiw	s1,s4,3
    8000065c:	bf19                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint32), 16, 0);
    8000065e:	f8843783          	ld	a5,-120(s0)
    80000662:	00878713          	addi	a4,a5,8
    80000666:	f8e43423          	sd	a4,-120(s0)
    8000066a:	4601                	li	a2,0
    8000066c:	45c1                	li	a1,16
    8000066e:	0007e503          	lwu	a0,0(a5)
    80000672:	df3ff0ef          	jal	80000464 <printint>
    80000676:	bdf5                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 16, 0);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	45c1                	li	a1,16
    80000686:	6388                	ld	a0,0(a5)
    80000688:	dddff0ef          	jal	80000464 <printint>
      i += 1;
    8000068c:	002a049b          	addiw	s1,s4,2
    80000690:	b5cd                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 16, 0);
    80000692:	f8843783          	ld	a5,-120(s0)
    80000696:	00878713          	addi	a4,a5,8
    8000069a:	f8e43423          	sd	a4,-120(s0)
    8000069e:	4601                	li	a2,0
    800006a0:	45c1                	li	a1,16
    800006a2:	6388                	ld	a0,0(a5)
    800006a4:	dc1ff0ef          	jal	80000464 <printint>
      i += 2;
    800006a8:	003a049b          	addiw	s1,s4,3
    800006ac:	b5d9                	j	80000572 <printf+0x78>
    800006ae:	f466                	sd	s9,40(sp)
      printptr(va_arg(ap, uint64));
    800006b0:	f8843783          	ld	a5,-120(s0)
    800006b4:	00878713          	addi	a4,a5,8
    800006b8:	f8e43423          	sd	a4,-120(s0)
    800006bc:	0007ba83          	ld	s5,0(a5)
  consputc('0');
    800006c0:	03000513          	li	a0,48
    800006c4:	bb7ff0ef          	jal	8000027a <consputc>
  consputc('x');
    800006c8:	07800513          	li	a0,120
    800006cc:	bafff0ef          	jal	8000027a <consputc>
    800006d0:	4a41                	li	s4,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006d2:	00008c97          	auipc	s9,0x8
    800006d6:	426c8c93          	addi	s9,s9,1062 # 80008af8 <digits>
    800006da:	03cad793          	srli	a5,s5,0x3c
    800006de:	97e6                	add	a5,a5,s9
    800006e0:	0007c503          	lbu	a0,0(a5)
    800006e4:	b97ff0ef          	jal	8000027a <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006e8:	0a92                	slli	s5,s5,0x4
    800006ea:	3a7d                	addiw	s4,s4,-1
    800006ec:	fe0a17e3          	bnez	s4,800006da <printf+0x1e0>
    800006f0:	7ca2                	ld	s9,40(sp)
    800006f2:	b541                	j	80000572 <printf+0x78>
    } else if(c0 == 'c'){
      consputc(va_arg(ap, uint));
    800006f4:	f8843783          	ld	a5,-120(s0)
    800006f8:	00878713          	addi	a4,a5,8
    800006fc:	f8e43423          	sd	a4,-120(s0)
    80000700:	4388                	lw	a0,0(a5)
    80000702:	b79ff0ef          	jal	8000027a <consputc>
    80000706:	b5b5                	j	80000572 <printf+0x78>
    } else if(c0 == 's'){
      if((s = va_arg(ap, char*)) == 0)
    80000708:	f8843783          	ld	a5,-120(s0)
    8000070c:	00878713          	addi	a4,a5,8
    80000710:	f8e43423          	sd	a4,-120(s0)
    80000714:	0007ba03          	ld	s4,0(a5)
    80000718:	000a0d63          	beqz	s4,80000732 <printf+0x238>
        s = "(null)";
      for(; *s; s++)
    8000071c:	000a4503          	lbu	a0,0(s4)
    80000720:	e40509e3          	beqz	a0,80000572 <printf+0x78>
        consputc(*s);
    80000724:	b57ff0ef          	jal	8000027a <consputc>
      for(; *s; s++)
    80000728:	0a05                	addi	s4,s4,1
    8000072a:	000a4503          	lbu	a0,0(s4)
    8000072e:	f97d                	bnez	a0,80000724 <printf+0x22a>
    80000730:	b589                	j	80000572 <printf+0x78>
        s = "(null)";
    80000732:	00008a17          	auipc	s4,0x8
    80000736:	8e6a0a13          	addi	s4,s4,-1818 # 80008018 <etext+0x18>
      for(; *s; s++)
    8000073a:	02800513          	li	a0,40
    8000073e:	b7dd                	j	80000724 <printf+0x22a>
    } else if(c0 == '%'){
      consputc('%');
    80000740:	8556                	mv	a0,s5
    80000742:	b39ff0ef          	jal	8000027a <consputc>
    80000746:	b535                	j	80000572 <printf+0x78>
    80000748:	74a6                	ld	s1,104(sp)
    8000074a:	69e6                	ld	s3,88(sp)
    8000074c:	6a46                	ld	s4,80(sp)
    8000074e:	6aa6                	ld	s5,72(sp)
    80000750:	6b06                	ld	s6,64(sp)
    80000752:	7be2                	ld	s7,56(sp)
    80000754:	7c42                	ld	s8,48(sp)
    80000756:	7d02                	ld	s10,32(sp)
    80000758:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    8000075a:	00008797          	auipc	a5,0x8
    8000075e:	5fa7a783          	lw	a5,1530(a5) # 80008d54 <panicking>
    80000762:	c38d                	beqz	a5,80000784 <printf+0x28a>
    release(&pr.lock);

  return 0;
}
    80000764:	4501                	li	a0,0
    80000766:	70e6                	ld	ra,120(sp)
    80000768:	7446                	ld	s0,112(sp)
    8000076a:	7906                	ld	s2,96(sp)
    8000076c:	6129                	addi	sp,sp,192
    8000076e:	8082                	ret
    80000770:	74a6                	ld	s1,104(sp)
    80000772:	69e6                	ld	s3,88(sp)
    80000774:	6a46                	ld	s4,80(sp)
    80000776:	6aa6                	ld	s5,72(sp)
    80000778:	6b06                	ld	s6,64(sp)
    8000077a:	7be2                	ld	s7,56(sp)
    8000077c:	7c42                	ld	s8,48(sp)
    8000077e:	7d02                	ld	s10,32(sp)
    80000780:	6de2                	ld	s11,24(sp)
    80000782:	bfe1                	j	8000075a <printf+0x260>
    release(&pr.lock);
    80000784:	00010517          	auipc	a0,0x10
    80000788:	6a450513          	addi	a0,a0,1700 # 80010e28 <pr>
    8000078c:	530000ef          	jal	80000cbc <release>
  return 0;
    80000790:	bfd1                	j	80000764 <printf+0x26a>
    if(c0 == 'd'){
    80000792:	e37a8ee3          	beq	s5,s7,800005ce <printf+0xd4>
    } else if(c0 == 'l' && c1 == 'd'){
    80000796:	f94a8713          	addi	a4,s5,-108
    8000079a:	00173713          	seqz	a4,a4
    8000079e:	8636                	mv	a2,a3
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800007a0:	4781                	li	a5,0
    800007a2:	a00d                	j	800007c4 <printf+0x2ca>
    } else if(c0 == 'l' && c1 == 'd'){
    800007a4:	f94a8713          	addi	a4,s5,-108
    800007a8:	00173713          	seqz	a4,a4
    c1 = c2 = 0;
    800007ac:	8656                	mv	a2,s5
    800007ae:	86d6                	mv	a3,s5
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800007b0:	f9460793          	addi	a5,a2,-108
    800007b4:	0017b793          	seqz	a5,a5
    800007b8:	8ff9                	and	a5,a5,a4
    800007ba:	f9c68593          	addi	a1,a3,-100
    800007be:	e199                	bnez	a1,800007c4 <printf+0x2ca>
    800007c0:	e20798e3          	bnez	a5,800005f0 <printf+0xf6>
    } else if(c0 == 'u'){
    800007c4:	e58a84e3          	beq	s5,s8,8000060c <printf+0x112>
    } else if(c0 == 'l' && c1 == 'u'){
    800007c8:	f8b60593          	addi	a1,a2,-117
    800007cc:	e199                	bnez	a1,800007d2 <printf+0x2d8>
    800007ce:	e4071ce3          	bnez	a4,80000626 <printf+0x12c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800007d2:	f8b68593          	addi	a1,a3,-117
    800007d6:	e199                	bnez	a1,800007dc <printf+0x2e2>
    800007d8:	e60795e3          	bnez	a5,80000642 <printf+0x148>
    } else if(c0 == 'x'){
    800007dc:	e9aa81e3          	beq	s5,s10,8000065e <printf+0x164>
    } else if(c0 == 'l' && c1 == 'x'){
    800007e0:	f8860613          	addi	a2,a2,-120
    800007e4:	e219                	bnez	a2,800007ea <printf+0x2f0>
    800007e6:	e80719e3          	bnez	a4,80000678 <printf+0x17e>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    800007ea:	f8868693          	addi	a3,a3,-120
    800007ee:	e299                	bnez	a3,800007f4 <printf+0x2fa>
    800007f0:	ea0791e3          	bnez	a5,80000692 <printf+0x198>
    } else if(c0 == 'p'){
    800007f4:	ebba8de3          	beq	s5,s11,800006ae <printf+0x1b4>
    } else if(c0 == 'c'){
    800007f8:	06300793          	li	a5,99
    800007fc:	eefa8ce3          	beq	s5,a5,800006f4 <printf+0x1fa>
    } else if(c0 == 's'){
    80000800:	07300793          	li	a5,115
    80000804:	f0fa82e3          	beq	s5,a5,80000708 <printf+0x20e>
    } else if(c0 == '%'){
    80000808:	02500793          	li	a5,37
    8000080c:	f2fa8ae3          	beq	s5,a5,80000740 <printf+0x246>
    } else if(c0 == 0){
    80000810:	f60a80e3          	beqz	s5,80000770 <printf+0x276>
      consputc('%');
    80000814:	02500513          	li	a0,37
    80000818:	a63ff0ef          	jal	8000027a <consputc>
      consputc(c0);
    8000081c:	8556                	mv	a0,s5
    8000081e:	a5dff0ef          	jal	8000027a <consputc>
    80000822:	bb81                	j	80000572 <printf+0x78>

0000000080000824 <panic>:

void
panic(char *s)
{
    80000824:	1101                	addi	sp,sp,-32
    80000826:	ec06                	sd	ra,24(sp)
    80000828:	e822                	sd	s0,16(sp)
    8000082a:	e426                	sd	s1,8(sp)
    8000082c:	e04a                	sd	s2,0(sp)
    8000082e:	1000                	addi	s0,sp,32
    80000830:	892a                	mv	s2,a0
  panicking = 1;
    80000832:	4485                	li	s1,1
    80000834:	00008797          	auipc	a5,0x8
    80000838:	5297a023          	sw	s1,1312(a5) # 80008d54 <panicking>
  printf("panic: ");
    8000083c:	00007517          	auipc	a0,0x7
    80000840:	7e450513          	addi	a0,a0,2020 # 80008020 <etext+0x20>
    80000844:	cb7ff0ef          	jal	800004fa <printf>
  printf("%s\n", s);
    80000848:	85ca                	mv	a1,s2
    8000084a:	00007517          	auipc	a0,0x7
    8000084e:	7de50513          	addi	a0,a0,2014 # 80008028 <etext+0x28>
    80000852:	ca9ff0ef          	jal	800004fa <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000856:	00008797          	auipc	a5,0x8
    8000085a:	4e97ad23          	sw	s1,1274(a5) # 80008d50 <panicked>
  for(;;)
    8000085e:	a001                	j	8000085e <panic+0x3a>

0000000080000860 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000860:	1141                	addi	sp,sp,-16
    80000862:	e406                	sd	ra,8(sp)
    80000864:	e022                	sd	s0,0(sp)
    80000866:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000868:	00007597          	auipc	a1,0x7
    8000086c:	7c858593          	addi	a1,a1,1992 # 80008030 <etext+0x30>
    80000870:	00010517          	auipc	a0,0x10
    80000874:	5b850513          	addi	a0,a0,1464 # 80010e28 <pr>
    80000878:	326000ef          	jal	80000b9e <initlock>
}
    8000087c:	60a2                	ld	ra,8(sp)
    8000087e:	6402                	ld	s0,0(sp)
    80000880:	0141                	addi	sp,sp,16
    80000882:	8082                	ret

0000000080000884 <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    80000884:	1141                	addi	sp,sp,-16
    80000886:	e406                	sd	ra,8(sp)
    80000888:	e022                	sd	s0,0(sp)
    8000088a:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000088c:	100007b7          	lui	a5,0x10000
    80000890:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000894:	10000737          	lui	a4,0x10000
    80000898:	f8000693          	li	a3,-128
    8000089c:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800008a0:	468d                	li	a3,3
    800008a2:	10000637          	lui	a2,0x10000
    800008a6:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800008aa:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800008ae:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800008b2:	8732                	mv	a4,a2
    800008b4:	461d                	li	a2,7
    800008b6:	00c70123          	sb	a2,2(a4)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800008ba:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    800008be:	00007597          	auipc	a1,0x7
    800008c2:	77a58593          	addi	a1,a1,1914 # 80008038 <etext+0x38>
    800008c6:	00010517          	auipc	a0,0x10
    800008ca:	57a50513          	addi	a0,a0,1402 # 80010e40 <tx_lock>
    800008ce:	2d0000ef          	jal	80000b9e <initlock>
}
    800008d2:	60a2                	ld	ra,8(sp)
    800008d4:	6402                	ld	s0,0(sp)
    800008d6:	0141                	addi	sp,sp,16
    800008d8:	8082                	ret

00000000800008da <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    800008da:	715d                	addi	sp,sp,-80
    800008dc:	e486                	sd	ra,72(sp)
    800008de:	e0a2                	sd	s0,64(sp)
    800008e0:	fc26                	sd	s1,56(sp)
    800008e2:	ec56                	sd	s5,24(sp)
    800008e4:	0880                	addi	s0,sp,80
    800008e6:	8aaa                	mv	s5,a0
    800008e8:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    800008ea:	00010517          	auipc	a0,0x10
    800008ee:	55650513          	addi	a0,a0,1366 # 80010e40 <tx_lock>
    800008f2:	336000ef          	jal	80000c28 <acquire>

  int i = 0;
  while(i < n){ 
    800008f6:	06905063          	blez	s1,80000956 <uartwrite+0x7c>
    800008fa:	f84a                	sd	s2,48(sp)
    800008fc:	f44e                	sd	s3,40(sp)
    800008fe:	f052                	sd	s4,32(sp)
    80000900:	e85a                	sd	s6,16(sp)
    80000902:	e45e                	sd	s7,8(sp)
    80000904:	8a56                	mv	s4,s5
    80000906:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    80000908:	00008497          	auipc	s1,0x8
    8000090c:	45448493          	addi	s1,s1,1108 # 80008d5c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000910:	00010997          	auipc	s3,0x10
    80000914:	53098993          	addi	s3,s3,1328 # 80010e40 <tx_lock>
    80000918:	00008917          	auipc	s2,0x8
    8000091c:	44090913          	addi	s2,s2,1088 # 80008d58 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    80000920:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    80000924:	4b05                	li	s6,1
    80000926:	a005                	j	80000946 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    80000928:	85ce                	mv	a1,s3
    8000092a:	854a                	mv	a0,s2
    8000092c:	666010ef          	jal	80001f92 <sleep>
    while(tx_busy != 0){
    80000930:	409c                	lw	a5,0(s1)
    80000932:	fbfd                	bnez	a5,80000928 <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    80000934:	000a4783          	lbu	a5,0(s4)
    80000938:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    8000093c:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    80000940:	0a05                	addi	s4,s4,1
    80000942:	015a0563          	beq	s4,s5,8000094c <uartwrite+0x72>
    while(tx_busy != 0){
    80000946:	409c                	lw	a5,0(s1)
    80000948:	f3e5                	bnez	a5,80000928 <uartwrite+0x4e>
    8000094a:	b7ed                	j	80000934 <uartwrite+0x5a>
    8000094c:	7942                	ld	s2,48(sp)
    8000094e:	79a2                	ld	s3,40(sp)
    80000950:	7a02                	ld	s4,32(sp)
    80000952:	6b42                	ld	s6,16(sp)
    80000954:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80000956:	00010517          	auipc	a0,0x10
    8000095a:	4ea50513          	addi	a0,a0,1258 # 80010e40 <tx_lock>
    8000095e:	35e000ef          	jal	80000cbc <release>
}
    80000962:	60a6                	ld	ra,72(sp)
    80000964:	6406                	ld	s0,64(sp)
    80000966:	74e2                	ld	s1,56(sp)
    80000968:	6ae2                	ld	s5,24(sp)
    8000096a:	6161                	addi	sp,sp,80
    8000096c:	8082                	ret

000000008000096e <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000096e:	1101                	addi	sp,sp,-32
    80000970:	ec06                	sd	ra,24(sp)
    80000972:	e822                	sd	s0,16(sp)
    80000974:	e426                	sd	s1,8(sp)
    80000976:	1000                	addi	s0,sp,32
    80000978:	84aa                	mv	s1,a0
  if(panicking == 0)
    8000097a:	00008797          	auipc	a5,0x8
    8000097e:	3da7a783          	lw	a5,986(a5) # 80008d54 <panicking>
    80000982:	cf95                	beqz	a5,800009be <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000984:	00008797          	auipc	a5,0x8
    80000988:	3cc7a783          	lw	a5,972(a5) # 80008d50 <panicked>
    8000098c:	ef85                	bnez	a5,800009c4 <uartputc_sync+0x56>
    for(;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000098e:	10000737          	lui	a4,0x10000
    80000992:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000994:	00074783          	lbu	a5,0(a4)
    80000998:	0207f793          	andi	a5,a5,32
    8000099c:	dfe5                	beqz	a5,80000994 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000099e:	0ff4f513          	zext.b	a0,s1
    800009a2:	100007b7          	lui	a5,0x10000
    800009a6:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    800009aa:	00008797          	auipc	a5,0x8
    800009ae:	3aa7a783          	lw	a5,938(a5) # 80008d54 <panicking>
    800009b2:	cb91                	beqz	a5,800009c6 <uartputc_sync+0x58>
    pop_off();
}
    800009b4:	60e2                	ld	ra,24(sp)
    800009b6:	6442                	ld	s0,16(sp)
    800009b8:	64a2                	ld	s1,8(sp)
    800009ba:	6105                	addi	sp,sp,32
    800009bc:	8082                	ret
    push_off();
    800009be:	226000ef          	jal	80000be4 <push_off>
    800009c2:	b7c9                	j	80000984 <uartputc_sync+0x16>
    for(;;)
    800009c4:	a001                	j	800009c4 <uartputc_sync+0x56>
    pop_off();
    800009c6:	2a6000ef          	jal	80000c6c <pop_off>
}
    800009ca:	b7ed                	j	800009b4 <uartputc_sync+0x46>

00000000800009cc <uartgetc>:

// try to read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009cc:	1141                	addi	sp,sp,-16
    800009ce:	e406                	sd	ra,8(sp)
    800009d0:	e022                	sd	s0,0(sp)
    800009d2:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    800009d4:	100007b7          	lui	a5,0x10000
    800009d8:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009dc:	8b85                	andi	a5,a5,1
    800009de:	cb89                	beqz	a5,800009f0 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009e0:	100007b7          	lui	a5,0x10000
    800009e4:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009e8:	60a2                	ld	ra,8(sp)
    800009ea:	6402                	ld	s0,0(sp)
    800009ec:	0141                	addi	sp,sp,16
    800009ee:	8082                	ret
    return -1;
    800009f0:	557d                	li	a0,-1
    800009f2:	bfdd                	j	800009e8 <uartgetc+0x1c>

00000000800009f4 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009f4:	1101                	addi	sp,sp,-32
    800009f6:	ec06                	sd	ra,24(sp)
    800009f8:	e822                	sd	s0,16(sp)
    800009fa:	e426                	sd	s1,8(sp)
    800009fc:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800009fe:	100007b7          	lui	a5,0x10000
    80000a02:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>

  acquire(&tx_lock);
    80000a06:	00010517          	auipc	a0,0x10
    80000a0a:	43a50513          	addi	a0,a0,1082 # 80010e40 <tx_lock>
    80000a0e:	21a000ef          	jal	80000c28 <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    80000a12:	100007b7          	lui	a5,0x10000
    80000a16:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000a1a:	0207f793          	andi	a5,a5,32
    80000a1e:	ef99                	bnez	a5,80000a3c <uartintr+0x48>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    80000a20:	00010517          	auipc	a0,0x10
    80000a24:	42050513          	addi	a0,a0,1056 # 80010e40 <tx_lock>
    80000a28:	294000ef          	jal	80000cbc <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a2c:	54fd                	li	s1,-1
    int c = uartgetc();
    80000a2e:	f9fff0ef          	jal	800009cc <uartgetc>
    if(c == -1)
    80000a32:	02950063          	beq	a0,s1,80000a52 <uartintr+0x5e>
      break;
    consoleintr(c);
    80000a36:	877ff0ef          	jal	800002ac <consoleintr>
  while(1){
    80000a3a:	bfd5                	j	80000a2e <uartintr+0x3a>
    tx_busy = 0;
    80000a3c:	00008797          	auipc	a5,0x8
    80000a40:	3207a023          	sw	zero,800(a5) # 80008d5c <tx_busy>
    wakeup(&tx_chan);
    80000a44:	00008517          	auipc	a0,0x8
    80000a48:	31450513          	addi	a0,a0,788 # 80008d58 <tx_chan>
    80000a4c:	592010ef          	jal	80001fde <wakeup>
    80000a50:	bfc1                	j	80000a20 <uartintr+0x2c>
  }
}
    80000a52:	60e2                	ld	ra,24(sp)
    80000a54:	6442                	ld	s0,16(sp)
    80000a56:	64a2                	ld	s1,8(sp)
    80000a58:	6105                	addi	sp,sp,32
    80000a5a:	8082                	ret

0000000080000a5c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a5c:	1101                	addi	sp,sp,-32
    80000a5e:	ec06                	sd	ra,24(sp)
    80000a60:	e822                	sd	s0,16(sp)
    80000a62:	e426                	sd	s1,8(sp)
    80000a64:	e04a                	sd	s2,0(sp)
    80000a66:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a68:	0002e797          	auipc	a5,0x2e
    80000a6c:	d7878793          	addi	a5,a5,-648 # 8002e7e0 <end>
    80000a70:	00f53733          	sltu	a4,a0,a5
    80000a74:	47c5                	li	a5,17
    80000a76:	07ee                	slli	a5,a5,0x1b
    80000a78:	17fd                	addi	a5,a5,-1
    80000a7a:	00a7b7b3          	sltu	a5,a5,a0
    80000a7e:	8fd9                	or	a5,a5,a4
    80000a80:	ef95                	bnez	a5,80000abc <kfree+0x60>
    80000a82:	84aa                	mv	s1,a0
    80000a84:	03451793          	slli	a5,a0,0x34
    80000a88:	eb95                	bnez	a5,80000abc <kfree+0x60>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a8a:	6605                	lui	a2,0x1
    80000a8c:	4585                	li	a1,1
    80000a8e:	26a000ef          	jal	80000cf8 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a92:	00010917          	auipc	s2,0x10
    80000a96:	3c690913          	addi	s2,s2,966 # 80010e58 <kmem>
    80000a9a:	854a                	mv	a0,s2
    80000a9c:	18c000ef          	jal	80000c28 <acquire>
  r->next = kmem.freelist;
    80000aa0:	01893783          	ld	a5,24(s2)
    80000aa4:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000aa6:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000aaa:	854a                	mv	a0,s2
    80000aac:	210000ef          	jal	80000cbc <release>
}
    80000ab0:	60e2                	ld	ra,24(sp)
    80000ab2:	6442                	ld	s0,16(sp)
    80000ab4:	64a2                	ld	s1,8(sp)
    80000ab6:	6902                	ld	s2,0(sp)
    80000ab8:	6105                	addi	sp,sp,32
    80000aba:	8082                	ret
    panic("kfree");
    80000abc:	00007517          	auipc	a0,0x7
    80000ac0:	58450513          	addi	a0,a0,1412 # 80008040 <etext+0x40>
    80000ac4:	d61ff0ef          	jal	80000824 <panic>

0000000080000ac8 <freerange>:
{
    80000ac8:	7179                	addi	sp,sp,-48
    80000aca:	f406                	sd	ra,40(sp)
    80000acc:	f022                	sd	s0,32(sp)
    80000ace:	ec26                	sd	s1,24(sp)
    80000ad0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ad2:	6785                	lui	a5,0x1
    80000ad4:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ad8:	00e504b3          	add	s1,a0,a4
    80000adc:	777d                	lui	a4,0xfffff
    80000ade:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ae0:	94be                	add	s1,s1,a5
    80000ae2:	0295e263          	bltu	a1,s1,80000b06 <freerange+0x3e>
    80000ae6:	e84a                	sd	s2,16(sp)
    80000ae8:	e44e                	sd	s3,8(sp)
    80000aea:	e052                	sd	s4,0(sp)
    80000aec:	892e                	mv	s2,a1
    kfree(p);
    80000aee:	8a3a                	mv	s4,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000af0:	89be                	mv	s3,a5
    kfree(p);
    80000af2:	01448533          	add	a0,s1,s4
    80000af6:	f67ff0ef          	jal	80000a5c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000afa:	94ce                	add	s1,s1,s3
    80000afc:	fe997be3          	bgeu	s2,s1,80000af2 <freerange+0x2a>
    80000b00:	6942                	ld	s2,16(sp)
    80000b02:	69a2                	ld	s3,8(sp)
    80000b04:	6a02                	ld	s4,0(sp)
}
    80000b06:	70a2                	ld	ra,40(sp)
    80000b08:	7402                	ld	s0,32(sp)
    80000b0a:	64e2                	ld	s1,24(sp)
    80000b0c:	6145                	addi	sp,sp,48
    80000b0e:	8082                	ret

0000000080000b10 <kinit>:
{
    80000b10:	1141                	addi	sp,sp,-16
    80000b12:	e406                	sd	ra,8(sp)
    80000b14:	e022                	sd	s0,0(sp)
    80000b16:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b18:	00007597          	auipc	a1,0x7
    80000b1c:	53058593          	addi	a1,a1,1328 # 80008048 <etext+0x48>
    80000b20:	00010517          	auipc	a0,0x10
    80000b24:	33850513          	addi	a0,a0,824 # 80010e58 <kmem>
    80000b28:	076000ef          	jal	80000b9e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b2c:	45c5                	li	a1,17
    80000b2e:	05ee                	slli	a1,a1,0x1b
    80000b30:	0002e517          	auipc	a0,0x2e
    80000b34:	cb050513          	addi	a0,a0,-848 # 8002e7e0 <end>
    80000b38:	f91ff0ef          	jal	80000ac8 <freerange>
}
    80000b3c:	60a2                	ld	ra,8(sp)
    80000b3e:	6402                	ld	s0,0(sp)
    80000b40:	0141                	addi	sp,sp,16
    80000b42:	8082                	ret

0000000080000b44 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b44:	1101                	addi	sp,sp,-32
    80000b46:	ec06                	sd	ra,24(sp)
    80000b48:	e822                	sd	s0,16(sp)
    80000b4a:	e426                	sd	s1,8(sp)
    80000b4c:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b4e:	00010517          	auipc	a0,0x10
    80000b52:	30a50513          	addi	a0,a0,778 # 80010e58 <kmem>
    80000b56:	0d2000ef          	jal	80000c28 <acquire>
  r = kmem.freelist;
    80000b5a:	00010497          	auipc	s1,0x10
    80000b5e:	3164b483          	ld	s1,790(s1) # 80010e70 <kmem+0x18>
  if(r)
    80000b62:	c49d                	beqz	s1,80000b90 <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b64:	609c                	ld	a5,0(s1)
    80000b66:	00010717          	auipc	a4,0x10
    80000b6a:	30f73523          	sd	a5,778(a4) # 80010e70 <kmem+0x18>
  release(&kmem.lock);
    80000b6e:	00010517          	auipc	a0,0x10
    80000b72:	2ea50513          	addi	a0,a0,746 # 80010e58 <kmem>
    80000b76:	146000ef          	jal	80000cbc <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b7a:	6605                	lui	a2,0x1
    80000b7c:	4595                	li	a1,5
    80000b7e:	8526                	mv	a0,s1
    80000b80:	178000ef          	jal	80000cf8 <memset>
  return (void*)r;
}
    80000b84:	8526                	mv	a0,s1
    80000b86:	60e2                	ld	ra,24(sp)
    80000b88:	6442                	ld	s0,16(sp)
    80000b8a:	64a2                	ld	s1,8(sp)
    80000b8c:	6105                	addi	sp,sp,32
    80000b8e:	8082                	ret
  release(&kmem.lock);
    80000b90:	00010517          	auipc	a0,0x10
    80000b94:	2c850513          	addi	a0,a0,712 # 80010e58 <kmem>
    80000b98:	124000ef          	jal	80000cbc <release>
  if(r)
    80000b9c:	b7e5                	j	80000b84 <kalloc+0x40>

0000000080000b9e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b9e:	1141                	addi	sp,sp,-16
    80000ba0:	e406                	sd	ra,8(sp)
    80000ba2:	e022                	sd	s0,0(sp)
    80000ba4:	0800                	addi	s0,sp,16
  lk->name = name;
    80000ba6:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000ba8:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bac:	00053823          	sd	zero,16(a0)
}
    80000bb0:	60a2                	ld	ra,8(sp)
    80000bb2:	6402                	ld	s0,0(sp)
    80000bb4:	0141                	addi	sp,sp,16
    80000bb6:	8082                	ret

0000000080000bb8 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bb8:	411c                	lw	a5,0(a0)
    80000bba:	e399                	bnez	a5,80000bc0 <holding+0x8>
    80000bbc:	4501                	li	a0,0
  return r;
}
    80000bbe:	8082                	ret
{
    80000bc0:	1101                	addi	sp,sp,-32
    80000bc2:	ec06                	sd	ra,24(sp)
    80000bc4:	e822                	sd	s0,16(sp)
    80000bc6:	e426                	sd	s1,8(sp)
    80000bc8:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bca:	691c                	ld	a5,16(a0)
    80000bcc:	84be                	mv	s1,a5
    80000bce:	549000ef          	jal	80001916 <mycpu>
    80000bd2:	40a48533          	sub	a0,s1,a0
    80000bd6:	00153513          	seqz	a0,a0
}
    80000bda:	60e2                	ld	ra,24(sp)
    80000bdc:	6442                	ld	s0,16(sp)
    80000bde:	64a2                	ld	s1,8(sp)
    80000be0:	6105                	addi	sp,sp,32
    80000be2:	8082                	ret

0000000080000be4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000be4:	1101                	addi	sp,sp,-32
    80000be6:	ec06                	sd	ra,24(sp)
    80000be8:	e822                	sd	s0,16(sp)
    80000bea:	e426                	sd	s1,8(sp)
    80000bec:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bee:	100027f3          	csrr	a5,sstatus
    80000bf2:	84be                	mv	s1,a5
    80000bf4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bf8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bfa:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000bfe:	519000ef          	jal	80001916 <mycpu>
    80000c02:	5d3c                	lw	a5,120(a0)
    80000c04:	cb99                	beqz	a5,80000c1a <push_off+0x36>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c06:	511000ef          	jal	80001916 <mycpu>
    80000c0a:	5d3c                	lw	a5,120(a0)
    80000c0c:	2785                	addiw	a5,a5,1
    80000c0e:	dd3c                	sw	a5,120(a0)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    mycpu()->intena = old;
    80000c1a:	4fd000ef          	jal	80001916 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c1e:	0014d793          	srli	a5,s1,0x1
    80000c22:	8b85                	andi	a5,a5,1
    80000c24:	dd7c                	sw	a5,124(a0)
    80000c26:	b7c5                	j	80000c06 <push_off+0x22>

0000000080000c28 <acquire>:
{
    80000c28:	1101                	addi	sp,sp,-32
    80000c2a:	ec06                	sd	ra,24(sp)
    80000c2c:	e822                	sd	s0,16(sp)
    80000c2e:	e426                	sd	s1,8(sp)
    80000c30:	1000                	addi	s0,sp,32
    80000c32:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c34:	fb1ff0ef          	jal	80000be4 <push_off>
  if(holding(lk))
    80000c38:	8526                	mv	a0,s1
    80000c3a:	f7fff0ef          	jal	80000bb8 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c3e:	4705                	li	a4,1
  if(holding(lk))
    80000c40:	e105                	bnez	a0,80000c60 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c42:	87ba                	mv	a5,a4
    80000c44:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c48:	2781                	sext.w	a5,a5
    80000c4a:	ffe5                	bnez	a5,80000c42 <acquire+0x1a>
  __sync_synchronize();
    80000c4c:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c50:	4c7000ef          	jal	80001916 <mycpu>
    80000c54:	e888                	sd	a0,16(s1)
}
    80000c56:	60e2                	ld	ra,24(sp)
    80000c58:	6442                	ld	s0,16(sp)
    80000c5a:	64a2                	ld	s1,8(sp)
    80000c5c:	6105                	addi	sp,sp,32
    80000c5e:	8082                	ret
    panic("acquire");
    80000c60:	00007517          	auipc	a0,0x7
    80000c64:	3f050513          	addi	a0,a0,1008 # 80008050 <etext+0x50>
    80000c68:	bbdff0ef          	jal	80000824 <panic>

0000000080000c6c <pop_off>:

void
pop_off(void)
{
    80000c6c:	1141                	addi	sp,sp,-16
    80000c6e:	e406                	sd	ra,8(sp)
    80000c70:	e022                	sd	s0,0(sp)
    80000c72:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c74:	4a3000ef          	jal	80001916 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c78:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c7c:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c7e:	e39d                	bnez	a5,80000ca4 <pop_off+0x38>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c80:	5d3c                	lw	a5,120(a0)
    80000c82:	02f05763          	blez	a5,80000cb0 <pop_off+0x44>
    panic("pop_off");
  c->noff -= 1;
    80000c86:	37fd                	addiw	a5,a5,-1
    80000c88:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c8a:	eb89                	bnez	a5,80000c9c <pop_off+0x30>
    80000c8c:	5d7c                	lw	a5,124(a0)
    80000c8e:	c799                	beqz	a5,80000c9c <pop_off+0x30>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c90:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c94:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c98:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c9c:	60a2                	ld	ra,8(sp)
    80000c9e:	6402                	ld	s0,0(sp)
    80000ca0:	0141                	addi	sp,sp,16
    80000ca2:	8082                	ret
    panic("pop_off - interruptible");
    80000ca4:	00007517          	auipc	a0,0x7
    80000ca8:	3b450513          	addi	a0,a0,948 # 80008058 <etext+0x58>
    80000cac:	b79ff0ef          	jal	80000824 <panic>
    panic("pop_off");
    80000cb0:	00007517          	auipc	a0,0x7
    80000cb4:	3c050513          	addi	a0,a0,960 # 80008070 <etext+0x70>
    80000cb8:	b6dff0ef          	jal	80000824 <panic>

0000000080000cbc <release>:
{
    80000cbc:	1101                	addi	sp,sp,-32
    80000cbe:	ec06                	sd	ra,24(sp)
    80000cc0:	e822                	sd	s0,16(sp)
    80000cc2:	e426                	sd	s1,8(sp)
    80000cc4:	1000                	addi	s0,sp,32
    80000cc6:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cc8:	ef1ff0ef          	jal	80000bb8 <holding>
    80000ccc:	c105                	beqz	a0,80000cec <release+0x30>
  lk->cpu = 0;
    80000cce:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cd2:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000cd6:	0310000f          	fence	rw,w
    80000cda:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000cde:	f8fff0ef          	jal	80000c6c <pop_off>
}
    80000ce2:	60e2                	ld	ra,24(sp)
    80000ce4:	6442                	ld	s0,16(sp)
    80000ce6:	64a2                	ld	s1,8(sp)
    80000ce8:	6105                	addi	sp,sp,32
    80000cea:	8082                	ret
    panic("release");
    80000cec:	00007517          	auipc	a0,0x7
    80000cf0:	38c50513          	addi	a0,a0,908 # 80008078 <etext+0x78>
    80000cf4:	b31ff0ef          	jal	80000824 <panic>

0000000080000cf8 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cf8:	1141                	addi	sp,sp,-16
    80000cfa:	e406                	sd	ra,8(sp)
    80000cfc:	e022                	sd	s0,0(sp)
    80000cfe:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d00:	ca19                	beqz	a2,80000d16 <memset+0x1e>
    80000d02:	87aa                	mv	a5,a0
    80000d04:	1602                	slli	a2,a2,0x20
    80000d06:	9201                	srli	a2,a2,0x20
    80000d08:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d0c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d10:	0785                	addi	a5,a5,1
    80000d12:	fee79de3          	bne	a5,a4,80000d0c <memset+0x14>
  }
  return dst;
}
    80000d16:	60a2                	ld	ra,8(sp)
    80000d18:	6402                	ld	s0,0(sp)
    80000d1a:	0141                	addi	sp,sp,16
    80000d1c:	8082                	ret

0000000080000d1e <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d1e:	1141                	addi	sp,sp,-16
    80000d20:	e406                	sd	ra,8(sp)
    80000d22:	e022                	sd	s0,0(sp)
    80000d24:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d26:	c61d                	beqz	a2,80000d54 <memcmp+0x36>
    80000d28:	1602                	slli	a2,a2,0x20
    80000d2a:	9201                	srli	a2,a2,0x20
    80000d2c:	00c506b3          	add	a3,a0,a2
    if(*s1 != *s2)
    80000d30:	00054783          	lbu	a5,0(a0)
    80000d34:	0005c703          	lbu	a4,0(a1)
    80000d38:	00e79863          	bne	a5,a4,80000d48 <memcmp+0x2a>
      return *s1 - *s2;
    s1++, s2++;
    80000d3c:	0505                	addi	a0,a0,1
    80000d3e:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d40:	fed518e3          	bne	a0,a3,80000d30 <memcmp+0x12>
  }

  return 0;
    80000d44:	4501                	li	a0,0
    80000d46:	a019                	j	80000d4c <memcmp+0x2e>
      return *s1 - *s2;
    80000d48:	40e7853b          	subw	a0,a5,a4
}
    80000d4c:	60a2                	ld	ra,8(sp)
    80000d4e:	6402                	ld	s0,0(sp)
    80000d50:	0141                	addi	sp,sp,16
    80000d52:	8082                	ret
  return 0;
    80000d54:	4501                	li	a0,0
    80000d56:	bfdd                	j	80000d4c <memcmp+0x2e>

0000000080000d58 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d58:	1141                	addi	sp,sp,-16
    80000d5a:	e406                	sd	ra,8(sp)
    80000d5c:	e022                	sd	s0,0(sp)
    80000d5e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d60:	c205                	beqz	a2,80000d80 <memmove+0x28>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d62:	02a5e363          	bltu	a1,a0,80000d88 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d66:	1602                	slli	a2,a2,0x20
    80000d68:	9201                	srli	a2,a2,0x20
    80000d6a:	00c587b3          	add	a5,a1,a2
{
    80000d6e:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d70:	0585                	addi	a1,a1,1
    80000d72:	0705                	addi	a4,a4,1
    80000d74:	fff5c683          	lbu	a3,-1(a1)
    80000d78:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d7c:	feb79ae3          	bne	a5,a1,80000d70 <memmove+0x18>

  return dst;
}
    80000d80:	60a2                	ld	ra,8(sp)
    80000d82:	6402                	ld	s0,0(sp)
    80000d84:	0141                	addi	sp,sp,16
    80000d86:	8082                	ret
  if(s < d && s + n > d){
    80000d88:	02061693          	slli	a3,a2,0x20
    80000d8c:	9281                	srli	a3,a3,0x20
    80000d8e:	00d58733          	add	a4,a1,a3
    80000d92:	fce57ae3          	bgeu	a0,a4,80000d66 <memmove+0xe>
    d += n;
    80000d96:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d98:	fff6079b          	addiw	a5,a2,-1 # fff <_entry-0x7ffff001>
    80000d9c:	1782                	slli	a5,a5,0x20
    80000d9e:	9381                	srli	a5,a5,0x20
    80000da0:	fff7c793          	not	a5,a5
    80000da4:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000da6:	177d                	addi	a4,a4,-1
    80000da8:	16fd                	addi	a3,a3,-1
    80000daa:	00074603          	lbu	a2,0(a4)
    80000dae:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000db2:	fee79ae3          	bne	a5,a4,80000da6 <memmove+0x4e>
    80000db6:	b7e9                	j	80000d80 <memmove+0x28>

0000000080000db8 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000db8:	1141                	addi	sp,sp,-16
    80000dba:	e406                	sd	ra,8(sp)
    80000dbc:	e022                	sd	s0,0(sp)
    80000dbe:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000dc0:	f99ff0ef          	jal	80000d58 <memmove>
}
    80000dc4:	60a2                	ld	ra,8(sp)
    80000dc6:	6402                	ld	s0,0(sp)
    80000dc8:	0141                	addi	sp,sp,16
    80000dca:	8082                	ret

0000000080000dcc <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000dcc:	1141                	addi	sp,sp,-16
    80000dce:	e406                	sd	ra,8(sp)
    80000dd0:	e022                	sd	s0,0(sp)
    80000dd2:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dd4:	ce11                	beqz	a2,80000df0 <strncmp+0x24>
    80000dd6:	00054783          	lbu	a5,0(a0)
    80000dda:	cf89                	beqz	a5,80000df4 <strncmp+0x28>
    80000ddc:	0005c703          	lbu	a4,0(a1)
    80000de0:	00f71a63          	bne	a4,a5,80000df4 <strncmp+0x28>
    n--, p++, q++;
    80000de4:	367d                	addiw	a2,a2,-1
    80000de6:	0505                	addi	a0,a0,1
    80000de8:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dea:	f675                	bnez	a2,80000dd6 <strncmp+0xa>
  if(n == 0)
    return 0;
    80000dec:	4501                	li	a0,0
    80000dee:	a801                	j	80000dfe <strncmp+0x32>
    80000df0:	4501                	li	a0,0
    80000df2:	a031                	j	80000dfe <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000df4:	00054503          	lbu	a0,0(a0)
    80000df8:	0005c783          	lbu	a5,0(a1)
    80000dfc:	9d1d                	subw	a0,a0,a5
}
    80000dfe:	60a2                	ld	ra,8(sp)
    80000e00:	6402                	ld	s0,0(sp)
    80000e02:	0141                	addi	sp,sp,16
    80000e04:	8082                	ret

0000000080000e06 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e06:	1141                	addi	sp,sp,-16
    80000e08:	e406                	sd	ra,8(sp)
    80000e0a:	e022                	sd	s0,0(sp)
    80000e0c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e0e:	87aa                	mv	a5,a0
    80000e10:	a011                	j	80000e14 <strncpy+0xe>
    80000e12:	8636                	mv	a2,a3
    80000e14:	02c05863          	blez	a2,80000e44 <strncpy+0x3e>
    80000e18:	fff6069b          	addiw	a3,a2,-1
    80000e1c:	8836                	mv	a6,a3
    80000e1e:	0785                	addi	a5,a5,1
    80000e20:	0005c703          	lbu	a4,0(a1)
    80000e24:	fee78fa3          	sb	a4,-1(a5)
    80000e28:	0585                	addi	a1,a1,1
    80000e2a:	f765                	bnez	a4,80000e12 <strncpy+0xc>
    ;
  while(n-- > 0)
    80000e2c:	873e                	mv	a4,a5
    80000e2e:	01005b63          	blez	a6,80000e44 <strncpy+0x3e>
    80000e32:	9fb1                	addw	a5,a5,a2
    80000e34:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000e36:	0705                	addi	a4,a4,1
    80000e38:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e3c:	40e786bb          	subw	a3,a5,a4
    80000e40:	fed04be3          	bgtz	a3,80000e36 <strncpy+0x30>
  return os;
}
    80000e44:	60a2                	ld	ra,8(sp)
    80000e46:	6402                	ld	s0,0(sp)
    80000e48:	0141                	addi	sp,sp,16
    80000e4a:	8082                	ret

0000000080000e4c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e4c:	1141                	addi	sp,sp,-16
    80000e4e:	e406                	sd	ra,8(sp)
    80000e50:	e022                	sd	s0,0(sp)
    80000e52:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e54:	02c05363          	blez	a2,80000e7a <safestrcpy+0x2e>
    80000e58:	fff6069b          	addiw	a3,a2,-1
    80000e5c:	1682                	slli	a3,a3,0x20
    80000e5e:	9281                	srli	a3,a3,0x20
    80000e60:	96ae                	add	a3,a3,a1
    80000e62:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e64:	00d58963          	beq	a1,a3,80000e76 <safestrcpy+0x2a>
    80000e68:	0585                	addi	a1,a1,1
    80000e6a:	0785                	addi	a5,a5,1
    80000e6c:	fff5c703          	lbu	a4,-1(a1)
    80000e70:	fee78fa3          	sb	a4,-1(a5)
    80000e74:	fb65                	bnez	a4,80000e64 <safestrcpy+0x18>
    ;
  *s = 0;
    80000e76:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e7a:	60a2                	ld	ra,8(sp)
    80000e7c:	6402                	ld	s0,0(sp)
    80000e7e:	0141                	addi	sp,sp,16
    80000e80:	8082                	ret

0000000080000e82 <strlen>:

int
strlen(const char *s)
{
    80000e82:	1141                	addi	sp,sp,-16
    80000e84:	e406                	sd	ra,8(sp)
    80000e86:	e022                	sd	s0,0(sp)
    80000e88:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e8a:	00054783          	lbu	a5,0(a0)
    80000e8e:	cf91                	beqz	a5,80000eaa <strlen+0x28>
    80000e90:	00150793          	addi	a5,a0,1
    80000e94:	86be                	mv	a3,a5
    80000e96:	0785                	addi	a5,a5,1
    80000e98:	fff7c703          	lbu	a4,-1(a5)
    80000e9c:	ff65                	bnez	a4,80000e94 <strlen+0x12>
    80000e9e:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
    80000ea2:	60a2                	ld	ra,8(sp)
    80000ea4:	6402                	ld	s0,0(sp)
    80000ea6:	0141                	addi	sp,sp,16
    80000ea8:	8082                	ret
  for(n = 0; s[n]; n++)
    80000eaa:	4501                	li	a0,0
    80000eac:	bfdd                	j	80000ea2 <strlen+0x20>

0000000080000eae <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000eae:	1141                	addi	sp,sp,-16
    80000eb0:	e406                	sd	ra,8(sp)
    80000eb2:	e022                	sd	s0,0(sp)
    80000eb4:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000eb6:	24d000ef          	jal	80001902 <cpuid>

    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000eba:	00008717          	auipc	a4,0x8
    80000ebe:	ea670713          	addi	a4,a4,-346 # 80008d60 <started>
  if(cpuid() == 0){
    80000ec2:	c51d                	beqz	a0,80000ef0 <main+0x42>
    while(started == 0)
    80000ec4:	431c                	lw	a5,0(a4)
    80000ec6:	2781                	sext.w	a5,a5
    80000ec8:	dff5                	beqz	a5,80000ec4 <main+0x16>
      ;
    __sync_synchronize();
    80000eca:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000ece:	235000ef          	jal	80001902 <cpuid>
    80000ed2:	85aa                	mv	a1,a0
    80000ed4:	00007517          	auipc	a0,0x7
    80000ed8:	1c450513          	addi	a0,a0,452 # 80008098 <etext+0x98>
    80000edc:	e1eff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000ee0:	088000ef          	jal	80000f68 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ee4:	5ce010ef          	jal	800024b2 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ee8:	151040ef          	jal	80005838 <plicinithart>
  }

  scheduler();        
    80000eec:	70d000ef          	jal	80001df8 <scheduler>
    consoleinit();
    80000ef0:	d30ff0ef          	jal	80000420 <consoleinit>
    printfinit();
    80000ef4:	96dff0ef          	jal	80000860 <printfinit>
    printf("\n");
    80000ef8:	00008517          	auipc	a0,0x8
    80000efc:	86850513          	addi	a0,a0,-1944 # 80008760 <etext+0x760>
    80000f00:	dfaff0ef          	jal	800004fa <printf>
    printf("xv6 kernel is booting\n");
    80000f04:	00007517          	auipc	a0,0x7
    80000f08:	17c50513          	addi	a0,a0,380 # 80008080 <etext+0x80>
    80000f0c:	deeff0ef          	jal	800004fa <printf>
    printf("\n");
    80000f10:	00008517          	auipc	a0,0x8
    80000f14:	85050513          	addi	a0,a0,-1968 # 80008760 <etext+0x760>
    80000f18:	de2ff0ef          	jal	800004fa <printf>
    kinit();         // physical page allocator
    80000f1c:	bf5ff0ef          	jal	80000b10 <kinit>
    kvminit();       // create kernel page table
    80000f20:	2d4000ef          	jal	800011f4 <kvminit>
    kvminithart();   // turn on paging
    80000f24:	044000ef          	jal	80000f68 <kvminithart>
    procinit();      // process table
    80000f28:	125000ef          	jal	8000184c <procinit>
    trapinit();      // trap vectors
    80000f2c:	562010ef          	jal	8000248e <trapinit>
    trapinithart();  // install kernel trap vector
    80000f30:	582010ef          	jal	800024b2 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f34:	0eb040ef          	jal	8000581e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f38:	101040ef          	jal	80005838 <plicinithart>
    binit();         // buffer cache
    80000f3c:	413010ef          	jal	80002b4e <binit>
    iinit();         // inode table
    80000f40:	164020ef          	jal	800030a4 <iinit>
    fileinit();      // file table
    80000f44:	16c030ef          	jal	800040b0 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f48:	1e1040ef          	jal	80005928 <virtio_disk_init>
    audit_init();          // Must be before auth_init (auth logs events)
    80000f4c:	644050ef          	jal	80006590 <audit_init>
    auth_init();           // Load default user credentials
    80000f50:	6eb040ef          	jal	80005e3a <auth_init>
    userinit();      // first user process
    80000f54:	4ad000ef          	jal	80001c00 <userinit>
    __sync_synchronize();
    80000f58:	0330000f          	fence	rw,rw
    started = 1;
    80000f5c:	4785                	li	a5,1
    80000f5e:	00008717          	auipc	a4,0x8
    80000f62:	e0f72123          	sw	a5,-510(a4) # 80008d60 <started>
    80000f66:	b759                	j	80000eec <main+0x3e>

0000000080000f68 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000f68:	1141                	addi	sp,sp,-16
    80000f6a:	e406                	sd	ra,8(sp)
    80000f6c:	e022                	sd	s0,0(sp)
    80000f6e:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f70:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f74:	00008797          	auipc	a5,0x8
    80000f78:	df47b783          	ld	a5,-524(a5) # 80008d68 <kernel_pagetable>
    80000f7c:	83b1                	srli	a5,a5,0xc
    80000f7e:	577d                	li	a4,-1
    80000f80:	177e                	slli	a4,a4,0x3f
    80000f82:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f84:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f88:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f8c:	60a2                	ld	ra,8(sp)
    80000f8e:	6402                	ld	s0,0(sp)
    80000f90:	0141                	addi	sp,sp,16
    80000f92:	8082                	ret

0000000080000f94 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f94:	7139                	addi	sp,sp,-64
    80000f96:	fc06                	sd	ra,56(sp)
    80000f98:	f822                	sd	s0,48(sp)
    80000f9a:	f426                	sd	s1,40(sp)
    80000f9c:	f04a                	sd	s2,32(sp)
    80000f9e:	ec4e                	sd	s3,24(sp)
    80000fa0:	e852                	sd	s4,16(sp)
    80000fa2:	e456                	sd	s5,8(sp)
    80000fa4:	e05a                	sd	s6,0(sp)
    80000fa6:	0080                	addi	s0,sp,64
    80000fa8:	84aa                	mv	s1,a0
    80000faa:	89ae                	mv	s3,a1
    80000fac:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    80000fae:	57fd                	li	a5,-1
    80000fb0:	83e9                	srli	a5,a5,0x1a
    80000fb2:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fb4:	4ab1                	li	s5,12
  if(va >= MAXVA)
    80000fb6:	04b7e263          	bltu	a5,a1,80000ffa <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    80000fba:	0149d933          	srl	s2,s3,s4
    80000fbe:	1ff97913          	andi	s2,s2,511
    80000fc2:	090e                	slli	s2,s2,0x3
    80000fc4:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000fc6:	00093483          	ld	s1,0(s2)
    80000fca:	0014f793          	andi	a5,s1,1
    80000fce:	cf85                	beqz	a5,80001006 <walk+0x72>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fd0:	80a9                	srli	s1,s1,0xa
    80000fd2:	04b2                	slli	s1,s1,0xc
  for(int level = 2; level > 0; level--) {
    80000fd4:	3a5d                	addiw	s4,s4,-9
    80000fd6:	ff5a12e3          	bne	s4,s5,80000fba <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    80000fda:	00c9d513          	srli	a0,s3,0xc
    80000fde:	1ff57513          	andi	a0,a0,511
    80000fe2:	050e                	slli	a0,a0,0x3
    80000fe4:	9526                	add	a0,a0,s1
}
    80000fe6:	70e2                	ld	ra,56(sp)
    80000fe8:	7442                	ld	s0,48(sp)
    80000fea:	74a2                	ld	s1,40(sp)
    80000fec:	7902                	ld	s2,32(sp)
    80000fee:	69e2                	ld	s3,24(sp)
    80000ff0:	6a42                	ld	s4,16(sp)
    80000ff2:	6aa2                	ld	s5,8(sp)
    80000ff4:	6b02                	ld	s6,0(sp)
    80000ff6:	6121                	addi	sp,sp,64
    80000ff8:	8082                	ret
    panic("walk");
    80000ffa:	00007517          	auipc	a0,0x7
    80000ffe:	0b650513          	addi	a0,a0,182 # 800080b0 <etext+0xb0>
    80001002:	823ff0ef          	jal	80000824 <panic>
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001006:	020b0263          	beqz	s6,8000102a <walk+0x96>
    8000100a:	b3bff0ef          	jal	80000b44 <kalloc>
    8000100e:	84aa                	mv	s1,a0
    80001010:	d979                	beqz	a0,80000fe6 <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    80001012:	6605                	lui	a2,0x1
    80001014:	4581                	li	a1,0
    80001016:	ce3ff0ef          	jal	80000cf8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000101a:	00c4d793          	srli	a5,s1,0xc
    8000101e:	07aa                	slli	a5,a5,0xa
    80001020:	0017e793          	ori	a5,a5,1
    80001024:	00f93023          	sd	a5,0(s2)
    80001028:	b775                	j	80000fd4 <walk+0x40>
        return 0;
    8000102a:	4501                	li	a0,0
    8000102c:	bf6d                	j	80000fe6 <walk+0x52>

000000008000102e <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000102e:	57fd                	li	a5,-1
    80001030:	83e9                	srli	a5,a5,0x1a
    80001032:	00b7f463          	bgeu	a5,a1,8000103a <walkaddr+0xc>
    return 0;
    80001036:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001038:	8082                	ret
{
    8000103a:	1141                	addi	sp,sp,-16
    8000103c:	e406                	sd	ra,8(sp)
    8000103e:	e022                	sd	s0,0(sp)
    80001040:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001042:	4601                	li	a2,0
    80001044:	f51ff0ef          	jal	80000f94 <walk>
  if(pte == 0)
    80001048:	c901                	beqz	a0,80001058 <walkaddr+0x2a>
  if((*pte & PTE_V) == 0)
    8000104a:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000104c:	0117f693          	andi	a3,a5,17
    80001050:	4745                	li	a4,17
    return 0;
    80001052:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001054:	00e68663          	beq	a3,a4,80001060 <walkaddr+0x32>
}
    80001058:	60a2                	ld	ra,8(sp)
    8000105a:	6402                	ld	s0,0(sp)
    8000105c:	0141                	addi	sp,sp,16
    8000105e:	8082                	ret
  pa = PTE2PA(*pte);
    80001060:	83a9                	srli	a5,a5,0xa
    80001062:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001066:	bfcd                	j	80001058 <walkaddr+0x2a>

0000000080001068 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001068:	715d                	addi	sp,sp,-80
    8000106a:	e486                	sd	ra,72(sp)
    8000106c:	e0a2                	sd	s0,64(sp)
    8000106e:	fc26                	sd	s1,56(sp)
    80001070:	f84a                	sd	s2,48(sp)
    80001072:	f44e                	sd	s3,40(sp)
    80001074:	f052                	sd	s4,32(sp)
    80001076:	ec56                	sd	s5,24(sp)
    80001078:	e85a                	sd	s6,16(sp)
    8000107a:	e45e                	sd	s7,8(sp)
    8000107c:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000107e:	03459793          	slli	a5,a1,0x34
    80001082:	eba1                	bnez	a5,800010d2 <mappages+0x6a>
    80001084:	8a2a                	mv	s4,a0
    80001086:	8aba                	mv	s5,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001088:	03461793          	slli	a5,a2,0x34
    8000108c:	eba9                	bnez	a5,800010de <mappages+0x76>
    panic("mappages: size not aligned");

  if(size == 0)
    8000108e:	ce31                	beqz	a2,800010ea <mappages+0x82>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80001090:	80060613          	addi	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    80001094:	80060613          	addi	a2,a2,-2048
    80001098:	00b60933          	add	s2,a2,a1
  a = va;
    8000109c:	84ae                	mv	s1,a1
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
    8000109e:	4b05                	li	s6,1
    800010a0:	40b689b3          	sub	s3,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010a4:	6b85                	lui	s7,0x1
    if((pte = walk(pagetable, a, 1)) == 0)
    800010a6:	865a                	mv	a2,s6
    800010a8:	85a6                	mv	a1,s1
    800010aa:	8552                	mv	a0,s4
    800010ac:	ee9ff0ef          	jal	80000f94 <walk>
    800010b0:	c929                	beqz	a0,80001102 <mappages+0x9a>
    if(*pte & PTE_V)
    800010b2:	611c                	ld	a5,0(a0)
    800010b4:	8b85                	andi	a5,a5,1
    800010b6:	e3a1                	bnez	a5,800010f6 <mappages+0x8e>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010b8:	013487b3          	add	a5,s1,s3
    800010bc:	83b1                	srli	a5,a5,0xc
    800010be:	07aa                	slli	a5,a5,0xa
    800010c0:	0157e7b3          	or	a5,a5,s5
    800010c4:	0017e793          	ori	a5,a5,1
    800010c8:	e11c                	sd	a5,0(a0)
    if(a == last)
    800010ca:	05248863          	beq	s1,s2,8000111a <mappages+0xb2>
    a += PGSIZE;
    800010ce:	94de                	add	s1,s1,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d0:	bfd9                	j	800010a6 <mappages+0x3e>
    panic("mappages: va not aligned");
    800010d2:	00007517          	auipc	a0,0x7
    800010d6:	fe650513          	addi	a0,a0,-26 # 800080b8 <etext+0xb8>
    800010da:	f4aff0ef          	jal	80000824 <panic>
    panic("mappages: size not aligned");
    800010de:	00007517          	auipc	a0,0x7
    800010e2:	ffa50513          	addi	a0,a0,-6 # 800080d8 <etext+0xd8>
    800010e6:	f3eff0ef          	jal	80000824 <panic>
    panic("mappages: size");
    800010ea:	00007517          	auipc	a0,0x7
    800010ee:	00e50513          	addi	a0,a0,14 # 800080f8 <etext+0xf8>
    800010f2:	f32ff0ef          	jal	80000824 <panic>
      panic("mappages: remap");
    800010f6:	00007517          	auipc	a0,0x7
    800010fa:	01250513          	addi	a0,a0,18 # 80008108 <etext+0x108>
    800010fe:	f26ff0ef          	jal	80000824 <panic>
      return -1;
    80001102:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001104:	60a6                	ld	ra,72(sp)
    80001106:	6406                	ld	s0,64(sp)
    80001108:	74e2                	ld	s1,56(sp)
    8000110a:	7942                	ld	s2,48(sp)
    8000110c:	79a2                	ld	s3,40(sp)
    8000110e:	7a02                	ld	s4,32(sp)
    80001110:	6ae2                	ld	s5,24(sp)
    80001112:	6b42                	ld	s6,16(sp)
    80001114:	6ba2                	ld	s7,8(sp)
    80001116:	6161                	addi	sp,sp,80
    80001118:	8082                	ret
  return 0;
    8000111a:	4501                	li	a0,0
    8000111c:	b7e5                	j	80001104 <mappages+0x9c>

000000008000111e <kvmmap>:
{
    8000111e:	1141                	addi	sp,sp,-16
    80001120:	e406                	sd	ra,8(sp)
    80001122:	e022                	sd	s0,0(sp)
    80001124:	0800                	addi	s0,sp,16
    80001126:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001128:	86b2                	mv	a3,a2
    8000112a:	863e                	mv	a2,a5
    8000112c:	f3dff0ef          	jal	80001068 <mappages>
    80001130:	e509                	bnez	a0,8000113a <kvmmap+0x1c>
}
    80001132:	60a2                	ld	ra,8(sp)
    80001134:	6402                	ld	s0,0(sp)
    80001136:	0141                	addi	sp,sp,16
    80001138:	8082                	ret
    panic("kvmmap");
    8000113a:	00007517          	auipc	a0,0x7
    8000113e:	fde50513          	addi	a0,a0,-34 # 80008118 <etext+0x118>
    80001142:	ee2ff0ef          	jal	80000824 <panic>

0000000080001146 <kvmmake>:
{
    80001146:	1101                	addi	sp,sp,-32
    80001148:	ec06                	sd	ra,24(sp)
    8000114a:	e822                	sd	s0,16(sp)
    8000114c:	e426                	sd	s1,8(sp)
    8000114e:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001150:	9f5ff0ef          	jal	80000b44 <kalloc>
    80001154:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001156:	6605                	lui	a2,0x1
    80001158:	4581                	li	a1,0
    8000115a:	b9fff0ef          	jal	80000cf8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000115e:	4719                	li	a4,6
    80001160:	6685                	lui	a3,0x1
    80001162:	10000637          	lui	a2,0x10000
    80001166:	85b2                	mv	a1,a2
    80001168:	8526                	mv	a0,s1
    8000116a:	fb5ff0ef          	jal	8000111e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000116e:	4719                	li	a4,6
    80001170:	6685                	lui	a3,0x1
    80001172:	10001637          	lui	a2,0x10001
    80001176:	85b2                	mv	a1,a2
    80001178:	8526                	mv	a0,s1
    8000117a:	fa5ff0ef          	jal	8000111e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    8000117e:	4719                	li	a4,6
    80001180:	040006b7          	lui	a3,0x4000
    80001184:	0c000637          	lui	a2,0xc000
    80001188:	85b2                	mv	a1,a2
    8000118a:	8526                	mv	a0,s1
    8000118c:	f93ff0ef          	jal	8000111e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001190:	4729                	li	a4,10
    80001192:	80007697          	auipc	a3,0x80007
    80001196:	e6e68693          	addi	a3,a3,-402 # 8000 <_entry-0x7fff8000>
    8000119a:	4605                	li	a2,1
    8000119c:	067e                	slli	a2,a2,0x1f
    8000119e:	85b2                	mv	a1,a2
    800011a0:	8526                	mv	a0,s1
    800011a2:	f7dff0ef          	jal	8000111e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011a6:	4719                	li	a4,6
    800011a8:	00007697          	auipc	a3,0x7
    800011ac:	e5868693          	addi	a3,a3,-424 # 80008000 <etext>
    800011b0:	47c5                	li	a5,17
    800011b2:	07ee                	slli	a5,a5,0x1b
    800011b4:	40d786b3          	sub	a3,a5,a3
    800011b8:	00007617          	auipc	a2,0x7
    800011bc:	e4860613          	addi	a2,a2,-440 # 80008000 <etext>
    800011c0:	85b2                	mv	a1,a2
    800011c2:	8526                	mv	a0,s1
    800011c4:	f5bff0ef          	jal	8000111e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011c8:	4729                	li	a4,10
    800011ca:	6685                	lui	a3,0x1
    800011cc:	00006617          	auipc	a2,0x6
    800011d0:	e3460613          	addi	a2,a2,-460 # 80007000 <_trampoline>
    800011d4:	040005b7          	lui	a1,0x4000
    800011d8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800011da:	05b2                	slli	a1,a1,0xc
    800011dc:	8526                	mv	a0,s1
    800011de:	f41ff0ef          	jal	8000111e <kvmmap>
  proc_mapstacks(kpgtbl);
    800011e2:	8526                	mv	a0,s1
    800011e4:	5c4000ef          	jal	800017a8 <proc_mapstacks>
}
    800011e8:	8526                	mv	a0,s1
    800011ea:	60e2                	ld	ra,24(sp)
    800011ec:	6442                	ld	s0,16(sp)
    800011ee:	64a2                	ld	s1,8(sp)
    800011f0:	6105                	addi	sp,sp,32
    800011f2:	8082                	ret

00000000800011f4 <kvminit>:
{
    800011f4:	1141                	addi	sp,sp,-16
    800011f6:	e406                	sd	ra,8(sp)
    800011f8:	e022                	sd	s0,0(sp)
    800011fa:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011fc:	f4bff0ef          	jal	80001146 <kvmmake>
    80001200:	00008797          	auipc	a5,0x8
    80001204:	b6a7b423          	sd	a0,-1176(a5) # 80008d68 <kernel_pagetable>
}
    80001208:	60a2                	ld	ra,8(sp)
    8000120a:	6402                	ld	s0,0(sp)
    8000120c:	0141                	addi	sp,sp,16
    8000120e:	8082                	ret

0000000080001210 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001210:	1101                	addi	sp,sp,-32
    80001212:	ec06                	sd	ra,24(sp)
    80001214:	e822                	sd	s0,16(sp)
    80001216:	e426                	sd	s1,8(sp)
    80001218:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000121a:	92bff0ef          	jal	80000b44 <kalloc>
    8000121e:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001220:	c509                	beqz	a0,8000122a <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001222:	6605                	lui	a2,0x1
    80001224:	4581                	li	a1,0
    80001226:	ad3ff0ef          	jal	80000cf8 <memset>
  return pagetable;
}
    8000122a:	8526                	mv	a0,s1
    8000122c:	60e2                	ld	ra,24(sp)
    8000122e:	6442                	ld	s0,16(sp)
    80001230:	64a2                	ld	s1,8(sp)
    80001232:	6105                	addi	sp,sp,32
    80001234:	8082                	ret

0000000080001236 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001236:	7139                	addi	sp,sp,-64
    80001238:	fc06                	sd	ra,56(sp)
    8000123a:	f822                	sd	s0,48(sp)
    8000123c:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000123e:	03459793          	slli	a5,a1,0x34
    80001242:	e38d                	bnez	a5,80001264 <uvmunmap+0x2e>
    80001244:	f04a                	sd	s2,32(sp)
    80001246:	ec4e                	sd	s3,24(sp)
    80001248:	e852                	sd	s4,16(sp)
    8000124a:	e456                	sd	s5,8(sp)
    8000124c:	e05a                	sd	s6,0(sp)
    8000124e:	8a2a                	mv	s4,a0
    80001250:	892e                	mv	s2,a1
    80001252:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001254:	0632                	slli	a2,a2,0xc
    80001256:	00b609b3          	add	s3,a2,a1
    8000125a:	6b05                	lui	s6,0x1
    8000125c:	0535f963          	bgeu	a1,s3,800012ae <uvmunmap+0x78>
    80001260:	f426                	sd	s1,40(sp)
    80001262:	a015                	j	80001286 <uvmunmap+0x50>
    80001264:	f426                	sd	s1,40(sp)
    80001266:	f04a                	sd	s2,32(sp)
    80001268:	ec4e                	sd	s3,24(sp)
    8000126a:	e852                	sd	s4,16(sp)
    8000126c:	e456                	sd	s5,8(sp)
    8000126e:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    80001270:	00007517          	auipc	a0,0x7
    80001274:	eb050513          	addi	a0,a0,-336 # 80008120 <etext+0x120>
    80001278:	dacff0ef          	jal	80000824 <panic>
      continue;
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000127c:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001280:	995a                	add	s2,s2,s6
    80001282:	03397563          	bgeu	s2,s3,800012ac <uvmunmap+0x76>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    80001286:	4601                	li	a2,0
    80001288:	85ca                	mv	a1,s2
    8000128a:	8552                	mv	a0,s4
    8000128c:	d09ff0ef          	jal	80000f94 <walk>
    80001290:	84aa                	mv	s1,a0
    80001292:	d57d                	beqz	a0,80001280 <uvmunmap+0x4a>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    80001294:	611c                	ld	a5,0(a0)
    80001296:	0017f713          	andi	a4,a5,1
    8000129a:	d37d                	beqz	a4,80001280 <uvmunmap+0x4a>
    if(do_free){
    8000129c:	fe0a80e3          	beqz	s5,8000127c <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    800012a0:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    800012a2:	00c79513          	slli	a0,a5,0xc
    800012a6:	fb6ff0ef          	jal	80000a5c <kfree>
    800012aa:	bfc9                	j	8000127c <uvmunmap+0x46>
    800012ac:	74a2                	ld	s1,40(sp)
    800012ae:	7902                	ld	s2,32(sp)
    800012b0:	69e2                	ld	s3,24(sp)
    800012b2:	6a42                	ld	s4,16(sp)
    800012b4:	6aa2                	ld	s5,8(sp)
    800012b6:	6b02                	ld	s6,0(sp)
  }
}
    800012b8:	70e2                	ld	ra,56(sp)
    800012ba:	7442                	ld	s0,48(sp)
    800012bc:	6121                	addi	sp,sp,64
    800012be:	8082                	ret

00000000800012c0 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800012c0:	1101                	addi	sp,sp,-32
    800012c2:	ec06                	sd	ra,24(sp)
    800012c4:	e822                	sd	s0,16(sp)
    800012c6:	e426                	sd	s1,8(sp)
    800012c8:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800012ca:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800012cc:	00b67d63          	bgeu	a2,a1,800012e6 <uvmdealloc+0x26>
    800012d0:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800012d2:	6785                	lui	a5,0x1
    800012d4:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012d6:	00f60733          	add	a4,a2,a5
    800012da:	76fd                	lui	a3,0xfffff
    800012dc:	8f75                	and	a4,a4,a3
    800012de:	97ae                	add	a5,a5,a1
    800012e0:	8ff5                	and	a5,a5,a3
    800012e2:	00f76863          	bltu	a4,a5,800012f2 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800012e6:	8526                	mv	a0,s1
    800012e8:	60e2                	ld	ra,24(sp)
    800012ea:	6442                	ld	s0,16(sp)
    800012ec:	64a2                	ld	s1,8(sp)
    800012ee:	6105                	addi	sp,sp,32
    800012f0:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800012f2:	8f99                	sub	a5,a5,a4
    800012f4:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800012f6:	4685                	li	a3,1
    800012f8:	0007861b          	sext.w	a2,a5
    800012fc:	85ba                	mv	a1,a4
    800012fe:	f39ff0ef          	jal	80001236 <uvmunmap>
    80001302:	b7d5                	j	800012e6 <uvmdealloc+0x26>

0000000080001304 <uvmalloc>:
  if(newsz < oldsz)
    80001304:	0ab66163          	bltu	a2,a1,800013a6 <uvmalloc+0xa2>
{
    80001308:	715d                	addi	sp,sp,-80
    8000130a:	e486                	sd	ra,72(sp)
    8000130c:	e0a2                	sd	s0,64(sp)
    8000130e:	f84a                	sd	s2,48(sp)
    80001310:	f052                	sd	s4,32(sp)
    80001312:	ec56                	sd	s5,24(sp)
    80001314:	e45e                	sd	s7,8(sp)
    80001316:	0880                	addi	s0,sp,80
    80001318:	8aaa                	mv	s5,a0
    8000131a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000131c:	6785                	lui	a5,0x1
    8000131e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001320:	95be                	add	a1,a1,a5
    80001322:	77fd                	lui	a5,0xfffff
    80001324:	00f5f933          	and	s2,a1,a5
    80001328:	8bca                	mv	s7,s2
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000132a:	08c97063          	bgeu	s2,a2,800013aa <uvmalloc+0xa6>
    8000132e:	fc26                	sd	s1,56(sp)
    80001330:	f44e                	sd	s3,40(sp)
    80001332:	e85a                	sd	s6,16(sp)
    memset(mem, 0, PGSIZE);
    80001334:	6985                	lui	s3,0x1
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001336:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000133a:	80bff0ef          	jal	80000b44 <kalloc>
    8000133e:	84aa                	mv	s1,a0
    if(mem == 0){
    80001340:	c50d                	beqz	a0,8000136a <uvmalloc+0x66>
    memset(mem, 0, PGSIZE);
    80001342:	864e                	mv	a2,s3
    80001344:	4581                	li	a1,0
    80001346:	9b3ff0ef          	jal	80000cf8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000134a:	875a                	mv	a4,s6
    8000134c:	86a6                	mv	a3,s1
    8000134e:	864e                	mv	a2,s3
    80001350:	85ca                	mv	a1,s2
    80001352:	8556                	mv	a0,s5
    80001354:	d15ff0ef          	jal	80001068 <mappages>
    80001358:	e915                	bnez	a0,8000138c <uvmalloc+0x88>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000135a:	994e                	add	s2,s2,s3
    8000135c:	fd496fe3          	bltu	s2,s4,8000133a <uvmalloc+0x36>
  return newsz;
    80001360:	8552                	mv	a0,s4
    80001362:	74e2                	ld	s1,56(sp)
    80001364:	79a2                	ld	s3,40(sp)
    80001366:	6b42                	ld	s6,16(sp)
    80001368:	a811                	j	8000137c <uvmalloc+0x78>
      uvmdealloc(pagetable, a, oldsz);
    8000136a:	865e                	mv	a2,s7
    8000136c:	85ca                	mv	a1,s2
    8000136e:	8556                	mv	a0,s5
    80001370:	f51ff0ef          	jal	800012c0 <uvmdealloc>
      return 0;
    80001374:	4501                	li	a0,0
    80001376:	74e2                	ld	s1,56(sp)
    80001378:	79a2                	ld	s3,40(sp)
    8000137a:	6b42                	ld	s6,16(sp)
}
    8000137c:	60a6                	ld	ra,72(sp)
    8000137e:	6406                	ld	s0,64(sp)
    80001380:	7942                	ld	s2,48(sp)
    80001382:	7a02                	ld	s4,32(sp)
    80001384:	6ae2                	ld	s5,24(sp)
    80001386:	6ba2                	ld	s7,8(sp)
    80001388:	6161                	addi	sp,sp,80
    8000138a:	8082                	ret
      kfree(mem);
    8000138c:	8526                	mv	a0,s1
    8000138e:	eceff0ef          	jal	80000a5c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001392:	865e                	mv	a2,s7
    80001394:	85ca                	mv	a1,s2
    80001396:	8556                	mv	a0,s5
    80001398:	f29ff0ef          	jal	800012c0 <uvmdealloc>
      return 0;
    8000139c:	4501                	li	a0,0
    8000139e:	74e2                	ld	s1,56(sp)
    800013a0:	79a2                	ld	s3,40(sp)
    800013a2:	6b42                	ld	s6,16(sp)
    800013a4:	bfe1                	j	8000137c <uvmalloc+0x78>
    return oldsz;
    800013a6:	852e                	mv	a0,a1
}
    800013a8:	8082                	ret
  return newsz;
    800013aa:	8532                	mv	a0,a2
    800013ac:	bfc1                	j	8000137c <uvmalloc+0x78>

00000000800013ae <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800013ae:	7179                	addi	sp,sp,-48
    800013b0:	f406                	sd	ra,40(sp)
    800013b2:	f022                	sd	s0,32(sp)
    800013b4:	ec26                	sd	s1,24(sp)
    800013b6:	e84a                	sd	s2,16(sp)
    800013b8:	e44e                	sd	s3,8(sp)
    800013ba:	1800                	addi	s0,sp,48
    800013bc:	89aa                	mv	s3,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800013be:	84aa                	mv	s1,a0
    800013c0:	6905                	lui	s2,0x1
    800013c2:	992a                	add	s2,s2,a0
    800013c4:	a811                	j	800013d8 <freewalk+0x2a>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if(pte & PTE_V){
      panic("freewalk: leaf");
    800013c6:	00007517          	auipc	a0,0x7
    800013ca:	d7250513          	addi	a0,a0,-654 # 80008138 <etext+0x138>
    800013ce:	c56ff0ef          	jal	80000824 <panic>
  for(int i = 0; i < 512; i++){
    800013d2:	04a1                	addi	s1,s1,8
    800013d4:	03248163          	beq	s1,s2,800013f6 <freewalk+0x48>
    pte_t pte = pagetable[i];
    800013d8:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013da:	0017f713          	andi	a4,a5,1
    800013de:	db75                	beqz	a4,800013d2 <freewalk+0x24>
    800013e0:	00e7f713          	andi	a4,a5,14
    800013e4:	f36d                	bnez	a4,800013c6 <freewalk+0x18>
      uint64 child = PTE2PA(pte);
    800013e6:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800013e8:	00c79513          	slli	a0,a5,0xc
    800013ec:	fc3ff0ef          	jal	800013ae <freewalk>
      pagetable[i] = 0;
    800013f0:	0004b023          	sd	zero,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013f4:	bff9                	j	800013d2 <freewalk+0x24>
    }
  }
  kfree((void*)pagetable);
    800013f6:	854e                	mv	a0,s3
    800013f8:	e64ff0ef          	jal	80000a5c <kfree>
}
    800013fc:	70a2                	ld	ra,40(sp)
    800013fe:	7402                	ld	s0,32(sp)
    80001400:	64e2                	ld	s1,24(sp)
    80001402:	6942                	ld	s2,16(sp)
    80001404:	69a2                	ld	s3,8(sp)
    80001406:	6145                	addi	sp,sp,48
    80001408:	8082                	ret

000000008000140a <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000140a:	1101                	addi	sp,sp,-32
    8000140c:	ec06                	sd	ra,24(sp)
    8000140e:	e822                	sd	s0,16(sp)
    80001410:	e426                	sd	s1,8(sp)
    80001412:	1000                	addi	s0,sp,32
    80001414:	84aa                	mv	s1,a0
  if(sz > 0)
    80001416:	e989                	bnez	a1,80001428 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001418:	8526                	mv	a0,s1
    8000141a:	f95ff0ef          	jal	800013ae <freewalk>
}
    8000141e:	60e2                	ld	ra,24(sp)
    80001420:	6442                	ld	s0,16(sp)
    80001422:	64a2                	ld	s1,8(sp)
    80001424:	6105                	addi	sp,sp,32
    80001426:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001428:	6785                	lui	a5,0x1
    8000142a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000142c:	95be                	add	a1,a1,a5
    8000142e:	4685                	li	a3,1
    80001430:	00c5d613          	srli	a2,a1,0xc
    80001434:	4581                	li	a1,0
    80001436:	e01ff0ef          	jal	80001236 <uvmunmap>
    8000143a:	bff9                	j	80001418 <uvmfree+0xe>

000000008000143c <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000143c:	ca59                	beqz	a2,800014d2 <uvmcopy+0x96>
{
    8000143e:	715d                	addi	sp,sp,-80
    80001440:	e486                	sd	ra,72(sp)
    80001442:	e0a2                	sd	s0,64(sp)
    80001444:	fc26                	sd	s1,56(sp)
    80001446:	f84a                	sd	s2,48(sp)
    80001448:	f44e                	sd	s3,40(sp)
    8000144a:	f052                	sd	s4,32(sp)
    8000144c:	ec56                	sd	s5,24(sp)
    8000144e:	e85a                	sd	s6,16(sp)
    80001450:	e45e                	sd	s7,8(sp)
    80001452:	0880                	addi	s0,sp,80
    80001454:	8b2a                	mv	s6,a0
    80001456:	8bae                	mv	s7,a1
    80001458:	8ab2                	mv	s5,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000145a:	4481                	li	s1,0
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000145c:	6a05                	lui	s4,0x1
    8000145e:	a021                	j	80001466 <uvmcopy+0x2a>
  for(i = 0; i < sz; i += PGSIZE){
    80001460:	94d2                	add	s1,s1,s4
    80001462:	0554fc63          	bgeu	s1,s5,800014ba <uvmcopy+0x7e>
    if((pte = walk(old, i, 0)) == 0)
    80001466:	4601                	li	a2,0
    80001468:	85a6                	mv	a1,s1
    8000146a:	855a                	mv	a0,s6
    8000146c:	b29ff0ef          	jal	80000f94 <walk>
    80001470:	d965                	beqz	a0,80001460 <uvmcopy+0x24>
    if((*pte & PTE_V) == 0)
    80001472:	00053983          	ld	s3,0(a0)
    80001476:	0019f793          	andi	a5,s3,1
    8000147a:	d3fd                	beqz	a5,80001460 <uvmcopy+0x24>
    if((mem = kalloc()) == 0)
    8000147c:	ec8ff0ef          	jal	80000b44 <kalloc>
    80001480:	892a                	mv	s2,a0
    80001482:	c11d                	beqz	a0,800014a8 <uvmcopy+0x6c>
    pa = PTE2PA(*pte);
    80001484:	00a9d593          	srli	a1,s3,0xa
    memmove(mem, (char*)pa, PGSIZE);
    80001488:	8652                	mv	a2,s4
    8000148a:	05b2                	slli	a1,a1,0xc
    8000148c:	8cdff0ef          	jal	80000d58 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001490:	3ff9f713          	andi	a4,s3,1023
    80001494:	86ca                	mv	a3,s2
    80001496:	8652                	mv	a2,s4
    80001498:	85a6                	mv	a1,s1
    8000149a:	855e                	mv	a0,s7
    8000149c:	bcdff0ef          	jal	80001068 <mappages>
    800014a0:	d161                	beqz	a0,80001460 <uvmcopy+0x24>
      kfree(mem);
    800014a2:	854a                	mv	a0,s2
    800014a4:	db8ff0ef          	jal	80000a5c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800014a8:	4685                	li	a3,1
    800014aa:	00c4d613          	srli	a2,s1,0xc
    800014ae:	4581                	li	a1,0
    800014b0:	855e                	mv	a0,s7
    800014b2:	d85ff0ef          	jal	80001236 <uvmunmap>
  return -1;
    800014b6:	557d                	li	a0,-1
    800014b8:	a011                	j	800014bc <uvmcopy+0x80>
  return 0;
    800014ba:	4501                	li	a0,0
}
    800014bc:	60a6                	ld	ra,72(sp)
    800014be:	6406                	ld	s0,64(sp)
    800014c0:	74e2                	ld	s1,56(sp)
    800014c2:	7942                	ld	s2,48(sp)
    800014c4:	79a2                	ld	s3,40(sp)
    800014c6:	7a02                	ld	s4,32(sp)
    800014c8:	6ae2                	ld	s5,24(sp)
    800014ca:	6b42                	ld	s6,16(sp)
    800014cc:	6ba2                	ld	s7,8(sp)
    800014ce:	6161                	addi	sp,sp,80
    800014d0:	8082                	ret
  return 0;
    800014d2:	4501                	li	a0,0
}
    800014d4:	8082                	ret

00000000800014d6 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800014d6:	1141                	addi	sp,sp,-16
    800014d8:	e406                	sd	ra,8(sp)
    800014da:	e022                	sd	s0,0(sp)
    800014dc:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800014de:	4601                	li	a2,0
    800014e0:	ab5ff0ef          	jal	80000f94 <walk>
  if(pte == 0)
    800014e4:	c901                	beqz	a0,800014f4 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800014e6:	611c                	ld	a5,0(a0)
    800014e8:	9bbd                	andi	a5,a5,-17
    800014ea:	e11c                	sd	a5,0(a0)
}
    800014ec:	60a2                	ld	ra,8(sp)
    800014ee:	6402                	ld	s0,0(sp)
    800014f0:	0141                	addi	sp,sp,16
    800014f2:	8082                	ret
    panic("uvmclear");
    800014f4:	00007517          	auipc	a0,0x7
    800014f8:	c5450513          	addi	a0,a0,-940 # 80008148 <etext+0x148>
    800014fc:	b28ff0ef          	jal	80000824 <panic>

0000000080001500 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001500:	cac5                	beqz	a3,800015b0 <copyinstr+0xb0>
{
    80001502:	715d                	addi	sp,sp,-80
    80001504:	e486                	sd	ra,72(sp)
    80001506:	e0a2                	sd	s0,64(sp)
    80001508:	fc26                	sd	s1,56(sp)
    8000150a:	f84a                	sd	s2,48(sp)
    8000150c:	f44e                	sd	s3,40(sp)
    8000150e:	f052                	sd	s4,32(sp)
    80001510:	ec56                	sd	s5,24(sp)
    80001512:	e85a                	sd	s6,16(sp)
    80001514:	e45e                	sd	s7,8(sp)
    80001516:	0880                	addi	s0,sp,80
    80001518:	8aaa                	mv	s5,a0
    8000151a:	84ae                	mv	s1,a1
    8000151c:	8bb2                	mv	s7,a2
    8000151e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001520:	7b7d                	lui	s6,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001522:	6a05                	lui	s4,0x1
    80001524:	a82d                	j	8000155e <copyinstr+0x5e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001526:	00078023          	sb	zero,0(a5)
        got_null = 1;
    8000152a:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000152c:	0017c793          	xori	a5,a5,1
    80001530:	40f0053b          	negw	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001534:	60a6                	ld	ra,72(sp)
    80001536:	6406                	ld	s0,64(sp)
    80001538:	74e2                	ld	s1,56(sp)
    8000153a:	7942                	ld	s2,48(sp)
    8000153c:	79a2                	ld	s3,40(sp)
    8000153e:	7a02                	ld	s4,32(sp)
    80001540:	6ae2                	ld	s5,24(sp)
    80001542:	6b42                	ld	s6,16(sp)
    80001544:	6ba2                	ld	s7,8(sp)
    80001546:	6161                	addi	sp,sp,80
    80001548:	8082                	ret
    8000154a:	fff98713          	addi	a4,s3,-1 # fff <_entry-0x7ffff001>
    8000154e:	9726                	add	a4,a4,s1
      --max;
    80001550:	40b709b3          	sub	s3,a4,a1
    srcva = va0 + PGSIZE;
    80001554:	01490bb3          	add	s7,s2,s4
  while(got_null == 0 && max > 0){
    80001558:	04e58463          	beq	a1,a4,800015a0 <copyinstr+0xa0>
{
    8000155c:	84be                	mv	s1,a5
    va0 = PGROUNDDOWN(srcva);
    8000155e:	016bf933          	and	s2,s7,s6
    pa0 = walkaddr(pagetable, va0);
    80001562:	85ca                	mv	a1,s2
    80001564:	8556                	mv	a0,s5
    80001566:	ac9ff0ef          	jal	8000102e <walkaddr>
    if(pa0 == 0)
    8000156a:	cd0d                	beqz	a0,800015a4 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    8000156c:	417906b3          	sub	a3,s2,s7
    80001570:	96d2                	add	a3,a3,s4
    if(n > max)
    80001572:	00d9f363          	bgeu	s3,a3,80001578 <copyinstr+0x78>
    80001576:	86ce                	mv	a3,s3
    while(n > 0){
    80001578:	ca85                	beqz	a3,800015a8 <copyinstr+0xa8>
    char *p = (char *) (pa0 + (srcva - va0));
    8000157a:	01750633          	add	a2,a0,s7
    8000157e:	41260633          	sub	a2,a2,s2
    80001582:	87a6                	mv	a5,s1
      if(*p == '\0'){
    80001584:	8e05                	sub	a2,a2,s1
    while(n > 0){
    80001586:	96a6                	add	a3,a3,s1
    80001588:	85be                	mv	a1,a5
      if(*p == '\0'){
    8000158a:	00f60733          	add	a4,a2,a5
    8000158e:	00074703          	lbu	a4,0(a4)
    80001592:	db51                	beqz	a4,80001526 <copyinstr+0x26>
        *dst = *p;
    80001594:	00e78023          	sb	a4,0(a5)
      dst++;
    80001598:	0785                	addi	a5,a5,1
    while(n > 0){
    8000159a:	fed797e3          	bne	a5,a3,80001588 <copyinstr+0x88>
    8000159e:	b775                	j	8000154a <copyinstr+0x4a>
    800015a0:	4781                	li	a5,0
    800015a2:	b769                	j	8000152c <copyinstr+0x2c>
      return -1;
    800015a4:	557d                	li	a0,-1
    800015a6:	b779                	j	80001534 <copyinstr+0x34>
    srcva = va0 + PGSIZE;
    800015a8:	6b85                	lui	s7,0x1
    800015aa:	9bca                	add	s7,s7,s2
    800015ac:	87a6                	mv	a5,s1
    800015ae:	b77d                	j	8000155c <copyinstr+0x5c>
  int got_null = 0;
    800015b0:	4781                	li	a5,0
  if(got_null){
    800015b2:	0017c793          	xori	a5,a5,1
    800015b6:	40f0053b          	negw	a0,a5
}
    800015ba:	8082                	ret

00000000800015bc <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    800015bc:	1141                	addi	sp,sp,-16
    800015be:	e406                	sd	ra,8(sp)
    800015c0:	e022                	sd	s0,0(sp)
    800015c2:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800015c4:	4601                	li	a2,0
    800015c6:	9cfff0ef          	jal	80000f94 <walk>
  if (pte == 0) {
    800015ca:	c119                	beqz	a0,800015d0 <ismapped+0x14>
    return 0;
  }
  if (*pte & PTE_V){
    800015cc:	6108                	ld	a0,0(a0)
    800015ce:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    800015d0:	60a2                	ld	ra,8(sp)
    800015d2:	6402                	ld	s0,0(sp)
    800015d4:	0141                	addi	sp,sp,16
    800015d6:	8082                	ret

00000000800015d8 <vmfault>:
{
    800015d8:	7179                	addi	sp,sp,-48
    800015da:	f406                	sd	ra,40(sp)
    800015dc:	f022                	sd	s0,32(sp)
    800015de:	e84a                	sd	s2,16(sp)
    800015e0:	e44e                	sd	s3,8(sp)
    800015e2:	1800                	addi	s0,sp,48
    800015e4:	89aa                	mv	s3,a0
    800015e6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800015e8:	34e000ef          	jal	80001936 <myproc>
  if (va >= p->sz)
    800015ec:	653c                	ld	a5,72(a0)
    800015ee:	00f96a63          	bltu	s2,a5,80001602 <vmfault+0x2a>
    return 0;
    800015f2:	4981                	li	s3,0
}
    800015f4:	854e                	mv	a0,s3
    800015f6:	70a2                	ld	ra,40(sp)
    800015f8:	7402                	ld	s0,32(sp)
    800015fa:	6942                	ld	s2,16(sp)
    800015fc:	69a2                	ld	s3,8(sp)
    800015fe:	6145                	addi	sp,sp,48
    80001600:	8082                	ret
    80001602:	ec26                	sd	s1,24(sp)
    80001604:	e052                	sd	s4,0(sp)
    80001606:	84aa                	mv	s1,a0
  va = PGROUNDDOWN(va);
    80001608:	77fd                	lui	a5,0xfffff
    8000160a:	00f97a33          	and	s4,s2,a5
  if(ismapped(pagetable, va)) {
    8000160e:	85d2                	mv	a1,s4
    80001610:	854e                	mv	a0,s3
    80001612:	fabff0ef          	jal	800015bc <ismapped>
    return 0;
    80001616:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    80001618:	c501                	beqz	a0,80001620 <vmfault+0x48>
    8000161a:	64e2                	ld	s1,24(sp)
    8000161c:	6a02                	ld	s4,0(sp)
    8000161e:	bfd9                	j	800015f4 <vmfault+0x1c>
  mem = (uint64) kalloc();
    80001620:	d24ff0ef          	jal	80000b44 <kalloc>
    80001624:	892a                	mv	s2,a0
  if(mem == 0)
    80001626:	c905                	beqz	a0,80001656 <vmfault+0x7e>
  mem = (uint64) kalloc();
    80001628:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    8000162a:	6605                	lui	a2,0x1
    8000162c:	4581                	li	a1,0
    8000162e:	ecaff0ef          	jal	80000cf8 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    80001632:	4759                	li	a4,22
    80001634:	86ca                	mv	a3,s2
    80001636:	6605                	lui	a2,0x1
    80001638:	85d2                	mv	a1,s4
    8000163a:	68a8                	ld	a0,80(s1)
    8000163c:	a2dff0ef          	jal	80001068 <mappages>
    80001640:	e501                	bnez	a0,80001648 <vmfault+0x70>
    80001642:	64e2                	ld	s1,24(sp)
    80001644:	6a02                	ld	s4,0(sp)
    80001646:	b77d                	j	800015f4 <vmfault+0x1c>
    kfree((void *)mem);
    80001648:	854a                	mv	a0,s2
    8000164a:	c12ff0ef          	jal	80000a5c <kfree>
    return 0;
    8000164e:	4981                	li	s3,0
    80001650:	64e2                	ld	s1,24(sp)
    80001652:	6a02                	ld	s4,0(sp)
    80001654:	b745                	j	800015f4 <vmfault+0x1c>
    80001656:	64e2                	ld	s1,24(sp)
    80001658:	6a02                	ld	s4,0(sp)
    8000165a:	bf69                	j	800015f4 <vmfault+0x1c>

000000008000165c <copyout>:
  while(len > 0){
    8000165c:	cad1                	beqz	a3,800016f0 <copyout+0x94>
{
    8000165e:	711d                	addi	sp,sp,-96
    80001660:	ec86                	sd	ra,88(sp)
    80001662:	e8a2                	sd	s0,80(sp)
    80001664:	e4a6                	sd	s1,72(sp)
    80001666:	e0ca                	sd	s2,64(sp)
    80001668:	fc4e                	sd	s3,56(sp)
    8000166a:	f852                	sd	s4,48(sp)
    8000166c:	f456                	sd	s5,40(sp)
    8000166e:	f05a                	sd	s6,32(sp)
    80001670:	ec5e                	sd	s7,24(sp)
    80001672:	e862                	sd	s8,16(sp)
    80001674:	e466                	sd	s9,8(sp)
    80001676:	e06a                	sd	s10,0(sp)
    80001678:	1080                	addi	s0,sp,96
    8000167a:	8baa                	mv	s7,a0
    8000167c:	8a2e                	mv	s4,a1
    8000167e:	8b32                	mv	s6,a2
    80001680:	8ab6                	mv	s5,a3
    va0 = PGROUNDDOWN(dstva);
    80001682:	7d7d                	lui	s10,0xfffff
    if(va0 >= MAXVA)
    80001684:	5cfd                	li	s9,-1
    80001686:	01acdc93          	srli	s9,s9,0x1a
    n = PGSIZE - (dstva - va0);
    8000168a:	6c05                	lui	s8,0x1
    8000168c:	a005                	j	800016ac <copyout+0x50>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000168e:	409a0533          	sub	a0,s4,s1
    80001692:	0009061b          	sext.w	a2,s2
    80001696:	85da                	mv	a1,s6
    80001698:	954e                	add	a0,a0,s3
    8000169a:	ebeff0ef          	jal	80000d58 <memmove>
    len -= n;
    8000169e:	412a8ab3          	sub	s5,s5,s2
    src += n;
    800016a2:	9b4a                	add	s6,s6,s2
    dstva = va0 + PGSIZE;
    800016a4:	01848a33          	add	s4,s1,s8
  while(len > 0){
    800016a8:	040a8263          	beqz	s5,800016ec <copyout+0x90>
    va0 = PGROUNDDOWN(dstva);
    800016ac:	01aa74b3          	and	s1,s4,s10
    if(va0 >= MAXVA)
    800016b0:	049ce263          	bltu	s9,s1,800016f4 <copyout+0x98>
    pa0 = walkaddr(pagetable, va0);
    800016b4:	85a6                	mv	a1,s1
    800016b6:	855e                	mv	a0,s7
    800016b8:	977ff0ef          	jal	8000102e <walkaddr>
    800016bc:	89aa                	mv	s3,a0
    if(pa0 == 0) {
    800016be:	e901                	bnez	a0,800016ce <copyout+0x72>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800016c0:	4601                	li	a2,0
    800016c2:	85a6                	mv	a1,s1
    800016c4:	855e                	mv	a0,s7
    800016c6:	f13ff0ef          	jal	800015d8 <vmfault>
    800016ca:	89aa                	mv	s3,a0
    800016cc:	c139                	beqz	a0,80001712 <copyout+0xb6>
    pte = walk(pagetable, va0, 0);
    800016ce:	4601                	li	a2,0
    800016d0:	85a6                	mv	a1,s1
    800016d2:	855e                	mv	a0,s7
    800016d4:	8c1ff0ef          	jal	80000f94 <walk>
    if((*pte & PTE_W) == 0)
    800016d8:	611c                	ld	a5,0(a0)
    800016da:	8b91                	andi	a5,a5,4
    800016dc:	cf8d                	beqz	a5,80001716 <copyout+0xba>
    n = PGSIZE - (dstva - va0);
    800016de:	41448933          	sub	s2,s1,s4
    800016e2:	9962                	add	s2,s2,s8
    if(n > len)
    800016e4:	fb2af5e3          	bgeu	s5,s2,8000168e <copyout+0x32>
    800016e8:	8956                	mv	s2,s5
    800016ea:	b755                	j	8000168e <copyout+0x32>
  return 0;
    800016ec:	4501                	li	a0,0
    800016ee:	a021                	j	800016f6 <copyout+0x9a>
    800016f0:	4501                	li	a0,0
}
    800016f2:	8082                	ret
      return -1;
    800016f4:	557d                	li	a0,-1
}
    800016f6:	60e6                	ld	ra,88(sp)
    800016f8:	6446                	ld	s0,80(sp)
    800016fa:	64a6                	ld	s1,72(sp)
    800016fc:	6906                	ld	s2,64(sp)
    800016fe:	79e2                	ld	s3,56(sp)
    80001700:	7a42                	ld	s4,48(sp)
    80001702:	7aa2                	ld	s5,40(sp)
    80001704:	7b02                	ld	s6,32(sp)
    80001706:	6be2                	ld	s7,24(sp)
    80001708:	6c42                	ld	s8,16(sp)
    8000170a:	6ca2                	ld	s9,8(sp)
    8000170c:	6d02                	ld	s10,0(sp)
    8000170e:	6125                	addi	sp,sp,96
    80001710:	8082                	ret
        return -1;
    80001712:	557d                	li	a0,-1
    80001714:	b7cd                	j	800016f6 <copyout+0x9a>
      return -1;
    80001716:	557d                	li	a0,-1
    80001718:	bff9                	j	800016f6 <copyout+0x9a>

000000008000171a <copyin>:
  while(len > 0){
    8000171a:	c6c9                	beqz	a3,800017a4 <copyin+0x8a>
{
    8000171c:	715d                	addi	sp,sp,-80
    8000171e:	e486                	sd	ra,72(sp)
    80001720:	e0a2                	sd	s0,64(sp)
    80001722:	fc26                	sd	s1,56(sp)
    80001724:	f84a                	sd	s2,48(sp)
    80001726:	f44e                	sd	s3,40(sp)
    80001728:	f052                	sd	s4,32(sp)
    8000172a:	ec56                	sd	s5,24(sp)
    8000172c:	e85a                	sd	s6,16(sp)
    8000172e:	e45e                	sd	s7,8(sp)
    80001730:	e062                	sd	s8,0(sp)
    80001732:	0880                	addi	s0,sp,80
    80001734:	8baa                	mv	s7,a0
    80001736:	8aae                	mv	s5,a1
    80001738:	8932                	mv	s2,a2
    8000173a:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    8000173c:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    8000173e:	6b05                	lui	s6,0x1
    80001740:	a035                	j	8000176c <copyin+0x52>
    80001742:	412984b3          	sub	s1,s3,s2
    80001746:	94da                	add	s1,s1,s6
    if(n > len)
    80001748:	009a7363          	bgeu	s4,s1,8000174e <copyin+0x34>
    8000174c:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000174e:	413905b3          	sub	a1,s2,s3
    80001752:	0004861b          	sext.w	a2,s1
    80001756:	95aa                	add	a1,a1,a0
    80001758:	8556                	mv	a0,s5
    8000175a:	dfeff0ef          	jal	80000d58 <memmove>
    len -= n;
    8000175e:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80001762:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001764:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001768:	020a0163          	beqz	s4,8000178a <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    8000176c:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001770:	85ce                	mv	a1,s3
    80001772:	855e                	mv	a0,s7
    80001774:	8bbff0ef          	jal	8000102e <walkaddr>
    if(pa0 == 0) {
    80001778:	f569                	bnez	a0,80001742 <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    8000177a:	4601                	li	a2,0
    8000177c:	85ce                	mv	a1,s3
    8000177e:	855e                	mv	a0,s7
    80001780:	e59ff0ef          	jal	800015d8 <vmfault>
    80001784:	fd5d                	bnez	a0,80001742 <copyin+0x28>
        return -1;
    80001786:	557d                	li	a0,-1
    80001788:	a011                	j	8000178c <copyin+0x72>
  return 0;
    8000178a:	4501                	li	a0,0
}
    8000178c:	60a6                	ld	ra,72(sp)
    8000178e:	6406                	ld	s0,64(sp)
    80001790:	74e2                	ld	s1,56(sp)
    80001792:	7942                	ld	s2,48(sp)
    80001794:	79a2                	ld	s3,40(sp)
    80001796:	7a02                	ld	s4,32(sp)
    80001798:	6ae2                	ld	s5,24(sp)
    8000179a:	6b42                	ld	s6,16(sp)
    8000179c:	6ba2                	ld	s7,8(sp)
    8000179e:	6c02                	ld	s8,0(sp)
    800017a0:	6161                	addi	sp,sp,80
    800017a2:	8082                	ret
  return 0;
    800017a4:	4501                	li	a0,0
}
    800017a6:	8082                	ret

00000000800017a8 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800017a8:	715d                	addi	sp,sp,-80
    800017aa:	e486                	sd	ra,72(sp)
    800017ac:	e0a2                	sd	s0,64(sp)
    800017ae:	fc26                	sd	s1,56(sp)
    800017b0:	f84a                	sd	s2,48(sp)
    800017b2:	f44e                	sd	s3,40(sp)
    800017b4:	f052                	sd	s4,32(sp)
    800017b6:	ec56                	sd	s5,24(sp)
    800017b8:	e85a                	sd	s6,16(sp)
    800017ba:	e45e                	sd	s7,8(sp)
    800017bc:	e062                	sd	s8,0(sp)
    800017be:	0880                	addi	s0,sp,80
    800017c0:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800017c2:	00010497          	auipc	s1,0x10
    800017c6:	ae648493          	addi	s1,s1,-1306 # 800112a8 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800017ca:	8c26                	mv	s8,s1
    800017cc:	000c57b7          	lui	a5,0xc5
    800017d0:	ec578793          	addi	a5,a5,-315 # c4ec5 <_entry-0x7ff3b13b>
    800017d4:	07b2                	slli	a5,a5,0xc
    800017d6:	ec578793          	addi	a5,a5,-315
    800017da:	4ec4f937          	lui	s2,0x4ec4f
    800017de:	c4e90913          	addi	s2,s2,-946 # 4ec4ec4e <_entry-0x313b13b2>
    800017e2:	1902                	slli	s2,s2,0x20
    800017e4:	993e                	add	s2,s2,a5
    800017e6:	040009b7          	lui	s3,0x4000
    800017ea:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017ec:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017ee:	4b99                	li	s7,6
    800017f0:	6b05                	lui	s6,0x1
  for(p = proc; p < &proc[NPROC]; p++) {
    800017f2:	00016a97          	auipc	s5,0x16
    800017f6:	2b6a8a93          	addi	s5,s5,694 # 80017aa8 <tickslock>
    char *pa = kalloc();
    800017fa:	b4aff0ef          	jal	80000b44 <kalloc>
    800017fe:	862a                	mv	a2,a0
    if(pa == 0)
    80001800:	c121                	beqz	a0,80001840 <proc_mapstacks+0x98>
    uint64 va = KSTACK((int) (p - proc));
    80001802:	418485b3          	sub	a1,s1,s8
    80001806:	8595                	srai	a1,a1,0x5
    80001808:	032585b3          	mul	a1,a1,s2
    8000180c:	05b6                	slli	a1,a1,0xd
    8000180e:	6789                	lui	a5,0x2
    80001810:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001812:	875e                	mv	a4,s7
    80001814:	86da                	mv	a3,s6
    80001816:	40b985b3          	sub	a1,s3,a1
    8000181a:	8552                	mv	a0,s4
    8000181c:	903ff0ef          	jal	8000111e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001820:	1a048493          	addi	s1,s1,416
    80001824:	fd549be3          	bne	s1,s5,800017fa <proc_mapstacks+0x52>
  }
}
    80001828:	60a6                	ld	ra,72(sp)
    8000182a:	6406                	ld	s0,64(sp)
    8000182c:	74e2                	ld	s1,56(sp)
    8000182e:	7942                	ld	s2,48(sp)
    80001830:	79a2                	ld	s3,40(sp)
    80001832:	7a02                	ld	s4,32(sp)
    80001834:	6ae2                	ld	s5,24(sp)
    80001836:	6b42                	ld	s6,16(sp)
    80001838:	6ba2                	ld	s7,8(sp)
    8000183a:	6c02                	ld	s8,0(sp)
    8000183c:	6161                	addi	sp,sp,80
    8000183e:	8082                	ret
      panic("kalloc");
    80001840:	00007517          	auipc	a0,0x7
    80001844:	91850513          	addi	a0,a0,-1768 # 80008158 <etext+0x158>
    80001848:	fddfe0ef          	jal	80000824 <panic>

000000008000184c <procinit>:

// initialize the proc table.
void
procinit(void)
{
    8000184c:	7139                	addi	sp,sp,-64
    8000184e:	fc06                	sd	ra,56(sp)
    80001850:	f822                	sd	s0,48(sp)
    80001852:	f426                	sd	s1,40(sp)
    80001854:	f04a                	sd	s2,32(sp)
    80001856:	ec4e                	sd	s3,24(sp)
    80001858:	e852                	sd	s4,16(sp)
    8000185a:	e456                	sd	s5,8(sp)
    8000185c:	e05a                	sd	s6,0(sp)
    8000185e:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001860:	00007597          	auipc	a1,0x7
    80001864:	90058593          	addi	a1,a1,-1792 # 80008160 <etext+0x160>
    80001868:	0000f517          	auipc	a0,0xf
    8000186c:	61050513          	addi	a0,a0,1552 # 80010e78 <pid_lock>
    80001870:	b2eff0ef          	jal	80000b9e <initlock>
  initlock(&wait_lock, "wait_lock");
    80001874:	00007597          	auipc	a1,0x7
    80001878:	8f458593          	addi	a1,a1,-1804 # 80008168 <etext+0x168>
    8000187c:	0000f517          	auipc	a0,0xf
    80001880:	61450513          	addi	a0,a0,1556 # 80010e90 <wait_lock>
    80001884:	b1aff0ef          	jal	80000b9e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001888:	00010497          	auipc	s1,0x10
    8000188c:	a2048493          	addi	s1,s1,-1504 # 800112a8 <proc>
      initlock(&p->lock, "proc");
    80001890:	00007b17          	auipc	s6,0x7
    80001894:	8e8b0b13          	addi	s6,s6,-1816 # 80008178 <etext+0x178>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001898:	8aa6                	mv	s5,s1
    8000189a:	000c57b7          	lui	a5,0xc5
    8000189e:	ec578793          	addi	a5,a5,-315 # c4ec5 <_entry-0x7ff3b13b>
    800018a2:	07b2                	slli	a5,a5,0xc
    800018a4:	ec578793          	addi	a5,a5,-315
    800018a8:	4ec4f937          	lui	s2,0x4ec4f
    800018ac:	c4e90913          	addi	s2,s2,-946 # 4ec4ec4e <_entry-0x313b13b2>
    800018b0:	1902                	slli	s2,s2,0x20
    800018b2:	993e                	add	s2,s2,a5
    800018b4:	040009b7          	lui	s3,0x4000
    800018b8:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018ba:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018bc:	00016a17          	auipc	s4,0x16
    800018c0:	1eca0a13          	addi	s4,s4,492 # 80017aa8 <tickslock>
      initlock(&p->lock, "proc");
    800018c4:	85da                	mv	a1,s6
    800018c6:	8526                	mv	a0,s1
    800018c8:	ad6ff0ef          	jal	80000b9e <initlock>
      p->state = UNUSED;
    800018cc:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800018d0:	415487b3          	sub	a5,s1,s5
    800018d4:	8795                	srai	a5,a5,0x5
    800018d6:	032787b3          	mul	a5,a5,s2
    800018da:	07b6                	slli	a5,a5,0xd
    800018dc:	6709                	lui	a4,0x2
    800018de:	9fb9                	addw	a5,a5,a4
    800018e0:	40f987b3          	sub	a5,s3,a5
    800018e4:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800018e6:	1a048493          	addi	s1,s1,416
    800018ea:	fd449de3          	bne	s1,s4,800018c4 <procinit+0x78>
  }
}
    800018ee:	70e2                	ld	ra,56(sp)
    800018f0:	7442                	ld	s0,48(sp)
    800018f2:	74a2                	ld	s1,40(sp)
    800018f4:	7902                	ld	s2,32(sp)
    800018f6:	69e2                	ld	s3,24(sp)
    800018f8:	6a42                	ld	s4,16(sp)
    800018fa:	6aa2                	ld	s5,8(sp)
    800018fc:	6b02                	ld	s6,0(sp)
    800018fe:	6121                	addi	sp,sp,64
    80001900:	8082                	ret

0000000080001902 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001902:	1141                	addi	sp,sp,-16
    80001904:	e406                	sd	ra,8(sp)
    80001906:	e022                	sd	s0,0(sp)
    80001908:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    8000190a:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    8000190c:	2501                	sext.w	a0,a0
    8000190e:	60a2                	ld	ra,8(sp)
    80001910:	6402                	ld	s0,0(sp)
    80001912:	0141                	addi	sp,sp,16
    80001914:	8082                	ret

0000000080001916 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001916:	1141                	addi	sp,sp,-16
    80001918:	e406                	sd	ra,8(sp)
    8000191a:	e022                	sd	s0,0(sp)
    8000191c:	0800                	addi	s0,sp,16
    8000191e:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001920:	2781                	sext.w	a5,a5
    80001922:	079e                	slli	a5,a5,0x7
  return c;
}
    80001924:	0000f517          	auipc	a0,0xf
    80001928:	58450513          	addi	a0,a0,1412 # 80010ea8 <cpus>
    8000192c:	953e                	add	a0,a0,a5
    8000192e:	60a2                	ld	ra,8(sp)
    80001930:	6402                	ld	s0,0(sp)
    80001932:	0141                	addi	sp,sp,16
    80001934:	8082                	ret

0000000080001936 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001936:	1101                	addi	sp,sp,-32
    80001938:	ec06                	sd	ra,24(sp)
    8000193a:	e822                	sd	s0,16(sp)
    8000193c:	e426                	sd	s1,8(sp)
    8000193e:	1000                	addi	s0,sp,32
  push_off();
    80001940:	aa4ff0ef          	jal	80000be4 <push_off>
    80001944:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001946:	2781                	sext.w	a5,a5
    80001948:	079e                	slli	a5,a5,0x7
    8000194a:	0000f717          	auipc	a4,0xf
    8000194e:	52e70713          	addi	a4,a4,1326 # 80010e78 <pid_lock>
    80001952:	97ba                	add	a5,a5,a4
    80001954:	7b9c                	ld	a5,48(a5)
    80001956:	84be                	mv	s1,a5
  pop_off();
    80001958:	b14ff0ef          	jal	80000c6c <pop_off>
  return p;
}
    8000195c:	8526                	mv	a0,s1
    8000195e:	60e2                	ld	ra,24(sp)
    80001960:	6442                	ld	s0,16(sp)
    80001962:	64a2                	ld	s1,8(sp)
    80001964:	6105                	addi	sp,sp,32
    80001966:	8082                	ret

0000000080001968 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001968:	7179                	addi	sp,sp,-48
    8000196a:	f406                	sd	ra,40(sp)
    8000196c:	f022                	sd	s0,32(sp)
    8000196e:	ec26                	sd	s1,24(sp)
    80001970:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001972:	fc5ff0ef          	jal	80001936 <myproc>
    80001976:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001978:	b44ff0ef          	jal	80000cbc <release>

  if (first) {
    8000197c:	00007797          	auipc	a5,0x7
    80001980:	3c47a783          	lw	a5,964(a5) # 80008d40 <first.1>
    80001984:	cf95                	beqz	a5,800019c0 <forkret+0x58>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001986:	4505                	li	a0,1
    80001988:	441010ef          	jal	800035c8 <fsinit>

    first = 0;
    8000198c:	00007797          	auipc	a5,0x7
    80001990:	3a07aa23          	sw	zero,948(a5) # 80008d40 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001994:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001998:	00006797          	auipc	a5,0x6
    8000199c:	7e878793          	addi	a5,a5,2024 # 80008180 <etext+0x180>
    800019a0:	fcf43823          	sd	a5,-48(s0)
    800019a4:	fc043c23          	sd	zero,-40(s0)
    800019a8:	fd040593          	addi	a1,s0,-48
    800019ac:	853e                	mv	a0,a5
    800019ae:	6d9020ef          	jal	80004886 <kexec>
    800019b2:	6cbc                	ld	a5,88(s1)
    800019b4:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    800019b6:	6cbc                	ld	a5,88(s1)
    800019b8:	7bb8                	ld	a4,112(a5)
    800019ba:	57fd                	li	a5,-1
    800019bc:	02f70d63          	beq	a4,a5,800019f6 <forkret+0x8e>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    800019c0:	30f000ef          	jal	800024ce <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800019c4:	68a8                	ld	a0,80(s1)
    800019c6:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800019c8:	04000737          	lui	a4,0x4000
    800019cc:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800019ce:	0732                	slli	a4,a4,0xc
    800019d0:	00005797          	auipc	a5,0x5
    800019d4:	6cc78793          	addi	a5,a5,1740 # 8000709c <userret>
    800019d8:	00005697          	auipc	a3,0x5
    800019dc:	62868693          	addi	a3,a3,1576 # 80007000 <_trampoline>
    800019e0:	8f95                	sub	a5,a5,a3
    800019e2:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800019e4:	577d                	li	a4,-1
    800019e6:	177e                	slli	a4,a4,0x3f
    800019e8:	8d59                	or	a0,a0,a4
    800019ea:	9782                	jalr	a5
}
    800019ec:	70a2                	ld	ra,40(sp)
    800019ee:	7402                	ld	s0,32(sp)
    800019f0:	64e2                	ld	s1,24(sp)
    800019f2:	6145                	addi	sp,sp,48
    800019f4:	8082                	ret
      panic("exec");
    800019f6:	00006517          	auipc	a0,0x6
    800019fa:	79250513          	addi	a0,a0,1938 # 80008188 <etext+0x188>
    800019fe:	e27fe0ef          	jal	80000824 <panic>

0000000080001a02 <allocpid>:
{
    80001a02:	1101                	addi	sp,sp,-32
    80001a04:	ec06                	sd	ra,24(sp)
    80001a06:	e822                	sd	s0,16(sp)
    80001a08:	e426                	sd	s1,8(sp)
    80001a0a:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a0c:	0000f517          	auipc	a0,0xf
    80001a10:	46c50513          	addi	a0,a0,1132 # 80010e78 <pid_lock>
    80001a14:	a14ff0ef          	jal	80000c28 <acquire>
  pid = nextpid;
    80001a18:	00007797          	auipc	a5,0x7
    80001a1c:	32c78793          	addi	a5,a5,812 # 80008d44 <nextpid>
    80001a20:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a22:	0014871b          	addiw	a4,s1,1
    80001a26:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a28:	0000f517          	auipc	a0,0xf
    80001a2c:	45050513          	addi	a0,a0,1104 # 80010e78 <pid_lock>
    80001a30:	a8cff0ef          	jal	80000cbc <release>
}
    80001a34:	8526                	mv	a0,s1
    80001a36:	60e2                	ld	ra,24(sp)
    80001a38:	6442                	ld	s0,16(sp)
    80001a3a:	64a2                	ld	s1,8(sp)
    80001a3c:	6105                	addi	sp,sp,32
    80001a3e:	8082                	ret

0000000080001a40 <proc_pagetable>:
{
    80001a40:	1101                	addi	sp,sp,-32
    80001a42:	ec06                	sd	ra,24(sp)
    80001a44:	e822                	sd	s0,16(sp)
    80001a46:	e426                	sd	s1,8(sp)
    80001a48:	e04a                	sd	s2,0(sp)
    80001a4a:	1000                	addi	s0,sp,32
    80001a4c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a4e:	fc2ff0ef          	jal	80001210 <uvmcreate>
    80001a52:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a54:	cd05                	beqz	a0,80001a8c <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a56:	4729                	li	a4,10
    80001a58:	00005697          	auipc	a3,0x5
    80001a5c:	5a868693          	addi	a3,a3,1448 # 80007000 <_trampoline>
    80001a60:	6605                	lui	a2,0x1
    80001a62:	040005b7          	lui	a1,0x4000
    80001a66:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a68:	05b2                	slli	a1,a1,0xc
    80001a6a:	dfeff0ef          	jal	80001068 <mappages>
    80001a6e:	02054663          	bltz	a0,80001a9a <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001a72:	4719                	li	a4,6
    80001a74:	05893683          	ld	a3,88(s2)
    80001a78:	6605                	lui	a2,0x1
    80001a7a:	020005b7          	lui	a1,0x2000
    80001a7e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a80:	05b6                	slli	a1,a1,0xd
    80001a82:	8526                	mv	a0,s1
    80001a84:	de4ff0ef          	jal	80001068 <mappages>
    80001a88:	00054f63          	bltz	a0,80001aa6 <proc_pagetable+0x66>
}
    80001a8c:	8526                	mv	a0,s1
    80001a8e:	60e2                	ld	ra,24(sp)
    80001a90:	6442                	ld	s0,16(sp)
    80001a92:	64a2                	ld	s1,8(sp)
    80001a94:	6902                	ld	s2,0(sp)
    80001a96:	6105                	addi	sp,sp,32
    80001a98:	8082                	ret
    uvmfree(pagetable, 0);
    80001a9a:	4581                	li	a1,0
    80001a9c:	8526                	mv	a0,s1
    80001a9e:	96dff0ef          	jal	8000140a <uvmfree>
    return 0;
    80001aa2:	4481                	li	s1,0
    80001aa4:	b7e5                	j	80001a8c <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001aa6:	4681                	li	a3,0
    80001aa8:	4605                	li	a2,1
    80001aaa:	040005b7          	lui	a1,0x4000
    80001aae:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ab0:	05b2                	slli	a1,a1,0xc
    80001ab2:	8526                	mv	a0,s1
    80001ab4:	f82ff0ef          	jal	80001236 <uvmunmap>
    uvmfree(pagetable, 0);
    80001ab8:	4581                	li	a1,0
    80001aba:	8526                	mv	a0,s1
    80001abc:	94fff0ef          	jal	8000140a <uvmfree>
    return 0;
    80001ac0:	4481                	li	s1,0
    80001ac2:	b7e9                	j	80001a8c <proc_pagetable+0x4c>

0000000080001ac4 <proc_freepagetable>:
{
    80001ac4:	1101                	addi	sp,sp,-32
    80001ac6:	ec06                	sd	ra,24(sp)
    80001ac8:	e822                	sd	s0,16(sp)
    80001aca:	e426                	sd	s1,8(sp)
    80001acc:	e04a                	sd	s2,0(sp)
    80001ace:	1000                	addi	s0,sp,32
    80001ad0:	84aa                	mv	s1,a0
    80001ad2:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ad4:	4681                	li	a3,0
    80001ad6:	4605                	li	a2,1
    80001ad8:	040005b7          	lui	a1,0x4000
    80001adc:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ade:	05b2                	slli	a1,a1,0xc
    80001ae0:	f56ff0ef          	jal	80001236 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001ae4:	4681                	li	a3,0
    80001ae6:	4605                	li	a2,1
    80001ae8:	020005b7          	lui	a1,0x2000
    80001aec:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001aee:	05b6                	slli	a1,a1,0xd
    80001af0:	8526                	mv	a0,s1
    80001af2:	f44ff0ef          	jal	80001236 <uvmunmap>
  uvmfree(pagetable, sz);
    80001af6:	85ca                	mv	a1,s2
    80001af8:	8526                	mv	a0,s1
    80001afa:	911ff0ef          	jal	8000140a <uvmfree>
}
    80001afe:	60e2                	ld	ra,24(sp)
    80001b00:	6442                	ld	s0,16(sp)
    80001b02:	64a2                	ld	s1,8(sp)
    80001b04:	6902                	ld	s2,0(sp)
    80001b06:	6105                	addi	sp,sp,32
    80001b08:	8082                	ret

0000000080001b0a <freeproc>:
{
    80001b0a:	1101                	addi	sp,sp,-32
    80001b0c:	ec06                	sd	ra,24(sp)
    80001b0e:	e822                	sd	s0,16(sp)
    80001b10:	e426                	sd	s1,8(sp)
    80001b12:	1000                	addi	s0,sp,32
    80001b14:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b16:	6d28                	ld	a0,88(a0)
    80001b18:	c119                	beqz	a0,80001b1e <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001b1a:	f43fe0ef          	jal	80000a5c <kfree>
  p->trapframe = 0;
    80001b1e:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b22:	68a8                	ld	a0,80(s1)
    80001b24:	c501                	beqz	a0,80001b2c <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001b26:	64ac                	ld	a1,72(s1)
    80001b28:	f9dff0ef          	jal	80001ac4 <proc_freepagetable>
  p->pagetable = 0;
    80001b2c:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b30:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b34:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b38:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b3c:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b40:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b44:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b48:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b4c:	0004ac23          	sw	zero,24(s1)
}
    80001b50:	60e2                	ld	ra,24(sp)
    80001b52:	6442                	ld	s0,16(sp)
    80001b54:	64a2                	ld	s1,8(sp)
    80001b56:	6105                	addi	sp,sp,32
    80001b58:	8082                	ret

0000000080001b5a <allocproc>:
{
    80001b5a:	1101                	addi	sp,sp,-32
    80001b5c:	ec06                	sd	ra,24(sp)
    80001b5e:	e822                	sd	s0,16(sp)
    80001b60:	e426                	sd	s1,8(sp)
    80001b62:	e04a                	sd	s2,0(sp)
    80001b64:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b66:	0000f497          	auipc	s1,0xf
    80001b6a:	74248493          	addi	s1,s1,1858 # 800112a8 <proc>
    80001b6e:	00016917          	auipc	s2,0x16
    80001b72:	f3a90913          	addi	s2,s2,-198 # 80017aa8 <tickslock>
    acquire(&p->lock);
    80001b76:	8526                	mv	a0,s1
    80001b78:	8b0ff0ef          	jal	80000c28 <acquire>
    if(p->state == UNUSED) {
    80001b7c:	4c9c                	lw	a5,24(s1)
    80001b7e:	cb91                	beqz	a5,80001b92 <allocproc+0x38>
      release(&p->lock);
    80001b80:	8526                	mv	a0,s1
    80001b82:	93aff0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b86:	1a048493          	addi	s1,s1,416
    80001b8a:	ff2496e3          	bne	s1,s2,80001b76 <allocproc+0x1c>
  return 0;
    80001b8e:	4481                	li	s1,0
    80001b90:	a089                	j	80001bd2 <allocproc+0x78>
  p->pid = allocpid();
    80001b92:	e71ff0ef          	jal	80001a02 <allocpid>
    80001b96:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b98:	4785                	li	a5,1
    80001b9a:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001b9c:	fa9fe0ef          	jal	80000b44 <kalloc>
    80001ba0:	892a                	mv	s2,a0
    80001ba2:	eca8                	sd	a0,88(s1)
    80001ba4:	cd15                	beqz	a0,80001be0 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001ba6:	8526                	mv	a0,s1
    80001ba8:	e99ff0ef          	jal	80001a40 <proc_pagetable>
    80001bac:	892a                	mv	s2,a0
    80001bae:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001bb0:	c121                	beqz	a0,80001bf0 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001bb2:	07000613          	li	a2,112
    80001bb6:	4581                	li	a1,0
    80001bb8:	06048513          	addi	a0,s1,96
    80001bbc:	93cff0ef          	jal	80000cf8 <memset>
  p->context.ra = (uint64)forkret;
    80001bc0:	00000797          	auipc	a5,0x0
    80001bc4:	da878793          	addi	a5,a5,-600 # 80001968 <forkret>
    80001bc8:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001bca:	60bc                	ld	a5,64(s1)
    80001bcc:	6705                	lui	a4,0x1
    80001bce:	97ba                	add	a5,a5,a4
    80001bd0:	f4bc                	sd	a5,104(s1)
}
    80001bd2:	8526                	mv	a0,s1
    80001bd4:	60e2                	ld	ra,24(sp)
    80001bd6:	6442                	ld	s0,16(sp)
    80001bd8:	64a2                	ld	s1,8(sp)
    80001bda:	6902                	ld	s2,0(sp)
    80001bdc:	6105                	addi	sp,sp,32
    80001bde:	8082                	ret
    freeproc(p);
    80001be0:	8526                	mv	a0,s1
    80001be2:	f29ff0ef          	jal	80001b0a <freeproc>
    release(&p->lock);
    80001be6:	8526                	mv	a0,s1
    80001be8:	8d4ff0ef          	jal	80000cbc <release>
    return 0;
    80001bec:	84ca                	mv	s1,s2
    80001bee:	b7d5                	j	80001bd2 <allocproc+0x78>
    freeproc(p);
    80001bf0:	8526                	mv	a0,s1
    80001bf2:	f19ff0ef          	jal	80001b0a <freeproc>
    release(&p->lock);
    80001bf6:	8526                	mv	a0,s1
    80001bf8:	8c4ff0ef          	jal	80000cbc <release>
    return 0;
    80001bfc:	84ca                	mv	s1,s2
    80001bfe:	bfd1                	j	80001bd2 <allocproc+0x78>

0000000080001c00 <userinit>:
{
    80001c00:	1101                	addi	sp,sp,-32
    80001c02:	ec06                	sd	ra,24(sp)
    80001c04:	e822                	sd	s0,16(sp)
    80001c06:	e426                	sd	s1,8(sp)
    80001c08:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c0a:	f51ff0ef          	jal	80001b5a <allocproc>
    80001c0e:	84aa                	mv	s1,a0
  initproc = p;
    80001c10:	00007797          	auipc	a5,0x7
    80001c14:	16a7b023          	sd	a0,352(a5) # 80008d70 <initproc>
  p->cwd = namei("/");
    80001c18:	00006517          	auipc	a0,0x6
    80001c1c:	57850513          	addi	a0,a0,1400 # 80008190 <etext+0x190>
    80001c20:	6e7010ef          	jal	80003b06 <namei>
    80001c24:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001c28:	478d                	li	a5,3
    80001c2a:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001c2c:	8526                	mv	a0,s1
    80001c2e:	88eff0ef          	jal	80000cbc <release>
}
    80001c32:	60e2                	ld	ra,24(sp)
    80001c34:	6442                	ld	s0,16(sp)
    80001c36:	64a2                	ld	s1,8(sp)
    80001c38:	6105                	addi	sp,sp,32
    80001c3a:	8082                	ret

0000000080001c3c <growproc>:
{
    80001c3c:	1101                	addi	sp,sp,-32
    80001c3e:	ec06                	sd	ra,24(sp)
    80001c40:	e822                	sd	s0,16(sp)
    80001c42:	e426                	sd	s1,8(sp)
    80001c44:	e04a                	sd	s2,0(sp)
    80001c46:	1000                	addi	s0,sp,32
    80001c48:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c4a:	cedff0ef          	jal	80001936 <myproc>
    80001c4e:	892a                	mv	s2,a0
  sz = p->sz;
    80001c50:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001c52:	02905963          	blez	s1,80001c84 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001c56:	00b48633          	add	a2,s1,a1
    80001c5a:	020007b7          	lui	a5,0x2000
    80001c5e:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c60:	07b6                	slli	a5,a5,0xd
    80001c62:	02c7ea63          	bltu	a5,a2,80001c96 <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c66:	4691                	li	a3,4
    80001c68:	6928                	ld	a0,80(a0)
    80001c6a:	e9aff0ef          	jal	80001304 <uvmalloc>
    80001c6e:	85aa                	mv	a1,a0
    80001c70:	c50d                	beqz	a0,80001c9a <growproc+0x5e>
  p->sz = sz;
    80001c72:	04b93423          	sd	a1,72(s2)
  return 0;
    80001c76:	4501                	li	a0,0
}
    80001c78:	60e2                	ld	ra,24(sp)
    80001c7a:	6442                	ld	s0,16(sp)
    80001c7c:	64a2                	ld	s1,8(sp)
    80001c7e:	6902                	ld	s2,0(sp)
    80001c80:	6105                	addi	sp,sp,32
    80001c82:	8082                	ret
  } else if(n < 0){
    80001c84:	fe04d7e3          	bgez	s1,80001c72 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c88:	00b48633          	add	a2,s1,a1
    80001c8c:	6928                	ld	a0,80(a0)
    80001c8e:	e32ff0ef          	jal	800012c0 <uvmdealloc>
    80001c92:	85aa                	mv	a1,a0
    80001c94:	bff9                	j	80001c72 <growproc+0x36>
      return -1;
    80001c96:	557d                	li	a0,-1
    80001c98:	b7c5                	j	80001c78 <growproc+0x3c>
      return -1;
    80001c9a:	557d                	li	a0,-1
    80001c9c:	bff1                	j	80001c78 <growproc+0x3c>

0000000080001c9e <kfork>:
{
    80001c9e:	7139                	addi	sp,sp,-64
    80001ca0:	fc06                	sd	ra,56(sp)
    80001ca2:	f822                	sd	s0,48(sp)
    80001ca4:	f426                	sd	s1,40(sp)
    80001ca6:	e852                	sd	s4,16(sp)
    80001ca8:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001caa:	c8dff0ef          	jal	80001936 <myproc>
    80001cae:	8a2a                	mv	s4,a0
  if((np = allocproc()) == 0){
    80001cb0:	eabff0ef          	jal	80001b5a <allocproc>
    80001cb4:	14050063          	beqz	a0,80001df4 <kfork+0x156>
    80001cb8:	ec4e                	sd	s3,24(sp)
    80001cba:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001cbc:	048a3603          	ld	a2,72(s4)
    80001cc0:	692c                	ld	a1,80(a0)
    80001cc2:	050a3503          	ld	a0,80(s4)
    80001cc6:	f76ff0ef          	jal	8000143c <uvmcopy>
    80001cca:	04054863          	bltz	a0,80001d1a <kfork+0x7c>
    80001cce:	f04a                	sd	s2,32(sp)
    80001cd0:	e456                	sd	s5,8(sp)
  np->sz = p->sz;
    80001cd2:	048a3783          	ld	a5,72(s4)
    80001cd6:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001cda:	058a3683          	ld	a3,88(s4)
    80001cde:	87b6                	mv	a5,a3
    80001ce0:	0589b703          	ld	a4,88(s3)
    80001ce4:	12068693          	addi	a3,a3,288
    80001ce8:	6388                	ld	a0,0(a5)
    80001cea:	678c                	ld	a1,8(a5)
    80001cec:	6b90                	ld	a2,16(a5)
    80001cee:	e308                	sd	a0,0(a4)
    80001cf0:	e70c                	sd	a1,8(a4)
    80001cf2:	eb10                	sd	a2,16(a4)
    80001cf4:	6f90                	ld	a2,24(a5)
    80001cf6:	ef10                	sd	a2,24(a4)
    80001cf8:	02078793          	addi	a5,a5,32
    80001cfc:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001d00:	fed794e3          	bne	a5,a3,80001ce8 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001d04:	0589b783          	ld	a5,88(s3)
    80001d08:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001d0c:	0d0a0493          	addi	s1,s4,208
    80001d10:	0d098913          	addi	s2,s3,208
    80001d14:	150a0a93          	addi	s5,s4,336
    80001d18:	a831                	j	80001d34 <kfork+0x96>
    freeproc(np);
    80001d1a:	854e                	mv	a0,s3
    80001d1c:	defff0ef          	jal	80001b0a <freeproc>
    release(&np->lock);
    80001d20:	854e                	mv	a0,s3
    80001d22:	f9bfe0ef          	jal	80000cbc <release>
    return -1;
    80001d26:	54fd                	li	s1,-1
    80001d28:	69e2                	ld	s3,24(sp)
    80001d2a:	a875                	j	80001de6 <kfork+0x148>
  for(i = 0; i < NOFILE; i++)
    80001d2c:	04a1                	addi	s1,s1,8
    80001d2e:	0921                	addi	s2,s2,8
    80001d30:	01548963          	beq	s1,s5,80001d42 <kfork+0xa4>
    if(p->ofile[i])
    80001d34:	6088                	ld	a0,0(s1)
    80001d36:	d97d                	beqz	a0,80001d2c <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d38:	3fa020ef          	jal	80004132 <filedup>
    80001d3c:	00a93023          	sd	a0,0(s2)
    80001d40:	b7f5                	j	80001d2c <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001d42:	150a3503          	ld	a0,336(s4)
    80001d46:	536010ef          	jal	8000327c <idup>
    80001d4a:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d4e:	4641                	li	a2,16
    80001d50:	158a0593          	addi	a1,s4,344
    80001d54:	15898513          	addi	a0,s3,344
    80001d58:	8f4ff0ef          	jal	80000e4c <safestrcpy>
  np->creds = p->creds;
    80001d5c:	168a3583          	ld	a1,360(s4)
    80001d60:	170a3603          	ld	a2,368(s4)
    80001d64:	178a3683          	ld	a3,376(s4)
    80001d68:	180a3703          	ld	a4,384(s4)
    80001d6c:	188a3783          	ld	a5,392(s4)
    80001d70:	16b9b423          	sd	a1,360(s3)
    80001d74:	16c9b823          	sd	a2,368(s3)
    80001d78:	16d9bc23          	sd	a3,376(s3)
    80001d7c:	18e9b023          	sd	a4,384(s3)
    80001d80:	18f9b423          	sd	a5,392(s3)
    80001d84:	190a3783          	ld	a5,400(s4)
    80001d88:	18f9b823          	sd	a5,400(s3)
  printf("DEBUG: fork pid %d -> %d: parent uid=%d, child uid=%d\n", p->pid, np->pid, p->creds.uid, np->creds.uid);
    80001d8c:	1689a703          	lw	a4,360(s3)
    80001d90:	168a2683          	lw	a3,360(s4)
    80001d94:	0309a603          	lw	a2,48(s3)
    80001d98:	030a2583          	lw	a1,48(s4)
    80001d9c:	00006517          	auipc	a0,0x6
    80001da0:	3fc50513          	addi	a0,a0,1020 # 80008198 <etext+0x198>
    80001da4:	f56fe0ef          	jal	800004fa <printf>
  pid = np->pid;
    80001da8:	0309a483          	lw	s1,48(s3)
  release(&np->lock);
    80001dac:	854e                	mv	a0,s3
    80001dae:	f0ffe0ef          	jal	80000cbc <release>
  acquire(&wait_lock);
    80001db2:	0000f517          	auipc	a0,0xf
    80001db6:	0de50513          	addi	a0,a0,222 # 80010e90 <wait_lock>
    80001dba:	e6ffe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001dbe:	0349bc23          	sd	s4,56(s3)
  release(&wait_lock);
    80001dc2:	0000f517          	auipc	a0,0xf
    80001dc6:	0ce50513          	addi	a0,a0,206 # 80010e90 <wait_lock>
    80001dca:	ef3fe0ef          	jal	80000cbc <release>
  acquire(&np->lock);
    80001dce:	854e                	mv	a0,s3
    80001dd0:	e59fe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001dd4:	478d                	li	a5,3
    80001dd6:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001dda:	854e                	mv	a0,s3
    80001ddc:	ee1fe0ef          	jal	80000cbc <release>
  return pid;
    80001de0:	7902                	ld	s2,32(sp)
    80001de2:	69e2                	ld	s3,24(sp)
    80001de4:	6aa2                	ld	s5,8(sp)
}
    80001de6:	8526                	mv	a0,s1
    80001de8:	70e2                	ld	ra,56(sp)
    80001dea:	7442                	ld	s0,48(sp)
    80001dec:	74a2                	ld	s1,40(sp)
    80001dee:	6a42                	ld	s4,16(sp)
    80001df0:	6121                	addi	sp,sp,64
    80001df2:	8082                	ret
    return -1;
    80001df4:	54fd                	li	s1,-1
    80001df6:	bfc5                	j	80001de6 <kfork+0x148>

0000000080001df8 <scheduler>:
{
    80001df8:	715d                	addi	sp,sp,-80
    80001dfa:	e486                	sd	ra,72(sp)
    80001dfc:	e0a2                	sd	s0,64(sp)
    80001dfe:	fc26                	sd	s1,56(sp)
    80001e00:	f84a                	sd	s2,48(sp)
    80001e02:	f44e                	sd	s3,40(sp)
    80001e04:	f052                	sd	s4,32(sp)
    80001e06:	ec56                	sd	s5,24(sp)
    80001e08:	e85a                	sd	s6,16(sp)
    80001e0a:	e45e                	sd	s7,8(sp)
    80001e0c:	e062                	sd	s8,0(sp)
    80001e0e:	0880                	addi	s0,sp,80
    80001e10:	8792                	mv	a5,tp
  int id = r_tp();
    80001e12:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001e14:	00779b13          	slli	s6,a5,0x7
    80001e18:	0000f717          	auipc	a4,0xf
    80001e1c:	06070713          	addi	a4,a4,96 # 80010e78 <pid_lock>
    80001e20:	975a                	add	a4,a4,s6
    80001e22:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001e26:	0000f717          	auipc	a4,0xf
    80001e2a:	08a70713          	addi	a4,a4,138 # 80010eb0 <cpus+0x8>
    80001e2e:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001e30:	4c11                	li	s8,4
        c->proc = p;
    80001e32:	079e                	slli	a5,a5,0x7
    80001e34:	0000fa17          	auipc	s4,0xf
    80001e38:	044a0a13          	addi	s4,s4,68 # 80010e78 <pid_lock>
    80001e3c:	9a3e                	add	s4,s4,a5
        found = 1;
    80001e3e:	4b85                	li	s7,1
    80001e40:	a83d                	j	80001e7e <scheduler+0x86>
      release(&p->lock);
    80001e42:	8526                	mv	a0,s1
    80001e44:	e79fe0ef          	jal	80000cbc <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e48:	1a048493          	addi	s1,s1,416
    80001e4c:	03248563          	beq	s1,s2,80001e76 <scheduler+0x7e>
      acquire(&p->lock);
    80001e50:	8526                	mv	a0,s1
    80001e52:	dd7fe0ef          	jal	80000c28 <acquire>
      if(p->state == RUNNABLE) {
    80001e56:	4c9c                	lw	a5,24(s1)
    80001e58:	ff3795e3          	bne	a5,s3,80001e42 <scheduler+0x4a>
        p->state = RUNNING;
    80001e5c:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001e60:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001e64:	06048593          	addi	a1,s1,96
    80001e68:	855a                	mv	a0,s6
    80001e6a:	5ba000ef          	jal	80002424 <swtch>
        c->proc = 0;
    80001e6e:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001e72:	8ade                	mv	s5,s7
    80001e74:	b7f9                	j	80001e42 <scheduler+0x4a>
    if(found == 0) {
    80001e76:	000a9463          	bnez	s5,80001e7e <scheduler+0x86>
      asm volatile("wfi");
    80001e7a:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e7e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001e82:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e86:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e8a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001e8e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e90:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001e94:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e96:	0000f497          	auipc	s1,0xf
    80001e9a:	41248493          	addi	s1,s1,1042 # 800112a8 <proc>
      if(p->state == RUNNABLE) {
    80001e9e:	498d                	li	s3,3
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ea0:	00016917          	auipc	s2,0x16
    80001ea4:	c0890913          	addi	s2,s2,-1016 # 80017aa8 <tickslock>
    80001ea8:	b765                	j	80001e50 <scheduler+0x58>

0000000080001eaa <sched>:
{
    80001eaa:	7179                	addi	sp,sp,-48
    80001eac:	f406                	sd	ra,40(sp)
    80001eae:	f022                	sd	s0,32(sp)
    80001eb0:	ec26                	sd	s1,24(sp)
    80001eb2:	e84a                	sd	s2,16(sp)
    80001eb4:	e44e                	sd	s3,8(sp)
    80001eb6:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001eb8:	a7fff0ef          	jal	80001936 <myproc>
    80001ebc:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001ebe:	cfbfe0ef          	jal	80000bb8 <holding>
    80001ec2:	c935                	beqz	a0,80001f36 <sched+0x8c>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ec4:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001ec6:	2781                	sext.w	a5,a5
    80001ec8:	079e                	slli	a5,a5,0x7
    80001eca:	0000f717          	auipc	a4,0xf
    80001ece:	fae70713          	addi	a4,a4,-82 # 80010e78 <pid_lock>
    80001ed2:	97ba                	add	a5,a5,a4
    80001ed4:	0a87a703          	lw	a4,168(a5)
    80001ed8:	4785                	li	a5,1
    80001eda:	06f71463          	bne	a4,a5,80001f42 <sched+0x98>
  if(p->state == RUNNING)
    80001ede:	4c98                	lw	a4,24(s1)
    80001ee0:	4791                	li	a5,4
    80001ee2:	06f70663          	beq	a4,a5,80001f4e <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ee6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001eea:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001eec:	e7bd                	bnez	a5,80001f5a <sched+0xb0>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001eee:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001ef0:	0000f917          	auipc	s2,0xf
    80001ef4:	f8890913          	addi	s2,s2,-120 # 80010e78 <pid_lock>
    80001ef8:	2781                	sext.w	a5,a5
    80001efa:	079e                	slli	a5,a5,0x7
    80001efc:	97ca                	add	a5,a5,s2
    80001efe:	0ac7a983          	lw	s3,172(a5)
    80001f02:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001f04:	2781                	sext.w	a5,a5
    80001f06:	079e                	slli	a5,a5,0x7
    80001f08:	07a1                	addi	a5,a5,8
    80001f0a:	0000f597          	auipc	a1,0xf
    80001f0e:	f9e58593          	addi	a1,a1,-98 # 80010ea8 <cpus>
    80001f12:	95be                	add	a1,a1,a5
    80001f14:	06048513          	addi	a0,s1,96
    80001f18:	50c000ef          	jal	80002424 <swtch>
    80001f1c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001f1e:	2781                	sext.w	a5,a5
    80001f20:	079e                	slli	a5,a5,0x7
    80001f22:	993e                	add	s2,s2,a5
    80001f24:	0b392623          	sw	s3,172(s2)
}
    80001f28:	70a2                	ld	ra,40(sp)
    80001f2a:	7402                	ld	s0,32(sp)
    80001f2c:	64e2                	ld	s1,24(sp)
    80001f2e:	6942                	ld	s2,16(sp)
    80001f30:	69a2                	ld	s3,8(sp)
    80001f32:	6145                	addi	sp,sp,48
    80001f34:	8082                	ret
    panic("sched p->lock");
    80001f36:	00006517          	auipc	a0,0x6
    80001f3a:	29a50513          	addi	a0,a0,666 # 800081d0 <etext+0x1d0>
    80001f3e:	8e7fe0ef          	jal	80000824 <panic>
    panic("sched locks");
    80001f42:	00006517          	auipc	a0,0x6
    80001f46:	29e50513          	addi	a0,a0,670 # 800081e0 <etext+0x1e0>
    80001f4a:	8dbfe0ef          	jal	80000824 <panic>
    panic("sched RUNNING");
    80001f4e:	00006517          	auipc	a0,0x6
    80001f52:	2a250513          	addi	a0,a0,674 # 800081f0 <etext+0x1f0>
    80001f56:	8cffe0ef          	jal	80000824 <panic>
    panic("sched interruptible");
    80001f5a:	00006517          	auipc	a0,0x6
    80001f5e:	2a650513          	addi	a0,a0,678 # 80008200 <etext+0x200>
    80001f62:	8c3fe0ef          	jal	80000824 <panic>

0000000080001f66 <yield>:
{
    80001f66:	1101                	addi	sp,sp,-32
    80001f68:	ec06                	sd	ra,24(sp)
    80001f6a:	e822                	sd	s0,16(sp)
    80001f6c:	e426                	sd	s1,8(sp)
    80001f6e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001f70:	9c7ff0ef          	jal	80001936 <myproc>
    80001f74:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001f76:	cb3fe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    80001f7a:	478d                	li	a5,3
    80001f7c:	cc9c                	sw	a5,24(s1)
  sched();
    80001f7e:	f2dff0ef          	jal	80001eaa <sched>
  release(&p->lock);
    80001f82:	8526                	mv	a0,s1
    80001f84:	d39fe0ef          	jal	80000cbc <release>
}
    80001f88:	60e2                	ld	ra,24(sp)
    80001f8a:	6442                	ld	s0,16(sp)
    80001f8c:	64a2                	ld	s1,8(sp)
    80001f8e:	6105                	addi	sp,sp,32
    80001f90:	8082                	ret

0000000080001f92 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001f92:	7179                	addi	sp,sp,-48
    80001f94:	f406                	sd	ra,40(sp)
    80001f96:	f022                	sd	s0,32(sp)
    80001f98:	ec26                	sd	s1,24(sp)
    80001f9a:	e84a                	sd	s2,16(sp)
    80001f9c:	e44e                	sd	s3,8(sp)
    80001f9e:	1800                	addi	s0,sp,48
    80001fa0:	89aa                	mv	s3,a0
    80001fa2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001fa4:	993ff0ef          	jal	80001936 <myproc>
    80001fa8:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001faa:	c7ffe0ef          	jal	80000c28 <acquire>
  release(lk);
    80001fae:	854a                	mv	a0,s2
    80001fb0:	d0dfe0ef          	jal	80000cbc <release>

  // Go to sleep.
  p->chan = chan;
    80001fb4:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001fb8:	4789                	li	a5,2
    80001fba:	cc9c                	sw	a5,24(s1)

  sched();
    80001fbc:	eefff0ef          	jal	80001eaa <sched>

  // Tidy up.
  p->chan = 0;
    80001fc0:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001fc4:	8526                	mv	a0,s1
    80001fc6:	cf7fe0ef          	jal	80000cbc <release>
  acquire(lk);
    80001fca:	854a                	mv	a0,s2
    80001fcc:	c5dfe0ef          	jal	80000c28 <acquire>
}
    80001fd0:	70a2                	ld	ra,40(sp)
    80001fd2:	7402                	ld	s0,32(sp)
    80001fd4:	64e2                	ld	s1,24(sp)
    80001fd6:	6942                	ld	s2,16(sp)
    80001fd8:	69a2                	ld	s3,8(sp)
    80001fda:	6145                	addi	sp,sp,48
    80001fdc:	8082                	ret

0000000080001fde <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80001fde:	7139                	addi	sp,sp,-64
    80001fe0:	fc06                	sd	ra,56(sp)
    80001fe2:	f822                	sd	s0,48(sp)
    80001fe4:	f426                	sd	s1,40(sp)
    80001fe6:	f04a                	sd	s2,32(sp)
    80001fe8:	ec4e                	sd	s3,24(sp)
    80001fea:	e852                	sd	s4,16(sp)
    80001fec:	e456                	sd	s5,8(sp)
    80001fee:	0080                	addi	s0,sp,64
    80001ff0:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001ff2:	0000f497          	auipc	s1,0xf
    80001ff6:	2b648493          	addi	s1,s1,694 # 800112a8 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001ffa:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001ffc:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ffe:	00016917          	auipc	s2,0x16
    80002002:	aaa90913          	addi	s2,s2,-1366 # 80017aa8 <tickslock>
    80002006:	a801                	j	80002016 <wakeup+0x38>
      }
      release(&p->lock);
    80002008:	8526                	mv	a0,s1
    8000200a:	cb3fe0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000200e:	1a048493          	addi	s1,s1,416
    80002012:	03248263          	beq	s1,s2,80002036 <wakeup+0x58>
    if(p != myproc()){
    80002016:	921ff0ef          	jal	80001936 <myproc>
    8000201a:	fe950ae3          	beq	a0,s1,8000200e <wakeup+0x30>
      acquire(&p->lock);
    8000201e:	8526                	mv	a0,s1
    80002020:	c09fe0ef          	jal	80000c28 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002024:	4c9c                	lw	a5,24(s1)
    80002026:	ff3791e3          	bne	a5,s3,80002008 <wakeup+0x2a>
    8000202a:	709c                	ld	a5,32(s1)
    8000202c:	fd479ee3          	bne	a5,s4,80002008 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002030:	0154ac23          	sw	s5,24(s1)
    80002034:	bfd1                	j	80002008 <wakeup+0x2a>
    }
  }
}
    80002036:	70e2                	ld	ra,56(sp)
    80002038:	7442                	ld	s0,48(sp)
    8000203a:	74a2                	ld	s1,40(sp)
    8000203c:	7902                	ld	s2,32(sp)
    8000203e:	69e2                	ld	s3,24(sp)
    80002040:	6a42                	ld	s4,16(sp)
    80002042:	6aa2                	ld	s5,8(sp)
    80002044:	6121                	addi	sp,sp,64
    80002046:	8082                	ret

0000000080002048 <reparent>:
{
    80002048:	7179                	addi	sp,sp,-48
    8000204a:	f406                	sd	ra,40(sp)
    8000204c:	f022                	sd	s0,32(sp)
    8000204e:	ec26                	sd	s1,24(sp)
    80002050:	e84a                	sd	s2,16(sp)
    80002052:	e44e                	sd	s3,8(sp)
    80002054:	e052                	sd	s4,0(sp)
    80002056:	1800                	addi	s0,sp,48
    80002058:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000205a:	0000f497          	auipc	s1,0xf
    8000205e:	24e48493          	addi	s1,s1,590 # 800112a8 <proc>
      pp->parent = initproc;
    80002062:	00007a17          	auipc	s4,0x7
    80002066:	d0ea0a13          	addi	s4,s4,-754 # 80008d70 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000206a:	00016997          	auipc	s3,0x16
    8000206e:	a3e98993          	addi	s3,s3,-1474 # 80017aa8 <tickslock>
    80002072:	a029                	j	8000207c <reparent+0x34>
    80002074:	1a048493          	addi	s1,s1,416
    80002078:	01348b63          	beq	s1,s3,8000208e <reparent+0x46>
    if(pp->parent == p){
    8000207c:	7c9c                	ld	a5,56(s1)
    8000207e:	ff279be3          	bne	a5,s2,80002074 <reparent+0x2c>
      pp->parent = initproc;
    80002082:	000a3503          	ld	a0,0(s4)
    80002086:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002088:	f57ff0ef          	jal	80001fde <wakeup>
    8000208c:	b7e5                	j	80002074 <reparent+0x2c>
}
    8000208e:	70a2                	ld	ra,40(sp)
    80002090:	7402                	ld	s0,32(sp)
    80002092:	64e2                	ld	s1,24(sp)
    80002094:	6942                	ld	s2,16(sp)
    80002096:	69a2                	ld	s3,8(sp)
    80002098:	6a02                	ld	s4,0(sp)
    8000209a:	6145                	addi	sp,sp,48
    8000209c:	8082                	ret

000000008000209e <kexit>:
{
    8000209e:	7179                	addi	sp,sp,-48
    800020a0:	f406                	sd	ra,40(sp)
    800020a2:	f022                	sd	s0,32(sp)
    800020a4:	ec26                	sd	s1,24(sp)
    800020a6:	e84a                	sd	s2,16(sp)
    800020a8:	e44e                	sd	s3,8(sp)
    800020aa:	e052                	sd	s4,0(sp)
    800020ac:	1800                	addi	s0,sp,48
    800020ae:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800020b0:	887ff0ef          	jal	80001936 <myproc>
    800020b4:	89aa                	mv	s3,a0
  if(p == initproc)
    800020b6:	00007797          	auipc	a5,0x7
    800020ba:	cba7b783          	ld	a5,-838(a5) # 80008d70 <initproc>
    800020be:	0d050493          	addi	s1,a0,208
    800020c2:	15050913          	addi	s2,a0,336
    800020c6:	00a79b63          	bne	a5,a0,800020dc <kexit+0x3e>
    panic("init exiting");
    800020ca:	00006517          	auipc	a0,0x6
    800020ce:	14e50513          	addi	a0,a0,334 # 80008218 <etext+0x218>
    800020d2:	f52fe0ef          	jal	80000824 <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    800020d6:	04a1                	addi	s1,s1,8
    800020d8:	01248963          	beq	s1,s2,800020ea <kexit+0x4c>
    if(p->ofile[fd]){
    800020dc:	6088                	ld	a0,0(s1)
    800020de:	dd65                	beqz	a0,800020d6 <kexit+0x38>
      fileclose(f);
    800020e0:	098020ef          	jal	80004178 <fileclose>
      p->ofile[fd] = 0;
    800020e4:	0004b023          	sd	zero,0(s1)
    800020e8:	b7fd                	j	800020d6 <kexit+0x38>
  begin_op();
    800020ea:	3fb010ef          	jal	80003ce4 <begin_op>
  iput(p->cwd);
    800020ee:	1509b503          	ld	a0,336(s3)
    800020f2:	364010ef          	jal	80003456 <iput>
  end_op();
    800020f6:	45f010ef          	jal	80003d54 <end_op>
  p->cwd = 0;
    800020fa:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800020fe:	0000f517          	auipc	a0,0xf
    80002102:	d9250513          	addi	a0,a0,-622 # 80010e90 <wait_lock>
    80002106:	b23fe0ef          	jal	80000c28 <acquire>
  reparent(p);
    8000210a:	854e                	mv	a0,s3
    8000210c:	f3dff0ef          	jal	80002048 <reparent>
  wakeup(p->parent);
    80002110:	0389b503          	ld	a0,56(s3)
    80002114:	ecbff0ef          	jal	80001fde <wakeup>
  acquire(&p->lock);
    80002118:	854e                	mv	a0,s3
    8000211a:	b0ffe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    8000211e:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002122:	4795                	li	a5,5
    80002124:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002128:	0000f517          	auipc	a0,0xf
    8000212c:	d6850513          	addi	a0,a0,-664 # 80010e90 <wait_lock>
    80002130:	b8dfe0ef          	jal	80000cbc <release>
  sched();
    80002134:	d77ff0ef          	jal	80001eaa <sched>
  panic("zombie exit");
    80002138:	00006517          	auipc	a0,0x6
    8000213c:	0f050513          	addi	a0,a0,240 # 80008228 <etext+0x228>
    80002140:	ee4fe0ef          	jal	80000824 <panic>

0000000080002144 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80002144:	7179                	addi	sp,sp,-48
    80002146:	f406                	sd	ra,40(sp)
    80002148:	f022                	sd	s0,32(sp)
    8000214a:	ec26                	sd	s1,24(sp)
    8000214c:	e84a                	sd	s2,16(sp)
    8000214e:	e44e                	sd	s3,8(sp)
    80002150:	1800                	addi	s0,sp,48
    80002152:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002154:	0000f497          	auipc	s1,0xf
    80002158:	15448493          	addi	s1,s1,340 # 800112a8 <proc>
    8000215c:	00016997          	auipc	s3,0x16
    80002160:	94c98993          	addi	s3,s3,-1716 # 80017aa8 <tickslock>
    acquire(&p->lock);
    80002164:	8526                	mv	a0,s1
    80002166:	ac3fe0ef          	jal	80000c28 <acquire>
    if(p->pid == pid){
    8000216a:	589c                	lw	a5,48(s1)
    8000216c:	01278b63          	beq	a5,s2,80002182 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002170:	8526                	mv	a0,s1
    80002172:	b4bfe0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002176:	1a048493          	addi	s1,s1,416
    8000217a:	ff3495e3          	bne	s1,s3,80002164 <kkill+0x20>
  }
  return -1;
    8000217e:	557d                	li	a0,-1
    80002180:	a819                	j	80002196 <kkill+0x52>
      p->killed = 1;
    80002182:	4785                	li	a5,1
    80002184:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002186:	4c98                	lw	a4,24(s1)
    80002188:	4789                	li	a5,2
    8000218a:	00f70d63          	beq	a4,a5,800021a4 <kkill+0x60>
      release(&p->lock);
    8000218e:	8526                	mv	a0,s1
    80002190:	b2dfe0ef          	jal	80000cbc <release>
      return 0;
    80002194:	4501                	li	a0,0
}
    80002196:	70a2                	ld	ra,40(sp)
    80002198:	7402                	ld	s0,32(sp)
    8000219a:	64e2                	ld	s1,24(sp)
    8000219c:	6942                	ld	s2,16(sp)
    8000219e:	69a2                	ld	s3,8(sp)
    800021a0:	6145                	addi	sp,sp,48
    800021a2:	8082                	ret
        p->state = RUNNABLE;
    800021a4:	478d                	li	a5,3
    800021a6:	cc9c                	sw	a5,24(s1)
    800021a8:	b7dd                	j	8000218e <kkill+0x4a>

00000000800021aa <setkilled>:

void
setkilled(struct proc *p)
{
    800021aa:	1101                	addi	sp,sp,-32
    800021ac:	ec06                	sd	ra,24(sp)
    800021ae:	e822                	sd	s0,16(sp)
    800021b0:	e426                	sd	s1,8(sp)
    800021b2:	1000                	addi	s0,sp,32
    800021b4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021b6:	a73fe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    800021ba:	4785                	li	a5,1
    800021bc:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800021be:	8526                	mv	a0,s1
    800021c0:	afdfe0ef          	jal	80000cbc <release>
}
    800021c4:	60e2                	ld	ra,24(sp)
    800021c6:	6442                	ld	s0,16(sp)
    800021c8:	64a2                	ld	s1,8(sp)
    800021ca:	6105                	addi	sp,sp,32
    800021cc:	8082                	ret

00000000800021ce <killed>:

int
killed(struct proc *p)
{
    800021ce:	1101                	addi	sp,sp,-32
    800021d0:	ec06                	sd	ra,24(sp)
    800021d2:	e822                	sd	s0,16(sp)
    800021d4:	e426                	sd	s1,8(sp)
    800021d6:	e04a                	sd	s2,0(sp)
    800021d8:	1000                	addi	s0,sp,32
    800021da:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800021dc:	a4dfe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    800021e0:	549c                	lw	a5,40(s1)
    800021e2:	893e                	mv	s2,a5
  release(&p->lock);
    800021e4:	8526                	mv	a0,s1
    800021e6:	ad7fe0ef          	jal	80000cbc <release>
  return k;
}
    800021ea:	854a                	mv	a0,s2
    800021ec:	60e2                	ld	ra,24(sp)
    800021ee:	6442                	ld	s0,16(sp)
    800021f0:	64a2                	ld	s1,8(sp)
    800021f2:	6902                	ld	s2,0(sp)
    800021f4:	6105                	addi	sp,sp,32
    800021f6:	8082                	ret

00000000800021f8 <kwait>:
{
    800021f8:	715d                	addi	sp,sp,-80
    800021fa:	e486                	sd	ra,72(sp)
    800021fc:	e0a2                	sd	s0,64(sp)
    800021fe:	fc26                	sd	s1,56(sp)
    80002200:	f84a                	sd	s2,48(sp)
    80002202:	f44e                	sd	s3,40(sp)
    80002204:	f052                	sd	s4,32(sp)
    80002206:	ec56                	sd	s5,24(sp)
    80002208:	e85a                	sd	s6,16(sp)
    8000220a:	e45e                	sd	s7,8(sp)
    8000220c:	0880                	addi	s0,sp,80
    8000220e:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002210:	f26ff0ef          	jal	80001936 <myproc>
    80002214:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002216:	0000f517          	auipc	a0,0xf
    8000221a:	c7a50513          	addi	a0,a0,-902 # 80010e90 <wait_lock>
    8000221e:	a0bfe0ef          	jal	80000c28 <acquire>
        if(pp->state == ZOMBIE){
    80002222:	4a15                	li	s4,5
        havekids = 1;
    80002224:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002226:	00016997          	auipc	s3,0x16
    8000222a:	88298993          	addi	s3,s3,-1918 # 80017aa8 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000222e:	0000fb17          	auipc	s6,0xf
    80002232:	c62b0b13          	addi	s6,s6,-926 # 80010e90 <wait_lock>
    80002236:	a869                	j	800022d0 <kwait+0xd8>
          pid = pp->pid;
    80002238:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000223c:	000b8c63          	beqz	s7,80002254 <kwait+0x5c>
    80002240:	4691                	li	a3,4
    80002242:	02c48613          	addi	a2,s1,44
    80002246:	85de                	mv	a1,s7
    80002248:	05093503          	ld	a0,80(s2)
    8000224c:	c10ff0ef          	jal	8000165c <copyout>
    80002250:	02054a63          	bltz	a0,80002284 <kwait+0x8c>
          freeproc(pp);
    80002254:	8526                	mv	a0,s1
    80002256:	8b5ff0ef          	jal	80001b0a <freeproc>
          release(&pp->lock);
    8000225a:	8526                	mv	a0,s1
    8000225c:	a61fe0ef          	jal	80000cbc <release>
          release(&wait_lock);
    80002260:	0000f517          	auipc	a0,0xf
    80002264:	c3050513          	addi	a0,a0,-976 # 80010e90 <wait_lock>
    80002268:	a55fe0ef          	jal	80000cbc <release>
}
    8000226c:	854e                	mv	a0,s3
    8000226e:	60a6                	ld	ra,72(sp)
    80002270:	6406                	ld	s0,64(sp)
    80002272:	74e2                	ld	s1,56(sp)
    80002274:	7942                	ld	s2,48(sp)
    80002276:	79a2                	ld	s3,40(sp)
    80002278:	7a02                	ld	s4,32(sp)
    8000227a:	6ae2                	ld	s5,24(sp)
    8000227c:	6b42                	ld	s6,16(sp)
    8000227e:	6ba2                	ld	s7,8(sp)
    80002280:	6161                	addi	sp,sp,80
    80002282:	8082                	ret
            release(&pp->lock);
    80002284:	8526                	mv	a0,s1
    80002286:	a37fe0ef          	jal	80000cbc <release>
            release(&wait_lock);
    8000228a:	0000f517          	auipc	a0,0xf
    8000228e:	c0650513          	addi	a0,a0,-1018 # 80010e90 <wait_lock>
    80002292:	a2bfe0ef          	jal	80000cbc <release>
            return -1;
    80002296:	59fd                	li	s3,-1
    80002298:	bfd1                	j	8000226c <kwait+0x74>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000229a:	1a048493          	addi	s1,s1,416
    8000229e:	03348063          	beq	s1,s3,800022be <kwait+0xc6>
      if(pp->parent == p){
    800022a2:	7c9c                	ld	a5,56(s1)
    800022a4:	ff279be3          	bne	a5,s2,8000229a <kwait+0xa2>
        acquire(&pp->lock);
    800022a8:	8526                	mv	a0,s1
    800022aa:	97ffe0ef          	jal	80000c28 <acquire>
        if(pp->state == ZOMBIE){
    800022ae:	4c9c                	lw	a5,24(s1)
    800022b0:	f94784e3          	beq	a5,s4,80002238 <kwait+0x40>
        release(&pp->lock);
    800022b4:	8526                	mv	a0,s1
    800022b6:	a07fe0ef          	jal	80000cbc <release>
        havekids = 1;
    800022ba:	8756                	mv	a4,s5
    800022bc:	bff9                	j	8000229a <kwait+0xa2>
    if(!havekids || killed(p)){
    800022be:	cf19                	beqz	a4,800022dc <kwait+0xe4>
    800022c0:	854a                	mv	a0,s2
    800022c2:	f0dff0ef          	jal	800021ce <killed>
    800022c6:	e919                	bnez	a0,800022dc <kwait+0xe4>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800022c8:	85da                	mv	a1,s6
    800022ca:	854a                	mv	a0,s2
    800022cc:	cc7ff0ef          	jal	80001f92 <sleep>
    havekids = 0;
    800022d0:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800022d2:	0000f497          	auipc	s1,0xf
    800022d6:	fd648493          	addi	s1,s1,-42 # 800112a8 <proc>
    800022da:	b7e1                	j	800022a2 <kwait+0xaa>
      release(&wait_lock);
    800022dc:	0000f517          	auipc	a0,0xf
    800022e0:	bb450513          	addi	a0,a0,-1100 # 80010e90 <wait_lock>
    800022e4:	9d9fe0ef          	jal	80000cbc <release>
      return -1;
    800022e8:	59fd                	li	s3,-1
    800022ea:	b749                	j	8000226c <kwait+0x74>

00000000800022ec <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800022ec:	7179                	addi	sp,sp,-48
    800022ee:	f406                	sd	ra,40(sp)
    800022f0:	f022                	sd	s0,32(sp)
    800022f2:	ec26                	sd	s1,24(sp)
    800022f4:	e84a                	sd	s2,16(sp)
    800022f6:	e44e                	sd	s3,8(sp)
    800022f8:	e052                	sd	s4,0(sp)
    800022fa:	1800                	addi	s0,sp,48
    800022fc:	84aa                	mv	s1,a0
    800022fe:	8a2e                	mv	s4,a1
    80002300:	89b2                	mv	s3,a2
    80002302:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002304:	e32ff0ef          	jal	80001936 <myproc>
  if(user_dst){
    80002308:	cc99                	beqz	s1,80002326 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    8000230a:	86ca                	mv	a3,s2
    8000230c:	864e                	mv	a2,s3
    8000230e:	85d2                	mv	a1,s4
    80002310:	6928                	ld	a0,80(a0)
    80002312:	b4aff0ef          	jal	8000165c <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002316:	70a2                	ld	ra,40(sp)
    80002318:	7402                	ld	s0,32(sp)
    8000231a:	64e2                	ld	s1,24(sp)
    8000231c:	6942                	ld	s2,16(sp)
    8000231e:	69a2                	ld	s3,8(sp)
    80002320:	6a02                	ld	s4,0(sp)
    80002322:	6145                	addi	sp,sp,48
    80002324:	8082                	ret
    memmove((char *)dst, src, len);
    80002326:	0009061b          	sext.w	a2,s2
    8000232a:	85ce                	mv	a1,s3
    8000232c:	8552                	mv	a0,s4
    8000232e:	a2bfe0ef          	jal	80000d58 <memmove>
    return 0;
    80002332:	8526                	mv	a0,s1
    80002334:	b7cd                	j	80002316 <either_copyout+0x2a>

0000000080002336 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002336:	7179                	addi	sp,sp,-48
    80002338:	f406                	sd	ra,40(sp)
    8000233a:	f022                	sd	s0,32(sp)
    8000233c:	ec26                	sd	s1,24(sp)
    8000233e:	e84a                	sd	s2,16(sp)
    80002340:	e44e                	sd	s3,8(sp)
    80002342:	e052                	sd	s4,0(sp)
    80002344:	1800                	addi	s0,sp,48
    80002346:	8a2a                	mv	s4,a0
    80002348:	84ae                	mv	s1,a1
    8000234a:	89b2                	mv	s3,a2
    8000234c:	8936                	mv	s2,a3
  struct proc *p = myproc();
    8000234e:	de8ff0ef          	jal	80001936 <myproc>
  if(user_src){
    80002352:	cc99                	beqz	s1,80002370 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002354:	86ca                	mv	a3,s2
    80002356:	864e                	mv	a2,s3
    80002358:	85d2                	mv	a1,s4
    8000235a:	6928                	ld	a0,80(a0)
    8000235c:	bbeff0ef          	jal	8000171a <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002360:	70a2                	ld	ra,40(sp)
    80002362:	7402                	ld	s0,32(sp)
    80002364:	64e2                	ld	s1,24(sp)
    80002366:	6942                	ld	s2,16(sp)
    80002368:	69a2                	ld	s3,8(sp)
    8000236a:	6a02                	ld	s4,0(sp)
    8000236c:	6145                	addi	sp,sp,48
    8000236e:	8082                	ret
    memmove(dst, (char*)src, len);
    80002370:	0009061b          	sext.w	a2,s2
    80002374:	85ce                	mv	a1,s3
    80002376:	8552                	mv	a0,s4
    80002378:	9e1fe0ef          	jal	80000d58 <memmove>
    return 0;
    8000237c:	8526                	mv	a0,s1
    8000237e:	b7cd                	j	80002360 <either_copyin+0x2a>

0000000080002380 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002380:	715d                	addi	sp,sp,-80
    80002382:	e486                	sd	ra,72(sp)
    80002384:	e0a2                	sd	s0,64(sp)
    80002386:	fc26                	sd	s1,56(sp)
    80002388:	f84a                	sd	s2,48(sp)
    8000238a:	f44e                	sd	s3,40(sp)
    8000238c:	f052                	sd	s4,32(sp)
    8000238e:	ec56                	sd	s5,24(sp)
    80002390:	e85a                	sd	s6,16(sp)
    80002392:	e45e                	sd	s7,8(sp)
    80002394:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002396:	00006517          	auipc	a0,0x6
    8000239a:	3ca50513          	addi	a0,a0,970 # 80008760 <etext+0x760>
    8000239e:	95cfe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800023a2:	0000f497          	auipc	s1,0xf
    800023a6:	05e48493          	addi	s1,s1,94 # 80011400 <proc+0x158>
    800023aa:	00016917          	auipc	s2,0x16
    800023ae:	85690913          	addi	s2,s2,-1962 # 80017c00 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023b2:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800023b4:	00006997          	auipc	s3,0x6
    800023b8:	e8498993          	addi	s3,s3,-380 # 80008238 <etext+0x238>
    printf("%d %s %s", p->pid, state, p->name);
    800023bc:	00006a97          	auipc	s5,0x6
    800023c0:	e84a8a93          	addi	s5,s5,-380 # 80008240 <etext+0x240>
    printf("\n");
    800023c4:	00006a17          	auipc	s4,0x6
    800023c8:	39ca0a13          	addi	s4,s4,924 # 80008760 <etext+0x760>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023cc:	00006b97          	auipc	s7,0x6
    800023d0:	744b8b93          	addi	s7,s7,1860 # 80008b10 <states.0>
    800023d4:	a829                	j	800023ee <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800023d6:	ed86a583          	lw	a1,-296(a3)
    800023da:	8556                	mv	a0,s5
    800023dc:	91efe0ef          	jal	800004fa <printf>
    printf("\n");
    800023e0:	8552                	mv	a0,s4
    800023e2:	918fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800023e6:	1a048493          	addi	s1,s1,416
    800023ea:	03248263          	beq	s1,s2,8000240e <procdump+0x8e>
    if(p->state == UNUSED)
    800023ee:	86a6                	mv	a3,s1
    800023f0:	ec04a783          	lw	a5,-320(s1)
    800023f4:	dbed                	beqz	a5,800023e6 <procdump+0x66>
      state = "???";
    800023f6:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023f8:	fcfb6fe3          	bltu	s6,a5,800023d6 <procdump+0x56>
    800023fc:	02079713          	slli	a4,a5,0x20
    80002400:	01d75793          	srli	a5,a4,0x1d
    80002404:	97de                	add	a5,a5,s7
    80002406:	6390                	ld	a2,0(a5)
    80002408:	f679                	bnez	a2,800023d6 <procdump+0x56>
      state = "???";
    8000240a:	864e                	mv	a2,s3
    8000240c:	b7e9                	j	800023d6 <procdump+0x56>
  }
}
    8000240e:	60a6                	ld	ra,72(sp)
    80002410:	6406                	ld	s0,64(sp)
    80002412:	74e2                	ld	s1,56(sp)
    80002414:	7942                	ld	s2,48(sp)
    80002416:	79a2                	ld	s3,40(sp)
    80002418:	7a02                	ld	s4,32(sp)
    8000241a:	6ae2                	ld	s5,24(sp)
    8000241c:	6b42                	ld	s6,16(sp)
    8000241e:	6ba2                	ld	s7,8(sp)
    80002420:	6161                	addi	sp,sp,80
    80002422:	8082                	ret

0000000080002424 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002424:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002428:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    8000242c:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    8000242e:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002430:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002434:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002438:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    8000243c:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002440:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002444:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002448:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    8000244c:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002450:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002454:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002458:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    8000245c:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002460:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002462:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002464:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002468:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    8000246c:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002470:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002474:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002478:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    8000247c:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002480:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002484:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002488:	0685bd83          	ld	s11,104(a1)
        
        ret
    8000248c:	8082                	ret

000000008000248e <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000248e:	1141                	addi	sp,sp,-16
    80002490:	e406                	sd	ra,8(sp)
    80002492:	e022                	sd	s0,0(sp)
    80002494:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002496:	00006597          	auipc	a1,0x6
    8000249a:	dea58593          	addi	a1,a1,-534 # 80008280 <etext+0x280>
    8000249e:	00015517          	auipc	a0,0x15
    800024a2:	60a50513          	addi	a0,a0,1546 # 80017aa8 <tickslock>
    800024a6:	ef8fe0ef          	jal	80000b9e <initlock>
}
    800024aa:	60a2                	ld	ra,8(sp)
    800024ac:	6402                	ld	s0,0(sp)
    800024ae:	0141                	addi	sp,sp,16
    800024b0:	8082                	ret

00000000800024b2 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800024b2:	1141                	addi	sp,sp,-16
    800024b4:	e406                	sd	ra,8(sp)
    800024b6:	e022                	sd	s0,0(sp)
    800024b8:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800024ba:	00003797          	auipc	a5,0x3
    800024be:	30678793          	addi	a5,a5,774 # 800057c0 <kernelvec>
    800024c2:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800024c6:	60a2                	ld	ra,8(sp)
    800024c8:	6402                	ld	s0,0(sp)
    800024ca:	0141                	addi	sp,sp,16
    800024cc:	8082                	ret

00000000800024ce <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800024ce:	1141                	addi	sp,sp,-16
    800024d0:	e406                	sd	ra,8(sp)
    800024d2:	e022                	sd	s0,0(sp)
    800024d4:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800024d6:	c60ff0ef          	jal	80001936 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024da:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800024de:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024e0:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800024e4:	04000737          	lui	a4,0x4000
    800024e8:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800024ea:	0732                	slli	a4,a4,0xc
    800024ec:	00005797          	auipc	a5,0x5
    800024f0:	b1478793          	addi	a5,a5,-1260 # 80007000 <_trampoline>
    800024f4:	00005697          	auipc	a3,0x5
    800024f8:	b0c68693          	addi	a3,a3,-1268 # 80007000 <_trampoline>
    800024fc:	8f95                	sub	a5,a5,a3
    800024fe:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002500:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002504:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002506:	18002773          	csrr	a4,satp
    8000250a:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000250c:	6d38                	ld	a4,88(a0)
    8000250e:	613c                	ld	a5,64(a0)
    80002510:	6685                	lui	a3,0x1
    80002512:	97b6                	add	a5,a5,a3
    80002514:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002516:	6d3c                	ld	a5,88(a0)
    80002518:	00000717          	auipc	a4,0x0
    8000251c:	0fc70713          	addi	a4,a4,252 # 80002614 <usertrap>
    80002520:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002522:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002524:	8712                	mv	a4,tp
    80002526:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002528:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000252c:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002530:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002534:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002538:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000253a:	6f9c                	ld	a5,24(a5)
    8000253c:	14179073          	csrw	sepc,a5
}
    80002540:	60a2                	ld	ra,8(sp)
    80002542:	6402                	ld	s0,0(sp)
    80002544:	0141                	addi	sp,sp,16
    80002546:	8082                	ret

0000000080002548 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002548:	1141                	addi	sp,sp,-16
    8000254a:	e406                	sd	ra,8(sp)
    8000254c:	e022                	sd	s0,0(sp)
    8000254e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80002550:	bb2ff0ef          	jal	80001902 <cpuid>
    80002554:	cd11                	beqz	a0,80002570 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002556:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    8000255a:	000f4737          	lui	a4,0xf4
    8000255e:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002562:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002564:	14d79073          	csrw	stimecmp,a5
}
    80002568:	60a2                	ld	ra,8(sp)
    8000256a:	6402                	ld	s0,0(sp)
    8000256c:	0141                	addi	sp,sp,16
    8000256e:	8082                	ret
    acquire(&tickslock);
    80002570:	00015517          	auipc	a0,0x15
    80002574:	53850513          	addi	a0,a0,1336 # 80017aa8 <tickslock>
    80002578:	eb0fe0ef          	jal	80000c28 <acquire>
    ticks++;
    8000257c:	00006717          	auipc	a4,0x6
    80002580:	7fc70713          	addi	a4,a4,2044 # 80008d78 <ticks>
    80002584:	431c                	lw	a5,0(a4)
    80002586:	2785                	addiw	a5,a5,1
    80002588:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    8000258a:	853a                	mv	a0,a4
    8000258c:	a53ff0ef          	jal	80001fde <wakeup>
    release(&tickslock);
    80002590:	00015517          	auipc	a0,0x15
    80002594:	51850513          	addi	a0,a0,1304 # 80017aa8 <tickslock>
    80002598:	f24fe0ef          	jal	80000cbc <release>
    8000259c:	bf6d                	j	80002556 <clockintr+0xe>

000000008000259e <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000259e:	1101                	addi	sp,sp,-32
    800025a0:	ec06                	sd	ra,24(sp)
    800025a2:	e822                	sd	s0,16(sp)
    800025a4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800025a6:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800025aa:	57fd                	li	a5,-1
    800025ac:	17fe                	slli	a5,a5,0x3f
    800025ae:	07a5                	addi	a5,a5,9
    800025b0:	00f70c63          	beq	a4,a5,800025c8 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800025b4:	57fd                	li	a5,-1
    800025b6:	17fe                	slli	a5,a5,0x3f
    800025b8:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800025ba:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800025bc:	04f70863          	beq	a4,a5,8000260c <devintr+0x6e>
  }
}
    800025c0:	60e2                	ld	ra,24(sp)
    800025c2:	6442                	ld	s0,16(sp)
    800025c4:	6105                	addi	sp,sp,32
    800025c6:	8082                	ret
    800025c8:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800025ca:	2a2030ef          	jal	8000586c <plic_claim>
    800025ce:	872a                	mv	a4,a0
    800025d0:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800025d2:	47a9                	li	a5,10
    800025d4:	00f50963          	beq	a0,a5,800025e6 <devintr+0x48>
    } else if(irq == VIRTIO0_IRQ){
    800025d8:	4785                	li	a5,1
    800025da:	00f50963          	beq	a0,a5,800025ec <devintr+0x4e>
    return 1;
    800025de:	4505                	li	a0,1
    } else if(irq){
    800025e0:	eb09                	bnez	a4,800025f2 <devintr+0x54>
    800025e2:	64a2                	ld	s1,8(sp)
    800025e4:	bff1                	j	800025c0 <devintr+0x22>
      uartintr();
    800025e6:	c0efe0ef          	jal	800009f4 <uartintr>
    if(irq)
    800025ea:	a819                	j	80002600 <devintr+0x62>
      virtio_disk_intr();
    800025ec:	716030ef          	jal	80005d02 <virtio_disk_intr>
    if(irq)
    800025f0:	a801                	j	80002600 <devintr+0x62>
      printf("unexpected interrupt irq=%d\n", irq);
    800025f2:	85ba                	mv	a1,a4
    800025f4:	00006517          	auipc	a0,0x6
    800025f8:	c9450513          	addi	a0,a0,-876 # 80008288 <etext+0x288>
    800025fc:	efffd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    80002600:	8526                	mv	a0,s1
    80002602:	28a030ef          	jal	8000588c <plic_complete>
    return 1;
    80002606:	4505                	li	a0,1
    80002608:	64a2                	ld	s1,8(sp)
    8000260a:	bf5d                	j	800025c0 <devintr+0x22>
    clockintr();
    8000260c:	f3dff0ef          	jal	80002548 <clockintr>
    return 2;
    80002610:	4509                	li	a0,2
    80002612:	b77d                	j	800025c0 <devintr+0x22>

0000000080002614 <usertrap>:
{
    80002614:	1101                	addi	sp,sp,-32
    80002616:	ec06                	sd	ra,24(sp)
    80002618:	e822                	sd	s0,16(sp)
    8000261a:	e426                	sd	s1,8(sp)
    8000261c:	e04a                	sd	s2,0(sp)
    8000261e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002620:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002624:	1007f793          	andi	a5,a5,256
    80002628:	eba5                	bnez	a5,80002698 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000262a:	00003797          	auipc	a5,0x3
    8000262e:	19678793          	addi	a5,a5,406 # 800057c0 <kernelvec>
    80002632:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002636:	b00ff0ef          	jal	80001936 <myproc>
    8000263a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000263c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000263e:	14102773          	csrr	a4,sepc
    80002642:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002644:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002648:	47a1                	li	a5,8
    8000264a:	04f70d63          	beq	a4,a5,800026a4 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    8000264e:	f51ff0ef          	jal	8000259e <devintr>
    80002652:	892a                	mv	s2,a0
    80002654:	e945                	bnez	a0,80002704 <usertrap+0xf0>
    80002656:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    8000265a:	47bd                	li	a5,15
    8000265c:	08f70863          	beq	a4,a5,800026ec <usertrap+0xd8>
    80002660:	14202773          	csrr	a4,scause
    80002664:	47b5                	li	a5,13
    80002666:	08f70363          	beq	a4,a5,800026ec <usertrap+0xd8>
    8000266a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    8000266e:	5890                	lw	a2,48(s1)
    80002670:	00006517          	auipc	a0,0x6
    80002674:	c5850513          	addi	a0,a0,-936 # 800082c8 <etext+0x2c8>
    80002678:	e83fd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000267c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002680:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002684:	00006517          	auipc	a0,0x6
    80002688:	c7450513          	addi	a0,a0,-908 # 800082f8 <etext+0x2f8>
    8000268c:	e6ffd0ef          	jal	800004fa <printf>
    setkilled(p);
    80002690:	8526                	mv	a0,s1
    80002692:	b19ff0ef          	jal	800021aa <setkilled>
    80002696:	a035                	j	800026c2 <usertrap+0xae>
    panic("usertrap: not from user mode");
    80002698:	00006517          	auipc	a0,0x6
    8000269c:	c1050513          	addi	a0,a0,-1008 # 800082a8 <etext+0x2a8>
    800026a0:	984fe0ef          	jal	80000824 <panic>
    if(killed(p))
    800026a4:	b2bff0ef          	jal	800021ce <killed>
    800026a8:	ed15                	bnez	a0,800026e4 <usertrap+0xd0>
    p->trapframe->epc += 4;
    800026aa:	6cb8                	ld	a4,88(s1)
    800026ac:	6f1c                	ld	a5,24(a4)
    800026ae:	0791                	addi	a5,a5,4
    800026b0:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026b2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800026b6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026ba:	10079073          	csrw	sstatus,a5
    syscall();
    800026be:	244000ef          	jal	80002902 <syscall>
  if(killed(p))
    800026c2:	8526                	mv	a0,s1
    800026c4:	b0bff0ef          	jal	800021ce <killed>
    800026c8:	e139                	bnez	a0,8000270e <usertrap+0xfa>
  prepare_return();
    800026ca:	e05ff0ef          	jal	800024ce <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800026ce:	68a8                	ld	a0,80(s1)
    800026d0:	8131                	srli	a0,a0,0xc
    800026d2:	57fd                	li	a5,-1
    800026d4:	17fe                	slli	a5,a5,0x3f
    800026d6:	8d5d                	or	a0,a0,a5
}
    800026d8:	60e2                	ld	ra,24(sp)
    800026da:	6442                	ld	s0,16(sp)
    800026dc:	64a2                	ld	s1,8(sp)
    800026de:	6902                	ld	s2,0(sp)
    800026e0:	6105                	addi	sp,sp,32
    800026e2:	8082                	ret
      kexit(-1);
    800026e4:	557d                	li	a0,-1
    800026e6:	9b9ff0ef          	jal	8000209e <kexit>
    800026ea:	b7c1                	j	800026aa <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026ec:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026f0:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    800026f4:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    800026f6:	00163613          	seqz	a2,a2
    800026fa:	68a8                	ld	a0,80(s1)
    800026fc:	eddfe0ef          	jal	800015d8 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002700:	f169                	bnez	a0,800026c2 <usertrap+0xae>
    80002702:	b7a5                	j	8000266a <usertrap+0x56>
  if(killed(p))
    80002704:	8526                	mv	a0,s1
    80002706:	ac9ff0ef          	jal	800021ce <killed>
    8000270a:	c511                	beqz	a0,80002716 <usertrap+0x102>
    8000270c:	a011                	j	80002710 <usertrap+0xfc>
    8000270e:	4901                	li	s2,0
    kexit(-1);
    80002710:	557d                	li	a0,-1
    80002712:	98dff0ef          	jal	8000209e <kexit>
  if(which_dev == 2)
    80002716:	4789                	li	a5,2
    80002718:	faf919e3          	bne	s2,a5,800026ca <usertrap+0xb6>
    yield();
    8000271c:	84bff0ef          	jal	80001f66 <yield>
    80002720:	b76d                	j	800026ca <usertrap+0xb6>

0000000080002722 <kerneltrap>:
{
    80002722:	7179                	addi	sp,sp,-48
    80002724:	f406                	sd	ra,40(sp)
    80002726:	f022                	sd	s0,32(sp)
    80002728:	ec26                	sd	s1,24(sp)
    8000272a:	e84a                	sd	s2,16(sp)
    8000272c:	e44e                	sd	s3,8(sp)
    8000272e:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002730:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002734:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002738:	142027f3          	csrr	a5,scause
    8000273c:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    8000273e:	1004f793          	andi	a5,s1,256
    80002742:	c795                	beqz	a5,8000276e <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002744:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002748:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000274a:	eb85                	bnez	a5,8000277a <kerneltrap+0x58>
  if((which_dev = devintr()) == 0){
    8000274c:	e53ff0ef          	jal	8000259e <devintr>
    80002750:	c91d                	beqz	a0,80002786 <kerneltrap+0x64>
  if(which_dev == 2 && myproc() != 0)
    80002752:	4789                	li	a5,2
    80002754:	04f50a63          	beq	a0,a5,800027a8 <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002758:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000275c:	10049073          	csrw	sstatus,s1
}
    80002760:	70a2                	ld	ra,40(sp)
    80002762:	7402                	ld	s0,32(sp)
    80002764:	64e2                	ld	s1,24(sp)
    80002766:	6942                	ld	s2,16(sp)
    80002768:	69a2                	ld	s3,8(sp)
    8000276a:	6145                	addi	sp,sp,48
    8000276c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000276e:	00006517          	auipc	a0,0x6
    80002772:	bb250513          	addi	a0,a0,-1102 # 80008320 <etext+0x320>
    80002776:	8aefe0ef          	jal	80000824 <panic>
    panic("kerneltrap: interrupts enabled");
    8000277a:	00006517          	auipc	a0,0x6
    8000277e:	bce50513          	addi	a0,a0,-1074 # 80008348 <etext+0x348>
    80002782:	8a2fe0ef          	jal	80000824 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002786:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000278a:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    8000278e:	85ce                	mv	a1,s3
    80002790:	00006517          	auipc	a0,0x6
    80002794:	bd850513          	addi	a0,a0,-1064 # 80008368 <etext+0x368>
    80002798:	d63fd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    8000279c:	00006517          	auipc	a0,0x6
    800027a0:	bf450513          	addi	a0,a0,-1036 # 80008390 <etext+0x390>
    800027a4:	880fe0ef          	jal	80000824 <panic>
  if(which_dev == 2 && myproc() != 0)
    800027a8:	98eff0ef          	jal	80001936 <myproc>
    800027ac:	d555                	beqz	a0,80002758 <kerneltrap+0x36>
    yield();
    800027ae:	fb8ff0ef          	jal	80001f66 <yield>
    800027b2:	b75d                	j	80002758 <kerneltrap+0x36>

00000000800027b4 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800027b4:	1101                	addi	sp,sp,-32
    800027b6:	ec06                	sd	ra,24(sp)
    800027b8:	e822                	sd	s0,16(sp)
    800027ba:	e426                	sd	s1,8(sp)
    800027bc:	1000                	addi	s0,sp,32
    800027be:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800027c0:	976ff0ef          	jal	80001936 <myproc>
  switch (n) {
    800027c4:	4795                	li	a5,5
    800027c6:	0497e163          	bltu	a5,s1,80002808 <argraw+0x54>
    800027ca:	048a                	slli	s1,s1,0x2
    800027cc:	00006717          	auipc	a4,0x6
    800027d0:	37470713          	addi	a4,a4,884 # 80008b40 <states.0+0x30>
    800027d4:	94ba                	add	s1,s1,a4
    800027d6:	409c                	lw	a5,0(s1)
    800027d8:	97ba                	add	a5,a5,a4
    800027da:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800027dc:	6d3c                	ld	a5,88(a0)
    800027de:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800027e0:	60e2                	ld	ra,24(sp)
    800027e2:	6442                	ld	s0,16(sp)
    800027e4:	64a2                	ld	s1,8(sp)
    800027e6:	6105                	addi	sp,sp,32
    800027e8:	8082                	ret
    return p->trapframe->a1;
    800027ea:	6d3c                	ld	a5,88(a0)
    800027ec:	7fa8                	ld	a0,120(a5)
    800027ee:	bfcd                	j	800027e0 <argraw+0x2c>
    return p->trapframe->a2;
    800027f0:	6d3c                	ld	a5,88(a0)
    800027f2:	63c8                	ld	a0,128(a5)
    800027f4:	b7f5                	j	800027e0 <argraw+0x2c>
    return p->trapframe->a3;
    800027f6:	6d3c                	ld	a5,88(a0)
    800027f8:	67c8                	ld	a0,136(a5)
    800027fa:	b7dd                	j	800027e0 <argraw+0x2c>
    return p->trapframe->a4;
    800027fc:	6d3c                	ld	a5,88(a0)
    800027fe:	6bc8                	ld	a0,144(a5)
    80002800:	b7c5                	j	800027e0 <argraw+0x2c>
    return p->trapframe->a5;
    80002802:	6d3c                	ld	a5,88(a0)
    80002804:	6fc8                	ld	a0,152(a5)
    80002806:	bfe9                	j	800027e0 <argraw+0x2c>
  panic("argraw");
    80002808:	00006517          	auipc	a0,0x6
    8000280c:	b9850513          	addi	a0,a0,-1128 # 800083a0 <etext+0x3a0>
    80002810:	814fe0ef          	jal	80000824 <panic>

0000000080002814 <fetchaddr>:
{
    80002814:	1101                	addi	sp,sp,-32
    80002816:	ec06                	sd	ra,24(sp)
    80002818:	e822                	sd	s0,16(sp)
    8000281a:	e426                	sd	s1,8(sp)
    8000281c:	e04a                	sd	s2,0(sp)
    8000281e:	1000                	addi	s0,sp,32
    80002820:	84aa                	mv	s1,a0
    80002822:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002824:	912ff0ef          	jal	80001936 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002828:	653c                	ld	a5,72(a0)
    8000282a:	02f4f663          	bgeu	s1,a5,80002856 <fetchaddr+0x42>
    8000282e:	00848713          	addi	a4,s1,8
    80002832:	02e7e463          	bltu	a5,a4,8000285a <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002836:	46a1                	li	a3,8
    80002838:	8626                	mv	a2,s1
    8000283a:	85ca                	mv	a1,s2
    8000283c:	6928                	ld	a0,80(a0)
    8000283e:	eddfe0ef          	jal	8000171a <copyin>
    80002842:	00a03533          	snez	a0,a0
    80002846:	40a0053b          	negw	a0,a0
}
    8000284a:	60e2                	ld	ra,24(sp)
    8000284c:	6442                	ld	s0,16(sp)
    8000284e:	64a2                	ld	s1,8(sp)
    80002850:	6902                	ld	s2,0(sp)
    80002852:	6105                	addi	sp,sp,32
    80002854:	8082                	ret
    return -1;
    80002856:	557d                	li	a0,-1
    80002858:	bfcd                	j	8000284a <fetchaddr+0x36>
    8000285a:	557d                	li	a0,-1
    8000285c:	b7fd                	j	8000284a <fetchaddr+0x36>

000000008000285e <fetchstr>:
{
    8000285e:	7179                	addi	sp,sp,-48
    80002860:	f406                	sd	ra,40(sp)
    80002862:	f022                	sd	s0,32(sp)
    80002864:	ec26                	sd	s1,24(sp)
    80002866:	e84a                	sd	s2,16(sp)
    80002868:	e44e                	sd	s3,8(sp)
    8000286a:	1800                	addi	s0,sp,48
    8000286c:	89aa                	mv	s3,a0
    8000286e:	84ae                	mv	s1,a1
    80002870:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002872:	8c4ff0ef          	jal	80001936 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002876:	86ca                	mv	a3,s2
    80002878:	864e                	mv	a2,s3
    8000287a:	85a6                	mv	a1,s1
    8000287c:	6928                	ld	a0,80(a0)
    8000287e:	c83fe0ef          	jal	80001500 <copyinstr>
    80002882:	00054c63          	bltz	a0,8000289a <fetchstr+0x3c>
  return strlen(buf);
    80002886:	8526                	mv	a0,s1
    80002888:	dfafe0ef          	jal	80000e82 <strlen>
}
    8000288c:	70a2                	ld	ra,40(sp)
    8000288e:	7402                	ld	s0,32(sp)
    80002890:	64e2                	ld	s1,24(sp)
    80002892:	6942                	ld	s2,16(sp)
    80002894:	69a2                	ld	s3,8(sp)
    80002896:	6145                	addi	sp,sp,48
    80002898:	8082                	ret
    return -1;
    8000289a:	557d                	li	a0,-1
    8000289c:	bfc5                	j	8000288c <fetchstr+0x2e>

000000008000289e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    8000289e:	1101                	addi	sp,sp,-32
    800028a0:	ec06                	sd	ra,24(sp)
    800028a2:	e822                	sd	s0,16(sp)
    800028a4:	e426                	sd	s1,8(sp)
    800028a6:	1000                	addi	s0,sp,32
    800028a8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800028aa:	f0bff0ef          	jal	800027b4 <argraw>
    800028ae:	c088                	sw	a0,0(s1)
  return 0;
}
    800028b0:	4501                	li	a0,0
    800028b2:	60e2                	ld	ra,24(sp)
    800028b4:	6442                	ld	s0,16(sp)
    800028b6:	64a2                	ld	s1,8(sp)
    800028b8:	6105                	addi	sp,sp,32
    800028ba:	8082                	ret

00000000800028bc <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    800028bc:	1101                	addi	sp,sp,-32
    800028be:	ec06                	sd	ra,24(sp)
    800028c0:	e822                	sd	s0,16(sp)
    800028c2:	e426                	sd	s1,8(sp)
    800028c4:	1000                	addi	s0,sp,32
    800028c6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800028c8:	eedff0ef          	jal	800027b4 <argraw>
    800028cc:	e088                	sd	a0,0(s1)
  return 0;
}
    800028ce:	4501                	li	a0,0
    800028d0:	60e2                	ld	ra,24(sp)
    800028d2:	6442                	ld	s0,16(sp)
    800028d4:	64a2                	ld	s1,8(sp)
    800028d6:	6105                	addi	sp,sp,32
    800028d8:	8082                	ret

00000000800028da <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800028da:	1101                	addi	sp,sp,-32
    800028dc:	ec06                	sd	ra,24(sp)
    800028de:	e822                	sd	s0,16(sp)
    800028e0:	e426                	sd	s1,8(sp)
    800028e2:	e04a                	sd	s2,0(sp)
    800028e4:	1000                	addi	s0,sp,32
    800028e6:	892e                	mv	s2,a1
    800028e8:	84b2                	mv	s1,a2
  *ip = argraw(n);
    800028ea:	ecbff0ef          	jal	800027b4 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    800028ee:	8626                	mv	a2,s1
    800028f0:	85ca                	mv	a1,s2
    800028f2:	f6dff0ef          	jal	8000285e <fetchstr>
}
    800028f6:	60e2                	ld	ra,24(sp)
    800028f8:	6442                	ld	s0,16(sp)
    800028fa:	64a2                	ld	s1,8(sp)
    800028fc:	6902                	ld	s2,0(sp)
    800028fe:	6105                	addi	sp,sp,32
    80002900:	8082                	ret

0000000080002902 <syscall>:
[SYS_audit_read] sys_audit_read,
};

void
syscall(void)
{
    80002902:	1101                	addi	sp,sp,-32
    80002904:	ec06                	sd	ra,24(sp)
    80002906:	e822                	sd	s0,16(sp)
    80002908:	e426                	sd	s1,8(sp)
    8000290a:	e04a                	sd	s2,0(sp)
    8000290c:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    8000290e:	828ff0ef          	jal	80001936 <myproc>
    80002912:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002914:	05853903          	ld	s2,88(a0)
    80002918:	0a893783          	ld	a5,168(s2)
    8000291c:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002920:	37fd                	addiw	a5,a5,-1
    80002922:	4771                	li	a4,28
    80002924:	00f76f63          	bltu	a4,a5,80002942 <syscall+0x40>
    80002928:	00369713          	slli	a4,a3,0x3
    8000292c:	00006797          	auipc	a5,0x6
    80002930:	22c78793          	addi	a5,a5,556 # 80008b58 <syscalls>
    80002934:	97ba                	add	a5,a5,a4
    80002936:	639c                	ld	a5,0(a5)
    80002938:	c789                	beqz	a5,80002942 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    8000293a:	9782                	jalr	a5
    8000293c:	06a93823          	sd	a0,112(s2)
    80002940:	a829                	j	8000295a <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002942:	15848613          	addi	a2,s1,344
    80002946:	588c                	lw	a1,48(s1)
    80002948:	00006517          	auipc	a0,0x6
    8000294c:	a6050513          	addi	a0,a0,-1440 # 800083a8 <etext+0x3a8>
    80002950:	babfd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002954:	6cbc                	ld	a5,88(s1)
    80002956:	577d                	li	a4,-1
    80002958:	fbb8                	sd	a4,112(a5)
  }
}
    8000295a:	60e2                	ld	ra,24(sp)
    8000295c:	6442                	ld	s0,16(sp)
    8000295e:	64a2                	ld	s1,8(sp)
    80002960:	6902                	ld	s2,0(sp)
    80002962:	6105                	addi	sp,sp,32
    80002964:	8082                	ret

0000000080002966 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002966:	1101                	addi	sp,sp,-32
    80002968:	ec06                	sd	ra,24(sp)
    8000296a:	e822                	sd	s0,16(sp)
    8000296c:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    8000296e:	fec40593          	addi	a1,s0,-20
    80002972:	4501                	li	a0,0
    80002974:	f2bff0ef          	jal	8000289e <argint>
  kexit(n);
    80002978:	fec42503          	lw	a0,-20(s0)
    8000297c:	f22ff0ef          	jal	8000209e <kexit>
  return 0;  // not reached
}
    80002980:	4501                	li	a0,0
    80002982:	60e2                	ld	ra,24(sp)
    80002984:	6442                	ld	s0,16(sp)
    80002986:	6105                	addi	sp,sp,32
    80002988:	8082                	ret

000000008000298a <sys_getpid>:

uint64
sys_getpid(void)
{
    8000298a:	1141                	addi	sp,sp,-16
    8000298c:	e406                	sd	ra,8(sp)
    8000298e:	e022                	sd	s0,0(sp)
    80002990:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002992:	fa5fe0ef          	jal	80001936 <myproc>
}
    80002996:	5908                	lw	a0,48(a0)
    80002998:	60a2                	ld	ra,8(sp)
    8000299a:	6402                	ld	s0,0(sp)
    8000299c:	0141                	addi	sp,sp,16
    8000299e:	8082                	ret

00000000800029a0 <sys_fork>:

uint64
sys_fork(void)
{
    800029a0:	1141                	addi	sp,sp,-16
    800029a2:	e406                	sd	ra,8(sp)
    800029a4:	e022                	sd	s0,0(sp)
    800029a6:	0800                	addi	s0,sp,16
  return kfork();
    800029a8:	af6ff0ef          	jal	80001c9e <kfork>
}
    800029ac:	60a2                	ld	ra,8(sp)
    800029ae:	6402                	ld	s0,0(sp)
    800029b0:	0141                	addi	sp,sp,16
    800029b2:	8082                	ret

00000000800029b4 <sys_wait>:

uint64
sys_wait(void)
{
    800029b4:	1101                	addi	sp,sp,-32
    800029b6:	ec06                	sd	ra,24(sp)
    800029b8:	e822                	sd	s0,16(sp)
    800029ba:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800029bc:	fe840593          	addi	a1,s0,-24
    800029c0:	4501                	li	a0,0
    800029c2:	efbff0ef          	jal	800028bc <argaddr>
  return kwait(p);
    800029c6:	fe843503          	ld	a0,-24(s0)
    800029ca:	82fff0ef          	jal	800021f8 <kwait>
}
    800029ce:	60e2                	ld	ra,24(sp)
    800029d0:	6442                	ld	s0,16(sp)
    800029d2:	6105                	addi	sp,sp,32
    800029d4:	8082                	ret

00000000800029d6 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800029d6:	7179                	addi	sp,sp,-48
    800029d8:	f406                	sd	ra,40(sp)
    800029da:	f022                	sd	s0,32(sp)
    800029dc:	ec26                	sd	s1,24(sp)
    800029de:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    800029e0:	fd840593          	addi	a1,s0,-40
    800029e4:	4501                	li	a0,0
    800029e6:	eb9ff0ef          	jal	8000289e <argint>
  argint(1, &t);
    800029ea:	fdc40593          	addi	a1,s0,-36
    800029ee:	4505                	li	a0,1
    800029f0:	eafff0ef          	jal	8000289e <argint>
  addr = myproc()->sz;
    800029f4:	f43fe0ef          	jal	80001936 <myproc>
    800029f8:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    800029fa:	fdc42703          	lw	a4,-36(s0)
    800029fe:	4785                	li	a5,1
    80002a00:	02f70763          	beq	a4,a5,80002a2e <sys_sbrk+0x58>
    80002a04:	fd842783          	lw	a5,-40(s0)
    80002a08:	0207c363          	bltz	a5,80002a2e <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002a0c:	97a6                	add	a5,a5,s1
      return -1;
    if(addr + n > TRAPFRAME)
    80002a0e:	02000737          	lui	a4,0x2000
    80002a12:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002a14:	0736                	slli	a4,a4,0xd
    80002a16:	02f76a63          	bltu	a4,a5,80002a4a <sys_sbrk+0x74>
    80002a1a:	0297e863          	bltu	a5,s1,80002a4a <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002a1e:	f19fe0ef          	jal	80001936 <myproc>
    80002a22:	fd842703          	lw	a4,-40(s0)
    80002a26:	653c                	ld	a5,72(a0)
    80002a28:	97ba                	add	a5,a5,a4
    80002a2a:	e53c                	sd	a5,72(a0)
    80002a2c:	a039                	j	80002a3a <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002a2e:	fd842503          	lw	a0,-40(s0)
    80002a32:	a0aff0ef          	jal	80001c3c <growproc>
    80002a36:	00054863          	bltz	a0,80002a46 <sys_sbrk+0x70>
  }
  return addr;
}
    80002a3a:	8526                	mv	a0,s1
    80002a3c:	70a2                	ld	ra,40(sp)
    80002a3e:	7402                	ld	s0,32(sp)
    80002a40:	64e2                	ld	s1,24(sp)
    80002a42:	6145                	addi	sp,sp,48
    80002a44:	8082                	ret
      return -1;
    80002a46:	54fd                	li	s1,-1
    80002a48:	bfcd                	j	80002a3a <sys_sbrk+0x64>
      return -1;
    80002a4a:	54fd                	li	s1,-1
    80002a4c:	b7fd                	j	80002a3a <sys_sbrk+0x64>

0000000080002a4e <sys_pause>:

uint64
sys_pause(void)
{
    80002a4e:	7139                	addi	sp,sp,-64
    80002a50:	fc06                	sd	ra,56(sp)
    80002a52:	f822                	sd	s0,48(sp)
    80002a54:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002a56:	fcc40593          	addi	a1,s0,-52
    80002a5a:	4501                	li	a0,0
    80002a5c:	e43ff0ef          	jal	8000289e <argint>
  if(n < 0)
    80002a60:	fcc42783          	lw	a5,-52(s0)
    80002a64:	0607c863          	bltz	a5,80002ad4 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002a68:	00015517          	auipc	a0,0x15
    80002a6c:	04050513          	addi	a0,a0,64 # 80017aa8 <tickslock>
    80002a70:	9b8fe0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    80002a74:	fcc42783          	lw	a5,-52(s0)
    80002a78:	c3b9                	beqz	a5,80002abe <sys_pause+0x70>
    80002a7a:	f426                	sd	s1,40(sp)
    80002a7c:	f04a                	sd	s2,32(sp)
    80002a7e:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002a80:	00006997          	auipc	s3,0x6
    80002a84:	2f89a983          	lw	s3,760(s3) # 80008d78 <ticks>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002a88:	00015917          	auipc	s2,0x15
    80002a8c:	02090913          	addi	s2,s2,32 # 80017aa8 <tickslock>
    80002a90:	00006497          	auipc	s1,0x6
    80002a94:	2e848493          	addi	s1,s1,744 # 80008d78 <ticks>
    if(killed(myproc())){
    80002a98:	e9ffe0ef          	jal	80001936 <myproc>
    80002a9c:	f32ff0ef          	jal	800021ce <killed>
    80002aa0:	ed0d                	bnez	a0,80002ada <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002aa2:	85ca                	mv	a1,s2
    80002aa4:	8526                	mv	a0,s1
    80002aa6:	cecff0ef          	jal	80001f92 <sleep>
  while(ticks - ticks0 < n){
    80002aaa:	409c                	lw	a5,0(s1)
    80002aac:	413787bb          	subw	a5,a5,s3
    80002ab0:	fcc42703          	lw	a4,-52(s0)
    80002ab4:	fee7e2e3          	bltu	a5,a4,80002a98 <sys_pause+0x4a>
    80002ab8:	74a2                	ld	s1,40(sp)
    80002aba:	7902                	ld	s2,32(sp)
    80002abc:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002abe:	00015517          	auipc	a0,0x15
    80002ac2:	fea50513          	addi	a0,a0,-22 # 80017aa8 <tickslock>
    80002ac6:	9f6fe0ef          	jal	80000cbc <release>
  return 0;
    80002aca:	4501                	li	a0,0
}
    80002acc:	70e2                	ld	ra,56(sp)
    80002ace:	7442                	ld	s0,48(sp)
    80002ad0:	6121                	addi	sp,sp,64
    80002ad2:	8082                	ret
    n = 0;
    80002ad4:	fc042623          	sw	zero,-52(s0)
    80002ad8:	bf41                	j	80002a68 <sys_pause+0x1a>
      release(&tickslock);
    80002ada:	00015517          	auipc	a0,0x15
    80002ade:	fce50513          	addi	a0,a0,-50 # 80017aa8 <tickslock>
    80002ae2:	9dafe0ef          	jal	80000cbc <release>
      return -1;
    80002ae6:	557d                	li	a0,-1
    80002ae8:	74a2                	ld	s1,40(sp)
    80002aea:	7902                	ld	s2,32(sp)
    80002aec:	69e2                	ld	s3,24(sp)
    80002aee:	bff9                	j	80002acc <sys_pause+0x7e>

0000000080002af0 <sys_kill>:

uint64
sys_kill(void)
{
    80002af0:	1101                	addi	sp,sp,-32
    80002af2:	ec06                	sd	ra,24(sp)
    80002af4:	e822                	sd	s0,16(sp)
    80002af6:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002af8:	fec40593          	addi	a1,s0,-20
    80002afc:	4501                	li	a0,0
    80002afe:	da1ff0ef          	jal	8000289e <argint>
  return kkill(pid);
    80002b02:	fec42503          	lw	a0,-20(s0)
    80002b06:	e3eff0ef          	jal	80002144 <kkill>
}
    80002b0a:	60e2                	ld	ra,24(sp)
    80002b0c:	6442                	ld	s0,16(sp)
    80002b0e:	6105                	addi	sp,sp,32
    80002b10:	8082                	ret

0000000080002b12 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002b12:	1101                	addi	sp,sp,-32
    80002b14:	ec06                	sd	ra,24(sp)
    80002b16:	e822                	sd	s0,16(sp)
    80002b18:	e426                	sd	s1,8(sp)
    80002b1a:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002b1c:	00015517          	auipc	a0,0x15
    80002b20:	f8c50513          	addi	a0,a0,-116 # 80017aa8 <tickslock>
    80002b24:	904fe0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002b28:	00006797          	auipc	a5,0x6
    80002b2c:	2507a783          	lw	a5,592(a5) # 80008d78 <ticks>
    80002b30:	84be                	mv	s1,a5
  release(&tickslock);
    80002b32:	00015517          	auipc	a0,0x15
    80002b36:	f7650513          	addi	a0,a0,-138 # 80017aa8 <tickslock>
    80002b3a:	982fe0ef          	jal	80000cbc <release>
  return xticks;
}
    80002b3e:	02049513          	slli	a0,s1,0x20
    80002b42:	9101                	srli	a0,a0,0x20
    80002b44:	60e2                	ld	ra,24(sp)
    80002b46:	6442                	ld	s0,16(sp)
    80002b48:	64a2                	ld	s1,8(sp)
    80002b4a:	6105                	addi	sp,sp,32
    80002b4c:	8082                	ret

0000000080002b4e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002b4e:	7179                	addi	sp,sp,-48
    80002b50:	f406                	sd	ra,40(sp)
    80002b52:	f022                	sd	s0,32(sp)
    80002b54:	ec26                	sd	s1,24(sp)
    80002b56:	e84a                	sd	s2,16(sp)
    80002b58:	e44e                	sd	s3,8(sp)
    80002b5a:	e052                	sd	s4,0(sp)
    80002b5c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002b5e:	00006597          	auipc	a1,0x6
    80002b62:	86a58593          	addi	a1,a1,-1942 # 800083c8 <etext+0x3c8>
    80002b66:	00015517          	auipc	a0,0x15
    80002b6a:	f5a50513          	addi	a0,a0,-166 # 80017ac0 <bcache>
    80002b6e:	830fe0ef          	jal	80000b9e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002b72:	0001d797          	auipc	a5,0x1d
    80002b76:	f4e78793          	addi	a5,a5,-178 # 8001fac0 <bcache+0x8000>
    80002b7a:	0001d717          	auipc	a4,0x1d
    80002b7e:	1ae70713          	addi	a4,a4,430 # 8001fd28 <bcache+0x8268>
    80002b82:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002b86:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002b8a:	00015497          	auipc	s1,0x15
    80002b8e:	f4e48493          	addi	s1,s1,-178 # 80017ad8 <bcache+0x18>
    b->next = bcache.head.next;
    80002b92:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002b94:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002b96:	00006a17          	auipc	s4,0x6
    80002b9a:	83aa0a13          	addi	s4,s4,-1990 # 800083d0 <etext+0x3d0>
    b->next = bcache.head.next;
    80002b9e:	2b893783          	ld	a5,696(s2)
    80002ba2:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002ba4:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002ba8:	85d2                	mv	a1,s4
    80002baa:	01048513          	addi	a0,s1,16
    80002bae:	394010ef          	jal	80003f42 <initsleeplock>
    bcache.head.next->prev = b;
    80002bb2:	2b893783          	ld	a5,696(s2)
    80002bb6:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002bb8:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002bbc:	45848493          	addi	s1,s1,1112
    80002bc0:	fd349fe3          	bne	s1,s3,80002b9e <binit+0x50>
  }
}
    80002bc4:	70a2                	ld	ra,40(sp)
    80002bc6:	7402                	ld	s0,32(sp)
    80002bc8:	64e2                	ld	s1,24(sp)
    80002bca:	6942                	ld	s2,16(sp)
    80002bcc:	69a2                	ld	s3,8(sp)
    80002bce:	6a02                	ld	s4,0(sp)
    80002bd0:	6145                	addi	sp,sp,48
    80002bd2:	8082                	ret

0000000080002bd4 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002bd4:	7179                	addi	sp,sp,-48
    80002bd6:	f406                	sd	ra,40(sp)
    80002bd8:	f022                	sd	s0,32(sp)
    80002bda:	ec26                	sd	s1,24(sp)
    80002bdc:	e84a                	sd	s2,16(sp)
    80002bde:	e44e                	sd	s3,8(sp)
    80002be0:	1800                	addi	s0,sp,48
    80002be2:	892a                	mv	s2,a0
    80002be4:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002be6:	00015517          	auipc	a0,0x15
    80002bea:	eda50513          	addi	a0,a0,-294 # 80017ac0 <bcache>
    80002bee:	83afe0ef          	jal	80000c28 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002bf2:	0001d497          	auipc	s1,0x1d
    80002bf6:	1864b483          	ld	s1,390(s1) # 8001fd78 <bcache+0x82b8>
    80002bfa:	0001d797          	auipc	a5,0x1d
    80002bfe:	12e78793          	addi	a5,a5,302 # 8001fd28 <bcache+0x8268>
    80002c02:	02f48b63          	beq	s1,a5,80002c38 <bread+0x64>
    80002c06:	873e                	mv	a4,a5
    80002c08:	a021                	j	80002c10 <bread+0x3c>
    80002c0a:	68a4                	ld	s1,80(s1)
    80002c0c:	02e48663          	beq	s1,a4,80002c38 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002c10:	449c                	lw	a5,8(s1)
    80002c12:	ff279ce3          	bne	a5,s2,80002c0a <bread+0x36>
    80002c16:	44dc                	lw	a5,12(s1)
    80002c18:	ff3799e3          	bne	a5,s3,80002c0a <bread+0x36>
      b->refcnt++;
    80002c1c:	40bc                	lw	a5,64(s1)
    80002c1e:	2785                	addiw	a5,a5,1
    80002c20:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c22:	00015517          	auipc	a0,0x15
    80002c26:	e9e50513          	addi	a0,a0,-354 # 80017ac0 <bcache>
    80002c2a:	892fe0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    80002c2e:	01048513          	addi	a0,s1,16
    80002c32:	346010ef          	jal	80003f78 <acquiresleep>
      return b;
    80002c36:	a889                	j	80002c88 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002c38:	0001d497          	auipc	s1,0x1d
    80002c3c:	1384b483          	ld	s1,312(s1) # 8001fd70 <bcache+0x82b0>
    80002c40:	0001d797          	auipc	a5,0x1d
    80002c44:	0e878793          	addi	a5,a5,232 # 8001fd28 <bcache+0x8268>
    80002c48:	00f48863          	beq	s1,a5,80002c58 <bread+0x84>
    80002c4c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002c4e:	40bc                	lw	a5,64(s1)
    80002c50:	cb91                	beqz	a5,80002c64 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002c52:	64a4                	ld	s1,72(s1)
    80002c54:	fee49de3          	bne	s1,a4,80002c4e <bread+0x7a>
  panic("bget: no buffers");
    80002c58:	00005517          	auipc	a0,0x5
    80002c5c:	78050513          	addi	a0,a0,1920 # 800083d8 <etext+0x3d8>
    80002c60:	bc5fd0ef          	jal	80000824 <panic>
      b->dev = dev;
    80002c64:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002c68:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002c6c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002c70:	4785                	li	a5,1
    80002c72:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c74:	00015517          	auipc	a0,0x15
    80002c78:	e4c50513          	addi	a0,a0,-436 # 80017ac0 <bcache>
    80002c7c:	840fe0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    80002c80:	01048513          	addi	a0,s1,16
    80002c84:	2f4010ef          	jal	80003f78 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002c88:	409c                	lw	a5,0(s1)
    80002c8a:	cb89                	beqz	a5,80002c9c <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002c8c:	8526                	mv	a0,s1
    80002c8e:	70a2                	ld	ra,40(sp)
    80002c90:	7402                	ld	s0,32(sp)
    80002c92:	64e2                	ld	s1,24(sp)
    80002c94:	6942                	ld	s2,16(sp)
    80002c96:	69a2                	ld	s3,8(sp)
    80002c98:	6145                	addi	sp,sp,48
    80002c9a:	8082                	ret
    virtio_disk_rw(b, 0);
    80002c9c:	4581                	li	a1,0
    80002c9e:	8526                	mv	a0,s1
    80002ca0:	651020ef          	jal	80005af0 <virtio_disk_rw>
    b->valid = 1;
    80002ca4:	4785                	li	a5,1
    80002ca6:	c09c                	sw	a5,0(s1)
  return b;
    80002ca8:	b7d5                	j	80002c8c <bread+0xb8>

0000000080002caa <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002caa:	1101                	addi	sp,sp,-32
    80002cac:	ec06                	sd	ra,24(sp)
    80002cae:	e822                	sd	s0,16(sp)
    80002cb0:	e426                	sd	s1,8(sp)
    80002cb2:	1000                	addi	s0,sp,32
    80002cb4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002cb6:	0541                	addi	a0,a0,16
    80002cb8:	33e010ef          	jal	80003ff6 <holdingsleep>
    80002cbc:	c911                	beqz	a0,80002cd0 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002cbe:	4585                	li	a1,1
    80002cc0:	8526                	mv	a0,s1
    80002cc2:	62f020ef          	jal	80005af0 <virtio_disk_rw>
}
    80002cc6:	60e2                	ld	ra,24(sp)
    80002cc8:	6442                	ld	s0,16(sp)
    80002cca:	64a2                	ld	s1,8(sp)
    80002ccc:	6105                	addi	sp,sp,32
    80002cce:	8082                	ret
    panic("bwrite");
    80002cd0:	00005517          	auipc	a0,0x5
    80002cd4:	72050513          	addi	a0,a0,1824 # 800083f0 <etext+0x3f0>
    80002cd8:	b4dfd0ef          	jal	80000824 <panic>

0000000080002cdc <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002cdc:	1101                	addi	sp,sp,-32
    80002cde:	ec06                	sd	ra,24(sp)
    80002ce0:	e822                	sd	s0,16(sp)
    80002ce2:	e426                	sd	s1,8(sp)
    80002ce4:	e04a                	sd	s2,0(sp)
    80002ce6:	1000                	addi	s0,sp,32
    80002ce8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002cea:	01050913          	addi	s2,a0,16
    80002cee:	854a                	mv	a0,s2
    80002cf0:	306010ef          	jal	80003ff6 <holdingsleep>
    80002cf4:	c125                	beqz	a0,80002d54 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002cf6:	854a                	mv	a0,s2
    80002cf8:	2c6010ef          	jal	80003fbe <releasesleep>

  acquire(&bcache.lock);
    80002cfc:	00015517          	auipc	a0,0x15
    80002d00:	dc450513          	addi	a0,a0,-572 # 80017ac0 <bcache>
    80002d04:	f25fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002d08:	40bc                	lw	a5,64(s1)
    80002d0a:	37fd                	addiw	a5,a5,-1
    80002d0c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002d0e:	e79d                	bnez	a5,80002d3c <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002d10:	68b8                	ld	a4,80(s1)
    80002d12:	64bc                	ld	a5,72(s1)
    80002d14:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002d16:	68b8                	ld	a4,80(s1)
    80002d18:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002d1a:	0001d797          	auipc	a5,0x1d
    80002d1e:	da678793          	addi	a5,a5,-602 # 8001fac0 <bcache+0x8000>
    80002d22:	2b87b703          	ld	a4,696(a5)
    80002d26:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002d28:	0001d717          	auipc	a4,0x1d
    80002d2c:	00070713          	mv	a4,a4
    80002d30:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002d32:	2b87b703          	ld	a4,696(a5)
    80002d36:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002d38:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002d3c:	00015517          	auipc	a0,0x15
    80002d40:	d8450513          	addi	a0,a0,-636 # 80017ac0 <bcache>
    80002d44:	f79fd0ef          	jal	80000cbc <release>
}
    80002d48:	60e2                	ld	ra,24(sp)
    80002d4a:	6442                	ld	s0,16(sp)
    80002d4c:	64a2                	ld	s1,8(sp)
    80002d4e:	6902                	ld	s2,0(sp)
    80002d50:	6105                	addi	sp,sp,32
    80002d52:	8082                	ret
    panic("brelse");
    80002d54:	00005517          	auipc	a0,0x5
    80002d58:	6a450513          	addi	a0,a0,1700 # 800083f8 <etext+0x3f8>
    80002d5c:	ac9fd0ef          	jal	80000824 <panic>

0000000080002d60 <bpin>:

void
bpin(struct buf *b) {
    80002d60:	1101                	addi	sp,sp,-32
    80002d62:	ec06                	sd	ra,24(sp)
    80002d64:	e822                	sd	s0,16(sp)
    80002d66:	e426                	sd	s1,8(sp)
    80002d68:	1000                	addi	s0,sp,32
    80002d6a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d6c:	00015517          	auipc	a0,0x15
    80002d70:	d5450513          	addi	a0,a0,-684 # 80017ac0 <bcache>
    80002d74:	eb5fd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    80002d78:	40bc                	lw	a5,64(s1)
    80002d7a:	2785                	addiw	a5,a5,1
    80002d7c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d7e:	00015517          	auipc	a0,0x15
    80002d82:	d4250513          	addi	a0,a0,-702 # 80017ac0 <bcache>
    80002d86:	f37fd0ef          	jal	80000cbc <release>
}
    80002d8a:	60e2                	ld	ra,24(sp)
    80002d8c:	6442                	ld	s0,16(sp)
    80002d8e:	64a2                	ld	s1,8(sp)
    80002d90:	6105                	addi	sp,sp,32
    80002d92:	8082                	ret

0000000080002d94 <bunpin>:

void
bunpin(struct buf *b) {
    80002d94:	1101                	addi	sp,sp,-32
    80002d96:	ec06                	sd	ra,24(sp)
    80002d98:	e822                	sd	s0,16(sp)
    80002d9a:	e426                	sd	s1,8(sp)
    80002d9c:	1000                	addi	s0,sp,32
    80002d9e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002da0:	00015517          	auipc	a0,0x15
    80002da4:	d2050513          	addi	a0,a0,-736 # 80017ac0 <bcache>
    80002da8:	e81fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002dac:	40bc                	lw	a5,64(s1)
    80002dae:	37fd                	addiw	a5,a5,-1
    80002db0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002db2:	00015517          	auipc	a0,0x15
    80002db6:	d0e50513          	addi	a0,a0,-754 # 80017ac0 <bcache>
    80002dba:	f03fd0ef          	jal	80000cbc <release>
}
    80002dbe:	60e2                	ld	ra,24(sp)
    80002dc0:	6442                	ld	s0,16(sp)
    80002dc2:	64a2                	ld	s1,8(sp)
    80002dc4:	6105                	addi	sp,sp,32
    80002dc6:	8082                	ret

0000000080002dc8 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002dc8:	1101                	addi	sp,sp,-32
    80002dca:	ec06                	sd	ra,24(sp)
    80002dcc:	e822                	sd	s0,16(sp)
    80002dce:	e426                	sd	s1,8(sp)
    80002dd0:	e04a                	sd	s2,0(sp)
    80002dd2:	1000                	addi	s0,sp,32
    80002dd4:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002dd6:	00d5d79b          	srliw	a5,a1,0xd
    80002dda:	0001d597          	auipc	a1,0x1d
    80002dde:	3c25a583          	lw	a1,962(a1) # 8002019c <sb+0x1c>
    80002de2:	9dbd                	addw	a1,a1,a5
    80002de4:	df1ff0ef          	jal	80002bd4 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002de8:	0074f713          	andi	a4,s1,7
    80002dec:	4785                	li	a5,1
    80002dee:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002df2:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    80002df4:	90d9                	srli	s1,s1,0x36
    80002df6:	00950733          	add	a4,a0,s1
    80002dfa:	05874703          	lbu	a4,88(a4) # 8001fd80 <bcache+0x82c0>
    80002dfe:	00e7f6b3          	and	a3,a5,a4
    80002e02:	c29d                	beqz	a3,80002e28 <bfree+0x60>
    80002e04:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002e06:	94aa                	add	s1,s1,a0
    80002e08:	fff7c793          	not	a5,a5
    80002e0c:	8f7d                	and	a4,a4,a5
    80002e0e:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002e12:	06c010ef          	jal	80003e7e <log_write>
  brelse(bp);
    80002e16:	854a                	mv	a0,s2
    80002e18:	ec5ff0ef          	jal	80002cdc <brelse>
}
    80002e1c:	60e2                	ld	ra,24(sp)
    80002e1e:	6442                	ld	s0,16(sp)
    80002e20:	64a2                	ld	s1,8(sp)
    80002e22:	6902                	ld	s2,0(sp)
    80002e24:	6105                	addi	sp,sp,32
    80002e26:	8082                	ret
    panic("freeing free block");
    80002e28:	00005517          	auipc	a0,0x5
    80002e2c:	5d850513          	addi	a0,a0,1496 # 80008400 <etext+0x400>
    80002e30:	9f5fd0ef          	jal	80000824 <panic>

0000000080002e34 <balloc>:
{
    80002e34:	715d                	addi	sp,sp,-80
    80002e36:	e486                	sd	ra,72(sp)
    80002e38:	e0a2                	sd	s0,64(sp)
    80002e3a:	fc26                	sd	s1,56(sp)
    80002e3c:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80002e3e:	0001d797          	auipc	a5,0x1d
    80002e42:	3467a783          	lw	a5,838(a5) # 80020184 <sb+0x4>
    80002e46:	0e078263          	beqz	a5,80002f2a <balloc+0xf6>
    80002e4a:	f84a                	sd	s2,48(sp)
    80002e4c:	f44e                	sd	s3,40(sp)
    80002e4e:	f052                	sd	s4,32(sp)
    80002e50:	ec56                	sd	s5,24(sp)
    80002e52:	e85a                	sd	s6,16(sp)
    80002e54:	e45e                	sd	s7,8(sp)
    80002e56:	e062                	sd	s8,0(sp)
    80002e58:	8baa                	mv	s7,a0
    80002e5a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002e5c:	0001db17          	auipc	s6,0x1d
    80002e60:	324b0b13          	addi	s6,s6,804 # 80020180 <sb>
      m = 1 << (bi % 8);
    80002e64:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e66:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002e68:	6c09                	lui	s8,0x2
    80002e6a:	a09d                	j	80002ed0 <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002e6c:	97ca                	add	a5,a5,s2
    80002e6e:	8e55                	or	a2,a2,a3
    80002e70:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002e74:	854a                	mv	a0,s2
    80002e76:	008010ef          	jal	80003e7e <log_write>
        brelse(bp);
    80002e7a:	854a                	mv	a0,s2
    80002e7c:	e61ff0ef          	jal	80002cdc <brelse>
  bp = bread(dev, bno);
    80002e80:	85a6                	mv	a1,s1
    80002e82:	855e                	mv	a0,s7
    80002e84:	d51ff0ef          	jal	80002bd4 <bread>
    80002e88:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002e8a:	40000613          	li	a2,1024
    80002e8e:	4581                	li	a1,0
    80002e90:	05850513          	addi	a0,a0,88
    80002e94:	e65fd0ef          	jal	80000cf8 <memset>
  log_write(bp);
    80002e98:	854a                	mv	a0,s2
    80002e9a:	7e5000ef          	jal	80003e7e <log_write>
  brelse(bp);
    80002e9e:	854a                	mv	a0,s2
    80002ea0:	e3dff0ef          	jal	80002cdc <brelse>
}
    80002ea4:	7942                	ld	s2,48(sp)
    80002ea6:	79a2                	ld	s3,40(sp)
    80002ea8:	7a02                	ld	s4,32(sp)
    80002eaa:	6ae2                	ld	s5,24(sp)
    80002eac:	6b42                	ld	s6,16(sp)
    80002eae:	6ba2                	ld	s7,8(sp)
    80002eb0:	6c02                	ld	s8,0(sp)
}
    80002eb2:	8526                	mv	a0,s1
    80002eb4:	60a6                	ld	ra,72(sp)
    80002eb6:	6406                	ld	s0,64(sp)
    80002eb8:	74e2                	ld	s1,56(sp)
    80002eba:	6161                	addi	sp,sp,80
    80002ebc:	8082                	ret
    brelse(bp);
    80002ebe:	854a                	mv	a0,s2
    80002ec0:	e1dff0ef          	jal	80002cdc <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002ec4:	015c0abb          	addw	s5,s8,s5
    80002ec8:	004b2783          	lw	a5,4(s6)
    80002ecc:	04faf863          	bgeu	s5,a5,80002f1c <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80002ed0:	40dad59b          	sraiw	a1,s5,0xd
    80002ed4:	01cb2783          	lw	a5,28(s6)
    80002ed8:	9dbd                	addw	a1,a1,a5
    80002eda:	855e                	mv	a0,s7
    80002edc:	cf9ff0ef          	jal	80002bd4 <bread>
    80002ee0:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002ee2:	004b2503          	lw	a0,4(s6)
    80002ee6:	84d6                	mv	s1,s5
    80002ee8:	4701                	li	a4,0
    80002eea:	fca4fae3          	bgeu	s1,a0,80002ebe <balloc+0x8a>
      m = 1 << (bi % 8);
    80002eee:	00777693          	andi	a3,a4,7
    80002ef2:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002ef6:	41f7579b          	sraiw	a5,a4,0x1f
    80002efa:	01d7d79b          	srliw	a5,a5,0x1d
    80002efe:	9fb9                	addw	a5,a5,a4
    80002f00:	4037d79b          	sraiw	a5,a5,0x3
    80002f04:	00f90633          	add	a2,s2,a5
    80002f08:	05864603          	lbu	a2,88(a2)
    80002f0c:	00c6f5b3          	and	a1,a3,a2
    80002f10:	ddb1                	beqz	a1,80002e6c <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f12:	2705                	addiw	a4,a4,1
    80002f14:	2485                	addiw	s1,s1,1
    80002f16:	fd471ae3          	bne	a4,s4,80002eea <balloc+0xb6>
    80002f1a:	b755                	j	80002ebe <balloc+0x8a>
    80002f1c:	7942                	ld	s2,48(sp)
    80002f1e:	79a2                	ld	s3,40(sp)
    80002f20:	7a02                	ld	s4,32(sp)
    80002f22:	6ae2                	ld	s5,24(sp)
    80002f24:	6b42                	ld	s6,16(sp)
    80002f26:	6ba2                	ld	s7,8(sp)
    80002f28:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    80002f2a:	00005517          	auipc	a0,0x5
    80002f2e:	4ee50513          	addi	a0,a0,1262 # 80008418 <etext+0x418>
    80002f32:	dc8fd0ef          	jal	800004fa <printf>
  return 0;
    80002f36:	4481                	li	s1,0
    80002f38:	bfad                	j	80002eb2 <balloc+0x7e>

0000000080002f3a <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002f3a:	7179                	addi	sp,sp,-48
    80002f3c:	f406                	sd	ra,40(sp)
    80002f3e:	f022                	sd	s0,32(sp)
    80002f40:	ec26                	sd	s1,24(sp)
    80002f42:	e84a                	sd	s2,16(sp)
    80002f44:	e44e                	sd	s3,8(sp)
    80002f46:	1800                	addi	s0,sp,48
    80002f48:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002f4a:	47ad                	li	a5,11
    80002f4c:	02b7e363          	bltu	a5,a1,80002f72 <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    80002f50:	02059793          	slli	a5,a1,0x20
    80002f54:	01e7d593          	srli	a1,a5,0x1e
    80002f58:	00b509b3          	add	s3,a0,a1
    80002f5c:	0509a483          	lw	s1,80(s3)
    80002f60:	e0b5                	bnez	s1,80002fc4 <bmap+0x8a>
      addr = balloc(ip->dev);
    80002f62:	4108                	lw	a0,0(a0)
    80002f64:	ed1ff0ef          	jal	80002e34 <balloc>
    80002f68:	84aa                	mv	s1,a0
      if(addr == 0)
    80002f6a:	cd29                	beqz	a0,80002fc4 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    80002f6c:	04a9a823          	sw	a0,80(s3)
    80002f70:	a891                	j	80002fc4 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002f72:	ff45879b          	addiw	a5,a1,-12
    80002f76:	873e                	mv	a4,a5
    80002f78:	89be                	mv	s3,a5

  if(bn < NINDIRECT){
    80002f7a:	0ff00793          	li	a5,255
    80002f7e:	06e7e763          	bltu	a5,a4,80002fec <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002f82:	08052483          	lw	s1,128(a0)
    80002f86:	e891                	bnez	s1,80002f9a <bmap+0x60>
      addr = balloc(ip->dev);
    80002f88:	4108                	lw	a0,0(a0)
    80002f8a:	eabff0ef          	jal	80002e34 <balloc>
    80002f8e:	84aa                	mv	s1,a0
      if(addr == 0)
    80002f90:	c915                	beqz	a0,80002fc4 <bmap+0x8a>
    80002f92:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002f94:	08a92023          	sw	a0,128(s2)
    80002f98:	a011                	j	80002f9c <bmap+0x62>
    80002f9a:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002f9c:	85a6                	mv	a1,s1
    80002f9e:	00092503          	lw	a0,0(s2)
    80002fa2:	c33ff0ef          	jal	80002bd4 <bread>
    80002fa6:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002fa8:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002fac:	02099713          	slli	a4,s3,0x20
    80002fb0:	01e75593          	srli	a1,a4,0x1e
    80002fb4:	97ae                	add	a5,a5,a1
    80002fb6:	89be                	mv	s3,a5
    80002fb8:	4384                	lw	s1,0(a5)
    80002fba:	cc89                	beqz	s1,80002fd4 <bmap+0x9a>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002fbc:	8552                	mv	a0,s4
    80002fbe:	d1fff0ef          	jal	80002cdc <brelse>
    return addr;
    80002fc2:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002fc4:	8526                	mv	a0,s1
    80002fc6:	70a2                	ld	ra,40(sp)
    80002fc8:	7402                	ld	s0,32(sp)
    80002fca:	64e2                	ld	s1,24(sp)
    80002fcc:	6942                	ld	s2,16(sp)
    80002fce:	69a2                	ld	s3,8(sp)
    80002fd0:	6145                	addi	sp,sp,48
    80002fd2:	8082                	ret
      addr = balloc(ip->dev);
    80002fd4:	00092503          	lw	a0,0(s2)
    80002fd8:	e5dff0ef          	jal	80002e34 <balloc>
    80002fdc:	84aa                	mv	s1,a0
      if(addr){
    80002fde:	dd79                	beqz	a0,80002fbc <bmap+0x82>
        a[bn] = addr;
    80002fe0:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    80002fe4:	8552                	mv	a0,s4
    80002fe6:	699000ef          	jal	80003e7e <log_write>
    80002fea:	bfc9                	j	80002fbc <bmap+0x82>
    80002fec:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80002fee:	00005517          	auipc	a0,0x5
    80002ff2:	44250513          	addi	a0,a0,1090 # 80008430 <etext+0x430>
    80002ff6:	82ffd0ef          	jal	80000824 <panic>

0000000080002ffa <iget>:
{
    80002ffa:	7179                	addi	sp,sp,-48
    80002ffc:	f406                	sd	ra,40(sp)
    80002ffe:	f022                	sd	s0,32(sp)
    80003000:	ec26                	sd	s1,24(sp)
    80003002:	e84a                	sd	s2,16(sp)
    80003004:	e44e                	sd	s3,8(sp)
    80003006:	e052                	sd	s4,0(sp)
    80003008:	1800                	addi	s0,sp,48
    8000300a:	892a                	mv	s2,a0
    8000300c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000300e:	0001d517          	auipc	a0,0x1d
    80003012:	19250513          	addi	a0,a0,402 # 800201a0 <itable>
    80003016:	c13fd0ef          	jal	80000c28 <acquire>
  empty = 0;
    8000301a:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000301c:	0001d497          	auipc	s1,0x1d
    80003020:	19c48493          	addi	s1,s1,412 # 800201b8 <itable+0x18>
    80003024:	0001f697          	auipc	a3,0x1f
    80003028:	db468693          	addi	a3,a3,-588 # 80021dd8 <log>
    8000302c:	a809                	j	8000303e <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000302e:	e781                	bnez	a5,80003036 <iget+0x3c>
    80003030:	00099363          	bnez	s3,80003036 <iget+0x3c>
      empty = ip;
    80003034:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003036:	09048493          	addi	s1,s1,144
    8000303a:	02d48563          	beq	s1,a3,80003064 <iget+0x6a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000303e:	449c                	lw	a5,8(s1)
    80003040:	fef057e3          	blez	a5,8000302e <iget+0x34>
    80003044:	4098                	lw	a4,0(s1)
    80003046:	ff2718e3          	bne	a4,s2,80003036 <iget+0x3c>
    8000304a:	40d8                	lw	a4,4(s1)
    8000304c:	ff4715e3          	bne	a4,s4,80003036 <iget+0x3c>
      ip->ref++;
    80003050:	2785                	addiw	a5,a5,1
    80003052:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003054:	0001d517          	auipc	a0,0x1d
    80003058:	14c50513          	addi	a0,a0,332 # 800201a0 <itable>
    8000305c:	c61fd0ef          	jal	80000cbc <release>
      return ip;
    80003060:	89a6                	mv	s3,s1
    80003062:	a015                	j	80003086 <iget+0x8c>
  if(empty == 0)
    80003064:	02098a63          	beqz	s3,80003098 <iget+0x9e>
  ip->dev = dev;
    80003068:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    8000306c:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    80003070:	4785                	li	a5,1
    80003072:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80003076:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    8000307a:	0001d517          	auipc	a0,0x1d
    8000307e:	12650513          	addi	a0,a0,294 # 800201a0 <itable>
    80003082:	c3bfd0ef          	jal	80000cbc <release>
}
    80003086:	854e                	mv	a0,s3
    80003088:	70a2                	ld	ra,40(sp)
    8000308a:	7402                	ld	s0,32(sp)
    8000308c:	64e2                	ld	s1,24(sp)
    8000308e:	6942                	ld	s2,16(sp)
    80003090:	69a2                	ld	s3,8(sp)
    80003092:	6a02                	ld	s4,0(sp)
    80003094:	6145                	addi	sp,sp,48
    80003096:	8082                	ret
    panic("iget: no inodes");
    80003098:	00005517          	auipc	a0,0x5
    8000309c:	3b050513          	addi	a0,a0,944 # 80008448 <etext+0x448>
    800030a0:	f84fd0ef          	jal	80000824 <panic>

00000000800030a4 <iinit>:
{
    800030a4:	7179                	addi	sp,sp,-48
    800030a6:	f406                	sd	ra,40(sp)
    800030a8:	f022                	sd	s0,32(sp)
    800030aa:	ec26                	sd	s1,24(sp)
    800030ac:	e84a                	sd	s2,16(sp)
    800030ae:	e44e                	sd	s3,8(sp)
    800030b0:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800030b2:	00005597          	auipc	a1,0x5
    800030b6:	3a658593          	addi	a1,a1,934 # 80008458 <etext+0x458>
    800030ba:	0001d517          	auipc	a0,0x1d
    800030be:	0e650513          	addi	a0,a0,230 # 800201a0 <itable>
    800030c2:	addfd0ef          	jal	80000b9e <initlock>
  for(i = 0; i < NINODE; i++) {
    800030c6:	0001d497          	auipc	s1,0x1d
    800030ca:	10248493          	addi	s1,s1,258 # 800201c8 <itable+0x28>
    800030ce:	0001f997          	auipc	s3,0x1f
    800030d2:	d1a98993          	addi	s3,s3,-742 # 80021de8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800030d6:	00005917          	auipc	s2,0x5
    800030da:	38a90913          	addi	s2,s2,906 # 80008460 <etext+0x460>
    800030de:	85ca                	mv	a1,s2
    800030e0:	8526                	mv	a0,s1
    800030e2:	661000ef          	jal	80003f42 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800030e6:	09048493          	addi	s1,s1,144
    800030ea:	ff349ae3          	bne	s1,s3,800030de <iinit+0x3a>
}
    800030ee:	70a2                	ld	ra,40(sp)
    800030f0:	7402                	ld	s0,32(sp)
    800030f2:	64e2                	ld	s1,24(sp)
    800030f4:	6942                	ld	s2,16(sp)
    800030f6:	69a2                	ld	s3,8(sp)
    800030f8:	6145                	addi	sp,sp,48
    800030fa:	8082                	ret

00000000800030fc <ialloc>:
{
    800030fc:	7139                	addi	sp,sp,-64
    800030fe:	fc06                	sd	ra,56(sp)
    80003100:	f822                	sd	s0,48(sp)
    80003102:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003104:	0001d717          	auipc	a4,0x1d
    80003108:	08872703          	lw	a4,136(a4) # 8002018c <sb+0xc>
    8000310c:	4785                	li	a5,1
    8000310e:	06e7f063          	bgeu	a5,a4,8000316e <ialloc+0x72>
    80003112:	f426                	sd	s1,40(sp)
    80003114:	f04a                	sd	s2,32(sp)
    80003116:	ec4e                	sd	s3,24(sp)
    80003118:	e852                	sd	s4,16(sp)
    8000311a:	e456                	sd	s5,8(sp)
    8000311c:	e05a                	sd	s6,0(sp)
    8000311e:	8aaa                	mv	s5,a0
    80003120:	8b2e                	mv	s6,a1
    80003122:	84be                	mv	s1,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003124:	0001da17          	auipc	s4,0x1d
    80003128:	05ca0a13          	addi	s4,s4,92 # 80020180 <sb>
    8000312c:	0034d593          	srli	a1,s1,0x3
    80003130:	018a2783          	lw	a5,24(s4)
    80003134:	9dbd                	addw	a1,a1,a5
    80003136:	8556                	mv	a0,s5
    80003138:	a9dff0ef          	jal	80002bd4 <bread>
    8000313c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000313e:	05850993          	addi	s3,a0,88
    80003142:	0074f793          	andi	a5,s1,7
    80003146:	079e                	slli	a5,a5,0x7
    80003148:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000314a:	00099783          	lh	a5,0(s3)
    8000314e:	cb9d                	beqz	a5,80003184 <ialloc+0x88>
    brelse(bp);
    80003150:	b8dff0ef          	jal	80002cdc <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003154:	0485                	addi	s1,s1,1
    80003156:	00ca2703          	lw	a4,12(s4)
    8000315a:	0004879b          	sext.w	a5,s1
    8000315e:	fce7e7e3          	bltu	a5,a4,8000312c <ialloc+0x30>
    80003162:	74a2                	ld	s1,40(sp)
    80003164:	7902                	ld	s2,32(sp)
    80003166:	69e2                	ld	s3,24(sp)
    80003168:	6a42                	ld	s4,16(sp)
    8000316a:	6aa2                	ld	s5,8(sp)
    8000316c:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    8000316e:	00005517          	auipc	a0,0x5
    80003172:	2fa50513          	addi	a0,a0,762 # 80008468 <etext+0x468>
    80003176:	b84fd0ef          	jal	800004fa <printf>
  return 0;
    8000317a:	4501                	li	a0,0
}
    8000317c:	70e2                	ld	ra,56(sp)
    8000317e:	7442                	ld	s0,48(sp)
    80003180:	6121                	addi	sp,sp,64
    80003182:	8082                	ret
    80003184:	2481                	sext.w	s1,s1
      memset(dip, 0, sizeof(*dip));
    80003186:	08000613          	li	a2,128
    8000318a:	4581                	li	a1,0
    8000318c:	854e                	mv	a0,s3
    8000318e:	b6bfd0ef          	jal	80000cf8 <memset>
      dip->type = type;
    80003192:	01699023          	sh	s6,0(s3)
      struct proc *p = myproc();
    80003196:	fa0fe0ef          	jal	80001936 <myproc>
      dip->uid = p->creds.uid;
    8000319a:	16852783          	lw	a5,360(a0)
    8000319e:	04f9a223          	sw	a5,68(s3)
      dip->gid = p->creds.gid;
    800031a2:	16c52783          	lw	a5,364(a0)
    800031a6:	04f9a423          	sw	a5,72(s3)
      dip->mode = (type == T_DIR) ? 0755 : 0644;
    800031aa:	4705                	li	a4,1
    800031ac:	1a400793          	li	a5,420
    800031b0:	02eb0563          	beq	s6,a4,800031da <ialloc+0xde>
    800031b4:	04f9a023          	sw	a5,64(s3)
      log_write(bp);   // mark it allocated on the disk
    800031b8:	854a                	mv	a0,s2
    800031ba:	4c5000ef          	jal	80003e7e <log_write>
      brelse(bp);
    800031be:	854a                	mv	a0,s2
    800031c0:	b1dff0ef          	jal	80002cdc <brelse>
      return iget(dev, inum);
    800031c4:	85a6                	mv	a1,s1
    800031c6:	8556                	mv	a0,s5
    800031c8:	e33ff0ef          	jal	80002ffa <iget>
    800031cc:	74a2                	ld	s1,40(sp)
    800031ce:	7902                	ld	s2,32(sp)
    800031d0:	69e2                	ld	s3,24(sp)
    800031d2:	6a42                	ld	s4,16(sp)
    800031d4:	6aa2                	ld	s5,8(sp)
    800031d6:	6b02                	ld	s6,0(sp)
    800031d8:	b755                	j	8000317c <ialloc+0x80>
      dip->mode = (type == T_DIR) ? 0755 : 0644;
    800031da:	1ed00793          	li	a5,493
    800031de:	bfd9                	j	800031b4 <ialloc+0xb8>

00000000800031e0 <iupdate>:
{
    800031e0:	7179                	addi	sp,sp,-48
    800031e2:	f406                	sd	ra,40(sp)
    800031e4:	f022                	sd	s0,32(sp)
    800031e6:	ec26                	sd	s1,24(sp)
    800031e8:	e84a                	sd	s2,16(sp)
    800031ea:	e44e                	sd	s3,8(sp)
    800031ec:	1800                	addi	s0,sp,48
    800031ee:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800031f0:	415c                	lw	a5,4(a0)
    800031f2:	0037d79b          	srliw	a5,a5,0x3
    800031f6:	0001d597          	auipc	a1,0x1d
    800031fa:	fa25a583          	lw	a1,-94(a1) # 80020198 <sb+0x18>
    800031fe:	9dbd                	addw	a1,a1,a5
    80003200:	4108                	lw	a0,0(a0)
    80003202:	9d3ff0ef          	jal	80002bd4 <bread>
    80003206:	89aa                	mv	s3,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003208:	05850913          	addi	s2,a0,88
    8000320c:	40dc                	lw	a5,4(s1)
    8000320e:	8b9d                	andi	a5,a5,7
    80003210:	079e                	slli	a5,a5,0x7
    80003212:	993e                	add	s2,s2,a5
  dip->type = ip->type;
    80003214:	04449783          	lh	a5,68(s1)
    80003218:	00f91023          	sh	a5,0(s2)
  dip->major = ip->major;
    8000321c:	04649783          	lh	a5,70(s1)
    80003220:	00f91123          	sh	a5,2(s2)
  dip->minor = ip->minor;
    80003224:	04849783          	lh	a5,72(s1)
    80003228:	00f91223          	sh	a5,4(s2)
  dip->nlink = ip->nlink;
    8000322c:	04a49783          	lh	a5,74(s1)
    80003230:	00f91323          	sh	a5,6(s2)
  dip->size = ip->size;
    80003234:	44fc                	lw	a5,76(s1)
    80003236:	00f92423          	sw	a5,8(s2)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000323a:	03400613          	li	a2,52
    8000323e:	05048593          	addi	a1,s1,80
    80003242:	00c90513          	addi	a0,s2,12
    80003246:	b13fd0ef          	jal	80000d58 <memmove>
  dip->mode = ip->mode;
    8000324a:	0844a783          	lw	a5,132(s1)
    8000324e:	04f92023          	sw	a5,64(s2)
  dip->uid  = ip->uid;
    80003252:	0884a783          	lw	a5,136(s1)
    80003256:	04f92223          	sw	a5,68(s2)
  dip->gid  = ip->gid;
    8000325a:	08c4a783          	lw	a5,140(s1)
    8000325e:	04f92423          	sw	a5,72(s2)
  log_write(bp);
    80003262:	854e                	mv	a0,s3
    80003264:	41b000ef          	jal	80003e7e <log_write>
  brelse(bp);
    80003268:	854e                	mv	a0,s3
    8000326a:	a73ff0ef          	jal	80002cdc <brelse>
}
    8000326e:	70a2                	ld	ra,40(sp)
    80003270:	7402                	ld	s0,32(sp)
    80003272:	64e2                	ld	s1,24(sp)
    80003274:	6942                	ld	s2,16(sp)
    80003276:	69a2                	ld	s3,8(sp)
    80003278:	6145                	addi	sp,sp,48
    8000327a:	8082                	ret

000000008000327c <idup>:
{
    8000327c:	1101                	addi	sp,sp,-32
    8000327e:	ec06                	sd	ra,24(sp)
    80003280:	e822                	sd	s0,16(sp)
    80003282:	e426                	sd	s1,8(sp)
    80003284:	1000                	addi	s0,sp,32
    80003286:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003288:	0001d517          	auipc	a0,0x1d
    8000328c:	f1850513          	addi	a0,a0,-232 # 800201a0 <itable>
    80003290:	999fd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    80003294:	449c                	lw	a5,8(s1)
    80003296:	2785                	addiw	a5,a5,1
    80003298:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000329a:	0001d517          	auipc	a0,0x1d
    8000329e:	f0650513          	addi	a0,a0,-250 # 800201a0 <itable>
    800032a2:	a1bfd0ef          	jal	80000cbc <release>
}
    800032a6:	8526                	mv	a0,s1
    800032a8:	60e2                	ld	ra,24(sp)
    800032aa:	6442                	ld	s0,16(sp)
    800032ac:	64a2                	ld	s1,8(sp)
    800032ae:	6105                	addi	sp,sp,32
    800032b0:	8082                	ret

00000000800032b2 <ilock>:
{
    800032b2:	7179                	addi	sp,sp,-48
    800032b4:	f406                	sd	ra,40(sp)
    800032b6:	f022                	sd	s0,32(sp)
    800032b8:	ec26                	sd	s1,24(sp)
    800032ba:	1800                	addi	s0,sp,48
  if(ip == 0 || ip->ref < 1)
    800032bc:	cd19                	beqz	a0,800032da <ilock+0x28>
    800032be:	84aa                	mv	s1,a0
    800032c0:	451c                	lw	a5,8(a0)
    800032c2:	00f05c63          	blez	a5,800032da <ilock+0x28>
  acquiresleep(&ip->lock);
    800032c6:	0541                	addi	a0,a0,16
    800032c8:	4b1000ef          	jal	80003f78 <acquiresleep>
  if(ip->valid == 0){
    800032cc:	40bc                	lw	a5,64(s1)
    800032ce:	cf91                	beqz	a5,800032ea <ilock+0x38>
}
    800032d0:	70a2                	ld	ra,40(sp)
    800032d2:	7402                	ld	s0,32(sp)
    800032d4:	64e2                	ld	s1,24(sp)
    800032d6:	6145                	addi	sp,sp,48
    800032d8:	8082                	ret
    800032da:	e84a                	sd	s2,16(sp)
    800032dc:	e44e                	sd	s3,8(sp)
    panic("ilock");
    800032de:	00005517          	auipc	a0,0x5
    800032e2:	1a250513          	addi	a0,a0,418 # 80008480 <etext+0x480>
    800032e6:	d3efd0ef          	jal	80000824 <panic>
    800032ea:	e84a                	sd	s2,16(sp)
    800032ec:	e44e                	sd	s3,8(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800032ee:	40dc                	lw	a5,4(s1)
    800032f0:	0037d79b          	srliw	a5,a5,0x3
    800032f4:	0001d597          	auipc	a1,0x1d
    800032f8:	ea45a583          	lw	a1,-348(a1) # 80020198 <sb+0x18>
    800032fc:	9dbd                	addw	a1,a1,a5
    800032fe:	4088                	lw	a0,0(s1)
    80003300:	8d5ff0ef          	jal	80002bd4 <bread>
    80003304:	89aa                	mv	s3,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003306:	05850913          	addi	s2,a0,88
    8000330a:	40dc                	lw	a5,4(s1)
    8000330c:	8b9d                	andi	a5,a5,7
    8000330e:	079e                	slli	a5,a5,0x7
    80003310:	993e                	add	s2,s2,a5
    ip->type = dip->type;
    80003312:	00091783          	lh	a5,0(s2)
    80003316:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000331a:	00291783          	lh	a5,2(s2)
    8000331e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003322:	00491783          	lh	a5,4(s2)
    80003326:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000332a:	00691783          	lh	a5,6(s2)
    8000332e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003332:	00892783          	lw	a5,8(s2)
    80003336:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003338:	03400613          	li	a2,52
    8000333c:	00c90593          	addi	a1,s2,12
    80003340:	05048513          	addi	a0,s1,80
    80003344:	a15fd0ef          	jal	80000d58 <memmove>
    ip->mode  = dip->mode;
    80003348:	04092783          	lw	a5,64(s2)
    8000334c:	08f4a223          	sw	a5,132(s1)
    ip->uid   = dip->uid;
    80003350:	04492783          	lw	a5,68(s2)
    80003354:	08f4a423          	sw	a5,136(s1)
    ip->gid   = dip->gid;
    80003358:	04892783          	lw	a5,72(s2)
    8000335c:	08f4a623          	sw	a5,140(s1)
    brelse(bp);
    80003360:	854e                	mv	a0,s3
    80003362:	97bff0ef          	jal	80002cdc <brelse>
    ip->valid = 1;
    80003366:	4785                	li	a5,1
    80003368:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000336a:	04449783          	lh	a5,68(s1)
    8000336e:	c781                	beqz	a5,80003376 <ilock+0xc4>
    80003370:	6942                	ld	s2,16(sp)
    80003372:	69a2                	ld	s3,8(sp)
    80003374:	bfb1                	j	800032d0 <ilock+0x1e>
      panic("ilock: no type");
    80003376:	00005517          	auipc	a0,0x5
    8000337a:	11250513          	addi	a0,a0,274 # 80008488 <etext+0x488>
    8000337e:	ca6fd0ef          	jal	80000824 <panic>

0000000080003382 <iunlock>:
{
    80003382:	1101                	addi	sp,sp,-32
    80003384:	ec06                	sd	ra,24(sp)
    80003386:	e822                	sd	s0,16(sp)
    80003388:	e426                	sd	s1,8(sp)
    8000338a:	e04a                	sd	s2,0(sp)
    8000338c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000338e:	c505                	beqz	a0,800033b6 <iunlock+0x34>
    80003390:	84aa                	mv	s1,a0
    80003392:	01050913          	addi	s2,a0,16
    80003396:	854a                	mv	a0,s2
    80003398:	45f000ef          	jal	80003ff6 <holdingsleep>
    8000339c:	cd09                	beqz	a0,800033b6 <iunlock+0x34>
    8000339e:	449c                	lw	a5,8(s1)
    800033a0:	00f05b63          	blez	a5,800033b6 <iunlock+0x34>
  releasesleep(&ip->lock);
    800033a4:	854a                	mv	a0,s2
    800033a6:	419000ef          	jal	80003fbe <releasesleep>
}
    800033aa:	60e2                	ld	ra,24(sp)
    800033ac:	6442                	ld	s0,16(sp)
    800033ae:	64a2                	ld	s1,8(sp)
    800033b0:	6902                	ld	s2,0(sp)
    800033b2:	6105                	addi	sp,sp,32
    800033b4:	8082                	ret
    panic("iunlock");
    800033b6:	00005517          	auipc	a0,0x5
    800033ba:	0e250513          	addi	a0,a0,226 # 80008498 <etext+0x498>
    800033be:	c66fd0ef          	jal	80000824 <panic>

00000000800033c2 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800033c2:	7179                	addi	sp,sp,-48
    800033c4:	f406                	sd	ra,40(sp)
    800033c6:	f022                	sd	s0,32(sp)
    800033c8:	ec26                	sd	s1,24(sp)
    800033ca:	e84a                	sd	s2,16(sp)
    800033cc:	e44e                	sd	s3,8(sp)
    800033ce:	1800                	addi	s0,sp,48
    800033d0:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800033d2:	05050493          	addi	s1,a0,80
    800033d6:	08050913          	addi	s2,a0,128
    800033da:	a021                	j	800033e2 <itrunc+0x20>
    800033dc:	0491                	addi	s1,s1,4
    800033de:	01248b63          	beq	s1,s2,800033f4 <itrunc+0x32>
    if(ip->addrs[i]){
    800033e2:	408c                	lw	a1,0(s1)
    800033e4:	dde5                	beqz	a1,800033dc <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800033e6:	0009a503          	lw	a0,0(s3)
    800033ea:	9dfff0ef          	jal	80002dc8 <bfree>
      ip->addrs[i] = 0;
    800033ee:	0004a023          	sw	zero,0(s1)
    800033f2:	b7ed                	j	800033dc <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800033f4:	0809a583          	lw	a1,128(s3)
    800033f8:	ed89                	bnez	a1,80003412 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800033fa:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800033fe:	854e                	mv	a0,s3
    80003400:	de1ff0ef          	jal	800031e0 <iupdate>
}
    80003404:	70a2                	ld	ra,40(sp)
    80003406:	7402                	ld	s0,32(sp)
    80003408:	64e2                	ld	s1,24(sp)
    8000340a:	6942                	ld	s2,16(sp)
    8000340c:	69a2                	ld	s3,8(sp)
    8000340e:	6145                	addi	sp,sp,48
    80003410:	8082                	ret
    80003412:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003414:	0009a503          	lw	a0,0(s3)
    80003418:	fbcff0ef          	jal	80002bd4 <bread>
    8000341c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000341e:	05850493          	addi	s1,a0,88
    80003422:	45850913          	addi	s2,a0,1112
    80003426:	a021                	j	8000342e <itrunc+0x6c>
    80003428:	0491                	addi	s1,s1,4
    8000342a:	01248963          	beq	s1,s2,8000343c <itrunc+0x7a>
      if(a[j])
    8000342e:	408c                	lw	a1,0(s1)
    80003430:	dde5                	beqz	a1,80003428 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003432:	0009a503          	lw	a0,0(s3)
    80003436:	993ff0ef          	jal	80002dc8 <bfree>
    8000343a:	b7fd                	j	80003428 <itrunc+0x66>
    brelse(bp);
    8000343c:	8552                	mv	a0,s4
    8000343e:	89fff0ef          	jal	80002cdc <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003442:	0809a583          	lw	a1,128(s3)
    80003446:	0009a503          	lw	a0,0(s3)
    8000344a:	97fff0ef          	jal	80002dc8 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000344e:	0809a023          	sw	zero,128(s3)
    80003452:	6a02                	ld	s4,0(sp)
    80003454:	b75d                	j	800033fa <itrunc+0x38>

0000000080003456 <iput>:
{
    80003456:	1101                	addi	sp,sp,-32
    80003458:	ec06                	sd	ra,24(sp)
    8000345a:	e822                	sd	s0,16(sp)
    8000345c:	e426                	sd	s1,8(sp)
    8000345e:	1000                	addi	s0,sp,32
    80003460:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003462:	0001d517          	auipc	a0,0x1d
    80003466:	d3e50513          	addi	a0,a0,-706 # 800201a0 <itable>
    8000346a:	fbefd0ef          	jal	80000c28 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000346e:	4498                	lw	a4,8(s1)
    80003470:	4785                	li	a5,1
    80003472:	02f70063          	beq	a4,a5,80003492 <iput+0x3c>
  ip->ref--;
    80003476:	449c                	lw	a5,8(s1)
    80003478:	37fd                	addiw	a5,a5,-1
    8000347a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000347c:	0001d517          	auipc	a0,0x1d
    80003480:	d2450513          	addi	a0,a0,-732 # 800201a0 <itable>
    80003484:	839fd0ef          	jal	80000cbc <release>
}
    80003488:	60e2                	ld	ra,24(sp)
    8000348a:	6442                	ld	s0,16(sp)
    8000348c:	64a2                	ld	s1,8(sp)
    8000348e:	6105                	addi	sp,sp,32
    80003490:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003492:	40bc                	lw	a5,64(s1)
    80003494:	d3ed                	beqz	a5,80003476 <iput+0x20>
    80003496:	04a49783          	lh	a5,74(s1)
    8000349a:	fff1                	bnez	a5,80003476 <iput+0x20>
    8000349c:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    8000349e:	01048793          	addi	a5,s1,16
    800034a2:	893e                	mv	s2,a5
    800034a4:	853e                	mv	a0,a5
    800034a6:	2d3000ef          	jal	80003f78 <acquiresleep>
    release(&itable.lock);
    800034aa:	0001d517          	auipc	a0,0x1d
    800034ae:	cf650513          	addi	a0,a0,-778 # 800201a0 <itable>
    800034b2:	80bfd0ef          	jal	80000cbc <release>
    itrunc(ip);
    800034b6:	8526                	mv	a0,s1
    800034b8:	f0bff0ef          	jal	800033c2 <itrunc>
    ip->type = 0;
    800034bc:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800034c0:	8526                	mv	a0,s1
    800034c2:	d1fff0ef          	jal	800031e0 <iupdate>
    ip->valid = 0;
    800034c6:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800034ca:	854a                	mv	a0,s2
    800034cc:	2f3000ef          	jal	80003fbe <releasesleep>
    acquire(&itable.lock);
    800034d0:	0001d517          	auipc	a0,0x1d
    800034d4:	cd050513          	addi	a0,a0,-816 # 800201a0 <itable>
    800034d8:	f50fd0ef          	jal	80000c28 <acquire>
    800034dc:	6902                	ld	s2,0(sp)
    800034de:	bf61                	j	80003476 <iput+0x20>

00000000800034e0 <iunlockput>:
{
    800034e0:	1101                	addi	sp,sp,-32
    800034e2:	ec06                	sd	ra,24(sp)
    800034e4:	e822                	sd	s0,16(sp)
    800034e6:	e426                	sd	s1,8(sp)
    800034e8:	1000                	addi	s0,sp,32
    800034ea:	84aa                	mv	s1,a0
  iunlock(ip);
    800034ec:	e97ff0ef          	jal	80003382 <iunlock>
  iput(ip);
    800034f0:	8526                	mv	a0,s1
    800034f2:	f65ff0ef          	jal	80003456 <iput>
}
    800034f6:	60e2                	ld	ra,24(sp)
    800034f8:	6442                	ld	s0,16(sp)
    800034fa:	64a2                	ld	s1,8(sp)
    800034fc:	6105                	addi	sp,sp,32
    800034fe:	8082                	ret

0000000080003500 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003500:	0001d717          	auipc	a4,0x1d
    80003504:	c8c72703          	lw	a4,-884(a4) # 8002018c <sb+0xc>
    80003508:	4785                	li	a5,1
    8000350a:	0ae7fe63          	bgeu	a5,a4,800035c6 <ireclaim+0xc6>
{
    8000350e:	7139                	addi	sp,sp,-64
    80003510:	fc06                	sd	ra,56(sp)
    80003512:	f822                	sd	s0,48(sp)
    80003514:	f426                	sd	s1,40(sp)
    80003516:	f04a                	sd	s2,32(sp)
    80003518:	ec4e                	sd	s3,24(sp)
    8000351a:	e852                	sd	s4,16(sp)
    8000351c:	e456                	sd	s5,8(sp)
    8000351e:	e05a                	sd	s6,0(sp)
    80003520:	0080                	addi	s0,sp,64
    80003522:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003524:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003526:	0001da17          	auipc	s4,0x1d
    8000352a:	c5aa0a13          	addi	s4,s4,-934 # 80020180 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    8000352e:	00005b17          	auipc	s6,0x5
    80003532:	f72b0b13          	addi	s6,s6,-142 # 800084a0 <etext+0x4a0>
    80003536:	a099                	j	8000357c <ireclaim+0x7c>
    80003538:	85ce                	mv	a1,s3
    8000353a:	855a                	mv	a0,s6
    8000353c:	fbffc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    80003540:	85ce                	mv	a1,s3
    80003542:	8556                	mv	a0,s5
    80003544:	ab7ff0ef          	jal	80002ffa <iget>
    80003548:	89aa                	mv	s3,a0
    brelse(bp);
    8000354a:	854a                	mv	a0,s2
    8000354c:	f90ff0ef          	jal	80002cdc <brelse>
    if (ip) {
    80003550:	00098f63          	beqz	s3,8000356e <ireclaim+0x6e>
      begin_op();
    80003554:	790000ef          	jal	80003ce4 <begin_op>
      ilock(ip);
    80003558:	854e                	mv	a0,s3
    8000355a:	d59ff0ef          	jal	800032b2 <ilock>
      iunlock(ip);
    8000355e:	854e                	mv	a0,s3
    80003560:	e23ff0ef          	jal	80003382 <iunlock>
      iput(ip);
    80003564:	854e                	mv	a0,s3
    80003566:	ef1ff0ef          	jal	80003456 <iput>
      end_op();
    8000356a:	7ea000ef          	jal	80003d54 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000356e:	0485                	addi	s1,s1,1
    80003570:	00ca2703          	lw	a4,12(s4)
    80003574:	0004879b          	sext.w	a5,s1
    80003578:	02e7fd63          	bgeu	a5,a4,800035b2 <ireclaim+0xb2>
    8000357c:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003580:	0034d593          	srli	a1,s1,0x3
    80003584:	018a2783          	lw	a5,24(s4)
    80003588:	9dbd                	addw	a1,a1,a5
    8000358a:	8556                	mv	a0,s5
    8000358c:	e48ff0ef          	jal	80002bd4 <bread>
    80003590:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003592:	05850793          	addi	a5,a0,88
    80003596:	0079f713          	andi	a4,s3,7
    8000359a:	071e                	slli	a4,a4,0x7
    8000359c:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    8000359e:	00079703          	lh	a4,0(a5)
    800035a2:	c701                	beqz	a4,800035aa <ireclaim+0xaa>
    800035a4:	00679783          	lh	a5,6(a5)
    800035a8:	dbc1                	beqz	a5,80003538 <ireclaim+0x38>
    brelse(bp);
    800035aa:	854a                	mv	a0,s2
    800035ac:	f30ff0ef          	jal	80002cdc <brelse>
    if (ip) {
    800035b0:	bf7d                	j	8000356e <ireclaim+0x6e>
}
    800035b2:	70e2                	ld	ra,56(sp)
    800035b4:	7442                	ld	s0,48(sp)
    800035b6:	74a2                	ld	s1,40(sp)
    800035b8:	7902                	ld	s2,32(sp)
    800035ba:	69e2                	ld	s3,24(sp)
    800035bc:	6a42                	ld	s4,16(sp)
    800035be:	6aa2                	ld	s5,8(sp)
    800035c0:	6b02                	ld	s6,0(sp)
    800035c2:	6121                	addi	sp,sp,64
    800035c4:	8082                	ret
    800035c6:	8082                	ret

00000000800035c8 <fsinit>:
fsinit(int dev) {
    800035c8:	1101                	addi	sp,sp,-32
    800035ca:	ec06                	sd	ra,24(sp)
    800035cc:	e822                	sd	s0,16(sp)
    800035ce:	e426                	sd	s1,8(sp)
    800035d0:	e04a                	sd	s2,0(sp)
    800035d2:	1000                	addi	s0,sp,32
    800035d4:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800035d6:	4585                	li	a1,1
    800035d8:	dfcff0ef          	jal	80002bd4 <bread>
    800035dc:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800035de:	02000613          	li	a2,32
    800035e2:	05850593          	addi	a1,a0,88
    800035e6:	0001d517          	auipc	a0,0x1d
    800035ea:	b9a50513          	addi	a0,a0,-1126 # 80020180 <sb>
    800035ee:	f6afd0ef          	jal	80000d58 <memmove>
  brelse(bp);
    800035f2:	8526                	mv	a0,s1
    800035f4:	ee8ff0ef          	jal	80002cdc <brelse>
  if(sb.magic != FSMAGIC)
    800035f8:	0001d717          	auipc	a4,0x1d
    800035fc:	b8872703          	lw	a4,-1144(a4) # 80020180 <sb>
    80003600:	102037b7          	lui	a5,0x10203
    80003604:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003608:	02f71463          	bne	a4,a5,80003630 <fsinit+0x68>
  initlog(dev, &sb);
    8000360c:	0001d597          	auipc	a1,0x1d
    80003610:	b7458593          	addi	a1,a1,-1164 # 80020180 <sb>
    80003614:	854a                	mv	a0,s2
    80003616:	64c000ef          	jal	80003c62 <initlog>
  ireclaim(dev);
    8000361a:	854a                	mv	a0,s2
    8000361c:	ee5ff0ef          	jal	80003500 <ireclaim>
  fsinit_security();
    80003620:	128020ef          	jal	80005748 <fsinit_security>
}
    80003624:	60e2                	ld	ra,24(sp)
    80003626:	6442                	ld	s0,16(sp)
    80003628:	64a2                	ld	s1,8(sp)
    8000362a:	6902                	ld	s2,0(sp)
    8000362c:	6105                	addi	sp,sp,32
    8000362e:	8082                	ret
    panic("invalid file system");
    80003630:	00005517          	auipc	a0,0x5
    80003634:	e9050513          	addi	a0,a0,-368 # 800084c0 <etext+0x4c0>
    80003638:	9ecfd0ef          	jal	80000824 <panic>

000000008000363c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000363c:	1141                	addi	sp,sp,-16
    8000363e:	e406                	sd	ra,8(sp)
    80003640:	e022                	sd	s0,0(sp)
    80003642:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003644:	411c                	lw	a5,0(a0)
    80003646:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003648:	415c                	lw	a5,4(a0)
    8000364a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000364c:	04451783          	lh	a5,68(a0)
    80003650:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003654:	04a51783          	lh	a5,74(a0)
    80003658:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000365c:	04c56783          	lwu	a5,76(a0)
    80003660:	e99c                	sd	a5,16(a1)
}
    80003662:	60a2                	ld	ra,8(sp)
    80003664:	6402                	ld	s0,0(sp)
    80003666:	0141                	addi	sp,sp,16
    80003668:	8082                	ret

000000008000366a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000366a:	457c                	lw	a5,76(a0)
    8000366c:	0ed7e663          	bltu	a5,a3,80003758 <readi+0xee>
{
    80003670:	7159                	addi	sp,sp,-112
    80003672:	f486                	sd	ra,104(sp)
    80003674:	f0a2                	sd	s0,96(sp)
    80003676:	eca6                	sd	s1,88(sp)
    80003678:	e0d2                	sd	s4,64(sp)
    8000367a:	fc56                	sd	s5,56(sp)
    8000367c:	f85a                	sd	s6,48(sp)
    8000367e:	f45e                	sd	s7,40(sp)
    80003680:	1880                	addi	s0,sp,112
    80003682:	8b2a                	mv	s6,a0
    80003684:	8bae                	mv	s7,a1
    80003686:	8a32                	mv	s4,a2
    80003688:	84b6                	mv	s1,a3
    8000368a:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000368c:	9f35                	addw	a4,a4,a3
    return 0;
    8000368e:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003690:	0ad76b63          	bltu	a4,a3,80003746 <readi+0xdc>
    80003694:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003696:	00e7f463          	bgeu	a5,a4,8000369e <readi+0x34>
    n = ip->size - off;
    8000369a:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000369e:	080a8b63          	beqz	s5,80003734 <readi+0xca>
    800036a2:	e8ca                	sd	s2,80(sp)
    800036a4:	f062                	sd	s8,32(sp)
    800036a6:	ec66                	sd	s9,24(sp)
    800036a8:	e86a                	sd	s10,16(sp)
    800036aa:	e46e                	sd	s11,8(sp)
    800036ac:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800036ae:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800036b2:	5c7d                	li	s8,-1
    800036b4:	a80d                	j	800036e6 <readi+0x7c>
    800036b6:	020d1d93          	slli	s11,s10,0x20
    800036ba:	020ddd93          	srli	s11,s11,0x20
    800036be:	05890613          	addi	a2,s2,88
    800036c2:	86ee                	mv	a3,s11
    800036c4:	963e                	add	a2,a2,a5
    800036c6:	85d2                	mv	a1,s4
    800036c8:	855e                	mv	a0,s7
    800036ca:	c23fe0ef          	jal	800022ec <either_copyout>
    800036ce:	05850363          	beq	a0,s8,80003714 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800036d2:	854a                	mv	a0,s2
    800036d4:	e08ff0ef          	jal	80002cdc <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800036d8:	013d09bb          	addw	s3,s10,s3
    800036dc:	009d04bb          	addw	s1,s10,s1
    800036e0:	9a6e                	add	s4,s4,s11
    800036e2:	0559f363          	bgeu	s3,s5,80003728 <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800036e6:	00a4d59b          	srliw	a1,s1,0xa
    800036ea:	855a                	mv	a0,s6
    800036ec:	84fff0ef          	jal	80002f3a <bmap>
    800036f0:	85aa                	mv	a1,a0
    if(addr == 0)
    800036f2:	c139                	beqz	a0,80003738 <readi+0xce>
    bp = bread(ip->dev, addr);
    800036f4:	000b2503          	lw	a0,0(s6)
    800036f8:	cdcff0ef          	jal	80002bd4 <bread>
    800036fc:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800036fe:	3ff4f793          	andi	a5,s1,1023
    80003702:	40fc873b          	subw	a4,s9,a5
    80003706:	413a86bb          	subw	a3,s5,s3
    8000370a:	8d3a                	mv	s10,a4
    8000370c:	fae6f5e3          	bgeu	a3,a4,800036b6 <readi+0x4c>
    80003710:	8d36                	mv	s10,a3
    80003712:	b755                	j	800036b6 <readi+0x4c>
      brelse(bp);
    80003714:	854a                	mv	a0,s2
    80003716:	dc6ff0ef          	jal	80002cdc <brelse>
      tot = -1;
    8000371a:	59fd                	li	s3,-1
      break;
    8000371c:	6946                	ld	s2,80(sp)
    8000371e:	7c02                	ld	s8,32(sp)
    80003720:	6ce2                	ld	s9,24(sp)
    80003722:	6d42                	ld	s10,16(sp)
    80003724:	6da2                	ld	s11,8(sp)
    80003726:	a831                	j	80003742 <readi+0xd8>
    80003728:	6946                	ld	s2,80(sp)
    8000372a:	7c02                	ld	s8,32(sp)
    8000372c:	6ce2                	ld	s9,24(sp)
    8000372e:	6d42                	ld	s10,16(sp)
    80003730:	6da2                	ld	s11,8(sp)
    80003732:	a801                	j	80003742 <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003734:	89d6                	mv	s3,s5
    80003736:	a031                	j	80003742 <readi+0xd8>
    80003738:	6946                	ld	s2,80(sp)
    8000373a:	7c02                	ld	s8,32(sp)
    8000373c:	6ce2                	ld	s9,24(sp)
    8000373e:	6d42                	ld	s10,16(sp)
    80003740:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003742:	854e                	mv	a0,s3
    80003744:	69a6                	ld	s3,72(sp)
}
    80003746:	70a6                	ld	ra,104(sp)
    80003748:	7406                	ld	s0,96(sp)
    8000374a:	64e6                	ld	s1,88(sp)
    8000374c:	6a06                	ld	s4,64(sp)
    8000374e:	7ae2                	ld	s5,56(sp)
    80003750:	7b42                	ld	s6,48(sp)
    80003752:	7ba2                	ld	s7,40(sp)
    80003754:	6165                	addi	sp,sp,112
    80003756:	8082                	ret
    return 0;
    80003758:	4501                	li	a0,0
}
    8000375a:	8082                	ret

000000008000375c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000375c:	457c                	lw	a5,76(a0)
    8000375e:	0ed7eb63          	bltu	a5,a3,80003854 <writei+0xf8>
{
    80003762:	7159                	addi	sp,sp,-112
    80003764:	f486                	sd	ra,104(sp)
    80003766:	f0a2                	sd	s0,96(sp)
    80003768:	e8ca                	sd	s2,80(sp)
    8000376a:	e0d2                	sd	s4,64(sp)
    8000376c:	fc56                	sd	s5,56(sp)
    8000376e:	f85a                	sd	s6,48(sp)
    80003770:	f45e                	sd	s7,40(sp)
    80003772:	1880                	addi	s0,sp,112
    80003774:	8aaa                	mv	s5,a0
    80003776:	8bae                	mv	s7,a1
    80003778:	8a32                	mv	s4,a2
    8000377a:	8936                	mv	s2,a3
    8000377c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000377e:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003782:	00043737          	lui	a4,0x43
    80003786:	0cf76963          	bltu	a4,a5,80003858 <writei+0xfc>
    8000378a:	0cd7e763          	bltu	a5,a3,80003858 <writei+0xfc>
    8000378e:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003790:	0a0b0a63          	beqz	s6,80003844 <writei+0xe8>
    80003794:	eca6                	sd	s1,88(sp)
    80003796:	f062                	sd	s8,32(sp)
    80003798:	ec66                	sd	s9,24(sp)
    8000379a:	e86a                	sd	s10,16(sp)
    8000379c:	e46e                	sd	s11,8(sp)
    8000379e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800037a0:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800037a4:	5c7d                	li	s8,-1
    800037a6:	a825                	j	800037de <writei+0x82>
    800037a8:	020d1d93          	slli	s11,s10,0x20
    800037ac:	020ddd93          	srli	s11,s11,0x20
    800037b0:	05848513          	addi	a0,s1,88
    800037b4:	86ee                	mv	a3,s11
    800037b6:	8652                	mv	a2,s4
    800037b8:	85de                	mv	a1,s7
    800037ba:	953e                	add	a0,a0,a5
    800037bc:	b7bfe0ef          	jal	80002336 <either_copyin>
    800037c0:	05850663          	beq	a0,s8,8000380c <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    800037c4:	8526                	mv	a0,s1
    800037c6:	6b8000ef          	jal	80003e7e <log_write>
    brelse(bp);
    800037ca:	8526                	mv	a0,s1
    800037cc:	d10ff0ef          	jal	80002cdc <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800037d0:	013d09bb          	addw	s3,s10,s3
    800037d4:	012d093b          	addw	s2,s10,s2
    800037d8:	9a6e                	add	s4,s4,s11
    800037da:	0369fc63          	bgeu	s3,s6,80003812 <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    800037de:	00a9559b          	srliw	a1,s2,0xa
    800037e2:	8556                	mv	a0,s5
    800037e4:	f56ff0ef          	jal	80002f3a <bmap>
    800037e8:	85aa                	mv	a1,a0
    if(addr == 0)
    800037ea:	c505                	beqz	a0,80003812 <writei+0xb6>
    bp = bread(ip->dev, addr);
    800037ec:	000aa503          	lw	a0,0(s5)
    800037f0:	be4ff0ef          	jal	80002bd4 <bread>
    800037f4:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800037f6:	3ff97793          	andi	a5,s2,1023
    800037fa:	40fc873b          	subw	a4,s9,a5
    800037fe:	413b06bb          	subw	a3,s6,s3
    80003802:	8d3a                	mv	s10,a4
    80003804:	fae6f2e3          	bgeu	a3,a4,800037a8 <writei+0x4c>
    80003808:	8d36                	mv	s10,a3
    8000380a:	bf79                	j	800037a8 <writei+0x4c>
      brelse(bp);
    8000380c:	8526                	mv	a0,s1
    8000380e:	cceff0ef          	jal	80002cdc <brelse>
  }

  if(off > ip->size)
    80003812:	04caa783          	lw	a5,76(s5)
    80003816:	0327f963          	bgeu	a5,s2,80003848 <writei+0xec>
    ip->size = off;
    8000381a:	052aa623          	sw	s2,76(s5)
    8000381e:	64e6                	ld	s1,88(sp)
    80003820:	7c02                	ld	s8,32(sp)
    80003822:	6ce2                	ld	s9,24(sp)
    80003824:	6d42                	ld	s10,16(sp)
    80003826:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003828:	8556                	mv	a0,s5
    8000382a:	9b7ff0ef          	jal	800031e0 <iupdate>

  return tot;
    8000382e:	854e                	mv	a0,s3
    80003830:	69a6                	ld	s3,72(sp)
}
    80003832:	70a6                	ld	ra,104(sp)
    80003834:	7406                	ld	s0,96(sp)
    80003836:	6946                	ld	s2,80(sp)
    80003838:	6a06                	ld	s4,64(sp)
    8000383a:	7ae2                	ld	s5,56(sp)
    8000383c:	7b42                	ld	s6,48(sp)
    8000383e:	7ba2                	ld	s7,40(sp)
    80003840:	6165                	addi	sp,sp,112
    80003842:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003844:	89da                	mv	s3,s6
    80003846:	b7cd                	j	80003828 <writei+0xcc>
    80003848:	64e6                	ld	s1,88(sp)
    8000384a:	7c02                	ld	s8,32(sp)
    8000384c:	6ce2                	ld	s9,24(sp)
    8000384e:	6d42                	ld	s10,16(sp)
    80003850:	6da2                	ld	s11,8(sp)
    80003852:	bfd9                	j	80003828 <writei+0xcc>
    return -1;
    80003854:	557d                	li	a0,-1
}
    80003856:	8082                	ret
    return -1;
    80003858:	557d                	li	a0,-1
    8000385a:	bfe1                	j	80003832 <writei+0xd6>

000000008000385c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000385c:	1141                	addi	sp,sp,-16
    8000385e:	e406                	sd	ra,8(sp)
    80003860:	e022                	sd	s0,0(sp)
    80003862:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003864:	4639                	li	a2,14
    80003866:	d66fd0ef          	jal	80000dcc <strncmp>
}
    8000386a:	60a2                	ld	ra,8(sp)
    8000386c:	6402                	ld	s0,0(sp)
    8000386e:	0141                	addi	sp,sp,16
    80003870:	8082                	ret

0000000080003872 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003872:	711d                	addi	sp,sp,-96
    80003874:	ec86                	sd	ra,88(sp)
    80003876:	e8a2                	sd	s0,80(sp)
    80003878:	e4a6                	sd	s1,72(sp)
    8000387a:	e0ca                	sd	s2,64(sp)
    8000387c:	fc4e                	sd	s3,56(sp)
    8000387e:	f852                	sd	s4,48(sp)
    80003880:	f456                	sd	s5,40(sp)
    80003882:	f05a                	sd	s6,32(sp)
    80003884:	ec5e                	sd	s7,24(sp)
    80003886:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003888:	04451703          	lh	a4,68(a0)
    8000388c:	4785                	li	a5,1
    8000388e:	00f71f63          	bne	a4,a5,800038ac <dirlookup+0x3a>
    80003892:	892a                	mv	s2,a0
    80003894:	8aae                	mv	s5,a1
    80003896:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003898:	457c                	lw	a5,76(a0)
    8000389a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000389c:	fa040a13          	addi	s4,s0,-96
    800038a0:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    800038a2:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800038a6:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800038a8:	e39d                	bnez	a5,800038ce <dirlookup+0x5c>
    800038aa:	a8b9                	j	80003908 <dirlookup+0x96>
    panic("dirlookup not DIR");
    800038ac:	00005517          	auipc	a0,0x5
    800038b0:	c2c50513          	addi	a0,a0,-980 # 800084d8 <etext+0x4d8>
    800038b4:	f71fc0ef          	jal	80000824 <panic>
      panic("dirlookup read");
    800038b8:	00005517          	auipc	a0,0x5
    800038bc:	c3850513          	addi	a0,a0,-968 # 800084f0 <etext+0x4f0>
    800038c0:	f65fc0ef          	jal	80000824 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800038c4:	24c1                	addiw	s1,s1,16
    800038c6:	04c92783          	lw	a5,76(s2)
    800038ca:	02f4fe63          	bgeu	s1,a5,80003906 <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800038ce:	874e                	mv	a4,s3
    800038d0:	86a6                	mv	a3,s1
    800038d2:	8652                	mv	a2,s4
    800038d4:	4581                	li	a1,0
    800038d6:	854a                	mv	a0,s2
    800038d8:	d93ff0ef          	jal	8000366a <readi>
    800038dc:	fd351ee3          	bne	a0,s3,800038b8 <dirlookup+0x46>
    if(de.inum == 0)
    800038e0:	fa045783          	lhu	a5,-96(s0)
    800038e4:	d3e5                	beqz	a5,800038c4 <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    800038e6:	85da                	mv	a1,s6
    800038e8:	8556                	mv	a0,s5
    800038ea:	f73ff0ef          	jal	8000385c <namecmp>
    800038ee:	f979                	bnez	a0,800038c4 <dirlookup+0x52>
      if(poff)
    800038f0:	000b8463          	beqz	s7,800038f8 <dirlookup+0x86>
        *poff = off;
    800038f4:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    800038f8:	fa045583          	lhu	a1,-96(s0)
    800038fc:	00092503          	lw	a0,0(s2)
    80003900:	efaff0ef          	jal	80002ffa <iget>
    80003904:	a011                	j	80003908 <dirlookup+0x96>
  return 0;
    80003906:	4501                	li	a0,0
}
    80003908:	60e6                	ld	ra,88(sp)
    8000390a:	6446                	ld	s0,80(sp)
    8000390c:	64a6                	ld	s1,72(sp)
    8000390e:	6906                	ld	s2,64(sp)
    80003910:	79e2                	ld	s3,56(sp)
    80003912:	7a42                	ld	s4,48(sp)
    80003914:	7aa2                	ld	s5,40(sp)
    80003916:	7b02                	ld	s6,32(sp)
    80003918:	6be2                	ld	s7,24(sp)
    8000391a:	6125                	addi	sp,sp,96
    8000391c:	8082                	ret

000000008000391e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000391e:	711d                	addi	sp,sp,-96
    80003920:	ec86                	sd	ra,88(sp)
    80003922:	e8a2                	sd	s0,80(sp)
    80003924:	e4a6                	sd	s1,72(sp)
    80003926:	e0ca                	sd	s2,64(sp)
    80003928:	fc4e                	sd	s3,56(sp)
    8000392a:	f852                	sd	s4,48(sp)
    8000392c:	f456                	sd	s5,40(sp)
    8000392e:	f05a                	sd	s6,32(sp)
    80003930:	ec5e                	sd	s7,24(sp)
    80003932:	e862                	sd	s8,16(sp)
    80003934:	e466                	sd	s9,8(sp)
    80003936:	e06a                	sd	s10,0(sp)
    80003938:	1080                	addi	s0,sp,96
    8000393a:	84aa                	mv	s1,a0
    8000393c:	8b2e                	mv	s6,a1
    8000393e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003940:	00054703          	lbu	a4,0(a0)
    80003944:	02f00793          	li	a5,47
    80003948:	00f70f63          	beq	a4,a5,80003966 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000394c:	febfd0ef          	jal	80001936 <myproc>
    80003950:	15053503          	ld	a0,336(a0)
    80003954:	929ff0ef          	jal	8000327c <idup>
    80003958:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000395a:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    8000395e:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003960:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003962:	4b85                	li	s7,1
    80003964:	a879                	j	80003a02 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80003966:	4585                	li	a1,1
    80003968:	852e                	mv	a0,a1
    8000396a:	e90ff0ef          	jal	80002ffa <iget>
    8000396e:	8a2a                	mv	s4,a0
    80003970:	b7ed                	j	8000395a <namex+0x3c>
      iunlockput(ip);
    80003972:	8552                	mv	a0,s4
    80003974:	b6dff0ef          	jal	800034e0 <iunlockput>
      return 0;
    80003978:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    8000397a:	8552                	mv	a0,s4
    8000397c:	60e6                	ld	ra,88(sp)
    8000397e:	6446                	ld	s0,80(sp)
    80003980:	64a6                	ld	s1,72(sp)
    80003982:	6906                	ld	s2,64(sp)
    80003984:	79e2                	ld	s3,56(sp)
    80003986:	7a42                	ld	s4,48(sp)
    80003988:	7aa2                	ld	s5,40(sp)
    8000398a:	7b02                	ld	s6,32(sp)
    8000398c:	6be2                	ld	s7,24(sp)
    8000398e:	6c42                	ld	s8,16(sp)
    80003990:	6ca2                	ld	s9,8(sp)
    80003992:	6d02                	ld	s10,0(sp)
    80003994:	6125                	addi	sp,sp,96
    80003996:	8082                	ret
      iunlock(ip);
    80003998:	8552                	mv	a0,s4
    8000399a:	9e9ff0ef          	jal	80003382 <iunlock>
      return ip;
    8000399e:	bff1                	j	8000397a <namex+0x5c>
      iunlockput(ip);
    800039a0:	8552                	mv	a0,s4
    800039a2:	b3fff0ef          	jal	800034e0 <iunlockput>
      return 0;
    800039a6:	8a4a                	mv	s4,s2
    800039a8:	bfc9                	j	8000397a <namex+0x5c>
  len = path - s;
    800039aa:	40990633          	sub	a2,s2,s1
    800039ae:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    800039b2:	09ac5463          	bge	s8,s10,80003a3a <namex+0x11c>
    memmove(name, s, DIRSIZ);
    800039b6:	8666                	mv	a2,s9
    800039b8:	85a6                	mv	a1,s1
    800039ba:	8556                	mv	a0,s5
    800039bc:	b9cfd0ef          	jal	80000d58 <memmove>
    800039c0:	84ca                	mv	s1,s2
  while(*path == '/')
    800039c2:	0004c783          	lbu	a5,0(s1)
    800039c6:	01379763          	bne	a5,s3,800039d4 <namex+0xb6>
    path++;
    800039ca:	0485                	addi	s1,s1,1
  while(*path == '/')
    800039cc:	0004c783          	lbu	a5,0(s1)
    800039d0:	ff378de3          	beq	a5,s3,800039ca <namex+0xac>
    ilock(ip);
    800039d4:	8552                	mv	a0,s4
    800039d6:	8ddff0ef          	jal	800032b2 <ilock>
    if(ip->type != T_DIR){
    800039da:	044a1783          	lh	a5,68(s4)
    800039de:	f9779ae3          	bne	a5,s7,80003972 <namex+0x54>
    if(nameiparent && *path == '\0'){
    800039e2:	000b0563          	beqz	s6,800039ec <namex+0xce>
    800039e6:	0004c783          	lbu	a5,0(s1)
    800039ea:	d7dd                	beqz	a5,80003998 <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    800039ec:	4601                	li	a2,0
    800039ee:	85d6                	mv	a1,s5
    800039f0:	8552                	mv	a0,s4
    800039f2:	e81ff0ef          	jal	80003872 <dirlookup>
    800039f6:	892a                	mv	s2,a0
    800039f8:	d545                	beqz	a0,800039a0 <namex+0x82>
    iunlockput(ip);
    800039fa:	8552                	mv	a0,s4
    800039fc:	ae5ff0ef          	jal	800034e0 <iunlockput>
    ip = next;
    80003a00:	8a4a                	mv	s4,s2
  while(*path == '/')
    80003a02:	0004c783          	lbu	a5,0(s1)
    80003a06:	01379763          	bne	a5,s3,80003a14 <namex+0xf6>
    path++;
    80003a0a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003a0c:	0004c783          	lbu	a5,0(s1)
    80003a10:	ff378de3          	beq	a5,s3,80003a0a <namex+0xec>
  if(*path == 0)
    80003a14:	cf8d                	beqz	a5,80003a4e <namex+0x130>
  while(*path != '/' && *path != 0)
    80003a16:	0004c783          	lbu	a5,0(s1)
    80003a1a:	fd178713          	addi	a4,a5,-47
    80003a1e:	cb19                	beqz	a4,80003a34 <namex+0x116>
    80003a20:	cb91                	beqz	a5,80003a34 <namex+0x116>
    80003a22:	8926                	mv	s2,s1
    path++;
    80003a24:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    80003a26:	00094783          	lbu	a5,0(s2)
    80003a2a:	fd178713          	addi	a4,a5,-47
    80003a2e:	df35                	beqz	a4,800039aa <namex+0x8c>
    80003a30:	fbf5                	bnez	a5,80003a24 <namex+0x106>
    80003a32:	bfa5                	j	800039aa <namex+0x8c>
    80003a34:	8926                	mv	s2,s1
  len = path - s;
    80003a36:	4d01                	li	s10,0
    80003a38:	4601                	li	a2,0
    memmove(name, s, len);
    80003a3a:	2601                	sext.w	a2,a2
    80003a3c:	85a6                	mv	a1,s1
    80003a3e:	8556                	mv	a0,s5
    80003a40:	b18fd0ef          	jal	80000d58 <memmove>
    name[len] = 0;
    80003a44:	9d56                	add	s10,s10,s5
    80003a46:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffd0820>
    80003a4a:	84ca                	mv	s1,s2
    80003a4c:	bf9d                	j	800039c2 <namex+0xa4>
  if(nameiparent){
    80003a4e:	f20b06e3          	beqz	s6,8000397a <namex+0x5c>
    iput(ip);
    80003a52:	8552                	mv	a0,s4
    80003a54:	a03ff0ef          	jal	80003456 <iput>
    return 0;
    80003a58:	4a01                	li	s4,0
    80003a5a:	b705                	j	8000397a <namex+0x5c>

0000000080003a5c <dirlink>:
{
    80003a5c:	715d                	addi	sp,sp,-80
    80003a5e:	e486                	sd	ra,72(sp)
    80003a60:	e0a2                	sd	s0,64(sp)
    80003a62:	f84a                	sd	s2,48(sp)
    80003a64:	ec56                	sd	s5,24(sp)
    80003a66:	e85a                	sd	s6,16(sp)
    80003a68:	0880                	addi	s0,sp,80
    80003a6a:	892a                	mv	s2,a0
    80003a6c:	8aae                	mv	s5,a1
    80003a6e:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003a70:	4601                	li	a2,0
    80003a72:	e01ff0ef          	jal	80003872 <dirlookup>
    80003a76:	ed1d                	bnez	a0,80003ab4 <dirlink+0x58>
    80003a78:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a7a:	04c92483          	lw	s1,76(s2)
    80003a7e:	c4b9                	beqz	s1,80003acc <dirlink+0x70>
    80003a80:	f44e                	sd	s3,40(sp)
    80003a82:	f052                	sd	s4,32(sp)
    80003a84:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a86:	fb040a13          	addi	s4,s0,-80
    80003a8a:	49c1                	li	s3,16
    80003a8c:	874e                	mv	a4,s3
    80003a8e:	86a6                	mv	a3,s1
    80003a90:	8652                	mv	a2,s4
    80003a92:	4581                	li	a1,0
    80003a94:	854a                	mv	a0,s2
    80003a96:	bd5ff0ef          	jal	8000366a <readi>
    80003a9a:	03351163          	bne	a0,s3,80003abc <dirlink+0x60>
    if(de.inum == 0)
    80003a9e:	fb045783          	lhu	a5,-80(s0)
    80003aa2:	c39d                	beqz	a5,80003ac8 <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003aa4:	24c1                	addiw	s1,s1,16
    80003aa6:	04c92783          	lw	a5,76(s2)
    80003aaa:	fef4e1e3          	bltu	s1,a5,80003a8c <dirlink+0x30>
    80003aae:	79a2                	ld	s3,40(sp)
    80003ab0:	7a02                	ld	s4,32(sp)
    80003ab2:	a829                	j	80003acc <dirlink+0x70>
    iput(ip);
    80003ab4:	9a3ff0ef          	jal	80003456 <iput>
    return -1;
    80003ab8:	557d                	li	a0,-1
    80003aba:	a83d                	j	80003af8 <dirlink+0x9c>
      panic("dirlink read");
    80003abc:	00005517          	auipc	a0,0x5
    80003ac0:	a4450513          	addi	a0,a0,-1468 # 80008500 <etext+0x500>
    80003ac4:	d61fc0ef          	jal	80000824 <panic>
    80003ac8:	79a2                	ld	s3,40(sp)
    80003aca:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003acc:	4639                	li	a2,14
    80003ace:	85d6                	mv	a1,s5
    80003ad0:	fb240513          	addi	a0,s0,-78
    80003ad4:	b32fd0ef          	jal	80000e06 <strncpy>
  de.inum = inum;
    80003ad8:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003adc:	4741                	li	a4,16
    80003ade:	86a6                	mv	a3,s1
    80003ae0:	fb040613          	addi	a2,s0,-80
    80003ae4:	4581                	li	a1,0
    80003ae6:	854a                	mv	a0,s2
    80003ae8:	c75ff0ef          	jal	8000375c <writei>
    80003aec:	1541                	addi	a0,a0,-16
    80003aee:	00a03533          	snez	a0,a0
    80003af2:	40a0053b          	negw	a0,a0
    80003af6:	74e2                	ld	s1,56(sp)
}
    80003af8:	60a6                	ld	ra,72(sp)
    80003afa:	6406                	ld	s0,64(sp)
    80003afc:	7942                	ld	s2,48(sp)
    80003afe:	6ae2                	ld	s5,24(sp)
    80003b00:	6b42                	ld	s6,16(sp)
    80003b02:	6161                	addi	sp,sp,80
    80003b04:	8082                	ret

0000000080003b06 <namei>:

struct inode*
namei(char *path)
{
    80003b06:	1101                	addi	sp,sp,-32
    80003b08:	ec06                	sd	ra,24(sp)
    80003b0a:	e822                	sd	s0,16(sp)
    80003b0c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003b0e:	fe040613          	addi	a2,s0,-32
    80003b12:	4581                	li	a1,0
    80003b14:	e0bff0ef          	jal	8000391e <namex>
}
    80003b18:	60e2                	ld	ra,24(sp)
    80003b1a:	6442                	ld	s0,16(sp)
    80003b1c:	6105                	addi	sp,sp,32
    80003b1e:	8082                	ret

0000000080003b20 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003b20:	1141                	addi	sp,sp,-16
    80003b22:	e406                	sd	ra,8(sp)
    80003b24:	e022                	sd	s0,0(sp)
    80003b26:	0800                	addi	s0,sp,16
    80003b28:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003b2a:	4585                	li	a1,1
    80003b2c:	df3ff0ef          	jal	8000391e <namex>
}
    80003b30:	60a2                	ld	ra,8(sp)
    80003b32:	6402                	ld	s0,0(sp)
    80003b34:	0141                	addi	sp,sp,16
    80003b36:	8082                	ret

0000000080003b38 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003b38:	1101                	addi	sp,sp,-32
    80003b3a:	ec06                	sd	ra,24(sp)
    80003b3c:	e822                	sd	s0,16(sp)
    80003b3e:	e426                	sd	s1,8(sp)
    80003b40:	e04a                	sd	s2,0(sp)
    80003b42:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003b44:	0001e917          	auipc	s2,0x1e
    80003b48:	29490913          	addi	s2,s2,660 # 80021dd8 <log>
    80003b4c:	01892583          	lw	a1,24(s2)
    80003b50:	02492503          	lw	a0,36(s2)
    80003b54:	880ff0ef          	jal	80002bd4 <bread>
    80003b58:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003b5a:	02892603          	lw	a2,40(s2)
    80003b5e:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003b60:	00c05f63          	blez	a2,80003b7e <write_head+0x46>
    80003b64:	0001e717          	auipc	a4,0x1e
    80003b68:	2a070713          	addi	a4,a4,672 # 80021e04 <log+0x2c>
    80003b6c:	87aa                	mv	a5,a0
    80003b6e:	060a                	slli	a2,a2,0x2
    80003b70:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003b72:	4314                	lw	a3,0(a4)
    80003b74:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003b76:	0711                	addi	a4,a4,4
    80003b78:	0791                	addi	a5,a5,4
    80003b7a:	fec79ce3          	bne	a5,a2,80003b72 <write_head+0x3a>
  }
  bwrite(buf);
    80003b7e:	8526                	mv	a0,s1
    80003b80:	92aff0ef          	jal	80002caa <bwrite>
  brelse(buf);
    80003b84:	8526                	mv	a0,s1
    80003b86:	956ff0ef          	jal	80002cdc <brelse>
}
    80003b8a:	60e2                	ld	ra,24(sp)
    80003b8c:	6442                	ld	s0,16(sp)
    80003b8e:	64a2                	ld	s1,8(sp)
    80003b90:	6902                	ld	s2,0(sp)
    80003b92:	6105                	addi	sp,sp,32
    80003b94:	8082                	ret

0000000080003b96 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b96:	0001e797          	auipc	a5,0x1e
    80003b9a:	26a7a783          	lw	a5,618(a5) # 80021e00 <log+0x28>
    80003b9e:	0cf05163          	blez	a5,80003c60 <install_trans+0xca>
{
    80003ba2:	715d                	addi	sp,sp,-80
    80003ba4:	e486                	sd	ra,72(sp)
    80003ba6:	e0a2                	sd	s0,64(sp)
    80003ba8:	fc26                	sd	s1,56(sp)
    80003baa:	f84a                	sd	s2,48(sp)
    80003bac:	f44e                	sd	s3,40(sp)
    80003bae:	f052                	sd	s4,32(sp)
    80003bb0:	ec56                	sd	s5,24(sp)
    80003bb2:	e85a                	sd	s6,16(sp)
    80003bb4:	e45e                	sd	s7,8(sp)
    80003bb6:	e062                	sd	s8,0(sp)
    80003bb8:	0880                	addi	s0,sp,80
    80003bba:	8b2a                	mv	s6,a0
    80003bbc:	0001ea97          	auipc	s5,0x1e
    80003bc0:	248a8a93          	addi	s5,s5,584 # 80021e04 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003bc4:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003bc6:	00005c17          	auipc	s8,0x5
    80003bca:	94ac0c13          	addi	s8,s8,-1718 # 80008510 <etext+0x510>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003bce:	0001ea17          	auipc	s4,0x1e
    80003bd2:	20aa0a13          	addi	s4,s4,522 # 80021dd8 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003bd6:	40000b93          	li	s7,1024
    80003bda:	a025                	j	80003c02 <install_trans+0x6c>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003bdc:	000aa603          	lw	a2,0(s5)
    80003be0:	85ce                	mv	a1,s3
    80003be2:	8562                	mv	a0,s8
    80003be4:	917fc0ef          	jal	800004fa <printf>
    80003be8:	a839                	j	80003c06 <install_trans+0x70>
    brelse(lbuf);
    80003bea:	854a                	mv	a0,s2
    80003bec:	8f0ff0ef          	jal	80002cdc <brelse>
    brelse(dbuf);
    80003bf0:	8526                	mv	a0,s1
    80003bf2:	8eaff0ef          	jal	80002cdc <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003bf6:	2985                	addiw	s3,s3,1
    80003bf8:	0a91                	addi	s5,s5,4
    80003bfa:	028a2783          	lw	a5,40(s4)
    80003bfe:	04f9d563          	bge	s3,a5,80003c48 <install_trans+0xb2>
    if(recovering) {
    80003c02:	fc0b1de3          	bnez	s6,80003bdc <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003c06:	018a2583          	lw	a1,24(s4)
    80003c0a:	013585bb          	addw	a1,a1,s3
    80003c0e:	2585                	addiw	a1,a1,1
    80003c10:	024a2503          	lw	a0,36(s4)
    80003c14:	fc1fe0ef          	jal	80002bd4 <bread>
    80003c18:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003c1a:	000aa583          	lw	a1,0(s5)
    80003c1e:	024a2503          	lw	a0,36(s4)
    80003c22:	fb3fe0ef          	jal	80002bd4 <bread>
    80003c26:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003c28:	865e                	mv	a2,s7
    80003c2a:	05890593          	addi	a1,s2,88
    80003c2e:	05850513          	addi	a0,a0,88
    80003c32:	926fd0ef          	jal	80000d58 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003c36:	8526                	mv	a0,s1
    80003c38:	872ff0ef          	jal	80002caa <bwrite>
    if(recovering == 0)
    80003c3c:	fa0b17e3          	bnez	s6,80003bea <install_trans+0x54>
      bunpin(dbuf);
    80003c40:	8526                	mv	a0,s1
    80003c42:	952ff0ef          	jal	80002d94 <bunpin>
    80003c46:	b755                	j	80003bea <install_trans+0x54>
}
    80003c48:	60a6                	ld	ra,72(sp)
    80003c4a:	6406                	ld	s0,64(sp)
    80003c4c:	74e2                	ld	s1,56(sp)
    80003c4e:	7942                	ld	s2,48(sp)
    80003c50:	79a2                	ld	s3,40(sp)
    80003c52:	7a02                	ld	s4,32(sp)
    80003c54:	6ae2                	ld	s5,24(sp)
    80003c56:	6b42                	ld	s6,16(sp)
    80003c58:	6ba2                	ld	s7,8(sp)
    80003c5a:	6c02                	ld	s8,0(sp)
    80003c5c:	6161                	addi	sp,sp,80
    80003c5e:	8082                	ret
    80003c60:	8082                	ret

0000000080003c62 <initlog>:
{
    80003c62:	7179                	addi	sp,sp,-48
    80003c64:	f406                	sd	ra,40(sp)
    80003c66:	f022                	sd	s0,32(sp)
    80003c68:	ec26                	sd	s1,24(sp)
    80003c6a:	e84a                	sd	s2,16(sp)
    80003c6c:	e44e                	sd	s3,8(sp)
    80003c6e:	1800                	addi	s0,sp,48
    80003c70:	84aa                	mv	s1,a0
    80003c72:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003c74:	0001e917          	auipc	s2,0x1e
    80003c78:	16490913          	addi	s2,s2,356 # 80021dd8 <log>
    80003c7c:	00005597          	auipc	a1,0x5
    80003c80:	d9458593          	addi	a1,a1,-620 # 80008a10 <etext+0xa10>
    80003c84:	854a                	mv	a0,s2
    80003c86:	f19fc0ef          	jal	80000b9e <initlock>
  log.start = sb->logstart;
    80003c8a:	0149a583          	lw	a1,20(s3)
    80003c8e:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003c92:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003c96:	8526                	mv	a0,s1
    80003c98:	f3dfe0ef          	jal	80002bd4 <bread>
  log.lh.n = lh->n;
    80003c9c:	4d30                	lw	a2,88(a0)
    80003c9e:	02c92423          	sw	a2,40(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003ca2:	00c05f63          	blez	a2,80003cc0 <initlog+0x5e>
    80003ca6:	87aa                	mv	a5,a0
    80003ca8:	0001e717          	auipc	a4,0x1e
    80003cac:	15c70713          	addi	a4,a4,348 # 80021e04 <log+0x2c>
    80003cb0:	060a                	slli	a2,a2,0x2
    80003cb2:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003cb4:	4ff4                	lw	a3,92(a5)
    80003cb6:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003cb8:	0791                	addi	a5,a5,4
    80003cba:	0711                	addi	a4,a4,4
    80003cbc:	fec79ce3          	bne	a5,a2,80003cb4 <initlog+0x52>
  brelse(buf);
    80003cc0:	81cff0ef          	jal	80002cdc <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003cc4:	4505                	li	a0,1
    80003cc6:	ed1ff0ef          	jal	80003b96 <install_trans>
  log.lh.n = 0;
    80003cca:	0001e797          	auipc	a5,0x1e
    80003cce:	1207ab23          	sw	zero,310(a5) # 80021e00 <log+0x28>
  write_head(); // clear the log
    80003cd2:	e67ff0ef          	jal	80003b38 <write_head>
}
    80003cd6:	70a2                	ld	ra,40(sp)
    80003cd8:	7402                	ld	s0,32(sp)
    80003cda:	64e2                	ld	s1,24(sp)
    80003cdc:	6942                	ld	s2,16(sp)
    80003cde:	69a2                	ld	s3,8(sp)
    80003ce0:	6145                	addi	sp,sp,48
    80003ce2:	8082                	ret

0000000080003ce4 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003ce4:	1101                	addi	sp,sp,-32
    80003ce6:	ec06                	sd	ra,24(sp)
    80003ce8:	e822                	sd	s0,16(sp)
    80003cea:	e426                	sd	s1,8(sp)
    80003cec:	e04a                	sd	s2,0(sp)
    80003cee:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003cf0:	0001e517          	auipc	a0,0x1e
    80003cf4:	0e850513          	addi	a0,a0,232 # 80021dd8 <log>
    80003cf8:	f31fc0ef          	jal	80000c28 <acquire>
  while(1){
    if(log.committing){
    80003cfc:	0001e497          	auipc	s1,0x1e
    80003d00:	0dc48493          	addi	s1,s1,220 # 80021dd8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003d04:	4979                	li	s2,30
    80003d06:	a029                	j	80003d10 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003d08:	85a6                	mv	a1,s1
    80003d0a:	8526                	mv	a0,s1
    80003d0c:	a86fe0ef          	jal	80001f92 <sleep>
    if(log.committing){
    80003d10:	509c                	lw	a5,32(s1)
    80003d12:	fbfd                	bnez	a5,80003d08 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003d14:	4cd8                	lw	a4,28(s1)
    80003d16:	2705                	addiw	a4,a4,1
    80003d18:	0027179b          	slliw	a5,a4,0x2
    80003d1c:	9fb9                	addw	a5,a5,a4
    80003d1e:	0017979b          	slliw	a5,a5,0x1
    80003d22:	5494                	lw	a3,40(s1)
    80003d24:	9fb5                	addw	a5,a5,a3
    80003d26:	00f95763          	bge	s2,a5,80003d34 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003d2a:	85a6                	mv	a1,s1
    80003d2c:	8526                	mv	a0,s1
    80003d2e:	a64fe0ef          	jal	80001f92 <sleep>
    80003d32:	bff9                	j	80003d10 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003d34:	0001e797          	auipc	a5,0x1e
    80003d38:	0ce7a023          	sw	a4,192(a5) # 80021df4 <log+0x1c>
      release(&log.lock);
    80003d3c:	0001e517          	auipc	a0,0x1e
    80003d40:	09c50513          	addi	a0,a0,156 # 80021dd8 <log>
    80003d44:	f79fc0ef          	jal	80000cbc <release>
      break;
    }
  }
}
    80003d48:	60e2                	ld	ra,24(sp)
    80003d4a:	6442                	ld	s0,16(sp)
    80003d4c:	64a2                	ld	s1,8(sp)
    80003d4e:	6902                	ld	s2,0(sp)
    80003d50:	6105                	addi	sp,sp,32
    80003d52:	8082                	ret

0000000080003d54 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003d54:	7139                	addi	sp,sp,-64
    80003d56:	fc06                	sd	ra,56(sp)
    80003d58:	f822                	sd	s0,48(sp)
    80003d5a:	f426                	sd	s1,40(sp)
    80003d5c:	f04a                	sd	s2,32(sp)
    80003d5e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003d60:	0001e497          	auipc	s1,0x1e
    80003d64:	07848493          	addi	s1,s1,120 # 80021dd8 <log>
    80003d68:	8526                	mv	a0,s1
    80003d6a:	ebffc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    80003d6e:	4cdc                	lw	a5,28(s1)
    80003d70:	37fd                	addiw	a5,a5,-1
    80003d72:	893e                	mv	s2,a5
    80003d74:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003d76:	509c                	lw	a5,32(s1)
    80003d78:	e7b1                	bnez	a5,80003dc4 <end_op+0x70>
    panic("log.committing");
  if(log.outstanding == 0){
    80003d7a:	04091e63          	bnez	s2,80003dd6 <end_op+0x82>
    do_commit = 1;
    log.committing = 1;
    80003d7e:	0001e497          	auipc	s1,0x1e
    80003d82:	05a48493          	addi	s1,s1,90 # 80021dd8 <log>
    80003d86:	4785                	li	a5,1
    80003d88:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003d8a:	8526                	mv	a0,s1
    80003d8c:	f31fc0ef          	jal	80000cbc <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003d90:	549c                	lw	a5,40(s1)
    80003d92:	06f04463          	bgtz	a5,80003dfa <end_op+0xa6>
    acquire(&log.lock);
    80003d96:	0001e517          	auipc	a0,0x1e
    80003d9a:	04250513          	addi	a0,a0,66 # 80021dd8 <log>
    80003d9e:	e8bfc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    80003da2:	0001e797          	auipc	a5,0x1e
    80003da6:	0407ab23          	sw	zero,86(a5) # 80021df8 <log+0x20>
    wakeup(&log);
    80003daa:	0001e517          	auipc	a0,0x1e
    80003dae:	02e50513          	addi	a0,a0,46 # 80021dd8 <log>
    80003db2:	a2cfe0ef          	jal	80001fde <wakeup>
    release(&log.lock);
    80003db6:	0001e517          	auipc	a0,0x1e
    80003dba:	02250513          	addi	a0,a0,34 # 80021dd8 <log>
    80003dbe:	efffc0ef          	jal	80000cbc <release>
}
    80003dc2:	a035                	j	80003dee <end_op+0x9a>
    80003dc4:	ec4e                	sd	s3,24(sp)
    80003dc6:	e852                	sd	s4,16(sp)
    80003dc8:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003dca:	00004517          	auipc	a0,0x4
    80003dce:	76650513          	addi	a0,a0,1894 # 80008530 <etext+0x530>
    80003dd2:	a53fc0ef          	jal	80000824 <panic>
    wakeup(&log);
    80003dd6:	0001e517          	auipc	a0,0x1e
    80003dda:	00250513          	addi	a0,a0,2 # 80021dd8 <log>
    80003dde:	a00fe0ef          	jal	80001fde <wakeup>
  release(&log.lock);
    80003de2:	0001e517          	auipc	a0,0x1e
    80003de6:	ff650513          	addi	a0,a0,-10 # 80021dd8 <log>
    80003dea:	ed3fc0ef          	jal	80000cbc <release>
}
    80003dee:	70e2                	ld	ra,56(sp)
    80003df0:	7442                	ld	s0,48(sp)
    80003df2:	74a2                	ld	s1,40(sp)
    80003df4:	7902                	ld	s2,32(sp)
    80003df6:	6121                	addi	sp,sp,64
    80003df8:	8082                	ret
    80003dfa:	ec4e                	sd	s3,24(sp)
    80003dfc:	e852                	sd	s4,16(sp)
    80003dfe:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e00:	0001ea97          	auipc	s5,0x1e
    80003e04:	004a8a93          	addi	s5,s5,4 # 80021e04 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003e08:	0001ea17          	auipc	s4,0x1e
    80003e0c:	fd0a0a13          	addi	s4,s4,-48 # 80021dd8 <log>
    80003e10:	018a2583          	lw	a1,24(s4)
    80003e14:	012585bb          	addw	a1,a1,s2
    80003e18:	2585                	addiw	a1,a1,1
    80003e1a:	024a2503          	lw	a0,36(s4)
    80003e1e:	db7fe0ef          	jal	80002bd4 <bread>
    80003e22:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003e24:	000aa583          	lw	a1,0(s5)
    80003e28:	024a2503          	lw	a0,36(s4)
    80003e2c:	da9fe0ef          	jal	80002bd4 <bread>
    80003e30:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003e32:	40000613          	li	a2,1024
    80003e36:	05850593          	addi	a1,a0,88
    80003e3a:	05848513          	addi	a0,s1,88
    80003e3e:	f1bfc0ef          	jal	80000d58 <memmove>
    bwrite(to);  // write the log
    80003e42:	8526                	mv	a0,s1
    80003e44:	e67fe0ef          	jal	80002caa <bwrite>
    brelse(from);
    80003e48:	854e                	mv	a0,s3
    80003e4a:	e93fe0ef          	jal	80002cdc <brelse>
    brelse(to);
    80003e4e:	8526                	mv	a0,s1
    80003e50:	e8dfe0ef          	jal	80002cdc <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e54:	2905                	addiw	s2,s2,1
    80003e56:	0a91                	addi	s5,s5,4
    80003e58:	028a2783          	lw	a5,40(s4)
    80003e5c:	faf94ae3          	blt	s2,a5,80003e10 <end_op+0xbc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003e60:	cd9ff0ef          	jal	80003b38 <write_head>
    install_trans(0); // Now install writes to home locations
    80003e64:	4501                	li	a0,0
    80003e66:	d31ff0ef          	jal	80003b96 <install_trans>
    log.lh.n = 0;
    80003e6a:	0001e797          	auipc	a5,0x1e
    80003e6e:	f807ab23          	sw	zero,-106(a5) # 80021e00 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003e72:	cc7ff0ef          	jal	80003b38 <write_head>
    80003e76:	69e2                	ld	s3,24(sp)
    80003e78:	6a42                	ld	s4,16(sp)
    80003e7a:	6aa2                	ld	s5,8(sp)
    80003e7c:	bf29                	j	80003d96 <end_op+0x42>

0000000080003e7e <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003e7e:	1101                	addi	sp,sp,-32
    80003e80:	ec06                	sd	ra,24(sp)
    80003e82:	e822                	sd	s0,16(sp)
    80003e84:	e426                	sd	s1,8(sp)
    80003e86:	1000                	addi	s0,sp,32
    80003e88:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003e8a:	0001e517          	auipc	a0,0x1e
    80003e8e:	f4e50513          	addi	a0,a0,-178 # 80021dd8 <log>
    80003e92:	d97fc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003e96:	0001e617          	auipc	a2,0x1e
    80003e9a:	f6a62603          	lw	a2,-150(a2) # 80021e00 <log+0x28>
    80003e9e:	47f5                	li	a5,29
    80003ea0:	04c7cd63          	blt	a5,a2,80003efa <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003ea4:	0001e797          	auipc	a5,0x1e
    80003ea8:	f507a783          	lw	a5,-176(a5) # 80021df4 <log+0x1c>
    80003eac:	04f05d63          	blez	a5,80003f06 <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003eb0:	4781                	li	a5,0
    80003eb2:	06c05063          	blez	a2,80003f12 <log_write+0x94>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003eb6:	44cc                	lw	a1,12(s1)
    80003eb8:	0001e717          	auipc	a4,0x1e
    80003ebc:	f4c70713          	addi	a4,a4,-180 # 80021e04 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003ec0:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003ec2:	4314                	lw	a3,0(a4)
    80003ec4:	04b68763          	beq	a3,a1,80003f12 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80003ec8:	2785                	addiw	a5,a5,1
    80003eca:	0711                	addi	a4,a4,4
    80003ecc:	fef61be3          	bne	a2,a5,80003ec2 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003ed0:	060a                	slli	a2,a2,0x2
    80003ed2:	02060613          	addi	a2,a2,32
    80003ed6:	0001e797          	auipc	a5,0x1e
    80003eda:	f0278793          	addi	a5,a5,-254 # 80021dd8 <log>
    80003ede:	97b2                	add	a5,a5,a2
    80003ee0:	44d8                	lw	a4,12(s1)
    80003ee2:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003ee4:	8526                	mv	a0,s1
    80003ee6:	e7bfe0ef          	jal	80002d60 <bpin>
    log.lh.n++;
    80003eea:	0001e717          	auipc	a4,0x1e
    80003eee:	eee70713          	addi	a4,a4,-274 # 80021dd8 <log>
    80003ef2:	571c                	lw	a5,40(a4)
    80003ef4:	2785                	addiw	a5,a5,1
    80003ef6:	d71c                	sw	a5,40(a4)
    80003ef8:	a815                	j	80003f2c <log_write+0xae>
    panic("too big a transaction");
    80003efa:	00004517          	auipc	a0,0x4
    80003efe:	64650513          	addi	a0,a0,1606 # 80008540 <etext+0x540>
    80003f02:	923fc0ef          	jal	80000824 <panic>
    panic("log_write outside of trans");
    80003f06:	00004517          	auipc	a0,0x4
    80003f0a:	65250513          	addi	a0,a0,1618 # 80008558 <etext+0x558>
    80003f0e:	917fc0ef          	jal	80000824 <panic>
  log.lh.block[i] = b->blockno;
    80003f12:	00279693          	slli	a3,a5,0x2
    80003f16:	02068693          	addi	a3,a3,32
    80003f1a:	0001e717          	auipc	a4,0x1e
    80003f1e:	ebe70713          	addi	a4,a4,-322 # 80021dd8 <log>
    80003f22:	9736                	add	a4,a4,a3
    80003f24:	44d4                	lw	a3,12(s1)
    80003f26:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003f28:	faf60ee3          	beq	a2,a5,80003ee4 <log_write+0x66>
  }
  release(&log.lock);
    80003f2c:	0001e517          	auipc	a0,0x1e
    80003f30:	eac50513          	addi	a0,a0,-340 # 80021dd8 <log>
    80003f34:	d89fc0ef          	jal	80000cbc <release>
}
    80003f38:	60e2                	ld	ra,24(sp)
    80003f3a:	6442                	ld	s0,16(sp)
    80003f3c:	64a2                	ld	s1,8(sp)
    80003f3e:	6105                	addi	sp,sp,32
    80003f40:	8082                	ret

0000000080003f42 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003f42:	1101                	addi	sp,sp,-32
    80003f44:	ec06                	sd	ra,24(sp)
    80003f46:	e822                	sd	s0,16(sp)
    80003f48:	e426                	sd	s1,8(sp)
    80003f4a:	e04a                	sd	s2,0(sp)
    80003f4c:	1000                	addi	s0,sp,32
    80003f4e:	84aa                	mv	s1,a0
    80003f50:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003f52:	00004597          	auipc	a1,0x4
    80003f56:	62658593          	addi	a1,a1,1574 # 80008578 <etext+0x578>
    80003f5a:	0521                	addi	a0,a0,8
    80003f5c:	c43fc0ef          	jal	80000b9e <initlock>
  lk->name = name;
    80003f60:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003f64:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003f68:	0204a423          	sw	zero,40(s1)
}
    80003f6c:	60e2                	ld	ra,24(sp)
    80003f6e:	6442                	ld	s0,16(sp)
    80003f70:	64a2                	ld	s1,8(sp)
    80003f72:	6902                	ld	s2,0(sp)
    80003f74:	6105                	addi	sp,sp,32
    80003f76:	8082                	ret

0000000080003f78 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003f78:	1101                	addi	sp,sp,-32
    80003f7a:	ec06                	sd	ra,24(sp)
    80003f7c:	e822                	sd	s0,16(sp)
    80003f7e:	e426                	sd	s1,8(sp)
    80003f80:	e04a                	sd	s2,0(sp)
    80003f82:	1000                	addi	s0,sp,32
    80003f84:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003f86:	00850913          	addi	s2,a0,8
    80003f8a:	854a                	mv	a0,s2
    80003f8c:	c9dfc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    80003f90:	409c                	lw	a5,0(s1)
    80003f92:	c799                	beqz	a5,80003fa0 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003f94:	85ca                	mv	a1,s2
    80003f96:	8526                	mv	a0,s1
    80003f98:	ffbfd0ef          	jal	80001f92 <sleep>
  while (lk->locked) {
    80003f9c:	409c                	lw	a5,0(s1)
    80003f9e:	fbfd                	bnez	a5,80003f94 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003fa0:	4785                	li	a5,1
    80003fa2:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003fa4:	993fd0ef          	jal	80001936 <myproc>
    80003fa8:	591c                	lw	a5,48(a0)
    80003faa:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003fac:	854a                	mv	a0,s2
    80003fae:	d0ffc0ef          	jal	80000cbc <release>
}
    80003fb2:	60e2                	ld	ra,24(sp)
    80003fb4:	6442                	ld	s0,16(sp)
    80003fb6:	64a2                	ld	s1,8(sp)
    80003fb8:	6902                	ld	s2,0(sp)
    80003fba:	6105                	addi	sp,sp,32
    80003fbc:	8082                	ret

0000000080003fbe <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003fbe:	1101                	addi	sp,sp,-32
    80003fc0:	ec06                	sd	ra,24(sp)
    80003fc2:	e822                	sd	s0,16(sp)
    80003fc4:	e426                	sd	s1,8(sp)
    80003fc6:	e04a                	sd	s2,0(sp)
    80003fc8:	1000                	addi	s0,sp,32
    80003fca:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003fcc:	00850913          	addi	s2,a0,8
    80003fd0:	854a                	mv	a0,s2
    80003fd2:	c57fc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    80003fd6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003fda:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003fde:	8526                	mv	a0,s1
    80003fe0:	ffffd0ef          	jal	80001fde <wakeup>
  release(&lk->lk);
    80003fe4:	854a                	mv	a0,s2
    80003fe6:	cd7fc0ef          	jal	80000cbc <release>
}
    80003fea:	60e2                	ld	ra,24(sp)
    80003fec:	6442                	ld	s0,16(sp)
    80003fee:	64a2                	ld	s1,8(sp)
    80003ff0:	6902                	ld	s2,0(sp)
    80003ff2:	6105                	addi	sp,sp,32
    80003ff4:	8082                	ret

0000000080003ff6 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003ff6:	7179                	addi	sp,sp,-48
    80003ff8:	f406                	sd	ra,40(sp)
    80003ffa:	f022                	sd	s0,32(sp)
    80003ffc:	ec26                	sd	s1,24(sp)
    80003ffe:	e84a                	sd	s2,16(sp)
    80004000:	1800                	addi	s0,sp,48
    80004002:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004004:	00850913          	addi	s2,a0,8
    80004008:	854a                	mv	a0,s2
    8000400a:	c1ffc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000400e:	409c                	lw	a5,0(s1)
    80004010:	ef81                	bnez	a5,80004028 <holdingsleep+0x32>
    80004012:	4481                	li	s1,0
  release(&lk->lk);
    80004014:	854a                	mv	a0,s2
    80004016:	ca7fc0ef          	jal	80000cbc <release>
  return r;
}
    8000401a:	8526                	mv	a0,s1
    8000401c:	70a2                	ld	ra,40(sp)
    8000401e:	7402                	ld	s0,32(sp)
    80004020:	64e2                	ld	s1,24(sp)
    80004022:	6942                	ld	s2,16(sp)
    80004024:	6145                	addi	sp,sp,48
    80004026:	8082                	ret
    80004028:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000402a:	0284a983          	lw	s3,40(s1)
    8000402e:	909fd0ef          	jal	80001936 <myproc>
    80004032:	5904                	lw	s1,48(a0)
    80004034:	413484b3          	sub	s1,s1,s3
    80004038:	0014b493          	seqz	s1,s1
    8000403c:	69a2                	ld	s3,8(sp)
    8000403e:	bfd9                	j	80004014 <holdingsleep+0x1e>

0000000080004040 <check_permission>:
// fileread, filewrite, sys_open — single point of truth
// means a single fix if a vulnerability is found
// =============================================================
int
check_permission(struct inode *ip, int access_mode, int caller_uid, int caller_gid)
{
    80004040:	1141                	addi	sp,sp,-16
    80004042:	e406                	sd	ra,8(sp)
    80004044:	e022                	sd	s0,0(sp)
    80004046:	0800                	addi	s0,sp,16
    // ADMIN (uid=0) bypasses all permission checks
    // WHY: ADMIN must be able to recover the system; this matches
    // Linux's CAP_DAC_OVERRIDE capability
    if (caller_uid == ROLE_ADMIN)
    80004048:	ca39                	beqz	a2,8000409e <check_permission+0x5e>
        return 0;

    uint perm_bits;

    if (caller_uid == (int)ip->uid) {
    8000404a:	08852783          	lw	a5,136(a0)
    8000404e:	02c78c63          	beq	a5,a2,80004086 <check_permission+0x46>
        // Caller is the owner
        perm_bits = (ip->mode >> 6) & 0x7;  // Owner bits
    } else if (caller_gid == (int)ip->gid) {
    80004052:	08c52783          	lw	a5,140(a0)
    80004056:	02d78e63          	beq	a5,a3,80004092 <check_permission+0x52>
        // Caller's group matches file's group
        perm_bits = (ip->mode >> 3) & 0x7;  // Group bits
    } else {
        // Everyone else
        perm_bits = ip->mode & 0x7;          // Other bits
    8000405a:	08452783          	lw	a5,132(a0)
    8000405e:	8b9d                	andi	a5,a5,7
    }

    // access_mode: 1=read, 2=write, 4=execute (can be ORed)
    if ((access_mode & 1) && !(perm_bits & 4)) return -1;  // Need read, no read bit
    80004060:	0015f713          	andi	a4,a1,1
    80004064:	c701                	beqz	a4,8000406c <check_permission+0x2c>
    80004066:	0047f713          	andi	a4,a5,4
    8000406a:	cf1d                	beqz	a4,800040a8 <check_permission+0x68>
    if ((access_mode & 2) && !(perm_bits & 2)) return -1;  // Need write, no write bit
    8000406c:	0025f713          	andi	a4,a1,2
    80004070:	c701                	beqz	a4,80004078 <check_permission+0x38>
    80004072:	0027f713          	andi	a4,a5,2
    80004076:	cb1d                	beqz	a4,800040ac <check_permission+0x6c>
    if ((access_mode & 4) && !(perm_bits & 1)) return -1;  // Need exec, no exec bit
    80004078:	0045f513          	andi	a0,a1,4
    8000407c:	c115                	beqz	a0,800040a0 <check_permission+0x60>
    8000407e:	8b85                	andi	a5,a5,1
    80004080:	fff7851b          	addiw	a0,a5,-1
    80004084:	a831                	j	800040a0 <check_permission+0x60>
        perm_bits = (ip->mode >> 6) & 0x7;  // Owner bits
    80004086:	08452783          	lw	a5,132(a0)
    8000408a:	0067d79b          	srliw	a5,a5,0x6
    8000408e:	8b9d                	andi	a5,a5,7
    80004090:	bfc1                	j	80004060 <check_permission+0x20>
        perm_bits = (ip->mode >> 3) & 0x7;  // Group bits
    80004092:	08452783          	lw	a5,132(a0)
    80004096:	0037d79b          	srliw	a5,a5,0x3
    8000409a:	8b9d                	andi	a5,a5,7
    8000409c:	b7d1                	j	80004060 <check_permission+0x20>
        return 0;
    8000409e:	8532                	mv	a0,a2

    return 0;  // Permitted
}
    800040a0:	60a2                	ld	ra,8(sp)
    800040a2:	6402                	ld	s0,0(sp)
    800040a4:	0141                	addi	sp,sp,16
    800040a6:	8082                	ret
    if ((access_mode & 1) && !(perm_bits & 4)) return -1;  // Need read, no read bit
    800040a8:	557d                	li	a0,-1
    800040aa:	bfdd                	j	800040a0 <check_permission+0x60>
    if ((access_mode & 2) && !(perm_bits & 2)) return -1;  // Need write, no write bit
    800040ac:	557d                	li	a0,-1
    800040ae:	bfcd                	j	800040a0 <check_permission+0x60>

00000000800040b0 <fileinit>:

void
fileinit(void)
{
    800040b0:	1141                	addi	sp,sp,-16
    800040b2:	e406                	sd	ra,8(sp)
    800040b4:	e022                	sd	s0,0(sp)
    800040b6:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800040b8:	00004597          	auipc	a1,0x4
    800040bc:	4d058593          	addi	a1,a1,1232 # 80008588 <etext+0x588>
    800040c0:	0001e517          	auipc	a0,0x1e
    800040c4:	e6050513          	addi	a0,a0,-416 # 80021f20 <ftable>
    800040c8:	ad7fc0ef          	jal	80000b9e <initlock>
}
    800040cc:	60a2                	ld	ra,8(sp)
    800040ce:	6402                	ld	s0,0(sp)
    800040d0:	0141                	addi	sp,sp,16
    800040d2:	8082                	ret

00000000800040d4 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800040d4:	1101                	addi	sp,sp,-32
    800040d6:	ec06                	sd	ra,24(sp)
    800040d8:	e822                	sd	s0,16(sp)
    800040da:	e426                	sd	s1,8(sp)
    800040dc:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800040de:	0001e517          	auipc	a0,0x1e
    800040e2:	e4250513          	addi	a0,a0,-446 # 80021f20 <ftable>
    800040e6:	b43fc0ef          	jal	80000c28 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800040ea:	0001e497          	auipc	s1,0x1e
    800040ee:	e4e48493          	addi	s1,s1,-434 # 80021f38 <ftable+0x18>
    800040f2:	0001f717          	auipc	a4,0x1f
    800040f6:	de670713          	addi	a4,a4,-538 # 80022ed8 <disk>
    if(f->ref == 0){
    800040fa:	40dc                	lw	a5,4(s1)
    800040fc:	cf89                	beqz	a5,80004116 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800040fe:	02848493          	addi	s1,s1,40
    80004102:	fee49ce3          	bne	s1,a4,800040fa <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004106:	0001e517          	auipc	a0,0x1e
    8000410a:	e1a50513          	addi	a0,a0,-486 # 80021f20 <ftable>
    8000410e:	baffc0ef          	jal	80000cbc <release>
  return 0;
    80004112:	4481                	li	s1,0
    80004114:	a809                	j	80004126 <filealloc+0x52>
      f->ref = 1;
    80004116:	4785                	li	a5,1
    80004118:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000411a:	0001e517          	auipc	a0,0x1e
    8000411e:	e0650513          	addi	a0,a0,-506 # 80021f20 <ftable>
    80004122:	b9bfc0ef          	jal	80000cbc <release>
}
    80004126:	8526                	mv	a0,s1
    80004128:	60e2                	ld	ra,24(sp)
    8000412a:	6442                	ld	s0,16(sp)
    8000412c:	64a2                	ld	s1,8(sp)
    8000412e:	6105                	addi	sp,sp,32
    80004130:	8082                	ret

0000000080004132 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004132:	1101                	addi	sp,sp,-32
    80004134:	ec06                	sd	ra,24(sp)
    80004136:	e822                	sd	s0,16(sp)
    80004138:	e426                	sd	s1,8(sp)
    8000413a:	1000                	addi	s0,sp,32
    8000413c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000413e:	0001e517          	auipc	a0,0x1e
    80004142:	de250513          	addi	a0,a0,-542 # 80021f20 <ftable>
    80004146:	ae3fc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    8000414a:	40dc                	lw	a5,4(s1)
    8000414c:	02f05063          	blez	a5,8000416c <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004150:	2785                	addiw	a5,a5,1
    80004152:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004154:	0001e517          	auipc	a0,0x1e
    80004158:	dcc50513          	addi	a0,a0,-564 # 80021f20 <ftable>
    8000415c:	b61fc0ef          	jal	80000cbc <release>
  return f;
}
    80004160:	8526                	mv	a0,s1
    80004162:	60e2                	ld	ra,24(sp)
    80004164:	6442                	ld	s0,16(sp)
    80004166:	64a2                	ld	s1,8(sp)
    80004168:	6105                	addi	sp,sp,32
    8000416a:	8082                	ret
    panic("filedup");
    8000416c:	00004517          	auipc	a0,0x4
    80004170:	42450513          	addi	a0,a0,1060 # 80008590 <etext+0x590>
    80004174:	eb0fc0ef          	jal	80000824 <panic>

0000000080004178 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004178:	7139                	addi	sp,sp,-64
    8000417a:	fc06                	sd	ra,56(sp)
    8000417c:	f822                	sd	s0,48(sp)
    8000417e:	f426                	sd	s1,40(sp)
    80004180:	0080                	addi	s0,sp,64
    80004182:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004184:	0001e517          	auipc	a0,0x1e
    80004188:	d9c50513          	addi	a0,a0,-612 # 80021f20 <ftable>
    8000418c:	a9dfc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    80004190:	40dc                	lw	a5,4(s1)
    80004192:	04f05a63          	blez	a5,800041e6 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80004196:	37fd                	addiw	a5,a5,-1
    80004198:	c0dc                	sw	a5,4(s1)
    8000419a:	06f04063          	bgtz	a5,800041fa <fileclose+0x82>
    8000419e:	f04a                	sd	s2,32(sp)
    800041a0:	ec4e                	sd	s3,24(sp)
    800041a2:	e852                	sd	s4,16(sp)
    800041a4:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800041a6:	0004a903          	lw	s2,0(s1)
    800041aa:	0094c783          	lbu	a5,9(s1)
    800041ae:	89be                	mv	s3,a5
    800041b0:	689c                	ld	a5,16(s1)
    800041b2:	8a3e                	mv	s4,a5
    800041b4:	6c9c                	ld	a5,24(s1)
    800041b6:	8abe                	mv	s5,a5
  f->ref = 0;
    800041b8:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800041bc:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800041c0:	0001e517          	auipc	a0,0x1e
    800041c4:	d6050513          	addi	a0,a0,-672 # 80021f20 <ftable>
    800041c8:	af5fc0ef          	jal	80000cbc <release>

  if(ff.type == FD_PIPE){
    800041cc:	4785                	li	a5,1
    800041ce:	04f90163          	beq	s2,a5,80004210 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800041d2:	ffe9079b          	addiw	a5,s2,-2
    800041d6:	4705                	li	a4,1
    800041d8:	04f77563          	bgeu	a4,a5,80004222 <fileclose+0xaa>
    800041dc:	7902                	ld	s2,32(sp)
    800041de:	69e2                	ld	s3,24(sp)
    800041e0:	6a42                	ld	s4,16(sp)
    800041e2:	6aa2                	ld	s5,8(sp)
    800041e4:	a00d                	j	80004206 <fileclose+0x8e>
    800041e6:	f04a                	sd	s2,32(sp)
    800041e8:	ec4e                	sd	s3,24(sp)
    800041ea:	e852                	sd	s4,16(sp)
    800041ec:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800041ee:	00004517          	auipc	a0,0x4
    800041f2:	3aa50513          	addi	a0,a0,938 # 80008598 <etext+0x598>
    800041f6:	e2efc0ef          	jal	80000824 <panic>
    release(&ftable.lock);
    800041fa:	0001e517          	auipc	a0,0x1e
    800041fe:	d2650513          	addi	a0,a0,-730 # 80021f20 <ftable>
    80004202:	abbfc0ef          	jal	80000cbc <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004206:	70e2                	ld	ra,56(sp)
    80004208:	7442                	ld	s0,48(sp)
    8000420a:	74a2                	ld	s1,40(sp)
    8000420c:	6121                	addi	sp,sp,64
    8000420e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004210:	85ce                	mv	a1,s3
    80004212:	8552                	mv	a0,s4
    80004214:	40a000ef          	jal	8000461e <pipeclose>
    80004218:	7902                	ld	s2,32(sp)
    8000421a:	69e2                	ld	s3,24(sp)
    8000421c:	6a42                	ld	s4,16(sp)
    8000421e:	6aa2                	ld	s5,8(sp)
    80004220:	b7dd                	j	80004206 <fileclose+0x8e>
    begin_op();
    80004222:	ac3ff0ef          	jal	80003ce4 <begin_op>
    iput(ff.ip);
    80004226:	8556                	mv	a0,s5
    80004228:	a2eff0ef          	jal	80003456 <iput>
    end_op();
    8000422c:	b29ff0ef          	jal	80003d54 <end_op>
    80004230:	7902                	ld	s2,32(sp)
    80004232:	69e2                	ld	s3,24(sp)
    80004234:	6a42                	ld	s4,16(sp)
    80004236:	6aa2                	ld	s5,8(sp)
    80004238:	b7f9                	j	80004206 <fileclose+0x8e>

000000008000423a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000423a:	715d                	addi	sp,sp,-80
    8000423c:	e486                	sd	ra,72(sp)
    8000423e:	e0a2                	sd	s0,64(sp)
    80004240:	fc26                	sd	s1,56(sp)
    80004242:	f052                	sd	s4,32(sp)
    80004244:	0880                	addi	s0,sp,80
    80004246:	84aa                	mv	s1,a0
    80004248:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    8000424a:	eecfd0ef          	jal	80001936 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000424e:	409c                	lw	a5,0(s1)
    80004250:	37f9                	addiw	a5,a5,-2
    80004252:	4705                	li	a4,1
    80004254:	04f76263          	bltu	a4,a5,80004298 <filestat+0x5e>
    80004258:	f84a                	sd	s2,48(sp)
    8000425a:	f44e                	sd	s3,40(sp)
    8000425c:	89aa                	mv	s3,a0
    ilock(f->ip);
    8000425e:	6c88                	ld	a0,24(s1)
    80004260:	852ff0ef          	jal	800032b2 <ilock>
    stati(f->ip, &st);
    80004264:	fb840913          	addi	s2,s0,-72
    80004268:	85ca                	mv	a1,s2
    8000426a:	6c88                	ld	a0,24(s1)
    8000426c:	bd0ff0ef          	jal	8000363c <stati>
    iunlock(f->ip);
    80004270:	6c88                	ld	a0,24(s1)
    80004272:	910ff0ef          	jal	80003382 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004276:	46e1                	li	a3,24
    80004278:	864a                	mv	a2,s2
    8000427a:	85d2                	mv	a1,s4
    8000427c:	0509b503          	ld	a0,80(s3)
    80004280:	bdcfd0ef          	jal	8000165c <copyout>
    80004284:	41f5551b          	sraiw	a0,a0,0x1f
    80004288:	7942                	ld	s2,48(sp)
    8000428a:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    8000428c:	60a6                	ld	ra,72(sp)
    8000428e:	6406                	ld	s0,64(sp)
    80004290:	74e2                	ld	s1,56(sp)
    80004292:	7a02                	ld	s4,32(sp)
    80004294:	6161                	addi	sp,sp,80
    80004296:	8082                	ret
  return -1;
    80004298:	557d                	li	a0,-1
    8000429a:	bfcd                	j	8000428c <filestat+0x52>

000000008000429c <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000429c:	7139                	addi	sp,sp,-64
    8000429e:	fc06                	sd	ra,56(sp)
    800042a0:	f822                	sd	s0,48(sp)
    800042a2:	f426                	sd	s1,40(sp)
    800042a4:	f04a                	sd	s2,32(sp)
    800042a6:	ec4e                	sd	s3,24(sp)
    800042a8:	0080                	addi	s0,sp,64
    800042aa:	84aa                	mv	s1,a0
    800042ac:	892e                	mv	s2,a1
    800042ae:	89b2                	mv	s3,a2
  int r = 0;
  struct proc *p = myproc();
    800042b0:	e86fd0ef          	jal	80001936 <myproc>

  if(f->readable == 0)
    800042b4:	0084c783          	lbu	a5,8(s1)
    800042b8:	0e078b63          	beqz	a5,800043ae <fileread+0x112>
    800042bc:	e852                	sd	s4,16(sp)
    800042be:	8a2a                	mv	s4,a0
    return -1;

  // === NEW: PERMISSION CHECK (Ring 0 enforcement) ===
  if (f->type == FD_INODE) {
    800042c0:	4098                	lw	a4,0(s1)
    800042c2:	4789                	li	a5,2
    800042c4:	04f70863          	beq	a4,a5,80004314 <fileread+0x78>
      return -1;
    }
    iunlock(f->ip);
  }

  if(f->type == FD_PIPE){
    800042c8:	409c                	lw	a5,0(s1)
    800042ca:	4705                	li	a4,1
    800042cc:	08e78b63          	beq	a5,a4,80004362 <fileread+0xc6>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800042d0:	470d                	li	a4,3
    800042d2:	0ae78063          	beq	a5,a4,80004372 <fileread+0xd6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800042d6:	4709                	li	a4,2
    800042d8:	0ce79463          	bne	a5,a4,800043a0 <fileread+0x104>
    ilock(f->ip);
    800042dc:	6c88                	ld	a0,24(s1)
    800042de:	fd5fe0ef          	jal	800032b2 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800042e2:	874e                	mv	a4,s3
    800042e4:	5094                	lw	a3,32(s1)
    800042e6:	864a                	mv	a2,s2
    800042e8:	4585                	li	a1,1
    800042ea:	6c88                	ld	a0,24(s1)
    800042ec:	b7eff0ef          	jal	8000366a <readi>
    800042f0:	892a                	mv	s2,a0
    800042f2:	00a05563          	blez	a0,800042fc <fileread+0x60>
      f->off += r;
    800042f6:	509c                	lw	a5,32(s1)
    800042f8:	9fa9                	addw	a5,a5,a0
    800042fa:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800042fc:	6c88                	ld	a0,24(s1)
    800042fe:	884ff0ef          	jal	80003382 <iunlock>
    80004302:	6a42                	ld	s4,16(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004304:	854a                	mv	a0,s2
    80004306:	70e2                	ld	ra,56(sp)
    80004308:	7442                	ld	s0,48(sp)
    8000430a:	74a2                	ld	s1,40(sp)
    8000430c:	7902                	ld	s2,32(sp)
    8000430e:	69e2                	ld	s3,24(sp)
    80004310:	6121                	addi	sp,sp,64
    80004312:	8082                	ret
    80004314:	e456                	sd	s5,8(sp)
    ilock(f->ip);
    80004316:	6c88                	ld	a0,24(s1)
    80004318:	f9bfe0ef          	jal	800032b2 <ilock>
    if (check_permission(f->ip, 1 /*read*/, p->creds.uid, p->creds.gid) < 0) {
    8000431c:	6c88                	ld	a0,24(s1)
    8000431e:	8aaa                	mv	s5,a0
    80004320:	16ca2683          	lw	a3,364(s4)
    80004324:	168a2603          	lw	a2,360(s4)
    80004328:	4585                	li	a1,1
    8000432a:	d17ff0ef          	jal	80004040 <check_permission>
    8000432e:	00054763          	bltz	a0,8000433c <fileread+0xa0>
    iunlock(f->ip);
    80004332:	8556                	mv	a0,s5
    80004334:	84eff0ef          	jal	80003382 <iunlock>
    80004338:	6aa2                	ld	s5,8(sp)
    8000433a:	b779                	j	800042c8 <fileread+0x2c>
      iunlock(f->ip);
    8000433c:	8556                	mv	a0,s5
    8000433e:	844ff0ef          	jal	80003382 <iunlock>
      audit_log_event(p->pid, p->creds.uid, SYS_read, "DENIED:read_permission");
    80004342:	00004697          	auipc	a3,0x4
    80004346:	26668693          	addi	a3,a3,614 # 800085a8 <etext+0x5a8>
    8000434a:	4615                	li	a2,5
    8000434c:	168a2583          	lw	a1,360(s4)
    80004350:	030a2503          	lw	a0,48(s4)
    80004354:	290020ef          	jal	800065e4 <audit_log_event>
      return -1;
    80004358:	57fd                	li	a5,-1
    8000435a:	893e                	mv	s2,a5
    8000435c:	6a42                	ld	s4,16(sp)
    8000435e:	6aa2                	ld	s5,8(sp)
    80004360:	b755                	j	80004304 <fileread+0x68>
    r = piperead(f->pipe, addr, n);
    80004362:	864e                	mv	a2,s3
    80004364:	85ca                	mv	a1,s2
    80004366:	6888                	ld	a0,16(s1)
    80004368:	40c000ef          	jal	80004774 <piperead>
    8000436c:	892a                	mv	s2,a0
    8000436e:	6a42                	ld	s4,16(sp)
    80004370:	bf51                	j	80004304 <fileread+0x68>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004372:	02449783          	lh	a5,36(s1)
    80004376:	03079693          	slli	a3,a5,0x30
    8000437a:	92c1                	srli	a3,a3,0x30
    8000437c:	4725                	li	a4,9
    8000437e:	02d76b63          	bltu	a4,a3,800043b4 <fileread+0x118>
    80004382:	0792                	slli	a5,a5,0x4
    80004384:	0001e717          	auipc	a4,0x1e
    80004388:	afc70713          	addi	a4,a4,-1284 # 80021e80 <devsw>
    8000438c:	97ba                	add	a5,a5,a4
    8000438e:	639c                	ld	a5,0(a5)
    80004390:	c795                	beqz	a5,800043bc <fileread+0x120>
    r = devsw[f->major].read(1, addr, n);
    80004392:	864e                	mv	a2,s3
    80004394:	85ca                	mv	a1,s2
    80004396:	4505                	li	a0,1
    80004398:	9782                	jalr	a5
    8000439a:	892a                	mv	s2,a0
    8000439c:	6a42                	ld	s4,16(sp)
    8000439e:	b79d                	j	80004304 <fileread+0x68>
    800043a0:	e456                	sd	s5,8(sp)
    panic("fileread");
    800043a2:	00004517          	auipc	a0,0x4
    800043a6:	21e50513          	addi	a0,a0,542 # 800085c0 <etext+0x5c0>
    800043aa:	c7afc0ef          	jal	80000824 <panic>
    return -1;
    800043ae:	57fd                	li	a5,-1
    800043b0:	893e                	mv	s2,a5
    800043b2:	bf89                	j	80004304 <fileread+0x68>
      return -1;
    800043b4:	57fd                	li	a5,-1
    800043b6:	893e                	mv	s2,a5
    800043b8:	6a42                	ld	s4,16(sp)
    800043ba:	b7a9                	j	80004304 <fileread+0x68>
    800043bc:	57fd                	li	a5,-1
    800043be:	893e                	mv	s2,a5
    800043c0:	6a42                	ld	s4,16(sp)
    800043c2:	b789                	j	80004304 <fileread+0x68>

00000000800043c4 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800043c4:	711d                	addi	sp,sp,-96
    800043c6:	ec86                	sd	ra,88(sp)
    800043c8:	e8a2                	sd	s0,80(sp)
    800043ca:	e4a6                	sd	s1,72(sp)
    800043cc:	f456                	sd	s5,40(sp)
    800043ce:	f05a                	sd	s6,32(sp)
    800043d0:	1080                	addi	s0,sp,96
    800043d2:	84aa                	mv	s1,a0
    800043d4:	8b2e                	mv	s6,a1
    800043d6:	8ab2                	mv	s5,a2
  int r, ret = 0;
  struct proc *p = myproc();
    800043d8:	d5efd0ef          	jal	80001936 <myproc>

  if(f->writable == 0)
    800043dc:	0094c783          	lbu	a5,9(s1)
    800043e0:	14078f63          	beqz	a5,8000453e <filewrite+0x17a>
    800043e4:	e0ca                	sd	s2,64(sp)
    800043e6:	892a                	mv	s2,a0
    return -1;

  // === NEW: PERMISSION CHECK ===
  if (f->type == FD_INODE) {
    800043e8:	4098                	lw	a4,0(s1)
    800043ea:	4789                	li	a5,2
    800043ec:	02f70d63          	beq	a4,a5,80004426 <filewrite+0x62>
    }
    iunlock(f->ip);
  }
  // === END NEW ===

  if(f->type == FD_PIPE){
    800043f0:	409c                	lw	a5,0(s1)
    800043f2:	4705                	li	a4,1
    800043f4:	08e78063          	beq	a5,a4,80004474 <filewrite+0xb0>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800043f8:	470d                	li	a4,3
    800043fa:	08e78463          	beq	a5,a4,80004482 <filewrite+0xbe>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800043fe:	4709                	li	a4,2
    80004400:	12e79463          	bne	a5,a4,80004528 <filewrite+0x164>
    80004404:	f852                	sd	s4,48(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004406:	0f505f63          	blez	s5,80004504 <filewrite+0x140>
    8000440a:	fc4e                	sd	s3,56(sp)
    8000440c:	ec5e                	sd	s7,24(sp)
    8000440e:	e862                	sd	s8,16(sp)
    80004410:	e466                	sd	s9,8(sp)
    int i = 0;
    80004412:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    80004414:	6b85                	lui	s7,0x1
    80004416:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000441a:	6785                	lui	a5,0x1
    8000441c:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    80004420:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004422:	4c05                	li	s8,1
    80004424:	a0e1                	j	800044ec <filewrite+0x128>
    80004426:	fc4e                	sd	s3,56(sp)
    ilock(f->ip);
    80004428:	6c88                	ld	a0,24(s1)
    8000442a:	e89fe0ef          	jal	800032b2 <ilock>
    if (check_permission(f->ip, 2 /*write*/, p->creds.uid, p->creds.gid) < 0) {
    8000442e:	0184b983          	ld	s3,24(s1)
    80004432:	16c92683          	lw	a3,364(s2)
    80004436:	16892603          	lw	a2,360(s2)
    8000443a:	4589                	li	a1,2
    8000443c:	854e                	mv	a0,s3
    8000443e:	c03ff0ef          	jal	80004040 <check_permission>
    80004442:	00054763          	bltz	a0,80004450 <filewrite+0x8c>
    iunlock(f->ip);
    80004446:	854e                	mv	a0,s3
    80004448:	f3bfe0ef          	jal	80003382 <iunlock>
    8000444c:	79e2                	ld	s3,56(sp)
    8000444e:	b74d                	j	800043f0 <filewrite+0x2c>
      iunlock(f->ip);
    80004450:	854e                	mv	a0,s3
    80004452:	f31fe0ef          	jal	80003382 <iunlock>
      audit_log_event(p->pid, p->creds.uid, SYS_write, "DENIED:write_permission");
    80004456:	00004697          	auipc	a3,0x4
    8000445a:	17a68693          	addi	a3,a3,378 # 800085d0 <etext+0x5d0>
    8000445e:	4641                	li	a2,16
    80004460:	16892583          	lw	a1,360(s2)
    80004464:	03092503          	lw	a0,48(s2)
    80004468:	17c020ef          	jal	800065e4 <audit_log_event>
      return -1;
    8000446c:	557d                	li	a0,-1
    8000446e:	6906                	ld	s2,64(sp)
    80004470:	79e2                	ld	s3,56(sp)
    80004472:	a065                	j	8000451a <filewrite+0x156>
    ret = pipewrite(f->pipe, addr, n);
    80004474:	8656                	mv	a2,s5
    80004476:	85da                	mv	a1,s6
    80004478:	6888                	ld	a0,16(s1)
    8000447a:	202000ef          	jal	8000467c <pipewrite>
    8000447e:	6906                	ld	s2,64(sp)
    80004480:	a869                	j	8000451a <filewrite+0x156>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004482:	02449783          	lh	a5,36(s1)
    80004486:	03079693          	slli	a3,a5,0x30
    8000448a:	92c1                	srli	a3,a3,0x30
    8000448c:	4725                	li	a4,9
    8000448e:	0ad76a63          	bltu	a4,a3,80004542 <filewrite+0x17e>
    80004492:	0792                	slli	a5,a5,0x4
    80004494:	0001e717          	auipc	a4,0x1e
    80004498:	9ec70713          	addi	a4,a4,-1556 # 80021e80 <devsw>
    8000449c:	97ba                	add	a5,a5,a4
    8000449e:	679c                	ld	a5,8(a5)
    800044a0:	c7c5                	beqz	a5,80004548 <filewrite+0x184>
    ret = devsw[f->major].write(1, addr, n);
    800044a2:	8656                	mv	a2,s5
    800044a4:	85da                	mv	a1,s6
    800044a6:	4505                	li	a0,1
    800044a8:	9782                	jalr	a5
    800044aa:	6906                	ld	s2,64(sp)
    800044ac:	a0bd                	j	8000451a <filewrite+0x156>
      if(n1 > max)
    800044ae:	2981                	sext.w	s3,s3
      begin_op();
    800044b0:	835ff0ef          	jal	80003ce4 <begin_op>
      ilock(f->ip);
    800044b4:	6c88                	ld	a0,24(s1)
    800044b6:	dfdfe0ef          	jal	800032b2 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800044ba:	874e                	mv	a4,s3
    800044bc:	5094                	lw	a3,32(s1)
    800044be:	016a0633          	add	a2,s4,s6
    800044c2:	85e2                	mv	a1,s8
    800044c4:	6c88                	ld	a0,24(s1)
    800044c6:	a96ff0ef          	jal	8000375c <writei>
    800044ca:	892a                	mv	s2,a0
    800044cc:	00a05563          	blez	a0,800044d6 <filewrite+0x112>
        f->off += r;
    800044d0:	509c                	lw	a5,32(s1)
    800044d2:	9fa9                	addw	a5,a5,a0
    800044d4:	d09c                	sw	a5,32(s1)
      iunlock(f->ip);
    800044d6:	6c88                	ld	a0,24(s1)
    800044d8:	eabfe0ef          	jal	80003382 <iunlock>
      end_op();
    800044dc:	879ff0ef          	jal	80003d54 <end_op>

      if(r != n1){
    800044e0:	03299463          	bne	s3,s2,80004508 <filewrite+0x144>
        // error from writei
        break;
      }
      i += r;
    800044e4:	01490a3b          	addw	s4,s2,s4
    while(i < n){
    800044e8:	015a5963          	bge	s4,s5,800044fa <filewrite+0x136>
      int n1 = n - i;
    800044ec:	414a87bb          	subw	a5,s5,s4
    800044f0:	89be                	mv	s3,a5
      if(n1 > max)
    800044f2:	fafbdee3          	bge	s7,a5,800044ae <filewrite+0xea>
    800044f6:	89e6                	mv	s3,s9
    800044f8:	bf5d                	j	800044ae <filewrite+0xea>
    800044fa:	79e2                	ld	s3,56(sp)
    800044fc:	6be2                	ld	s7,24(sp)
    800044fe:	6c42                	ld	s8,16(sp)
    80004500:	6ca2                	ld	s9,8(sp)
    80004502:	a039                	j	80004510 <filewrite+0x14c>
    int i = 0;
    80004504:	4a01                	li	s4,0
    80004506:	a029                	j	80004510 <filewrite+0x14c>
    80004508:	79e2                	ld	s3,56(sp)
    8000450a:	6be2                	ld	s7,24(sp)
    8000450c:	6c42                	ld	s8,16(sp)
    8000450e:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    80004510:	034a9f63          	bne	s5,s4,8000454e <filewrite+0x18a>
    80004514:	8556                	mv	a0,s5
    80004516:	6906                	ld	s2,64(sp)
    80004518:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000451a:	60e6                	ld	ra,88(sp)
    8000451c:	6446                	ld	s0,80(sp)
    8000451e:	64a6                	ld	s1,72(sp)
    80004520:	7aa2                	ld	s5,40(sp)
    80004522:	7b02                	ld	s6,32(sp)
    80004524:	6125                	addi	sp,sp,96
    80004526:	8082                	ret
    80004528:	fc4e                	sd	s3,56(sp)
    8000452a:	f852                	sd	s4,48(sp)
    8000452c:	ec5e                	sd	s7,24(sp)
    8000452e:	e862                	sd	s8,16(sp)
    80004530:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80004532:	00004517          	auipc	a0,0x4
    80004536:	0b650513          	addi	a0,a0,182 # 800085e8 <etext+0x5e8>
    8000453a:	aeafc0ef          	jal	80000824 <panic>
    return -1;
    8000453e:	557d                	li	a0,-1
    80004540:	bfe9                	j	8000451a <filewrite+0x156>
      return -1;
    80004542:	557d                	li	a0,-1
    80004544:	6906                	ld	s2,64(sp)
    80004546:	bfd1                	j	8000451a <filewrite+0x156>
    80004548:	557d                	li	a0,-1
    8000454a:	6906                	ld	s2,64(sp)
    8000454c:	b7f9                	j	8000451a <filewrite+0x156>
    ret = (i == n ? n : -1);
    8000454e:	557d                	li	a0,-1
    80004550:	6906                	ld	s2,64(sp)
    80004552:	7a42                	ld	s4,48(sp)
    80004554:	b7d9                	j	8000451a <filewrite+0x156>

0000000080004556 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004556:	7179                	addi	sp,sp,-48
    80004558:	f406                	sd	ra,40(sp)
    8000455a:	f022                	sd	s0,32(sp)
    8000455c:	ec26                	sd	s1,24(sp)
    8000455e:	e052                	sd	s4,0(sp)
    80004560:	1800                	addi	s0,sp,48
    80004562:	84aa                	mv	s1,a0
    80004564:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004566:	0005b023          	sd	zero,0(a1)
    8000456a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000456e:	b67ff0ef          	jal	800040d4 <filealloc>
    80004572:	e088                	sd	a0,0(s1)
    80004574:	c549                	beqz	a0,800045fe <pipealloc+0xa8>
    80004576:	b5fff0ef          	jal	800040d4 <filealloc>
    8000457a:	00aa3023          	sd	a0,0(s4)
    8000457e:	cd25                	beqz	a0,800045f6 <pipealloc+0xa0>
    80004580:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004582:	dc2fc0ef          	jal	80000b44 <kalloc>
    80004586:	892a                	mv	s2,a0
    80004588:	c12d                	beqz	a0,800045ea <pipealloc+0x94>
    8000458a:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    8000458c:	4985                	li	s3,1
    8000458e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004592:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004596:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000459a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000459e:	00004597          	auipc	a1,0x4
    800045a2:	05a58593          	addi	a1,a1,90 # 800085f8 <etext+0x5f8>
    800045a6:	df8fc0ef          	jal	80000b9e <initlock>
  (*f0)->type = FD_PIPE;
    800045aa:	609c                	ld	a5,0(s1)
    800045ac:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800045b0:	609c                	ld	a5,0(s1)
    800045b2:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800045b6:	609c                	ld	a5,0(s1)
    800045b8:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800045bc:	609c                	ld	a5,0(s1)
    800045be:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800045c2:	000a3783          	ld	a5,0(s4)
    800045c6:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800045ca:	000a3783          	ld	a5,0(s4)
    800045ce:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800045d2:	000a3783          	ld	a5,0(s4)
    800045d6:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800045da:	000a3783          	ld	a5,0(s4)
    800045de:	0127b823          	sd	s2,16(a5)
  return 0;
    800045e2:	4501                	li	a0,0
    800045e4:	6942                	ld	s2,16(sp)
    800045e6:	69a2                	ld	s3,8(sp)
    800045e8:	a01d                	j	8000460e <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800045ea:	6088                	ld	a0,0(s1)
    800045ec:	c119                	beqz	a0,800045f2 <pipealloc+0x9c>
    800045ee:	6942                	ld	s2,16(sp)
    800045f0:	a029                	j	800045fa <pipealloc+0xa4>
    800045f2:	6942                	ld	s2,16(sp)
    800045f4:	a029                	j	800045fe <pipealloc+0xa8>
    800045f6:	6088                	ld	a0,0(s1)
    800045f8:	c10d                	beqz	a0,8000461a <pipealloc+0xc4>
    fileclose(*f0);
    800045fa:	b7fff0ef          	jal	80004178 <fileclose>
  if(*f1)
    800045fe:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004602:	557d                	li	a0,-1
  if(*f1)
    80004604:	c789                	beqz	a5,8000460e <pipealloc+0xb8>
    fileclose(*f1);
    80004606:	853e                	mv	a0,a5
    80004608:	b71ff0ef          	jal	80004178 <fileclose>
  return -1;
    8000460c:	557d                	li	a0,-1
}
    8000460e:	70a2                	ld	ra,40(sp)
    80004610:	7402                	ld	s0,32(sp)
    80004612:	64e2                	ld	s1,24(sp)
    80004614:	6a02                	ld	s4,0(sp)
    80004616:	6145                	addi	sp,sp,48
    80004618:	8082                	ret
  return -1;
    8000461a:	557d                	li	a0,-1
    8000461c:	bfcd                	j	8000460e <pipealloc+0xb8>

000000008000461e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000461e:	1101                	addi	sp,sp,-32
    80004620:	ec06                	sd	ra,24(sp)
    80004622:	e822                	sd	s0,16(sp)
    80004624:	e426                	sd	s1,8(sp)
    80004626:	e04a                	sd	s2,0(sp)
    80004628:	1000                	addi	s0,sp,32
    8000462a:	84aa                	mv	s1,a0
    8000462c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000462e:	dfafc0ef          	jal	80000c28 <acquire>
  if(writable){
    80004632:	02090763          	beqz	s2,80004660 <pipeclose+0x42>
    pi->writeopen = 0;
    80004636:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000463a:	21848513          	addi	a0,s1,536
    8000463e:	9a1fd0ef          	jal	80001fde <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004642:	2204a783          	lw	a5,544(s1)
    80004646:	e781                	bnez	a5,8000464e <pipeclose+0x30>
    80004648:	2244a783          	lw	a5,548(s1)
    8000464c:	c38d                	beqz	a5,8000466e <pipeclose+0x50>
    release(&pi->lock);
    kfree((char*)pi);
  } else
    release(&pi->lock);
    8000464e:	8526                	mv	a0,s1
    80004650:	e6cfc0ef          	jal	80000cbc <release>
}
    80004654:	60e2                	ld	ra,24(sp)
    80004656:	6442                	ld	s0,16(sp)
    80004658:	64a2                	ld	s1,8(sp)
    8000465a:	6902                	ld	s2,0(sp)
    8000465c:	6105                	addi	sp,sp,32
    8000465e:	8082                	ret
    pi->readopen = 0;
    80004660:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004664:	21c48513          	addi	a0,s1,540
    80004668:	977fd0ef          	jal	80001fde <wakeup>
    8000466c:	bfd9                	j	80004642 <pipeclose+0x24>
    release(&pi->lock);
    8000466e:	8526                	mv	a0,s1
    80004670:	e4cfc0ef          	jal	80000cbc <release>
    kfree((char*)pi);
    80004674:	8526                	mv	a0,s1
    80004676:	be6fc0ef          	jal	80000a5c <kfree>
    8000467a:	bfe9                	j	80004654 <pipeclose+0x36>

000000008000467c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000467c:	7159                	addi	sp,sp,-112
    8000467e:	f486                	sd	ra,104(sp)
    80004680:	f0a2                	sd	s0,96(sp)
    80004682:	eca6                	sd	s1,88(sp)
    80004684:	e8ca                	sd	s2,80(sp)
    80004686:	e4ce                	sd	s3,72(sp)
    80004688:	e0d2                	sd	s4,64(sp)
    8000468a:	fc56                	sd	s5,56(sp)
    8000468c:	1880                	addi	s0,sp,112
    8000468e:	84aa                	mv	s1,a0
    80004690:	8aae                	mv	s5,a1
    80004692:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004694:	aa2fd0ef          	jal	80001936 <myproc>
    80004698:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000469a:	8526                	mv	a0,s1
    8000469c:	d8cfc0ef          	jal	80000c28 <acquire>
  while(i < n){
    800046a0:	0d405263          	blez	s4,80004764 <pipewrite+0xe8>
    800046a4:	f85a                	sd	s6,48(sp)
    800046a6:	f45e                	sd	s7,40(sp)
    800046a8:	f062                	sd	s8,32(sp)
    800046aa:	ec66                	sd	s9,24(sp)
    800046ac:	e86a                	sd	s10,16(sp)
  int i = 0;
    800046ae:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800046b0:	f9f40c13          	addi	s8,s0,-97
    800046b4:	4b85                	li	s7,1
    800046b6:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800046b8:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800046bc:	21c48c93          	addi	s9,s1,540
    800046c0:	a82d                	j	800046fa <pipewrite+0x7e>
      release(&pi->lock);
    800046c2:	8526                	mv	a0,s1
    800046c4:	df8fc0ef          	jal	80000cbc <release>
      return -1;
    800046c8:	597d                	li	s2,-1
    800046ca:	7b42                	ld	s6,48(sp)
    800046cc:	7ba2                	ld	s7,40(sp)
    800046ce:	7c02                	ld	s8,32(sp)
    800046d0:	6ce2                	ld	s9,24(sp)
    800046d2:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800046d4:	854a                	mv	a0,s2
    800046d6:	70a6                	ld	ra,104(sp)
    800046d8:	7406                	ld	s0,96(sp)
    800046da:	64e6                	ld	s1,88(sp)
    800046dc:	6946                	ld	s2,80(sp)
    800046de:	69a6                	ld	s3,72(sp)
    800046e0:	6a06                	ld	s4,64(sp)
    800046e2:	7ae2                	ld	s5,56(sp)
    800046e4:	6165                	addi	sp,sp,112
    800046e6:	8082                	ret
      wakeup(&pi->nread);
    800046e8:	856a                	mv	a0,s10
    800046ea:	8f5fd0ef          	jal	80001fde <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800046ee:	85a6                	mv	a1,s1
    800046f0:	8566                	mv	a0,s9
    800046f2:	8a1fd0ef          	jal	80001f92 <sleep>
  while(i < n){
    800046f6:	05495a63          	bge	s2,s4,8000474a <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    800046fa:	2204a783          	lw	a5,544(s1)
    800046fe:	d3f1                	beqz	a5,800046c2 <pipewrite+0x46>
    80004700:	854e                	mv	a0,s3
    80004702:	acdfd0ef          	jal	800021ce <killed>
    80004706:	fd55                	bnez	a0,800046c2 <pipewrite+0x46>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004708:	2184a783          	lw	a5,536(s1)
    8000470c:	21c4a703          	lw	a4,540(s1)
    80004710:	2007879b          	addiw	a5,a5,512
    80004714:	fcf70ae3          	beq	a4,a5,800046e8 <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004718:	86de                	mv	a3,s7
    8000471a:	01590633          	add	a2,s2,s5
    8000471e:	85e2                	mv	a1,s8
    80004720:	0509b503          	ld	a0,80(s3)
    80004724:	ff7fc0ef          	jal	8000171a <copyin>
    80004728:	05650063          	beq	a0,s6,80004768 <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000472c:	21c4a783          	lw	a5,540(s1)
    80004730:	0017871b          	addiw	a4,a5,1
    80004734:	20e4ae23          	sw	a4,540(s1)
    80004738:	1ff7f793          	andi	a5,a5,511
    8000473c:	97a6                	add	a5,a5,s1
    8000473e:	f9f44703          	lbu	a4,-97(s0)
    80004742:	00e78c23          	sb	a4,24(a5)
      i++;
    80004746:	2905                	addiw	s2,s2,1
    80004748:	b77d                	j	800046f6 <pipewrite+0x7a>
    8000474a:	7b42                	ld	s6,48(sp)
    8000474c:	7ba2                	ld	s7,40(sp)
    8000474e:	7c02                	ld	s8,32(sp)
    80004750:	6ce2                	ld	s9,24(sp)
    80004752:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004754:	21848513          	addi	a0,s1,536
    80004758:	887fd0ef          	jal	80001fde <wakeup>
  release(&pi->lock);
    8000475c:	8526                	mv	a0,s1
    8000475e:	d5efc0ef          	jal	80000cbc <release>
  return i;
    80004762:	bf8d                	j	800046d4 <pipewrite+0x58>
  int i = 0;
    80004764:	4901                	li	s2,0
    80004766:	b7fd                	j	80004754 <pipewrite+0xd8>
    80004768:	7b42                	ld	s6,48(sp)
    8000476a:	7ba2                	ld	s7,40(sp)
    8000476c:	7c02                	ld	s8,32(sp)
    8000476e:	6ce2                	ld	s9,24(sp)
    80004770:	6d42                	ld	s10,16(sp)
    80004772:	b7cd                	j	80004754 <pipewrite+0xd8>

0000000080004774 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004774:	711d                	addi	sp,sp,-96
    80004776:	ec86                	sd	ra,88(sp)
    80004778:	e8a2                	sd	s0,80(sp)
    8000477a:	e4a6                	sd	s1,72(sp)
    8000477c:	e0ca                	sd	s2,64(sp)
    8000477e:	fc4e                	sd	s3,56(sp)
    80004780:	f852                	sd	s4,48(sp)
    80004782:	f456                	sd	s5,40(sp)
    80004784:	1080                	addi	s0,sp,96
    80004786:	84aa                	mv	s1,a0
    80004788:	892e                	mv	s2,a1
    8000478a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000478c:	9aafd0ef          	jal	80001936 <myproc>
    80004790:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004792:	8526                	mv	a0,s1
    80004794:	c94fc0ef          	jal	80000c28 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004798:	2184a703          	lw	a4,536(s1)
    8000479c:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800047a0:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800047a4:	02f71763          	bne	a4,a5,800047d2 <piperead+0x5e>
    800047a8:	2244a783          	lw	a5,548(s1)
    800047ac:	cf85                	beqz	a5,800047e4 <piperead+0x70>
    if(killed(pr)){
    800047ae:	8552                	mv	a0,s4
    800047b0:	a1ffd0ef          	jal	800021ce <killed>
    800047b4:	e11d                	bnez	a0,800047da <piperead+0x66>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800047b6:	85a6                	mv	a1,s1
    800047b8:	854e                	mv	a0,s3
    800047ba:	fd8fd0ef          	jal	80001f92 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800047be:	2184a703          	lw	a4,536(s1)
    800047c2:	21c4a783          	lw	a5,540(s1)
    800047c6:	fef701e3          	beq	a4,a5,800047a8 <piperead+0x34>
    800047ca:	f05a                	sd	s6,32(sp)
    800047cc:	ec5e                	sd	s7,24(sp)
    800047ce:	e862                	sd	s8,16(sp)
    800047d0:	a829                	j	800047ea <piperead+0x76>
    800047d2:	f05a                	sd	s6,32(sp)
    800047d4:	ec5e                	sd	s7,24(sp)
    800047d6:	e862                	sd	s8,16(sp)
    800047d8:	a809                	j	800047ea <piperead+0x76>
      release(&pi->lock);
    800047da:	8526                	mv	a0,s1
    800047dc:	ce0fc0ef          	jal	80000cbc <release>
      return -1;
    800047e0:	59fd                	li	s3,-1
    800047e2:	a0a5                	j	8000484a <piperead+0xd6>
    800047e4:	f05a                	sd	s6,32(sp)
    800047e6:	ec5e                	sd	s7,24(sp)
    800047e8:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800047ea:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800047ec:	faf40c13          	addi	s8,s0,-81
    800047f0:	4b85                	li	s7,1
    800047f2:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800047f4:	05505163          	blez	s5,80004836 <piperead+0xc2>
    if(pi->nread == pi->nwrite)
    800047f8:	2184a783          	lw	a5,536(s1)
    800047fc:	21c4a703          	lw	a4,540(s1)
    80004800:	02f70b63          	beq	a4,a5,80004836 <piperead+0xc2>
    ch = pi->data[pi->nread % PIPESIZE];
    80004804:	1ff7f793          	andi	a5,a5,511
    80004808:	97a6                	add	a5,a5,s1
    8000480a:	0187c783          	lbu	a5,24(a5)
    8000480e:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004812:	86de                	mv	a3,s7
    80004814:	8662                	mv	a2,s8
    80004816:	85ca                	mv	a1,s2
    80004818:	050a3503          	ld	a0,80(s4)
    8000481c:	e41fc0ef          	jal	8000165c <copyout>
    80004820:	03650f63          	beq	a0,s6,8000485e <piperead+0xea>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004824:	2184a783          	lw	a5,536(s1)
    80004828:	2785                	addiw	a5,a5,1
    8000482a:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000482e:	2985                	addiw	s3,s3,1
    80004830:	0905                	addi	s2,s2,1
    80004832:	fd3a93e3          	bne	s5,s3,800047f8 <piperead+0x84>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004836:	21c48513          	addi	a0,s1,540
    8000483a:	fa4fd0ef          	jal	80001fde <wakeup>
  release(&pi->lock);
    8000483e:	8526                	mv	a0,s1
    80004840:	c7cfc0ef          	jal	80000cbc <release>
    80004844:	7b02                	ld	s6,32(sp)
    80004846:	6be2                	ld	s7,24(sp)
    80004848:	6c42                	ld	s8,16(sp)
  return i;
}
    8000484a:	854e                	mv	a0,s3
    8000484c:	60e6                	ld	ra,88(sp)
    8000484e:	6446                	ld	s0,80(sp)
    80004850:	64a6                	ld	s1,72(sp)
    80004852:	6906                	ld	s2,64(sp)
    80004854:	79e2                	ld	s3,56(sp)
    80004856:	7a42                	ld	s4,48(sp)
    80004858:	7aa2                	ld	s5,40(sp)
    8000485a:	6125                	addi	sp,sp,96
    8000485c:	8082                	ret
      if(i == 0)
    8000485e:	fc099ce3          	bnez	s3,80004836 <piperead+0xc2>
        i = -1;
    80004862:	89aa                	mv	s3,a0
    80004864:	bfc9                	j	80004836 <piperead+0xc2>

0000000080004866 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004866:	1141                	addi	sp,sp,-16
    80004868:	e406                	sd	ra,8(sp)
    8000486a:	e022                	sd	s0,0(sp)
    8000486c:	0800                	addi	s0,sp,16
    8000486e:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004870:	0035151b          	slliw	a0,a0,0x3
    80004874:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    80004876:	8b89                	andi	a5,a5,2
    80004878:	c399                	beqz	a5,8000487e <flags2perm+0x18>
      perm |= PTE_W;
    8000487a:	00456513          	ori	a0,a0,4
    return perm;
}
    8000487e:	60a2                	ld	ra,8(sp)
    80004880:	6402                	ld	s0,0(sp)
    80004882:	0141                	addi	sp,sp,16
    80004884:	8082                	ret

0000000080004886 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004886:	de010113          	addi	sp,sp,-544
    8000488a:	20113c23          	sd	ra,536(sp)
    8000488e:	20813823          	sd	s0,528(sp)
    80004892:	20913423          	sd	s1,520(sp)
    80004896:	21213023          	sd	s2,512(sp)
    8000489a:	1400                	addi	s0,sp,544
    8000489c:	892a                	mv	s2,a0
    8000489e:	dea43823          	sd	a0,-528(s0)
    800048a2:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800048a6:	890fd0ef          	jal	80001936 <myproc>
    800048aa:	84aa                	mv	s1,a0

  begin_op();
    800048ac:	c38ff0ef          	jal	80003ce4 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    800048b0:	854a                	mv	a0,s2
    800048b2:	a54ff0ef          	jal	80003b06 <namei>
    800048b6:	cd21                	beqz	a0,8000490e <kexec+0x88>
    800048b8:	fbd2                	sd	s4,496(sp)
    800048ba:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800048bc:	9f7fe0ef          	jal	800032b2 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800048c0:	04000713          	li	a4,64
    800048c4:	4681                	li	a3,0
    800048c6:	e5040613          	addi	a2,s0,-432
    800048ca:	4581                	li	a1,0
    800048cc:	8552                	mv	a0,s4
    800048ce:	d9dfe0ef          	jal	8000366a <readi>
    800048d2:	04000793          	li	a5,64
    800048d6:	00f51a63          	bne	a0,a5,800048ea <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    800048da:	e5042703          	lw	a4,-432(s0)
    800048de:	464c47b7          	lui	a5,0x464c4
    800048e2:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800048e6:	02f70863          	beq	a4,a5,80004916 <kexec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800048ea:	8552                	mv	a0,s4
    800048ec:	bf5fe0ef          	jal	800034e0 <iunlockput>
    end_op();
    800048f0:	c64ff0ef          	jal	80003d54 <end_op>
  }
  return -1;
    800048f4:	557d                	li	a0,-1
    800048f6:	7a5e                	ld	s4,496(sp)
}
    800048f8:	21813083          	ld	ra,536(sp)
    800048fc:	21013403          	ld	s0,528(sp)
    80004900:	20813483          	ld	s1,520(sp)
    80004904:	20013903          	ld	s2,512(sp)
    80004908:	22010113          	addi	sp,sp,544
    8000490c:	8082                	ret
    end_op();
    8000490e:	c46ff0ef          	jal	80003d54 <end_op>
    return -1;
    80004912:	557d                	li	a0,-1
    80004914:	b7d5                	j	800048f8 <kexec+0x72>
    80004916:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004918:	8526                	mv	a0,s1
    8000491a:	926fd0ef          	jal	80001a40 <proc_pagetable>
    8000491e:	8b2a                	mv	s6,a0
    80004920:	26050f63          	beqz	a0,80004b9e <kexec+0x318>
    80004924:	ffce                	sd	s3,504(sp)
    80004926:	f7d6                	sd	s5,488(sp)
    80004928:	efde                	sd	s7,472(sp)
    8000492a:	ebe2                	sd	s8,464(sp)
    8000492c:	e7e6                	sd	s9,456(sp)
    8000492e:	e3ea                	sd	s10,448(sp)
    80004930:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004932:	e8845783          	lhu	a5,-376(s0)
    80004936:	0e078963          	beqz	a5,80004a28 <kexec+0x1a2>
    8000493a:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000493e:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004940:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004942:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    80004946:	6c85                	lui	s9,0x1
    80004948:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000494c:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004950:	6a85                	lui	s5,0x1
    80004952:	a085                	j	800049b2 <kexec+0x12c>
      panic("loadseg: address should exist");
    80004954:	00004517          	auipc	a0,0x4
    80004958:	cac50513          	addi	a0,a0,-852 # 80008600 <etext+0x600>
    8000495c:	ec9fb0ef          	jal	80000824 <panic>
    if(sz - i < PGSIZE)
    80004960:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004962:	874a                	mv	a4,s2
    80004964:	009b86bb          	addw	a3,s7,s1
    80004968:	4581                	li	a1,0
    8000496a:	8552                	mv	a0,s4
    8000496c:	cfffe0ef          	jal	8000366a <readi>
    80004970:	22a91b63          	bne	s2,a0,80004ba6 <kexec+0x320>
  for(i = 0; i < sz; i += PGSIZE){
    80004974:	009a84bb          	addw	s1,s5,s1
    80004978:	0334f263          	bgeu	s1,s3,8000499c <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    8000497c:	02049593          	slli	a1,s1,0x20
    80004980:	9181                	srli	a1,a1,0x20
    80004982:	95e2                	add	a1,a1,s8
    80004984:	855a                	mv	a0,s6
    80004986:	ea8fc0ef          	jal	8000102e <walkaddr>
    8000498a:	862a                	mv	a2,a0
    if(pa == 0)
    8000498c:	d561                	beqz	a0,80004954 <kexec+0xce>
    if(sz - i < PGSIZE)
    8000498e:	409987bb          	subw	a5,s3,s1
    80004992:	893e                	mv	s2,a5
    80004994:	fcfcf6e3          	bgeu	s9,a5,80004960 <kexec+0xda>
    80004998:	8956                	mv	s2,s5
    8000499a:	b7d9                	j	80004960 <kexec+0xda>
    sz = sz1;
    8000499c:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800049a0:	2d05                	addiw	s10,s10,1
    800049a2:	e0843783          	ld	a5,-504(s0)
    800049a6:	0387869b          	addiw	a3,a5,56
    800049aa:	e8845783          	lhu	a5,-376(s0)
    800049ae:	06fd5e63          	bge	s10,a5,80004a2a <kexec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800049b2:	e0d43423          	sd	a3,-504(s0)
    800049b6:	876e                	mv	a4,s11
    800049b8:	e1840613          	addi	a2,s0,-488
    800049bc:	4581                	li	a1,0
    800049be:	8552                	mv	a0,s4
    800049c0:	cabfe0ef          	jal	8000366a <readi>
    800049c4:	1db51f63          	bne	a0,s11,80004ba2 <kexec+0x31c>
    if(ph.type != ELF_PROG_LOAD)
    800049c8:	e1842783          	lw	a5,-488(s0)
    800049cc:	4705                	li	a4,1
    800049ce:	fce799e3          	bne	a5,a4,800049a0 <kexec+0x11a>
    if(ph.memsz < ph.filesz)
    800049d2:	e4043483          	ld	s1,-448(s0)
    800049d6:	e3843783          	ld	a5,-456(s0)
    800049da:	1ef4e463          	bltu	s1,a5,80004bc2 <kexec+0x33c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800049de:	e2843783          	ld	a5,-472(s0)
    800049e2:	94be                	add	s1,s1,a5
    800049e4:	1ef4e263          	bltu	s1,a5,80004bc8 <kexec+0x342>
    if(ph.vaddr % PGSIZE != 0)
    800049e8:	de843703          	ld	a4,-536(s0)
    800049ec:	8ff9                	and	a5,a5,a4
    800049ee:	1e079063          	bnez	a5,80004bce <kexec+0x348>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800049f2:	e1c42503          	lw	a0,-484(s0)
    800049f6:	e71ff0ef          	jal	80004866 <flags2perm>
    800049fa:	86aa                	mv	a3,a0
    800049fc:	8626                	mv	a2,s1
    800049fe:	85ca                	mv	a1,s2
    80004a00:	855a                	mv	a0,s6
    80004a02:	903fc0ef          	jal	80001304 <uvmalloc>
    80004a06:	dea43c23          	sd	a0,-520(s0)
    80004a0a:	1c050563          	beqz	a0,80004bd4 <kexec+0x34e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004a0e:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004a12:	00098863          	beqz	s3,80004a22 <kexec+0x19c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004a16:	e2843c03          	ld	s8,-472(s0)
    80004a1a:	e2042b83          	lw	s7,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004a1e:	4481                	li	s1,0
    80004a20:	bfb1                	j	8000497c <kexec+0xf6>
    sz = sz1;
    80004a22:	df843903          	ld	s2,-520(s0)
    80004a26:	bfad                	j	800049a0 <kexec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004a28:	4901                	li	s2,0
  iunlockput(ip);
    80004a2a:	8552                	mv	a0,s4
    80004a2c:	ab5fe0ef          	jal	800034e0 <iunlockput>
  end_op();
    80004a30:	b24ff0ef          	jal	80003d54 <end_op>
  p = myproc();
    80004a34:	f03fc0ef          	jal	80001936 <myproc>
    80004a38:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004a3a:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004a3e:	6985                	lui	s3,0x1
    80004a40:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004a42:	99ca                	add	s3,s3,s2
    80004a44:	77fd                	lui	a5,0xfffff
    80004a46:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004a4a:	4691                	li	a3,4
    80004a4c:	6609                	lui	a2,0x2
    80004a4e:	964e                	add	a2,a2,s3
    80004a50:	85ce                	mv	a1,s3
    80004a52:	855a                	mv	a0,s6
    80004a54:	8b1fc0ef          	jal	80001304 <uvmalloc>
    80004a58:	8a2a                	mv	s4,a0
    80004a5a:	e105                	bnez	a0,80004a7a <kexec+0x1f4>
    proc_freepagetable(pagetable, sz);
    80004a5c:	85ce                	mv	a1,s3
    80004a5e:	855a                	mv	a0,s6
    80004a60:	864fd0ef          	jal	80001ac4 <proc_freepagetable>
  return -1;
    80004a64:	557d                	li	a0,-1
    80004a66:	79fe                	ld	s3,504(sp)
    80004a68:	7a5e                	ld	s4,496(sp)
    80004a6a:	7abe                	ld	s5,488(sp)
    80004a6c:	7b1e                	ld	s6,480(sp)
    80004a6e:	6bfe                	ld	s7,472(sp)
    80004a70:	6c5e                	ld	s8,464(sp)
    80004a72:	6cbe                	ld	s9,456(sp)
    80004a74:	6d1e                	ld	s10,448(sp)
    80004a76:	7dfa                	ld	s11,440(sp)
    80004a78:	b541                	j	800048f8 <kexec+0x72>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004a7a:	75f9                	lui	a1,0xffffe
    80004a7c:	95aa                	add	a1,a1,a0
    80004a7e:	855a                	mv	a0,s6
    80004a80:	a57fc0ef          	jal	800014d6 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004a84:	800a0b93          	addi	s7,s4,-2048
    80004a88:	800b8b93          	addi	s7,s7,-2048
  for(argc = 0; argv[argc]; argc++) {
    80004a8c:	e0043783          	ld	a5,-512(s0)
    80004a90:	6388                	ld	a0,0(a5)
  sp = sz;
    80004a92:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80004a94:	4481                	li	s1,0
    ustack[argc] = sp;
    80004a96:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80004a9a:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    80004a9e:	cd21                	beqz	a0,80004af6 <kexec+0x270>
    sp -= strlen(argv[argc]) + 1;
    80004aa0:	be2fc0ef          	jal	80000e82 <strlen>
    80004aa4:	0015079b          	addiw	a5,a0,1
    80004aa8:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004aac:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004ab0:	13796563          	bltu	s2,s7,80004bda <kexec+0x354>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004ab4:	e0043d83          	ld	s11,-512(s0)
    80004ab8:	000db983          	ld	s3,0(s11)
    80004abc:	854e                	mv	a0,s3
    80004abe:	bc4fc0ef          	jal	80000e82 <strlen>
    80004ac2:	0015069b          	addiw	a3,a0,1
    80004ac6:	864e                	mv	a2,s3
    80004ac8:	85ca                	mv	a1,s2
    80004aca:	855a                	mv	a0,s6
    80004acc:	b91fc0ef          	jal	8000165c <copyout>
    80004ad0:	10054763          	bltz	a0,80004bde <kexec+0x358>
    ustack[argc] = sp;
    80004ad4:	00349793          	slli	a5,s1,0x3
    80004ad8:	97e6                	add	a5,a5,s9
    80004ada:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffd0820>
  for(argc = 0; argv[argc]; argc++) {
    80004ade:	0485                	addi	s1,s1,1
    80004ae0:	008d8793          	addi	a5,s11,8
    80004ae4:	e0f43023          	sd	a5,-512(s0)
    80004ae8:	008db503          	ld	a0,8(s11)
    80004aec:	c509                	beqz	a0,80004af6 <kexec+0x270>
    if(argc >= MAXARG)
    80004aee:	fb8499e3          	bne	s1,s8,80004aa0 <kexec+0x21a>
  sz = sz1;
    80004af2:	89d2                	mv	s3,s4
    80004af4:	b7a5                	j	80004a5c <kexec+0x1d6>
  ustack[argc] = 0;
    80004af6:	00349793          	slli	a5,s1,0x3
    80004afa:	f9078793          	addi	a5,a5,-112
    80004afe:	97a2                	add	a5,a5,s0
    80004b00:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004b04:	00349693          	slli	a3,s1,0x3
    80004b08:	06a1                	addi	a3,a3,8
    80004b0a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004b0e:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004b12:	89d2                	mv	s3,s4
  if(sp < stackbase)
    80004b14:	f57964e3          	bltu	s2,s7,80004a5c <kexec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004b18:	e9040613          	addi	a2,s0,-368
    80004b1c:	85ca                	mv	a1,s2
    80004b1e:	855a                	mv	a0,s6
    80004b20:	b3dfc0ef          	jal	8000165c <copyout>
    80004b24:	f2054ce3          	bltz	a0,80004a5c <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004b28:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004b2c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004b30:	df043783          	ld	a5,-528(s0)
    80004b34:	0007c703          	lbu	a4,0(a5)
    80004b38:	cf11                	beqz	a4,80004b54 <kexec+0x2ce>
    80004b3a:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004b3c:	02f00693          	li	a3,47
    80004b40:	a029                	j	80004b4a <kexec+0x2c4>
  for(last=s=path; *s; s++)
    80004b42:	0785                	addi	a5,a5,1
    80004b44:	fff7c703          	lbu	a4,-1(a5)
    80004b48:	c711                	beqz	a4,80004b54 <kexec+0x2ce>
    if(*s == '/')
    80004b4a:	fed71ce3          	bne	a4,a3,80004b42 <kexec+0x2bc>
      last = s+1;
    80004b4e:	def43823          	sd	a5,-528(s0)
    80004b52:	bfc5                	j	80004b42 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004b54:	4641                	li	a2,16
    80004b56:	df043583          	ld	a1,-528(s0)
    80004b5a:	158a8513          	addi	a0,s5,344
    80004b5e:	aeefc0ef          	jal	80000e4c <safestrcpy>
  oldpagetable = p->pagetable;
    80004b62:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004b66:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004b6a:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004b6e:	058ab783          	ld	a5,88(s5)
    80004b72:	e6843703          	ld	a4,-408(s0)
    80004b76:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004b78:	058ab783          	ld	a5,88(s5)
    80004b7c:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004b80:	85ea                	mv	a1,s10
    80004b82:	f43fc0ef          	jal	80001ac4 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004b86:	0004851b          	sext.w	a0,s1
    80004b8a:	79fe                	ld	s3,504(sp)
    80004b8c:	7a5e                	ld	s4,496(sp)
    80004b8e:	7abe                	ld	s5,488(sp)
    80004b90:	7b1e                	ld	s6,480(sp)
    80004b92:	6bfe                	ld	s7,472(sp)
    80004b94:	6c5e                	ld	s8,464(sp)
    80004b96:	6cbe                	ld	s9,456(sp)
    80004b98:	6d1e                	ld	s10,448(sp)
    80004b9a:	7dfa                	ld	s11,440(sp)
    80004b9c:	bbb1                	j	800048f8 <kexec+0x72>
    80004b9e:	7b1e                	ld	s6,480(sp)
    80004ba0:	b3a9                	j	800048ea <kexec+0x64>
    80004ba2:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004ba6:	df843583          	ld	a1,-520(s0)
    80004baa:	855a                	mv	a0,s6
    80004bac:	f19fc0ef          	jal	80001ac4 <proc_freepagetable>
  if(ip){
    80004bb0:	79fe                	ld	s3,504(sp)
    80004bb2:	7abe                	ld	s5,488(sp)
    80004bb4:	7b1e                	ld	s6,480(sp)
    80004bb6:	6bfe                	ld	s7,472(sp)
    80004bb8:	6c5e                	ld	s8,464(sp)
    80004bba:	6cbe                	ld	s9,456(sp)
    80004bbc:	6d1e                	ld	s10,448(sp)
    80004bbe:	7dfa                	ld	s11,440(sp)
    80004bc0:	b32d                	j	800048ea <kexec+0x64>
    80004bc2:	df243c23          	sd	s2,-520(s0)
    80004bc6:	b7c5                	j	80004ba6 <kexec+0x320>
    80004bc8:	df243c23          	sd	s2,-520(s0)
    80004bcc:	bfe9                	j	80004ba6 <kexec+0x320>
    80004bce:	df243c23          	sd	s2,-520(s0)
    80004bd2:	bfd1                	j	80004ba6 <kexec+0x320>
    80004bd4:	df243c23          	sd	s2,-520(s0)
    80004bd8:	b7f9                	j	80004ba6 <kexec+0x320>
  sz = sz1;
    80004bda:	89d2                	mv	s3,s4
    80004bdc:	b541                	j	80004a5c <kexec+0x1d6>
    80004bde:	89d2                	mv	s3,s4
    80004be0:	bdb5                	j	80004a5c <kexec+0x1d6>

0000000080004be2 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004be2:	7179                	addi	sp,sp,-48
    80004be4:	f406                	sd	ra,40(sp)
    80004be6:	f022                	sd	s0,32(sp)
    80004be8:	ec26                	sd	s1,24(sp)
    80004bea:	e84a                	sd	s2,16(sp)
    80004bec:	1800                	addi	s0,sp,48
    80004bee:	892e                	mv	s2,a1
    80004bf0:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004bf2:	fdc40593          	addi	a1,s0,-36
    80004bf6:	ca9fd0ef          	jal	8000289e <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004bfa:	fdc42703          	lw	a4,-36(s0)
    80004bfe:	47bd                	li	a5,15
    80004c00:	02e7ea63          	bltu	a5,a4,80004c34 <argfd+0x52>
    80004c04:	d33fc0ef          	jal	80001936 <myproc>
    80004c08:	fdc42703          	lw	a4,-36(s0)
    80004c0c:	00371793          	slli	a5,a4,0x3
    80004c10:	0d078793          	addi	a5,a5,208
    80004c14:	953e                	add	a0,a0,a5
    80004c16:	611c                	ld	a5,0(a0)
    80004c18:	c385                	beqz	a5,80004c38 <argfd+0x56>
    return -1;
  if(pfd)
    80004c1a:	00090463          	beqz	s2,80004c22 <argfd+0x40>
    *pfd = fd;
    80004c1e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004c22:	4501                	li	a0,0
  if(pf)
    80004c24:	c091                	beqz	s1,80004c28 <argfd+0x46>
    *pf = f;
    80004c26:	e09c                	sd	a5,0(s1)
}
    80004c28:	70a2                	ld	ra,40(sp)
    80004c2a:	7402                	ld	s0,32(sp)
    80004c2c:	64e2                	ld	s1,24(sp)
    80004c2e:	6942                	ld	s2,16(sp)
    80004c30:	6145                	addi	sp,sp,48
    80004c32:	8082                	ret
    return -1;
    80004c34:	557d                	li	a0,-1
    80004c36:	bfcd                	j	80004c28 <argfd+0x46>
    80004c38:	557d                	li	a0,-1
    80004c3a:	b7fd                	j	80004c28 <argfd+0x46>

0000000080004c3c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004c3c:	1101                	addi	sp,sp,-32
    80004c3e:	ec06                	sd	ra,24(sp)
    80004c40:	e822                	sd	s0,16(sp)
    80004c42:	e426                	sd	s1,8(sp)
    80004c44:	1000                	addi	s0,sp,32
    80004c46:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004c48:	ceffc0ef          	jal	80001936 <myproc>
    80004c4c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004c4e:	0d050793          	addi	a5,a0,208
    80004c52:	4501                	li	a0,0
    80004c54:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004c56:	6398                	ld	a4,0(a5)
    80004c58:	cb19                	beqz	a4,80004c6e <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004c5a:	2505                	addiw	a0,a0,1
    80004c5c:	07a1                	addi	a5,a5,8
    80004c5e:	fed51ce3          	bne	a0,a3,80004c56 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004c62:	557d                	li	a0,-1
}
    80004c64:	60e2                	ld	ra,24(sp)
    80004c66:	6442                	ld	s0,16(sp)
    80004c68:	64a2                	ld	s1,8(sp)
    80004c6a:	6105                	addi	sp,sp,32
    80004c6c:	8082                	ret
      p->ofile[fd] = f;
    80004c6e:	00351793          	slli	a5,a0,0x3
    80004c72:	0d078793          	addi	a5,a5,208
    80004c76:	963e                	add	a2,a2,a5
    80004c78:	e204                	sd	s1,0(a2)
      return fd;
    80004c7a:	b7ed                	j	80004c64 <fdalloc+0x28>

0000000080004c7c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004c7c:	715d                	addi	sp,sp,-80
    80004c7e:	e486                	sd	ra,72(sp)
    80004c80:	e0a2                	sd	s0,64(sp)
    80004c82:	fc26                	sd	s1,56(sp)
    80004c84:	f84a                	sd	s2,48(sp)
    80004c86:	f44e                	sd	s3,40(sp)
    80004c88:	f052                	sd	s4,32(sp)
    80004c8a:	ec56                	sd	s5,24(sp)
    80004c8c:	e85a                	sd	s6,16(sp)
    80004c8e:	0880                	addi	s0,sp,80
    80004c90:	892e                	mv	s2,a1
    80004c92:	8a2e                	mv	s4,a1
    80004c94:	8ab2                	mv	s5,a2
    80004c96:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004c98:	fb040593          	addi	a1,s0,-80
    80004c9c:	e85fe0ef          	jal	80003b20 <nameiparent>
    80004ca0:	84aa                	mv	s1,a0
    80004ca2:	10050763          	beqz	a0,80004db0 <create+0x134>
    return 0;

  ilock(dp);
    80004ca6:	e0cfe0ef          	jal	800032b2 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004caa:	4601                	li	a2,0
    80004cac:	fb040593          	addi	a1,s0,-80
    80004cb0:	8526                	mv	a0,s1
    80004cb2:	bc1fe0ef          	jal	80003872 <dirlookup>
    80004cb6:	89aa                	mv	s3,a0
    80004cb8:	c131                	beqz	a0,80004cfc <create+0x80>
    iunlockput(dp);
    80004cba:	8526                	mv	a0,s1
    80004cbc:	825fe0ef          	jal	800034e0 <iunlockput>
    ilock(ip);
    80004cc0:	854e                	mv	a0,s3
    80004cc2:	df0fe0ef          	jal	800032b2 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004cc6:	4789                	li	a5,2
    80004cc8:	02f91563          	bne	s2,a5,80004cf2 <create+0x76>
    80004ccc:	0449d783          	lhu	a5,68(s3)
    80004cd0:	37f9                	addiw	a5,a5,-2
    80004cd2:	17c2                	slli	a5,a5,0x30
    80004cd4:	93c1                	srli	a5,a5,0x30
    80004cd6:	4705                	li	a4,1
    80004cd8:	00f76d63          	bltu	a4,a5,80004cf2 <create+0x76>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004cdc:	854e                	mv	a0,s3
    80004cde:	60a6                	ld	ra,72(sp)
    80004ce0:	6406                	ld	s0,64(sp)
    80004ce2:	74e2                	ld	s1,56(sp)
    80004ce4:	7942                	ld	s2,48(sp)
    80004ce6:	79a2                	ld	s3,40(sp)
    80004ce8:	7a02                	ld	s4,32(sp)
    80004cea:	6ae2                	ld	s5,24(sp)
    80004cec:	6b42                	ld	s6,16(sp)
    80004cee:	6161                	addi	sp,sp,80
    80004cf0:	8082                	ret
    iunlockput(ip);
    80004cf2:	854e                	mv	a0,s3
    80004cf4:	fecfe0ef          	jal	800034e0 <iunlockput>
    return 0;
    80004cf8:	4981                	li	s3,0
    80004cfa:	b7cd                	j	80004cdc <create+0x60>
  if((ip = ialloc(dp->dev, type)) == 0){
    80004cfc:	85ca                	mv	a1,s2
    80004cfe:	4088                	lw	a0,0(s1)
    80004d00:	bfcfe0ef          	jal	800030fc <ialloc>
    80004d04:	892a                	mv	s2,a0
    80004d06:	cd15                	beqz	a0,80004d42 <create+0xc6>
  ilock(ip);
    80004d08:	daafe0ef          	jal	800032b2 <ilock>
  ip->major = major;
    80004d0c:	05591323          	sh	s5,70(s2)
  ip->minor = minor;
    80004d10:	05691423          	sh	s6,72(s2)
  ip->nlink = 1;
    80004d14:	4785                	li	a5,1
    80004d16:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004d1a:	854a                	mv	a0,s2
    80004d1c:	cc4fe0ef          	jal	800031e0 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004d20:	4705                	li	a4,1
    80004d22:	02ea0463          	beq	s4,a4,80004d4a <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004d26:	00492603          	lw	a2,4(s2)
    80004d2a:	fb040593          	addi	a1,s0,-80
    80004d2e:	8526                	mv	a0,s1
    80004d30:	d2dfe0ef          	jal	80003a5c <dirlink>
    80004d34:	06054263          	bltz	a0,80004d98 <create+0x11c>
  iunlockput(dp);
    80004d38:	8526                	mv	a0,s1
    80004d3a:	fa6fe0ef          	jal	800034e0 <iunlockput>
  return ip;
    80004d3e:	89ca                	mv	s3,s2
    80004d40:	bf71                	j	80004cdc <create+0x60>
    iunlockput(dp);
    80004d42:	8526                	mv	a0,s1
    80004d44:	f9cfe0ef          	jal	800034e0 <iunlockput>
    return 0;
    80004d48:	bf51                	j	80004cdc <create+0x60>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004d4a:	00492603          	lw	a2,4(s2)
    80004d4e:	00004597          	auipc	a1,0x4
    80004d52:	8d258593          	addi	a1,a1,-1838 # 80008620 <etext+0x620>
    80004d56:	854a                	mv	a0,s2
    80004d58:	d05fe0ef          	jal	80003a5c <dirlink>
    80004d5c:	02054e63          	bltz	a0,80004d98 <create+0x11c>
    80004d60:	40d0                	lw	a2,4(s1)
    80004d62:	00004597          	auipc	a1,0x4
    80004d66:	8c658593          	addi	a1,a1,-1850 # 80008628 <etext+0x628>
    80004d6a:	854a                	mv	a0,s2
    80004d6c:	cf1fe0ef          	jal	80003a5c <dirlink>
    80004d70:	02054463          	bltz	a0,80004d98 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004d74:	00492603          	lw	a2,4(s2)
    80004d78:	fb040593          	addi	a1,s0,-80
    80004d7c:	8526                	mv	a0,s1
    80004d7e:	cdffe0ef          	jal	80003a5c <dirlink>
    80004d82:	00054b63          	bltz	a0,80004d98 <create+0x11c>
    dp->nlink++;  // for ".."
    80004d86:	04a4d783          	lhu	a5,74(s1)
    80004d8a:	2785                	addiw	a5,a5,1
    80004d8c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004d90:	8526                	mv	a0,s1
    80004d92:	c4efe0ef          	jal	800031e0 <iupdate>
    80004d96:	b74d                	j	80004d38 <create+0xbc>
  ip->nlink = 0;
    80004d98:	04091523          	sh	zero,74(s2)
  iupdate(ip);
    80004d9c:	854a                	mv	a0,s2
    80004d9e:	c42fe0ef          	jal	800031e0 <iupdate>
  iunlockput(ip);
    80004da2:	854a                	mv	a0,s2
    80004da4:	f3cfe0ef          	jal	800034e0 <iunlockput>
  iunlockput(dp);
    80004da8:	8526                	mv	a0,s1
    80004daa:	f36fe0ef          	jal	800034e0 <iunlockput>
  return 0;
    80004dae:	b73d                	j	80004cdc <create+0x60>
    return 0;
    80004db0:	89aa                	mv	s3,a0
    80004db2:	b72d                	j	80004cdc <create+0x60>

0000000080004db4 <sys_dup>:
{
    80004db4:	7179                	addi	sp,sp,-48
    80004db6:	f406                	sd	ra,40(sp)
    80004db8:	f022                	sd	s0,32(sp)
    80004dba:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004dbc:	fd840613          	addi	a2,s0,-40
    80004dc0:	4581                	li	a1,0
    80004dc2:	4501                	li	a0,0
    80004dc4:	e1fff0ef          	jal	80004be2 <argfd>
    return -1;
    80004dc8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004dca:	02054363          	bltz	a0,80004df0 <sys_dup+0x3c>
    80004dce:	ec26                	sd	s1,24(sp)
    80004dd0:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004dd2:	fd843483          	ld	s1,-40(s0)
    80004dd6:	8526                	mv	a0,s1
    80004dd8:	e65ff0ef          	jal	80004c3c <fdalloc>
    80004ddc:	892a                	mv	s2,a0
    return -1;
    80004dde:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004de0:	00054d63          	bltz	a0,80004dfa <sys_dup+0x46>
  filedup(f);
    80004de4:	8526                	mv	a0,s1
    80004de6:	b4cff0ef          	jal	80004132 <filedup>
  return fd;
    80004dea:	87ca                	mv	a5,s2
    80004dec:	64e2                	ld	s1,24(sp)
    80004dee:	6942                	ld	s2,16(sp)
}
    80004df0:	853e                	mv	a0,a5
    80004df2:	70a2                	ld	ra,40(sp)
    80004df4:	7402                	ld	s0,32(sp)
    80004df6:	6145                	addi	sp,sp,48
    80004df8:	8082                	ret
    80004dfa:	64e2                	ld	s1,24(sp)
    80004dfc:	6942                	ld	s2,16(sp)
    80004dfe:	bfcd                	j	80004df0 <sys_dup+0x3c>

0000000080004e00 <sys_read>:
{
    80004e00:	7179                	addi	sp,sp,-48
    80004e02:	f406                	sd	ra,40(sp)
    80004e04:	f022                	sd	s0,32(sp)
    80004e06:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004e08:	fd840593          	addi	a1,s0,-40
    80004e0c:	4505                	li	a0,1
    80004e0e:	aaffd0ef          	jal	800028bc <argaddr>
  argint(2, &n);
    80004e12:	fe440593          	addi	a1,s0,-28
    80004e16:	4509                	li	a0,2
    80004e18:	a87fd0ef          	jal	8000289e <argint>
  if(argfd(0, 0, &f) < 0)
    80004e1c:	fe840613          	addi	a2,s0,-24
    80004e20:	4581                	li	a1,0
    80004e22:	4501                	li	a0,0
    80004e24:	dbfff0ef          	jal	80004be2 <argfd>
    80004e28:	87aa                	mv	a5,a0
    return -1;
    80004e2a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004e2c:	0007ca63          	bltz	a5,80004e40 <sys_read+0x40>
  return fileread(f, p, n);
    80004e30:	fe442603          	lw	a2,-28(s0)
    80004e34:	fd843583          	ld	a1,-40(s0)
    80004e38:	fe843503          	ld	a0,-24(s0)
    80004e3c:	c60ff0ef          	jal	8000429c <fileread>
}
    80004e40:	70a2                	ld	ra,40(sp)
    80004e42:	7402                	ld	s0,32(sp)
    80004e44:	6145                	addi	sp,sp,48
    80004e46:	8082                	ret

0000000080004e48 <sys_write>:
{
    80004e48:	7179                	addi	sp,sp,-48
    80004e4a:	f406                	sd	ra,40(sp)
    80004e4c:	f022                	sd	s0,32(sp)
    80004e4e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004e50:	fd840593          	addi	a1,s0,-40
    80004e54:	4505                	li	a0,1
    80004e56:	a67fd0ef          	jal	800028bc <argaddr>
  argint(2, &n);
    80004e5a:	fe440593          	addi	a1,s0,-28
    80004e5e:	4509                	li	a0,2
    80004e60:	a3ffd0ef          	jal	8000289e <argint>
  if(argfd(0, 0, &f) < 0)
    80004e64:	fe840613          	addi	a2,s0,-24
    80004e68:	4581                	li	a1,0
    80004e6a:	4501                	li	a0,0
    80004e6c:	d77ff0ef          	jal	80004be2 <argfd>
    80004e70:	87aa                	mv	a5,a0
    return -1;
    80004e72:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004e74:	0007ca63          	bltz	a5,80004e88 <sys_write+0x40>
  return filewrite(f, p, n);
    80004e78:	fe442603          	lw	a2,-28(s0)
    80004e7c:	fd843583          	ld	a1,-40(s0)
    80004e80:	fe843503          	ld	a0,-24(s0)
    80004e84:	d40ff0ef          	jal	800043c4 <filewrite>
}
    80004e88:	70a2                	ld	ra,40(sp)
    80004e8a:	7402                	ld	s0,32(sp)
    80004e8c:	6145                	addi	sp,sp,48
    80004e8e:	8082                	ret

0000000080004e90 <sys_close>:
{
    80004e90:	1101                	addi	sp,sp,-32
    80004e92:	ec06                	sd	ra,24(sp)
    80004e94:	e822                	sd	s0,16(sp)
    80004e96:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004e98:	fe040613          	addi	a2,s0,-32
    80004e9c:	fec40593          	addi	a1,s0,-20
    80004ea0:	4501                	li	a0,0
    80004ea2:	d41ff0ef          	jal	80004be2 <argfd>
    return -1;
    80004ea6:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004ea8:	02054163          	bltz	a0,80004eca <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80004eac:	a8bfc0ef          	jal	80001936 <myproc>
    80004eb0:	fec42783          	lw	a5,-20(s0)
    80004eb4:	078e                	slli	a5,a5,0x3
    80004eb6:	0d078793          	addi	a5,a5,208
    80004eba:	953e                	add	a0,a0,a5
    80004ebc:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004ec0:	fe043503          	ld	a0,-32(s0)
    80004ec4:	ab4ff0ef          	jal	80004178 <fileclose>
  return 0;
    80004ec8:	4781                	li	a5,0
}
    80004eca:	853e                	mv	a0,a5
    80004ecc:	60e2                	ld	ra,24(sp)
    80004ece:	6442                	ld	s0,16(sp)
    80004ed0:	6105                	addi	sp,sp,32
    80004ed2:	8082                	ret

0000000080004ed4 <sys_fstat>:
{
    80004ed4:	1101                	addi	sp,sp,-32
    80004ed6:	ec06                	sd	ra,24(sp)
    80004ed8:	e822                	sd	s0,16(sp)
    80004eda:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004edc:	fe040593          	addi	a1,s0,-32
    80004ee0:	4505                	li	a0,1
    80004ee2:	9dbfd0ef          	jal	800028bc <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004ee6:	fe840613          	addi	a2,s0,-24
    80004eea:	4581                	li	a1,0
    80004eec:	4501                	li	a0,0
    80004eee:	cf5ff0ef          	jal	80004be2 <argfd>
    80004ef2:	87aa                	mv	a5,a0
    return -1;
    80004ef4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004ef6:	0007c863          	bltz	a5,80004f06 <sys_fstat+0x32>
  return filestat(f, st);
    80004efa:	fe043583          	ld	a1,-32(s0)
    80004efe:	fe843503          	ld	a0,-24(s0)
    80004f02:	b38ff0ef          	jal	8000423a <filestat>
}
    80004f06:	60e2                	ld	ra,24(sp)
    80004f08:	6442                	ld	s0,16(sp)
    80004f0a:	6105                	addi	sp,sp,32
    80004f0c:	8082                	ret

0000000080004f0e <sys_link>:
{
    80004f0e:	7169                	addi	sp,sp,-304
    80004f10:	f606                	sd	ra,296(sp)
    80004f12:	f222                	sd	s0,288(sp)
    80004f14:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f16:	08000613          	li	a2,128
    80004f1a:	ed040593          	addi	a1,s0,-304
    80004f1e:	4501                	li	a0,0
    80004f20:	9bbfd0ef          	jal	800028da <argstr>
    return -1;
    80004f24:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f26:	0c054e63          	bltz	a0,80005002 <sys_link+0xf4>
    80004f2a:	08000613          	li	a2,128
    80004f2e:	f5040593          	addi	a1,s0,-176
    80004f32:	4505                	li	a0,1
    80004f34:	9a7fd0ef          	jal	800028da <argstr>
    return -1;
    80004f38:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f3a:	0c054463          	bltz	a0,80005002 <sys_link+0xf4>
    80004f3e:	ee26                	sd	s1,280(sp)
  begin_op();
    80004f40:	da5fe0ef          	jal	80003ce4 <begin_op>
  if((ip = namei(old)) == 0){
    80004f44:	ed040513          	addi	a0,s0,-304
    80004f48:	bbffe0ef          	jal	80003b06 <namei>
    80004f4c:	84aa                	mv	s1,a0
    80004f4e:	c53d                	beqz	a0,80004fbc <sys_link+0xae>
  ilock(ip);
    80004f50:	b62fe0ef          	jal	800032b2 <ilock>
  if(ip->type == T_DIR){
    80004f54:	04449703          	lh	a4,68(s1)
    80004f58:	4785                	li	a5,1
    80004f5a:	06f70663          	beq	a4,a5,80004fc6 <sys_link+0xb8>
    80004f5e:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004f60:	04a4d783          	lhu	a5,74(s1)
    80004f64:	2785                	addiw	a5,a5,1
    80004f66:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004f6a:	8526                	mv	a0,s1
    80004f6c:	a74fe0ef          	jal	800031e0 <iupdate>
  iunlock(ip);
    80004f70:	8526                	mv	a0,s1
    80004f72:	c10fe0ef          	jal	80003382 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004f76:	fd040593          	addi	a1,s0,-48
    80004f7a:	f5040513          	addi	a0,s0,-176
    80004f7e:	ba3fe0ef          	jal	80003b20 <nameiparent>
    80004f82:	892a                	mv	s2,a0
    80004f84:	cd21                	beqz	a0,80004fdc <sys_link+0xce>
  ilock(dp);
    80004f86:	b2cfe0ef          	jal	800032b2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004f8a:	854a                	mv	a0,s2
    80004f8c:	00092703          	lw	a4,0(s2)
    80004f90:	409c                	lw	a5,0(s1)
    80004f92:	04f71263          	bne	a4,a5,80004fd6 <sys_link+0xc8>
    80004f96:	40d0                	lw	a2,4(s1)
    80004f98:	fd040593          	addi	a1,s0,-48
    80004f9c:	ac1fe0ef          	jal	80003a5c <dirlink>
    80004fa0:	02054b63          	bltz	a0,80004fd6 <sys_link+0xc8>
  iunlockput(dp);
    80004fa4:	854a                	mv	a0,s2
    80004fa6:	d3afe0ef          	jal	800034e0 <iunlockput>
  iput(ip);
    80004faa:	8526                	mv	a0,s1
    80004fac:	caafe0ef          	jal	80003456 <iput>
  end_op();
    80004fb0:	da5fe0ef          	jal	80003d54 <end_op>
  return 0;
    80004fb4:	4781                	li	a5,0
    80004fb6:	64f2                	ld	s1,280(sp)
    80004fb8:	6952                	ld	s2,272(sp)
    80004fba:	a0a1                	j	80005002 <sys_link+0xf4>
    end_op();
    80004fbc:	d99fe0ef          	jal	80003d54 <end_op>
    return -1;
    80004fc0:	57fd                	li	a5,-1
    80004fc2:	64f2                	ld	s1,280(sp)
    80004fc4:	a83d                	j	80005002 <sys_link+0xf4>
    iunlockput(ip);
    80004fc6:	8526                	mv	a0,s1
    80004fc8:	d18fe0ef          	jal	800034e0 <iunlockput>
    end_op();
    80004fcc:	d89fe0ef          	jal	80003d54 <end_op>
    return -1;
    80004fd0:	57fd                	li	a5,-1
    80004fd2:	64f2                	ld	s1,280(sp)
    80004fd4:	a03d                	j	80005002 <sys_link+0xf4>
    iunlockput(dp);
    80004fd6:	854a                	mv	a0,s2
    80004fd8:	d08fe0ef          	jal	800034e0 <iunlockput>
  ilock(ip);
    80004fdc:	8526                	mv	a0,s1
    80004fde:	ad4fe0ef          	jal	800032b2 <ilock>
  ip->nlink--;
    80004fe2:	04a4d783          	lhu	a5,74(s1)
    80004fe6:	37fd                	addiw	a5,a5,-1
    80004fe8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004fec:	8526                	mv	a0,s1
    80004fee:	9f2fe0ef          	jal	800031e0 <iupdate>
  iunlockput(ip);
    80004ff2:	8526                	mv	a0,s1
    80004ff4:	cecfe0ef          	jal	800034e0 <iunlockput>
  end_op();
    80004ff8:	d5dfe0ef          	jal	80003d54 <end_op>
  return -1;
    80004ffc:	57fd                	li	a5,-1
    80004ffe:	64f2                	ld	s1,280(sp)
    80005000:	6952                	ld	s2,272(sp)
}
    80005002:	853e                	mv	a0,a5
    80005004:	70b2                	ld	ra,296(sp)
    80005006:	7412                	ld	s0,288(sp)
    80005008:	6155                	addi	sp,sp,304
    8000500a:	8082                	ret

000000008000500c <sys_unlink>:
{
    8000500c:	7151                	addi	sp,sp,-240
    8000500e:	f586                	sd	ra,232(sp)
    80005010:	f1a2                	sd	s0,224(sp)
    80005012:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005014:	08000613          	li	a2,128
    80005018:	f3040593          	addi	a1,s0,-208
    8000501c:	4501                	li	a0,0
    8000501e:	8bdfd0ef          	jal	800028da <argstr>
    80005022:	14054d63          	bltz	a0,8000517c <sys_unlink+0x170>
    80005026:	eda6                	sd	s1,216(sp)
  begin_op();
    80005028:	cbdfe0ef          	jal	80003ce4 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000502c:	fb040593          	addi	a1,s0,-80
    80005030:	f3040513          	addi	a0,s0,-208
    80005034:	aedfe0ef          	jal	80003b20 <nameiparent>
    80005038:	84aa                	mv	s1,a0
    8000503a:	c955                	beqz	a0,800050ee <sys_unlink+0xe2>
  ilock(dp);
    8000503c:	a76fe0ef          	jal	800032b2 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005040:	00003597          	auipc	a1,0x3
    80005044:	5e058593          	addi	a1,a1,1504 # 80008620 <etext+0x620>
    80005048:	fb040513          	addi	a0,s0,-80
    8000504c:	811fe0ef          	jal	8000385c <namecmp>
    80005050:	10050b63          	beqz	a0,80005166 <sys_unlink+0x15a>
    80005054:	00003597          	auipc	a1,0x3
    80005058:	5d458593          	addi	a1,a1,1492 # 80008628 <etext+0x628>
    8000505c:	fb040513          	addi	a0,s0,-80
    80005060:	ffcfe0ef          	jal	8000385c <namecmp>
    80005064:	10050163          	beqz	a0,80005166 <sys_unlink+0x15a>
    80005068:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000506a:	f2c40613          	addi	a2,s0,-212
    8000506e:	fb040593          	addi	a1,s0,-80
    80005072:	8526                	mv	a0,s1
    80005074:	ffefe0ef          	jal	80003872 <dirlookup>
    80005078:	892a                	mv	s2,a0
    8000507a:	0e050563          	beqz	a0,80005164 <sys_unlink+0x158>
    8000507e:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    80005080:	a32fe0ef          	jal	800032b2 <ilock>
  if(ip->nlink < 1)
    80005084:	04a91783          	lh	a5,74(s2)
    80005088:	06f05863          	blez	a5,800050f8 <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000508c:	04491703          	lh	a4,68(s2)
    80005090:	4785                	li	a5,1
    80005092:	06f70963          	beq	a4,a5,80005104 <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    80005096:	fc040993          	addi	s3,s0,-64
    8000509a:	4641                	li	a2,16
    8000509c:	4581                	li	a1,0
    8000509e:	854e                	mv	a0,s3
    800050a0:	c59fb0ef          	jal	80000cf8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800050a4:	4741                	li	a4,16
    800050a6:	f2c42683          	lw	a3,-212(s0)
    800050aa:	864e                	mv	a2,s3
    800050ac:	4581                	li	a1,0
    800050ae:	8526                	mv	a0,s1
    800050b0:	eacfe0ef          	jal	8000375c <writei>
    800050b4:	47c1                	li	a5,16
    800050b6:	08f51863          	bne	a0,a5,80005146 <sys_unlink+0x13a>
  if(ip->type == T_DIR){
    800050ba:	04491703          	lh	a4,68(s2)
    800050be:	4785                	li	a5,1
    800050c0:	08f70963          	beq	a4,a5,80005152 <sys_unlink+0x146>
  iunlockput(dp);
    800050c4:	8526                	mv	a0,s1
    800050c6:	c1afe0ef          	jal	800034e0 <iunlockput>
  ip->nlink--;
    800050ca:	04a95783          	lhu	a5,74(s2)
    800050ce:	37fd                	addiw	a5,a5,-1
    800050d0:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800050d4:	854a                	mv	a0,s2
    800050d6:	90afe0ef          	jal	800031e0 <iupdate>
  iunlockput(ip);
    800050da:	854a                	mv	a0,s2
    800050dc:	c04fe0ef          	jal	800034e0 <iunlockput>
  end_op();
    800050e0:	c75fe0ef          	jal	80003d54 <end_op>
  return 0;
    800050e4:	4501                	li	a0,0
    800050e6:	64ee                	ld	s1,216(sp)
    800050e8:	694e                	ld	s2,208(sp)
    800050ea:	69ae                	ld	s3,200(sp)
    800050ec:	a061                	j	80005174 <sys_unlink+0x168>
    end_op();
    800050ee:	c67fe0ef          	jal	80003d54 <end_op>
    return -1;
    800050f2:	557d                	li	a0,-1
    800050f4:	64ee                	ld	s1,216(sp)
    800050f6:	a8bd                	j	80005174 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    800050f8:	00003517          	auipc	a0,0x3
    800050fc:	53850513          	addi	a0,a0,1336 # 80008630 <etext+0x630>
    80005100:	f24fb0ef          	jal	80000824 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005104:	04c92703          	lw	a4,76(s2)
    80005108:	02000793          	li	a5,32
    8000510c:	f8e7f5e3          	bgeu	a5,a4,80005096 <sys_unlink+0x8a>
    80005110:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005112:	4741                	li	a4,16
    80005114:	86ce                	mv	a3,s3
    80005116:	f1840613          	addi	a2,s0,-232
    8000511a:	4581                	li	a1,0
    8000511c:	854a                	mv	a0,s2
    8000511e:	d4cfe0ef          	jal	8000366a <readi>
    80005122:	47c1                	li	a5,16
    80005124:	00f51b63          	bne	a0,a5,8000513a <sys_unlink+0x12e>
    if(de.inum != 0)
    80005128:	f1845783          	lhu	a5,-232(s0)
    8000512c:	ebb1                	bnez	a5,80005180 <sys_unlink+0x174>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000512e:	29c1                	addiw	s3,s3,16
    80005130:	04c92783          	lw	a5,76(s2)
    80005134:	fcf9efe3          	bltu	s3,a5,80005112 <sys_unlink+0x106>
    80005138:	bfb9                	j	80005096 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    8000513a:	00003517          	auipc	a0,0x3
    8000513e:	50e50513          	addi	a0,a0,1294 # 80008648 <etext+0x648>
    80005142:	ee2fb0ef          	jal	80000824 <panic>
    panic("unlink: writei");
    80005146:	00003517          	auipc	a0,0x3
    8000514a:	51a50513          	addi	a0,a0,1306 # 80008660 <etext+0x660>
    8000514e:	ed6fb0ef          	jal	80000824 <panic>
    dp->nlink--;
    80005152:	04a4d783          	lhu	a5,74(s1)
    80005156:	37fd                	addiw	a5,a5,-1
    80005158:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000515c:	8526                	mv	a0,s1
    8000515e:	882fe0ef          	jal	800031e0 <iupdate>
    80005162:	b78d                	j	800050c4 <sys_unlink+0xb8>
    80005164:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005166:	8526                	mv	a0,s1
    80005168:	b78fe0ef          	jal	800034e0 <iunlockput>
  end_op();
    8000516c:	be9fe0ef          	jal	80003d54 <end_op>
  return -1;
    80005170:	557d                	li	a0,-1
    80005172:	64ee                	ld	s1,216(sp)
}
    80005174:	70ae                	ld	ra,232(sp)
    80005176:	740e                	ld	s0,224(sp)
    80005178:	616d                	addi	sp,sp,240
    8000517a:	8082                	ret
    return -1;
    8000517c:	557d                	li	a0,-1
    8000517e:	bfdd                	j	80005174 <sys_unlink+0x168>
    iunlockput(ip);
    80005180:	854a                	mv	a0,s2
    80005182:	b5efe0ef          	jal	800034e0 <iunlockput>
    goto bad;
    80005186:	694e                	ld	s2,208(sp)
    80005188:	69ae                	ld	s3,200(sp)
    8000518a:	bff1                	j	80005166 <sys_unlink+0x15a>

000000008000518c <sys_open>:

uint64
sys_open(void)
{
    8000518c:	7131                	addi	sp,sp,-192
    8000518e:	fd06                	sd	ra,184(sp)
    80005190:	f922                	sd	s0,176(sp)
    80005192:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005194:	f4c40593          	addi	a1,s0,-180
    80005198:	4505                	li	a0,1
    8000519a:	f04fd0ef          	jal	8000289e <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000519e:	08000613          	li	a2,128
    800051a2:	f5040593          	addi	a1,s0,-176
    800051a6:	4501                	li	a0,0
    800051a8:	f32fd0ef          	jal	800028da <argstr>
    800051ac:	87aa                	mv	a5,a0
    return -1;
    800051ae:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800051b0:	1007c763          	bltz	a5,800052be <sys_open+0x132>
    800051b4:	f526                	sd	s1,168(sp)

  printf("sys_open: path=%s uid=%d gid=%d\n", path, myproc()->creds.uid, myproc()->creds.gid);
    800051b6:	f80fc0ef          	jal	80001936 <myproc>
    800051ba:	16852483          	lw	s1,360(a0)
    800051be:	f78fc0ef          	jal	80001936 <myproc>
    800051c2:	16c52683          	lw	a3,364(a0)
    800051c6:	8626                	mv	a2,s1
    800051c8:	f5040593          	addi	a1,s0,-176
    800051cc:	00003517          	auipc	a0,0x3
    800051d0:	4a450513          	addi	a0,a0,1188 # 80008670 <etext+0x670>
    800051d4:	b26fb0ef          	jal	800004fa <printf>

  begin_op();
    800051d8:	b0dfe0ef          	jal	80003ce4 <begin_op>

  if(omode & O_CREATE){
    800051dc:	f4c42783          	lw	a5,-180(s0)
    800051e0:	2007f793          	andi	a5,a5,512
    800051e4:	0e078663          	beqz	a5,800052d0 <sys_open+0x144>
    ip = create(path, T_FILE, 0, 0);
    800051e8:	4681                	li	a3,0
    800051ea:	4601                	li	a2,0
    800051ec:	4589                	li	a1,2
    800051ee:	f5040513          	addi	a0,s0,-176
    800051f2:	a8bff0ef          	jal	80004c7c <create>
    800051f6:	84aa                	mv	s1,a0
    if(ip == 0){
    800051f8:	c579                	beqz	a0,800052c6 <sys_open+0x13a>
    800051fa:	f14a                	sd	s2,160(sp)
      return -1;
    }
  }

  // === NEW: Check open-time permissions (before filealloc) ===
  struct proc *p = myproc();
    800051fc:	f3afc0ef          	jal	80001936 <myproc>
    80005200:	892a                	mv	s2,a0
  int need_read  = (omode == O_RDONLY || omode == O_RDWR) ? 1 : 0;
    80005202:	f4c42783          	lw	a5,-180(s0)
    80005206:	ffd7f713          	andi	a4,a5,-3
    8000520a:	00173713          	seqz	a4,a4
  int need_write = (omode == O_WRONLY || omode == O_RDWR ||
                    (omode & O_TRUNC)  || (omode & O_APPEND)) ? 2 : 0;
    8000520e:	fff7861b          	addiw	a2,a5,-1
    80005212:	4685                	li	a3,1
  int need_write = (omode == O_WRONLY || omode == O_RDWR ||
    80005214:	4589                	li	a1,2
                    (omode & O_TRUNC)  || (omode & O_APPEND)) ? 2 : 0;
    80005216:	00c6fa63          	bgeu	a3,a2,8000522a <sys_open+0x9e>
    8000521a:	6685                	lui	a3,0x1
    8000521c:	c0068693          	addi	a3,a3,-1024 # c00 <_entry-0x7ffff400>
    80005220:	8ff5                	and	a5,a5,a3
    80005222:	00f037b3          	snez	a5,a5
    80005226:	00179593          	slli	a1,a5,0x1

  if (check_permission(ip, need_read | need_write,
    8000522a:	16c92683          	lw	a3,364(s2)
    8000522e:	16892603          	lw	a2,360(s2)
    80005232:	8dd9                	or	a1,a1,a4
    80005234:	8526                	mv	a0,s1
    80005236:	e0bfe0ef          	jal	80004040 <check_permission>
    8000523a:	0c054963          	bltz	a0,8000530c <sys_open+0x180>
    audit_log_event(p->pid, p->creds.uid, SYS_open, "DENIED:open_permission");
    return -1;
  }
  // === END NEW ===

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000523e:	04449703          	lh	a4,68(s1)
    80005242:	478d                	li	a5,3
    80005244:	00f71763          	bne	a4,a5,80005252 <sys_open+0xc6>
    80005248:	0464d703          	lhu	a4,70(s1)
    8000524c:	47a5                	li	a5,9
    8000524e:	0ee7e363          	bltu	a5,a4,80005334 <sys_open+0x1a8>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005252:	e83fe0ef          	jal	800040d4 <filealloc>
    80005256:	892a                	mv	s2,a0
    80005258:	0e050b63          	beqz	a0,8000534e <sys_open+0x1c2>
    8000525c:	ed4e                	sd	s3,152(sp)
    8000525e:	9dfff0ef          	jal	80004c3c <fdalloc>
    80005262:	89aa                	mv	s3,a0
    80005264:	0e054163          	bltz	a0,80005346 <sys_open+0x1ba>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005268:	04449703          	lh	a4,68(s1)
    8000526c:	478d                	li	a5,3
    8000526e:	0ef70963          	beq	a4,a5,80005360 <sys_open+0x1d4>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005272:	4789                	li	a5,2
    80005274:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005278:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000527c:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005280:	f4c42783          	lw	a5,-180(s0)
    80005284:	0017f713          	andi	a4,a5,1
    80005288:	00174713          	xori	a4,a4,1
    8000528c:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005290:	0037f713          	andi	a4,a5,3
    80005294:	00e03733          	snez	a4,a4
    80005298:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000529c:	4007f793          	andi	a5,a5,1024
    800052a0:	c791                	beqz	a5,800052ac <sys_open+0x120>
    800052a2:	04449703          	lh	a4,68(s1)
    800052a6:	4789                	li	a5,2
    800052a8:	0cf70363          	beq	a4,a5,8000536e <sys_open+0x1e2>
    itrunc(ip);
  }

  iunlock(ip);
    800052ac:	8526                	mv	a0,s1
    800052ae:	8d4fe0ef          	jal	80003382 <iunlock>
  end_op();
    800052b2:	aa3fe0ef          	jal	80003d54 <end_op>

  return fd;
    800052b6:	854e                	mv	a0,s3
    800052b8:	74aa                	ld	s1,168(sp)
    800052ba:	790a                	ld	s2,160(sp)
    800052bc:	69ea                	ld	s3,152(sp)
}
    800052be:	70ea                	ld	ra,184(sp)
    800052c0:	744a                	ld	s0,176(sp)
    800052c2:	6129                	addi	sp,sp,192
    800052c4:	8082                	ret
      end_op();
    800052c6:	a8ffe0ef          	jal	80003d54 <end_op>
      return -1;
    800052ca:	557d                	li	a0,-1
    800052cc:	74aa                	ld	s1,168(sp)
    800052ce:	bfc5                	j	800052be <sys_open+0x132>
    if((ip = namei(path)) == 0){
    800052d0:	f5040513          	addi	a0,s0,-176
    800052d4:	833fe0ef          	jal	80003b06 <namei>
    800052d8:	84aa                	mv	s1,a0
    800052da:	c505                	beqz	a0,80005302 <sys_open+0x176>
    ilock(ip);
    800052dc:	fd7fd0ef          	jal	800032b2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800052e0:	04449703          	lh	a4,68(s1)
    800052e4:	4785                	li	a5,1
    800052e6:	f0f71ae3          	bne	a4,a5,800051fa <sys_open+0x6e>
    800052ea:	f4c42783          	lw	a5,-180(s0)
    800052ee:	f00786e3          	beqz	a5,800051fa <sys_open+0x6e>
      iunlockput(ip);
    800052f2:	8526                	mv	a0,s1
    800052f4:	9ecfe0ef          	jal	800034e0 <iunlockput>
      end_op();
    800052f8:	a5dfe0ef          	jal	80003d54 <end_op>
      return -1;
    800052fc:	557d                	li	a0,-1
    800052fe:	74aa                	ld	s1,168(sp)
    80005300:	bf7d                	j	800052be <sys_open+0x132>
      end_op();
    80005302:	a53fe0ef          	jal	80003d54 <end_op>
      return -1;
    80005306:	557d                	li	a0,-1
    80005308:	74aa                	ld	s1,168(sp)
    8000530a:	bf55                	j	800052be <sys_open+0x132>
    iunlockput(ip);
    8000530c:	8526                	mv	a0,s1
    8000530e:	9d2fe0ef          	jal	800034e0 <iunlockput>
    end_op();
    80005312:	a43fe0ef          	jal	80003d54 <end_op>
    audit_log_event(p->pid, p->creds.uid, SYS_open, "DENIED:open_permission");
    80005316:	00003697          	auipc	a3,0x3
    8000531a:	38268693          	addi	a3,a3,898 # 80008698 <etext+0x698>
    8000531e:	463d                	li	a2,15
    80005320:	16892583          	lw	a1,360(s2)
    80005324:	03092503          	lw	a0,48(s2)
    80005328:	2bc010ef          	jal	800065e4 <audit_log_event>
    return -1;
    8000532c:	557d                	li	a0,-1
    8000532e:	74aa                	ld	s1,168(sp)
    80005330:	790a                	ld	s2,160(sp)
    80005332:	b771                	j	800052be <sys_open+0x132>
    iunlockput(ip);
    80005334:	8526                	mv	a0,s1
    80005336:	9aafe0ef          	jal	800034e0 <iunlockput>
    end_op();
    8000533a:	a1bfe0ef          	jal	80003d54 <end_op>
    return -1;
    8000533e:	557d                	li	a0,-1
    80005340:	74aa                	ld	s1,168(sp)
    80005342:	790a                	ld	s2,160(sp)
    80005344:	bfad                	j	800052be <sys_open+0x132>
      fileclose(f);
    80005346:	854a                	mv	a0,s2
    80005348:	e31fe0ef          	jal	80004178 <fileclose>
    8000534c:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000534e:	8526                	mv	a0,s1
    80005350:	990fe0ef          	jal	800034e0 <iunlockput>
    end_op();
    80005354:	a01fe0ef          	jal	80003d54 <end_op>
    return -1;
    80005358:	557d                	li	a0,-1
    8000535a:	74aa                	ld	s1,168(sp)
    8000535c:	790a                	ld	s2,160(sp)
    8000535e:	b785                	j	800052be <sys_open+0x132>
    f->type = FD_DEVICE;
    80005360:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    80005364:	04649783          	lh	a5,70(s1)
    80005368:	02f91223          	sh	a5,36(s2)
    8000536c:	bf01                	j	8000527c <sys_open+0xf0>
    itrunc(ip);
    8000536e:	8526                	mv	a0,s1
    80005370:	852fe0ef          	jal	800033c2 <itrunc>
    80005374:	bf25                	j	800052ac <sys_open+0x120>

0000000080005376 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005376:	7175                	addi	sp,sp,-144
    80005378:	e506                	sd	ra,136(sp)
    8000537a:	e122                	sd	s0,128(sp)
    8000537c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000537e:	967fe0ef          	jal	80003ce4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005382:	08000613          	li	a2,128
    80005386:	f7040593          	addi	a1,s0,-144
    8000538a:	4501                	li	a0,0
    8000538c:	d4efd0ef          	jal	800028da <argstr>
    80005390:	02054363          	bltz	a0,800053b6 <sys_mkdir+0x40>
    80005394:	4681                	li	a3,0
    80005396:	4601                	li	a2,0
    80005398:	4585                	li	a1,1
    8000539a:	f7040513          	addi	a0,s0,-144
    8000539e:	8dfff0ef          	jal	80004c7c <create>
    800053a2:	c911                	beqz	a0,800053b6 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800053a4:	93cfe0ef          	jal	800034e0 <iunlockput>
  end_op();
    800053a8:	9adfe0ef          	jal	80003d54 <end_op>
  return 0;
    800053ac:	4501                	li	a0,0
}
    800053ae:	60aa                	ld	ra,136(sp)
    800053b0:	640a                	ld	s0,128(sp)
    800053b2:	6149                	addi	sp,sp,144
    800053b4:	8082                	ret
    end_op();
    800053b6:	99ffe0ef          	jal	80003d54 <end_op>
    return -1;
    800053ba:	557d                	li	a0,-1
    800053bc:	bfcd                	j	800053ae <sys_mkdir+0x38>

00000000800053be <sys_mknod>:

uint64
sys_mknod(void)
{
    800053be:	7135                	addi	sp,sp,-160
    800053c0:	ed06                	sd	ra,152(sp)
    800053c2:	e922                	sd	s0,144(sp)
    800053c4:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800053c6:	91ffe0ef          	jal	80003ce4 <begin_op>
  argint(1, &major);
    800053ca:	f6c40593          	addi	a1,s0,-148
    800053ce:	4505                	li	a0,1
    800053d0:	ccefd0ef          	jal	8000289e <argint>
  argint(2, &minor);
    800053d4:	f6840593          	addi	a1,s0,-152
    800053d8:	4509                	li	a0,2
    800053da:	cc4fd0ef          	jal	8000289e <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800053de:	08000613          	li	a2,128
    800053e2:	f7040593          	addi	a1,s0,-144
    800053e6:	4501                	li	a0,0
    800053e8:	cf2fd0ef          	jal	800028da <argstr>
    800053ec:	02054563          	bltz	a0,80005416 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800053f0:	f6841683          	lh	a3,-152(s0)
    800053f4:	f6c41603          	lh	a2,-148(s0)
    800053f8:	458d                	li	a1,3
    800053fa:	f7040513          	addi	a0,s0,-144
    800053fe:	87fff0ef          	jal	80004c7c <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005402:	c911                	beqz	a0,80005416 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005404:	8dcfe0ef          	jal	800034e0 <iunlockput>
  end_op();
    80005408:	94dfe0ef          	jal	80003d54 <end_op>
  return 0;
    8000540c:	4501                	li	a0,0
}
    8000540e:	60ea                	ld	ra,152(sp)
    80005410:	644a                	ld	s0,144(sp)
    80005412:	610d                	addi	sp,sp,160
    80005414:	8082                	ret
    end_op();
    80005416:	93ffe0ef          	jal	80003d54 <end_op>
    return -1;
    8000541a:	557d                	li	a0,-1
    8000541c:	bfcd                	j	8000540e <sys_mknod+0x50>

000000008000541e <sys_chdir>:

uint64
sys_chdir(void)
{
    8000541e:	7135                	addi	sp,sp,-160
    80005420:	ed06                	sd	ra,152(sp)
    80005422:	e922                	sd	s0,144(sp)
    80005424:	e14a                	sd	s2,128(sp)
    80005426:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005428:	d0efc0ef          	jal	80001936 <myproc>
    8000542c:	892a                	mv	s2,a0
  
  begin_op();
    8000542e:	8b7fe0ef          	jal	80003ce4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005432:	08000613          	li	a2,128
    80005436:	f6040593          	addi	a1,s0,-160
    8000543a:	4501                	li	a0,0
    8000543c:	c9efd0ef          	jal	800028da <argstr>
    80005440:	04054363          	bltz	a0,80005486 <sys_chdir+0x68>
    80005444:	e526                	sd	s1,136(sp)
    80005446:	f6040513          	addi	a0,s0,-160
    8000544a:	ebcfe0ef          	jal	80003b06 <namei>
    8000544e:	84aa                	mv	s1,a0
    80005450:	c915                	beqz	a0,80005484 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005452:	e61fd0ef          	jal	800032b2 <ilock>
  if(ip->type != T_DIR){
    80005456:	04449703          	lh	a4,68(s1)
    8000545a:	4785                	li	a5,1
    8000545c:	02f71963          	bne	a4,a5,8000548e <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005460:	8526                	mv	a0,s1
    80005462:	f21fd0ef          	jal	80003382 <iunlock>
  iput(p->cwd);
    80005466:	15093503          	ld	a0,336(s2)
    8000546a:	fedfd0ef          	jal	80003456 <iput>
  end_op();
    8000546e:	8e7fe0ef          	jal	80003d54 <end_op>
  p->cwd = ip;
    80005472:	14993823          	sd	s1,336(s2)
  return 0;
    80005476:	4501                	li	a0,0
    80005478:	64aa                	ld	s1,136(sp)
}
    8000547a:	60ea                	ld	ra,152(sp)
    8000547c:	644a                	ld	s0,144(sp)
    8000547e:	690a                	ld	s2,128(sp)
    80005480:	610d                	addi	sp,sp,160
    80005482:	8082                	ret
    80005484:	64aa                	ld	s1,136(sp)
    end_op();
    80005486:	8cffe0ef          	jal	80003d54 <end_op>
    return -1;
    8000548a:	557d                	li	a0,-1
    8000548c:	b7fd                	j	8000547a <sys_chdir+0x5c>
    iunlockput(ip);
    8000548e:	8526                	mv	a0,s1
    80005490:	850fe0ef          	jal	800034e0 <iunlockput>
    end_op();
    80005494:	8c1fe0ef          	jal	80003d54 <end_op>
    return -1;
    80005498:	557d                	li	a0,-1
    8000549a:	64aa                	ld	s1,136(sp)
    8000549c:	bff9                	j	8000547a <sys_chdir+0x5c>

000000008000549e <sys_exec>:

uint64
sys_exec(void)
{
    8000549e:	7105                	addi	sp,sp,-480
    800054a0:	ef86                	sd	ra,472(sp)
    800054a2:	eba2                	sd	s0,464(sp)
    800054a4:	eb62                	sd	s8,400(sp)
    800054a6:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;
  struct proc *p = myproc();
    800054a8:	c8efc0ef          	jal	80001936 <myproc>
    800054ac:	8c2a                	mv	s8,a0

  argaddr(1, &uargv);
    800054ae:	e2840593          	addi	a1,s0,-472
    800054b2:	4505                	li	a0,1
    800054b4:	c08fd0ef          	jal	800028bc <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800054b8:	08000613          	li	a2,128
    800054bc:	f3040593          	addi	a1,s0,-208
    800054c0:	4501                	li	a0,0
    800054c2:	c18fd0ef          	jal	800028da <argstr>
    800054c6:	87aa                	mv	a5,a0
    return -1;
    800054c8:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800054ca:	1207c663          	bltz	a5,800055f6 <sys_exec+0x158>
    800054ce:	e7a6                	sd	s1,456(sp)
    800054d0:	e3ca                	sd	s2,448(sp)
    800054d2:	ff4e                	sd	s3,440(sp)
    800054d4:	fb52                	sd	s4,432(sp)
    800054d6:	f756                	sd	s5,424(sp)
    800054d8:	f35a                	sd	s6,416(sp)
    800054da:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    800054dc:	e3040a13          	addi	s4,s0,-464
    800054e0:	10000613          	li	a2,256
    800054e4:	4581                	li	a1,0
    800054e6:	8552                	mv	a0,s4
    800054e8:	811fb0ef          	jal	80000cf8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800054ec:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    800054ee:	89d2                	mv	s3,s4
    800054f0:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800054f2:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800054f6:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    800054f8:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800054fc:	00391793          	slli	a5,s2,0x3
    80005500:	85d6                	mv	a1,s5
    80005502:	e2843503          	ld	a0,-472(s0)
    80005506:	953e                	add	a0,a0,a5
    80005508:	b0cfd0ef          	jal	80002814 <fetchaddr>
    8000550c:	02054663          	bltz	a0,80005538 <sys_exec+0x9a>
    if(uarg == 0){
    80005510:	e2043783          	ld	a5,-480(s0)
    80005514:	c7a1                	beqz	a5,8000555c <sys_exec+0xbe>
    argv[i] = kalloc();
    80005516:	e2efb0ef          	jal	80000b44 <kalloc>
    8000551a:	85aa                	mv	a1,a0
    8000551c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005520:	cd01                	beqz	a0,80005538 <sys_exec+0x9a>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005522:	865a                	mv	a2,s6
    80005524:	e2043503          	ld	a0,-480(s0)
    80005528:	b36fd0ef          	jal	8000285e <fetchstr>
    8000552c:	00054663          	bltz	a0,80005538 <sys_exec+0x9a>
    if(i >= NELEM(argv)){
    80005530:	0905                	addi	s2,s2,1
    80005532:	09a1                	addi	s3,s3,8
    80005534:	fd7914e3          	bne	s2,s7,800054fc <sys_exec+0x5e>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005538:	100a0a13          	addi	s4,s4,256
    8000553c:	6088                	ld	a0,0(s1)
    8000553e:	c545                	beqz	a0,800055e6 <sys_exec+0x148>
    kfree(argv[i]);
    80005540:	d1cfb0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005544:	04a1                	addi	s1,s1,8
    80005546:	ff449be3          	bne	s1,s4,8000553c <sys_exec+0x9e>
  return -1;
    8000554a:	557d                	li	a0,-1
    8000554c:	64be                	ld	s1,456(sp)
    8000554e:	691e                	ld	s2,448(sp)
    80005550:	79fa                	ld	s3,440(sp)
    80005552:	7a5a                	ld	s4,432(sp)
    80005554:	7aba                	ld	s5,424(sp)
    80005556:	7b1a                	ld	s6,416(sp)
    80005558:	6bfa                	ld	s7,408(sp)
    8000555a:	a871                	j	800055f6 <sys_exec+0x158>
      argv[i] = 0;
    8000555c:	0009079b          	sext.w	a5,s2
    80005560:	078e                	slli	a5,a5,0x3
    80005562:	fb078793          	addi	a5,a5,-80
    80005566:	97a2                	add	a5,a5,s0
    80005568:	e807b023          	sd	zero,-384(a5)
  struct inode *ip = namei(path);
    8000556c:	f3040513          	addi	a0,s0,-208
    80005570:	d96fe0ef          	jal	80003b06 <namei>
    80005574:	892a                	mv	s2,a0
  if (ip) {
    80005576:	c105                	beqz	a0,80005596 <sys_exec+0xf8>
    ilock(ip);
    80005578:	d3bfd0ef          	jal	800032b2 <ilock>
    if (check_permission(ip, 4 /*execute*/, p->creds.uid, p->creds.gid) < 0) {
    8000557c:	16cc2683          	lw	a3,364(s8)
    80005580:	168c2603          	lw	a2,360(s8)
    80005584:	4591                	li	a1,4
    80005586:	854a                	mv	a0,s2
    80005588:	ab9fe0ef          	jal	80004040 <check_permission>
    8000558c:	02054e63          	bltz	a0,800055c8 <sys_exec+0x12a>
    iunlockput(ip);
    80005590:	854a                	mv	a0,s2
    80005592:	f4ffd0ef          	jal	800034e0 <iunlockput>
  int ret = kexec(path, argv);
    80005596:	e3040593          	addi	a1,s0,-464
    8000559a:	f3040513          	addi	a0,s0,-208
    8000559e:	ae8ff0ef          	jal	80004886 <kexec>
    800055a2:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800055a4:	100a0a13          	addi	s4,s4,256
    800055a8:	6088                	ld	a0,0(s1)
    800055aa:	c511                	beqz	a0,800055b6 <sys_exec+0x118>
    kfree(argv[i]);
    800055ac:	cb0fb0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800055b0:	04a1                	addi	s1,s1,8
    800055b2:	ff449be3          	bne	s1,s4,800055a8 <sys_exec+0x10a>
  return ret;
    800055b6:	854a                	mv	a0,s2
    800055b8:	64be                	ld	s1,456(sp)
    800055ba:	691e                	ld	s2,448(sp)
    800055bc:	79fa                	ld	s3,440(sp)
    800055be:	7a5a                	ld	s4,432(sp)
    800055c0:	7aba                	ld	s5,424(sp)
    800055c2:	7b1a                	ld	s6,416(sp)
    800055c4:	6bfa                	ld	s7,408(sp)
    800055c6:	a805                	j	800055f6 <sys_exec+0x158>
      iunlockput(ip);
    800055c8:	854a                	mv	a0,s2
    800055ca:	f17fd0ef          	jal	800034e0 <iunlockput>
      audit_log_event(p->pid, p->creds.uid, SYS_exec, "DENIED:exec_permission");
    800055ce:	00003697          	auipc	a3,0x3
    800055d2:	0e268693          	addi	a3,a3,226 # 800086b0 <etext+0x6b0>
    800055d6:	461d                	li	a2,7
    800055d8:	168c2583          	lw	a1,360(s8)
    800055dc:	030c2503          	lw	a0,48(s8)
    800055e0:	004010ef          	jal	800065e4 <audit_log_event>
      goto bad;
    800055e4:	bf91                	j	80005538 <sys_exec+0x9a>
  return -1;
    800055e6:	557d                	li	a0,-1
    800055e8:	64be                	ld	s1,456(sp)
    800055ea:	691e                	ld	s2,448(sp)
    800055ec:	79fa                	ld	s3,440(sp)
    800055ee:	7a5a                	ld	s4,432(sp)
    800055f0:	7aba                	ld	s5,424(sp)
    800055f2:	7b1a                	ld	s6,416(sp)
    800055f4:	6bfa                	ld	s7,408(sp)
}
    800055f6:	60fe                	ld	ra,472(sp)
    800055f8:	645e                	ld	s0,464(sp)
    800055fa:	6c5a                	ld	s8,400(sp)
    800055fc:	613d                	addi	sp,sp,480
    800055fe:	8082                	ret

0000000080005600 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005600:	7139                	addi	sp,sp,-64
    80005602:	fc06                	sd	ra,56(sp)
    80005604:	f822                	sd	s0,48(sp)
    80005606:	f426                	sd	s1,40(sp)
    80005608:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000560a:	b2cfc0ef          	jal	80001936 <myproc>
    8000560e:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005610:	fd840593          	addi	a1,s0,-40
    80005614:	4501                	li	a0,0
    80005616:	aa6fd0ef          	jal	800028bc <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000561a:	fc840593          	addi	a1,s0,-56
    8000561e:	fd040513          	addi	a0,s0,-48
    80005622:	f35fe0ef          	jal	80004556 <pipealloc>
    return -1;
    80005626:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005628:	0a054763          	bltz	a0,800056d6 <sys_pipe+0xd6>
  fd0 = -1;
    8000562c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005630:	fd043503          	ld	a0,-48(s0)
    80005634:	e08ff0ef          	jal	80004c3c <fdalloc>
    80005638:	fca42223          	sw	a0,-60(s0)
    8000563c:	08054463          	bltz	a0,800056c4 <sys_pipe+0xc4>
    80005640:	fc843503          	ld	a0,-56(s0)
    80005644:	df8ff0ef          	jal	80004c3c <fdalloc>
    80005648:	fca42023          	sw	a0,-64(s0)
    8000564c:	06054263          	bltz	a0,800056b0 <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005650:	4691                	li	a3,4
    80005652:	fc440613          	addi	a2,s0,-60
    80005656:	fd843583          	ld	a1,-40(s0)
    8000565a:	68a8                	ld	a0,80(s1)
    8000565c:	800fc0ef          	jal	8000165c <copyout>
    80005660:	00054e63          	bltz	a0,8000567c <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005664:	4691                	li	a3,4
    80005666:	fc040613          	addi	a2,s0,-64
    8000566a:	fd843583          	ld	a1,-40(s0)
    8000566e:	95b6                	add	a1,a1,a3
    80005670:	68a8                	ld	a0,80(s1)
    80005672:	febfb0ef          	jal	8000165c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005676:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005678:	04055f63          	bgez	a0,800056d6 <sys_pipe+0xd6>
    p->ofile[fd0] = 0;
    8000567c:	fc442783          	lw	a5,-60(s0)
    80005680:	078e                	slli	a5,a5,0x3
    80005682:	0d078793          	addi	a5,a5,208
    80005686:	97a6                	add	a5,a5,s1
    80005688:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000568c:	fc042783          	lw	a5,-64(s0)
    80005690:	078e                	slli	a5,a5,0x3
    80005692:	0d078793          	addi	a5,a5,208
    80005696:	97a6                	add	a5,a5,s1
    80005698:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000569c:	fd043503          	ld	a0,-48(s0)
    800056a0:	ad9fe0ef          	jal	80004178 <fileclose>
    fileclose(wf);
    800056a4:	fc843503          	ld	a0,-56(s0)
    800056a8:	ad1fe0ef          	jal	80004178 <fileclose>
    return -1;
    800056ac:	57fd                	li	a5,-1
    800056ae:	a025                	j	800056d6 <sys_pipe+0xd6>
    if(fd0 >= 0)
    800056b0:	fc442783          	lw	a5,-60(s0)
    800056b4:	0007c863          	bltz	a5,800056c4 <sys_pipe+0xc4>
      p->ofile[fd0] = 0;
    800056b8:	078e                	slli	a5,a5,0x3
    800056ba:	0d078793          	addi	a5,a5,208
    800056be:	97a6                	add	a5,a5,s1
    800056c0:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800056c4:	fd043503          	ld	a0,-48(s0)
    800056c8:	ab1fe0ef          	jal	80004178 <fileclose>
    fileclose(wf);
    800056cc:	fc843503          	ld	a0,-56(s0)
    800056d0:	aa9fe0ef          	jal	80004178 <fileclose>
    return -1;
    800056d4:	57fd                	li	a5,-1
}
    800056d6:	853e                	mv	a0,a5
    800056d8:	70e2                	ld	ra,56(sp)
    800056da:	7442                	ld	s0,48(sp)
    800056dc:	74a2                	ld	s1,40(sp)
    800056de:	6121                	addi	sp,sp,64
    800056e0:	8082                	ret

00000000800056e2 <secure_path>:
#include "proc.h"

// Helper: set permissions on a path (must be called with no locks held)
static void
secure_path(char *path, uint uid, uint gid, uint mode)
{
    800056e2:	7139                	addi	sp,sp,-64
    800056e4:	fc06                	sd	ra,56(sp)
    800056e6:	f822                	sd	s0,48(sp)
    800056e8:	f04a                	sd	s2,32(sp)
    800056ea:	ec4e                	sd	s3,24(sp)
    800056ec:	e852                	sd	s4,16(sp)
    800056ee:	e456                	sd	s5,8(sp)
    800056f0:	0080                	addi	s0,sp,64
    800056f2:	8aaa                	mv	s5,a0
    800056f4:	892e                	mv	s2,a1
    800056f6:	89b2                	mv	s3,a2
    800056f8:	8a36                	mv	s4,a3
    struct inode *ip = namei(path);
    800056fa:	c0cfe0ef          	jal	80003b06 <namei>
    if (ip == 0) {
    800056fe:	cd0d                	beqz	a0,80005738 <secure_path+0x56>
    80005700:	f426                	sd	s1,40(sp)
    80005702:	84aa                	mv	s1,a0
        printf("fsinit_security: warning: %s not found\n", path);
        return;
    }
    ilock(ip);
    80005704:	baffd0ef          	jal	800032b2 <ilock>
    ip->uid  = uid;
    80005708:	0924a423          	sw	s2,136(s1)
    ip->gid  = gid;
    8000570c:	0934a623          	sw	s3,140(s1)
    ip->mode = mode;
    80005710:	0944a223          	sw	s4,132(s1)
    iupdate(ip);
    80005714:	8526                	mv	a0,s1
    80005716:	acbfd0ef          	jal	800031e0 <iupdate>
    iunlock(ip);
    8000571a:	8526                	mv	a0,s1
    8000571c:	c67fd0ef          	jal	80003382 <iunlock>

    iput(ip);
    80005720:	8526                	mv	a0,s1
    80005722:	d35fd0ef          	jal	80003456 <iput>
    80005726:	74a2                	ld	s1,40(sp)
}
    80005728:	70e2                	ld	ra,56(sp)
    8000572a:	7442                	ld	s0,48(sp)
    8000572c:	7902                	ld	s2,32(sp)
    8000572e:	69e2                	ld	s3,24(sp)
    80005730:	6a42                	ld	s4,16(sp)
    80005732:	6aa2                	ld	s5,8(sp)
    80005734:	6121                	addi	sp,sp,64
    80005736:	8082                	ret
        printf("fsinit_security: warning: %s not found\n", path);
    80005738:	85d6                	mv	a1,s5
    8000573a:	00003517          	auipc	a0,0x3
    8000573e:	f8e50513          	addi	a0,a0,-114 # 800086c8 <etext+0x6c8>
    80005742:	db9fa0ef          	jal	800004fa <printf>
        return;
    80005746:	b7cd                	j	80005728 <secure_path+0x46>

0000000080005748 <fsinit_security>:

void
fsinit_security(void)
{
    80005748:	1141                	addi	sp,sp,-16
    8000574a:	e406                	sd	ra,8(sp)
    8000574c:	e022                	sd	s0,0(sp)
    8000574e:	0800                	addi	s0,sp,16
    // WHY these specific permissions (course rubric + PoLP):
    //
    // /records:
    //   uid=1 (PATIENT) read-only → mode=0400
    //   DOCTOR also needs read → use group bits: mode=0440, gid=2
    begin_op();
    80005750:	d94fe0ef          	jal	80003ce4 <begin_op>
    secure_path("/records",
    80005754:	12000693          	li	a3,288
    80005758:	4609                	li	a2,2
    8000575a:	4585                	li	a1,1
    8000575c:	00003517          	auipc	a0,0x3
    80005760:	f9450513          	addi	a0,a0,-108 # 800086f0 <etext+0x6f0>
    80005764:	f7fff0ef          	jal	800056e2 <secure_path>
                ROLE_DOCTOR  /*gid*/,
                0440 /*r--r-----*/);

    // /insulin.log:
    //   uid=2 (DOCTOR) Write, uid=1 (PATIENT) Read
    secure_path("/insulin.log",
    80005768:	1a000693          	li	a3,416
    8000576c:	4605                	li	a2,1
    8000576e:	4589                	li	a1,2
    80005770:	00003517          	auipc	a0,0x3
    80005774:	f9050513          	addi	a0,a0,-112 # 80008700 <etext+0x700>
    80005778:	f6bff0ef          	jal	800056e2 <secure_path>
                ROLE_PATIENT /*gid*/,
                0640 /*rw-r-----*/);

    // /config:
    //   UID 0 (ADMIN) only → mode=0600
    secure_path("/config",
    8000577c:	18000693          	li	a3,384
    80005780:	4601                	li	a2,0
    80005782:	4581                	li	a1,0
    80005784:	00003517          	auipc	a0,0x3
    80005788:	f8c50513          	addi	a0,a0,-116 # 80008710 <etext+0x710>
    8000578c:	f57ff0ef          	jal	800056e2 <secure_path>
                ROLE_ADMIN, ROLE_ADMIN,
                0600 /*rw-------*/);

    // /syscall.log:
    //   UID 0 (ADMIN) only → mode=0600 (read-write for persistent logging)
    secure_path("/syscall.log",
    80005790:	18000693          	li	a3,384
    80005794:	4601                	li	a2,0
    80005796:	4581                	li	a1,0
    80005798:	00003517          	auipc	a0,0x3
    8000579c:	f8050513          	addi	a0,a0,-128 # 80008718 <etext+0x718>
    800057a0:	f43ff0ef          	jal	800056e2 <secure_path>
                ROLE_ADMIN, ROLE_ADMIN,
                0600 /*rw-------*/);
    end_op();
    800057a4:	db0fe0ef          	jal	80003d54 <end_op>

    printf("fsinit_security: medical device file permissions applied\n");
    800057a8:	00003517          	auipc	a0,0x3
    800057ac:	f8050513          	addi	a0,a0,-128 # 80008728 <etext+0x728>
    800057b0:	d4bfa0ef          	jal	800004fa <printf>
}
    800057b4:	60a2                	ld	ra,8(sp)
    800057b6:	6402                	ld	s0,0(sp)
    800057b8:	0141                	addi	sp,sp,16
    800057ba:	8082                	ret
    800057bc:	0000                	unimp
	...

00000000800057c0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    800057c0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    800057c2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    800057c4:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    800057c6:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    800057c8:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    800057ca:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    800057cc:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    800057ce:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    800057d0:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    800057d2:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    800057d4:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    800057d6:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    800057d8:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    800057da:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    800057dc:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    800057de:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800057e0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800057e2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800057e4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800057e6:	f3dfc0ef          	jal	80002722 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800057ea:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800057ec:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800057ee:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800057f0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800057f2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800057f4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800057f6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800057f8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800057fa:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800057fc:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800057fe:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005800:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005802:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005804:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005806:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005808:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000580a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000580c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000580e:	10200073          	sret
    80005812:	00000013          	nop
    80005816:	00000013          	nop
    8000581a:	00000013          	nop

000000008000581e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000581e:	1141                	addi	sp,sp,-16
    80005820:	e406                	sd	ra,8(sp)
    80005822:	e022                	sd	s0,0(sp)
    80005824:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005826:	0c000737          	lui	a4,0xc000
    8000582a:	4785                	li	a5,1
    8000582c:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000582e:	c35c                	sw	a5,4(a4)
}
    80005830:	60a2                	ld	ra,8(sp)
    80005832:	6402                	ld	s0,0(sp)
    80005834:	0141                	addi	sp,sp,16
    80005836:	8082                	ret

0000000080005838 <plicinithart>:

void
plicinithart(void)
{
    80005838:	1141                	addi	sp,sp,-16
    8000583a:	e406                	sd	ra,8(sp)
    8000583c:	e022                	sd	s0,0(sp)
    8000583e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005840:	8c2fc0ef          	jal	80001902 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005844:	0085171b          	slliw	a4,a0,0x8
    80005848:	0c0027b7          	lui	a5,0xc002
    8000584c:	97ba                	add	a5,a5,a4
    8000584e:	40200713          	li	a4,1026
    80005852:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005856:	00d5151b          	slliw	a0,a0,0xd
    8000585a:	0c2017b7          	lui	a5,0xc201
    8000585e:	97aa                	add	a5,a5,a0
    80005860:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005864:	60a2                	ld	ra,8(sp)
    80005866:	6402                	ld	s0,0(sp)
    80005868:	0141                	addi	sp,sp,16
    8000586a:	8082                	ret

000000008000586c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000586c:	1141                	addi	sp,sp,-16
    8000586e:	e406                	sd	ra,8(sp)
    80005870:	e022                	sd	s0,0(sp)
    80005872:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005874:	88efc0ef          	jal	80001902 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005878:	00d5151b          	slliw	a0,a0,0xd
    8000587c:	0c2017b7          	lui	a5,0xc201
    80005880:	97aa                	add	a5,a5,a0
  return irq;
}
    80005882:	43c8                	lw	a0,4(a5)
    80005884:	60a2                	ld	ra,8(sp)
    80005886:	6402                	ld	s0,0(sp)
    80005888:	0141                	addi	sp,sp,16
    8000588a:	8082                	ret

000000008000588c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000588c:	1101                	addi	sp,sp,-32
    8000588e:	ec06                	sd	ra,24(sp)
    80005890:	e822                	sd	s0,16(sp)
    80005892:	e426                	sd	s1,8(sp)
    80005894:	1000                	addi	s0,sp,32
    80005896:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005898:	86afc0ef          	jal	80001902 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000589c:	00d5179b          	slliw	a5,a0,0xd
    800058a0:	0c201737          	lui	a4,0xc201
    800058a4:	97ba                	add	a5,a5,a4
    800058a6:	c3c4                	sw	s1,4(a5)
}
    800058a8:	60e2                	ld	ra,24(sp)
    800058aa:	6442                	ld	s0,16(sp)
    800058ac:	64a2                	ld	s1,8(sp)
    800058ae:	6105                	addi	sp,sp,32
    800058b0:	8082                	ret

00000000800058b2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800058b2:	1141                	addi	sp,sp,-16
    800058b4:	e406                	sd	ra,8(sp)
    800058b6:	e022                	sd	s0,0(sp)
    800058b8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800058ba:	479d                	li	a5,7
    800058bc:	04a7ca63          	blt	a5,a0,80005910 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800058c0:	0001d797          	auipc	a5,0x1d
    800058c4:	61878793          	addi	a5,a5,1560 # 80022ed8 <disk>
    800058c8:	97aa                	add	a5,a5,a0
    800058ca:	0187c783          	lbu	a5,24(a5)
    800058ce:	e7b9                	bnez	a5,8000591c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800058d0:	00451693          	slli	a3,a0,0x4
    800058d4:	0001d797          	auipc	a5,0x1d
    800058d8:	60478793          	addi	a5,a5,1540 # 80022ed8 <disk>
    800058dc:	6398                	ld	a4,0(a5)
    800058de:	9736                	add	a4,a4,a3
    800058e0:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    800058e4:	6398                	ld	a4,0(a5)
    800058e6:	9736                	add	a4,a4,a3
    800058e8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800058ec:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800058f0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800058f4:	97aa                	add	a5,a5,a0
    800058f6:	4705                	li	a4,1
    800058f8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800058fc:	0001d517          	auipc	a0,0x1d
    80005900:	5f450513          	addi	a0,a0,1524 # 80022ef0 <disk+0x18>
    80005904:	edafc0ef          	jal	80001fde <wakeup>
}
    80005908:	60a2                	ld	ra,8(sp)
    8000590a:	6402                	ld	s0,0(sp)
    8000590c:	0141                	addi	sp,sp,16
    8000590e:	8082                	ret
    panic("free_desc 1");
    80005910:	00003517          	auipc	a0,0x3
    80005914:	e5850513          	addi	a0,a0,-424 # 80008768 <etext+0x768>
    80005918:	f0dfa0ef          	jal	80000824 <panic>
    panic("free_desc 2");
    8000591c:	00003517          	auipc	a0,0x3
    80005920:	e5c50513          	addi	a0,a0,-420 # 80008778 <etext+0x778>
    80005924:	f01fa0ef          	jal	80000824 <panic>

0000000080005928 <virtio_disk_init>:
{
    80005928:	1101                	addi	sp,sp,-32
    8000592a:	ec06                	sd	ra,24(sp)
    8000592c:	e822                	sd	s0,16(sp)
    8000592e:	e426                	sd	s1,8(sp)
    80005930:	e04a                	sd	s2,0(sp)
    80005932:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005934:	00003597          	auipc	a1,0x3
    80005938:	e5458593          	addi	a1,a1,-428 # 80008788 <etext+0x788>
    8000593c:	0001d517          	auipc	a0,0x1d
    80005940:	6c450513          	addi	a0,a0,1732 # 80023000 <disk+0x128>
    80005944:	a5afb0ef          	jal	80000b9e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005948:	100017b7          	lui	a5,0x10001
    8000594c:	4398                	lw	a4,0(a5)
    8000594e:	2701                	sext.w	a4,a4
    80005950:	747277b7          	lui	a5,0x74727
    80005954:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005958:	14f71863          	bne	a4,a5,80005aa8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000595c:	100017b7          	lui	a5,0x10001
    80005960:	43dc                	lw	a5,4(a5)
    80005962:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005964:	4709                	li	a4,2
    80005966:	14e79163          	bne	a5,a4,80005aa8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000596a:	100017b7          	lui	a5,0x10001
    8000596e:	479c                	lw	a5,8(a5)
    80005970:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005972:	12e79b63          	bne	a5,a4,80005aa8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005976:	100017b7          	lui	a5,0x10001
    8000597a:	47d8                	lw	a4,12(a5)
    8000597c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000597e:	554d47b7          	lui	a5,0x554d4
    80005982:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005986:	12f71163          	bne	a4,a5,80005aa8 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000598a:	100017b7          	lui	a5,0x10001
    8000598e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005992:	4705                	li	a4,1
    80005994:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005996:	470d                	li	a4,3
    80005998:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000599a:	10001737          	lui	a4,0x10001
    8000599e:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800059a0:	c7ffe6b7          	lui	a3,0xc7ffe
    800059a4:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fcff7f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800059a8:	8f75                	and	a4,a4,a3
    800059aa:	100016b7          	lui	a3,0x10001
    800059ae:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    800059b0:	472d                	li	a4,11
    800059b2:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800059b4:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800059b8:	439c                	lw	a5,0(a5)
    800059ba:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800059be:	8ba1                	andi	a5,a5,8
    800059c0:	0e078a63          	beqz	a5,80005ab4 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800059c4:	100017b7          	lui	a5,0x10001
    800059c8:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800059cc:	43fc                	lw	a5,68(a5)
    800059ce:	2781                	sext.w	a5,a5
    800059d0:	0e079863          	bnez	a5,80005ac0 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800059d4:	100017b7          	lui	a5,0x10001
    800059d8:	5bdc                	lw	a5,52(a5)
    800059da:	2781                	sext.w	a5,a5
  if(max == 0)
    800059dc:	0e078863          	beqz	a5,80005acc <virtio_disk_init+0x1a4>
  if(max < NUM)
    800059e0:	471d                	li	a4,7
    800059e2:	0ef77b63          	bgeu	a4,a5,80005ad8 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    800059e6:	95efb0ef          	jal	80000b44 <kalloc>
    800059ea:	0001d497          	auipc	s1,0x1d
    800059ee:	4ee48493          	addi	s1,s1,1262 # 80022ed8 <disk>
    800059f2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800059f4:	950fb0ef          	jal	80000b44 <kalloc>
    800059f8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800059fa:	94afb0ef          	jal	80000b44 <kalloc>
    800059fe:	87aa                	mv	a5,a0
    80005a00:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005a02:	6088                	ld	a0,0(s1)
    80005a04:	0e050063          	beqz	a0,80005ae4 <virtio_disk_init+0x1bc>
    80005a08:	0001d717          	auipc	a4,0x1d
    80005a0c:	4d873703          	ld	a4,1240(a4) # 80022ee0 <disk+0x8>
    80005a10:	cb71                	beqz	a4,80005ae4 <virtio_disk_init+0x1bc>
    80005a12:	cbe9                	beqz	a5,80005ae4 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005a14:	6605                	lui	a2,0x1
    80005a16:	4581                	li	a1,0
    80005a18:	ae0fb0ef          	jal	80000cf8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005a1c:	0001d497          	auipc	s1,0x1d
    80005a20:	4bc48493          	addi	s1,s1,1212 # 80022ed8 <disk>
    80005a24:	6605                	lui	a2,0x1
    80005a26:	4581                	li	a1,0
    80005a28:	6488                	ld	a0,8(s1)
    80005a2a:	acefb0ef          	jal	80000cf8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005a2e:	6605                	lui	a2,0x1
    80005a30:	4581                	li	a1,0
    80005a32:	6888                	ld	a0,16(s1)
    80005a34:	ac4fb0ef          	jal	80000cf8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005a38:	100017b7          	lui	a5,0x10001
    80005a3c:	4721                	li	a4,8
    80005a3e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005a40:	4098                	lw	a4,0(s1)
    80005a42:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005a46:	40d8                	lw	a4,4(s1)
    80005a48:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005a4c:	649c                	ld	a5,8(s1)
    80005a4e:	0007869b          	sext.w	a3,a5
    80005a52:	10001737          	lui	a4,0x10001
    80005a56:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005a5a:	9781                	srai	a5,a5,0x20
    80005a5c:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005a60:	689c                	ld	a5,16(s1)
    80005a62:	0007869b          	sext.w	a3,a5
    80005a66:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005a6a:	9781                	srai	a5,a5,0x20
    80005a6c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005a70:	4785                	li	a5,1
    80005a72:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005a74:	00f48c23          	sb	a5,24(s1)
    80005a78:	00f48ca3          	sb	a5,25(s1)
    80005a7c:	00f48d23          	sb	a5,26(s1)
    80005a80:	00f48da3          	sb	a5,27(s1)
    80005a84:	00f48e23          	sb	a5,28(s1)
    80005a88:	00f48ea3          	sb	a5,29(s1)
    80005a8c:	00f48f23          	sb	a5,30(s1)
    80005a90:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005a94:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005a98:	07272823          	sw	s2,112(a4)
}
    80005a9c:	60e2                	ld	ra,24(sp)
    80005a9e:	6442                	ld	s0,16(sp)
    80005aa0:	64a2                	ld	s1,8(sp)
    80005aa2:	6902                	ld	s2,0(sp)
    80005aa4:	6105                	addi	sp,sp,32
    80005aa6:	8082                	ret
    panic("could not find virtio disk");
    80005aa8:	00003517          	auipc	a0,0x3
    80005aac:	cf050513          	addi	a0,a0,-784 # 80008798 <etext+0x798>
    80005ab0:	d75fa0ef          	jal	80000824 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005ab4:	00003517          	auipc	a0,0x3
    80005ab8:	d0450513          	addi	a0,a0,-764 # 800087b8 <etext+0x7b8>
    80005abc:	d69fa0ef          	jal	80000824 <panic>
    panic("virtio disk should not be ready");
    80005ac0:	00003517          	auipc	a0,0x3
    80005ac4:	d1850513          	addi	a0,a0,-744 # 800087d8 <etext+0x7d8>
    80005ac8:	d5dfa0ef          	jal	80000824 <panic>
    panic("virtio disk has no queue 0");
    80005acc:	00003517          	auipc	a0,0x3
    80005ad0:	d2c50513          	addi	a0,a0,-724 # 800087f8 <etext+0x7f8>
    80005ad4:	d51fa0ef          	jal	80000824 <panic>
    panic("virtio disk max queue too short");
    80005ad8:	00003517          	auipc	a0,0x3
    80005adc:	d4050513          	addi	a0,a0,-704 # 80008818 <etext+0x818>
    80005ae0:	d45fa0ef          	jal	80000824 <panic>
    panic("virtio disk kalloc");
    80005ae4:	00003517          	auipc	a0,0x3
    80005ae8:	d5450513          	addi	a0,a0,-684 # 80008838 <etext+0x838>
    80005aec:	d39fa0ef          	jal	80000824 <panic>

0000000080005af0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005af0:	711d                	addi	sp,sp,-96
    80005af2:	ec86                	sd	ra,88(sp)
    80005af4:	e8a2                	sd	s0,80(sp)
    80005af6:	e4a6                	sd	s1,72(sp)
    80005af8:	e0ca                	sd	s2,64(sp)
    80005afa:	fc4e                	sd	s3,56(sp)
    80005afc:	f852                	sd	s4,48(sp)
    80005afe:	f456                	sd	s5,40(sp)
    80005b00:	f05a                	sd	s6,32(sp)
    80005b02:	ec5e                	sd	s7,24(sp)
    80005b04:	e862                	sd	s8,16(sp)
    80005b06:	1080                	addi	s0,sp,96
    80005b08:	89aa                	mv	s3,a0
    80005b0a:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005b0c:	00c52b83          	lw	s7,12(a0)
    80005b10:	001b9b9b          	slliw	s7,s7,0x1
    80005b14:	1b82                	slli	s7,s7,0x20
    80005b16:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005b1a:	0001d517          	auipc	a0,0x1d
    80005b1e:	4e650513          	addi	a0,a0,1254 # 80023000 <disk+0x128>
    80005b22:	906fb0ef          	jal	80000c28 <acquire>
  for(int i = 0; i < NUM; i++){
    80005b26:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005b28:	0001da97          	auipc	s5,0x1d
    80005b2c:	3b0a8a93          	addi	s5,s5,944 # 80022ed8 <disk>
  for(int i = 0; i < 3; i++){
    80005b30:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005b32:	5c7d                	li	s8,-1
    80005b34:	a095                	j	80005b98 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    80005b36:	00fa8733          	add	a4,s5,a5
    80005b3a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005b3e:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005b40:	0207c563          	bltz	a5,80005b6a <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    80005b44:	2905                	addiw	s2,s2,1
    80005b46:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005b48:	05490c63          	beq	s2,s4,80005ba0 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    80005b4c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005b4e:	0001d717          	auipc	a4,0x1d
    80005b52:	38a70713          	addi	a4,a4,906 # 80022ed8 <disk>
    80005b56:	4781                	li	a5,0
    if(disk.free[i]){
    80005b58:	01874683          	lbu	a3,24(a4)
    80005b5c:	fee9                	bnez	a3,80005b36 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    80005b5e:	2785                	addiw	a5,a5,1
    80005b60:	0705                	addi	a4,a4,1
    80005b62:	fe979be3          	bne	a5,s1,80005b58 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005b66:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    80005b6a:	01205d63          	blez	s2,80005b84 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005b6e:	fa042503          	lw	a0,-96(s0)
    80005b72:	d41ff0ef          	jal	800058b2 <free_desc>
      for(int j = 0; j < i; j++)
    80005b76:	4785                	li	a5,1
    80005b78:	0127d663          	bge	a5,s2,80005b84 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005b7c:	fa442503          	lw	a0,-92(s0)
    80005b80:	d33ff0ef          	jal	800058b2 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005b84:	0001d597          	auipc	a1,0x1d
    80005b88:	47c58593          	addi	a1,a1,1148 # 80023000 <disk+0x128>
    80005b8c:	0001d517          	auipc	a0,0x1d
    80005b90:	36450513          	addi	a0,a0,868 # 80022ef0 <disk+0x18>
    80005b94:	bfefc0ef          	jal	80001f92 <sleep>
  for(int i = 0; i < 3; i++){
    80005b98:	fa040613          	addi	a2,s0,-96
    80005b9c:	4901                	li	s2,0
    80005b9e:	b77d                	j	80005b4c <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005ba0:	fa042503          	lw	a0,-96(s0)
    80005ba4:	00451693          	slli	a3,a0,0x4

  if(write)
    80005ba8:	0001d797          	auipc	a5,0x1d
    80005bac:	33078793          	addi	a5,a5,816 # 80022ed8 <disk>
    80005bb0:	00451713          	slli	a4,a0,0x4
    80005bb4:	0a070713          	addi	a4,a4,160
    80005bb8:	973e                	add	a4,a4,a5
    80005bba:	01603633          	snez	a2,s6
    80005bbe:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005bc0:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005bc4:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005bc8:	6398                	ld	a4,0(a5)
    80005bca:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005bcc:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005bd0:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005bd2:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005bd4:	6390                	ld	a2,0(a5)
    80005bd6:	00d60833          	add	a6,a2,a3
    80005bda:	4741                	li	a4,16
    80005bdc:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005be0:	4585                	li	a1,1
    80005be2:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005be6:	fa442703          	lw	a4,-92(s0)
    80005bea:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005bee:	0712                	slli	a4,a4,0x4
    80005bf0:	963a                	add	a2,a2,a4
    80005bf2:	05898813          	addi	a6,s3,88
    80005bf6:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005bfa:	0007b883          	ld	a7,0(a5)
    80005bfe:	9746                	add	a4,a4,a7
    80005c00:	40000613          	li	a2,1024
    80005c04:	c710                	sw	a2,8(a4)
  if(write)
    80005c06:	001b3613          	seqz	a2,s6
    80005c0a:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005c0e:	8e4d                	or	a2,a2,a1
    80005c10:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005c14:	fa842603          	lw	a2,-88(s0)
    80005c18:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005c1c:	00451813          	slli	a6,a0,0x4
    80005c20:	02080813          	addi	a6,a6,32
    80005c24:	983e                	add	a6,a6,a5
    80005c26:	577d                	li	a4,-1
    80005c28:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005c2c:	0612                	slli	a2,a2,0x4
    80005c2e:	98b2                	add	a7,a7,a2
    80005c30:	03068713          	addi	a4,a3,48
    80005c34:	973e                	add	a4,a4,a5
    80005c36:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005c3a:	6398                	ld	a4,0(a5)
    80005c3c:	9732                	add	a4,a4,a2
    80005c3e:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005c40:	4689                	li	a3,2
    80005c42:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005c46:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005c4a:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005c4e:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005c52:	6794                	ld	a3,8(a5)
    80005c54:	0026d703          	lhu	a4,2(a3)
    80005c58:	8b1d                	andi	a4,a4,7
    80005c5a:	0706                	slli	a4,a4,0x1
    80005c5c:	96ba                	add	a3,a3,a4
    80005c5e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005c62:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005c66:	6798                	ld	a4,8(a5)
    80005c68:	00275783          	lhu	a5,2(a4)
    80005c6c:	2785                	addiw	a5,a5,1
    80005c6e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005c72:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005c76:	100017b7          	lui	a5,0x10001
    80005c7a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005c7e:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    80005c82:	0001d917          	auipc	s2,0x1d
    80005c86:	37e90913          	addi	s2,s2,894 # 80023000 <disk+0x128>
  while(b->disk == 1) {
    80005c8a:	84ae                	mv	s1,a1
    80005c8c:	00b79a63          	bne	a5,a1,80005ca0 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005c90:	85ca                	mv	a1,s2
    80005c92:	854e                	mv	a0,s3
    80005c94:	afefc0ef          	jal	80001f92 <sleep>
  while(b->disk == 1) {
    80005c98:	0049a783          	lw	a5,4(s3)
    80005c9c:	fe978ae3          	beq	a5,s1,80005c90 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005ca0:	fa042903          	lw	s2,-96(s0)
    80005ca4:	00491713          	slli	a4,s2,0x4
    80005ca8:	02070713          	addi	a4,a4,32
    80005cac:	0001d797          	auipc	a5,0x1d
    80005cb0:	22c78793          	addi	a5,a5,556 # 80022ed8 <disk>
    80005cb4:	97ba                	add	a5,a5,a4
    80005cb6:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005cba:	0001d997          	auipc	s3,0x1d
    80005cbe:	21e98993          	addi	s3,s3,542 # 80022ed8 <disk>
    80005cc2:	00491713          	slli	a4,s2,0x4
    80005cc6:	0009b783          	ld	a5,0(s3)
    80005cca:	97ba                	add	a5,a5,a4
    80005ccc:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005cd0:	854a                	mv	a0,s2
    80005cd2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005cd6:	bddff0ef          	jal	800058b2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005cda:	8885                	andi	s1,s1,1
    80005cdc:	f0fd                	bnez	s1,80005cc2 <virtio_disk_rw+0x1d2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005cde:	0001d517          	auipc	a0,0x1d
    80005ce2:	32250513          	addi	a0,a0,802 # 80023000 <disk+0x128>
    80005ce6:	fd7fa0ef          	jal	80000cbc <release>
}
    80005cea:	60e6                	ld	ra,88(sp)
    80005cec:	6446                	ld	s0,80(sp)
    80005cee:	64a6                	ld	s1,72(sp)
    80005cf0:	6906                	ld	s2,64(sp)
    80005cf2:	79e2                	ld	s3,56(sp)
    80005cf4:	7a42                	ld	s4,48(sp)
    80005cf6:	7aa2                	ld	s5,40(sp)
    80005cf8:	7b02                	ld	s6,32(sp)
    80005cfa:	6be2                	ld	s7,24(sp)
    80005cfc:	6c42                	ld	s8,16(sp)
    80005cfe:	6125                	addi	sp,sp,96
    80005d00:	8082                	ret

0000000080005d02 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005d02:	1101                	addi	sp,sp,-32
    80005d04:	ec06                	sd	ra,24(sp)
    80005d06:	e822                	sd	s0,16(sp)
    80005d08:	e426                	sd	s1,8(sp)
    80005d0a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005d0c:	0001d497          	auipc	s1,0x1d
    80005d10:	1cc48493          	addi	s1,s1,460 # 80022ed8 <disk>
    80005d14:	0001d517          	auipc	a0,0x1d
    80005d18:	2ec50513          	addi	a0,a0,748 # 80023000 <disk+0x128>
    80005d1c:	f0dfa0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005d20:	100017b7          	lui	a5,0x10001
    80005d24:	53bc                	lw	a5,96(a5)
    80005d26:	8b8d                	andi	a5,a5,3
    80005d28:	10001737          	lui	a4,0x10001
    80005d2c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005d2e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005d32:	689c                	ld	a5,16(s1)
    80005d34:	0204d703          	lhu	a4,32(s1)
    80005d38:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005d3c:	04f70863          	beq	a4,a5,80005d8c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80005d40:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005d44:	6898                	ld	a4,16(s1)
    80005d46:	0204d783          	lhu	a5,32(s1)
    80005d4a:	8b9d                	andi	a5,a5,7
    80005d4c:	078e                	slli	a5,a5,0x3
    80005d4e:	97ba                	add	a5,a5,a4
    80005d50:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005d52:	00479713          	slli	a4,a5,0x4
    80005d56:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005d5a:	9726                	add	a4,a4,s1
    80005d5c:	01074703          	lbu	a4,16(a4)
    80005d60:	e329                	bnez	a4,80005da2 <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005d62:	0792                	slli	a5,a5,0x4
    80005d64:	02078793          	addi	a5,a5,32
    80005d68:	97a6                	add	a5,a5,s1
    80005d6a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005d6c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005d70:	a6efc0ef          	jal	80001fde <wakeup>

    disk.used_idx += 1;
    80005d74:	0204d783          	lhu	a5,32(s1)
    80005d78:	2785                	addiw	a5,a5,1
    80005d7a:	17c2                	slli	a5,a5,0x30
    80005d7c:	93c1                	srli	a5,a5,0x30
    80005d7e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005d82:	6898                	ld	a4,16(s1)
    80005d84:	00275703          	lhu	a4,2(a4)
    80005d88:	faf71ce3          	bne	a4,a5,80005d40 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005d8c:	0001d517          	auipc	a0,0x1d
    80005d90:	27450513          	addi	a0,a0,628 # 80023000 <disk+0x128>
    80005d94:	f29fa0ef          	jal	80000cbc <release>
}
    80005d98:	60e2                	ld	ra,24(sp)
    80005d9a:	6442                	ld	s0,16(sp)
    80005d9c:	64a2                	ld	s1,8(sp)
    80005d9e:	6105                	addi	sp,sp,32
    80005da0:	8082                	ret
      panic("virtio_disk_intr status");
    80005da2:	00003517          	auipc	a0,0x3
    80005da6:	aae50513          	addi	a0,a0,-1362 # 80008850 <etext+0x850>
    80005daa:	a7bfa0ef          	jal	80000824 <panic>

0000000080005dae <hash_password>:
// so we use a polynomial hash. Note this in your report as a
// known limitation with a recommendation to use SHA-256.
// =============================================================
void
hash_password(const char *password, char *out_hash)
{
    80005dae:	7179                	addi	sp,sp,-48
    80005db0:	f406                	sd	ra,40(sp)
    80005db2:	f022                	sd	s0,32(sp)
    80005db4:	1800                	addi	s0,sp,48
    uint64 h = 5381;
    int c;
    const char *p = password;

    while ((c = *p++) != 0) {
    80005db6:	00054703          	lbu	a4,0(a0)
    80005dba:	cf25                	beqz	a4,80005e32 <hash_password+0x84>
    80005dbc:	00150793          	addi	a5,a0,1
    uint64 h = 5381;
    80005dc0:	6685                	lui	a3,0x1
    80005dc2:	50568693          	addi	a3,a3,1285 # 1505 <_entry-0x7fffeafb>
        h = ((h << 5) + h) + c;  // h * 33 + c (djb2)
    80005dc6:	00569613          	slli	a2,a3,0x5
    80005dca:	96b2                	add	a3,a3,a2
    80005dcc:	96ba                	add	a3,a3,a4
    while ((c = *p++) != 0) {
    80005dce:	0785                	addi	a5,a5,1
    80005dd0:	fff7c703          	lbu	a4,-1(a5)
    80005dd4:	fb6d                	bnez	a4,80005dc6 <hash_password+0x18>
    }

    // Encode as 16-char hex string
    // In production: replace with proper cryptographic hash
    char hex[] = "0123456789abcdef";
    80005dd6:	00003797          	auipc	a5,0x3
    80005dda:	a9278793          	addi	a5,a5,-1390 # 80008868 <etext+0x868>
    80005dde:	6398                	ld	a4,0(a5)
    80005de0:	fce43c23          	sd	a4,-40(s0)
    80005de4:	6798                	ld	a4,8(a5)
    80005de6:	fee43023          	sd	a4,-32(s0)
    80005dea:	0107c783          	lbu	a5,16(a5)
    80005dee:	fef40423          	sb	a5,-24(s0)
    for (int i = 0; i < 16; i++) {
    80005df2:	862e                	mv	a2,a1
    char hex[] = "0123456789abcdef";
    80005df4:	03c00793          	li	a5,60
    for (int i = 0; i < 16; i++) {
    80005df8:	5571                	li	a0,-4
        out_hash[i * 2]     = hex[(h >> (60 - i * 4)) & 0xF];
    80005dfa:	00f6d733          	srl	a4,a3,a5
    80005dfe:	8b3d                	andi	a4,a4,15
    80005e00:	1741                	addi	a4,a4,-16
    80005e02:	9722                	add	a4,a4,s0
    80005e04:	fe874703          	lbu	a4,-24(a4)
    80005e08:	00e60023          	sb	a4,0(a2)
        out_hash[i * 2 + 1] = hex[(h >> (56 - i * 4)) & 0xF];
    80005e0c:	37f1                	addiw	a5,a5,-4
    80005e0e:	00f6d733          	srl	a4,a3,a5
    80005e12:	8b3d                	andi	a4,a4,15
    80005e14:	1741                	addi	a4,a4,-16
    80005e16:	9722                	add	a4,a4,s0
    80005e18:	fe874703          	lbu	a4,-24(a4)
    80005e1c:	00e600a3          	sb	a4,1(a2)
    for (int i = 0; i < 16; i++) {
    80005e20:	0609                	addi	a2,a2,2
    80005e22:	fca79ce3          	bne	a5,a0,80005dfa <hash_password+0x4c>
    }
    out_hash[32] = '\0';
    80005e26:	02058023          	sb	zero,32(a1)
}
    80005e2a:	70a2                	ld	ra,40(sp)
    80005e2c:	7402                	ld	s0,32(sp)
    80005e2e:	6145                	addi	sp,sp,48
    80005e30:	8082                	ret
    uint64 h = 5381;
    80005e32:	6685                	lui	a3,0x1
    80005e34:	50568693          	addi	a3,a3,1285 # 1505 <_entry-0x7fffeafb>
    80005e38:	bf79                	j	80005dd6 <hash_password+0x28>

0000000080005e3a <auth_init>:
// auth_init — Called from main() during boot
// Populates the in-memory user table with default credentials
// =============================================================
void
auth_init(void)
{
    80005e3a:	7139                	addi	sp,sp,-64
    80005e3c:	fc06                	sd	ra,56(sp)
    80005e3e:	f822                	sd	s0,48(sp)
    80005e40:	f426                	sd	s1,40(sp)
    80005e42:	f04a                	sd	s2,32(sp)
    80005e44:	ec4e                	sd	s3,24(sp)
    80005e46:	e852                	sd	s4,16(sp)
    80005e48:	e456                	sd	s5,8(sp)
    80005e4a:	e05a                	sd	s6,0(sp)
    80005e4c:	0080                	addi	s0,sp,64
    initlock(&g_users.lock, "auth");
    80005e4e:	0001d497          	auipc	s1,0x1d
    80005e52:	1ca48493          	addi	s1,s1,458 # 80023018 <g_users>
    80005e56:	00003597          	auipc	a1,0x3
    80005e5a:	a2a58593          	addi	a1,a1,-1494 # 80008880 <etext+0x880>
    80005e5e:	0001d517          	auipc	a0,0x1d
    80005e62:	54250513          	addi	a0,a0,1346 # 800233a0 <g_users+0x388>
    80005e66:	d39fa0ef          	jal	80000b9e <initlock>
    g_users.count = 0;

    // Seed default users — in production these come from /etc/passwd
    // ADMIN user
    struct passwd_entry *e = &g_users.entries[g_users.count++];
    80005e6a:	4985                	li	s3,1
    80005e6c:	3934a023          	sw	s3,896(s1)
    safestrcpy(e->username, "admin", AUTH_NAME_LEN);
    80005e70:	02000613          	li	a2,32
    80005e74:	00003597          	auipc	a1,0x3
    80005e78:	a1458593          	addi	a1,a1,-1516 # 80008888 <etext+0x888>
    80005e7c:	8526                	mv	a0,s1
    80005e7e:	fcffa0ef          	jal	80000e4c <safestrcpy>
    hash_password("admin123", e->passhash);
    80005e82:	0001d597          	auipc	a1,0x1d
    80005e86:	1b658593          	addi	a1,a1,438 # 80023038 <g_users+0x20>
    80005e8a:	00003517          	auipc	a0,0x3
    80005e8e:	a0650513          	addi	a0,a0,-1530 # 80008890 <etext+0x890>
    80005e92:	f1dff0ef          	jal	80005dae <hash_password>
    e->uid   = ROLE_ADMIN;
    80005e96:	0604a023          	sw	zero,96(s1)
    e->gid   = 0;
    80005e9a:	0604a223          	sw	zero,100(s1)
    e->role  = ROLE_ADMIN;
    80005e9e:	0604a423          	sw	zero,104(s1)
    e->valid = 1;
    80005ea2:	0734a623          	sw	s3,108(s1)

    // PATIENT user
    e = &g_users.entries[g_users.count++];
    80005ea6:	3804aa83          	lw	s5,896(s1)
    80005eaa:	001a879b          	addiw	a5,s5,1
    80005eae:	38f4a023          	sw	a5,896(s1)
    safestrcpy(e->username, "patient", AUTH_NAME_LEN);
    80005eb2:	003a9913          	slli	s2,s5,0x3
    80005eb6:	41590a33          	sub	s4,s2,s5
    80005eba:	0a12                	slli	s4,s4,0x4
    80005ebc:	01448b33          	add	s6,s1,s4
    80005ec0:	02000613          	li	a2,32
    80005ec4:	00003597          	auipc	a1,0x3
    80005ec8:	9dc58593          	addi	a1,a1,-1572 # 800088a0 <etext+0x8a0>
    80005ecc:	855a                	mv	a0,s6
    80005ece:	f7ffa0ef          	jal	80000e4c <safestrcpy>
    hash_password("patient123", e->passhash);
    80005ed2:	020a0593          	addi	a1,s4,32
    80005ed6:	95a6                	add	a1,a1,s1
    80005ed8:	00003517          	auipc	a0,0x3
    80005edc:	9d050513          	addi	a0,a0,-1584 # 800088a8 <etext+0x8a8>
    80005ee0:	ecfff0ef          	jal	80005dae <hash_password>
    e->uid   = ROLE_PATIENT;
    80005ee4:	073b2023          	sw	s3,96(s6) # 1060 <_entry-0x7fffefa0>
    e->gid   = 1;
    80005ee8:	073b2223          	sw	s3,100(s6)
    e->role  = ROLE_PATIENT;
    80005eec:	073b2423          	sw	s3,104(s6)
    e->valid = 1;
    80005ef0:	073b2623          	sw	s3,108(s6)

    // DOCTOR user
    e = &g_users.entries[g_users.count++];
    80005ef4:	3804aa83          	lw	s5,896(s1)
    80005ef8:	001a879b          	addiw	a5,s5,1
    80005efc:	38f4a023          	sw	a5,896(s1)
    safestrcpy(e->username, "doctor", AUTH_NAME_LEN);
    80005f00:	003a9913          	slli	s2,s5,0x3
    80005f04:	41590a33          	sub	s4,s2,s5
    80005f08:	0a12                	slli	s4,s4,0x4
    80005f0a:	01448b33          	add	s6,s1,s4
    80005f0e:	02000613          	li	a2,32
    80005f12:	00003597          	auipc	a1,0x3
    80005f16:	9a658593          	addi	a1,a1,-1626 # 800088b8 <etext+0x8b8>
    80005f1a:	855a                	mv	a0,s6
    80005f1c:	f31fa0ef          	jal	80000e4c <safestrcpy>
    hash_password("doctor123", e->passhash);
    80005f20:	020a0593          	addi	a1,s4,32
    80005f24:	95a6                	add	a1,a1,s1
    80005f26:	00003517          	auipc	a0,0x3
    80005f2a:	99a50513          	addi	a0,a0,-1638 # 800088c0 <etext+0x8c0>
    80005f2e:	e81ff0ef          	jal	80005dae <hash_password>
    e->uid   = ROLE_DOCTOR;
    80005f32:	4789                	li	a5,2
    80005f34:	06fb2023          	sw	a5,96(s6)
    e->gid   = 2;
    80005f38:	06fb2223          	sw	a5,100(s6)
    e->role  = ROLE_DOCTOR;
    80005f3c:	06fb2423          	sw	a5,104(s6)
    e->valid = 1;
    80005f40:	073b2623          	sw	s3,108(s6)
}
    80005f44:	70e2                	ld	ra,56(sp)
    80005f46:	7442                	ld	s0,48(sp)
    80005f48:	74a2                	ld	s1,40(sp)
    80005f4a:	7902                	ld	s2,32(sp)
    80005f4c:	69e2                	ld	s3,24(sp)
    80005f4e:	6a42                	ld	s4,16(sp)
    80005f50:	6aa2                	ld	s5,8(sp)
    80005f52:	6b02                	ld	s6,0(sp)
    80005f54:	6121                	addi	sp,sp,64
    80005f56:	8082                	ret

0000000080005f58 <auth_verify>:
// WHY kernel-side: user space must NEVER see the hash table
// directly — that would allow brute-force without audit trails
// =============================================================
int
auth_verify(const char *username, const char *password)
{
    80005f58:	7119                	addi	sp,sp,-128
    80005f5a:	fc86                	sd	ra,120(sp)
    80005f5c:	f8a2                	sd	s0,112(sp)
    80005f5e:	f4a6                	sd	s1,104(sp)
    80005f60:	f0ca                	sd	s2,96(sp)
    80005f62:	ecce                	sd	s3,88(sp)
    80005f64:	e8d2                	sd	s4,80(sp)
    80005f66:	e4d6                	sd	s5,72(sp)
    80005f68:	0100                	addi	s0,sp,128
    80005f6a:	8a2a                	mv	s4,a0
    80005f6c:	852e                	mv	a0,a1
    char attempt_hash[AUTH_HASH_LEN];
    hash_password(password, attempt_hash);
    80005f6e:	f8040593          	addi	a1,s0,-128
    80005f72:	e3dff0ef          	jal	80005dae <hash_password>

    acquire(&g_users.lock);
    80005f76:	0001d517          	auipc	a0,0x1d
    80005f7a:	42a50513          	addi	a0,a0,1066 # 800233a0 <g_users+0x388>
    80005f7e:	cabfa0ef          	jal	80000c28 <acquire>
    for (int i = 0; i < AUTH_MAX_USERS; i++) {
    80005f82:	0001d497          	auipc	s1,0x1d
    80005f86:	09648493          	addi	s1,s1,150 # 80023018 <g_users>
    80005f8a:	4901                	li	s2,0
        struct passwd_entry *e = &g_users.entries[i];
        if (!e->valid) continue;
        if (strncmp(e->username, username, AUTH_NAME_LEN) == 0) {
    80005f8c:	02000a93          	li	s5,32
    for (int i = 0; i < AUTH_MAX_USERS; i++) {
    80005f90:	49a1                	li	s3,8
    80005f92:	a031                	j	80005f9e <auth_verify+0x46>
    80005f94:	2905                	addiw	s2,s2,1
    80005f96:	07048493          	addi	s1,s1,112
    80005f9a:	05390f63          	beq	s2,s3,80005ff8 <auth_verify+0xa0>
        if (!e->valid) continue;
    80005f9e:	54fc                	lw	a5,108(s1)
    80005fa0:	dbf5                	beqz	a5,80005f94 <auth_verify+0x3c>
        if (strncmp(e->username, username, AUTH_NAME_LEN) == 0) {
    80005fa2:	8656                	mv	a2,s5
    80005fa4:	85d2                	mv	a1,s4
    80005fa6:	8526                	mv	a0,s1
    80005fa8:	e25fa0ef          	jal	80000dcc <strncmp>
    80005fac:	f565                	bnez	a0,80005f94 <auth_verify+0x3c>
            if (strncmp(e->passhash, attempt_hash, AUTH_HASH_LEN) == 0) {
    80005fae:	00391793          	slli	a5,s2,0x3
    80005fb2:	412787b3          	sub	a5,a5,s2
    80005fb6:	0792                	slli	a5,a5,0x4
    80005fb8:	02078793          	addi	a5,a5,32
    80005fbc:	04000613          	li	a2,64
    80005fc0:	f8040593          	addi	a1,s0,-128
    80005fc4:	0001d517          	auipc	a0,0x1d
    80005fc8:	05450513          	addi	a0,a0,84 # 80023018 <g_users>
    80005fcc:	953e                	add	a0,a0,a5
    80005fce:	dfffa0ef          	jal	80000dcc <strncmp>
    80005fd2:	e11d                	bnez	a0,80005ff8 <auth_verify+0xa0>
                int uid = e->uid;
    80005fd4:	00391793          	slli	a5,s2,0x3
    80005fd8:	412787b3          	sub	a5,a5,s2
    80005fdc:	0792                	slli	a5,a5,0x4
    80005fde:	0001d717          	auipc	a4,0x1d
    80005fe2:	03a70713          	addi	a4,a4,58 # 80023018 <g_users>
    80005fe6:	97ba                	add	a5,a5,a4
    80005fe8:	53a4                	lw	s1,96(a5)
                release(&g_users.lock);
    80005fea:	0001d517          	auipc	a0,0x1d
    80005fee:	3b650513          	addi	a0,a0,950 # 800233a0 <g_users+0x388>
    80005ff2:	ccbfa0ef          	jal	80000cbc <release>
                return uid;  // Success
    80005ff6:	a801                	j	80006006 <auth_verify+0xae>
            }
            break;  // Username matched, password wrong
        }
    }
    release(&g_users.lock);
    80005ff8:	0001d517          	auipc	a0,0x1d
    80005ffc:	3a850513          	addi	a0,a0,936 # 800233a0 <g_users+0x388>
    80006000:	cbdfa0ef          	jal	80000cbc <release>
    return -1;  // Authentication failed
    80006004:	54fd                	li	s1,-1
}
    80006006:	8526                	mv	a0,s1
    80006008:	70e6                	ld	ra,120(sp)
    8000600a:	7446                	ld	s0,112(sp)
    8000600c:	74a6                	ld	s1,104(sp)
    8000600e:	7906                	ld	s2,96(sp)
    80006010:	69e6                	ld	s3,88(sp)
    80006012:	6a46                	ld	s4,80(sp)
    80006014:	6aa6                	ld	s5,72(sp)
    80006016:	6109                	addi	sp,sp,128
    80006018:	8082                	ret

000000008000601a <auth_add_user>:
// =============================================================
// auth_add_user — Add a new user (ADMIN only, enforced by caller)
// =============================================================
int
auth_add_user(const char *username, const char *password, int uid, int gid)
{
    8000601a:	711d                	addi	sp,sp,-96
    8000601c:	ec86                	sd	ra,88(sp)
    8000601e:	e8a2                	sd	s0,80(sp)
    80006020:	fc4e                	sd	s3,56(sp)
    80006022:	ec5e                	sd	s7,24(sp)
    80006024:	e862                	sd	s8,16(sp)
    80006026:	e466                	sd	s9,8(sp)
    80006028:	e06a                	sd	s10,0(sp)
    8000602a:	1080                	addi	s0,sp,96
    8000602c:	8baa                	mv	s7,a0
    8000602e:	8c2e                	mv	s8,a1
    80006030:	8cb2                	mv	s9,a2
    80006032:	8d36                	mv	s10,a3
    acquire(&g_users.lock);
    80006034:	0001d517          	auipc	a0,0x1d
    80006038:	36c50513          	addi	a0,a0,876 # 800233a0 <g_users+0x388>
    8000603c:	bedfa0ef          	jal	80000c28 <acquire>

    if (g_users.count >= AUTH_MAX_USERS) {
    80006040:	0001d717          	auipc	a4,0x1d
    80006044:	35872703          	lw	a4,856(a4) # 80023398 <g_users+0x380>
    80006048:	479d                	li	a5,7
    8000604a:	02e7c163          	blt	a5,a4,8000606c <auth_add_user+0x52>
    8000604e:	e4a6                	sd	s1,72(sp)
    80006050:	e0ca                	sd	s2,64(sp)
    80006052:	f852                	sd	s4,48(sp)
    80006054:	0001d917          	auipc	s2,0x1d
    80006058:	fc490913          	addi	s2,s2,-60 # 80023018 <g_users>
    8000605c:	0001d997          	auipc	s3,0x1d
    80006060:	33c98993          	addi	s3,s3,828 # 80023398 <g_users+0x380>
    80006064:	84ca                	mv	s1,s2
    }

    // Check for duplicate username
    for (int i = 0; i < AUTH_MAX_USERS; i++) {
        if (g_users.entries[i].valid &&
            strncmp(g_users.entries[i].username, username, AUTH_NAME_LEN) == 0) {
    80006066:	02000a13          	li	s4,32
    8000606a:	a829                	j	80006084 <auth_add_user+0x6a>
        release(&g_users.lock);
    8000606c:	0001d517          	auipc	a0,0x1d
    80006070:	33450513          	addi	a0,a0,820 # 800233a0 <g_users+0x388>
    80006074:	c49fa0ef          	jal	80000cbc <release>
        return -1;  // Table full
    80006078:	59fd                	li	s3,-1
    8000607a:	a8a9                	j	800060d4 <auth_add_user+0xba>
    for (int i = 0; i < AUTH_MAX_USERS; i++) {
    8000607c:	07048493          	addi	s1,s1,112
    80006080:	03348563          	beq	s1,s3,800060aa <auth_add_user+0x90>
        if (g_users.entries[i].valid &&
    80006084:	54fc                	lw	a5,108(s1)
    80006086:	dbfd                	beqz	a5,8000607c <auth_add_user+0x62>
            strncmp(g_users.entries[i].username, username, AUTH_NAME_LEN) == 0) {
    80006088:	8652                	mv	a2,s4
    8000608a:	85de                	mv	a1,s7
    8000608c:	8526                	mv	a0,s1
    8000608e:	d3ffa0ef          	jal	80000dcc <strncmp>
        if (g_users.entries[i].valid &&
    80006092:	f56d                	bnez	a0,8000607c <auth_add_user+0x62>
            release(&g_users.lock);
    80006094:	0001d517          	auipc	a0,0x1d
    80006098:	30c50513          	addi	a0,a0,780 # 800233a0 <g_users+0x388>
    8000609c:	c21fa0ef          	jal	80000cbc <release>
            return -1;  // User exists
    800060a0:	59fd                	li	s3,-1
    800060a2:	64a6                	ld	s1,72(sp)
    800060a4:	6906                	ld	s2,64(sp)
    800060a6:	7a42                	ld	s4,48(sp)
    800060a8:	a035                	j	800060d4 <auth_add_user+0xba>
        }
    }

    // Find empty slot
    for (int i = 0; i < AUTH_MAX_USERS; i++) {
    800060aa:	4481                	li	s1,0
    800060ac:	47a1                	li	a5,8
        if (!g_users.entries[i].valid) {
    800060ae:	06c92983          	lw	s3,108(s2)
    800060b2:	02098b63          	beqz	s3,800060e8 <auth_add_user+0xce>
    for (int i = 0; i < AUTH_MAX_USERS; i++) {
    800060b6:	2485                	addiw	s1,s1,1
    800060b8:	07090913          	addi	s2,s2,112
    800060bc:	fef499e3          	bne	s1,a5,800060ae <auth_add_user+0x94>
            release(&g_users.lock);
            return 0;
        }
    }

    release(&g_users.lock);
    800060c0:	0001d517          	auipc	a0,0x1d
    800060c4:	2e050513          	addi	a0,a0,736 # 800233a0 <g_users+0x388>
    800060c8:	bf5fa0ef          	jal	80000cbc <release>
    return -1;
    800060cc:	59fd                	li	s3,-1
    800060ce:	64a6                	ld	s1,72(sp)
    800060d0:	6906                	ld	s2,64(sp)
    800060d2:	7a42                	ld	s4,48(sp)
}
    800060d4:	854e                	mv	a0,s3
    800060d6:	60e6                	ld	ra,88(sp)
    800060d8:	6446                	ld	s0,80(sp)
    800060da:	79e2                	ld	s3,56(sp)
    800060dc:	6be2                	ld	s7,24(sp)
    800060de:	6c42                	ld	s8,16(sp)
    800060e0:	6ca2                	ld	s9,8(sp)
    800060e2:	6d02                	ld	s10,0(sp)
    800060e4:	6125                	addi	sp,sp,96
    800060e6:	8082                	ret
    800060e8:	f456                	sd	s5,40(sp)
    800060ea:	f05a                	sd	s6,32(sp)
            safestrcpy(g_users.entries[i].username, username, AUTH_NAME_LEN);
    800060ec:	00349a93          	slli	s5,s1,0x3
    800060f0:	409a85b3          	sub	a1,s5,s1
    800060f4:	00459b13          	slli	s6,a1,0x4
    800060f8:	0001da17          	auipc	s4,0x1d
    800060fc:	f20a0a13          	addi	s4,s4,-224 # 80023018 <g_users>
    80006100:	016a0933          	add	s2,s4,s6
    80006104:	02000613          	li	a2,32
    80006108:	85de                	mv	a1,s7
    8000610a:	854a                	mv	a0,s2
    8000610c:	d41fa0ef          	jal	80000e4c <safestrcpy>
            hash_password(password, g_users.entries[i].passhash);
    80006110:	020b0593          	addi	a1,s6,32
    80006114:	95d2                	add	a1,a1,s4
    80006116:	8562                	mv	a0,s8
    80006118:	c97ff0ef          	jal	80005dae <hash_password>
            g_users.entries[i].uid   = uid;
    8000611c:	07992023          	sw	s9,96(s2)
            g_users.entries[i].gid   = gid;
    80006120:	07a92223          	sw	s10,100(s2)
            g_users.entries[i].role  = uid;  // role mirrors uid
    80006124:	07992423          	sw	s9,104(s2)
            g_users.entries[i].valid = 1;
    80006128:	4705                	li	a4,1
    8000612a:	06e92623          	sw	a4,108(s2)
            g_users.count++;
    8000612e:	380a2783          	lw	a5,896(s4)
    80006132:	2785                	addiw	a5,a5,1
    80006134:	38fa2023          	sw	a5,896(s4)
            release(&g_users.lock);
    80006138:	0001d517          	auipc	a0,0x1d
    8000613c:	26850513          	addi	a0,a0,616 # 800233a0 <g_users+0x388>
    80006140:	b7dfa0ef          	jal	80000cbc <release>
            return 0;
    80006144:	64a6                	ld	s1,72(sp)
    80006146:	6906                	ld	s2,64(sp)
    80006148:	7a42                	ld	s4,48(sp)
    8000614a:	7aa2                	ld	s5,40(sp)
    8000614c:	7b02                	ld	s6,32(sp)
    8000614e:	b759                	j	800060d4 <auth_add_user+0xba>

0000000080006150 <auth_del_user>:
// =============================================================
// auth_del_user — Remove user (ADMIN only)
// =============================================================
int
auth_del_user(const char *username)
{
    80006150:	7139                	addi	sp,sp,-64
    80006152:	fc06                	sd	ra,56(sp)
    80006154:	f822                	sd	s0,48(sp)
    80006156:	f426                	sd	s1,40(sp)
    80006158:	f04a                	sd	s2,32(sp)
    8000615a:	ec4e                	sd	s3,24(sp)
    8000615c:	e852                	sd	s4,16(sp)
    8000615e:	e456                	sd	s5,8(sp)
    80006160:	e05a                	sd	s6,0(sp)
    80006162:	0080                	addi	s0,sp,64
    80006164:	8b2a                	mv	s6,a0
    acquire(&g_users.lock);
    80006166:	0001d517          	auipc	a0,0x1d
    8000616a:	23a50513          	addi	a0,a0,570 # 800233a0 <g_users+0x388>
    8000616e:	abbfa0ef          	jal	80000c28 <acquire>
    for (int i = 0; i < AUTH_MAX_USERS; i++) {
    80006172:	0001d497          	auipc	s1,0x1d
    80006176:	ea648493          	addi	s1,s1,-346 # 80023018 <g_users>
    8000617a:	4901                	li	s2,0
        if (g_users.entries[i].valid &&
            strncmp(g_users.entries[i].username, username, AUTH_NAME_LEN) == 0) {
    8000617c:	02000a93          	li	s5,32
    for (int i = 0; i < AUTH_MAX_USERS; i++) {
    80006180:	4a21                	li	s4,8
    80006182:	a031                	j	8000618e <auth_del_user+0x3e>
    80006184:	2905                	addiw	s2,s2,1
    80006186:	07048493          	addi	s1,s1,112
    8000618a:	05490363          	beq	s2,s4,800061d0 <auth_del_user+0x80>
        if (g_users.entries[i].valid &&
    8000618e:	54fc                	lw	a5,108(s1)
    80006190:	dbf5                	beqz	a5,80006184 <auth_del_user+0x34>
            strncmp(g_users.entries[i].username, username, AUTH_NAME_LEN) == 0) {
    80006192:	8656                	mv	a2,s5
    80006194:	85da                	mv	a1,s6
    80006196:	8526                	mv	a0,s1
    80006198:	c35fa0ef          	jal	80000dcc <strncmp>
    8000619c:	89aa                	mv	s3,a0
        if (g_users.entries[i].valid &&
    8000619e:	f17d                	bnez	a0,80006184 <auth_del_user+0x34>
            g_users.entries[i].valid = 0;
    800061a0:	0001d717          	auipc	a4,0x1d
    800061a4:	e7870713          	addi	a4,a4,-392 # 80023018 <g_users>
    800061a8:	00391793          	slli	a5,s2,0x3
    800061ac:	412787b3          	sub	a5,a5,s2
    800061b0:	0792                	slli	a5,a5,0x4
    800061b2:	97ba                	add	a5,a5,a4
    800061b4:	0607a623          	sw	zero,108(a5)
            g_users.count--;
    800061b8:	38072783          	lw	a5,896(a4)
    800061bc:	37fd                	addiw	a5,a5,-1
    800061be:	38f72023          	sw	a5,896(a4)
            release(&g_users.lock);
    800061c2:	0001d517          	auipc	a0,0x1d
    800061c6:	1de50513          	addi	a0,a0,478 # 800233a0 <g_users+0x388>
    800061ca:	af3fa0ef          	jal	80000cbc <release>
            return 0;
    800061ce:	a801                	j	800061de <auth_del_user+0x8e>
        }
    }
    release(&g_users.lock);
    800061d0:	0001d517          	auipc	a0,0x1d
    800061d4:	1d050513          	addi	a0,a0,464 # 800233a0 <g_users+0x388>
    800061d8:	ae5fa0ef          	jal	80000cbc <release>
    return -1;  // User not found
    800061dc:	59fd                	li	s3,-1
    800061de:	854e                	mv	a0,s3
    800061e0:	70e2                	ld	ra,56(sp)
    800061e2:	7442                	ld	s0,48(sp)
    800061e4:	74a2                	ld	s1,40(sp)
    800061e6:	7902                	ld	s2,32(sp)
    800061e8:	69e2                	ld	s3,24(sp)
    800061ea:	6a42                	ld	s4,16(sp)
    800061ec:	6aa2                	ld	s5,8(sp)
    800061ee:	6b02                	ld	s6,0(sp)
    800061f0:	6121                	addi	sp,sp,64
    800061f2:	8082                	ret

00000000800061f4 <sys_login>:
// sys_login — Authenticate user, set proc credentials
// Called by login shell; transitions process from uid=-1 to real uid
// =============================================================
uint64
sys_login(void)
{
    800061f4:	7159                	addi	sp,sp,-112
    800061f6:	f486                	sd	ra,104(sp)
    800061f8:	f0a2                	sd	s0,96(sp)
    800061fa:	eca6                	sd	s1,88(sp)
    800061fc:	1880                	addi	s0,sp,112
    char username[32], password[32];

    // Safely copy arguments from user space
    // argstr validates the pointer is in user address space
    if (argstr(0, username, 32) < 0 ||
    800061fe:	02000613          	li	a2,32
    80006202:	fb040593          	addi	a1,s0,-80
    80006206:	4501                	li	a0,0
    80006208:	ed2fc0ef          	jal	800028da <argstr>
        argstr(1, password, 32) < 0)
        return -1;
    8000620c:	54fd                	li	s1,-1
    if (argstr(0, username, 32) < 0 ||
    8000620e:	0a054063          	bltz	a0,800062ae <sys_login+0xba>
        argstr(1, password, 32) < 0)
    80006212:	02000613          	li	a2,32
    80006216:	f9040593          	addi	a1,s0,-112
    8000621a:	4505                	li	a0,1
    8000621c:	ebefc0ef          	jal	800028da <argstr>
    if (argstr(0, username, 32) < 0 ||
    80006220:	08054763          	bltz	a0,800062ae <sys_login+0xba>

    int uid = auth_verify(username, password);
    80006224:	f9040593          	addi	a1,s0,-112
    80006228:	fb040513          	addi	a0,s0,-80
    8000622c:	d2dff0ef          	jal	80005f58 <auth_verify>
    80006230:	84aa                	mv	s1,a0
    if (uid < 0) {
    80006232:	08054463          	bltz	a0,800062ba <sys_login+0xc6>
    80006236:	e8ca                	sd	s2,80(sp)
    80006238:	e4ce                	sd	s3,72(sp)
        audit_log_event(myproc()->pid, -1, SYS_login, "FAIL:bad_credentials");
        return -1;
    }

    // Set credentials on the calling process
    struct proc *p = myproc();
    8000623a:	efcfb0ef          	jal	80001936 <myproc>
    8000623e:	892a                	mv	s2,a0
    acquire(&p->lock);
    80006240:	9e9fa0ef          	jal	80000c28 <acquire>
    p->creds.uid           = uid;
    80006244:	16992423          	sw	s1,360(s2)
    p->creds.gid           = uid;   // gid mirrors uid for this project
    80006248:	16992623          	sw	s1,364(s2)
    p->creds.role          = uid;
    8000624c:	16992823          	sw	s1,368(s2)
    p->creds.authenticated = 1;
    80006250:	4785                	li	a5,1
    80006252:	16f92a23          	sw	a5,372(s2)
    safestrcpy(p->creds.username, username, 32);
    80006256:	02000613          	li	a2,32
    8000625a:	fb040593          	addi	a1,s0,-80
    8000625e:	17890513          	addi	a0,s2,376
    80006262:	bebfa0ef          	jal	80000e4c <safestrcpy>
    // Initialize stack canary (simplified — production uses random value)
    p->stack_canary = 0xDEADBEEFCAFEBABE;
    80006266:	00002797          	auipc	a5,0x2
    8000626a:	d9a7b783          	ld	a5,-614(a5) # 80008000 <etext>
    8000626e:	18f93c23          	sd	a5,408(s2)
    
    // DEBUG: Verify credential was set
    int verify_uid = p->creds.uid;
    80006272:	16892783          	lw	a5,360(s2)
    80006276:	89be                	mv	s3,a5
    release(&p->lock);
    80006278:	854a                	mv	a0,s2
    8000627a:	a43fa0ef          	jal	80000cbc <release>

    printf("DEBUG: sys_login called for %s, pid=%d, setting uid=%d, verify=%d\n", username, p->pid, uid, verify_uid);
    8000627e:	874e                	mv	a4,s3
    80006280:	86a6                	mv	a3,s1
    80006282:	03092603          	lw	a2,48(s2)
    80006286:	fb040593          	addi	a1,s0,-80
    8000628a:	00002517          	auipc	a0,0x2
    8000628e:	65e50513          	addi	a0,a0,1630 # 800088e8 <etext+0x8e8>
    80006292:	a68fa0ef          	jal	800004fa <printf>
    audit_log_event(p->pid, uid, SYS_login, "SUCCESS:login");
    80006296:	00002697          	auipc	a3,0x2
    8000629a:	69a68693          	addi	a3,a3,1690 # 80008930 <etext+0x930>
    8000629e:	4659                	li	a2,22
    800062a0:	85a6                	mv	a1,s1
    800062a2:	03092503          	lw	a0,48(s2)
    800062a6:	33e000ef          	jal	800065e4 <audit_log_event>
    800062aa:	6946                	ld	s2,80(sp)
    800062ac:	69a6                	ld	s3,72(sp)
    return uid;
}
    800062ae:	8526                	mv	a0,s1
    800062b0:	70a6                	ld	ra,104(sp)
    800062b2:	7406                	ld	s0,96(sp)
    800062b4:	64e6                	ld	s1,88(sp)
    800062b6:	6165                	addi	sp,sp,112
    800062b8:	8082                	ret
        audit_log_event(myproc()->pid, -1, SYS_login, "FAIL:bad_credentials");
    800062ba:	e7cfb0ef          	jal	80001936 <myproc>
    800062be:	00002697          	auipc	a3,0x2
    800062c2:	61268693          	addi	a3,a3,1554 # 800088d0 <etext+0x8d0>
    800062c6:	4659                	li	a2,22
    800062c8:	55fd                	li	a1,-1
    800062ca:	5908                	lw	a0,48(a0)
    800062cc:	318000ef          	jal	800065e4 <audit_log_event>
        return -1;
    800062d0:	54fd                	li	s1,-1
    800062d2:	bff1                	j	800062ae <sys_login+0xba>

00000000800062d4 <sys_whoami>:
// =============================================================
// sys_whoami — Return current UID to user space
// =============================================================
uint64
sys_whoami(void)
{
    800062d4:	1141                	addi	sp,sp,-16
    800062d6:	e406                	sd	ra,8(sp)
    800062d8:	e022                	sd	s0,0(sp)
    800062da:	0800                	addi	s0,sp,16
    struct proc *p = myproc();
    800062dc:	e5afb0ef          	jal	80001936 <myproc>
    return p->creds.uid;
}
    800062e0:	16852503          	lw	a0,360(a0)
    800062e4:	60a2                	ld	ra,8(sp)
    800062e6:	6402                	ld	s0,0(sp)
    800062e8:	0141                	addi	sp,sp,16
    800062ea:	8082                	ret

00000000800062ec <sys_useradd>:
// sys_useradd — Add user (ADMIN only)
// Demonstrates PoLP: only uid=0 can create new accounts
// =============================================================
uint64
sys_useradd(void)
{
    800062ec:	7159                	addi	sp,sp,-112
    800062ee:	f486                	sd	ra,104(sp)
    800062f0:	f0a2                	sd	s0,96(sp)
    800062f2:	eca6                	sd	s1,88(sp)
    800062f4:	1880                	addi	s0,sp,112
    struct proc *p = myproc();
    800062f6:	e40fb0ef          	jal	80001936 <myproc>
    800062fa:	84aa                	mv	s1,a0

    // ENFORCE: Only admin can add users
    if (p->creds.uid != ROLE_ADMIN) {
    800062fc:	16852583          	lw	a1,360(a0)
    80006300:	e5c1                	bnez	a1,80006388 <sys_useradd+0x9c>
    }

    char username[32], password[32];
    int  uid, gid;

    if (argstr(0, username, 32) < 0 ||
    80006302:	02000613          	li	a2,32
    80006306:	fc040593          	addi	a1,s0,-64
    8000630a:	4501                	li	a0,0
    8000630c:	dcefc0ef          	jal	800028da <argstr>
        argstr(1, password, 32) < 0 ||
        argint(2, &uid)         < 0 ||
        argint(3, &gid)         < 0)
        return -1;
    80006310:	57fd                	li	a5,-1
    if (argstr(0, username, 32) < 0 ||
    80006312:	08054463          	bltz	a0,8000639a <sys_useradd+0xae>
        argstr(1, password, 32) < 0 ||
    80006316:	02000613          	li	a2,32
    8000631a:	fa040593          	addi	a1,s0,-96
    8000631e:	4505                	li	a0,1
    80006320:	dbafc0ef          	jal	800028da <argstr>
        return -1;
    80006324:	57fd                	li	a5,-1
    if (argstr(0, username, 32) < 0 ||
    80006326:	06054a63          	bltz	a0,8000639a <sys_useradd+0xae>
        argint(2, &uid)         < 0 ||
    8000632a:	f9c40593          	addi	a1,s0,-100
    8000632e:	4509                	li	a0,2
    80006330:	d6efc0ef          	jal	8000289e <argint>
        return -1;
    80006334:	57fd                	li	a5,-1
        argstr(1, password, 32) < 0 ||
    80006336:	06054263          	bltz	a0,8000639a <sys_useradd+0xae>
        argint(3, &gid)         < 0)
    8000633a:	f9840593          	addi	a1,s0,-104
    8000633e:	450d                	li	a0,3
    80006340:	d5efc0ef          	jal	8000289e <argint>
        return -1;
    80006344:	57fd                	li	a5,-1
        argint(2, &uid)         < 0 ||
    80006346:	04054a63          	bltz	a0,8000639a <sys_useradd+0xae>
    8000634a:	e8ca                	sd	s2,80(sp)

    int result = auth_add_user(username, password, uid, gid);
    8000634c:	f9842683          	lw	a3,-104(s0)
    80006350:	f9c42603          	lw	a2,-100(s0)
    80006354:	fa040593          	addi	a1,s0,-96
    80006358:	fc040513          	addi	a0,s0,-64
    8000635c:	cbfff0ef          	jal	8000601a <auth_add_user>
    80006360:	87aa                	mv	a5,a0
    80006362:	892a                	mv	s2,a0
    audit_log_event(p->pid, p->creds.uid, SYS_useradd,
    80006364:	5888                	lw	a0,48(s1)
    80006366:	1684a583          	lw	a1,360(s1)
    8000636a:	00002697          	auipc	a3,0x2
    8000636e:	5e668693          	addi	a3,a3,1510 # 80008950 <etext+0x950>
    80006372:	e789                	bnez	a5,8000637c <sys_useradd+0x90>
    80006374:	00002697          	auipc	a3,0x2
    80006378:	5cc68693          	addi	a3,a3,1484 # 80008940 <etext+0x940>
    8000637c:	465d                	li	a2,23
    8000637e:	266000ef          	jal	800065e4 <audit_log_event>
                    result == 0 ? "SUCCESS:useradd" : "FAIL:useradd");
    return result;
    80006382:	87ca                	mv	a5,s2
    80006384:	6946                	ld	s2,80(sp)
    80006386:	a811                	j	8000639a <sys_useradd+0xae>
        audit_log_event(p->pid, p->creds.uid, SYS_useradd, "DENIED:not_admin");
    80006388:	00002697          	auipc	a3,0x2
    8000638c:	5d868693          	addi	a3,a3,1496 # 80008960 <etext+0x960>
    80006390:	465d                	li	a2,23
    80006392:	5908                	lw	a0,48(a0)
    80006394:	250000ef          	jal	800065e4 <audit_log_event>
        return -1;
    80006398:	57fd                	li	a5,-1
}
    8000639a:	853e                	mv	a0,a5
    8000639c:	70a6                	ld	ra,104(sp)
    8000639e:	7406                	ld	s0,96(sp)
    800063a0:	64e6                	ld	s1,88(sp)
    800063a2:	6165                	addi	sp,sp,112
    800063a4:	8082                	ret

00000000800063a6 <sys_userdel>:
// =============================================================
// sys_userdel — Delete user (ADMIN only)
// =============================================================
uint64
sys_userdel(void)
{
    800063a6:	7139                	addi	sp,sp,-64
    800063a8:	fc06                	sd	ra,56(sp)
    800063aa:	f822                	sd	s0,48(sp)
    800063ac:	f426                	sd	s1,40(sp)
    800063ae:	0080                	addi	s0,sp,64
    struct proc *p = myproc();
    800063b0:	d86fb0ef          	jal	80001936 <myproc>
    800063b4:	84aa                	mv	s1,a0

    if (p->creds.uid != ROLE_ADMIN) {
    800063b6:	16852583          	lw	a1,360(a0)
    800063ba:	e1a1                	bnez	a1,800063fa <sys_userdel+0x54>
        audit_log_event(p->pid, p->creds.uid, SYS_userdel, "DENIED:not_admin");
        return -1;
    }

    char username[32];
    if (argstr(0, username, 32) < 0)
    800063bc:	02000613          	li	a2,32
    800063c0:	fc040593          	addi	a1,s0,-64
    800063c4:	4501                	li	a0,0
    800063c6:	d14fc0ef          	jal	800028da <argstr>
        return -1;
    800063ca:	57fd                	li	a5,-1
    if (argstr(0, username, 32) < 0)
    800063cc:	02054163          	bltz	a0,800063ee <sys_userdel+0x48>

    // Prevent deleting own account — safety guard
    if (strncmp(username, p->creds.username, 32) == 0)
    800063d0:	02000613          	li	a2,32
    800063d4:	17848593          	addi	a1,s1,376
    800063d8:	fc040513          	addi	a0,s0,-64
    800063dc:	9f1fa0ef          	jal	80000dcc <strncmp>
        return -1;
    800063e0:	57fd                	li	a5,-1
    if (strncmp(username, p->creds.username, 32) == 0)
    800063e2:	c511                	beqz	a0,800063ee <sys_userdel+0x48>

    return auth_del_user(username);
    800063e4:	fc040513          	addi	a0,s0,-64
    800063e8:	d69ff0ef          	jal	80006150 <auth_del_user>
    800063ec:	87aa                	mv	a5,a0
}
    800063ee:	853e                	mv	a0,a5
    800063f0:	70e2                	ld	ra,56(sp)
    800063f2:	7442                	ld	s0,48(sp)
    800063f4:	74a2                	ld	s1,40(sp)
    800063f6:	6121                	addi	sp,sp,64
    800063f8:	8082                	ret
        audit_log_event(p->pid, p->creds.uid, SYS_userdel, "DENIED:not_admin");
    800063fa:	00002697          	auipc	a3,0x2
    800063fe:	56668693          	addi	a3,a3,1382 # 80008960 <etext+0x960>
    80006402:	4661                	li	a2,24
    80006404:	5908                	lw	a0,48(a0)
    80006406:	1de000ef          	jal	800065e4 <audit_log_event>
        return -1;
    8000640a:	57fd                	li	a5,-1
    8000640c:	b7cd                	j	800063ee <sys_userdel+0x48>

000000008000640e <sys_passwd>:
// =============================================================
// sys_passwd — Change password (own account, or admin for any)
// =============================================================
uint64
sys_passwd(void)
{
    8000640e:	7135                	addi	sp,sp,-160
    80006410:	ed06                	sd	ra,152(sp)
    80006412:	e922                	sd	s0,144(sp)
    80006414:	e526                	sd	s1,136(sp)
    80006416:	f4d6                	sd	s5,104(sp)
    80006418:	1100                	addi	s0,sp,160
    struct proc *p = myproc();
    8000641a:	d1cfb0ef          	jal	80001936 <myproc>
    8000641e:	84aa                	mv	s1,a0
    80006420:	8aaa                	mv	s5,a0
    char username[32], old_pw[32], new_pw[32];

    if (argstr(0, username, 32) < 0 ||
    80006422:	02000613          	li	a2,32
    80006426:	fa040593          	addi	a1,s0,-96
    8000642a:	4501                	li	a0,0
    8000642c:	caefc0ef          	jal	800028da <argstr>
        argstr(1, old_pw,   32) < 0 ||
        argstr(2, new_pw,   32) < 0)
        return -1;
    80006430:	57fd                	li	a5,-1
    if (argstr(0, username, 32) < 0 ||
    80006432:	12054463          	bltz	a0,8000655a <sys_passwd+0x14c>
        argstr(1, old_pw,   32) < 0 ||
    80006436:	02000613          	li	a2,32
    8000643a:	f8040593          	addi	a1,s0,-128
    8000643e:	4505                	li	a0,1
    80006440:	c9afc0ef          	jal	800028da <argstr>
        return -1;
    80006444:	57fd                	li	a5,-1
    if (argstr(0, username, 32) < 0 ||
    80006446:	10054a63          	bltz	a0,8000655a <sys_passwd+0x14c>
        argstr(2, new_pw,   32) < 0)
    8000644a:	02000613          	li	a2,32
    8000644e:	f6040593          	addi	a1,s0,-160
    80006452:	4509                	li	a0,2
    80006454:	c86fc0ef          	jal	800028da <argstr>
        argstr(1, old_pw,   32) < 0 ||
    80006458:	10054863          	bltz	a0,80006568 <sys_passwd+0x15a>

    // Non-admin can only change their own password
    if (p->creds.uid != ROLE_ADMIN &&
    8000645c:	1684a783          	lw	a5,360(s1)
    80006460:	e39d                	bnez	a5,80006486 <sys_passwd+0x78>
    80006462:	e14a                	sd	s2,128(sp)
    80006464:	fcce                	sd	s3,120(sp)
    80006466:	f8d2                	sd	s4,112(sp)
            return -1;
        }
    }

    // Update hash in user table
    acquire(&g_users.lock);
    80006468:	0001d517          	auipc	a0,0x1d
    8000646c:	f3850513          	addi	a0,a0,-200 # 800233a0 <g_users+0x388>
    80006470:	fb8fa0ef          	jal	80000c28 <acquire>
    for (int i = 0; i < AUTH_MAX_USERS; i++) {
    80006474:	0001d497          	auipc	s1,0x1d
    80006478:	ba448493          	addi	s1,s1,-1116 # 80023018 <g_users>
    8000647c:	4901                	li	s2,0
        if (g_users.entries[i].valid &&
            strncmp(g_users.entries[i].username, username, 32) == 0) {
    8000647e:	fa040a13          	addi	s4,s0,-96
    for (int i = 0; i < AUTH_MAX_USERS; i++) {
    80006482:	49a1                	li	s3,8
    80006484:	a095                	j	800064e8 <sys_passwd+0xda>
        strncmp(username, p->creds.username, 32) != 0) {
    80006486:	02000613          	li	a2,32
    8000648a:	17848593          	addi	a1,s1,376
    8000648e:	fa040513          	addi	a0,s0,-96
    80006492:	93bfa0ef          	jal	80000dcc <strncmp>
    if (p->creds.uid != ROLE_ADMIN &&
    80006496:	e905                	bnez	a0,800064c6 <sys_passwd+0xb8>
    if (p->creds.uid != ROLE_ADMIN) {
    80006498:	1684a783          	lw	a5,360(s1)
    8000649c:	d3f9                	beqz	a5,80006462 <sys_passwd+0x54>
        if (auth_verify(username, old_pw) < 0) {
    8000649e:	f8040593          	addi	a1,s0,-128
    800064a2:	fa040513          	addi	a0,s0,-96
    800064a6:	ab3ff0ef          	jal	80005f58 <auth_verify>
    800064aa:	fa055ce3          	bgez	a0,80006462 <sys_passwd+0x54>
            audit_log_event(p->pid, p->creds.uid, SYS_passwd, "FAIL:wrong_password");
    800064ae:	00002697          	auipc	a3,0x2
    800064b2:	4e268693          	addi	a3,a3,1250 # 80008990 <etext+0x990>
    800064b6:	4665                	li	a2,25
    800064b8:	1684a583          	lw	a1,360(s1)
    800064bc:	5888                	lw	a0,48(s1)
    800064be:	126000ef          	jal	800065e4 <audit_log_event>
            return -1;
    800064c2:	57fd                	li	a5,-1
    800064c4:	a859                	j	8000655a <sys_passwd+0x14c>
        audit_log_event(p->pid, p->creds.uid, SYS_passwd, "DENIED:wrong_user");
    800064c6:	00002697          	auipc	a3,0x2
    800064ca:	4b268693          	addi	a3,a3,1202 # 80008978 <etext+0x978>
    800064ce:	4665                	li	a2,25
    800064d0:	1684a583          	lw	a1,360(s1)
    800064d4:	5888                	lw	a0,48(s1)
    800064d6:	10e000ef          	jal	800065e4 <audit_log_event>
        return -1;
    800064da:	57fd                	li	a5,-1
    800064dc:	a8bd                	j	8000655a <sys_passwd+0x14c>
    for (int i = 0; i < AUTH_MAX_USERS; i++) {
    800064de:	2905                	addiw	s2,s2,1
    800064e0:	07048493          	addi	s1,s1,112
    800064e4:	07390163          	beq	s2,s3,80006546 <sys_passwd+0x138>
        if (g_users.entries[i].valid &&
    800064e8:	54fc                	lw	a5,108(s1)
    800064ea:	dbf5                	beqz	a5,800064de <sys_passwd+0xd0>
            strncmp(g_users.entries[i].username, username, 32) == 0) {
    800064ec:	02000613          	li	a2,32
    800064f0:	85d2                	mv	a1,s4
    800064f2:	8526                	mv	a0,s1
    800064f4:	8d9fa0ef          	jal	80000dcc <strncmp>
        if (g_users.entries[i].valid &&
    800064f8:	f17d                	bnez	a0,800064de <sys_passwd+0xd0>
            hash_password(new_pw, g_users.entries[i].passhash);
    800064fa:	00391793          	slli	a5,s2,0x3
    800064fe:	412787b3          	sub	a5,a5,s2
    80006502:	0792                	slli	a5,a5,0x4
    80006504:	02078793          	addi	a5,a5,32
    80006508:	0001d597          	auipc	a1,0x1d
    8000650c:	b1058593          	addi	a1,a1,-1264 # 80023018 <g_users>
    80006510:	95be                	add	a1,a1,a5
    80006512:	f6040513          	addi	a0,s0,-160
    80006516:	899ff0ef          	jal	80005dae <hash_password>
            release(&g_users.lock);
    8000651a:	0001d517          	auipc	a0,0x1d
    8000651e:	e8650513          	addi	a0,a0,-378 # 800233a0 <g_users+0x388>
    80006522:	f9afa0ef          	jal	80000cbc <release>
            audit_log_event(p->pid, p->creds.uid, SYS_passwd, "SUCCESS:passwd_changed");
    80006526:	00002697          	auipc	a3,0x2
    8000652a:	48268693          	addi	a3,a3,1154 # 800089a8 <etext+0x9a8>
    8000652e:	4665                	li	a2,25
    80006530:	168aa583          	lw	a1,360(s5)
    80006534:	030aa503          	lw	a0,48(s5)
    80006538:	0ac000ef          	jal	800065e4 <audit_log_event>
            return 0;
    8000653c:	4781                	li	a5,0
    8000653e:	690a                	ld	s2,128(sp)
    80006540:	79e6                	ld	s3,120(sp)
    80006542:	7a46                	ld	s4,112(sp)
    80006544:	a819                	j	8000655a <sys_passwd+0x14c>
        }
    }
    release(&g_users.lock);
    80006546:	0001d517          	auipc	a0,0x1d
    8000654a:	e5a50513          	addi	a0,a0,-422 # 800233a0 <g_users+0x388>
    8000654e:	f6efa0ef          	jal	80000cbc <release>
    return -1;
    80006552:	57fd                	li	a5,-1
    80006554:	690a                	ld	s2,128(sp)
    80006556:	79e6                	ld	s3,120(sp)
    80006558:	7a46                	ld	s4,112(sp)
}
    8000655a:	853e                	mv	a0,a5
    8000655c:	60ea                	ld	ra,152(sp)
    8000655e:	644a                	ld	s0,144(sp)
    80006560:	64aa                	ld	s1,136(sp)
    80006562:	7aa6                	ld	s5,104(sp)
    80006564:	610d                	addi	sp,sp,160
    80006566:	8082                	ret
        return -1;
    80006568:	57fd                	li	a5,-1
    8000656a:	bfc5                	j	8000655a <sys_passwd+0x14c>

000000008000656c <sys_chmod>:
// =============================================================
// sys_chmod — Placeholder for Phase 2
// =============================================================
uint64
sys_chmod(void)
{
    8000656c:	1141                	addi	sp,sp,-16
    8000656e:	e406                	sd	ra,8(sp)
    80006570:	e022                	sd	s0,0(sp)
    80006572:	0800                	addi	s0,sp,16
    return 0; // Success placeholder
}
    80006574:	4501                	li	a0,0
    80006576:	60a2                	ld	ra,8(sp)
    80006578:	6402                	ld	s0,0(sp)
    8000657a:	0141                	addi	sp,sp,16
    8000657c:	8082                	ret

000000008000657e <sys_chown>:
// =============================================================
// sys_chown — Placeholder for Phase 2
// =============================================================
uint64
sys_chown(void)
{
    8000657e:	1141                	addi	sp,sp,-16
    80006580:	e406                	sd	ra,8(sp)
    80006582:	e022                	sd	s0,0(sp)
    80006584:	0800                	addi	s0,sp,16
    return 0; // Success placeholder
    80006586:	4501                	li	a0,0
    80006588:	60a2                	ld	ra,8(sp)
    8000658a:	6402                	ld	s0,0(sp)
    8000658c:	0141                	addi	sp,sp,16
    8000658e:	8082                	ret

0000000080006590 <audit_init>:
// =============================================================
// audit_init — Called from main() at boot
// =============================================================
void
audit_init(void)
{
    80006590:	1141                	addi	sp,sp,-16
    80006592:	e406                	sd	ra,8(sp)
    80006594:	e022                	sd	s0,0(sp)
    80006596:	0800                	addi	s0,sp,16
    initlock(&g_audit.lock, "audit");
    80006598:	00002597          	auipc	a1,0x2
    8000659c:	42858593          	addi	a1,a1,1064 # 800089c0 <etext+0x9c0>
    800065a0:	00028517          	auipc	a0,0x28
    800065a4:	22850513          	addi	a0,a0,552 # 8002e7c8 <g_audit+0xb410>
    800065a8:	df6fa0ef          	jal	80000b9e <initlock>
    g_audit.head  = 0;
    800065ac:	00028797          	auipc	a5,0x28
    800065b0:	e0c78793          	addi	a5,a5,-500 # 8002e3b8 <g_audit+0xb000>
    800065b4:	4007a023          	sw	zero,1024(a5)
    g_audit.tail  = 0;
    800065b8:	4007a223          	sw	zero,1028(a5)
    g_audit.count = 0;
    800065bc:	4007a423          	sw	zero,1032(a5)
    // Clear buffer
    for (int i = 0; i < AUDIT_MAX; i++)
    800065c0:	0001d797          	auipc	a5,0x1d
    800065c4:	ea878793          	addi	a5,a5,-344 # 80023468 <g_audit+0xb0>
    800065c8:	00028717          	auipc	a4,0x28
    800065cc:	2a070713          	addi	a4,a4,672 # 8002e868 <end+0x88>
        g_audit.buf[i].valid = 0;
    800065d0:	0007a023          	sw	zero,0(a5)
    for (int i = 0; i < AUDIT_MAX; i++)
    800065d4:	0b478793          	addi	a5,a5,180
    800065d8:	fee79ce3          	bne	a5,a4,800065d0 <audit_init+0x40>
}
    800065dc:	60a2                	ld	ra,8(sp)
    800065de:	6402                	ld	s0,0(sp)
    800065e0:	0141                	addi	sp,sp,16
    800065e2:	8082                	ret

00000000800065e4 <audit_log_event>:
// audit_log_event — Write an event to ring buffer AND disk file
// Called from anywhere in the kernel (interrupt-safe via spinlock)
// =============================================================
void
audit_log_event(int pid, int uid, int syscall_num, const char *message)
{
    800065e4:	7131                	addi	sp,sp,-192
    800065e6:	fd06                	sd	ra,184(sp)
    800065e8:	f922                	sd	s0,176(sp)
    800065ea:	f526                	sd	s1,168(sp)
    800065ec:	f14a                	sd	s2,160(sp)
    800065ee:	ed4e                	sd	s3,152(sp)
    800065f0:	e952                	sd	s4,144(sp)
    800065f2:	e556                	sd	s5,136(sp)
    800065f4:	e15a                	sd	s6,128(sp)
    800065f6:	0180                	addi	s0,sp,192
    800065f8:	8a2a                	mv	s4,a0
    800065fa:	89ae                	mv	s3,a1
    800065fc:	8932                	mv	s2,a2
    800065fe:	84b6                	mv	s1,a3
    acquire(&g_audit.lock);
    80006600:	00028517          	auipc	a0,0x28
    80006604:	1c850513          	addi	a0,a0,456 # 8002e7c8 <g_audit+0xb410>
    80006608:	e20fa0ef          	jal	80000c28 <acquire>

    struct audit_entry *e = &g_audit.buf[g_audit.head];
    8000660c:	00028a97          	auipc	s5,0x28
    80006610:	1acaaa83          	lw	s5,428(s5) # 8002e7b8 <g_audit+0xb400>

    e->pid         = pid;
    80006614:	0b400713          	li	a4,180
    80006618:	02ea8733          	mul	a4,s5,a4
    8000661c:	0001d797          	auipc	a5,0x1d
    80006620:	d9c78793          	addi	a5,a5,-612 # 800233b8 <g_audit>
    80006624:	97ba                	add	a5,a5,a4
    80006626:	0147a023          	sw	s4,0(a5)
    e->uid         = uid;
    8000662a:	0137a223          	sw	s3,4(a5)
    e->syscall_num = syscall_num;
    8000662e:	0127a423          	sw	s2,8(a5)

    // Resolve syscall name
    if (syscall_num >= 0 && syscall_num < (int)NUM_SYSCALLS &&
    80006632:	47f5                	li	a5,29
    80006634:	0327e963          	bltu	a5,s2,80006666 <audit_log_event+0x82>
        syscall_names[syscall_num]) {
    80006638:	00391713          	slli	a4,s2,0x3
    8000663c:	00002797          	auipc	a5,0x2
    80006640:	60c78793          	addi	a5,a5,1548 # 80008c48 <syscall_names>
    80006644:	97ba                	add	a5,a5,a4
    80006646:	638c                	ld	a1,0(a5)
    if (syscall_num >= 0 && syscall_num < (int)NUM_SYSCALLS &&
    80006648:	cd99                	beqz	a1,80006666 <audit_log_event+0x82>
        safestrcpy(e->syscall_name, syscall_names[syscall_num], 32);
    8000664a:	0b400793          	li	a5,180
    8000664e:	02fa87b3          	mul	a5,s5,a5
    80006652:	02000613          	li	a2,32
    80006656:	0001d517          	auipc	a0,0x1d
    8000665a:	d6e50513          	addi	a0,a0,-658 # 800233c4 <g_audit+0xc>
    8000665e:	953e                	add	a0,a0,a5
    80006660:	fecfa0ef          	jal	80000e4c <safestrcpy>
    80006664:	a015                	j	80006688 <audit_log_event+0xa4>
    } else {
        safestrcpy(e->syscall_name, "unknown", 32);
    80006666:	0b400793          	li	a5,180
    8000666a:	02fa87b3          	mul	a5,s5,a5
    8000666e:	02000613          	li	a2,32
    80006672:	00002597          	auipc	a1,0x2
    80006676:	35658593          	addi	a1,a1,854 # 800089c8 <etext+0x9c8>
    8000667a:	0001d517          	auipc	a0,0x1d
    8000667e:	d4a50513          	addi	a0,a0,-694 # 800233c4 <g_audit+0xc>
    80006682:	953e                	add	a0,a0,a5
    80006684:	fc8fa0ef          	jal	80000e4c <safestrcpy>
    }

    safestrcpy(e->message, message ? message : "", AUDIT_MSG_LEN);
    80006688:	0b400b13          	li	s6,180
    8000668c:	036a8b33          	mul	s6,s5,s6
    80006690:	0001d517          	auipc	a0,0x1d
    80006694:	d5450513          	addi	a0,a0,-684 # 800233e4 <g_audit+0x2c>
    80006698:	955a                	add	a0,a0,s6
    8000669a:	00002597          	auipc	a1,0x2
    8000669e:	ff658593          	addi	a1,a1,-10 # 80008690 <etext+0x690>
    800066a2:	c091                	beqz	s1,800066a6 <audit_log_event+0xc2>
    800066a4:	85a6                	mv	a1,s1
    800066a6:	08000613          	li	a2,128
    800066aa:	fa2fa0ef          	jal	80000e4c <safestrcpy>
    e->timestamp = ticks;  // Kernel tick counter (defined in trap.c)
    800066ae:	0b400793          	li	a5,180
    800066b2:	02fa8ab3          	mul	s5,s5,a5
    800066b6:	0001d797          	auipc	a5,0x1d
    800066ba:	d0278793          	addi	a5,a5,-766 # 800233b8 <g_audit>
    800066be:	97d6                	add	a5,a5,s5
    800066c0:	00002717          	auipc	a4,0x2
    800066c4:	6b872703          	lw	a4,1720(a4) # 80008d78 <ticks>
    800066c8:	0ae7a623          	sw	a4,172(a5)
    e->valid     = 1;
    800066cc:	4705                	li	a4,1
    800066ce:	0ae7a823          	sw	a4,176(a5)

    // Advance write pointer (wrap around — ring buffer)
    g_audit.head = (g_audit.head + 1) % AUDIT_MAX;
    800066d2:	00028697          	auipc	a3,0x28
    800066d6:	ce668693          	addi	a3,a3,-794 # 8002e3b8 <g_audit+0xb000>
    800066da:	4006a783          	lw	a5,1024(a3)
    800066de:	2785                	addiw	a5,a5,1
    800066e0:	41f7d71b          	sraiw	a4,a5,0x1f
    800066e4:	0187571b          	srliw	a4,a4,0x18
    800066e8:	9fb9                	addw	a5,a5,a4
    800066ea:	0ff7f793          	zext.b	a5,a5
    800066ee:	9f99                	subw	a5,a5,a4
    800066f0:	40f6a023          	sw	a5,1024(a3)

    // If buffer is full, overwrite oldest (tail advances too)
    // WHY: We prefer losing old entries over dropping current events
    if (g_audit.count < AUDIT_MAX) {
    800066f4:	4086a783          	lw	a5,1032(a3)
    800066f8:	0ff00713          	li	a4,255
    800066fc:	16f74563          	blt	a4,a5,80006866 <audit_log_event+0x282>
        g_audit.count++;
    80006700:	2785                	addiw	a5,a5,1
    80006702:	00028717          	auipc	a4,0x28
    80006706:	0af72f23          	sw	a5,190(a4) # 8002e7c0 <g_audit+0xb408>
        // Overwrite: advance tail to discard oldest
        g_audit.tail = (g_audit.tail + 1) % AUDIT_MAX;
        printf("audit: WARNING: ring buffer full, oldest entry dropped\n");
    }

    release(&g_audit.lock);
    8000670a:	00028517          	auipc	a0,0x28
    8000670e:	0be50513          	addi	a0,a0,190 # 8002e7c8 <g_audit+0xb410>
    80006712:	daafa0ef          	jal	80000cbc <release>
    
    // ALSO write to disk file (outside lock to avoid holding lock during I/O)
    audit_write_to_file(pid, uid, syscall_num, e->syscall_name, message);
    80006716:	0001d717          	auipc	a4,0x1d
    8000671a:	cae70713          	addi	a4,a4,-850 # 800233c4 <g_audit+0xc>
    8000671e:	975a                	add	a4,a4,s6
    if (pid < 10) line[off++] = '0' + pid;
    80006720:	47a5                	li	a5,9
    80006722:	1747ca63          	blt	a5,s4,80006896 <audit_log_event+0x2b2>
    80006726:	030a0a1b          	addiw	s4,s4,48
    8000672a:	f5440023          	sb	s4,-192(s0)
    8000672e:	4685                	li	a3,1
    line[off++] = '|';
    80006730:	0016861b          	addiw	a2,a3,1
    80006734:	07c00593          	li	a1,124
    80006738:	fc068793          	addi	a5,a3,-64
    8000673c:	97a2                	add	a5,a5,s0
    8000673e:	f8b78023          	sb	a1,-128(a5)
    if (uid < 10) line[off++] = '0' + uid;
    80006742:	47a5                	li	a5,9
    80006744:	1937c463          	blt	a5,s3,800068cc <audit_log_event+0x2e8>
    80006748:	00268793          	addi	a5,a3,2
    8000674c:	fc060693          	addi	a3,a2,-64
    80006750:	00868633          	add	a2,a3,s0
    80006754:	0309899b          	addiw	s3,s3,48
    80006758:	f9360023          	sb	s3,-128(a2)
    line[off++] = '|';
    8000675c:	0017861b          	addiw	a2,a5,1
    80006760:	07c00593          	li	a1,124
    80006764:	fc078693          	addi	a3,a5,-64
    80006768:	96a2                	add	a3,a3,s0
    8000676a:	f8b68023          	sb	a1,-128(a3)
    if (syscall_num < 10) line[off++] = '0' + syscall_num;
    8000676e:	46a5                	li	a3,9
    80006770:	1b26c163          	blt	a3,s2,80006912 <audit_log_event+0x32e>
    80006774:	0027859b          	addiw	a1,a5,2
    80006778:	fc060793          	addi	a5,a2,-64
    8000677c:	00878633          	add	a2,a5,s0
    80006780:	0309091b          	addiw	s2,s2,48
    80006784:	f9260023          	sb	s2,-128(a2)
    line[off++] = '|';
    80006788:	0015851b          	addiw	a0,a1,1
    8000678c:	07c00693          	li	a3,124
    80006790:	fc058793          	addi	a5,a1,-64
    80006794:	97a2                	add	a5,a5,s0
    80006796:	f8d78023          	sb	a3,-128(a5)
    for (int i = 0; syscall_name[i] && off < 100; i++)
    8000679a:	00074603          	lbu	a2,0(a4)
    8000679e:	c215                	beqz	a2,800067c2 <audit_log_event+0x1de>
    800067a0:	f4040693          	addi	a3,s0,-192
    800067a4:	96aa                	add	a3,a3,a0
    800067a6:	0705                	addi	a4,a4,1
        line[off++] = syscall_name[i];
    800067a8:	0015079b          	addiw	a5,a0,1
    800067ac:	853e                	mv	a0,a5
    800067ae:	00c68023          	sb	a2,0(a3)
    for (int i = 0; syscall_name[i] && off < 100; i++)
    800067b2:	00074603          	lbu	a2,0(a4)
    800067b6:	0685                	addi	a3,a3,1
    800067b8:	0705                	addi	a4,a4,1
    800067ba:	0647a793          	slti	a5,a5,100
    800067be:	c391                	beqz	a5,800067c2 <audit_log_event+0x1de>
    800067c0:	f665                	bnez	a2,800067a8 <audit_log_event+0x1c4>
    line[off++] = '|';
    800067c2:	0015091b          	addiw	s2,a0,1
    800067c6:	07c00713          	li	a4,124
    800067ca:	fc050793          	addi	a5,a0,-64
    800067ce:	97a2                	add	a5,a5,s0
    800067d0:	f8e78023          	sb	a4,-128(a5)
    for (int i = 0; message[i] && off < 118; i++)
    800067d4:	0004c583          	lbu	a1,0(s1)
    800067d8:	c19d                	beqz	a1,800067fe <audit_log_event+0x21a>
    800067da:	f4040613          	addi	a2,s0,-192
    800067de:	964a                	add	a2,a2,s2
    800067e0:	00148693          	addi	a3,s1,1
        line[off++] = message[i];
    800067e4:	0019079b          	addiw	a5,s2,1
    800067e8:	893e                	mv	s2,a5
    800067ea:	00b60023          	sb	a1,0(a2)
    for (int i = 0; message[i] && off < 118; i++)
    800067ee:	0006c583          	lbu	a1,0(a3)
    800067f2:	0605                	addi	a2,a2,1
    800067f4:	0685                	addi	a3,a3,1
    800067f6:	0767a793          	slti	a5,a5,118
    800067fa:	c391                	beqz	a5,800067fe <audit_log_event+0x21a>
    800067fc:	f5e5                	bnez	a1,800067e4 <audit_log_event+0x200>
    line[off++] = '\n';
    800067fe:	4729                	li	a4,10
    80006800:	fc090793          	addi	a5,s2,-64
    80006804:	97a2                	add	a5,a5,s0
    80006806:	f8e78023          	sb	a4,-128(a5)
    struct inode *ip = namei("syscall.log");
    8000680a:	00002517          	auipc	a0,0x2
    8000680e:	1fe50513          	addi	a0,a0,510 # 80008a08 <etext+0xa08>
    80006812:	af4fd0ef          	jal	80003b06 <namei>
    80006816:	84aa                	mv	s1,a0
    if (!ip) return;
    80006818:	cd0d                	beqz	a0,80006852 <audit_log_event+0x26e>
    begin_op();
    8000681a:	ccafd0ef          	jal	80003ce4 <begin_op>
    ilock(ip);
    8000681e:	8526                	mv	a0,s1
    80006820:	a93fc0ef          	jal	800032b2 <ilock>
    line[off++] = '\n';
    80006824:	2905                	addiw	s2,s2,1
    if (writei(ip, 0, (uint64)line, ip->size, off) > 0) {
    80006826:	874a                	mv	a4,s2
    80006828:	44f4                	lw	a3,76(s1)
    8000682a:	f4040613          	addi	a2,s0,-192
    8000682e:	4581                	li	a1,0
    80006830:	8526                	mv	a0,s1
    80006832:	f2bfc0ef          	jal	8000375c <writei>
    80006836:	00a05663          	blez	a0,80006842 <audit_log_event+0x25e>
        ip->size += off;  // Update size
    8000683a:	44fc                	lw	a5,76(s1)
    8000683c:	012787bb          	addw	a5,a5,s2
    80006840:	c4fc                	sw	a5,76(s1)
    iunlock(ip);
    80006842:	8526                	mv	a0,s1
    80006844:	b3ffc0ef          	jal	80003382 <iunlock>
    end_op();
    80006848:	d0cfd0ef          	jal	80003d54 <end_op>
    iput(ip);
    8000684c:	8526                	mv	a0,s1
    8000684e:	c09fc0ef          	jal	80003456 <iput>
}
    80006852:	70ea                	ld	ra,184(sp)
    80006854:	744a                	ld	s0,176(sp)
    80006856:	74aa                	ld	s1,168(sp)
    80006858:	790a                	ld	s2,160(sp)
    8000685a:	69ea                	ld	s3,152(sp)
    8000685c:	6a4a                	ld	s4,144(sp)
    8000685e:	6aaa                	ld	s5,136(sp)
    80006860:	6b0a                	ld	s6,128(sp)
    80006862:	6129                	addi	sp,sp,192
    80006864:	8082                	ret
        g_audit.tail = (g_audit.tail + 1) % AUDIT_MAX;
    80006866:	00028697          	auipc	a3,0x28
    8000686a:	b5268693          	addi	a3,a3,-1198 # 8002e3b8 <g_audit+0xb000>
    8000686e:	4046a783          	lw	a5,1028(a3)
    80006872:	2785                	addiw	a5,a5,1
    80006874:	41f7d71b          	sraiw	a4,a5,0x1f
    80006878:	0187571b          	srliw	a4,a4,0x18
    8000687c:	9fb9                	addw	a5,a5,a4
    8000687e:	0ff7f793          	zext.b	a5,a5
    80006882:	9f99                	subw	a5,a5,a4
    80006884:	40f6a223          	sw	a5,1028(a3)
        printf("audit: WARNING: ring buffer full, oldest entry dropped\n");
    80006888:	00002517          	auipc	a0,0x2
    8000688c:	14850513          	addi	a0,a0,328 # 800089d0 <etext+0x9d0>
    80006890:	c6bf90ef          	jal	800004fa <printf>
    80006894:	bd9d                	j	8000670a <audit_log_event+0x126>
        line[off++] = '0' + (pid / 10);
    80006896:	666667b7          	lui	a5,0x66666
    8000689a:	66778793          	addi	a5,a5,1639 # 66666667 <_entry-0x19999999>
    8000689e:	02fa07b3          	mul	a5,s4,a5
    800068a2:	9789                	srai	a5,a5,0x22
    800068a4:	41fa569b          	sraiw	a3,s4,0x1f
    800068a8:	9f95                	subw	a5,a5,a3
    800068aa:	0307869b          	addiw	a3,a5,48
    800068ae:	f4d40023          	sb	a3,-192(s0)
        line[off++] = '0' + (pid % 10);
    800068b2:	0027969b          	slliw	a3,a5,0x2
    800068b6:	9fb5                	addw	a5,a5,a3
    800068b8:	0017979b          	slliw	a5,a5,0x1
    800068bc:	40fa0a3b          	subw	s4,s4,a5
    800068c0:	030a0a1b          	addiw	s4,s4,48
    800068c4:	f54400a3          	sb	s4,-191(s0)
    800068c8:	4689                	li	a3,2
    800068ca:	b59d                	j	80006730 <audit_log_event+0x14c>
        line[off++] = '0' + (uid / 10);
    800068cc:	fc060793          	addi	a5,a2,-64
    800068d0:	97a2                	add	a5,a5,s0
    800068d2:	66666637          	lui	a2,0x66666
    800068d6:	66760613          	addi	a2,a2,1639 # 66666667 <_entry-0x19999999>
    800068da:	02c98633          	mul	a2,s3,a2
    800068de:	9609                	srai	a2,a2,0x22
    800068e0:	41f9d59b          	sraiw	a1,s3,0x1f
    800068e4:	9e0d                	subw	a2,a2,a1
    800068e6:	0306059b          	addiw	a1,a2,48
    800068ea:	f8b78023          	sb	a1,-128(a5)
        line[off++] = '0' + (uid % 10);
    800068ee:	00368793          	addi	a5,a3,3
        line[off++] = '0' + (uid / 10);
    800068f2:	2689                	addiw	a3,a3,2
        line[off++] = '0' + (uid % 10);
    800068f4:	fc068693          	addi	a3,a3,-64
    800068f8:	96a2                	add	a3,a3,s0
    800068fa:	0026159b          	slliw	a1,a2,0x2
    800068fe:	9e2d                	addw	a2,a2,a1
    80006900:	0016161b          	slliw	a2,a2,0x1
    80006904:	40c989bb          	subw	s3,s3,a2
    80006908:	0309899b          	addiw	s3,s3,48
    8000690c:	f9368023          	sb	s3,-128(a3)
    80006910:	b5b1                	j	8000675c <audit_log_event+0x178>
        line[off++] = '0' + (syscall_num / 10);
    80006912:	fc060693          	addi	a3,a2,-64
    80006916:	00868633          	add	a2,a3,s0
    8000691a:	666666b7          	lui	a3,0x66666
    8000691e:	66768693          	addi	a3,a3,1639 # 66666667 <_entry-0x19999999>
    80006922:	02d906b3          	mul	a3,s2,a3
    80006926:	9689                	srai	a3,a3,0x22
    80006928:	41f9559b          	sraiw	a1,s2,0x1f
    8000692c:	9e8d                	subw	a3,a3,a1
    8000692e:	0306859b          	addiw	a1,a3,48
    80006932:	f8b60023          	sb	a1,-128(a2)
        line[off++] = '0' + (syscall_num % 10);
    80006936:	0037859b          	addiw	a1,a5,3
        line[off++] = '0' + (syscall_num / 10);
    8000693a:	2789                	addiw	a5,a5,2
        line[off++] = '0' + (syscall_num % 10);
    8000693c:	fc078793          	addi	a5,a5,-64
    80006940:	97a2                	add	a5,a5,s0
    80006942:	0026961b          	slliw	a2,a3,0x2
    80006946:	9eb1                	addw	a3,a3,a2
    80006948:	0016969b          	slliw	a3,a3,0x1
    8000694c:	40d9093b          	subw	s2,s2,a3
    80006950:	0309091b          	addiw	s2,s2,48
    80006954:	f9278023          	sb	s2,-128(a5)
    80006958:	bd05                	j	80006788 <audit_log_event+0x1a4>

000000008000695a <sys_audit_read>:
// sys_audit_read — Export audit log to user space (ADMIN only)
// Returns -1 (EPERM) if caller is not uid=0
// =============================================================
uint64
sys_audit_read(void)
{
    8000695a:	711d                	addi	sp,sp,-96
    8000695c:	ec86                	sd	ra,88(sp)
    8000695e:	e8a2                	sd	s0,80(sp)
    80006960:	fc4e                	sd	s3,56(sp)
    80006962:	ec5e                	sd	s7,24(sp)
    80006964:	1080                	addi	s0,sp,96
    struct proc *p = myproc();
    80006966:	fd1fa0ef          	jal	80001936 <myproc>
    8000696a:	8baa                	mv	s7,a0

    // WHY hard block on non-admin: audit logs contain sensitive
    // operational data; a patient or doctor reading it could learn
    // timing patterns about the insulin pump's behavior
    if (p->creds.uid != ROLE_ADMIN) {
    8000696c:	16852983          	lw	s3,360(a0)
    80006970:	04099f63          	bnez	s3,800069ce <sys_audit_read+0x74>
    }

    // Arguments: user buffer pointer, max bytes to copy
    uint64 user_buf;
    int    max_bytes;
    if (argaddr(0, &user_buf) < 0 || argint(1, &max_bytes) < 0)
    80006974:	fa840593          	addi	a1,s0,-88
    80006978:	4501                	li	a0,0
    8000697a:	f43fb0ef          	jal	800028bc <argaddr>
        return -1;
    8000697e:	57fd                	li	a5,-1
    if (argaddr(0, &user_buf) < 0 || argint(1, &max_bytes) < 0)
    80006980:	0c054a63          	bltz	a0,80006a54 <sys_audit_read+0xfa>
    80006984:	fa440593          	addi	a1,s0,-92
    80006988:	4505                	li	a0,1
    8000698a:	f15fb0ef          	jal	8000289e <argint>
        return -1;
    8000698e:	57fd                	li	a5,-1
    if (argaddr(0, &user_buf) < 0 || argint(1, &max_bytes) < 0)
    80006990:	0c054263          	bltz	a0,80006a54 <sys_audit_read+0xfa>
    80006994:	f05a                	sd	s6,32(sp)
    // Serialize ring buffer into text format for user space
    // WHY text format: easier for user-space to display/parse;
    // binary format would require matching structs
    int  written = 0;

    acquire(&g_audit.lock);
    80006996:	00028517          	auipc	a0,0x28
    8000699a:	e3250513          	addi	a0,a0,-462 # 8002e7c8 <g_audit+0xb410>
    8000699e:	a8afa0ef          	jal	80000c28 <acquire>

    int idx   = g_audit.tail;
    int count = g_audit.count;
    800069a2:	00028b17          	auipc	s6,0x28
    800069a6:	e1eb2b03          	lw	s6,-482(s6) # 8002e7c0 <g_audit+0xb408>

    for (int i = 0; i < count && written < max_bytes - 1; i++) {
    800069aa:	09605d63          	blez	s6,80006a44 <sys_audit_read+0xea>
    800069ae:	e4a6                	sd	s1,72(sp)
    800069b0:	e0ca                	sd	s2,64(sp)
    800069b2:	f852                	sd	s4,48(sp)
    800069b4:	f456                	sd	s5,40(sp)
    int idx   = g_audit.tail;
    800069b6:	00028497          	auipc	s1,0x28
    800069ba:	e064a483          	lw	s1,-506(s1) # 8002e7bc <g_audit+0xb404>
    for (int i = 0; i < count && written < max_bytes - 1; i++) {
    800069be:	894e                	mv	s2,s3
        struct audit_entry *e = &g_audit.buf[idx];
        if (e->valid) {
    800069c0:	0001da97          	auipc	s5,0x1d
    800069c4:	9f8a8a93          	addi	s5,s5,-1544 # 800233b8 <g_audit>
    800069c8:	0b400a13          	li	s4,180
    800069cc:	a805                	j	800069fc <sys_audit_read+0xa2>
        audit_log_event(p->pid, p->creds.uid, SYS_audit_read,
    800069ce:	00002697          	auipc	a3,0x2
    800069d2:	04a68693          	addi	a3,a3,74 # 80008a18 <etext+0xa18>
    800069d6:	4675                	li	a2,29
    800069d8:	85ce                	mv	a1,s3
    800069da:	5908                	lw	a0,48(a0)
    800069dc:	c09ff0ef          	jal	800065e4 <audit_log_event>
        return -1;  // EPERM
    800069e0:	57fd                	li	a5,-1
    800069e2:	a88d                	j	80006a54 <sys_audit_read+0xfa>
                            (char*)e, sizeof(struct audit_entry)) < 0)
                    break;
                written += sizeof(struct audit_entry);
            }
        }
        idx = (idx + 1) % AUDIT_MAX;
    800069e4:	2485                	addiw	s1,s1,1
    800069e6:	41f4d79b          	sraiw	a5,s1,0x1f
    800069ea:	0187d79b          	srliw	a5,a5,0x18
    800069ee:	9cbd                	addw	s1,s1,a5
    800069f0:	0ff4f493          	zext.b	s1,s1
    800069f4:	9c9d                	subw	s1,s1,a5
    for (int i = 0; i < count && written < max_bytes - 1; i++) {
    800069f6:	2905                	addiw	s2,s2,1
    800069f8:	072b0a63          	beq	s6,s2,80006a6c <sys_audit_read+0x112>
    800069fc:	fa442703          	lw	a4,-92(s0)
    80006a00:	fff7079b          	addiw	a5,a4,-1
    80006a04:	02f9dc63          	bge	s3,a5,80006a3c <sys_audit_read+0xe2>
        if (e->valid) {
    80006a08:	034487b3          	mul	a5,s1,s4
    80006a0c:	97d6                	add	a5,a5,s5
    80006a0e:	0b07a783          	lw	a5,176(a5)
    80006a12:	dbe9                	beqz	a5,800069e4 <sys_audit_read+0x8a>
            if (written + (int)sizeof(struct audit_entry) <= max_bytes) {
    80006a14:	0b39879b          	addiw	a5,s3,179
    80006a18:	fce7d6e3          	bge	a5,a4,800069e4 <sys_audit_read+0x8a>
        struct audit_entry *e = &g_audit.buf[idx];
    80006a1c:	03448633          	mul	a2,s1,s4
                if (copyout(p->pagetable, user_buf + written,
    80006a20:	86d2                	mv	a3,s4
    80006a22:	9656                	add	a2,a2,s5
    80006a24:	fa843583          	ld	a1,-88(s0)
    80006a28:	95ce                	add	a1,a1,s3
    80006a2a:	050bb503          	ld	a0,80(s7)
    80006a2e:	c2ffa0ef          	jal	8000165c <copyout>
    80006a32:	02054863          	bltz	a0,80006a62 <sys_audit_read+0x108>
                written += sizeof(struct audit_entry);
    80006a36:	0b49899b          	addiw	s3,s3,180
    80006a3a:	b76d                	j	800069e4 <sys_audit_read+0x8a>
    80006a3c:	64a6                	ld	s1,72(sp)
    80006a3e:	6906                	ld	s2,64(sp)
    80006a40:	7a42                	ld	s4,48(sp)
    80006a42:	7aa2                	ld	s5,40(sp)
    }

    release(&g_audit.lock);
    80006a44:	00028517          	auipc	a0,0x28
    80006a48:	d8450513          	addi	a0,a0,-636 # 8002e7c8 <g_audit+0xb410>
    80006a4c:	a70fa0ef          	jal	80000cbc <release>
    return written;
    80006a50:	87ce                	mv	a5,s3
    80006a52:	7b02                	ld	s6,32(sp)
}
    80006a54:	853e                	mv	a0,a5
    80006a56:	60e6                	ld	ra,88(sp)
    80006a58:	6446                	ld	s0,80(sp)
    80006a5a:	79e2                	ld	s3,56(sp)
    80006a5c:	6be2                	ld	s7,24(sp)
    80006a5e:	6125                	addi	sp,sp,96
    80006a60:	8082                	ret
    80006a62:	64a6                	ld	s1,72(sp)
    80006a64:	6906                	ld	s2,64(sp)
    80006a66:	7a42                	ld	s4,48(sp)
    80006a68:	7aa2                	ld	s5,40(sp)
    80006a6a:	bfe9                	j	80006a44 <sys_audit_read+0xea>
    80006a6c:	64a6                	ld	s1,72(sp)
    80006a6e:	6906                	ld	s2,64(sp)
    80006a70:	7a42                	ld	s4,48(sp)
    80006a72:	7aa2                	ld	s5,40(sp)
    80006a74:	bfc1                	j	80006a44 <sys_audit_read+0xea>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	9282                	jalr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
