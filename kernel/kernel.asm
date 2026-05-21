
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
    80000004:	ef010113          	addi	sp,sp,-272 # 80008ef0 <stack0>
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
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffcfeaf>
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
    80000196:	d5e50513          	addi	a0,a0,-674 # 80010ef0 <cons>
    8000019a:	28f000ef          	jal	80000c28 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019e:	00011497          	auipc	s1,0x11
    800001a2:	d5248493          	addi	s1,s1,-686 # 80010ef0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a6:	00011917          	auipc	s2,0x11
    800001aa:	de290913          	addi	s2,s2,-542 # 80010f88 <cons+0x98>
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
    800001e2:	d1270713          	addi	a4,a4,-750 # 80010ef0 <cons>
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
    8000022c:	cc850513          	addi	a0,a0,-824 # 80010ef0 <cons>
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
    80000252:	d2f72d23          	sw	a5,-710(a4) # 80010f88 <cons+0x98>
    80000256:	7aa2                	ld	s5,40(sp)
    80000258:	a031                	j	80000264 <consoleread+0xee>
    8000025a:	f456                	sd	s5,40(sp)
    8000025c:	b749                	j	800001de <consoleread+0x68>
    8000025e:	7aa2                	ld	s5,40(sp)
    80000260:	a011                	j	80000264 <consoleread+0xee>
    80000262:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000264:	00011517          	auipc	a0,0x11
    80000268:	c8c50513          	addi	a0,a0,-884 # 80010ef0 <cons>
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
    800002bc:	c3850513          	addi	a0,a0,-968 # 80010ef0 <cons>
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
    800002e2:	c1250513          	addi	a0,a0,-1006 # 80010ef0 <cons>
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
    80000300:	bf470713          	addi	a4,a4,-1036 # 80010ef0 <cons>
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
    80000326:	bce70713          	addi	a4,a4,-1074 # 80010ef0 <cons>
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
    80000350:	c3c72703          	lw	a4,-964(a4) # 80010f88 <cons+0x98>
    80000354:	9f99                	subw	a5,a5,a4
    80000356:	08000713          	li	a4,128
    8000035a:	f8e792e3          	bne	a5,a4,800002de <consoleintr+0x32>
    8000035e:	a075                	j	8000040a <consoleintr+0x15e>
    80000360:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000362:	00011717          	auipc	a4,0x11
    80000366:	b8e70713          	addi	a4,a4,-1138 # 80010ef0 <cons>
    8000036a:	0a072783          	lw	a5,160(a4)
    8000036e:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000372:	00011497          	auipc	s1,0x11
    80000376:	b7e48493          	addi	s1,s1,-1154 # 80010ef0 <cons>
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
    800003b8:	b3c70713          	addi	a4,a4,-1220 # 80010ef0 <cons>
    800003bc:	0a072783          	lw	a5,160(a4)
    800003c0:	09c72703          	lw	a4,156(a4)
    800003c4:	f0f70de3          	beq	a4,a5,800002de <consoleintr+0x32>
      cons.e--;
    800003c8:	37fd                	addiw	a5,a5,-1
    800003ca:	00011717          	auipc	a4,0x11
    800003ce:	bcf72323          	sw	a5,-1082(a4) # 80010f90 <cons+0xa0>
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
    800003ec:	b0878793          	addi	a5,a5,-1272 # 80010ef0 <cons>
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
    8000040e:	b8c7a123          	sw	a2,-1150(a5) # 80010f8c <cons+0x9c>
        wakeup(&cons.r);
    80000412:	00011517          	auipc	a0,0x11
    80000416:	b7650513          	addi	a0,a0,-1162 # 80010f88 <cons+0x98>
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
    80000434:	ac050513          	addi	a0,a0,-1344 # 80010ef0 <cons>
    80000438:	766000ef          	jal	80000b9e <initlock>

  uartinit();
    8000043c:	448000ef          	jal	80000884 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000440:	00022797          	auipc	a5,0x22
    80000444:	bb078793          	addi	a5,a5,-1104 # 80021ff0 <devsw>
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
    80000482:	7b280813          	addi	a6,a6,1970 # 80008c30 <digits>
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
    8000051c:	9ac7a783          	lw	a5,-1620(a5) # 80008ec4 <panicking>
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
    80000562:	a3a50513          	addi	a0,a0,-1478 # 80010f98 <pr>
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
    800006d6:	55ec8c93          	addi	s9,s9,1374 # 80008c30 <digits>
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
    8000075e:	76a7a783          	lw	a5,1898(a5) # 80008ec4 <panicking>
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
    80000784:	00011517          	auipc	a0,0x11
    80000788:	81450513          	addi	a0,a0,-2028 # 80010f98 <pr>
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
    80000838:	6897a823          	sw	s1,1680(a5) # 80008ec4 <panicking>
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
    8000085a:	6697a523          	sw	s1,1642(a5) # 80008ec0 <panicked>
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
    80000874:	72850513          	addi	a0,a0,1832 # 80010f98 <pr>
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
    800008ca:	6ea50513          	addi	a0,a0,1770 # 80010fb0 <tx_lock>
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
    800008ee:	6c650513          	addi	a0,a0,1734 # 80010fb0 <tx_lock>
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
    8000090c:	5c448493          	addi	s1,s1,1476 # 80008ecc <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000910:	00010997          	auipc	s3,0x10
    80000914:	6a098993          	addi	s3,s3,1696 # 80010fb0 <tx_lock>
    80000918:	00008917          	auipc	s2,0x8
    8000091c:	5b090913          	addi	s2,s2,1456 # 80008ec8 <tx_chan>
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
    8000095a:	65a50513          	addi	a0,a0,1626 # 80010fb0 <tx_lock>
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
    8000097e:	54a7a783          	lw	a5,1354(a5) # 80008ec4 <panicking>
    80000982:	cf95                	beqz	a5,800009be <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000984:	00008797          	auipc	a5,0x8
    80000988:	53c7a783          	lw	a5,1340(a5) # 80008ec0 <panicked>
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
    800009ae:	51a7a783          	lw	a5,1306(a5) # 80008ec4 <panicking>
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
    80000a0a:	5aa50513          	addi	a0,a0,1450 # 80010fb0 <tx_lock>
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
    80000a24:	59050513          	addi	a0,a0,1424 # 80010fb0 <tx_lock>
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
    80000a40:	4807a823          	sw	zero,1168(a5) # 80008ecc <tx_busy>
    wakeup(&tx_chan);
    80000a44:	00008517          	auipc	a0,0x8
    80000a48:	48450513          	addi	a0,a0,1156 # 80008ec8 <tx_chan>
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
    80000a6c:	ee878793          	addi	a5,a5,-280 # 8002e950 <end>
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
    80000a96:	53690913          	addi	s2,s2,1334 # 80010fc8 <kmem>
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
    80000b24:	4a850513          	addi	a0,a0,1192 # 80010fc8 <kmem>
    80000b28:	076000ef          	jal	80000b9e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b2c:	45c5                	li	a1,17
    80000b2e:	05ee                	slli	a1,a1,0x1b
    80000b30:	0002e517          	auipc	a0,0x2e
    80000b34:	e2050513          	addi	a0,a0,-480 # 8002e950 <end>
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
    80000b52:	47a50513          	addi	a0,a0,1146 # 80010fc8 <kmem>
    80000b56:	0d2000ef          	jal	80000c28 <acquire>
  r = kmem.freelist;
    80000b5a:	00010497          	auipc	s1,0x10
    80000b5e:	4864b483          	ld	s1,1158(s1) # 80010fe0 <kmem+0x18>
  if(r)
    80000b62:	c49d                	beqz	s1,80000b90 <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b64:	609c                	ld	a5,0(s1)
    80000b66:	00010717          	auipc	a4,0x10
    80000b6a:	46f73d23          	sd	a5,1146(a4) # 80010fe0 <kmem+0x18>
  release(&kmem.lock);
    80000b6e:	00010517          	auipc	a0,0x10
    80000b72:	45a50513          	addi	a0,a0,1114 # 80010fc8 <kmem>
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
    80000b94:	43850513          	addi	a0,a0,1080 # 80010fc8 <kmem>
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
    80000ebe:	01670713          	addi	a4,a4,22 # 80008ed0 <started>
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
    80000ee8:	211040ef          	jal	800058f8 <plicinithart>
  }

  scheduler();        
    80000eec:	70d000ef          	jal	80001df8 <scheduler>
    consoleinit();
    80000ef0:	d30ff0ef          	jal	80000420 <consoleinit>
    printfinit();
    80000ef4:	96dff0ef          	jal	80000860 <printfinit>
    printf("\n");
    80000ef8:	00008517          	auipc	a0,0x8
    80000efc:	9e850513          	addi	a0,a0,-1560 # 800088e0 <etext+0x8e0>
    80000f00:	dfaff0ef          	jal	800004fa <printf>
    printf("xv6 kernel is booting\n");
    80000f04:	00007517          	auipc	a0,0x7
    80000f08:	17c50513          	addi	a0,a0,380 # 80008080 <etext+0x80>
    80000f0c:	deeff0ef          	jal	800004fa <printf>
    printf("\n");
    80000f10:	00008517          	auipc	a0,0x8
    80000f14:	9d050513          	addi	a0,a0,-1584 # 800088e0 <etext+0x8e0>
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
    80000f34:	1ab040ef          	jal	800058de <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f38:	1c1040ef          	jal	800058f8 <plicinithart>
    binit();         // buffer cache
    80000f3c:	4d1010ef          	jal	80002c0c <binit>
    iinit();         // inode table
    80000f40:	222020ef          	jal	80003162 <iinit>
    fileinit();      // file table
    80000f44:	22a030ef          	jal	8000416e <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f48:	2a1040ef          	jal	800059e8 <virtio_disk_init>
    audit_init();          // Must be before auth_init (auth logs events)
    80000f4c:	00b050ef          	jal	80006756 <audit_init>
    auth_init();           // Load default user credentials
    80000f50:	7ab040ef          	jal	80005efa <auth_init>
    userinit();      // first user process
    80000f54:	4ad000ef          	jal	80001c00 <userinit>
    __sync_synchronize();
    80000f58:	0330000f          	fence	rw,rw
    started = 1;
    80000f5c:	4785                	li	a5,1
    80000f5e:	00008717          	auipc	a4,0x8
    80000f62:	f6f72923          	sw	a5,-142(a4) # 80008ed0 <started>
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
    80000f78:	f647b783          	ld	a5,-156(a5) # 80008ed8 <kernel_pagetable>
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
    80001204:	cca7bc23          	sd	a0,-808(a5) # 80008ed8 <kernel_pagetable>
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
    800017c6:	c5648493          	addi	s1,s1,-938 # 80011418 <proc>
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
    800017f6:	426a8a93          	addi	s5,s5,1062 # 80017c18 <tickslock>
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
    8000186c:	78050513          	addi	a0,a0,1920 # 80010fe8 <pid_lock>
    80001870:	b2eff0ef          	jal	80000b9e <initlock>
  initlock(&wait_lock, "wait_lock");
    80001874:	00007597          	auipc	a1,0x7
    80001878:	8f458593          	addi	a1,a1,-1804 # 80008168 <etext+0x168>
    8000187c:	0000f517          	auipc	a0,0xf
    80001880:	78450513          	addi	a0,a0,1924 # 80011000 <wait_lock>
    80001884:	b1aff0ef          	jal	80000b9e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001888:	00010497          	auipc	s1,0x10
    8000188c:	b9048493          	addi	s1,s1,-1136 # 80011418 <proc>
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
    800018c0:	35ca0a13          	addi	s4,s4,860 # 80017c18 <tickslock>
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
    80001928:	6f450513          	addi	a0,a0,1780 # 80011018 <cpus>
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
    8000194e:	69e70713          	addi	a4,a4,1694 # 80010fe8 <pid_lock>
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
    80001980:	5347a783          	lw	a5,1332(a5) # 80008eb0 <first.1>
    80001984:	cf95                	beqz	a5,800019c0 <forkret+0x58>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001986:	4505                	li	a0,1
    80001988:	4ff010ef          	jal	80003686 <fsinit>

    first = 0;
    8000198c:	00007797          	auipc	a5,0x7
    80001990:	5207a223          	sw	zero,1316(a5) # 80008eb0 <first.1>
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
    800019ae:	797020ef          	jal	80004944 <kexec>
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
    80001a10:	5dc50513          	addi	a0,a0,1500 # 80010fe8 <pid_lock>
    80001a14:	a14ff0ef          	jal	80000c28 <acquire>
  pid = nextpid;
    80001a18:	00007797          	auipc	a5,0x7
    80001a1c:	49c78793          	addi	a5,a5,1180 # 80008eb4 <nextpid>
    80001a20:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a22:	0014871b          	addiw	a4,s1,1
    80001a26:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a28:	0000f517          	auipc	a0,0xf
    80001a2c:	5c050513          	addi	a0,a0,1472 # 80010fe8 <pid_lock>
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
    80001b66:	00010497          	auipc	s1,0x10
    80001b6a:	8b248493          	addi	s1,s1,-1870 # 80011418 <proc>
    80001b6e:	00016917          	auipc	s2,0x16
    80001b72:	0aa90913          	addi	s2,s2,170 # 80017c18 <tickslock>
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
    80001c14:	2ca7b823          	sd	a0,720(a5) # 80008ee0 <initproc>
  p->cwd = namei("/");
    80001c18:	00006517          	auipc	a0,0x6
    80001c1c:	57850513          	addi	a0,a0,1400 # 80008190 <etext+0x190>
    80001c20:	7a5010ef          	jal	80003bc4 <namei>
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
    80001d38:	4b8020ef          	jal	800041f0 <filedup>
    80001d3c:	00a93023          	sd	a0,0(s2)
    80001d40:	b7f5                	j	80001d2c <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001d42:	150a3503          	ld	a0,336(s4)
    80001d46:	5f4010ef          	jal	8000333a <idup>
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
    80001db6:	24e50513          	addi	a0,a0,590 # 80011000 <wait_lock>
    80001dba:	e6ffe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001dbe:	0349bc23          	sd	s4,56(s3)
  release(&wait_lock);
    80001dc2:	0000f517          	auipc	a0,0xf
    80001dc6:	23e50513          	addi	a0,a0,574 # 80011000 <wait_lock>
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
    80001e1c:	1d070713          	addi	a4,a4,464 # 80010fe8 <pid_lock>
    80001e20:	975a                	add	a4,a4,s6
    80001e22:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001e26:	0000f717          	auipc	a4,0xf
    80001e2a:	1fa70713          	addi	a4,a4,506 # 80011020 <cpus+0x8>
    80001e2e:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001e30:	4c11                	li	s8,4
        c->proc = p;
    80001e32:	079e                	slli	a5,a5,0x7
    80001e34:	0000fa17          	auipc	s4,0xf
    80001e38:	1b4a0a13          	addi	s4,s4,436 # 80010fe8 <pid_lock>
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
    80001e9a:	58248493          	addi	s1,s1,1410 # 80011418 <proc>
      if(p->state == RUNNABLE) {
    80001e9e:	498d                	li	s3,3
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ea0:	00016917          	auipc	s2,0x16
    80001ea4:	d7890913          	addi	s2,s2,-648 # 80017c18 <tickslock>
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
    80001ece:	11e70713          	addi	a4,a4,286 # 80010fe8 <pid_lock>
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
    80001ef4:	0f890913          	addi	s2,s2,248 # 80010fe8 <pid_lock>
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
    80001f0e:	10e58593          	addi	a1,a1,270 # 80011018 <cpus>
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
    80001ff6:	42648493          	addi	s1,s1,1062 # 80011418 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001ffa:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001ffc:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ffe:	00016917          	auipc	s2,0x16
    80002002:	c1a90913          	addi	s2,s2,-998 # 80017c18 <tickslock>
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
    8000205e:	3be48493          	addi	s1,s1,958 # 80011418 <proc>
      pp->parent = initproc;
    80002062:	00007a17          	auipc	s4,0x7
    80002066:	e7ea0a13          	addi	s4,s4,-386 # 80008ee0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000206a:	00016997          	auipc	s3,0x16
    8000206e:	bae98993          	addi	s3,s3,-1106 # 80017c18 <tickslock>
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
    800020ba:	e2a7b783          	ld	a5,-470(a5) # 80008ee0 <initproc>
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
    800020e0:	156020ef          	jal	80004236 <fileclose>
      p->ofile[fd] = 0;
    800020e4:	0004b023          	sd	zero,0(s1)
    800020e8:	b7fd                	j	800020d6 <kexit+0x38>
  begin_op();
    800020ea:	4b9010ef          	jal	80003da2 <begin_op>
  iput(p->cwd);
    800020ee:	1509b503          	ld	a0,336(s3)
    800020f2:	422010ef          	jal	80003514 <iput>
  end_op();
    800020f6:	51d010ef          	jal	80003e12 <end_op>
  p->cwd = 0;
    800020fa:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800020fe:	0000f517          	auipc	a0,0xf
    80002102:	f0250513          	addi	a0,a0,-254 # 80011000 <wait_lock>
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
    8000212c:	ed850513          	addi	a0,a0,-296 # 80011000 <wait_lock>
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
    80002158:	2c448493          	addi	s1,s1,708 # 80011418 <proc>
    8000215c:	00016997          	auipc	s3,0x16
    80002160:	abc98993          	addi	s3,s3,-1348 # 80017c18 <tickslock>
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
    8000221a:	dea50513          	addi	a0,a0,-534 # 80011000 <wait_lock>
    8000221e:	a0bfe0ef          	jal	80000c28 <acquire>
        if(pp->state == ZOMBIE){
    80002222:	4a15                	li	s4,5
        havekids = 1;
    80002224:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002226:	00016997          	auipc	s3,0x16
    8000222a:	9f298993          	addi	s3,s3,-1550 # 80017c18 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000222e:	0000fb17          	auipc	s6,0xf
    80002232:	dd2b0b13          	addi	s6,s6,-558 # 80011000 <wait_lock>
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
    80002264:	da050513          	addi	a0,a0,-608 # 80011000 <wait_lock>
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
    8000228e:	d7650513          	addi	a0,a0,-650 # 80011000 <wait_lock>
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
    800022d6:	14648493          	addi	s1,s1,326 # 80011418 <proc>
    800022da:	b7e1                	j	800022a2 <kwait+0xaa>
      release(&wait_lock);
    800022dc:	0000f517          	auipc	a0,0xf
    800022e0:	d2450513          	addi	a0,a0,-732 # 80011000 <wait_lock>
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
    8000239a:	54a50513          	addi	a0,a0,1354 # 800088e0 <etext+0x8e0>
    8000239e:	95cfe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800023a2:	0000f497          	auipc	s1,0xf
    800023a6:	1ce48493          	addi	s1,s1,462 # 80011570 <proc+0x158>
    800023aa:	00016917          	auipc	s2,0x16
    800023ae:	9c690913          	addi	s2,s2,-1594 # 80017d70 <bcache+0x140>
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
    800023c8:	51ca0a13          	addi	s4,s4,1308 # 800088e0 <etext+0x8e0>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023cc:	00007b97          	auipc	s7,0x7
    800023d0:	87cb8b93          	addi	s7,s7,-1924 # 80008c48 <states.0>
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
  }
}

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
    800024a2:	77a50513          	addi	a0,a0,1914 # 80017c18 <tickslock>
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
    800024be:	3c678793          	addi	a5,a5,966 # 80005880 <kernelvec>
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
    80002574:	6a850513          	addi	a0,a0,1704 # 80017c18 <tickslock>
    80002578:	eb0fe0ef          	jal	80000c28 <acquire>
    ticks++;
    8000257c:	00007717          	auipc	a4,0x7
    80002580:	96c70713          	addi	a4,a4,-1684 # 80008ee8 <ticks>
    80002584:	431c                	lw	a5,0(a4)
    80002586:	2785                	addiw	a5,a5,1
    80002588:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    8000258a:	853a                	mv	a0,a4
    8000258c:	a53ff0ef          	jal	80001fde <wakeup>
    release(&tickslock);
    80002590:	00015517          	auipc	a0,0x15
    80002594:	68850513          	addi	a0,a0,1672 # 80017c18 <tickslock>
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
    800025ca:	362030ef          	jal	8000592c <plic_claim>
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
    800025ec:	7d6030ef          	jal	80005dc2 <virtio_disk_intr>
    if(irq)
    800025f0:	a801                	j	80002600 <devintr+0x62>
      printf("unexpected interrupt irq=%d\n", irq);
    800025f2:	85ba                	mv	a1,a4
    800025f4:	00006517          	auipc	a0,0x6
    800025f8:	c9450513          	addi	a0,a0,-876 # 80008288 <etext+0x288>
    800025fc:	efffd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    80002600:	8526                	mv	a0,s1
    80002602:	34a030ef          	jal	8000594c <plic_complete>
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
    80002628:	e3bd                	bnez	a5,8000268e <usertrap+0x7a>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000262a:	00003797          	auipc	a5,0x3
    8000262e:	25678793          	addi	a5,a5,598 # 80005880 <kernelvec>
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
    8000264a:	04f70863          	beq	a4,a5,8000269a <usertrap+0x86>
  } else if((which_dev = devintr()) != 0){
    8000264e:	f51ff0ef          	jal	8000259e <devintr>
    80002652:	892a                	mv	s2,a0
    80002654:	16051763          	bnez	a0,800027c2 <usertrap+0x1ae>
    80002658:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    8000265c:	47bd                	li	a5,15
    8000265e:	08f70363          	beq	a4,a5,800026e4 <usertrap+0xd0>
    80002662:	14202773          	csrr	a4,scause
    80002666:	47b5                	li	a5,13
    80002668:	06f70e63          	beq	a4,a5,800026e4 <usertrap+0xd0>
    8000266c:	14202673          	csrr	a2,scause
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002670:	141027f3          	csrr	a5,sepc
  switch(scause) {
    80002674:	473d                	li	a4,15
    80002676:	12c76c63          	bltu	a4,a2,800027ae <usertrap+0x19a>
    8000267a:	00261713          	slli	a4,a2,0x2
    8000267e:	00006697          	auipc	a3,0x6
    80002682:	5fa68693          	addi	a3,a3,1530 # 80008c78 <states.0+0x30>
    80002686:	9736                	add	a4,a4,a3
    80002688:	4318                	lw	a4,0(a4)
    8000268a:	9736                	add	a4,a4,a3
    8000268c:	8702                	jr	a4
    panic("usertrap: not from user mode");
    8000268e:	00006517          	auipc	a0,0x6
    80002692:	dba50513          	addi	a0,a0,-582 # 80008448 <etext+0x448>
    80002696:	98efe0ef          	jal	80000824 <panic>
    if(killed(p))
    8000269a:	b35ff0ef          	jal	800021ce <killed>
    8000269e:	ed1d                	bnez	a0,800026dc <usertrap+0xc8>
    p->trapframe->epc += 4;
    800026a0:	6cb8                	ld	a4,88(s1)
    800026a2:	6f1c                	ld	a5,24(a4)
    800026a4:	0791                	addi	a5,a5,4
    800026a6:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026a8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800026ac:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026b0:	10079073          	csrw	sstatus,a5
    syscall();
    800026b4:	30c000ef          	jal	800029c0 <syscall>
  if(killed(p))
    800026b8:	8526                	mv	a0,s1
    800026ba:	b15ff0ef          	jal	800021ce <killed>
    800026be:	10051763          	bnez	a0,800027cc <usertrap+0x1b8>
  prepare_return();
    800026c2:	e0dff0ef          	jal	800024ce <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800026c6:	68a8                	ld	a0,80(s1)
    800026c8:	8131                	srli	a0,a0,0xc
    800026ca:	57fd                	li	a5,-1
    800026cc:	17fe                	slli	a5,a5,0x3f
    800026ce:	8d5d                	or	a0,a0,a5
}
    800026d0:	60e2                	ld	ra,24(sp)
    800026d2:	6442                	ld	s0,16(sp)
    800026d4:	64a2                	ld	s1,8(sp)
    800026d6:	6902                	ld	s2,0(sp)
    800026d8:	6105                	addi	sp,sp,32
    800026da:	8082                	ret
      kexit(-1);
    800026dc:	557d                	li	a0,-1
    800026de:	9c1ff0ef          	jal	8000209e <kexit>
    800026e2:	bf7d                	j	800026a0 <usertrap+0x8c>
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026e4:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026e8:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    800026ec:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    800026ee:	00163613          	seqz	a2,a2
    800026f2:	68a8                	ld	a0,80(s1)
    800026f4:	ee5fe0ef          	jal	800015d8 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800026f8:	f161                	bnez	a0,800026b8 <usertrap+0xa4>
    800026fa:	bf8d                	j	8000266c <usertrap+0x58>
    case 0:  return "Instruction address misaligned";
    800026fc:	00006597          	auipc	a1,0x6
    80002700:	bac58593          	addi	a1,a1,-1108 # 800082a8 <etext+0x2a8>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002704:	14302873          	csrr	a6,stval
    printf("TRAP [%s] (0x%lx): PID=%d UID=%d EIP=0x%lx STVAL=0x%lx\n",
    80002708:	1684a703          	lw	a4,360(s1)
    8000270c:	5894                	lw	a3,48(s1)
    8000270e:	00006517          	auipc	a0,0x6
    80002712:	d5a50513          	addi	a0,a0,-678 # 80008468 <etext+0x468>
    80002716:	de5fd0ef          	jal	800004fa <printf>
    setkilled(p);
    8000271a:	8526                	mv	a0,s1
    8000271c:	a8fff0ef          	jal	800021aa <setkilled>
    80002720:	bf61                	j	800026b8 <usertrap+0xa4>
    case 2:  return "Illegal instruction";
    80002722:	00006597          	auipc	a1,0x6
    80002726:	bc658593          	addi	a1,a1,-1082 # 800082e8 <etext+0x2e8>
    8000272a:	bfe9                	j	80002704 <usertrap+0xf0>
    case 3:  return "Breakpoint";
    8000272c:	00006597          	auipc	a1,0x6
    80002730:	bd458593          	addi	a1,a1,-1068 # 80008300 <etext+0x300>
    80002734:	bfc1                	j	80002704 <usertrap+0xf0>
    case 4:  return "Load address misaligned";
    80002736:	00006597          	auipc	a1,0x6
    8000273a:	bda58593          	addi	a1,a1,-1062 # 80008310 <etext+0x310>
    8000273e:	b7d9                	j	80002704 <usertrap+0xf0>
    case 5:  return "Load access fault";
    80002740:	00006597          	auipc	a1,0x6
    80002744:	be858593          	addi	a1,a1,-1048 # 80008328 <etext+0x328>
    80002748:	bf75                	j	80002704 <usertrap+0xf0>
    case 6:  return "Store/AMO address misaligned";
    8000274a:	00006597          	auipc	a1,0x6
    8000274e:	bf658593          	addi	a1,a1,-1034 # 80008340 <etext+0x340>
    80002752:	bf4d                	j	80002704 <usertrap+0xf0>
    case 7:  return "Store/AMO access fault";
    80002754:	00006597          	auipc	a1,0x6
    80002758:	c0c58593          	addi	a1,a1,-1012 # 80008360 <etext+0x360>
    8000275c:	b765                	j	80002704 <usertrap+0xf0>
    case 8:  return "Environment call (syscall)";
    8000275e:	00006597          	auipc	a1,0x6
    80002762:	c1a58593          	addi	a1,a1,-998 # 80008378 <etext+0x378>
    80002766:	bf79                	j	80002704 <usertrap+0xf0>
    case 9:  return "Supervisor software interrupt";
    80002768:	00006597          	auipc	a1,0x6
    8000276c:	c3058593          	addi	a1,a1,-976 # 80008398 <etext+0x398>
    80002770:	bf51                	j	80002704 <usertrap+0xf0>
    case 10: return "Reserved";
    80002772:	00006597          	auipc	a1,0x6
    80002776:	c4658593          	addi	a1,a1,-954 # 800083b8 <etext+0x3b8>
    8000277a:	b769                	j	80002704 <usertrap+0xf0>
    case 11: return "Machine software interrupt";
    8000277c:	00006597          	auipc	a1,0x6
    80002780:	c4c58593          	addi	a1,a1,-948 # 800083c8 <etext+0x3c8>
    80002784:	b741                	j	80002704 <usertrap+0xf0>
    case 12: return "Supervisor timer interrupt";
    80002786:	00006597          	auipc	a1,0x6
    8000278a:	c6258593          	addi	a1,a1,-926 # 800083e8 <etext+0x3e8>
    8000278e:	bf9d                	j	80002704 <usertrap+0xf0>
    case 13: return "Reserved";
    80002790:	00006597          	auipc	a1,0x6
    80002794:	c2858593          	addi	a1,a1,-984 # 800083b8 <etext+0x3b8>
    80002798:	b7b5                	j	80002704 <usertrap+0xf0>
    case 14: return "Machine timer interrupt";
    8000279a:	00006597          	auipc	a1,0x6
    8000279e:	c6e58593          	addi	a1,a1,-914 # 80008408 <etext+0x408>
    800027a2:	b78d                	j	80002704 <usertrap+0xf0>
    case 15: return "Supervisor external interrupt";
    800027a4:	00006597          	auipc	a1,0x6
    800027a8:	c7c58593          	addi	a1,a1,-900 # 80008420 <etext+0x420>
    800027ac:	bfa1                	j	80002704 <usertrap+0xf0>
    default: return "Unknown";
    800027ae:	00006597          	auipc	a1,0x6
    800027b2:	c9258593          	addi	a1,a1,-878 # 80008440 <etext+0x440>
    800027b6:	b7b9                	j	80002704 <usertrap+0xf0>
  switch(scause) {
    800027b8:	00006597          	auipc	a1,0x6
    800027bc:	b1058593          	addi	a1,a1,-1264 # 800082c8 <etext+0x2c8>
    800027c0:	b791                	j	80002704 <usertrap+0xf0>
  if(killed(p))
    800027c2:	8526                	mv	a0,s1
    800027c4:	a0bff0ef          	jal	800021ce <killed>
    800027c8:	c511                	beqz	a0,800027d4 <usertrap+0x1c0>
    800027ca:	a011                	j	800027ce <usertrap+0x1ba>
    800027cc:	4901                	li	s2,0
    kexit(-1);
    800027ce:	557d                	li	a0,-1
    800027d0:	8cfff0ef          	jal	8000209e <kexit>
  if(which_dev == 2)
    800027d4:	4789                	li	a5,2
    800027d6:	eef916e3          	bne	s2,a5,800026c2 <usertrap+0xae>
    yield();
    800027da:	f8cff0ef          	jal	80001f66 <yield>
    800027de:	b5d5                	j	800026c2 <usertrap+0xae>

00000000800027e0 <kerneltrap>:
{
    800027e0:	7179                	addi	sp,sp,-48
    800027e2:	f406                	sd	ra,40(sp)
    800027e4:	f022                	sd	s0,32(sp)
    800027e6:	ec26                	sd	s1,24(sp)
    800027e8:	e84a                	sd	s2,16(sp)
    800027ea:	e44e                	sd	s3,8(sp)
    800027ec:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800027ee:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027f2:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027f6:	142027f3          	csrr	a5,scause
    800027fa:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    800027fc:	1004f793          	andi	a5,s1,256
    80002800:	c795                	beqz	a5,8000282c <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002802:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002806:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002808:	eb85                	bnez	a5,80002838 <kerneltrap+0x58>
  if((which_dev = devintr()) == 0){
    8000280a:	d95ff0ef          	jal	8000259e <devintr>
    8000280e:	c91d                	beqz	a0,80002844 <kerneltrap+0x64>
  if(which_dev == 2 && myproc() != 0)
    80002810:	4789                	li	a5,2
    80002812:	04f50a63          	beq	a0,a5,80002866 <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002816:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000281a:	10049073          	csrw	sstatus,s1
}
    8000281e:	70a2                	ld	ra,40(sp)
    80002820:	7402                	ld	s0,32(sp)
    80002822:	64e2                	ld	s1,24(sp)
    80002824:	6942                	ld	s2,16(sp)
    80002826:	69a2                	ld	s3,8(sp)
    80002828:	6145                	addi	sp,sp,48
    8000282a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000282c:	00006517          	auipc	a0,0x6
    80002830:	c7450513          	addi	a0,a0,-908 # 800084a0 <etext+0x4a0>
    80002834:	ff1fd0ef          	jal	80000824 <panic>
    panic("kerneltrap: interrupts enabled");
    80002838:	00006517          	auipc	a0,0x6
    8000283c:	c9050513          	addi	a0,a0,-880 # 800084c8 <etext+0x4c8>
    80002840:	fe5fd0ef          	jal	80000824 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002844:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002848:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    8000284c:	85ce                	mv	a1,s3
    8000284e:	00006517          	auipc	a0,0x6
    80002852:	c9a50513          	addi	a0,a0,-870 # 800084e8 <etext+0x4e8>
    80002856:	ca5fd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    8000285a:	00006517          	auipc	a0,0x6
    8000285e:	cb650513          	addi	a0,a0,-842 # 80008510 <etext+0x510>
    80002862:	fc3fd0ef          	jal	80000824 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002866:	8d0ff0ef          	jal	80001936 <myproc>
    8000286a:	d555                	beqz	a0,80002816 <kerneltrap+0x36>
    yield();
    8000286c:	efaff0ef          	jal	80001f66 <yield>
    80002870:	b75d                	j	80002816 <kerneltrap+0x36>

0000000080002872 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002872:	1101                	addi	sp,sp,-32
    80002874:	ec06                	sd	ra,24(sp)
    80002876:	e822                	sd	s0,16(sp)
    80002878:	e426                	sd	s1,8(sp)
    8000287a:	1000                	addi	s0,sp,32
    8000287c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000287e:	8b8ff0ef          	jal	80001936 <myproc>
  switch (n) {
    80002882:	4795                	li	a5,5
    80002884:	0497e163          	bltu	a5,s1,800028c6 <argraw+0x54>
    80002888:	048a                	slli	s1,s1,0x2
    8000288a:	00006717          	auipc	a4,0x6
    8000288e:	42e70713          	addi	a4,a4,1070 # 80008cb8 <states.0+0x70>
    80002892:	94ba                	add	s1,s1,a4
    80002894:	409c                	lw	a5,0(s1)
    80002896:	97ba                	add	a5,a5,a4
    80002898:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000289a:	6d3c                	ld	a5,88(a0)
    8000289c:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000289e:	60e2                	ld	ra,24(sp)
    800028a0:	6442                	ld	s0,16(sp)
    800028a2:	64a2                	ld	s1,8(sp)
    800028a4:	6105                	addi	sp,sp,32
    800028a6:	8082                	ret
    return p->trapframe->a1;
    800028a8:	6d3c                	ld	a5,88(a0)
    800028aa:	7fa8                	ld	a0,120(a5)
    800028ac:	bfcd                	j	8000289e <argraw+0x2c>
    return p->trapframe->a2;
    800028ae:	6d3c                	ld	a5,88(a0)
    800028b0:	63c8                	ld	a0,128(a5)
    800028b2:	b7f5                	j	8000289e <argraw+0x2c>
    return p->trapframe->a3;
    800028b4:	6d3c                	ld	a5,88(a0)
    800028b6:	67c8                	ld	a0,136(a5)
    800028b8:	b7dd                	j	8000289e <argraw+0x2c>
    return p->trapframe->a4;
    800028ba:	6d3c                	ld	a5,88(a0)
    800028bc:	6bc8                	ld	a0,144(a5)
    800028be:	b7c5                	j	8000289e <argraw+0x2c>
    return p->trapframe->a5;
    800028c0:	6d3c                	ld	a5,88(a0)
    800028c2:	6fc8                	ld	a0,152(a5)
    800028c4:	bfe9                	j	8000289e <argraw+0x2c>
  panic("argraw");
    800028c6:	00006517          	auipc	a0,0x6
    800028ca:	c5a50513          	addi	a0,a0,-934 # 80008520 <etext+0x520>
    800028ce:	f57fd0ef          	jal	80000824 <panic>

00000000800028d2 <fetchaddr>:
{
    800028d2:	1101                	addi	sp,sp,-32
    800028d4:	ec06                	sd	ra,24(sp)
    800028d6:	e822                	sd	s0,16(sp)
    800028d8:	e426                	sd	s1,8(sp)
    800028da:	e04a                	sd	s2,0(sp)
    800028dc:	1000                	addi	s0,sp,32
    800028de:	84aa                	mv	s1,a0
    800028e0:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800028e2:	854ff0ef          	jal	80001936 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800028e6:	653c                	ld	a5,72(a0)
    800028e8:	02f4f663          	bgeu	s1,a5,80002914 <fetchaddr+0x42>
    800028ec:	00848713          	addi	a4,s1,8
    800028f0:	02e7e463          	bltu	a5,a4,80002918 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800028f4:	46a1                	li	a3,8
    800028f6:	8626                	mv	a2,s1
    800028f8:	85ca                	mv	a1,s2
    800028fa:	6928                	ld	a0,80(a0)
    800028fc:	e1ffe0ef          	jal	8000171a <copyin>
    80002900:	00a03533          	snez	a0,a0
    80002904:	40a0053b          	negw	a0,a0
}
    80002908:	60e2                	ld	ra,24(sp)
    8000290a:	6442                	ld	s0,16(sp)
    8000290c:	64a2                	ld	s1,8(sp)
    8000290e:	6902                	ld	s2,0(sp)
    80002910:	6105                	addi	sp,sp,32
    80002912:	8082                	ret
    return -1;
    80002914:	557d                	li	a0,-1
    80002916:	bfcd                	j	80002908 <fetchaddr+0x36>
    80002918:	557d                	li	a0,-1
    8000291a:	b7fd                	j	80002908 <fetchaddr+0x36>

000000008000291c <fetchstr>:
{
    8000291c:	7179                	addi	sp,sp,-48
    8000291e:	f406                	sd	ra,40(sp)
    80002920:	f022                	sd	s0,32(sp)
    80002922:	ec26                	sd	s1,24(sp)
    80002924:	e84a                	sd	s2,16(sp)
    80002926:	e44e                	sd	s3,8(sp)
    80002928:	1800                	addi	s0,sp,48
    8000292a:	89aa                	mv	s3,a0
    8000292c:	84ae                	mv	s1,a1
    8000292e:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002930:	806ff0ef          	jal	80001936 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002934:	86ca                	mv	a3,s2
    80002936:	864e                	mv	a2,s3
    80002938:	85a6                	mv	a1,s1
    8000293a:	6928                	ld	a0,80(a0)
    8000293c:	bc5fe0ef          	jal	80001500 <copyinstr>
    80002940:	00054c63          	bltz	a0,80002958 <fetchstr+0x3c>
  return strlen(buf);
    80002944:	8526                	mv	a0,s1
    80002946:	d3cfe0ef          	jal	80000e82 <strlen>
}
    8000294a:	70a2                	ld	ra,40(sp)
    8000294c:	7402                	ld	s0,32(sp)
    8000294e:	64e2                	ld	s1,24(sp)
    80002950:	6942                	ld	s2,16(sp)
    80002952:	69a2                	ld	s3,8(sp)
    80002954:	6145                	addi	sp,sp,48
    80002956:	8082                	ret
    return -1;
    80002958:	557d                	li	a0,-1
    8000295a:	bfc5                	j	8000294a <fetchstr+0x2e>

000000008000295c <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    8000295c:	1101                	addi	sp,sp,-32
    8000295e:	ec06                	sd	ra,24(sp)
    80002960:	e822                	sd	s0,16(sp)
    80002962:	e426                	sd	s1,8(sp)
    80002964:	1000                	addi	s0,sp,32
    80002966:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002968:	f0bff0ef          	jal	80002872 <argraw>
    8000296c:	c088                	sw	a0,0(s1)
  return 0;
}
    8000296e:	4501                	li	a0,0
    80002970:	60e2                	ld	ra,24(sp)
    80002972:	6442                	ld	s0,16(sp)
    80002974:	64a2                	ld	s1,8(sp)
    80002976:	6105                	addi	sp,sp,32
    80002978:	8082                	ret

000000008000297a <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    8000297a:	1101                	addi	sp,sp,-32
    8000297c:	ec06                	sd	ra,24(sp)
    8000297e:	e822                	sd	s0,16(sp)
    80002980:	e426                	sd	s1,8(sp)
    80002982:	1000                	addi	s0,sp,32
    80002984:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002986:	eedff0ef          	jal	80002872 <argraw>
    8000298a:	e088                	sd	a0,0(s1)
  return 0;
}
    8000298c:	4501                	li	a0,0
    8000298e:	60e2                	ld	ra,24(sp)
    80002990:	6442                	ld	s0,16(sp)
    80002992:	64a2                	ld	s1,8(sp)
    80002994:	6105                	addi	sp,sp,32
    80002996:	8082                	ret

0000000080002998 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002998:	1101                	addi	sp,sp,-32
    8000299a:	ec06                	sd	ra,24(sp)
    8000299c:	e822                	sd	s0,16(sp)
    8000299e:	e426                	sd	s1,8(sp)
    800029a0:	e04a                	sd	s2,0(sp)
    800029a2:	1000                	addi	s0,sp,32
    800029a4:	892e                	mv	s2,a1
    800029a6:	84b2                	mv	s1,a2
  *ip = argraw(n);
    800029a8:	ecbff0ef          	jal	80002872 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    800029ac:	8626                	mv	a2,s1
    800029ae:	85ca                	mv	a1,s2
    800029b0:	f6dff0ef          	jal	8000291c <fetchstr>
}
    800029b4:	60e2                	ld	ra,24(sp)
    800029b6:	6442                	ld	s0,16(sp)
    800029b8:	64a2                	ld	s1,8(sp)
    800029ba:	6902                	ld	s2,0(sp)
    800029bc:	6105                	addi	sp,sp,32
    800029be:	8082                	ret

00000000800029c0 <syscall>:
[SYS_audit_read] sys_audit_read,
};

void
syscall(void)
{
    800029c0:	1101                	addi	sp,sp,-32
    800029c2:	ec06                	sd	ra,24(sp)
    800029c4:	e822                	sd	s0,16(sp)
    800029c6:	e426                	sd	s1,8(sp)
    800029c8:	e04a                	sd	s2,0(sp)
    800029ca:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800029cc:	f6bfe0ef          	jal	80001936 <myproc>
    800029d0:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800029d2:	05853903          	ld	s2,88(a0)
    800029d6:	0a893783          	ld	a5,168(s2)
    800029da:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800029de:	37fd                	addiw	a5,a5,-1
    800029e0:	4771                	li	a4,28
    800029e2:	00f76f63          	bltu	a4,a5,80002a00 <syscall+0x40>
    800029e6:	00369713          	slli	a4,a3,0x3
    800029ea:	00006797          	auipc	a5,0x6
    800029ee:	2e678793          	addi	a5,a5,742 # 80008cd0 <syscalls>
    800029f2:	97ba                	add	a5,a5,a4
    800029f4:	639c                	ld	a5,0(a5)
    800029f6:	c789                	beqz	a5,80002a00 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800029f8:	9782                	jalr	a5
    800029fa:	06a93823          	sd	a0,112(s2)
    800029fe:	a829                	j	80002a18 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002a00:	15848613          	addi	a2,s1,344
    80002a04:	588c                	lw	a1,48(s1)
    80002a06:	00006517          	auipc	a0,0x6
    80002a0a:	b2250513          	addi	a0,a0,-1246 # 80008528 <etext+0x528>
    80002a0e:	aedfd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002a12:	6cbc                	ld	a5,88(s1)
    80002a14:	577d                	li	a4,-1
    80002a16:	fbb8                	sd	a4,112(a5)
  }
}
    80002a18:	60e2                	ld	ra,24(sp)
    80002a1a:	6442                	ld	s0,16(sp)
    80002a1c:	64a2                	ld	s1,8(sp)
    80002a1e:	6902                	ld	s2,0(sp)
    80002a20:	6105                	addi	sp,sp,32
    80002a22:	8082                	ret

0000000080002a24 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002a24:	1101                	addi	sp,sp,-32
    80002a26:	ec06                	sd	ra,24(sp)
    80002a28:	e822                	sd	s0,16(sp)
    80002a2a:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002a2c:	fec40593          	addi	a1,s0,-20
    80002a30:	4501                	li	a0,0
    80002a32:	f2bff0ef          	jal	8000295c <argint>
  kexit(n);
    80002a36:	fec42503          	lw	a0,-20(s0)
    80002a3a:	e64ff0ef          	jal	8000209e <kexit>
  return 0;  // not reached
}
    80002a3e:	4501                	li	a0,0
    80002a40:	60e2                	ld	ra,24(sp)
    80002a42:	6442                	ld	s0,16(sp)
    80002a44:	6105                	addi	sp,sp,32
    80002a46:	8082                	ret

0000000080002a48 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002a48:	1141                	addi	sp,sp,-16
    80002a4a:	e406                	sd	ra,8(sp)
    80002a4c:	e022                	sd	s0,0(sp)
    80002a4e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002a50:	ee7fe0ef          	jal	80001936 <myproc>
}
    80002a54:	5908                	lw	a0,48(a0)
    80002a56:	60a2                	ld	ra,8(sp)
    80002a58:	6402                	ld	s0,0(sp)
    80002a5a:	0141                	addi	sp,sp,16
    80002a5c:	8082                	ret

0000000080002a5e <sys_fork>:

uint64
sys_fork(void)
{
    80002a5e:	1141                	addi	sp,sp,-16
    80002a60:	e406                	sd	ra,8(sp)
    80002a62:	e022                	sd	s0,0(sp)
    80002a64:	0800                	addi	s0,sp,16
  return kfork();
    80002a66:	a38ff0ef          	jal	80001c9e <kfork>
}
    80002a6a:	60a2                	ld	ra,8(sp)
    80002a6c:	6402                	ld	s0,0(sp)
    80002a6e:	0141                	addi	sp,sp,16
    80002a70:	8082                	ret

0000000080002a72 <sys_wait>:

uint64
sys_wait(void)
{
    80002a72:	1101                	addi	sp,sp,-32
    80002a74:	ec06                	sd	ra,24(sp)
    80002a76:	e822                	sd	s0,16(sp)
    80002a78:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002a7a:	fe840593          	addi	a1,s0,-24
    80002a7e:	4501                	li	a0,0
    80002a80:	efbff0ef          	jal	8000297a <argaddr>
  return kwait(p);
    80002a84:	fe843503          	ld	a0,-24(s0)
    80002a88:	f70ff0ef          	jal	800021f8 <kwait>
}
    80002a8c:	60e2                	ld	ra,24(sp)
    80002a8e:	6442                	ld	s0,16(sp)
    80002a90:	6105                	addi	sp,sp,32
    80002a92:	8082                	ret

0000000080002a94 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002a94:	7179                	addi	sp,sp,-48
    80002a96:	f406                	sd	ra,40(sp)
    80002a98:	f022                	sd	s0,32(sp)
    80002a9a:	ec26                	sd	s1,24(sp)
    80002a9c:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002a9e:	fd840593          	addi	a1,s0,-40
    80002aa2:	4501                	li	a0,0
    80002aa4:	eb9ff0ef          	jal	8000295c <argint>
  argint(1, &t);
    80002aa8:	fdc40593          	addi	a1,s0,-36
    80002aac:	4505                	li	a0,1
    80002aae:	eafff0ef          	jal	8000295c <argint>
  addr = myproc()->sz;
    80002ab2:	e85fe0ef          	jal	80001936 <myproc>
    80002ab6:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002ab8:	fdc42703          	lw	a4,-36(s0)
    80002abc:	4785                	li	a5,1
    80002abe:	02f70763          	beq	a4,a5,80002aec <sys_sbrk+0x58>
    80002ac2:	fd842783          	lw	a5,-40(s0)
    80002ac6:	0207c363          	bltz	a5,80002aec <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002aca:	97a6                	add	a5,a5,s1
      return -1;
    if(addr + n > TRAPFRAME)
    80002acc:	02000737          	lui	a4,0x2000
    80002ad0:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002ad2:	0736                	slli	a4,a4,0xd
    80002ad4:	02f76a63          	bltu	a4,a5,80002b08 <sys_sbrk+0x74>
    80002ad8:	0297e863          	bltu	a5,s1,80002b08 <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002adc:	e5bfe0ef          	jal	80001936 <myproc>
    80002ae0:	fd842703          	lw	a4,-40(s0)
    80002ae4:	653c                	ld	a5,72(a0)
    80002ae6:	97ba                	add	a5,a5,a4
    80002ae8:	e53c                	sd	a5,72(a0)
    80002aea:	a039                	j	80002af8 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002aec:	fd842503          	lw	a0,-40(s0)
    80002af0:	94cff0ef          	jal	80001c3c <growproc>
    80002af4:	00054863          	bltz	a0,80002b04 <sys_sbrk+0x70>
  }
  return addr;
}
    80002af8:	8526                	mv	a0,s1
    80002afa:	70a2                	ld	ra,40(sp)
    80002afc:	7402                	ld	s0,32(sp)
    80002afe:	64e2                	ld	s1,24(sp)
    80002b00:	6145                	addi	sp,sp,48
    80002b02:	8082                	ret
      return -1;
    80002b04:	54fd                	li	s1,-1
    80002b06:	bfcd                	j	80002af8 <sys_sbrk+0x64>
      return -1;
    80002b08:	54fd                	li	s1,-1
    80002b0a:	b7fd                	j	80002af8 <sys_sbrk+0x64>

0000000080002b0c <sys_pause>:

uint64
sys_pause(void)
{
    80002b0c:	7139                	addi	sp,sp,-64
    80002b0e:	fc06                	sd	ra,56(sp)
    80002b10:	f822                	sd	s0,48(sp)
    80002b12:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002b14:	fcc40593          	addi	a1,s0,-52
    80002b18:	4501                	li	a0,0
    80002b1a:	e43ff0ef          	jal	8000295c <argint>
  if(n < 0)
    80002b1e:	fcc42783          	lw	a5,-52(s0)
    80002b22:	0607c863          	bltz	a5,80002b92 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002b26:	00015517          	auipc	a0,0x15
    80002b2a:	0f250513          	addi	a0,a0,242 # 80017c18 <tickslock>
    80002b2e:	8fafe0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    80002b32:	fcc42783          	lw	a5,-52(s0)
    80002b36:	c3b9                	beqz	a5,80002b7c <sys_pause+0x70>
    80002b38:	f426                	sd	s1,40(sp)
    80002b3a:	f04a                	sd	s2,32(sp)
    80002b3c:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002b3e:	00006997          	auipc	s3,0x6
    80002b42:	3aa9a983          	lw	s3,938(s3) # 80008ee8 <ticks>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002b46:	00015917          	auipc	s2,0x15
    80002b4a:	0d290913          	addi	s2,s2,210 # 80017c18 <tickslock>
    80002b4e:	00006497          	auipc	s1,0x6
    80002b52:	39a48493          	addi	s1,s1,922 # 80008ee8 <ticks>
    if(killed(myproc())){
    80002b56:	de1fe0ef          	jal	80001936 <myproc>
    80002b5a:	e74ff0ef          	jal	800021ce <killed>
    80002b5e:	ed0d                	bnez	a0,80002b98 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002b60:	85ca                	mv	a1,s2
    80002b62:	8526                	mv	a0,s1
    80002b64:	c2eff0ef          	jal	80001f92 <sleep>
  while(ticks - ticks0 < n){
    80002b68:	409c                	lw	a5,0(s1)
    80002b6a:	413787bb          	subw	a5,a5,s3
    80002b6e:	fcc42703          	lw	a4,-52(s0)
    80002b72:	fee7e2e3          	bltu	a5,a4,80002b56 <sys_pause+0x4a>
    80002b76:	74a2                	ld	s1,40(sp)
    80002b78:	7902                	ld	s2,32(sp)
    80002b7a:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002b7c:	00015517          	auipc	a0,0x15
    80002b80:	09c50513          	addi	a0,a0,156 # 80017c18 <tickslock>
    80002b84:	938fe0ef          	jal	80000cbc <release>
  return 0;
    80002b88:	4501                	li	a0,0
}
    80002b8a:	70e2                	ld	ra,56(sp)
    80002b8c:	7442                	ld	s0,48(sp)
    80002b8e:	6121                	addi	sp,sp,64
    80002b90:	8082                	ret
    n = 0;
    80002b92:	fc042623          	sw	zero,-52(s0)
    80002b96:	bf41                	j	80002b26 <sys_pause+0x1a>
      release(&tickslock);
    80002b98:	00015517          	auipc	a0,0x15
    80002b9c:	08050513          	addi	a0,a0,128 # 80017c18 <tickslock>
    80002ba0:	91cfe0ef          	jal	80000cbc <release>
      return -1;
    80002ba4:	557d                	li	a0,-1
    80002ba6:	74a2                	ld	s1,40(sp)
    80002ba8:	7902                	ld	s2,32(sp)
    80002baa:	69e2                	ld	s3,24(sp)
    80002bac:	bff9                	j	80002b8a <sys_pause+0x7e>

0000000080002bae <sys_kill>:

uint64
sys_kill(void)
{
    80002bae:	1101                	addi	sp,sp,-32
    80002bb0:	ec06                	sd	ra,24(sp)
    80002bb2:	e822                	sd	s0,16(sp)
    80002bb4:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002bb6:	fec40593          	addi	a1,s0,-20
    80002bba:	4501                	li	a0,0
    80002bbc:	da1ff0ef          	jal	8000295c <argint>
  return kkill(pid);
    80002bc0:	fec42503          	lw	a0,-20(s0)
    80002bc4:	d80ff0ef          	jal	80002144 <kkill>
}
    80002bc8:	60e2                	ld	ra,24(sp)
    80002bca:	6442                	ld	s0,16(sp)
    80002bcc:	6105                	addi	sp,sp,32
    80002bce:	8082                	ret

0000000080002bd0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002bd0:	1101                	addi	sp,sp,-32
    80002bd2:	ec06                	sd	ra,24(sp)
    80002bd4:	e822                	sd	s0,16(sp)
    80002bd6:	e426                	sd	s1,8(sp)
    80002bd8:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002bda:	00015517          	auipc	a0,0x15
    80002bde:	03e50513          	addi	a0,a0,62 # 80017c18 <tickslock>
    80002be2:	846fe0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002be6:	00006797          	auipc	a5,0x6
    80002bea:	3027a783          	lw	a5,770(a5) # 80008ee8 <ticks>
    80002bee:	84be                	mv	s1,a5
  release(&tickslock);
    80002bf0:	00015517          	auipc	a0,0x15
    80002bf4:	02850513          	addi	a0,a0,40 # 80017c18 <tickslock>
    80002bf8:	8c4fe0ef          	jal	80000cbc <release>
  return xticks;
}
    80002bfc:	02049513          	slli	a0,s1,0x20
    80002c00:	9101                	srli	a0,a0,0x20
    80002c02:	60e2                	ld	ra,24(sp)
    80002c04:	6442                	ld	s0,16(sp)
    80002c06:	64a2                	ld	s1,8(sp)
    80002c08:	6105                	addi	sp,sp,32
    80002c0a:	8082                	ret

0000000080002c0c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002c0c:	7179                	addi	sp,sp,-48
    80002c0e:	f406                	sd	ra,40(sp)
    80002c10:	f022                	sd	s0,32(sp)
    80002c12:	ec26                	sd	s1,24(sp)
    80002c14:	e84a                	sd	s2,16(sp)
    80002c16:	e44e                	sd	s3,8(sp)
    80002c18:	e052                	sd	s4,0(sp)
    80002c1a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002c1c:	00006597          	auipc	a1,0x6
    80002c20:	92c58593          	addi	a1,a1,-1748 # 80008548 <etext+0x548>
    80002c24:	00015517          	auipc	a0,0x15
    80002c28:	00c50513          	addi	a0,a0,12 # 80017c30 <bcache>
    80002c2c:	f73fd0ef          	jal	80000b9e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002c30:	0001d797          	auipc	a5,0x1d
    80002c34:	00078793          	mv	a5,a5
    80002c38:	0001d717          	auipc	a4,0x1d
    80002c3c:	26070713          	addi	a4,a4,608 # 8001fe98 <bcache+0x8268>
    80002c40:	2ae7b823          	sd	a4,688(a5) # 8001fee0 <bcache+0x82b0>
  bcache.head.next = &bcache.head;
    80002c44:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002c48:	00015497          	auipc	s1,0x15
    80002c4c:	00048493          	mv	s1,s1
    b->next = bcache.head.next;
    80002c50:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002c52:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002c54:	00006a17          	auipc	s4,0x6
    80002c58:	8fca0a13          	addi	s4,s4,-1796 # 80008550 <etext+0x550>
    b->next = bcache.head.next;
    80002c5c:	2b893783          	ld	a5,696(s2)
    80002c60:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002c62:	0534b423          	sd	s3,72(s1) # 80017c90 <bcache+0x60>
    initsleeplock(&b->lock, "buffer");
    80002c66:	85d2                	mv	a1,s4
    80002c68:	01048513          	addi	a0,s1,16
    80002c6c:	394010ef          	jal	80004000 <initsleeplock>
    bcache.head.next->prev = b;
    80002c70:	2b893783          	ld	a5,696(s2)
    80002c74:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002c76:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002c7a:	45848493          	addi	s1,s1,1112
    80002c7e:	fd349fe3          	bne	s1,s3,80002c5c <binit+0x50>
  }
}
    80002c82:	70a2                	ld	ra,40(sp)
    80002c84:	7402                	ld	s0,32(sp)
    80002c86:	64e2                	ld	s1,24(sp)
    80002c88:	6942                	ld	s2,16(sp)
    80002c8a:	69a2                	ld	s3,8(sp)
    80002c8c:	6a02                	ld	s4,0(sp)
    80002c8e:	6145                	addi	sp,sp,48
    80002c90:	8082                	ret

0000000080002c92 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002c92:	7179                	addi	sp,sp,-48
    80002c94:	f406                	sd	ra,40(sp)
    80002c96:	f022                	sd	s0,32(sp)
    80002c98:	ec26                	sd	s1,24(sp)
    80002c9a:	e84a                	sd	s2,16(sp)
    80002c9c:	e44e                	sd	s3,8(sp)
    80002c9e:	1800                	addi	s0,sp,48
    80002ca0:	892a                	mv	s2,a0
    80002ca2:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002ca4:	00015517          	auipc	a0,0x15
    80002ca8:	f8c50513          	addi	a0,a0,-116 # 80017c30 <bcache>
    80002cac:	f7dfd0ef          	jal	80000c28 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002cb0:	0001d497          	auipc	s1,0x1d
    80002cb4:	2384b483          	ld	s1,568(s1) # 8001fee8 <bcache+0x82b8>
    80002cb8:	0001d797          	auipc	a5,0x1d
    80002cbc:	1e078793          	addi	a5,a5,480 # 8001fe98 <bcache+0x8268>
    80002cc0:	02f48b63          	beq	s1,a5,80002cf6 <bread+0x64>
    80002cc4:	873e                	mv	a4,a5
    80002cc6:	a021                	j	80002cce <bread+0x3c>
    80002cc8:	68a4                	ld	s1,80(s1)
    80002cca:	02e48663          	beq	s1,a4,80002cf6 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002cce:	449c                	lw	a5,8(s1)
    80002cd0:	ff279ce3          	bne	a5,s2,80002cc8 <bread+0x36>
    80002cd4:	44dc                	lw	a5,12(s1)
    80002cd6:	ff3799e3          	bne	a5,s3,80002cc8 <bread+0x36>
      b->refcnt++;
    80002cda:	40bc                	lw	a5,64(s1)
    80002cdc:	2785                	addiw	a5,a5,1
    80002cde:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ce0:	00015517          	auipc	a0,0x15
    80002ce4:	f5050513          	addi	a0,a0,-176 # 80017c30 <bcache>
    80002ce8:	fd5fd0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    80002cec:	01048513          	addi	a0,s1,16
    80002cf0:	346010ef          	jal	80004036 <acquiresleep>
      return b;
    80002cf4:	a889                	j	80002d46 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002cf6:	0001d497          	auipc	s1,0x1d
    80002cfa:	1ea4b483          	ld	s1,490(s1) # 8001fee0 <bcache+0x82b0>
    80002cfe:	0001d797          	auipc	a5,0x1d
    80002d02:	19a78793          	addi	a5,a5,410 # 8001fe98 <bcache+0x8268>
    80002d06:	00f48863          	beq	s1,a5,80002d16 <bread+0x84>
    80002d0a:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002d0c:	40bc                	lw	a5,64(s1)
    80002d0e:	cb91                	beqz	a5,80002d22 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002d10:	64a4                	ld	s1,72(s1)
    80002d12:	fee49de3          	bne	s1,a4,80002d0c <bread+0x7a>
  panic("bget: no buffers");
    80002d16:	00006517          	auipc	a0,0x6
    80002d1a:	84250513          	addi	a0,a0,-1982 # 80008558 <etext+0x558>
    80002d1e:	b07fd0ef          	jal	80000824 <panic>
      b->dev = dev;
    80002d22:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002d26:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002d2a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002d2e:	4785                	li	a5,1
    80002d30:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d32:	00015517          	auipc	a0,0x15
    80002d36:	efe50513          	addi	a0,a0,-258 # 80017c30 <bcache>
    80002d3a:	f83fd0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    80002d3e:	01048513          	addi	a0,s1,16
    80002d42:	2f4010ef          	jal	80004036 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002d46:	409c                	lw	a5,0(s1)
    80002d48:	cb89                	beqz	a5,80002d5a <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002d4a:	8526                	mv	a0,s1
    80002d4c:	70a2                	ld	ra,40(sp)
    80002d4e:	7402                	ld	s0,32(sp)
    80002d50:	64e2                	ld	s1,24(sp)
    80002d52:	6942                	ld	s2,16(sp)
    80002d54:	69a2                	ld	s3,8(sp)
    80002d56:	6145                	addi	sp,sp,48
    80002d58:	8082                	ret
    virtio_disk_rw(b, 0);
    80002d5a:	4581                	li	a1,0
    80002d5c:	8526                	mv	a0,s1
    80002d5e:	653020ef          	jal	80005bb0 <virtio_disk_rw>
    b->valid = 1;
    80002d62:	4785                	li	a5,1
    80002d64:	c09c                	sw	a5,0(s1)
  return b;
    80002d66:	b7d5                	j	80002d4a <bread+0xb8>

0000000080002d68 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002d68:	1101                	addi	sp,sp,-32
    80002d6a:	ec06                	sd	ra,24(sp)
    80002d6c:	e822                	sd	s0,16(sp)
    80002d6e:	e426                	sd	s1,8(sp)
    80002d70:	1000                	addi	s0,sp,32
    80002d72:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002d74:	0541                	addi	a0,a0,16
    80002d76:	33e010ef          	jal	800040b4 <holdingsleep>
    80002d7a:	c911                	beqz	a0,80002d8e <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002d7c:	4585                	li	a1,1
    80002d7e:	8526                	mv	a0,s1
    80002d80:	631020ef          	jal	80005bb0 <virtio_disk_rw>
}
    80002d84:	60e2                	ld	ra,24(sp)
    80002d86:	6442                	ld	s0,16(sp)
    80002d88:	64a2                	ld	s1,8(sp)
    80002d8a:	6105                	addi	sp,sp,32
    80002d8c:	8082                	ret
    panic("bwrite");
    80002d8e:	00005517          	auipc	a0,0x5
    80002d92:	7e250513          	addi	a0,a0,2018 # 80008570 <etext+0x570>
    80002d96:	a8ffd0ef          	jal	80000824 <panic>

0000000080002d9a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002d9a:	1101                	addi	sp,sp,-32
    80002d9c:	ec06                	sd	ra,24(sp)
    80002d9e:	e822                	sd	s0,16(sp)
    80002da0:	e426                	sd	s1,8(sp)
    80002da2:	e04a                	sd	s2,0(sp)
    80002da4:	1000                	addi	s0,sp,32
    80002da6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002da8:	01050913          	addi	s2,a0,16
    80002dac:	854a                	mv	a0,s2
    80002dae:	306010ef          	jal	800040b4 <holdingsleep>
    80002db2:	c125                	beqz	a0,80002e12 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002db4:	854a                	mv	a0,s2
    80002db6:	2c6010ef          	jal	8000407c <releasesleep>

  acquire(&bcache.lock);
    80002dba:	00015517          	auipc	a0,0x15
    80002dbe:	e7650513          	addi	a0,a0,-394 # 80017c30 <bcache>
    80002dc2:	e67fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002dc6:	40bc                	lw	a5,64(s1)
    80002dc8:	37fd                	addiw	a5,a5,-1
    80002dca:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002dcc:	e79d                	bnez	a5,80002dfa <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002dce:	68b8                	ld	a4,80(s1)
    80002dd0:	64bc                	ld	a5,72(s1)
    80002dd2:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002dd4:	68b8                	ld	a4,80(s1)
    80002dd6:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002dd8:	0001d797          	auipc	a5,0x1d
    80002ddc:	e5878793          	addi	a5,a5,-424 # 8001fc30 <bcache+0x8000>
    80002de0:	2b87b703          	ld	a4,696(a5)
    80002de4:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002de6:	0001d717          	auipc	a4,0x1d
    80002dea:	0b270713          	addi	a4,a4,178 # 8001fe98 <bcache+0x8268>
    80002dee:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002df0:	2b87b703          	ld	a4,696(a5)
    80002df4:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002df6:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002dfa:	00015517          	auipc	a0,0x15
    80002dfe:	e3650513          	addi	a0,a0,-458 # 80017c30 <bcache>
    80002e02:	ebbfd0ef          	jal	80000cbc <release>
}
    80002e06:	60e2                	ld	ra,24(sp)
    80002e08:	6442                	ld	s0,16(sp)
    80002e0a:	64a2                	ld	s1,8(sp)
    80002e0c:	6902                	ld	s2,0(sp)
    80002e0e:	6105                	addi	sp,sp,32
    80002e10:	8082                	ret
    panic("brelse");
    80002e12:	00005517          	auipc	a0,0x5
    80002e16:	76650513          	addi	a0,a0,1894 # 80008578 <etext+0x578>
    80002e1a:	a0bfd0ef          	jal	80000824 <panic>

0000000080002e1e <bpin>:

void
bpin(struct buf *b) {
    80002e1e:	1101                	addi	sp,sp,-32
    80002e20:	ec06                	sd	ra,24(sp)
    80002e22:	e822                	sd	s0,16(sp)
    80002e24:	e426                	sd	s1,8(sp)
    80002e26:	1000                	addi	s0,sp,32
    80002e28:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002e2a:	00015517          	auipc	a0,0x15
    80002e2e:	e0650513          	addi	a0,a0,-506 # 80017c30 <bcache>
    80002e32:	df7fd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    80002e36:	40bc                	lw	a5,64(s1)
    80002e38:	2785                	addiw	a5,a5,1
    80002e3a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002e3c:	00015517          	auipc	a0,0x15
    80002e40:	df450513          	addi	a0,a0,-524 # 80017c30 <bcache>
    80002e44:	e79fd0ef          	jal	80000cbc <release>
}
    80002e48:	60e2                	ld	ra,24(sp)
    80002e4a:	6442                	ld	s0,16(sp)
    80002e4c:	64a2                	ld	s1,8(sp)
    80002e4e:	6105                	addi	sp,sp,32
    80002e50:	8082                	ret

0000000080002e52 <bunpin>:

void
bunpin(struct buf *b) {
    80002e52:	1101                	addi	sp,sp,-32
    80002e54:	ec06                	sd	ra,24(sp)
    80002e56:	e822                	sd	s0,16(sp)
    80002e58:	e426                	sd	s1,8(sp)
    80002e5a:	1000                	addi	s0,sp,32
    80002e5c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002e5e:	00015517          	auipc	a0,0x15
    80002e62:	dd250513          	addi	a0,a0,-558 # 80017c30 <bcache>
    80002e66:	dc3fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002e6a:	40bc                	lw	a5,64(s1)
    80002e6c:	37fd                	addiw	a5,a5,-1
    80002e6e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002e70:	00015517          	auipc	a0,0x15
    80002e74:	dc050513          	addi	a0,a0,-576 # 80017c30 <bcache>
    80002e78:	e45fd0ef          	jal	80000cbc <release>
}
    80002e7c:	60e2                	ld	ra,24(sp)
    80002e7e:	6442                	ld	s0,16(sp)
    80002e80:	64a2                	ld	s1,8(sp)
    80002e82:	6105                	addi	sp,sp,32
    80002e84:	8082                	ret

0000000080002e86 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002e86:	1101                	addi	sp,sp,-32
    80002e88:	ec06                	sd	ra,24(sp)
    80002e8a:	e822                	sd	s0,16(sp)
    80002e8c:	e426                	sd	s1,8(sp)
    80002e8e:	e04a                	sd	s2,0(sp)
    80002e90:	1000                	addi	s0,sp,32
    80002e92:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002e94:	00d5d79b          	srliw	a5,a1,0xd
    80002e98:	0001d597          	auipc	a1,0x1d
    80002e9c:	4745a583          	lw	a1,1140(a1) # 8002030c <sb+0x1c>
    80002ea0:	9dbd                	addw	a1,a1,a5
    80002ea2:	df1ff0ef          	jal	80002c92 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002ea6:	0074f713          	andi	a4,s1,7
    80002eaa:	4785                	li	a5,1
    80002eac:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002eb0:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    80002eb2:	90d9                	srli	s1,s1,0x36
    80002eb4:	00950733          	add	a4,a0,s1
    80002eb8:	05874703          	lbu	a4,88(a4)
    80002ebc:	00e7f6b3          	and	a3,a5,a4
    80002ec0:	c29d                	beqz	a3,80002ee6 <bfree+0x60>
    80002ec2:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002ec4:	94aa                	add	s1,s1,a0
    80002ec6:	fff7c793          	not	a5,a5
    80002eca:	8f7d                	and	a4,a4,a5
    80002ecc:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002ed0:	06c010ef          	jal	80003f3c <log_write>
  brelse(bp);
    80002ed4:	854a                	mv	a0,s2
    80002ed6:	ec5ff0ef          	jal	80002d9a <brelse>
}
    80002eda:	60e2                	ld	ra,24(sp)
    80002edc:	6442                	ld	s0,16(sp)
    80002ede:	64a2                	ld	s1,8(sp)
    80002ee0:	6902                	ld	s2,0(sp)
    80002ee2:	6105                	addi	sp,sp,32
    80002ee4:	8082                	ret
    panic("freeing free block");
    80002ee6:	00005517          	auipc	a0,0x5
    80002eea:	69a50513          	addi	a0,a0,1690 # 80008580 <etext+0x580>
    80002eee:	937fd0ef          	jal	80000824 <panic>

0000000080002ef2 <balloc>:
{
    80002ef2:	715d                	addi	sp,sp,-80
    80002ef4:	e486                	sd	ra,72(sp)
    80002ef6:	e0a2                	sd	s0,64(sp)
    80002ef8:	fc26                	sd	s1,56(sp)
    80002efa:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80002efc:	0001d797          	auipc	a5,0x1d
    80002f00:	3f87a783          	lw	a5,1016(a5) # 800202f4 <sb+0x4>
    80002f04:	0e078263          	beqz	a5,80002fe8 <balloc+0xf6>
    80002f08:	f84a                	sd	s2,48(sp)
    80002f0a:	f44e                	sd	s3,40(sp)
    80002f0c:	f052                	sd	s4,32(sp)
    80002f0e:	ec56                	sd	s5,24(sp)
    80002f10:	e85a                	sd	s6,16(sp)
    80002f12:	e45e                	sd	s7,8(sp)
    80002f14:	e062                	sd	s8,0(sp)
    80002f16:	8baa                	mv	s7,a0
    80002f18:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002f1a:	0001db17          	auipc	s6,0x1d
    80002f1e:	3d6b0b13          	addi	s6,s6,982 # 800202f0 <sb>
      m = 1 << (bi % 8);
    80002f22:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f24:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002f26:	6c09                	lui	s8,0x2
    80002f28:	a09d                	j	80002f8e <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002f2a:	97ca                	add	a5,a5,s2
    80002f2c:	8e55                	or	a2,a2,a3
    80002f2e:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002f32:	854a                	mv	a0,s2
    80002f34:	008010ef          	jal	80003f3c <log_write>
        brelse(bp);
    80002f38:	854a                	mv	a0,s2
    80002f3a:	e61ff0ef          	jal	80002d9a <brelse>
  bp = bread(dev, bno);
    80002f3e:	85a6                	mv	a1,s1
    80002f40:	855e                	mv	a0,s7
    80002f42:	d51ff0ef          	jal	80002c92 <bread>
    80002f46:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002f48:	40000613          	li	a2,1024
    80002f4c:	4581                	li	a1,0
    80002f4e:	05850513          	addi	a0,a0,88
    80002f52:	da7fd0ef          	jal	80000cf8 <memset>
  log_write(bp);
    80002f56:	854a                	mv	a0,s2
    80002f58:	7e5000ef          	jal	80003f3c <log_write>
  brelse(bp);
    80002f5c:	854a                	mv	a0,s2
    80002f5e:	e3dff0ef          	jal	80002d9a <brelse>
}
    80002f62:	7942                	ld	s2,48(sp)
    80002f64:	79a2                	ld	s3,40(sp)
    80002f66:	7a02                	ld	s4,32(sp)
    80002f68:	6ae2                	ld	s5,24(sp)
    80002f6a:	6b42                	ld	s6,16(sp)
    80002f6c:	6ba2                	ld	s7,8(sp)
    80002f6e:	6c02                	ld	s8,0(sp)
}
    80002f70:	8526                	mv	a0,s1
    80002f72:	60a6                	ld	ra,72(sp)
    80002f74:	6406                	ld	s0,64(sp)
    80002f76:	74e2                	ld	s1,56(sp)
    80002f78:	6161                	addi	sp,sp,80
    80002f7a:	8082                	ret
    brelse(bp);
    80002f7c:	854a                	mv	a0,s2
    80002f7e:	e1dff0ef          	jal	80002d9a <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002f82:	015c0abb          	addw	s5,s8,s5
    80002f86:	004b2783          	lw	a5,4(s6)
    80002f8a:	04faf863          	bgeu	s5,a5,80002fda <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80002f8e:	40dad59b          	sraiw	a1,s5,0xd
    80002f92:	01cb2783          	lw	a5,28(s6)
    80002f96:	9dbd                	addw	a1,a1,a5
    80002f98:	855e                	mv	a0,s7
    80002f9a:	cf9ff0ef          	jal	80002c92 <bread>
    80002f9e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002fa0:	004b2503          	lw	a0,4(s6)
    80002fa4:	84d6                	mv	s1,s5
    80002fa6:	4701                	li	a4,0
    80002fa8:	fca4fae3          	bgeu	s1,a0,80002f7c <balloc+0x8a>
      m = 1 << (bi % 8);
    80002fac:	00777693          	andi	a3,a4,7
    80002fb0:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002fb4:	41f7579b          	sraiw	a5,a4,0x1f
    80002fb8:	01d7d79b          	srliw	a5,a5,0x1d
    80002fbc:	9fb9                	addw	a5,a5,a4
    80002fbe:	4037d79b          	sraiw	a5,a5,0x3
    80002fc2:	00f90633          	add	a2,s2,a5
    80002fc6:	05864603          	lbu	a2,88(a2)
    80002fca:	00c6f5b3          	and	a1,a3,a2
    80002fce:	ddb1                	beqz	a1,80002f2a <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002fd0:	2705                	addiw	a4,a4,1
    80002fd2:	2485                	addiw	s1,s1,1
    80002fd4:	fd471ae3          	bne	a4,s4,80002fa8 <balloc+0xb6>
    80002fd8:	b755                	j	80002f7c <balloc+0x8a>
    80002fda:	7942                	ld	s2,48(sp)
    80002fdc:	79a2                	ld	s3,40(sp)
    80002fde:	7a02                	ld	s4,32(sp)
    80002fe0:	6ae2                	ld	s5,24(sp)
    80002fe2:	6b42                	ld	s6,16(sp)
    80002fe4:	6ba2                	ld	s7,8(sp)
    80002fe6:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    80002fe8:	00005517          	auipc	a0,0x5
    80002fec:	5b050513          	addi	a0,a0,1456 # 80008598 <etext+0x598>
    80002ff0:	d0afd0ef          	jal	800004fa <printf>
  return 0;
    80002ff4:	4481                	li	s1,0
    80002ff6:	bfad                	j	80002f70 <balloc+0x7e>

0000000080002ff8 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002ff8:	7179                	addi	sp,sp,-48
    80002ffa:	f406                	sd	ra,40(sp)
    80002ffc:	f022                	sd	s0,32(sp)
    80002ffe:	ec26                	sd	s1,24(sp)
    80003000:	e84a                	sd	s2,16(sp)
    80003002:	e44e                	sd	s3,8(sp)
    80003004:	1800                	addi	s0,sp,48
    80003006:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003008:	47ad                	li	a5,11
    8000300a:	02b7e363          	bltu	a5,a1,80003030 <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    8000300e:	02059793          	slli	a5,a1,0x20
    80003012:	01e7d593          	srli	a1,a5,0x1e
    80003016:	00b509b3          	add	s3,a0,a1
    8000301a:	0509a483          	lw	s1,80(s3)
    8000301e:	e0b5                	bnez	s1,80003082 <bmap+0x8a>
      addr = balloc(ip->dev);
    80003020:	4108                	lw	a0,0(a0)
    80003022:	ed1ff0ef          	jal	80002ef2 <balloc>
    80003026:	84aa                	mv	s1,a0
      if(addr == 0)
    80003028:	cd29                	beqz	a0,80003082 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    8000302a:	04a9a823          	sw	a0,80(s3)
    8000302e:	a891                	j	80003082 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003030:	ff45879b          	addiw	a5,a1,-12
    80003034:	873e                	mv	a4,a5
    80003036:	89be                	mv	s3,a5

  if(bn < NINDIRECT){
    80003038:	0ff00793          	li	a5,255
    8000303c:	06e7e763          	bltu	a5,a4,800030aa <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003040:	08052483          	lw	s1,128(a0)
    80003044:	e891                	bnez	s1,80003058 <bmap+0x60>
      addr = balloc(ip->dev);
    80003046:	4108                	lw	a0,0(a0)
    80003048:	eabff0ef          	jal	80002ef2 <balloc>
    8000304c:	84aa                	mv	s1,a0
      if(addr == 0)
    8000304e:	c915                	beqz	a0,80003082 <bmap+0x8a>
    80003050:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003052:	08a92023          	sw	a0,128(s2)
    80003056:	a011                	j	8000305a <bmap+0x62>
    80003058:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000305a:	85a6                	mv	a1,s1
    8000305c:	00092503          	lw	a0,0(s2)
    80003060:	c33ff0ef          	jal	80002c92 <bread>
    80003064:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003066:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000306a:	02099713          	slli	a4,s3,0x20
    8000306e:	01e75593          	srli	a1,a4,0x1e
    80003072:	97ae                	add	a5,a5,a1
    80003074:	89be                	mv	s3,a5
    80003076:	4384                	lw	s1,0(a5)
    80003078:	cc89                	beqz	s1,80003092 <bmap+0x9a>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000307a:	8552                	mv	a0,s4
    8000307c:	d1fff0ef          	jal	80002d9a <brelse>
    return addr;
    80003080:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003082:	8526                	mv	a0,s1
    80003084:	70a2                	ld	ra,40(sp)
    80003086:	7402                	ld	s0,32(sp)
    80003088:	64e2                	ld	s1,24(sp)
    8000308a:	6942                	ld	s2,16(sp)
    8000308c:	69a2                	ld	s3,8(sp)
    8000308e:	6145                	addi	sp,sp,48
    80003090:	8082                	ret
      addr = balloc(ip->dev);
    80003092:	00092503          	lw	a0,0(s2)
    80003096:	e5dff0ef          	jal	80002ef2 <balloc>
    8000309a:	84aa                	mv	s1,a0
      if(addr){
    8000309c:	dd79                	beqz	a0,8000307a <bmap+0x82>
        a[bn] = addr;
    8000309e:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    800030a2:	8552                	mv	a0,s4
    800030a4:	699000ef          	jal	80003f3c <log_write>
    800030a8:	bfc9                	j	8000307a <bmap+0x82>
    800030aa:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800030ac:	00005517          	auipc	a0,0x5
    800030b0:	50450513          	addi	a0,a0,1284 # 800085b0 <etext+0x5b0>
    800030b4:	f70fd0ef          	jal	80000824 <panic>

00000000800030b8 <iget>:
{
    800030b8:	7179                	addi	sp,sp,-48
    800030ba:	f406                	sd	ra,40(sp)
    800030bc:	f022                	sd	s0,32(sp)
    800030be:	ec26                	sd	s1,24(sp)
    800030c0:	e84a                	sd	s2,16(sp)
    800030c2:	e44e                	sd	s3,8(sp)
    800030c4:	e052                	sd	s4,0(sp)
    800030c6:	1800                	addi	s0,sp,48
    800030c8:	892a                	mv	s2,a0
    800030ca:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800030cc:	0001d517          	auipc	a0,0x1d
    800030d0:	24450513          	addi	a0,a0,580 # 80020310 <itable>
    800030d4:	b55fd0ef          	jal	80000c28 <acquire>
  empty = 0;
    800030d8:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800030da:	0001d497          	auipc	s1,0x1d
    800030de:	24e48493          	addi	s1,s1,590 # 80020328 <itable+0x18>
    800030e2:	0001f697          	auipc	a3,0x1f
    800030e6:	e6668693          	addi	a3,a3,-410 # 80021f48 <log>
    800030ea:	a809                	j	800030fc <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800030ec:	e781                	bnez	a5,800030f4 <iget+0x3c>
    800030ee:	00099363          	bnez	s3,800030f4 <iget+0x3c>
      empty = ip;
    800030f2:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800030f4:	09048493          	addi	s1,s1,144
    800030f8:	02d48563          	beq	s1,a3,80003122 <iget+0x6a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800030fc:	449c                	lw	a5,8(s1)
    800030fe:	fef057e3          	blez	a5,800030ec <iget+0x34>
    80003102:	4098                	lw	a4,0(s1)
    80003104:	ff2718e3          	bne	a4,s2,800030f4 <iget+0x3c>
    80003108:	40d8                	lw	a4,4(s1)
    8000310a:	ff4715e3          	bne	a4,s4,800030f4 <iget+0x3c>
      ip->ref++;
    8000310e:	2785                	addiw	a5,a5,1
    80003110:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003112:	0001d517          	auipc	a0,0x1d
    80003116:	1fe50513          	addi	a0,a0,510 # 80020310 <itable>
    8000311a:	ba3fd0ef          	jal	80000cbc <release>
      return ip;
    8000311e:	89a6                	mv	s3,s1
    80003120:	a015                	j	80003144 <iget+0x8c>
  if(empty == 0)
    80003122:	02098a63          	beqz	s3,80003156 <iget+0x9e>
  ip->dev = dev;
    80003126:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    8000312a:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    8000312e:	4785                	li	a5,1
    80003130:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80003134:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    80003138:	0001d517          	auipc	a0,0x1d
    8000313c:	1d850513          	addi	a0,a0,472 # 80020310 <itable>
    80003140:	b7dfd0ef          	jal	80000cbc <release>
}
    80003144:	854e                	mv	a0,s3
    80003146:	70a2                	ld	ra,40(sp)
    80003148:	7402                	ld	s0,32(sp)
    8000314a:	64e2                	ld	s1,24(sp)
    8000314c:	6942                	ld	s2,16(sp)
    8000314e:	69a2                	ld	s3,8(sp)
    80003150:	6a02                	ld	s4,0(sp)
    80003152:	6145                	addi	sp,sp,48
    80003154:	8082                	ret
    panic("iget: no inodes");
    80003156:	00005517          	auipc	a0,0x5
    8000315a:	47250513          	addi	a0,a0,1138 # 800085c8 <etext+0x5c8>
    8000315e:	ec6fd0ef          	jal	80000824 <panic>

0000000080003162 <iinit>:
{
    80003162:	7179                	addi	sp,sp,-48
    80003164:	f406                	sd	ra,40(sp)
    80003166:	f022                	sd	s0,32(sp)
    80003168:	ec26                	sd	s1,24(sp)
    8000316a:	e84a                	sd	s2,16(sp)
    8000316c:	e44e                	sd	s3,8(sp)
    8000316e:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003170:	00005597          	auipc	a1,0x5
    80003174:	46858593          	addi	a1,a1,1128 # 800085d8 <etext+0x5d8>
    80003178:	0001d517          	auipc	a0,0x1d
    8000317c:	19850513          	addi	a0,a0,408 # 80020310 <itable>
    80003180:	a1ffd0ef          	jal	80000b9e <initlock>
  for(i = 0; i < NINODE; i++) {
    80003184:	0001d497          	auipc	s1,0x1d
    80003188:	1b448493          	addi	s1,s1,436 # 80020338 <itable+0x28>
    8000318c:	0001f997          	auipc	s3,0x1f
    80003190:	dcc98993          	addi	s3,s3,-564 # 80021f58 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003194:	00005917          	auipc	s2,0x5
    80003198:	44c90913          	addi	s2,s2,1100 # 800085e0 <etext+0x5e0>
    8000319c:	85ca                	mv	a1,s2
    8000319e:	8526                	mv	a0,s1
    800031a0:	661000ef          	jal	80004000 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800031a4:	09048493          	addi	s1,s1,144
    800031a8:	ff349ae3          	bne	s1,s3,8000319c <iinit+0x3a>
}
    800031ac:	70a2                	ld	ra,40(sp)
    800031ae:	7402                	ld	s0,32(sp)
    800031b0:	64e2                	ld	s1,24(sp)
    800031b2:	6942                	ld	s2,16(sp)
    800031b4:	69a2                	ld	s3,8(sp)
    800031b6:	6145                	addi	sp,sp,48
    800031b8:	8082                	ret

00000000800031ba <ialloc>:
{
    800031ba:	7139                	addi	sp,sp,-64
    800031bc:	fc06                	sd	ra,56(sp)
    800031be:	f822                	sd	s0,48(sp)
    800031c0:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800031c2:	0001d717          	auipc	a4,0x1d
    800031c6:	13a72703          	lw	a4,314(a4) # 800202fc <sb+0xc>
    800031ca:	4785                	li	a5,1
    800031cc:	06e7f063          	bgeu	a5,a4,8000322c <ialloc+0x72>
    800031d0:	f426                	sd	s1,40(sp)
    800031d2:	f04a                	sd	s2,32(sp)
    800031d4:	ec4e                	sd	s3,24(sp)
    800031d6:	e852                	sd	s4,16(sp)
    800031d8:	e456                	sd	s5,8(sp)
    800031da:	e05a                	sd	s6,0(sp)
    800031dc:	8aaa                	mv	s5,a0
    800031de:	8b2e                	mv	s6,a1
    800031e0:	84be                	mv	s1,a5
    bp = bread(dev, IBLOCK(inum, sb));
    800031e2:	0001da17          	auipc	s4,0x1d
    800031e6:	10ea0a13          	addi	s4,s4,270 # 800202f0 <sb>
    800031ea:	0034d593          	srli	a1,s1,0x3
    800031ee:	018a2783          	lw	a5,24(s4)
    800031f2:	9dbd                	addw	a1,a1,a5
    800031f4:	8556                	mv	a0,s5
    800031f6:	a9dff0ef          	jal	80002c92 <bread>
    800031fa:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800031fc:	05850993          	addi	s3,a0,88
    80003200:	0074f793          	andi	a5,s1,7
    80003204:	079e                	slli	a5,a5,0x7
    80003206:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003208:	00099783          	lh	a5,0(s3)
    8000320c:	cb9d                	beqz	a5,80003242 <ialloc+0x88>
    brelse(bp);
    8000320e:	b8dff0ef          	jal	80002d9a <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003212:	0485                	addi	s1,s1,1
    80003214:	00ca2703          	lw	a4,12(s4)
    80003218:	0004879b          	sext.w	a5,s1
    8000321c:	fce7e7e3          	bltu	a5,a4,800031ea <ialloc+0x30>
    80003220:	74a2                	ld	s1,40(sp)
    80003222:	7902                	ld	s2,32(sp)
    80003224:	69e2                	ld	s3,24(sp)
    80003226:	6a42                	ld	s4,16(sp)
    80003228:	6aa2                	ld	s5,8(sp)
    8000322a:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    8000322c:	00005517          	auipc	a0,0x5
    80003230:	3bc50513          	addi	a0,a0,956 # 800085e8 <etext+0x5e8>
    80003234:	ac6fd0ef          	jal	800004fa <printf>
  return 0;
    80003238:	4501                	li	a0,0
}
    8000323a:	70e2                	ld	ra,56(sp)
    8000323c:	7442                	ld	s0,48(sp)
    8000323e:	6121                	addi	sp,sp,64
    80003240:	8082                	ret
    80003242:	2481                	sext.w	s1,s1
      memset(dip, 0, sizeof(*dip));
    80003244:	08000613          	li	a2,128
    80003248:	4581                	li	a1,0
    8000324a:	854e                	mv	a0,s3
    8000324c:	aadfd0ef          	jal	80000cf8 <memset>
      dip->type = type;
    80003250:	01699023          	sh	s6,0(s3)
      struct proc *p = myproc();
    80003254:	ee2fe0ef          	jal	80001936 <myproc>
      dip->uid = p->creds.uid;
    80003258:	16852783          	lw	a5,360(a0)
    8000325c:	04f9a223          	sw	a5,68(s3)
      dip->gid = p->creds.gid;
    80003260:	16c52783          	lw	a5,364(a0)
    80003264:	04f9a423          	sw	a5,72(s3)
      dip->mode = (type == T_DIR) ? 0755 : 0644;
    80003268:	4705                	li	a4,1
    8000326a:	1a400793          	li	a5,420
    8000326e:	02eb0563          	beq	s6,a4,80003298 <ialloc+0xde>
    80003272:	04f9a023          	sw	a5,64(s3)
      log_write(bp);   // mark it allocated on the disk
    80003276:	854a                	mv	a0,s2
    80003278:	4c5000ef          	jal	80003f3c <log_write>
      brelse(bp);
    8000327c:	854a                	mv	a0,s2
    8000327e:	b1dff0ef          	jal	80002d9a <brelse>
      return iget(dev, inum);
    80003282:	85a6                	mv	a1,s1
    80003284:	8556                	mv	a0,s5
    80003286:	e33ff0ef          	jal	800030b8 <iget>
    8000328a:	74a2                	ld	s1,40(sp)
    8000328c:	7902                	ld	s2,32(sp)
    8000328e:	69e2                	ld	s3,24(sp)
    80003290:	6a42                	ld	s4,16(sp)
    80003292:	6aa2                	ld	s5,8(sp)
    80003294:	6b02                	ld	s6,0(sp)
    80003296:	b755                	j	8000323a <ialloc+0x80>
      dip->mode = (type == T_DIR) ? 0755 : 0644;
    80003298:	1ed00793          	li	a5,493
    8000329c:	bfd9                	j	80003272 <ialloc+0xb8>

000000008000329e <iupdate>:
{
    8000329e:	7179                	addi	sp,sp,-48
    800032a0:	f406                	sd	ra,40(sp)
    800032a2:	f022                	sd	s0,32(sp)
    800032a4:	ec26                	sd	s1,24(sp)
    800032a6:	e84a                	sd	s2,16(sp)
    800032a8:	e44e                	sd	s3,8(sp)
    800032aa:	1800                	addi	s0,sp,48
    800032ac:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800032ae:	415c                	lw	a5,4(a0)
    800032b0:	0037d79b          	srliw	a5,a5,0x3
    800032b4:	0001d597          	auipc	a1,0x1d
    800032b8:	0545a583          	lw	a1,84(a1) # 80020308 <sb+0x18>
    800032bc:	9dbd                	addw	a1,a1,a5
    800032be:	4108                	lw	a0,0(a0)
    800032c0:	9d3ff0ef          	jal	80002c92 <bread>
    800032c4:	89aa                	mv	s3,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800032c6:	05850913          	addi	s2,a0,88
    800032ca:	40dc                	lw	a5,4(s1)
    800032cc:	8b9d                	andi	a5,a5,7
    800032ce:	079e                	slli	a5,a5,0x7
    800032d0:	993e                	add	s2,s2,a5
  dip->type = ip->type;
    800032d2:	04449783          	lh	a5,68(s1)
    800032d6:	00f91023          	sh	a5,0(s2)
  dip->major = ip->major;
    800032da:	04649783          	lh	a5,70(s1)
    800032de:	00f91123          	sh	a5,2(s2)
  dip->minor = ip->minor;
    800032e2:	04849783          	lh	a5,72(s1)
    800032e6:	00f91223          	sh	a5,4(s2)
  dip->nlink = ip->nlink;
    800032ea:	04a49783          	lh	a5,74(s1)
    800032ee:	00f91323          	sh	a5,6(s2)
  dip->size = ip->size;
    800032f2:	44fc                	lw	a5,76(s1)
    800032f4:	00f92423          	sw	a5,8(s2)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800032f8:	03400613          	li	a2,52
    800032fc:	05048593          	addi	a1,s1,80
    80003300:	00c90513          	addi	a0,s2,12
    80003304:	a55fd0ef          	jal	80000d58 <memmove>
  dip->mode = ip->mode;
    80003308:	0844a783          	lw	a5,132(s1)
    8000330c:	04f92023          	sw	a5,64(s2)
  dip->uid  = ip->uid;
    80003310:	0884a783          	lw	a5,136(s1)
    80003314:	04f92223          	sw	a5,68(s2)
  dip->gid  = ip->gid;
    80003318:	08c4a783          	lw	a5,140(s1)
    8000331c:	04f92423          	sw	a5,72(s2)
  log_write(bp);
    80003320:	854e                	mv	a0,s3
    80003322:	41b000ef          	jal	80003f3c <log_write>
  brelse(bp);
    80003326:	854e                	mv	a0,s3
    80003328:	a73ff0ef          	jal	80002d9a <brelse>
}
    8000332c:	70a2                	ld	ra,40(sp)
    8000332e:	7402                	ld	s0,32(sp)
    80003330:	64e2                	ld	s1,24(sp)
    80003332:	6942                	ld	s2,16(sp)
    80003334:	69a2                	ld	s3,8(sp)
    80003336:	6145                	addi	sp,sp,48
    80003338:	8082                	ret

000000008000333a <idup>:
{
    8000333a:	1101                	addi	sp,sp,-32
    8000333c:	ec06                	sd	ra,24(sp)
    8000333e:	e822                	sd	s0,16(sp)
    80003340:	e426                	sd	s1,8(sp)
    80003342:	1000                	addi	s0,sp,32
    80003344:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003346:	0001d517          	auipc	a0,0x1d
    8000334a:	fca50513          	addi	a0,a0,-54 # 80020310 <itable>
    8000334e:	8dbfd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    80003352:	449c                	lw	a5,8(s1)
    80003354:	2785                	addiw	a5,a5,1
    80003356:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003358:	0001d517          	auipc	a0,0x1d
    8000335c:	fb850513          	addi	a0,a0,-72 # 80020310 <itable>
    80003360:	95dfd0ef          	jal	80000cbc <release>
}
    80003364:	8526                	mv	a0,s1
    80003366:	60e2                	ld	ra,24(sp)
    80003368:	6442                	ld	s0,16(sp)
    8000336a:	64a2                	ld	s1,8(sp)
    8000336c:	6105                	addi	sp,sp,32
    8000336e:	8082                	ret

0000000080003370 <ilock>:
{
    80003370:	7179                	addi	sp,sp,-48
    80003372:	f406                	sd	ra,40(sp)
    80003374:	f022                	sd	s0,32(sp)
    80003376:	ec26                	sd	s1,24(sp)
    80003378:	1800                	addi	s0,sp,48
  if(ip == 0 || ip->ref < 1)
    8000337a:	cd19                	beqz	a0,80003398 <ilock+0x28>
    8000337c:	84aa                	mv	s1,a0
    8000337e:	451c                	lw	a5,8(a0)
    80003380:	00f05c63          	blez	a5,80003398 <ilock+0x28>
  acquiresleep(&ip->lock);
    80003384:	0541                	addi	a0,a0,16
    80003386:	4b1000ef          	jal	80004036 <acquiresleep>
  if(ip->valid == 0){
    8000338a:	40bc                	lw	a5,64(s1)
    8000338c:	cf91                	beqz	a5,800033a8 <ilock+0x38>
}
    8000338e:	70a2                	ld	ra,40(sp)
    80003390:	7402                	ld	s0,32(sp)
    80003392:	64e2                	ld	s1,24(sp)
    80003394:	6145                	addi	sp,sp,48
    80003396:	8082                	ret
    80003398:	e84a                	sd	s2,16(sp)
    8000339a:	e44e                	sd	s3,8(sp)
    panic("ilock");
    8000339c:	00005517          	auipc	a0,0x5
    800033a0:	26450513          	addi	a0,a0,612 # 80008600 <etext+0x600>
    800033a4:	c80fd0ef          	jal	80000824 <panic>
    800033a8:	e84a                	sd	s2,16(sp)
    800033aa:	e44e                	sd	s3,8(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800033ac:	40dc                	lw	a5,4(s1)
    800033ae:	0037d79b          	srliw	a5,a5,0x3
    800033b2:	0001d597          	auipc	a1,0x1d
    800033b6:	f565a583          	lw	a1,-170(a1) # 80020308 <sb+0x18>
    800033ba:	9dbd                	addw	a1,a1,a5
    800033bc:	4088                	lw	a0,0(s1)
    800033be:	8d5ff0ef          	jal	80002c92 <bread>
    800033c2:	89aa                	mv	s3,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800033c4:	05850913          	addi	s2,a0,88
    800033c8:	40dc                	lw	a5,4(s1)
    800033ca:	8b9d                	andi	a5,a5,7
    800033cc:	079e                	slli	a5,a5,0x7
    800033ce:	993e                	add	s2,s2,a5
    ip->type = dip->type;
    800033d0:	00091783          	lh	a5,0(s2)
    800033d4:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800033d8:	00291783          	lh	a5,2(s2)
    800033dc:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800033e0:	00491783          	lh	a5,4(s2)
    800033e4:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800033e8:	00691783          	lh	a5,6(s2)
    800033ec:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800033f0:	00892783          	lw	a5,8(s2)
    800033f4:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800033f6:	03400613          	li	a2,52
    800033fa:	00c90593          	addi	a1,s2,12
    800033fe:	05048513          	addi	a0,s1,80
    80003402:	957fd0ef          	jal	80000d58 <memmove>
    ip->mode  = dip->mode;
    80003406:	04092783          	lw	a5,64(s2)
    8000340a:	08f4a223          	sw	a5,132(s1)
    ip->uid   = dip->uid;
    8000340e:	04492783          	lw	a5,68(s2)
    80003412:	08f4a423          	sw	a5,136(s1)
    ip->gid   = dip->gid;
    80003416:	04892783          	lw	a5,72(s2)
    8000341a:	08f4a623          	sw	a5,140(s1)
    brelse(bp);
    8000341e:	854e                	mv	a0,s3
    80003420:	97bff0ef          	jal	80002d9a <brelse>
    ip->valid = 1;
    80003424:	4785                	li	a5,1
    80003426:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003428:	04449783          	lh	a5,68(s1)
    8000342c:	c781                	beqz	a5,80003434 <ilock+0xc4>
    8000342e:	6942                	ld	s2,16(sp)
    80003430:	69a2                	ld	s3,8(sp)
    80003432:	bfb1                	j	8000338e <ilock+0x1e>
      panic("ilock: no type");
    80003434:	00005517          	auipc	a0,0x5
    80003438:	1d450513          	addi	a0,a0,468 # 80008608 <etext+0x608>
    8000343c:	be8fd0ef          	jal	80000824 <panic>

0000000080003440 <iunlock>:
{
    80003440:	1101                	addi	sp,sp,-32
    80003442:	ec06                	sd	ra,24(sp)
    80003444:	e822                	sd	s0,16(sp)
    80003446:	e426                	sd	s1,8(sp)
    80003448:	e04a                	sd	s2,0(sp)
    8000344a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000344c:	c505                	beqz	a0,80003474 <iunlock+0x34>
    8000344e:	84aa                	mv	s1,a0
    80003450:	01050913          	addi	s2,a0,16
    80003454:	854a                	mv	a0,s2
    80003456:	45f000ef          	jal	800040b4 <holdingsleep>
    8000345a:	cd09                	beqz	a0,80003474 <iunlock+0x34>
    8000345c:	449c                	lw	a5,8(s1)
    8000345e:	00f05b63          	blez	a5,80003474 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003462:	854a                	mv	a0,s2
    80003464:	419000ef          	jal	8000407c <releasesleep>
}
    80003468:	60e2                	ld	ra,24(sp)
    8000346a:	6442                	ld	s0,16(sp)
    8000346c:	64a2                	ld	s1,8(sp)
    8000346e:	6902                	ld	s2,0(sp)
    80003470:	6105                	addi	sp,sp,32
    80003472:	8082                	ret
    panic("iunlock");
    80003474:	00005517          	auipc	a0,0x5
    80003478:	1a450513          	addi	a0,a0,420 # 80008618 <etext+0x618>
    8000347c:	ba8fd0ef          	jal	80000824 <panic>

0000000080003480 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003480:	7179                	addi	sp,sp,-48
    80003482:	f406                	sd	ra,40(sp)
    80003484:	f022                	sd	s0,32(sp)
    80003486:	ec26                	sd	s1,24(sp)
    80003488:	e84a                	sd	s2,16(sp)
    8000348a:	e44e                	sd	s3,8(sp)
    8000348c:	1800                	addi	s0,sp,48
    8000348e:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003490:	05050493          	addi	s1,a0,80
    80003494:	08050913          	addi	s2,a0,128
    80003498:	a021                	j	800034a0 <itrunc+0x20>
    8000349a:	0491                	addi	s1,s1,4
    8000349c:	01248b63          	beq	s1,s2,800034b2 <itrunc+0x32>
    if(ip->addrs[i]){
    800034a0:	408c                	lw	a1,0(s1)
    800034a2:	dde5                	beqz	a1,8000349a <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800034a4:	0009a503          	lw	a0,0(s3)
    800034a8:	9dfff0ef          	jal	80002e86 <bfree>
      ip->addrs[i] = 0;
    800034ac:	0004a023          	sw	zero,0(s1)
    800034b0:	b7ed                	j	8000349a <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800034b2:	0809a583          	lw	a1,128(s3)
    800034b6:	ed89                	bnez	a1,800034d0 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800034b8:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800034bc:	854e                	mv	a0,s3
    800034be:	de1ff0ef          	jal	8000329e <iupdate>
}
    800034c2:	70a2                	ld	ra,40(sp)
    800034c4:	7402                	ld	s0,32(sp)
    800034c6:	64e2                	ld	s1,24(sp)
    800034c8:	6942                	ld	s2,16(sp)
    800034ca:	69a2                	ld	s3,8(sp)
    800034cc:	6145                	addi	sp,sp,48
    800034ce:	8082                	ret
    800034d0:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800034d2:	0009a503          	lw	a0,0(s3)
    800034d6:	fbcff0ef          	jal	80002c92 <bread>
    800034da:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800034dc:	05850493          	addi	s1,a0,88
    800034e0:	45850913          	addi	s2,a0,1112
    800034e4:	a021                	j	800034ec <itrunc+0x6c>
    800034e6:	0491                	addi	s1,s1,4
    800034e8:	01248963          	beq	s1,s2,800034fa <itrunc+0x7a>
      if(a[j])
    800034ec:	408c                	lw	a1,0(s1)
    800034ee:	dde5                	beqz	a1,800034e6 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800034f0:	0009a503          	lw	a0,0(s3)
    800034f4:	993ff0ef          	jal	80002e86 <bfree>
    800034f8:	b7fd                	j	800034e6 <itrunc+0x66>
    brelse(bp);
    800034fa:	8552                	mv	a0,s4
    800034fc:	89fff0ef          	jal	80002d9a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003500:	0809a583          	lw	a1,128(s3)
    80003504:	0009a503          	lw	a0,0(s3)
    80003508:	97fff0ef          	jal	80002e86 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000350c:	0809a023          	sw	zero,128(s3)
    80003510:	6a02                	ld	s4,0(sp)
    80003512:	b75d                	j	800034b8 <itrunc+0x38>

0000000080003514 <iput>:
{
    80003514:	1101                	addi	sp,sp,-32
    80003516:	ec06                	sd	ra,24(sp)
    80003518:	e822                	sd	s0,16(sp)
    8000351a:	e426                	sd	s1,8(sp)
    8000351c:	1000                	addi	s0,sp,32
    8000351e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003520:	0001d517          	auipc	a0,0x1d
    80003524:	df050513          	addi	a0,a0,-528 # 80020310 <itable>
    80003528:	f00fd0ef          	jal	80000c28 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000352c:	4498                	lw	a4,8(s1)
    8000352e:	4785                	li	a5,1
    80003530:	02f70063          	beq	a4,a5,80003550 <iput+0x3c>
  ip->ref--;
    80003534:	449c                	lw	a5,8(s1)
    80003536:	37fd                	addiw	a5,a5,-1
    80003538:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000353a:	0001d517          	auipc	a0,0x1d
    8000353e:	dd650513          	addi	a0,a0,-554 # 80020310 <itable>
    80003542:	f7afd0ef          	jal	80000cbc <release>
}
    80003546:	60e2                	ld	ra,24(sp)
    80003548:	6442                	ld	s0,16(sp)
    8000354a:	64a2                	ld	s1,8(sp)
    8000354c:	6105                	addi	sp,sp,32
    8000354e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003550:	40bc                	lw	a5,64(s1)
    80003552:	d3ed                	beqz	a5,80003534 <iput+0x20>
    80003554:	04a49783          	lh	a5,74(s1)
    80003558:	fff1                	bnez	a5,80003534 <iput+0x20>
    8000355a:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    8000355c:	01048793          	addi	a5,s1,16
    80003560:	893e                	mv	s2,a5
    80003562:	853e                	mv	a0,a5
    80003564:	2d3000ef          	jal	80004036 <acquiresleep>
    release(&itable.lock);
    80003568:	0001d517          	auipc	a0,0x1d
    8000356c:	da850513          	addi	a0,a0,-600 # 80020310 <itable>
    80003570:	f4cfd0ef          	jal	80000cbc <release>
    itrunc(ip);
    80003574:	8526                	mv	a0,s1
    80003576:	f0bff0ef          	jal	80003480 <itrunc>
    ip->type = 0;
    8000357a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000357e:	8526                	mv	a0,s1
    80003580:	d1fff0ef          	jal	8000329e <iupdate>
    ip->valid = 0;
    80003584:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003588:	854a                	mv	a0,s2
    8000358a:	2f3000ef          	jal	8000407c <releasesleep>
    acquire(&itable.lock);
    8000358e:	0001d517          	auipc	a0,0x1d
    80003592:	d8250513          	addi	a0,a0,-638 # 80020310 <itable>
    80003596:	e92fd0ef          	jal	80000c28 <acquire>
    8000359a:	6902                	ld	s2,0(sp)
    8000359c:	bf61                	j	80003534 <iput+0x20>

000000008000359e <iunlockput>:
{
    8000359e:	1101                	addi	sp,sp,-32
    800035a0:	ec06                	sd	ra,24(sp)
    800035a2:	e822                	sd	s0,16(sp)
    800035a4:	e426                	sd	s1,8(sp)
    800035a6:	1000                	addi	s0,sp,32
    800035a8:	84aa                	mv	s1,a0
  iunlock(ip);
    800035aa:	e97ff0ef          	jal	80003440 <iunlock>
  iput(ip);
    800035ae:	8526                	mv	a0,s1
    800035b0:	f65ff0ef          	jal	80003514 <iput>
}
    800035b4:	60e2                	ld	ra,24(sp)
    800035b6:	6442                	ld	s0,16(sp)
    800035b8:	64a2                	ld	s1,8(sp)
    800035ba:	6105                	addi	sp,sp,32
    800035bc:	8082                	ret

00000000800035be <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800035be:	0001d717          	auipc	a4,0x1d
    800035c2:	d3e72703          	lw	a4,-706(a4) # 800202fc <sb+0xc>
    800035c6:	4785                	li	a5,1
    800035c8:	0ae7fe63          	bgeu	a5,a4,80003684 <ireclaim+0xc6>
{
    800035cc:	7139                	addi	sp,sp,-64
    800035ce:	fc06                	sd	ra,56(sp)
    800035d0:	f822                	sd	s0,48(sp)
    800035d2:	f426                	sd	s1,40(sp)
    800035d4:	f04a                	sd	s2,32(sp)
    800035d6:	ec4e                	sd	s3,24(sp)
    800035d8:	e852                	sd	s4,16(sp)
    800035da:	e456                	sd	s5,8(sp)
    800035dc:	e05a                	sd	s6,0(sp)
    800035de:	0080                	addi	s0,sp,64
    800035e0:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800035e2:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800035e4:	0001da17          	auipc	s4,0x1d
    800035e8:	d0ca0a13          	addi	s4,s4,-756 # 800202f0 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    800035ec:	00005b17          	auipc	s6,0x5
    800035f0:	034b0b13          	addi	s6,s6,52 # 80008620 <etext+0x620>
    800035f4:	a099                	j	8000363a <ireclaim+0x7c>
    800035f6:	85ce                	mv	a1,s3
    800035f8:	855a                	mv	a0,s6
    800035fa:	f01fc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    800035fe:	85ce                	mv	a1,s3
    80003600:	8556                	mv	a0,s5
    80003602:	ab7ff0ef          	jal	800030b8 <iget>
    80003606:	89aa                	mv	s3,a0
    brelse(bp);
    80003608:	854a                	mv	a0,s2
    8000360a:	f90ff0ef          	jal	80002d9a <brelse>
    if (ip) {
    8000360e:	00098f63          	beqz	s3,8000362c <ireclaim+0x6e>
      begin_op();
    80003612:	790000ef          	jal	80003da2 <begin_op>
      ilock(ip);
    80003616:	854e                	mv	a0,s3
    80003618:	d59ff0ef          	jal	80003370 <ilock>
      iunlock(ip);
    8000361c:	854e                	mv	a0,s3
    8000361e:	e23ff0ef          	jal	80003440 <iunlock>
      iput(ip);
    80003622:	854e                	mv	a0,s3
    80003624:	ef1ff0ef          	jal	80003514 <iput>
      end_op();
    80003628:	7ea000ef          	jal	80003e12 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000362c:	0485                	addi	s1,s1,1
    8000362e:	00ca2703          	lw	a4,12(s4)
    80003632:	0004879b          	sext.w	a5,s1
    80003636:	02e7fd63          	bgeu	a5,a4,80003670 <ireclaim+0xb2>
    8000363a:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000363e:	0034d593          	srli	a1,s1,0x3
    80003642:	018a2783          	lw	a5,24(s4)
    80003646:	9dbd                	addw	a1,a1,a5
    80003648:	8556                	mv	a0,s5
    8000364a:	e48ff0ef          	jal	80002c92 <bread>
    8000364e:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003650:	05850793          	addi	a5,a0,88
    80003654:	0079f713          	andi	a4,s3,7
    80003658:	071e                	slli	a4,a4,0x7
    8000365a:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    8000365c:	00079703          	lh	a4,0(a5)
    80003660:	c701                	beqz	a4,80003668 <ireclaim+0xaa>
    80003662:	00679783          	lh	a5,6(a5)
    80003666:	dbc1                	beqz	a5,800035f6 <ireclaim+0x38>
    brelse(bp);
    80003668:	854a                	mv	a0,s2
    8000366a:	f30ff0ef          	jal	80002d9a <brelse>
    if (ip) {
    8000366e:	bf7d                	j	8000362c <ireclaim+0x6e>
}
    80003670:	70e2                	ld	ra,56(sp)
    80003672:	7442                	ld	s0,48(sp)
    80003674:	74a2                	ld	s1,40(sp)
    80003676:	7902                	ld	s2,32(sp)
    80003678:	69e2                	ld	s3,24(sp)
    8000367a:	6a42                	ld	s4,16(sp)
    8000367c:	6aa2                	ld	s5,8(sp)
    8000367e:	6b02                	ld	s6,0(sp)
    80003680:	6121                	addi	sp,sp,64
    80003682:	8082                	ret
    80003684:	8082                	ret

0000000080003686 <fsinit>:
fsinit(int dev) {
    80003686:	1101                	addi	sp,sp,-32
    80003688:	ec06                	sd	ra,24(sp)
    8000368a:	e822                	sd	s0,16(sp)
    8000368c:	e426                	sd	s1,8(sp)
    8000368e:	e04a                	sd	s2,0(sp)
    80003690:	1000                	addi	s0,sp,32
    80003692:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003694:	4585                	li	a1,1
    80003696:	dfcff0ef          	jal	80002c92 <bread>
    8000369a:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000369c:	02000613          	li	a2,32
    800036a0:	05850593          	addi	a1,a0,88
    800036a4:	0001d517          	auipc	a0,0x1d
    800036a8:	c4c50513          	addi	a0,a0,-948 # 800202f0 <sb>
    800036ac:	eacfd0ef          	jal	80000d58 <memmove>
  brelse(bp);
    800036b0:	8526                	mv	a0,s1
    800036b2:	ee8ff0ef          	jal	80002d9a <brelse>
  if(sb.magic != FSMAGIC)
    800036b6:	0001d717          	auipc	a4,0x1d
    800036ba:	c3a72703          	lw	a4,-966(a4) # 800202f0 <sb>
    800036be:	102037b7          	lui	a5,0x10203
    800036c2:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800036c6:	02f71463          	bne	a4,a5,800036ee <fsinit+0x68>
  initlog(dev, &sb);
    800036ca:	0001d597          	auipc	a1,0x1d
    800036ce:	c2658593          	addi	a1,a1,-986 # 800202f0 <sb>
    800036d2:	854a                	mv	a0,s2
    800036d4:	64c000ef          	jal	80003d20 <initlog>
  ireclaim(dev);
    800036d8:	854a                	mv	a0,s2
    800036da:	ee5ff0ef          	jal	800035be <ireclaim>
  fsinit_security();
    800036de:	128020ef          	jal	80005806 <fsinit_security>
}
    800036e2:	60e2                	ld	ra,24(sp)
    800036e4:	6442                	ld	s0,16(sp)
    800036e6:	64a2                	ld	s1,8(sp)
    800036e8:	6902                	ld	s2,0(sp)
    800036ea:	6105                	addi	sp,sp,32
    800036ec:	8082                	ret
    panic("invalid file system");
    800036ee:	00005517          	auipc	a0,0x5
    800036f2:	f5250513          	addi	a0,a0,-174 # 80008640 <etext+0x640>
    800036f6:	92efd0ef          	jal	80000824 <panic>

00000000800036fa <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800036fa:	1141                	addi	sp,sp,-16
    800036fc:	e406                	sd	ra,8(sp)
    800036fe:	e022                	sd	s0,0(sp)
    80003700:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003702:	411c                	lw	a5,0(a0)
    80003704:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003706:	415c                	lw	a5,4(a0)
    80003708:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000370a:	04451783          	lh	a5,68(a0)
    8000370e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003712:	04a51783          	lh	a5,74(a0)
    80003716:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000371a:	04c56783          	lwu	a5,76(a0)
    8000371e:	e99c                	sd	a5,16(a1)
}
    80003720:	60a2                	ld	ra,8(sp)
    80003722:	6402                	ld	s0,0(sp)
    80003724:	0141                	addi	sp,sp,16
    80003726:	8082                	ret

0000000080003728 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003728:	457c                	lw	a5,76(a0)
    8000372a:	0ed7e663          	bltu	a5,a3,80003816 <readi+0xee>
{
    8000372e:	7159                	addi	sp,sp,-112
    80003730:	f486                	sd	ra,104(sp)
    80003732:	f0a2                	sd	s0,96(sp)
    80003734:	eca6                	sd	s1,88(sp)
    80003736:	e0d2                	sd	s4,64(sp)
    80003738:	fc56                	sd	s5,56(sp)
    8000373a:	f85a                	sd	s6,48(sp)
    8000373c:	f45e                	sd	s7,40(sp)
    8000373e:	1880                	addi	s0,sp,112
    80003740:	8b2a                	mv	s6,a0
    80003742:	8bae                	mv	s7,a1
    80003744:	8a32                	mv	s4,a2
    80003746:	84b6                	mv	s1,a3
    80003748:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000374a:	9f35                	addw	a4,a4,a3
    return 0;
    8000374c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000374e:	0ad76b63          	bltu	a4,a3,80003804 <readi+0xdc>
    80003752:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003754:	00e7f463          	bgeu	a5,a4,8000375c <readi+0x34>
    n = ip->size - off;
    80003758:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000375c:	080a8b63          	beqz	s5,800037f2 <readi+0xca>
    80003760:	e8ca                	sd	s2,80(sp)
    80003762:	f062                	sd	s8,32(sp)
    80003764:	ec66                	sd	s9,24(sp)
    80003766:	e86a                	sd	s10,16(sp)
    80003768:	e46e                	sd	s11,8(sp)
    8000376a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000376c:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003770:	5c7d                	li	s8,-1
    80003772:	a80d                	j	800037a4 <readi+0x7c>
    80003774:	020d1d93          	slli	s11,s10,0x20
    80003778:	020ddd93          	srli	s11,s11,0x20
    8000377c:	05890613          	addi	a2,s2,88
    80003780:	86ee                	mv	a3,s11
    80003782:	963e                	add	a2,a2,a5
    80003784:	85d2                	mv	a1,s4
    80003786:	855e                	mv	a0,s7
    80003788:	b65fe0ef          	jal	800022ec <either_copyout>
    8000378c:	05850363          	beq	a0,s8,800037d2 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003790:	854a                	mv	a0,s2
    80003792:	e08ff0ef          	jal	80002d9a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003796:	013d09bb          	addw	s3,s10,s3
    8000379a:	009d04bb          	addw	s1,s10,s1
    8000379e:	9a6e                	add	s4,s4,s11
    800037a0:	0559f363          	bgeu	s3,s5,800037e6 <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800037a4:	00a4d59b          	srliw	a1,s1,0xa
    800037a8:	855a                	mv	a0,s6
    800037aa:	84fff0ef          	jal	80002ff8 <bmap>
    800037ae:	85aa                	mv	a1,a0
    if(addr == 0)
    800037b0:	c139                	beqz	a0,800037f6 <readi+0xce>
    bp = bread(ip->dev, addr);
    800037b2:	000b2503          	lw	a0,0(s6)
    800037b6:	cdcff0ef          	jal	80002c92 <bread>
    800037ba:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800037bc:	3ff4f793          	andi	a5,s1,1023
    800037c0:	40fc873b          	subw	a4,s9,a5
    800037c4:	413a86bb          	subw	a3,s5,s3
    800037c8:	8d3a                	mv	s10,a4
    800037ca:	fae6f5e3          	bgeu	a3,a4,80003774 <readi+0x4c>
    800037ce:	8d36                	mv	s10,a3
    800037d0:	b755                	j	80003774 <readi+0x4c>
      brelse(bp);
    800037d2:	854a                	mv	a0,s2
    800037d4:	dc6ff0ef          	jal	80002d9a <brelse>
      tot = -1;
    800037d8:	59fd                	li	s3,-1
      break;
    800037da:	6946                	ld	s2,80(sp)
    800037dc:	7c02                	ld	s8,32(sp)
    800037de:	6ce2                	ld	s9,24(sp)
    800037e0:	6d42                	ld	s10,16(sp)
    800037e2:	6da2                	ld	s11,8(sp)
    800037e4:	a831                	j	80003800 <readi+0xd8>
    800037e6:	6946                	ld	s2,80(sp)
    800037e8:	7c02                	ld	s8,32(sp)
    800037ea:	6ce2                	ld	s9,24(sp)
    800037ec:	6d42                	ld	s10,16(sp)
    800037ee:	6da2                	ld	s11,8(sp)
    800037f0:	a801                	j	80003800 <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800037f2:	89d6                	mv	s3,s5
    800037f4:	a031                	j	80003800 <readi+0xd8>
    800037f6:	6946                	ld	s2,80(sp)
    800037f8:	7c02                	ld	s8,32(sp)
    800037fa:	6ce2                	ld	s9,24(sp)
    800037fc:	6d42                	ld	s10,16(sp)
    800037fe:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003800:	854e                	mv	a0,s3
    80003802:	69a6                	ld	s3,72(sp)
}
    80003804:	70a6                	ld	ra,104(sp)
    80003806:	7406                	ld	s0,96(sp)
    80003808:	64e6                	ld	s1,88(sp)
    8000380a:	6a06                	ld	s4,64(sp)
    8000380c:	7ae2                	ld	s5,56(sp)
    8000380e:	7b42                	ld	s6,48(sp)
    80003810:	7ba2                	ld	s7,40(sp)
    80003812:	6165                	addi	sp,sp,112
    80003814:	8082                	ret
    return 0;
    80003816:	4501                	li	a0,0
}
    80003818:	8082                	ret

000000008000381a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000381a:	457c                	lw	a5,76(a0)
    8000381c:	0ed7eb63          	bltu	a5,a3,80003912 <writei+0xf8>
{
    80003820:	7159                	addi	sp,sp,-112
    80003822:	f486                	sd	ra,104(sp)
    80003824:	f0a2                	sd	s0,96(sp)
    80003826:	e8ca                	sd	s2,80(sp)
    80003828:	e0d2                	sd	s4,64(sp)
    8000382a:	fc56                	sd	s5,56(sp)
    8000382c:	f85a                	sd	s6,48(sp)
    8000382e:	f45e                	sd	s7,40(sp)
    80003830:	1880                	addi	s0,sp,112
    80003832:	8aaa                	mv	s5,a0
    80003834:	8bae                	mv	s7,a1
    80003836:	8a32                	mv	s4,a2
    80003838:	8936                	mv	s2,a3
    8000383a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000383c:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003840:	00043737          	lui	a4,0x43
    80003844:	0cf76963          	bltu	a4,a5,80003916 <writei+0xfc>
    80003848:	0cd7e763          	bltu	a5,a3,80003916 <writei+0xfc>
    8000384c:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000384e:	0a0b0a63          	beqz	s6,80003902 <writei+0xe8>
    80003852:	eca6                	sd	s1,88(sp)
    80003854:	f062                	sd	s8,32(sp)
    80003856:	ec66                	sd	s9,24(sp)
    80003858:	e86a                	sd	s10,16(sp)
    8000385a:	e46e                	sd	s11,8(sp)
    8000385c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000385e:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003862:	5c7d                	li	s8,-1
    80003864:	a825                	j	8000389c <writei+0x82>
    80003866:	020d1d93          	slli	s11,s10,0x20
    8000386a:	020ddd93          	srli	s11,s11,0x20
    8000386e:	05848513          	addi	a0,s1,88
    80003872:	86ee                	mv	a3,s11
    80003874:	8652                	mv	a2,s4
    80003876:	85de                	mv	a1,s7
    80003878:	953e                	add	a0,a0,a5
    8000387a:	abdfe0ef          	jal	80002336 <either_copyin>
    8000387e:	05850663          	beq	a0,s8,800038ca <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003882:	8526                	mv	a0,s1
    80003884:	6b8000ef          	jal	80003f3c <log_write>
    brelse(bp);
    80003888:	8526                	mv	a0,s1
    8000388a:	d10ff0ef          	jal	80002d9a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000388e:	013d09bb          	addw	s3,s10,s3
    80003892:	012d093b          	addw	s2,s10,s2
    80003896:	9a6e                	add	s4,s4,s11
    80003898:	0369fc63          	bgeu	s3,s6,800038d0 <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    8000389c:	00a9559b          	srliw	a1,s2,0xa
    800038a0:	8556                	mv	a0,s5
    800038a2:	f56ff0ef          	jal	80002ff8 <bmap>
    800038a6:	85aa                	mv	a1,a0
    if(addr == 0)
    800038a8:	c505                	beqz	a0,800038d0 <writei+0xb6>
    bp = bread(ip->dev, addr);
    800038aa:	000aa503          	lw	a0,0(s5)
    800038ae:	be4ff0ef          	jal	80002c92 <bread>
    800038b2:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800038b4:	3ff97793          	andi	a5,s2,1023
    800038b8:	40fc873b          	subw	a4,s9,a5
    800038bc:	413b06bb          	subw	a3,s6,s3
    800038c0:	8d3a                	mv	s10,a4
    800038c2:	fae6f2e3          	bgeu	a3,a4,80003866 <writei+0x4c>
    800038c6:	8d36                	mv	s10,a3
    800038c8:	bf79                	j	80003866 <writei+0x4c>
      brelse(bp);
    800038ca:	8526                	mv	a0,s1
    800038cc:	cceff0ef          	jal	80002d9a <brelse>
  }

  if(off > ip->size)
    800038d0:	04caa783          	lw	a5,76(s5)
    800038d4:	0327f963          	bgeu	a5,s2,80003906 <writei+0xec>
    ip->size = off;
    800038d8:	052aa623          	sw	s2,76(s5)
    800038dc:	64e6                	ld	s1,88(sp)
    800038de:	7c02                	ld	s8,32(sp)
    800038e0:	6ce2                	ld	s9,24(sp)
    800038e2:	6d42                	ld	s10,16(sp)
    800038e4:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800038e6:	8556                	mv	a0,s5
    800038e8:	9b7ff0ef          	jal	8000329e <iupdate>

  return tot;
    800038ec:	854e                	mv	a0,s3
    800038ee:	69a6                	ld	s3,72(sp)
}
    800038f0:	70a6                	ld	ra,104(sp)
    800038f2:	7406                	ld	s0,96(sp)
    800038f4:	6946                	ld	s2,80(sp)
    800038f6:	6a06                	ld	s4,64(sp)
    800038f8:	7ae2                	ld	s5,56(sp)
    800038fa:	7b42                	ld	s6,48(sp)
    800038fc:	7ba2                	ld	s7,40(sp)
    800038fe:	6165                	addi	sp,sp,112
    80003900:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003902:	89da                	mv	s3,s6
    80003904:	b7cd                	j	800038e6 <writei+0xcc>
    80003906:	64e6                	ld	s1,88(sp)
    80003908:	7c02                	ld	s8,32(sp)
    8000390a:	6ce2                	ld	s9,24(sp)
    8000390c:	6d42                	ld	s10,16(sp)
    8000390e:	6da2                	ld	s11,8(sp)
    80003910:	bfd9                	j	800038e6 <writei+0xcc>
    return -1;
    80003912:	557d                	li	a0,-1
}
    80003914:	8082                	ret
    return -1;
    80003916:	557d                	li	a0,-1
    80003918:	bfe1                	j	800038f0 <writei+0xd6>

000000008000391a <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000391a:	1141                	addi	sp,sp,-16
    8000391c:	e406                	sd	ra,8(sp)
    8000391e:	e022                	sd	s0,0(sp)
    80003920:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003922:	4639                	li	a2,14
    80003924:	ca8fd0ef          	jal	80000dcc <strncmp>
}
    80003928:	60a2                	ld	ra,8(sp)
    8000392a:	6402                	ld	s0,0(sp)
    8000392c:	0141                	addi	sp,sp,16
    8000392e:	8082                	ret

0000000080003930 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003930:	711d                	addi	sp,sp,-96
    80003932:	ec86                	sd	ra,88(sp)
    80003934:	e8a2                	sd	s0,80(sp)
    80003936:	e4a6                	sd	s1,72(sp)
    80003938:	e0ca                	sd	s2,64(sp)
    8000393a:	fc4e                	sd	s3,56(sp)
    8000393c:	f852                	sd	s4,48(sp)
    8000393e:	f456                	sd	s5,40(sp)
    80003940:	f05a                	sd	s6,32(sp)
    80003942:	ec5e                	sd	s7,24(sp)
    80003944:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003946:	04451703          	lh	a4,68(a0)
    8000394a:	4785                	li	a5,1
    8000394c:	00f71f63          	bne	a4,a5,8000396a <dirlookup+0x3a>
    80003950:	892a                	mv	s2,a0
    80003952:	8aae                	mv	s5,a1
    80003954:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003956:	457c                	lw	a5,76(a0)
    80003958:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000395a:	fa040a13          	addi	s4,s0,-96
    8000395e:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    80003960:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003964:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003966:	e39d                	bnez	a5,8000398c <dirlookup+0x5c>
    80003968:	a8b9                	j	800039c6 <dirlookup+0x96>
    panic("dirlookup not DIR");
    8000396a:	00005517          	auipc	a0,0x5
    8000396e:	cee50513          	addi	a0,a0,-786 # 80008658 <etext+0x658>
    80003972:	eb3fc0ef          	jal	80000824 <panic>
      panic("dirlookup read");
    80003976:	00005517          	auipc	a0,0x5
    8000397a:	cfa50513          	addi	a0,a0,-774 # 80008670 <etext+0x670>
    8000397e:	ea7fc0ef          	jal	80000824 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003982:	24c1                	addiw	s1,s1,16
    80003984:	04c92783          	lw	a5,76(s2)
    80003988:	02f4fe63          	bgeu	s1,a5,800039c4 <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000398c:	874e                	mv	a4,s3
    8000398e:	86a6                	mv	a3,s1
    80003990:	8652                	mv	a2,s4
    80003992:	4581                	li	a1,0
    80003994:	854a                	mv	a0,s2
    80003996:	d93ff0ef          	jal	80003728 <readi>
    8000399a:	fd351ee3          	bne	a0,s3,80003976 <dirlookup+0x46>
    if(de.inum == 0)
    8000399e:	fa045783          	lhu	a5,-96(s0)
    800039a2:	d3e5                	beqz	a5,80003982 <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    800039a4:	85da                	mv	a1,s6
    800039a6:	8556                	mv	a0,s5
    800039a8:	f73ff0ef          	jal	8000391a <namecmp>
    800039ac:	f979                	bnez	a0,80003982 <dirlookup+0x52>
      if(poff)
    800039ae:	000b8463          	beqz	s7,800039b6 <dirlookup+0x86>
        *poff = off;
    800039b2:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    800039b6:	fa045583          	lhu	a1,-96(s0)
    800039ba:	00092503          	lw	a0,0(s2)
    800039be:	efaff0ef          	jal	800030b8 <iget>
    800039c2:	a011                	j	800039c6 <dirlookup+0x96>
  return 0;
    800039c4:	4501                	li	a0,0
}
    800039c6:	60e6                	ld	ra,88(sp)
    800039c8:	6446                	ld	s0,80(sp)
    800039ca:	64a6                	ld	s1,72(sp)
    800039cc:	6906                	ld	s2,64(sp)
    800039ce:	79e2                	ld	s3,56(sp)
    800039d0:	7a42                	ld	s4,48(sp)
    800039d2:	7aa2                	ld	s5,40(sp)
    800039d4:	7b02                	ld	s6,32(sp)
    800039d6:	6be2                	ld	s7,24(sp)
    800039d8:	6125                	addi	sp,sp,96
    800039da:	8082                	ret

00000000800039dc <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800039dc:	711d                	addi	sp,sp,-96
    800039de:	ec86                	sd	ra,88(sp)
    800039e0:	e8a2                	sd	s0,80(sp)
    800039e2:	e4a6                	sd	s1,72(sp)
    800039e4:	e0ca                	sd	s2,64(sp)
    800039e6:	fc4e                	sd	s3,56(sp)
    800039e8:	f852                	sd	s4,48(sp)
    800039ea:	f456                	sd	s5,40(sp)
    800039ec:	f05a                	sd	s6,32(sp)
    800039ee:	ec5e                	sd	s7,24(sp)
    800039f0:	e862                	sd	s8,16(sp)
    800039f2:	e466                	sd	s9,8(sp)
    800039f4:	e06a                	sd	s10,0(sp)
    800039f6:	1080                	addi	s0,sp,96
    800039f8:	84aa                	mv	s1,a0
    800039fa:	8b2e                	mv	s6,a1
    800039fc:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800039fe:	00054703          	lbu	a4,0(a0)
    80003a02:	02f00793          	li	a5,47
    80003a06:	00f70f63          	beq	a4,a5,80003a24 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003a0a:	f2dfd0ef          	jal	80001936 <myproc>
    80003a0e:	15053503          	ld	a0,336(a0)
    80003a12:	929ff0ef          	jal	8000333a <idup>
    80003a16:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003a18:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    80003a1c:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003a1e:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003a20:	4b85                	li	s7,1
    80003a22:	a879                	j	80003ac0 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80003a24:	4585                	li	a1,1
    80003a26:	852e                	mv	a0,a1
    80003a28:	e90ff0ef          	jal	800030b8 <iget>
    80003a2c:	8a2a                	mv	s4,a0
    80003a2e:	b7ed                	j	80003a18 <namex+0x3c>
      iunlockput(ip);
    80003a30:	8552                	mv	a0,s4
    80003a32:	b6dff0ef          	jal	8000359e <iunlockput>
      return 0;
    80003a36:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003a38:	8552                	mv	a0,s4
    80003a3a:	60e6                	ld	ra,88(sp)
    80003a3c:	6446                	ld	s0,80(sp)
    80003a3e:	64a6                	ld	s1,72(sp)
    80003a40:	6906                	ld	s2,64(sp)
    80003a42:	79e2                	ld	s3,56(sp)
    80003a44:	7a42                	ld	s4,48(sp)
    80003a46:	7aa2                	ld	s5,40(sp)
    80003a48:	7b02                	ld	s6,32(sp)
    80003a4a:	6be2                	ld	s7,24(sp)
    80003a4c:	6c42                	ld	s8,16(sp)
    80003a4e:	6ca2                	ld	s9,8(sp)
    80003a50:	6d02                	ld	s10,0(sp)
    80003a52:	6125                	addi	sp,sp,96
    80003a54:	8082                	ret
      iunlock(ip);
    80003a56:	8552                	mv	a0,s4
    80003a58:	9e9ff0ef          	jal	80003440 <iunlock>
      return ip;
    80003a5c:	bff1                	j	80003a38 <namex+0x5c>
      iunlockput(ip);
    80003a5e:	8552                	mv	a0,s4
    80003a60:	b3fff0ef          	jal	8000359e <iunlockput>
      return 0;
    80003a64:	8a4a                	mv	s4,s2
    80003a66:	bfc9                	j	80003a38 <namex+0x5c>
  len = path - s;
    80003a68:	40990633          	sub	a2,s2,s1
    80003a6c:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003a70:	09ac5463          	bge	s8,s10,80003af8 <namex+0x11c>
    memmove(name, s, DIRSIZ);
    80003a74:	8666                	mv	a2,s9
    80003a76:	85a6                	mv	a1,s1
    80003a78:	8556                	mv	a0,s5
    80003a7a:	adefd0ef          	jal	80000d58 <memmove>
    80003a7e:	84ca                	mv	s1,s2
  while(*path == '/')
    80003a80:	0004c783          	lbu	a5,0(s1)
    80003a84:	01379763          	bne	a5,s3,80003a92 <namex+0xb6>
    path++;
    80003a88:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003a8a:	0004c783          	lbu	a5,0(s1)
    80003a8e:	ff378de3          	beq	a5,s3,80003a88 <namex+0xac>
    ilock(ip);
    80003a92:	8552                	mv	a0,s4
    80003a94:	8ddff0ef          	jal	80003370 <ilock>
    if(ip->type != T_DIR){
    80003a98:	044a1783          	lh	a5,68(s4)
    80003a9c:	f9779ae3          	bne	a5,s7,80003a30 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80003aa0:	000b0563          	beqz	s6,80003aaa <namex+0xce>
    80003aa4:	0004c783          	lbu	a5,0(s1)
    80003aa8:	d7dd                	beqz	a5,80003a56 <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003aaa:	4601                	li	a2,0
    80003aac:	85d6                	mv	a1,s5
    80003aae:	8552                	mv	a0,s4
    80003ab0:	e81ff0ef          	jal	80003930 <dirlookup>
    80003ab4:	892a                	mv	s2,a0
    80003ab6:	d545                	beqz	a0,80003a5e <namex+0x82>
    iunlockput(ip);
    80003ab8:	8552                	mv	a0,s4
    80003aba:	ae5ff0ef          	jal	8000359e <iunlockput>
    ip = next;
    80003abe:	8a4a                	mv	s4,s2
  while(*path == '/')
    80003ac0:	0004c783          	lbu	a5,0(s1)
    80003ac4:	01379763          	bne	a5,s3,80003ad2 <namex+0xf6>
    path++;
    80003ac8:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003aca:	0004c783          	lbu	a5,0(s1)
    80003ace:	ff378de3          	beq	a5,s3,80003ac8 <namex+0xec>
  if(*path == 0)
    80003ad2:	cf8d                	beqz	a5,80003b0c <namex+0x130>
  while(*path != '/' && *path != 0)
    80003ad4:	0004c783          	lbu	a5,0(s1)
    80003ad8:	fd178713          	addi	a4,a5,-47
    80003adc:	cb19                	beqz	a4,80003af2 <namex+0x116>
    80003ade:	cb91                	beqz	a5,80003af2 <namex+0x116>
    80003ae0:	8926                	mv	s2,s1
    path++;
    80003ae2:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    80003ae4:	00094783          	lbu	a5,0(s2)
    80003ae8:	fd178713          	addi	a4,a5,-47
    80003aec:	df35                	beqz	a4,80003a68 <namex+0x8c>
    80003aee:	fbf5                	bnez	a5,80003ae2 <namex+0x106>
    80003af0:	bfa5                	j	80003a68 <namex+0x8c>
    80003af2:	8926                	mv	s2,s1
  len = path - s;
    80003af4:	4d01                	li	s10,0
    80003af6:	4601                	li	a2,0
    memmove(name, s, len);
    80003af8:	2601                	sext.w	a2,a2
    80003afa:	85a6                	mv	a1,s1
    80003afc:	8556                	mv	a0,s5
    80003afe:	a5afd0ef          	jal	80000d58 <memmove>
    name[len] = 0;
    80003b02:	9d56                	add	s10,s10,s5
    80003b04:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffd06b0>
    80003b08:	84ca                	mv	s1,s2
    80003b0a:	bf9d                	j	80003a80 <namex+0xa4>
  if(nameiparent){
    80003b0c:	f20b06e3          	beqz	s6,80003a38 <namex+0x5c>
    iput(ip);
    80003b10:	8552                	mv	a0,s4
    80003b12:	a03ff0ef          	jal	80003514 <iput>
    return 0;
    80003b16:	4a01                	li	s4,0
    80003b18:	b705                	j	80003a38 <namex+0x5c>

0000000080003b1a <dirlink>:
{
    80003b1a:	715d                	addi	sp,sp,-80
    80003b1c:	e486                	sd	ra,72(sp)
    80003b1e:	e0a2                	sd	s0,64(sp)
    80003b20:	f84a                	sd	s2,48(sp)
    80003b22:	ec56                	sd	s5,24(sp)
    80003b24:	e85a                	sd	s6,16(sp)
    80003b26:	0880                	addi	s0,sp,80
    80003b28:	892a                	mv	s2,a0
    80003b2a:	8aae                	mv	s5,a1
    80003b2c:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003b2e:	4601                	li	a2,0
    80003b30:	e01ff0ef          	jal	80003930 <dirlookup>
    80003b34:	ed1d                	bnez	a0,80003b72 <dirlink+0x58>
    80003b36:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b38:	04c92483          	lw	s1,76(s2)
    80003b3c:	c4b9                	beqz	s1,80003b8a <dirlink+0x70>
    80003b3e:	f44e                	sd	s3,40(sp)
    80003b40:	f052                	sd	s4,32(sp)
    80003b42:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b44:	fb040a13          	addi	s4,s0,-80
    80003b48:	49c1                	li	s3,16
    80003b4a:	874e                	mv	a4,s3
    80003b4c:	86a6                	mv	a3,s1
    80003b4e:	8652                	mv	a2,s4
    80003b50:	4581                	li	a1,0
    80003b52:	854a                	mv	a0,s2
    80003b54:	bd5ff0ef          	jal	80003728 <readi>
    80003b58:	03351163          	bne	a0,s3,80003b7a <dirlink+0x60>
    if(de.inum == 0)
    80003b5c:	fb045783          	lhu	a5,-80(s0)
    80003b60:	c39d                	beqz	a5,80003b86 <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b62:	24c1                	addiw	s1,s1,16
    80003b64:	04c92783          	lw	a5,76(s2)
    80003b68:	fef4e1e3          	bltu	s1,a5,80003b4a <dirlink+0x30>
    80003b6c:	79a2                	ld	s3,40(sp)
    80003b6e:	7a02                	ld	s4,32(sp)
    80003b70:	a829                	j	80003b8a <dirlink+0x70>
    iput(ip);
    80003b72:	9a3ff0ef          	jal	80003514 <iput>
    return -1;
    80003b76:	557d                	li	a0,-1
    80003b78:	a83d                	j	80003bb6 <dirlink+0x9c>
      panic("dirlink read");
    80003b7a:	00005517          	auipc	a0,0x5
    80003b7e:	b0650513          	addi	a0,a0,-1274 # 80008680 <etext+0x680>
    80003b82:	ca3fc0ef          	jal	80000824 <panic>
    80003b86:	79a2                	ld	s3,40(sp)
    80003b88:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003b8a:	4639                	li	a2,14
    80003b8c:	85d6                	mv	a1,s5
    80003b8e:	fb240513          	addi	a0,s0,-78
    80003b92:	a74fd0ef          	jal	80000e06 <strncpy>
  de.inum = inum;
    80003b96:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b9a:	4741                	li	a4,16
    80003b9c:	86a6                	mv	a3,s1
    80003b9e:	fb040613          	addi	a2,s0,-80
    80003ba2:	4581                	li	a1,0
    80003ba4:	854a                	mv	a0,s2
    80003ba6:	c75ff0ef          	jal	8000381a <writei>
    80003baa:	1541                	addi	a0,a0,-16
    80003bac:	00a03533          	snez	a0,a0
    80003bb0:	40a0053b          	negw	a0,a0
    80003bb4:	74e2                	ld	s1,56(sp)
}
    80003bb6:	60a6                	ld	ra,72(sp)
    80003bb8:	6406                	ld	s0,64(sp)
    80003bba:	7942                	ld	s2,48(sp)
    80003bbc:	6ae2                	ld	s5,24(sp)
    80003bbe:	6b42                	ld	s6,16(sp)
    80003bc0:	6161                	addi	sp,sp,80
    80003bc2:	8082                	ret

0000000080003bc4 <namei>:

struct inode*
namei(char *path)
{
    80003bc4:	1101                	addi	sp,sp,-32
    80003bc6:	ec06                	sd	ra,24(sp)
    80003bc8:	e822                	sd	s0,16(sp)
    80003bca:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003bcc:	fe040613          	addi	a2,s0,-32
    80003bd0:	4581                	li	a1,0
    80003bd2:	e0bff0ef          	jal	800039dc <namex>
}
    80003bd6:	60e2                	ld	ra,24(sp)
    80003bd8:	6442                	ld	s0,16(sp)
    80003bda:	6105                	addi	sp,sp,32
    80003bdc:	8082                	ret

0000000080003bde <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003bde:	1141                	addi	sp,sp,-16
    80003be0:	e406                	sd	ra,8(sp)
    80003be2:	e022                	sd	s0,0(sp)
    80003be4:	0800                	addi	s0,sp,16
    80003be6:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003be8:	4585                	li	a1,1
    80003bea:	df3ff0ef          	jal	800039dc <namex>
}
    80003bee:	60a2                	ld	ra,8(sp)
    80003bf0:	6402                	ld	s0,0(sp)
    80003bf2:	0141                	addi	sp,sp,16
    80003bf4:	8082                	ret

0000000080003bf6 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003bf6:	1101                	addi	sp,sp,-32
    80003bf8:	ec06                	sd	ra,24(sp)
    80003bfa:	e822                	sd	s0,16(sp)
    80003bfc:	e426                	sd	s1,8(sp)
    80003bfe:	e04a                	sd	s2,0(sp)
    80003c00:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003c02:	0001e917          	auipc	s2,0x1e
    80003c06:	34690913          	addi	s2,s2,838 # 80021f48 <log>
    80003c0a:	01892583          	lw	a1,24(s2)
    80003c0e:	02492503          	lw	a0,36(s2)
    80003c12:	880ff0ef          	jal	80002c92 <bread>
    80003c16:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003c18:	02892603          	lw	a2,40(s2)
    80003c1c:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003c1e:	00c05f63          	blez	a2,80003c3c <write_head+0x46>
    80003c22:	0001e717          	auipc	a4,0x1e
    80003c26:	35270713          	addi	a4,a4,850 # 80021f74 <log+0x2c>
    80003c2a:	87aa                	mv	a5,a0
    80003c2c:	060a                	slli	a2,a2,0x2
    80003c2e:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003c30:	4314                	lw	a3,0(a4)
    80003c32:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003c34:	0711                	addi	a4,a4,4
    80003c36:	0791                	addi	a5,a5,4
    80003c38:	fec79ce3          	bne	a5,a2,80003c30 <write_head+0x3a>
  }
  bwrite(buf);
    80003c3c:	8526                	mv	a0,s1
    80003c3e:	92aff0ef          	jal	80002d68 <bwrite>
  brelse(buf);
    80003c42:	8526                	mv	a0,s1
    80003c44:	956ff0ef          	jal	80002d9a <brelse>
}
    80003c48:	60e2                	ld	ra,24(sp)
    80003c4a:	6442                	ld	s0,16(sp)
    80003c4c:	64a2                	ld	s1,8(sp)
    80003c4e:	6902                	ld	s2,0(sp)
    80003c50:	6105                	addi	sp,sp,32
    80003c52:	8082                	ret

0000000080003c54 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c54:	0001e797          	auipc	a5,0x1e
    80003c58:	31c7a783          	lw	a5,796(a5) # 80021f70 <log+0x28>
    80003c5c:	0cf05163          	blez	a5,80003d1e <install_trans+0xca>
{
    80003c60:	715d                	addi	sp,sp,-80
    80003c62:	e486                	sd	ra,72(sp)
    80003c64:	e0a2                	sd	s0,64(sp)
    80003c66:	fc26                	sd	s1,56(sp)
    80003c68:	f84a                	sd	s2,48(sp)
    80003c6a:	f44e                	sd	s3,40(sp)
    80003c6c:	f052                	sd	s4,32(sp)
    80003c6e:	ec56                	sd	s5,24(sp)
    80003c70:	e85a                	sd	s6,16(sp)
    80003c72:	e45e                	sd	s7,8(sp)
    80003c74:	e062                	sd	s8,0(sp)
    80003c76:	0880                	addi	s0,sp,80
    80003c78:	8b2a                	mv	s6,a0
    80003c7a:	0001ea97          	auipc	s5,0x1e
    80003c7e:	2faa8a93          	addi	s5,s5,762 # 80021f74 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c82:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003c84:	00005c17          	auipc	s8,0x5
    80003c88:	a0cc0c13          	addi	s8,s8,-1524 # 80008690 <etext+0x690>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003c8c:	0001ea17          	auipc	s4,0x1e
    80003c90:	2bca0a13          	addi	s4,s4,700 # 80021f48 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003c94:	40000b93          	li	s7,1024
    80003c98:	a025                	j	80003cc0 <install_trans+0x6c>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003c9a:	000aa603          	lw	a2,0(s5)
    80003c9e:	85ce                	mv	a1,s3
    80003ca0:	8562                	mv	a0,s8
    80003ca2:	859fc0ef          	jal	800004fa <printf>
    80003ca6:	a839                	j	80003cc4 <install_trans+0x70>
    brelse(lbuf);
    80003ca8:	854a                	mv	a0,s2
    80003caa:	8f0ff0ef          	jal	80002d9a <brelse>
    brelse(dbuf);
    80003cae:	8526                	mv	a0,s1
    80003cb0:	8eaff0ef          	jal	80002d9a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003cb4:	2985                	addiw	s3,s3,1
    80003cb6:	0a91                	addi	s5,s5,4
    80003cb8:	028a2783          	lw	a5,40(s4)
    80003cbc:	04f9d563          	bge	s3,a5,80003d06 <install_trans+0xb2>
    if(recovering) {
    80003cc0:	fc0b1de3          	bnez	s6,80003c9a <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003cc4:	018a2583          	lw	a1,24(s4)
    80003cc8:	013585bb          	addw	a1,a1,s3
    80003ccc:	2585                	addiw	a1,a1,1
    80003cce:	024a2503          	lw	a0,36(s4)
    80003cd2:	fc1fe0ef          	jal	80002c92 <bread>
    80003cd6:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003cd8:	000aa583          	lw	a1,0(s5)
    80003cdc:	024a2503          	lw	a0,36(s4)
    80003ce0:	fb3fe0ef          	jal	80002c92 <bread>
    80003ce4:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003ce6:	865e                	mv	a2,s7
    80003ce8:	05890593          	addi	a1,s2,88
    80003cec:	05850513          	addi	a0,a0,88
    80003cf0:	868fd0ef          	jal	80000d58 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003cf4:	8526                	mv	a0,s1
    80003cf6:	872ff0ef          	jal	80002d68 <bwrite>
    if(recovering == 0)
    80003cfa:	fa0b17e3          	bnez	s6,80003ca8 <install_trans+0x54>
      bunpin(dbuf);
    80003cfe:	8526                	mv	a0,s1
    80003d00:	952ff0ef          	jal	80002e52 <bunpin>
    80003d04:	b755                	j	80003ca8 <install_trans+0x54>
}
    80003d06:	60a6                	ld	ra,72(sp)
    80003d08:	6406                	ld	s0,64(sp)
    80003d0a:	74e2                	ld	s1,56(sp)
    80003d0c:	7942                	ld	s2,48(sp)
    80003d0e:	79a2                	ld	s3,40(sp)
    80003d10:	7a02                	ld	s4,32(sp)
    80003d12:	6ae2                	ld	s5,24(sp)
    80003d14:	6b42                	ld	s6,16(sp)
    80003d16:	6ba2                	ld	s7,8(sp)
    80003d18:	6c02                	ld	s8,0(sp)
    80003d1a:	6161                	addi	sp,sp,80
    80003d1c:	8082                	ret
    80003d1e:	8082                	ret

0000000080003d20 <initlog>:
{
    80003d20:	7179                	addi	sp,sp,-48
    80003d22:	f406                	sd	ra,40(sp)
    80003d24:	f022                	sd	s0,32(sp)
    80003d26:	ec26                	sd	s1,24(sp)
    80003d28:	e84a                	sd	s2,16(sp)
    80003d2a:	e44e                	sd	s3,8(sp)
    80003d2c:	1800                	addi	s0,sp,48
    80003d2e:	84aa                	mv	s1,a0
    80003d30:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003d32:	0001e917          	auipc	s2,0x1e
    80003d36:	21690913          	addi	s2,s2,534 # 80021f48 <log>
    80003d3a:	00005597          	auipc	a1,0x5
    80003d3e:	e0e58593          	addi	a1,a1,-498 # 80008b48 <etext+0xb48>
    80003d42:	854a                	mv	a0,s2
    80003d44:	e5bfc0ef          	jal	80000b9e <initlock>
  log.start = sb->logstart;
    80003d48:	0149a583          	lw	a1,20(s3)
    80003d4c:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003d50:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003d54:	8526                	mv	a0,s1
    80003d56:	f3dfe0ef          	jal	80002c92 <bread>
  log.lh.n = lh->n;
    80003d5a:	4d30                	lw	a2,88(a0)
    80003d5c:	02c92423          	sw	a2,40(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003d60:	00c05f63          	blez	a2,80003d7e <initlog+0x5e>
    80003d64:	87aa                	mv	a5,a0
    80003d66:	0001e717          	auipc	a4,0x1e
    80003d6a:	20e70713          	addi	a4,a4,526 # 80021f74 <log+0x2c>
    80003d6e:	060a                	slli	a2,a2,0x2
    80003d70:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003d72:	4ff4                	lw	a3,92(a5)
    80003d74:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003d76:	0791                	addi	a5,a5,4
    80003d78:	0711                	addi	a4,a4,4
    80003d7a:	fec79ce3          	bne	a5,a2,80003d72 <initlog+0x52>
  brelse(buf);
    80003d7e:	81cff0ef          	jal	80002d9a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003d82:	4505                	li	a0,1
    80003d84:	ed1ff0ef          	jal	80003c54 <install_trans>
  log.lh.n = 0;
    80003d88:	0001e797          	auipc	a5,0x1e
    80003d8c:	1e07a423          	sw	zero,488(a5) # 80021f70 <log+0x28>
  write_head(); // clear the log
    80003d90:	e67ff0ef          	jal	80003bf6 <write_head>
}
    80003d94:	70a2                	ld	ra,40(sp)
    80003d96:	7402                	ld	s0,32(sp)
    80003d98:	64e2                	ld	s1,24(sp)
    80003d9a:	6942                	ld	s2,16(sp)
    80003d9c:	69a2                	ld	s3,8(sp)
    80003d9e:	6145                	addi	sp,sp,48
    80003da0:	8082                	ret

0000000080003da2 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003da2:	1101                	addi	sp,sp,-32
    80003da4:	ec06                	sd	ra,24(sp)
    80003da6:	e822                	sd	s0,16(sp)
    80003da8:	e426                	sd	s1,8(sp)
    80003daa:	e04a                	sd	s2,0(sp)
    80003dac:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003dae:	0001e517          	auipc	a0,0x1e
    80003db2:	19a50513          	addi	a0,a0,410 # 80021f48 <log>
    80003db6:	e73fc0ef          	jal	80000c28 <acquire>
  while(1){
    if(log.committing){
    80003dba:	0001e497          	auipc	s1,0x1e
    80003dbe:	18e48493          	addi	s1,s1,398 # 80021f48 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003dc2:	4979                	li	s2,30
    80003dc4:	a029                	j	80003dce <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003dc6:	85a6                	mv	a1,s1
    80003dc8:	8526                	mv	a0,s1
    80003dca:	9c8fe0ef          	jal	80001f92 <sleep>
    if(log.committing){
    80003dce:	509c                	lw	a5,32(s1)
    80003dd0:	fbfd                	bnez	a5,80003dc6 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003dd2:	4cd8                	lw	a4,28(s1)
    80003dd4:	2705                	addiw	a4,a4,1
    80003dd6:	0027179b          	slliw	a5,a4,0x2
    80003dda:	9fb9                	addw	a5,a5,a4
    80003ddc:	0017979b          	slliw	a5,a5,0x1
    80003de0:	5494                	lw	a3,40(s1)
    80003de2:	9fb5                	addw	a5,a5,a3
    80003de4:	00f95763          	bge	s2,a5,80003df2 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003de8:	85a6                	mv	a1,s1
    80003dea:	8526                	mv	a0,s1
    80003dec:	9a6fe0ef          	jal	80001f92 <sleep>
    80003df0:	bff9                	j	80003dce <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003df2:	0001e797          	auipc	a5,0x1e
    80003df6:	16e7a923          	sw	a4,370(a5) # 80021f64 <log+0x1c>
      release(&log.lock);
    80003dfa:	0001e517          	auipc	a0,0x1e
    80003dfe:	14e50513          	addi	a0,a0,334 # 80021f48 <log>
    80003e02:	ebbfc0ef          	jal	80000cbc <release>
      break;
    }
  }
}
    80003e06:	60e2                	ld	ra,24(sp)
    80003e08:	6442                	ld	s0,16(sp)
    80003e0a:	64a2                	ld	s1,8(sp)
    80003e0c:	6902                	ld	s2,0(sp)
    80003e0e:	6105                	addi	sp,sp,32
    80003e10:	8082                	ret

0000000080003e12 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003e12:	7139                	addi	sp,sp,-64
    80003e14:	fc06                	sd	ra,56(sp)
    80003e16:	f822                	sd	s0,48(sp)
    80003e18:	f426                	sd	s1,40(sp)
    80003e1a:	f04a                	sd	s2,32(sp)
    80003e1c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003e1e:	0001e497          	auipc	s1,0x1e
    80003e22:	12a48493          	addi	s1,s1,298 # 80021f48 <log>
    80003e26:	8526                	mv	a0,s1
    80003e28:	e01fc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    80003e2c:	4cdc                	lw	a5,28(s1)
    80003e2e:	37fd                	addiw	a5,a5,-1
    80003e30:	893e                	mv	s2,a5
    80003e32:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003e34:	509c                	lw	a5,32(s1)
    80003e36:	e7b1                	bnez	a5,80003e82 <end_op+0x70>
    panic("log.committing");
  if(log.outstanding == 0){
    80003e38:	04091e63          	bnez	s2,80003e94 <end_op+0x82>
    do_commit = 1;
    log.committing = 1;
    80003e3c:	0001e497          	auipc	s1,0x1e
    80003e40:	10c48493          	addi	s1,s1,268 # 80021f48 <log>
    80003e44:	4785                	li	a5,1
    80003e46:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003e48:	8526                	mv	a0,s1
    80003e4a:	e73fc0ef          	jal	80000cbc <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003e4e:	549c                	lw	a5,40(s1)
    80003e50:	06f04463          	bgtz	a5,80003eb8 <end_op+0xa6>
    acquire(&log.lock);
    80003e54:	0001e517          	auipc	a0,0x1e
    80003e58:	0f450513          	addi	a0,a0,244 # 80021f48 <log>
    80003e5c:	dcdfc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    80003e60:	0001e797          	auipc	a5,0x1e
    80003e64:	1007a423          	sw	zero,264(a5) # 80021f68 <log+0x20>
    wakeup(&log);
    80003e68:	0001e517          	auipc	a0,0x1e
    80003e6c:	0e050513          	addi	a0,a0,224 # 80021f48 <log>
    80003e70:	96efe0ef          	jal	80001fde <wakeup>
    release(&log.lock);
    80003e74:	0001e517          	auipc	a0,0x1e
    80003e78:	0d450513          	addi	a0,a0,212 # 80021f48 <log>
    80003e7c:	e41fc0ef          	jal	80000cbc <release>
}
    80003e80:	a035                	j	80003eac <end_op+0x9a>
    80003e82:	ec4e                	sd	s3,24(sp)
    80003e84:	e852                	sd	s4,16(sp)
    80003e86:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003e88:	00005517          	auipc	a0,0x5
    80003e8c:	82850513          	addi	a0,a0,-2008 # 800086b0 <etext+0x6b0>
    80003e90:	995fc0ef          	jal	80000824 <panic>
    wakeup(&log);
    80003e94:	0001e517          	auipc	a0,0x1e
    80003e98:	0b450513          	addi	a0,a0,180 # 80021f48 <log>
    80003e9c:	942fe0ef          	jal	80001fde <wakeup>
  release(&log.lock);
    80003ea0:	0001e517          	auipc	a0,0x1e
    80003ea4:	0a850513          	addi	a0,a0,168 # 80021f48 <log>
    80003ea8:	e15fc0ef          	jal	80000cbc <release>
}
    80003eac:	70e2                	ld	ra,56(sp)
    80003eae:	7442                	ld	s0,48(sp)
    80003eb0:	74a2                	ld	s1,40(sp)
    80003eb2:	7902                	ld	s2,32(sp)
    80003eb4:	6121                	addi	sp,sp,64
    80003eb6:	8082                	ret
    80003eb8:	ec4e                	sd	s3,24(sp)
    80003eba:	e852                	sd	s4,16(sp)
    80003ebc:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ebe:	0001ea97          	auipc	s5,0x1e
    80003ec2:	0b6a8a93          	addi	s5,s5,182 # 80021f74 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003ec6:	0001ea17          	auipc	s4,0x1e
    80003eca:	082a0a13          	addi	s4,s4,130 # 80021f48 <log>
    80003ece:	018a2583          	lw	a1,24(s4)
    80003ed2:	012585bb          	addw	a1,a1,s2
    80003ed6:	2585                	addiw	a1,a1,1
    80003ed8:	024a2503          	lw	a0,36(s4)
    80003edc:	db7fe0ef          	jal	80002c92 <bread>
    80003ee0:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003ee2:	000aa583          	lw	a1,0(s5)
    80003ee6:	024a2503          	lw	a0,36(s4)
    80003eea:	da9fe0ef          	jal	80002c92 <bread>
    80003eee:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003ef0:	40000613          	li	a2,1024
    80003ef4:	05850593          	addi	a1,a0,88
    80003ef8:	05848513          	addi	a0,s1,88
    80003efc:	e5dfc0ef          	jal	80000d58 <memmove>
    bwrite(to);  // write the log
    80003f00:	8526                	mv	a0,s1
    80003f02:	e67fe0ef          	jal	80002d68 <bwrite>
    brelse(from);
    80003f06:	854e                	mv	a0,s3
    80003f08:	e93fe0ef          	jal	80002d9a <brelse>
    brelse(to);
    80003f0c:	8526                	mv	a0,s1
    80003f0e:	e8dfe0ef          	jal	80002d9a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f12:	2905                	addiw	s2,s2,1
    80003f14:	0a91                	addi	s5,s5,4
    80003f16:	028a2783          	lw	a5,40(s4)
    80003f1a:	faf94ae3          	blt	s2,a5,80003ece <end_op+0xbc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003f1e:	cd9ff0ef          	jal	80003bf6 <write_head>
    install_trans(0); // Now install writes to home locations
    80003f22:	4501                	li	a0,0
    80003f24:	d31ff0ef          	jal	80003c54 <install_trans>
    log.lh.n = 0;
    80003f28:	0001e797          	auipc	a5,0x1e
    80003f2c:	0407a423          	sw	zero,72(a5) # 80021f70 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003f30:	cc7ff0ef          	jal	80003bf6 <write_head>
    80003f34:	69e2                	ld	s3,24(sp)
    80003f36:	6a42                	ld	s4,16(sp)
    80003f38:	6aa2                	ld	s5,8(sp)
    80003f3a:	bf29                	j	80003e54 <end_op+0x42>

0000000080003f3c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003f3c:	1101                	addi	sp,sp,-32
    80003f3e:	ec06                	sd	ra,24(sp)
    80003f40:	e822                	sd	s0,16(sp)
    80003f42:	e426                	sd	s1,8(sp)
    80003f44:	1000                	addi	s0,sp,32
    80003f46:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003f48:	0001e517          	auipc	a0,0x1e
    80003f4c:	00050513          	mv	a0,a0
    80003f50:	cd9fc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003f54:	0001e617          	auipc	a2,0x1e
    80003f58:	01c62603          	lw	a2,28(a2) # 80021f70 <log+0x28>
    80003f5c:	47f5                	li	a5,29
    80003f5e:	04c7cd63          	blt	a5,a2,80003fb8 <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003f62:	0001e797          	auipc	a5,0x1e
    80003f66:	0027a783          	lw	a5,2(a5) # 80021f64 <log+0x1c>
    80003f6a:	04f05d63          	blez	a5,80003fc4 <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003f6e:	4781                	li	a5,0
    80003f70:	06c05063          	blez	a2,80003fd0 <log_write+0x94>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003f74:	44cc                	lw	a1,12(s1)
    80003f76:	0001e717          	auipc	a4,0x1e
    80003f7a:	ffe70713          	addi	a4,a4,-2 # 80021f74 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003f7e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003f80:	4314                	lw	a3,0(a4)
    80003f82:	04b68763          	beq	a3,a1,80003fd0 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80003f86:	2785                	addiw	a5,a5,1
    80003f88:	0711                	addi	a4,a4,4
    80003f8a:	fef61be3          	bne	a2,a5,80003f80 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003f8e:	060a                	slli	a2,a2,0x2
    80003f90:	02060613          	addi	a2,a2,32
    80003f94:	0001e797          	auipc	a5,0x1e
    80003f98:	fb478793          	addi	a5,a5,-76 # 80021f48 <log>
    80003f9c:	97b2                	add	a5,a5,a2
    80003f9e:	44d8                	lw	a4,12(s1)
    80003fa0:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003fa2:	8526                	mv	a0,s1
    80003fa4:	e7bfe0ef          	jal	80002e1e <bpin>
    log.lh.n++;
    80003fa8:	0001e717          	auipc	a4,0x1e
    80003fac:	fa070713          	addi	a4,a4,-96 # 80021f48 <log>
    80003fb0:	571c                	lw	a5,40(a4)
    80003fb2:	2785                	addiw	a5,a5,1
    80003fb4:	d71c                	sw	a5,40(a4)
    80003fb6:	a815                	j	80003fea <log_write+0xae>
    panic("too big a transaction");
    80003fb8:	00004517          	auipc	a0,0x4
    80003fbc:	70850513          	addi	a0,a0,1800 # 800086c0 <etext+0x6c0>
    80003fc0:	865fc0ef          	jal	80000824 <panic>
    panic("log_write outside of trans");
    80003fc4:	00004517          	auipc	a0,0x4
    80003fc8:	71450513          	addi	a0,a0,1812 # 800086d8 <etext+0x6d8>
    80003fcc:	859fc0ef          	jal	80000824 <panic>
  log.lh.block[i] = b->blockno;
    80003fd0:	00279693          	slli	a3,a5,0x2
    80003fd4:	02068693          	addi	a3,a3,32
    80003fd8:	0001e717          	auipc	a4,0x1e
    80003fdc:	f7070713          	addi	a4,a4,-144 # 80021f48 <log>
    80003fe0:	9736                	add	a4,a4,a3
    80003fe2:	44d4                	lw	a3,12(s1)
    80003fe4:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003fe6:	faf60ee3          	beq	a2,a5,80003fa2 <log_write+0x66>
  }
  release(&log.lock);
    80003fea:	0001e517          	auipc	a0,0x1e
    80003fee:	f5e50513          	addi	a0,a0,-162 # 80021f48 <log>
    80003ff2:	ccbfc0ef          	jal	80000cbc <release>
}
    80003ff6:	60e2                	ld	ra,24(sp)
    80003ff8:	6442                	ld	s0,16(sp)
    80003ffa:	64a2                	ld	s1,8(sp)
    80003ffc:	6105                	addi	sp,sp,32
    80003ffe:	8082                	ret

0000000080004000 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004000:	1101                	addi	sp,sp,-32
    80004002:	ec06                	sd	ra,24(sp)
    80004004:	e822                	sd	s0,16(sp)
    80004006:	e426                	sd	s1,8(sp)
    80004008:	e04a                	sd	s2,0(sp)
    8000400a:	1000                	addi	s0,sp,32
    8000400c:	84aa                	mv	s1,a0
    8000400e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004010:	00004597          	auipc	a1,0x4
    80004014:	6e858593          	addi	a1,a1,1768 # 800086f8 <etext+0x6f8>
    80004018:	0521                	addi	a0,a0,8
    8000401a:	b85fc0ef          	jal	80000b9e <initlock>
  lk->name = name;
    8000401e:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004022:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004026:	0204a423          	sw	zero,40(s1)
}
    8000402a:	60e2                	ld	ra,24(sp)
    8000402c:	6442                	ld	s0,16(sp)
    8000402e:	64a2                	ld	s1,8(sp)
    80004030:	6902                	ld	s2,0(sp)
    80004032:	6105                	addi	sp,sp,32
    80004034:	8082                	ret

0000000080004036 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004036:	1101                	addi	sp,sp,-32
    80004038:	ec06                	sd	ra,24(sp)
    8000403a:	e822                	sd	s0,16(sp)
    8000403c:	e426                	sd	s1,8(sp)
    8000403e:	e04a                	sd	s2,0(sp)
    80004040:	1000                	addi	s0,sp,32
    80004042:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004044:	00850913          	addi	s2,a0,8
    80004048:	854a                	mv	a0,s2
    8000404a:	bdffc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    8000404e:	409c                	lw	a5,0(s1)
    80004050:	c799                	beqz	a5,8000405e <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004052:	85ca                	mv	a1,s2
    80004054:	8526                	mv	a0,s1
    80004056:	f3dfd0ef          	jal	80001f92 <sleep>
  while (lk->locked) {
    8000405a:	409c                	lw	a5,0(s1)
    8000405c:	fbfd                	bnez	a5,80004052 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    8000405e:	4785                	li	a5,1
    80004060:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004062:	8d5fd0ef          	jal	80001936 <myproc>
    80004066:	591c                	lw	a5,48(a0)
    80004068:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000406a:	854a                	mv	a0,s2
    8000406c:	c51fc0ef          	jal	80000cbc <release>
}
    80004070:	60e2                	ld	ra,24(sp)
    80004072:	6442                	ld	s0,16(sp)
    80004074:	64a2                	ld	s1,8(sp)
    80004076:	6902                	ld	s2,0(sp)
    80004078:	6105                	addi	sp,sp,32
    8000407a:	8082                	ret

000000008000407c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000407c:	1101                	addi	sp,sp,-32
    8000407e:	ec06                	sd	ra,24(sp)
    80004080:	e822                	sd	s0,16(sp)
    80004082:	e426                	sd	s1,8(sp)
    80004084:	e04a                	sd	s2,0(sp)
    80004086:	1000                	addi	s0,sp,32
    80004088:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000408a:	00850913          	addi	s2,a0,8
    8000408e:	854a                	mv	a0,s2
    80004090:	b99fc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    80004094:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004098:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000409c:	8526                	mv	a0,s1
    8000409e:	f41fd0ef          	jal	80001fde <wakeup>
  release(&lk->lk);
    800040a2:	854a                	mv	a0,s2
    800040a4:	c19fc0ef          	jal	80000cbc <release>
}
    800040a8:	60e2                	ld	ra,24(sp)
    800040aa:	6442                	ld	s0,16(sp)
    800040ac:	64a2                	ld	s1,8(sp)
    800040ae:	6902                	ld	s2,0(sp)
    800040b0:	6105                	addi	sp,sp,32
    800040b2:	8082                	ret

00000000800040b4 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800040b4:	7179                	addi	sp,sp,-48
    800040b6:	f406                	sd	ra,40(sp)
    800040b8:	f022                	sd	s0,32(sp)
    800040ba:	ec26                	sd	s1,24(sp)
    800040bc:	e84a                	sd	s2,16(sp)
    800040be:	1800                	addi	s0,sp,48
    800040c0:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800040c2:	00850913          	addi	s2,a0,8
    800040c6:	854a                	mv	a0,s2
    800040c8:	b61fc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800040cc:	409c                	lw	a5,0(s1)
    800040ce:	ef81                	bnez	a5,800040e6 <holdingsleep+0x32>
    800040d0:	4481                	li	s1,0
  release(&lk->lk);
    800040d2:	854a                	mv	a0,s2
    800040d4:	be9fc0ef          	jal	80000cbc <release>
  return r;
}
    800040d8:	8526                	mv	a0,s1
    800040da:	70a2                	ld	ra,40(sp)
    800040dc:	7402                	ld	s0,32(sp)
    800040de:	64e2                	ld	s1,24(sp)
    800040e0:	6942                	ld	s2,16(sp)
    800040e2:	6145                	addi	sp,sp,48
    800040e4:	8082                	ret
    800040e6:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800040e8:	0284a983          	lw	s3,40(s1)
    800040ec:	84bfd0ef          	jal	80001936 <myproc>
    800040f0:	5904                	lw	s1,48(a0)
    800040f2:	413484b3          	sub	s1,s1,s3
    800040f6:	0014b493          	seqz	s1,s1
    800040fa:	69a2                	ld	s3,8(sp)
    800040fc:	bfd9                	j	800040d2 <holdingsleep+0x1e>

00000000800040fe <check_permission>:
// fileread, filewrite, sys_open — single point of truth
// means a single fix if a vulnerability is found
// =============================================================
int
check_permission(struct inode *ip, int access_mode, int caller_uid, int caller_gid)
{
    800040fe:	1141                	addi	sp,sp,-16
    80004100:	e406                	sd	ra,8(sp)
    80004102:	e022                	sd	s0,0(sp)
    80004104:	0800                	addi	s0,sp,16
    // ADMIN (uid=0) bypasses all permission checks
    // WHY: ADMIN must be able to recover the system; this matches
    // Linux's CAP_DAC_OVERRIDE capability
    if (caller_uid == ROLE_ADMIN)
    80004106:	ca39                	beqz	a2,8000415c <check_permission+0x5e>
        return 0;

    uint perm_bits;

    if (caller_uid == (int)ip->uid) {
    80004108:	08852783          	lw	a5,136(a0)
    8000410c:	02c78c63          	beq	a5,a2,80004144 <check_permission+0x46>
        // Caller is the owner
        perm_bits = (ip->mode >> 6) & 0x7;  // Owner bits
    } else if (caller_gid == (int)ip->gid) {
    80004110:	08c52783          	lw	a5,140(a0)
    80004114:	02d78e63          	beq	a5,a3,80004150 <check_permission+0x52>
        // Caller's group matches file's group
        perm_bits = (ip->mode >> 3) & 0x7;  // Group bits
    } else {
        // Everyone else
        perm_bits = ip->mode & 0x7;          // Other bits
    80004118:	08452783          	lw	a5,132(a0)
    8000411c:	8b9d                	andi	a5,a5,7
    }

    // access_mode: 1=read, 2=write, 4=execute (can be ORed)
    if ((access_mode & 1) && !(perm_bits & 4)) return -1;  // Need read, no read bit
    8000411e:	0015f713          	andi	a4,a1,1
    80004122:	c701                	beqz	a4,8000412a <check_permission+0x2c>
    80004124:	0047f713          	andi	a4,a5,4
    80004128:	cf1d                	beqz	a4,80004166 <check_permission+0x68>
    if ((access_mode & 2) && !(perm_bits & 2)) return -1;  // Need write, no write bit
    8000412a:	0025f713          	andi	a4,a1,2
    8000412e:	c701                	beqz	a4,80004136 <check_permission+0x38>
    80004130:	0027f713          	andi	a4,a5,2
    80004134:	cb1d                	beqz	a4,8000416a <check_permission+0x6c>
    if ((access_mode & 4) && !(perm_bits & 1)) return -1;  // Need exec, no exec bit
    80004136:	0045f513          	andi	a0,a1,4
    8000413a:	c115                	beqz	a0,8000415e <check_permission+0x60>
    8000413c:	8b85                	andi	a5,a5,1
    8000413e:	fff7851b          	addiw	a0,a5,-1
    80004142:	a831                	j	8000415e <check_permission+0x60>
        perm_bits = (ip->mode >> 6) & 0x7;  // Owner bits
    80004144:	08452783          	lw	a5,132(a0)
    80004148:	0067d79b          	srliw	a5,a5,0x6
    8000414c:	8b9d                	andi	a5,a5,7
    8000414e:	bfc1                	j	8000411e <check_permission+0x20>
        perm_bits = (ip->mode >> 3) & 0x7;  // Group bits
    80004150:	08452783          	lw	a5,132(a0)
    80004154:	0037d79b          	srliw	a5,a5,0x3
    80004158:	8b9d                	andi	a5,a5,7
    8000415a:	b7d1                	j	8000411e <check_permission+0x20>
        return 0;
    8000415c:	8532                	mv	a0,a2

    return 0;  // Permitted
}
    8000415e:	60a2                	ld	ra,8(sp)
    80004160:	6402                	ld	s0,0(sp)
    80004162:	0141                	addi	sp,sp,16
    80004164:	8082                	ret
    if ((access_mode & 1) && !(perm_bits & 4)) return -1;  // Need read, no read bit
    80004166:	557d                	li	a0,-1
    80004168:	bfdd                	j	8000415e <check_permission+0x60>
    if ((access_mode & 2) && !(perm_bits & 2)) return -1;  // Need write, no write bit
    8000416a:	557d                	li	a0,-1
    8000416c:	bfcd                	j	8000415e <check_permission+0x60>

000000008000416e <fileinit>:

void
fileinit(void)
{
    8000416e:	1141                	addi	sp,sp,-16
    80004170:	e406                	sd	ra,8(sp)
    80004172:	e022                	sd	s0,0(sp)
    80004174:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004176:	00004597          	auipc	a1,0x4
    8000417a:	59258593          	addi	a1,a1,1426 # 80008708 <etext+0x708>
    8000417e:	0001e517          	auipc	a0,0x1e
    80004182:	f1250513          	addi	a0,a0,-238 # 80022090 <ftable>
    80004186:	a19fc0ef          	jal	80000b9e <initlock>
}
    8000418a:	60a2                	ld	ra,8(sp)
    8000418c:	6402                	ld	s0,0(sp)
    8000418e:	0141                	addi	sp,sp,16
    80004190:	8082                	ret

0000000080004192 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004192:	1101                	addi	sp,sp,-32
    80004194:	ec06                	sd	ra,24(sp)
    80004196:	e822                	sd	s0,16(sp)
    80004198:	e426                	sd	s1,8(sp)
    8000419a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000419c:	0001e517          	auipc	a0,0x1e
    800041a0:	ef450513          	addi	a0,a0,-268 # 80022090 <ftable>
    800041a4:	a85fc0ef          	jal	80000c28 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800041a8:	0001e497          	auipc	s1,0x1e
    800041ac:	f0048493          	addi	s1,s1,-256 # 800220a8 <ftable+0x18>
    800041b0:	0001f717          	auipc	a4,0x1f
    800041b4:	e9870713          	addi	a4,a4,-360 # 80023048 <disk>
    if(f->ref == 0){
    800041b8:	40dc                	lw	a5,4(s1)
    800041ba:	cf89                	beqz	a5,800041d4 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800041bc:	02848493          	addi	s1,s1,40
    800041c0:	fee49ce3          	bne	s1,a4,800041b8 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800041c4:	0001e517          	auipc	a0,0x1e
    800041c8:	ecc50513          	addi	a0,a0,-308 # 80022090 <ftable>
    800041cc:	af1fc0ef          	jal	80000cbc <release>
  return 0;
    800041d0:	4481                	li	s1,0
    800041d2:	a809                	j	800041e4 <filealloc+0x52>
      f->ref = 1;
    800041d4:	4785                	li	a5,1
    800041d6:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800041d8:	0001e517          	auipc	a0,0x1e
    800041dc:	eb850513          	addi	a0,a0,-328 # 80022090 <ftable>
    800041e0:	addfc0ef          	jal	80000cbc <release>
}
    800041e4:	8526                	mv	a0,s1
    800041e6:	60e2                	ld	ra,24(sp)
    800041e8:	6442                	ld	s0,16(sp)
    800041ea:	64a2                	ld	s1,8(sp)
    800041ec:	6105                	addi	sp,sp,32
    800041ee:	8082                	ret

00000000800041f0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800041f0:	1101                	addi	sp,sp,-32
    800041f2:	ec06                	sd	ra,24(sp)
    800041f4:	e822                	sd	s0,16(sp)
    800041f6:	e426                	sd	s1,8(sp)
    800041f8:	1000                	addi	s0,sp,32
    800041fa:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800041fc:	0001e517          	auipc	a0,0x1e
    80004200:	e9450513          	addi	a0,a0,-364 # 80022090 <ftable>
    80004204:	a25fc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    80004208:	40dc                	lw	a5,4(s1)
    8000420a:	02f05063          	blez	a5,8000422a <filedup+0x3a>
    panic("filedup");
  f->ref++;
    8000420e:	2785                	addiw	a5,a5,1
    80004210:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004212:	0001e517          	auipc	a0,0x1e
    80004216:	e7e50513          	addi	a0,a0,-386 # 80022090 <ftable>
    8000421a:	aa3fc0ef          	jal	80000cbc <release>
  return f;
}
    8000421e:	8526                	mv	a0,s1
    80004220:	60e2                	ld	ra,24(sp)
    80004222:	6442                	ld	s0,16(sp)
    80004224:	64a2                	ld	s1,8(sp)
    80004226:	6105                	addi	sp,sp,32
    80004228:	8082                	ret
    panic("filedup");
    8000422a:	00004517          	auipc	a0,0x4
    8000422e:	4e650513          	addi	a0,a0,1254 # 80008710 <etext+0x710>
    80004232:	df2fc0ef          	jal	80000824 <panic>

0000000080004236 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004236:	7139                	addi	sp,sp,-64
    80004238:	fc06                	sd	ra,56(sp)
    8000423a:	f822                	sd	s0,48(sp)
    8000423c:	f426                	sd	s1,40(sp)
    8000423e:	0080                	addi	s0,sp,64
    80004240:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004242:	0001e517          	auipc	a0,0x1e
    80004246:	e4e50513          	addi	a0,a0,-434 # 80022090 <ftable>
    8000424a:	9dffc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    8000424e:	40dc                	lw	a5,4(s1)
    80004250:	04f05a63          	blez	a5,800042a4 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80004254:	37fd                	addiw	a5,a5,-1
    80004256:	c0dc                	sw	a5,4(s1)
    80004258:	06f04063          	bgtz	a5,800042b8 <fileclose+0x82>
    8000425c:	f04a                	sd	s2,32(sp)
    8000425e:	ec4e                	sd	s3,24(sp)
    80004260:	e852                	sd	s4,16(sp)
    80004262:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004264:	0004a903          	lw	s2,0(s1)
    80004268:	0094c783          	lbu	a5,9(s1)
    8000426c:	89be                	mv	s3,a5
    8000426e:	689c                	ld	a5,16(s1)
    80004270:	8a3e                	mv	s4,a5
    80004272:	6c9c                	ld	a5,24(s1)
    80004274:	8abe                	mv	s5,a5
  f->ref = 0;
    80004276:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000427a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000427e:	0001e517          	auipc	a0,0x1e
    80004282:	e1250513          	addi	a0,a0,-494 # 80022090 <ftable>
    80004286:	a37fc0ef          	jal	80000cbc <release>

  if(ff.type == FD_PIPE){
    8000428a:	4785                	li	a5,1
    8000428c:	04f90163          	beq	s2,a5,800042ce <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004290:	ffe9079b          	addiw	a5,s2,-2
    80004294:	4705                	li	a4,1
    80004296:	04f77563          	bgeu	a4,a5,800042e0 <fileclose+0xaa>
    8000429a:	7902                	ld	s2,32(sp)
    8000429c:	69e2                	ld	s3,24(sp)
    8000429e:	6a42                	ld	s4,16(sp)
    800042a0:	6aa2                	ld	s5,8(sp)
    800042a2:	a00d                	j	800042c4 <fileclose+0x8e>
    800042a4:	f04a                	sd	s2,32(sp)
    800042a6:	ec4e                	sd	s3,24(sp)
    800042a8:	e852                	sd	s4,16(sp)
    800042aa:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800042ac:	00004517          	auipc	a0,0x4
    800042b0:	46c50513          	addi	a0,a0,1132 # 80008718 <etext+0x718>
    800042b4:	d70fc0ef          	jal	80000824 <panic>
    release(&ftable.lock);
    800042b8:	0001e517          	auipc	a0,0x1e
    800042bc:	dd850513          	addi	a0,a0,-552 # 80022090 <ftable>
    800042c0:	9fdfc0ef          	jal	80000cbc <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800042c4:	70e2                	ld	ra,56(sp)
    800042c6:	7442                	ld	s0,48(sp)
    800042c8:	74a2                	ld	s1,40(sp)
    800042ca:	6121                	addi	sp,sp,64
    800042cc:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800042ce:	85ce                	mv	a1,s3
    800042d0:	8552                	mv	a0,s4
    800042d2:	40a000ef          	jal	800046dc <pipeclose>
    800042d6:	7902                	ld	s2,32(sp)
    800042d8:	69e2                	ld	s3,24(sp)
    800042da:	6a42                	ld	s4,16(sp)
    800042dc:	6aa2                	ld	s5,8(sp)
    800042de:	b7dd                	j	800042c4 <fileclose+0x8e>
    begin_op();
    800042e0:	ac3ff0ef          	jal	80003da2 <begin_op>
    iput(ff.ip);
    800042e4:	8556                	mv	a0,s5
    800042e6:	a2eff0ef          	jal	80003514 <iput>
    end_op();
    800042ea:	b29ff0ef          	jal	80003e12 <end_op>
    800042ee:	7902                	ld	s2,32(sp)
    800042f0:	69e2                	ld	s3,24(sp)
    800042f2:	6a42                	ld	s4,16(sp)
    800042f4:	6aa2                	ld	s5,8(sp)
    800042f6:	b7f9                	j	800042c4 <fileclose+0x8e>

00000000800042f8 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800042f8:	715d                	addi	sp,sp,-80
    800042fa:	e486                	sd	ra,72(sp)
    800042fc:	e0a2                	sd	s0,64(sp)
    800042fe:	fc26                	sd	s1,56(sp)
    80004300:	f052                	sd	s4,32(sp)
    80004302:	0880                	addi	s0,sp,80
    80004304:	84aa                	mv	s1,a0
    80004306:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    80004308:	e2efd0ef          	jal	80001936 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000430c:	409c                	lw	a5,0(s1)
    8000430e:	37f9                	addiw	a5,a5,-2
    80004310:	4705                	li	a4,1
    80004312:	04f76263          	bltu	a4,a5,80004356 <filestat+0x5e>
    80004316:	f84a                	sd	s2,48(sp)
    80004318:	f44e                	sd	s3,40(sp)
    8000431a:	89aa                	mv	s3,a0
    ilock(f->ip);
    8000431c:	6c88                	ld	a0,24(s1)
    8000431e:	852ff0ef          	jal	80003370 <ilock>
    stati(f->ip, &st);
    80004322:	fb840913          	addi	s2,s0,-72
    80004326:	85ca                	mv	a1,s2
    80004328:	6c88                	ld	a0,24(s1)
    8000432a:	bd0ff0ef          	jal	800036fa <stati>
    iunlock(f->ip);
    8000432e:	6c88                	ld	a0,24(s1)
    80004330:	910ff0ef          	jal	80003440 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004334:	46e1                	li	a3,24
    80004336:	864a                	mv	a2,s2
    80004338:	85d2                	mv	a1,s4
    8000433a:	0509b503          	ld	a0,80(s3)
    8000433e:	b1efd0ef          	jal	8000165c <copyout>
    80004342:	41f5551b          	sraiw	a0,a0,0x1f
    80004346:	7942                	ld	s2,48(sp)
    80004348:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    8000434a:	60a6                	ld	ra,72(sp)
    8000434c:	6406                	ld	s0,64(sp)
    8000434e:	74e2                	ld	s1,56(sp)
    80004350:	7a02                	ld	s4,32(sp)
    80004352:	6161                	addi	sp,sp,80
    80004354:	8082                	ret
  return -1;
    80004356:	557d                	li	a0,-1
    80004358:	bfcd                	j	8000434a <filestat+0x52>

000000008000435a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000435a:	7139                	addi	sp,sp,-64
    8000435c:	fc06                	sd	ra,56(sp)
    8000435e:	f822                	sd	s0,48(sp)
    80004360:	f426                	sd	s1,40(sp)
    80004362:	f04a                	sd	s2,32(sp)
    80004364:	ec4e                	sd	s3,24(sp)
    80004366:	0080                	addi	s0,sp,64
    80004368:	84aa                	mv	s1,a0
    8000436a:	892e                	mv	s2,a1
    8000436c:	89b2                	mv	s3,a2
  int r = 0;
  struct proc *p = myproc();
    8000436e:	dc8fd0ef          	jal	80001936 <myproc>

  if(f->readable == 0)
    80004372:	0084c783          	lbu	a5,8(s1)
    80004376:	0e078b63          	beqz	a5,8000446c <fileread+0x112>
    8000437a:	e852                	sd	s4,16(sp)
    8000437c:	8a2a                	mv	s4,a0
    return -1;

  // === NEW: PERMISSION CHECK (Ring 0 enforcement) ===
  if (f->type == FD_INODE) {
    8000437e:	4098                	lw	a4,0(s1)
    80004380:	4789                	li	a5,2
    80004382:	04f70863          	beq	a4,a5,800043d2 <fileread+0x78>
      return -1;
    }
    iunlock(f->ip);
  }

  if(f->type == FD_PIPE){
    80004386:	409c                	lw	a5,0(s1)
    80004388:	4705                	li	a4,1
    8000438a:	08e78b63          	beq	a5,a4,80004420 <fileread+0xc6>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000438e:	470d                	li	a4,3
    80004390:	0ae78063          	beq	a5,a4,80004430 <fileread+0xd6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004394:	4709                	li	a4,2
    80004396:	0ce79463          	bne	a5,a4,8000445e <fileread+0x104>
    ilock(f->ip);
    8000439a:	6c88                	ld	a0,24(s1)
    8000439c:	fd5fe0ef          	jal	80003370 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800043a0:	874e                	mv	a4,s3
    800043a2:	5094                	lw	a3,32(s1)
    800043a4:	864a                	mv	a2,s2
    800043a6:	4585                	li	a1,1
    800043a8:	6c88                	ld	a0,24(s1)
    800043aa:	b7eff0ef          	jal	80003728 <readi>
    800043ae:	892a                	mv	s2,a0
    800043b0:	00a05563          	blez	a0,800043ba <fileread+0x60>
      f->off += r;
    800043b4:	509c                	lw	a5,32(s1)
    800043b6:	9fa9                	addw	a5,a5,a0
    800043b8:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800043ba:	6c88                	ld	a0,24(s1)
    800043bc:	884ff0ef          	jal	80003440 <iunlock>
    800043c0:	6a42                	ld	s4,16(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800043c2:	854a                	mv	a0,s2
    800043c4:	70e2                	ld	ra,56(sp)
    800043c6:	7442                	ld	s0,48(sp)
    800043c8:	74a2                	ld	s1,40(sp)
    800043ca:	7902                	ld	s2,32(sp)
    800043cc:	69e2                	ld	s3,24(sp)
    800043ce:	6121                	addi	sp,sp,64
    800043d0:	8082                	ret
    800043d2:	e456                	sd	s5,8(sp)
    ilock(f->ip);
    800043d4:	6c88                	ld	a0,24(s1)
    800043d6:	f9bfe0ef          	jal	80003370 <ilock>
    if (check_permission(f->ip, 1 /*read*/, p->creds.uid, p->creds.gid) < 0) {
    800043da:	6c88                	ld	a0,24(s1)
    800043dc:	8aaa                	mv	s5,a0
    800043de:	16ca2683          	lw	a3,364(s4)
    800043e2:	168a2603          	lw	a2,360(s4)
    800043e6:	4585                	li	a1,1
    800043e8:	d17ff0ef          	jal	800040fe <check_permission>
    800043ec:	00054763          	bltz	a0,800043fa <fileread+0xa0>
    iunlock(f->ip);
    800043f0:	8556                	mv	a0,s5
    800043f2:	84eff0ef          	jal	80003440 <iunlock>
    800043f6:	6aa2                	ld	s5,8(sp)
    800043f8:	b779                	j	80004386 <fileread+0x2c>
      iunlock(f->ip);
    800043fa:	8556                	mv	a0,s5
    800043fc:	844ff0ef          	jal	80003440 <iunlock>
      audit_log_event(p->pid, p->creds.uid, SYS_read, "DENIED:read_permission");
    80004400:	00004697          	auipc	a3,0x4
    80004404:	32868693          	addi	a3,a3,808 # 80008728 <etext+0x728>
    80004408:	4615                	li	a2,5
    8000440a:	168a2583          	lw	a1,360(s4)
    8000440e:	030a2503          	lw	a0,48(s4)
    80004412:	398020ef          	jal	800067aa <audit_log_event>
      return -1;
    80004416:	57fd                	li	a5,-1
    80004418:	893e                	mv	s2,a5
    8000441a:	6a42                	ld	s4,16(sp)
    8000441c:	6aa2                	ld	s5,8(sp)
    8000441e:	b755                	j	800043c2 <fileread+0x68>
    r = piperead(f->pipe, addr, n);
    80004420:	864e                	mv	a2,s3
    80004422:	85ca                	mv	a1,s2
    80004424:	6888                	ld	a0,16(s1)
    80004426:	40c000ef          	jal	80004832 <piperead>
    8000442a:	892a                	mv	s2,a0
    8000442c:	6a42                	ld	s4,16(sp)
    8000442e:	bf51                	j	800043c2 <fileread+0x68>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004430:	02449783          	lh	a5,36(s1)
    80004434:	03079693          	slli	a3,a5,0x30
    80004438:	92c1                	srli	a3,a3,0x30
    8000443a:	4725                	li	a4,9
    8000443c:	02d76b63          	bltu	a4,a3,80004472 <fileread+0x118>
    80004440:	0792                	slli	a5,a5,0x4
    80004442:	0001e717          	auipc	a4,0x1e
    80004446:	bae70713          	addi	a4,a4,-1106 # 80021ff0 <devsw>
    8000444a:	97ba                	add	a5,a5,a4
    8000444c:	639c                	ld	a5,0(a5)
    8000444e:	c795                	beqz	a5,8000447a <fileread+0x120>
    r = devsw[f->major].read(1, addr, n);
    80004450:	864e                	mv	a2,s3
    80004452:	85ca                	mv	a1,s2
    80004454:	4505                	li	a0,1
    80004456:	9782                	jalr	a5
    80004458:	892a                	mv	s2,a0
    8000445a:	6a42                	ld	s4,16(sp)
    8000445c:	b79d                	j	800043c2 <fileread+0x68>
    8000445e:	e456                	sd	s5,8(sp)
    panic("fileread");
    80004460:	00004517          	auipc	a0,0x4
    80004464:	2e050513          	addi	a0,a0,736 # 80008740 <etext+0x740>
    80004468:	bbcfc0ef          	jal	80000824 <panic>
    return -1;
    8000446c:	57fd                	li	a5,-1
    8000446e:	893e                	mv	s2,a5
    80004470:	bf89                	j	800043c2 <fileread+0x68>
      return -1;
    80004472:	57fd                	li	a5,-1
    80004474:	893e                	mv	s2,a5
    80004476:	6a42                	ld	s4,16(sp)
    80004478:	b7a9                	j	800043c2 <fileread+0x68>
    8000447a:	57fd                	li	a5,-1
    8000447c:	893e                	mv	s2,a5
    8000447e:	6a42                	ld	s4,16(sp)
    80004480:	b789                	j	800043c2 <fileread+0x68>

0000000080004482 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004482:	711d                	addi	sp,sp,-96
    80004484:	ec86                	sd	ra,88(sp)
    80004486:	e8a2                	sd	s0,80(sp)
    80004488:	e4a6                	sd	s1,72(sp)
    8000448a:	f456                	sd	s5,40(sp)
    8000448c:	f05a                	sd	s6,32(sp)
    8000448e:	1080                	addi	s0,sp,96
    80004490:	84aa                	mv	s1,a0
    80004492:	8b2e                	mv	s6,a1
    80004494:	8ab2                	mv	s5,a2
  int r, ret = 0;
  struct proc *p = myproc();
    80004496:	ca0fd0ef          	jal	80001936 <myproc>

  if(f->writable == 0)
    8000449a:	0094c783          	lbu	a5,9(s1)
    8000449e:	14078f63          	beqz	a5,800045fc <filewrite+0x17a>
    800044a2:	e0ca                	sd	s2,64(sp)
    800044a4:	892a                	mv	s2,a0
    return -1;

  // === NEW: PERMISSION CHECK ===
  if (f->type == FD_INODE) {
    800044a6:	4098                	lw	a4,0(s1)
    800044a8:	4789                	li	a5,2
    800044aa:	02f70d63          	beq	a4,a5,800044e4 <filewrite+0x62>
    }
    iunlock(f->ip);
  }
  // === END NEW ===

  if(f->type == FD_PIPE){
    800044ae:	409c                	lw	a5,0(s1)
    800044b0:	4705                	li	a4,1
    800044b2:	08e78063          	beq	a5,a4,80004532 <filewrite+0xb0>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800044b6:	470d                	li	a4,3
    800044b8:	08e78463          	beq	a5,a4,80004540 <filewrite+0xbe>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800044bc:	4709                	li	a4,2
    800044be:	12e79463          	bne	a5,a4,800045e6 <filewrite+0x164>
    800044c2:	f852                	sd	s4,48(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800044c4:	0f505f63          	blez	s5,800045c2 <filewrite+0x140>
    800044c8:	fc4e                	sd	s3,56(sp)
    800044ca:	ec5e                	sd	s7,24(sp)
    800044cc:	e862                	sd	s8,16(sp)
    800044ce:	e466                	sd	s9,8(sp)
    int i = 0;
    800044d0:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    800044d2:	6b85                	lui	s7,0x1
    800044d4:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800044d8:	6785                	lui	a5,0x1
    800044da:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    800044de:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800044e0:	4c05                	li	s8,1
    800044e2:	a0e1                	j	800045aa <filewrite+0x128>
    800044e4:	fc4e                	sd	s3,56(sp)
    ilock(f->ip);
    800044e6:	6c88                	ld	a0,24(s1)
    800044e8:	e89fe0ef          	jal	80003370 <ilock>
    if (check_permission(f->ip, 2 /*write*/, p->creds.uid, p->creds.gid) < 0) {
    800044ec:	0184b983          	ld	s3,24(s1)
    800044f0:	16c92683          	lw	a3,364(s2)
    800044f4:	16892603          	lw	a2,360(s2)
    800044f8:	4589                	li	a1,2
    800044fa:	854e                	mv	a0,s3
    800044fc:	c03ff0ef          	jal	800040fe <check_permission>
    80004500:	00054763          	bltz	a0,8000450e <filewrite+0x8c>
    iunlock(f->ip);
    80004504:	854e                	mv	a0,s3
    80004506:	f3bfe0ef          	jal	80003440 <iunlock>
    8000450a:	79e2                	ld	s3,56(sp)
    8000450c:	b74d                	j	800044ae <filewrite+0x2c>
      iunlock(f->ip);
    8000450e:	854e                	mv	a0,s3
    80004510:	f31fe0ef          	jal	80003440 <iunlock>
      audit_log_event(p->pid, p->creds.uid, SYS_write, "DENIED:write_permission");
    80004514:	00004697          	auipc	a3,0x4
    80004518:	23c68693          	addi	a3,a3,572 # 80008750 <etext+0x750>
    8000451c:	4641                	li	a2,16
    8000451e:	16892583          	lw	a1,360(s2)
    80004522:	03092503          	lw	a0,48(s2)
    80004526:	284020ef          	jal	800067aa <audit_log_event>
      return -1;
    8000452a:	557d                	li	a0,-1
    8000452c:	6906                	ld	s2,64(sp)
    8000452e:	79e2                	ld	s3,56(sp)
    80004530:	a065                	j	800045d8 <filewrite+0x156>
    ret = pipewrite(f->pipe, addr, n);
    80004532:	8656                	mv	a2,s5
    80004534:	85da                	mv	a1,s6
    80004536:	6888                	ld	a0,16(s1)
    80004538:	202000ef          	jal	8000473a <pipewrite>
    8000453c:	6906                	ld	s2,64(sp)
    8000453e:	a869                	j	800045d8 <filewrite+0x156>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004540:	02449783          	lh	a5,36(s1)
    80004544:	03079693          	slli	a3,a5,0x30
    80004548:	92c1                	srli	a3,a3,0x30
    8000454a:	4725                	li	a4,9
    8000454c:	0ad76a63          	bltu	a4,a3,80004600 <filewrite+0x17e>
    80004550:	0792                	slli	a5,a5,0x4
    80004552:	0001e717          	auipc	a4,0x1e
    80004556:	a9e70713          	addi	a4,a4,-1378 # 80021ff0 <devsw>
    8000455a:	97ba                	add	a5,a5,a4
    8000455c:	679c                	ld	a5,8(a5)
    8000455e:	c7c5                	beqz	a5,80004606 <filewrite+0x184>
    ret = devsw[f->major].write(1, addr, n);
    80004560:	8656                	mv	a2,s5
    80004562:	85da                	mv	a1,s6
    80004564:	4505                	li	a0,1
    80004566:	9782                	jalr	a5
    80004568:	6906                	ld	s2,64(sp)
    8000456a:	a0bd                	j	800045d8 <filewrite+0x156>
      if(n1 > max)
    8000456c:	2981                	sext.w	s3,s3
      begin_op();
    8000456e:	835ff0ef          	jal	80003da2 <begin_op>
      ilock(f->ip);
    80004572:	6c88                	ld	a0,24(s1)
    80004574:	dfdfe0ef          	jal	80003370 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004578:	874e                	mv	a4,s3
    8000457a:	5094                	lw	a3,32(s1)
    8000457c:	016a0633          	add	a2,s4,s6
    80004580:	85e2                	mv	a1,s8
    80004582:	6c88                	ld	a0,24(s1)
    80004584:	a96ff0ef          	jal	8000381a <writei>
    80004588:	892a                	mv	s2,a0
    8000458a:	00a05563          	blez	a0,80004594 <filewrite+0x112>
        f->off += r;
    8000458e:	509c                	lw	a5,32(s1)
    80004590:	9fa9                	addw	a5,a5,a0
    80004592:	d09c                	sw	a5,32(s1)
      iunlock(f->ip);
    80004594:	6c88                	ld	a0,24(s1)
    80004596:	eabfe0ef          	jal	80003440 <iunlock>
      end_op();
    8000459a:	879ff0ef          	jal	80003e12 <end_op>

      if(r != n1){
    8000459e:	03299463          	bne	s3,s2,800045c6 <filewrite+0x144>
        // error from writei
        break;
      }
      i += r;
    800045a2:	01490a3b          	addw	s4,s2,s4
    while(i < n){
    800045a6:	015a5963          	bge	s4,s5,800045b8 <filewrite+0x136>
      int n1 = n - i;
    800045aa:	414a87bb          	subw	a5,s5,s4
    800045ae:	89be                	mv	s3,a5
      if(n1 > max)
    800045b0:	fafbdee3          	bge	s7,a5,8000456c <filewrite+0xea>
    800045b4:	89e6                	mv	s3,s9
    800045b6:	bf5d                	j	8000456c <filewrite+0xea>
    800045b8:	79e2                	ld	s3,56(sp)
    800045ba:	6be2                	ld	s7,24(sp)
    800045bc:	6c42                	ld	s8,16(sp)
    800045be:	6ca2                	ld	s9,8(sp)
    800045c0:	a039                	j	800045ce <filewrite+0x14c>
    int i = 0;
    800045c2:	4a01                	li	s4,0
    800045c4:	a029                	j	800045ce <filewrite+0x14c>
    800045c6:	79e2                	ld	s3,56(sp)
    800045c8:	6be2                	ld	s7,24(sp)
    800045ca:	6c42                	ld	s8,16(sp)
    800045cc:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    800045ce:	034a9f63          	bne	s5,s4,8000460c <filewrite+0x18a>
    800045d2:	8556                	mv	a0,s5
    800045d4:	6906                	ld	s2,64(sp)
    800045d6:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800045d8:	60e6                	ld	ra,88(sp)
    800045da:	6446                	ld	s0,80(sp)
    800045dc:	64a6                	ld	s1,72(sp)
    800045de:	7aa2                	ld	s5,40(sp)
    800045e0:	7b02                	ld	s6,32(sp)
    800045e2:	6125                	addi	sp,sp,96
    800045e4:	8082                	ret
    800045e6:	fc4e                	sd	s3,56(sp)
    800045e8:	f852                	sd	s4,48(sp)
    800045ea:	ec5e                	sd	s7,24(sp)
    800045ec:	e862                	sd	s8,16(sp)
    800045ee:	e466                	sd	s9,8(sp)
    panic("filewrite");
    800045f0:	00004517          	auipc	a0,0x4
    800045f4:	17850513          	addi	a0,a0,376 # 80008768 <etext+0x768>
    800045f8:	a2cfc0ef          	jal	80000824 <panic>
    return -1;
    800045fc:	557d                	li	a0,-1
    800045fe:	bfe9                	j	800045d8 <filewrite+0x156>
      return -1;
    80004600:	557d                	li	a0,-1
    80004602:	6906                	ld	s2,64(sp)
    80004604:	bfd1                	j	800045d8 <filewrite+0x156>
    80004606:	557d                	li	a0,-1
    80004608:	6906                	ld	s2,64(sp)
    8000460a:	b7f9                	j	800045d8 <filewrite+0x156>
    ret = (i == n ? n : -1);
    8000460c:	557d                	li	a0,-1
    8000460e:	6906                	ld	s2,64(sp)
    80004610:	7a42                	ld	s4,48(sp)
    80004612:	b7d9                	j	800045d8 <filewrite+0x156>

0000000080004614 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004614:	7179                	addi	sp,sp,-48
    80004616:	f406                	sd	ra,40(sp)
    80004618:	f022                	sd	s0,32(sp)
    8000461a:	ec26                	sd	s1,24(sp)
    8000461c:	e052                	sd	s4,0(sp)
    8000461e:	1800                	addi	s0,sp,48
    80004620:	84aa                	mv	s1,a0
    80004622:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004624:	0005b023          	sd	zero,0(a1)
    80004628:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000462c:	b67ff0ef          	jal	80004192 <filealloc>
    80004630:	e088                	sd	a0,0(s1)
    80004632:	c549                	beqz	a0,800046bc <pipealloc+0xa8>
    80004634:	b5fff0ef          	jal	80004192 <filealloc>
    80004638:	00aa3023          	sd	a0,0(s4)
    8000463c:	cd25                	beqz	a0,800046b4 <pipealloc+0xa0>
    8000463e:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004640:	d04fc0ef          	jal	80000b44 <kalloc>
    80004644:	892a                	mv	s2,a0
    80004646:	c12d                	beqz	a0,800046a8 <pipealloc+0x94>
    80004648:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    8000464a:	4985                	li	s3,1
    8000464c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004650:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004654:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004658:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000465c:	00004597          	auipc	a1,0x4
    80004660:	11c58593          	addi	a1,a1,284 # 80008778 <etext+0x778>
    80004664:	d3afc0ef          	jal	80000b9e <initlock>
  (*f0)->type = FD_PIPE;
    80004668:	609c                	ld	a5,0(s1)
    8000466a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000466e:	609c                	ld	a5,0(s1)
    80004670:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004674:	609c                	ld	a5,0(s1)
    80004676:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000467a:	609c                	ld	a5,0(s1)
    8000467c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004680:	000a3783          	ld	a5,0(s4)
    80004684:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004688:	000a3783          	ld	a5,0(s4)
    8000468c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004690:	000a3783          	ld	a5,0(s4)
    80004694:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004698:	000a3783          	ld	a5,0(s4)
    8000469c:	0127b823          	sd	s2,16(a5)
  return 0;
    800046a0:	4501                	li	a0,0
    800046a2:	6942                	ld	s2,16(sp)
    800046a4:	69a2                	ld	s3,8(sp)
    800046a6:	a01d                	j	800046cc <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800046a8:	6088                	ld	a0,0(s1)
    800046aa:	c119                	beqz	a0,800046b0 <pipealloc+0x9c>
    800046ac:	6942                	ld	s2,16(sp)
    800046ae:	a029                	j	800046b8 <pipealloc+0xa4>
    800046b0:	6942                	ld	s2,16(sp)
    800046b2:	a029                	j	800046bc <pipealloc+0xa8>
    800046b4:	6088                	ld	a0,0(s1)
    800046b6:	c10d                	beqz	a0,800046d8 <pipealloc+0xc4>
    fileclose(*f0);
    800046b8:	b7fff0ef          	jal	80004236 <fileclose>
  if(*f1)
    800046bc:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800046c0:	557d                	li	a0,-1
  if(*f1)
    800046c2:	c789                	beqz	a5,800046cc <pipealloc+0xb8>
    fileclose(*f1);
    800046c4:	853e                	mv	a0,a5
    800046c6:	b71ff0ef          	jal	80004236 <fileclose>
  return -1;
    800046ca:	557d                	li	a0,-1
}
    800046cc:	70a2                	ld	ra,40(sp)
    800046ce:	7402                	ld	s0,32(sp)
    800046d0:	64e2                	ld	s1,24(sp)
    800046d2:	6a02                	ld	s4,0(sp)
    800046d4:	6145                	addi	sp,sp,48
    800046d6:	8082                	ret
  return -1;
    800046d8:	557d                	li	a0,-1
    800046da:	bfcd                	j	800046cc <pipealloc+0xb8>

00000000800046dc <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800046dc:	1101                	addi	sp,sp,-32
    800046de:	ec06                	sd	ra,24(sp)
    800046e0:	e822                	sd	s0,16(sp)
    800046e2:	e426                	sd	s1,8(sp)
    800046e4:	e04a                	sd	s2,0(sp)
    800046e6:	1000                	addi	s0,sp,32
    800046e8:	84aa                	mv	s1,a0
    800046ea:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800046ec:	d3cfc0ef          	jal	80000c28 <acquire>
  if(writable){
    800046f0:	02090763          	beqz	s2,8000471e <pipeclose+0x42>
    pi->writeopen = 0;
    800046f4:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800046f8:	21848513          	addi	a0,s1,536
    800046fc:	8e3fd0ef          	jal	80001fde <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004700:	2204a783          	lw	a5,544(s1)
    80004704:	e781                	bnez	a5,8000470c <pipeclose+0x30>
    80004706:	2244a783          	lw	a5,548(s1)
    8000470a:	c38d                	beqz	a5,8000472c <pipeclose+0x50>
    release(&pi->lock);
    kfree((char*)pi);
  } else
    release(&pi->lock);
    8000470c:	8526                	mv	a0,s1
    8000470e:	daefc0ef          	jal	80000cbc <release>
}
    80004712:	60e2                	ld	ra,24(sp)
    80004714:	6442                	ld	s0,16(sp)
    80004716:	64a2                	ld	s1,8(sp)
    80004718:	6902                	ld	s2,0(sp)
    8000471a:	6105                	addi	sp,sp,32
    8000471c:	8082                	ret
    pi->readopen = 0;
    8000471e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004722:	21c48513          	addi	a0,s1,540
    80004726:	8b9fd0ef          	jal	80001fde <wakeup>
    8000472a:	bfd9                	j	80004700 <pipeclose+0x24>
    release(&pi->lock);
    8000472c:	8526                	mv	a0,s1
    8000472e:	d8efc0ef          	jal	80000cbc <release>
    kfree((char*)pi);
    80004732:	8526                	mv	a0,s1
    80004734:	b28fc0ef          	jal	80000a5c <kfree>
    80004738:	bfe9                	j	80004712 <pipeclose+0x36>

000000008000473a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000473a:	7159                	addi	sp,sp,-112
    8000473c:	f486                	sd	ra,104(sp)
    8000473e:	f0a2                	sd	s0,96(sp)
    80004740:	eca6                	sd	s1,88(sp)
    80004742:	e8ca                	sd	s2,80(sp)
    80004744:	e4ce                	sd	s3,72(sp)
    80004746:	e0d2                	sd	s4,64(sp)
    80004748:	fc56                	sd	s5,56(sp)
    8000474a:	1880                	addi	s0,sp,112
    8000474c:	84aa                	mv	s1,a0
    8000474e:	8aae                	mv	s5,a1
    80004750:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004752:	9e4fd0ef          	jal	80001936 <myproc>
    80004756:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004758:	8526                	mv	a0,s1
    8000475a:	ccefc0ef          	jal	80000c28 <acquire>
  while(i < n){
    8000475e:	0d405263          	blez	s4,80004822 <pipewrite+0xe8>
    80004762:	f85a                	sd	s6,48(sp)
    80004764:	f45e                	sd	s7,40(sp)
    80004766:	f062                	sd	s8,32(sp)
    80004768:	ec66                	sd	s9,24(sp)
    8000476a:	e86a                	sd	s10,16(sp)
  int i = 0;
    8000476c:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000476e:	f9f40c13          	addi	s8,s0,-97
    80004772:	4b85                	li	s7,1
    80004774:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004776:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000477a:	21c48c93          	addi	s9,s1,540
    8000477e:	a82d                	j	800047b8 <pipewrite+0x7e>
      release(&pi->lock);
    80004780:	8526                	mv	a0,s1
    80004782:	d3afc0ef          	jal	80000cbc <release>
      return -1;
    80004786:	597d                	li	s2,-1
    80004788:	7b42                	ld	s6,48(sp)
    8000478a:	7ba2                	ld	s7,40(sp)
    8000478c:	7c02                	ld	s8,32(sp)
    8000478e:	6ce2                	ld	s9,24(sp)
    80004790:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004792:	854a                	mv	a0,s2
    80004794:	70a6                	ld	ra,104(sp)
    80004796:	7406                	ld	s0,96(sp)
    80004798:	64e6                	ld	s1,88(sp)
    8000479a:	6946                	ld	s2,80(sp)
    8000479c:	69a6                	ld	s3,72(sp)
    8000479e:	6a06                	ld	s4,64(sp)
    800047a0:	7ae2                	ld	s5,56(sp)
    800047a2:	6165                	addi	sp,sp,112
    800047a4:	8082                	ret
      wakeup(&pi->nread);
    800047a6:	856a                	mv	a0,s10
    800047a8:	837fd0ef          	jal	80001fde <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800047ac:	85a6                	mv	a1,s1
    800047ae:	8566                	mv	a0,s9
    800047b0:	fe2fd0ef          	jal	80001f92 <sleep>
  while(i < n){
    800047b4:	05495a63          	bge	s2,s4,80004808 <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    800047b8:	2204a783          	lw	a5,544(s1)
    800047bc:	d3f1                	beqz	a5,80004780 <pipewrite+0x46>
    800047be:	854e                	mv	a0,s3
    800047c0:	a0ffd0ef          	jal	800021ce <killed>
    800047c4:	fd55                	bnez	a0,80004780 <pipewrite+0x46>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800047c6:	2184a783          	lw	a5,536(s1)
    800047ca:	21c4a703          	lw	a4,540(s1)
    800047ce:	2007879b          	addiw	a5,a5,512
    800047d2:	fcf70ae3          	beq	a4,a5,800047a6 <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800047d6:	86de                	mv	a3,s7
    800047d8:	01590633          	add	a2,s2,s5
    800047dc:	85e2                	mv	a1,s8
    800047de:	0509b503          	ld	a0,80(s3)
    800047e2:	f39fc0ef          	jal	8000171a <copyin>
    800047e6:	05650063          	beq	a0,s6,80004826 <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800047ea:	21c4a783          	lw	a5,540(s1)
    800047ee:	0017871b          	addiw	a4,a5,1
    800047f2:	20e4ae23          	sw	a4,540(s1)
    800047f6:	1ff7f793          	andi	a5,a5,511
    800047fa:	97a6                	add	a5,a5,s1
    800047fc:	f9f44703          	lbu	a4,-97(s0)
    80004800:	00e78c23          	sb	a4,24(a5)
      i++;
    80004804:	2905                	addiw	s2,s2,1
    80004806:	b77d                	j	800047b4 <pipewrite+0x7a>
    80004808:	7b42                	ld	s6,48(sp)
    8000480a:	7ba2                	ld	s7,40(sp)
    8000480c:	7c02                	ld	s8,32(sp)
    8000480e:	6ce2                	ld	s9,24(sp)
    80004810:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004812:	21848513          	addi	a0,s1,536
    80004816:	fc8fd0ef          	jal	80001fde <wakeup>
  release(&pi->lock);
    8000481a:	8526                	mv	a0,s1
    8000481c:	ca0fc0ef          	jal	80000cbc <release>
  return i;
    80004820:	bf8d                	j	80004792 <pipewrite+0x58>
  int i = 0;
    80004822:	4901                	li	s2,0
    80004824:	b7fd                	j	80004812 <pipewrite+0xd8>
    80004826:	7b42                	ld	s6,48(sp)
    80004828:	7ba2                	ld	s7,40(sp)
    8000482a:	7c02                	ld	s8,32(sp)
    8000482c:	6ce2                	ld	s9,24(sp)
    8000482e:	6d42                	ld	s10,16(sp)
    80004830:	b7cd                	j	80004812 <pipewrite+0xd8>

0000000080004832 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004832:	711d                	addi	sp,sp,-96
    80004834:	ec86                	sd	ra,88(sp)
    80004836:	e8a2                	sd	s0,80(sp)
    80004838:	e4a6                	sd	s1,72(sp)
    8000483a:	e0ca                	sd	s2,64(sp)
    8000483c:	fc4e                	sd	s3,56(sp)
    8000483e:	f852                	sd	s4,48(sp)
    80004840:	f456                	sd	s5,40(sp)
    80004842:	1080                	addi	s0,sp,96
    80004844:	84aa                	mv	s1,a0
    80004846:	892e                	mv	s2,a1
    80004848:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000484a:	8ecfd0ef          	jal	80001936 <myproc>
    8000484e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004850:	8526                	mv	a0,s1
    80004852:	bd6fc0ef          	jal	80000c28 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004856:	2184a703          	lw	a4,536(s1)
    8000485a:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000485e:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004862:	02f71763          	bne	a4,a5,80004890 <piperead+0x5e>
    80004866:	2244a783          	lw	a5,548(s1)
    8000486a:	cf85                	beqz	a5,800048a2 <piperead+0x70>
    if(killed(pr)){
    8000486c:	8552                	mv	a0,s4
    8000486e:	961fd0ef          	jal	800021ce <killed>
    80004872:	e11d                	bnez	a0,80004898 <piperead+0x66>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004874:	85a6                	mv	a1,s1
    80004876:	854e                	mv	a0,s3
    80004878:	f1afd0ef          	jal	80001f92 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000487c:	2184a703          	lw	a4,536(s1)
    80004880:	21c4a783          	lw	a5,540(s1)
    80004884:	fef701e3          	beq	a4,a5,80004866 <piperead+0x34>
    80004888:	f05a                	sd	s6,32(sp)
    8000488a:	ec5e                	sd	s7,24(sp)
    8000488c:	e862                	sd	s8,16(sp)
    8000488e:	a829                	j	800048a8 <piperead+0x76>
    80004890:	f05a                	sd	s6,32(sp)
    80004892:	ec5e                	sd	s7,24(sp)
    80004894:	e862                	sd	s8,16(sp)
    80004896:	a809                	j	800048a8 <piperead+0x76>
      release(&pi->lock);
    80004898:	8526                	mv	a0,s1
    8000489a:	c22fc0ef          	jal	80000cbc <release>
      return -1;
    8000489e:	59fd                	li	s3,-1
    800048a0:	a0a5                	j	80004908 <piperead+0xd6>
    800048a2:	f05a                	sd	s6,32(sp)
    800048a4:	ec5e                	sd	s7,24(sp)
    800048a6:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800048a8:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800048aa:	faf40c13          	addi	s8,s0,-81
    800048ae:	4b85                	li	s7,1
    800048b0:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800048b2:	05505163          	blez	s5,800048f4 <piperead+0xc2>
    if(pi->nread == pi->nwrite)
    800048b6:	2184a783          	lw	a5,536(s1)
    800048ba:	21c4a703          	lw	a4,540(s1)
    800048be:	02f70b63          	beq	a4,a5,800048f4 <piperead+0xc2>
    ch = pi->data[pi->nread % PIPESIZE];
    800048c2:	1ff7f793          	andi	a5,a5,511
    800048c6:	97a6                	add	a5,a5,s1
    800048c8:	0187c783          	lbu	a5,24(a5)
    800048cc:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800048d0:	86de                	mv	a3,s7
    800048d2:	8662                	mv	a2,s8
    800048d4:	85ca                	mv	a1,s2
    800048d6:	050a3503          	ld	a0,80(s4)
    800048da:	d83fc0ef          	jal	8000165c <copyout>
    800048de:	03650f63          	beq	a0,s6,8000491c <piperead+0xea>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800048e2:	2184a783          	lw	a5,536(s1)
    800048e6:	2785                	addiw	a5,a5,1
    800048e8:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800048ec:	2985                	addiw	s3,s3,1
    800048ee:	0905                	addi	s2,s2,1
    800048f0:	fd3a93e3          	bne	s5,s3,800048b6 <piperead+0x84>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800048f4:	21c48513          	addi	a0,s1,540
    800048f8:	ee6fd0ef          	jal	80001fde <wakeup>
  release(&pi->lock);
    800048fc:	8526                	mv	a0,s1
    800048fe:	bbefc0ef          	jal	80000cbc <release>
    80004902:	7b02                	ld	s6,32(sp)
    80004904:	6be2                	ld	s7,24(sp)
    80004906:	6c42                	ld	s8,16(sp)
  return i;
}
    80004908:	854e                	mv	a0,s3
    8000490a:	60e6                	ld	ra,88(sp)
    8000490c:	6446                	ld	s0,80(sp)
    8000490e:	64a6                	ld	s1,72(sp)
    80004910:	6906                	ld	s2,64(sp)
    80004912:	79e2                	ld	s3,56(sp)
    80004914:	7a42                	ld	s4,48(sp)
    80004916:	7aa2                	ld	s5,40(sp)
    80004918:	6125                	addi	sp,sp,96
    8000491a:	8082                	ret
      if(i == 0)
    8000491c:	fc099ce3          	bnez	s3,800048f4 <piperead+0xc2>
        i = -1;
    80004920:	89aa                	mv	s3,a0
    80004922:	bfc9                	j	800048f4 <piperead+0xc2>

0000000080004924 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004924:	1141                	addi	sp,sp,-16
    80004926:	e406                	sd	ra,8(sp)
    80004928:	e022                	sd	s0,0(sp)
    8000492a:	0800                	addi	s0,sp,16
    8000492c:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000492e:	0035151b          	slliw	a0,a0,0x3
    80004932:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    80004934:	8b89                	andi	a5,a5,2
    80004936:	c399                	beqz	a5,8000493c <flags2perm+0x18>
      perm |= PTE_W;
    80004938:	00456513          	ori	a0,a0,4
    return perm;
}
    8000493c:	60a2                	ld	ra,8(sp)
    8000493e:	6402                	ld	s0,0(sp)
    80004940:	0141                	addi	sp,sp,16
    80004942:	8082                	ret

0000000080004944 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004944:	de010113          	addi	sp,sp,-544
    80004948:	20113c23          	sd	ra,536(sp)
    8000494c:	20813823          	sd	s0,528(sp)
    80004950:	20913423          	sd	s1,520(sp)
    80004954:	21213023          	sd	s2,512(sp)
    80004958:	1400                	addi	s0,sp,544
    8000495a:	892a                	mv	s2,a0
    8000495c:	dea43823          	sd	a0,-528(s0)
    80004960:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004964:	fd3fc0ef          	jal	80001936 <myproc>
    80004968:	84aa                	mv	s1,a0

  begin_op();
    8000496a:	c38ff0ef          	jal	80003da2 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    8000496e:	854a                	mv	a0,s2
    80004970:	a54ff0ef          	jal	80003bc4 <namei>
    80004974:	cd21                	beqz	a0,800049cc <kexec+0x88>
    80004976:	fbd2                	sd	s4,496(sp)
    80004978:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000497a:	9f7fe0ef          	jal	80003370 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000497e:	04000713          	li	a4,64
    80004982:	4681                	li	a3,0
    80004984:	e5040613          	addi	a2,s0,-432
    80004988:	4581                	li	a1,0
    8000498a:	8552                	mv	a0,s4
    8000498c:	d9dfe0ef          	jal	80003728 <readi>
    80004990:	04000793          	li	a5,64
    80004994:	00f51a63          	bne	a0,a5,800049a8 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004998:	e5042703          	lw	a4,-432(s0)
    8000499c:	464c47b7          	lui	a5,0x464c4
    800049a0:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800049a4:	02f70863          	beq	a4,a5,800049d4 <kexec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800049a8:	8552                	mv	a0,s4
    800049aa:	bf5fe0ef          	jal	8000359e <iunlockput>
    end_op();
    800049ae:	c64ff0ef          	jal	80003e12 <end_op>
  }
  return -1;
    800049b2:	557d                	li	a0,-1
    800049b4:	7a5e                	ld	s4,496(sp)
}
    800049b6:	21813083          	ld	ra,536(sp)
    800049ba:	21013403          	ld	s0,528(sp)
    800049be:	20813483          	ld	s1,520(sp)
    800049c2:	20013903          	ld	s2,512(sp)
    800049c6:	22010113          	addi	sp,sp,544
    800049ca:	8082                	ret
    end_op();
    800049cc:	c46ff0ef          	jal	80003e12 <end_op>
    return -1;
    800049d0:	557d                	li	a0,-1
    800049d2:	b7d5                	j	800049b6 <kexec+0x72>
    800049d4:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    800049d6:	8526                	mv	a0,s1
    800049d8:	868fd0ef          	jal	80001a40 <proc_pagetable>
    800049dc:	8b2a                	mv	s6,a0
    800049de:	26050f63          	beqz	a0,80004c5c <kexec+0x318>
    800049e2:	ffce                	sd	s3,504(sp)
    800049e4:	f7d6                	sd	s5,488(sp)
    800049e6:	efde                	sd	s7,472(sp)
    800049e8:	ebe2                	sd	s8,464(sp)
    800049ea:	e7e6                	sd	s9,456(sp)
    800049ec:	e3ea                	sd	s10,448(sp)
    800049ee:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800049f0:	e8845783          	lhu	a5,-376(s0)
    800049f4:	0e078963          	beqz	a5,80004ae6 <kexec+0x1a2>
    800049f8:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800049fc:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800049fe:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004a00:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    80004a04:	6c85                	lui	s9,0x1
    80004a06:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004a0a:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004a0e:	6a85                	lui	s5,0x1
    80004a10:	a085                	j	80004a70 <kexec+0x12c>
      panic("loadseg: address should exist");
    80004a12:	00004517          	auipc	a0,0x4
    80004a16:	d6e50513          	addi	a0,a0,-658 # 80008780 <etext+0x780>
    80004a1a:	e0bfb0ef          	jal	80000824 <panic>
    if(sz - i < PGSIZE)
    80004a1e:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004a20:	874a                	mv	a4,s2
    80004a22:	009b86bb          	addw	a3,s7,s1
    80004a26:	4581                	li	a1,0
    80004a28:	8552                	mv	a0,s4
    80004a2a:	cfffe0ef          	jal	80003728 <readi>
    80004a2e:	22a91b63          	bne	s2,a0,80004c64 <kexec+0x320>
  for(i = 0; i < sz; i += PGSIZE){
    80004a32:	009a84bb          	addw	s1,s5,s1
    80004a36:	0334f263          	bgeu	s1,s3,80004a5a <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004a3a:	02049593          	slli	a1,s1,0x20
    80004a3e:	9181                	srli	a1,a1,0x20
    80004a40:	95e2                	add	a1,a1,s8
    80004a42:	855a                	mv	a0,s6
    80004a44:	deafc0ef          	jal	8000102e <walkaddr>
    80004a48:	862a                	mv	a2,a0
    if(pa == 0)
    80004a4a:	d561                	beqz	a0,80004a12 <kexec+0xce>
    if(sz - i < PGSIZE)
    80004a4c:	409987bb          	subw	a5,s3,s1
    80004a50:	893e                	mv	s2,a5
    80004a52:	fcfcf6e3          	bgeu	s9,a5,80004a1e <kexec+0xda>
    80004a56:	8956                	mv	s2,s5
    80004a58:	b7d9                	j	80004a1e <kexec+0xda>
    sz = sz1;
    80004a5a:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004a5e:	2d05                	addiw	s10,s10,1
    80004a60:	e0843783          	ld	a5,-504(s0)
    80004a64:	0387869b          	addiw	a3,a5,56
    80004a68:	e8845783          	lhu	a5,-376(s0)
    80004a6c:	06fd5e63          	bge	s10,a5,80004ae8 <kexec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004a70:	e0d43423          	sd	a3,-504(s0)
    80004a74:	876e                	mv	a4,s11
    80004a76:	e1840613          	addi	a2,s0,-488
    80004a7a:	4581                	li	a1,0
    80004a7c:	8552                	mv	a0,s4
    80004a7e:	cabfe0ef          	jal	80003728 <readi>
    80004a82:	1db51f63          	bne	a0,s11,80004c60 <kexec+0x31c>
    if(ph.type != ELF_PROG_LOAD)
    80004a86:	e1842783          	lw	a5,-488(s0)
    80004a8a:	4705                	li	a4,1
    80004a8c:	fce799e3          	bne	a5,a4,80004a5e <kexec+0x11a>
    if(ph.memsz < ph.filesz)
    80004a90:	e4043483          	ld	s1,-448(s0)
    80004a94:	e3843783          	ld	a5,-456(s0)
    80004a98:	1ef4e463          	bltu	s1,a5,80004c80 <kexec+0x33c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004a9c:	e2843783          	ld	a5,-472(s0)
    80004aa0:	94be                	add	s1,s1,a5
    80004aa2:	1ef4e263          	bltu	s1,a5,80004c86 <kexec+0x342>
    if(ph.vaddr % PGSIZE != 0)
    80004aa6:	de843703          	ld	a4,-536(s0)
    80004aaa:	8ff9                	and	a5,a5,a4
    80004aac:	1e079063          	bnez	a5,80004c8c <kexec+0x348>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004ab0:	e1c42503          	lw	a0,-484(s0)
    80004ab4:	e71ff0ef          	jal	80004924 <flags2perm>
    80004ab8:	86aa                	mv	a3,a0
    80004aba:	8626                	mv	a2,s1
    80004abc:	85ca                	mv	a1,s2
    80004abe:	855a                	mv	a0,s6
    80004ac0:	845fc0ef          	jal	80001304 <uvmalloc>
    80004ac4:	dea43c23          	sd	a0,-520(s0)
    80004ac8:	1c050563          	beqz	a0,80004c92 <kexec+0x34e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004acc:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004ad0:	00098863          	beqz	s3,80004ae0 <kexec+0x19c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004ad4:	e2843c03          	ld	s8,-472(s0)
    80004ad8:	e2042b83          	lw	s7,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004adc:	4481                	li	s1,0
    80004ade:	bfb1                	j	80004a3a <kexec+0xf6>
    sz = sz1;
    80004ae0:	df843903          	ld	s2,-520(s0)
    80004ae4:	bfad                	j	80004a5e <kexec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004ae6:	4901                	li	s2,0
  iunlockput(ip);
    80004ae8:	8552                	mv	a0,s4
    80004aea:	ab5fe0ef          	jal	8000359e <iunlockput>
  end_op();
    80004aee:	b24ff0ef          	jal	80003e12 <end_op>
  p = myproc();
    80004af2:	e45fc0ef          	jal	80001936 <myproc>
    80004af6:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004af8:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004afc:	6985                	lui	s3,0x1
    80004afe:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004b00:	99ca                	add	s3,s3,s2
    80004b02:	77fd                	lui	a5,0xfffff
    80004b04:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004b08:	4691                	li	a3,4
    80004b0a:	6609                	lui	a2,0x2
    80004b0c:	964e                	add	a2,a2,s3
    80004b0e:	85ce                	mv	a1,s3
    80004b10:	855a                	mv	a0,s6
    80004b12:	ff2fc0ef          	jal	80001304 <uvmalloc>
    80004b16:	8a2a                	mv	s4,a0
    80004b18:	e105                	bnez	a0,80004b38 <kexec+0x1f4>
    proc_freepagetable(pagetable, sz);
    80004b1a:	85ce                	mv	a1,s3
    80004b1c:	855a                	mv	a0,s6
    80004b1e:	fa7fc0ef          	jal	80001ac4 <proc_freepagetable>
  return -1;
    80004b22:	557d                	li	a0,-1
    80004b24:	79fe                	ld	s3,504(sp)
    80004b26:	7a5e                	ld	s4,496(sp)
    80004b28:	7abe                	ld	s5,488(sp)
    80004b2a:	7b1e                	ld	s6,480(sp)
    80004b2c:	6bfe                	ld	s7,472(sp)
    80004b2e:	6c5e                	ld	s8,464(sp)
    80004b30:	6cbe                	ld	s9,456(sp)
    80004b32:	6d1e                	ld	s10,448(sp)
    80004b34:	7dfa                	ld	s11,440(sp)
    80004b36:	b541                	j	800049b6 <kexec+0x72>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004b38:	75f9                	lui	a1,0xffffe
    80004b3a:	95aa                	add	a1,a1,a0
    80004b3c:	855a                	mv	a0,s6
    80004b3e:	999fc0ef          	jal	800014d6 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004b42:	800a0b93          	addi	s7,s4,-2048
    80004b46:	800b8b93          	addi	s7,s7,-2048
  for(argc = 0; argv[argc]; argc++) {
    80004b4a:	e0043783          	ld	a5,-512(s0)
    80004b4e:	6388                	ld	a0,0(a5)
  sp = sz;
    80004b50:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80004b52:	4481                	li	s1,0
    ustack[argc] = sp;
    80004b54:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80004b58:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    80004b5c:	cd21                	beqz	a0,80004bb4 <kexec+0x270>
    sp -= strlen(argv[argc]) + 1;
    80004b5e:	b24fc0ef          	jal	80000e82 <strlen>
    80004b62:	0015079b          	addiw	a5,a0,1
    80004b66:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004b6a:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004b6e:	13796563          	bltu	s2,s7,80004c98 <kexec+0x354>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004b72:	e0043d83          	ld	s11,-512(s0)
    80004b76:	000db983          	ld	s3,0(s11)
    80004b7a:	854e                	mv	a0,s3
    80004b7c:	b06fc0ef          	jal	80000e82 <strlen>
    80004b80:	0015069b          	addiw	a3,a0,1
    80004b84:	864e                	mv	a2,s3
    80004b86:	85ca                	mv	a1,s2
    80004b88:	855a                	mv	a0,s6
    80004b8a:	ad3fc0ef          	jal	8000165c <copyout>
    80004b8e:	10054763          	bltz	a0,80004c9c <kexec+0x358>
    ustack[argc] = sp;
    80004b92:	00349793          	slli	a5,s1,0x3
    80004b96:	97e6                	add	a5,a5,s9
    80004b98:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffd06b0>
  for(argc = 0; argv[argc]; argc++) {
    80004b9c:	0485                	addi	s1,s1,1
    80004b9e:	008d8793          	addi	a5,s11,8
    80004ba2:	e0f43023          	sd	a5,-512(s0)
    80004ba6:	008db503          	ld	a0,8(s11)
    80004baa:	c509                	beqz	a0,80004bb4 <kexec+0x270>
    if(argc >= MAXARG)
    80004bac:	fb8499e3          	bne	s1,s8,80004b5e <kexec+0x21a>
  sz = sz1;
    80004bb0:	89d2                	mv	s3,s4
    80004bb2:	b7a5                	j	80004b1a <kexec+0x1d6>
  ustack[argc] = 0;
    80004bb4:	00349793          	slli	a5,s1,0x3
    80004bb8:	f9078793          	addi	a5,a5,-112
    80004bbc:	97a2                	add	a5,a5,s0
    80004bbe:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004bc2:	00349693          	slli	a3,s1,0x3
    80004bc6:	06a1                	addi	a3,a3,8
    80004bc8:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004bcc:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004bd0:	89d2                	mv	s3,s4
  if(sp < stackbase)
    80004bd2:	f57964e3          	bltu	s2,s7,80004b1a <kexec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004bd6:	e9040613          	addi	a2,s0,-368
    80004bda:	85ca                	mv	a1,s2
    80004bdc:	855a                	mv	a0,s6
    80004bde:	a7ffc0ef          	jal	8000165c <copyout>
    80004be2:	f2054ce3          	bltz	a0,80004b1a <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004be6:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004bea:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004bee:	df043783          	ld	a5,-528(s0)
    80004bf2:	0007c703          	lbu	a4,0(a5)
    80004bf6:	cf11                	beqz	a4,80004c12 <kexec+0x2ce>
    80004bf8:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004bfa:	02f00693          	li	a3,47
    80004bfe:	a029                	j	80004c08 <kexec+0x2c4>
  for(last=s=path; *s; s++)
    80004c00:	0785                	addi	a5,a5,1
    80004c02:	fff7c703          	lbu	a4,-1(a5)
    80004c06:	c711                	beqz	a4,80004c12 <kexec+0x2ce>
    if(*s == '/')
    80004c08:	fed71ce3          	bne	a4,a3,80004c00 <kexec+0x2bc>
      last = s+1;
    80004c0c:	def43823          	sd	a5,-528(s0)
    80004c10:	bfc5                	j	80004c00 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004c12:	4641                	li	a2,16
    80004c14:	df043583          	ld	a1,-528(s0)
    80004c18:	158a8513          	addi	a0,s5,344
    80004c1c:	a30fc0ef          	jal	80000e4c <safestrcpy>
  oldpagetable = p->pagetable;
    80004c20:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004c24:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004c28:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004c2c:	058ab783          	ld	a5,88(s5)
    80004c30:	e6843703          	ld	a4,-408(s0)
    80004c34:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004c36:	058ab783          	ld	a5,88(s5)
    80004c3a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004c3e:	85ea                	mv	a1,s10
    80004c40:	e85fc0ef          	jal	80001ac4 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004c44:	0004851b          	sext.w	a0,s1
    80004c48:	79fe                	ld	s3,504(sp)
    80004c4a:	7a5e                	ld	s4,496(sp)
    80004c4c:	7abe                	ld	s5,488(sp)
    80004c4e:	7b1e                	ld	s6,480(sp)
    80004c50:	6bfe                	ld	s7,472(sp)
    80004c52:	6c5e                	ld	s8,464(sp)
    80004c54:	6cbe                	ld	s9,456(sp)
    80004c56:	6d1e                	ld	s10,448(sp)
    80004c58:	7dfa                	ld	s11,440(sp)
    80004c5a:	bbb1                	j	800049b6 <kexec+0x72>
    80004c5c:	7b1e                	ld	s6,480(sp)
    80004c5e:	b3a9                	j	800049a8 <kexec+0x64>
    80004c60:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004c64:	df843583          	ld	a1,-520(s0)
    80004c68:	855a                	mv	a0,s6
    80004c6a:	e5bfc0ef          	jal	80001ac4 <proc_freepagetable>
  if(ip){
    80004c6e:	79fe                	ld	s3,504(sp)
    80004c70:	7abe                	ld	s5,488(sp)
    80004c72:	7b1e                	ld	s6,480(sp)
    80004c74:	6bfe                	ld	s7,472(sp)
    80004c76:	6c5e                	ld	s8,464(sp)
    80004c78:	6cbe                	ld	s9,456(sp)
    80004c7a:	6d1e                	ld	s10,448(sp)
    80004c7c:	7dfa                	ld	s11,440(sp)
    80004c7e:	b32d                	j	800049a8 <kexec+0x64>
    80004c80:	df243c23          	sd	s2,-520(s0)
    80004c84:	b7c5                	j	80004c64 <kexec+0x320>
    80004c86:	df243c23          	sd	s2,-520(s0)
    80004c8a:	bfe9                	j	80004c64 <kexec+0x320>
    80004c8c:	df243c23          	sd	s2,-520(s0)
    80004c90:	bfd1                	j	80004c64 <kexec+0x320>
    80004c92:	df243c23          	sd	s2,-520(s0)
    80004c96:	b7f9                	j	80004c64 <kexec+0x320>
  sz = sz1;
    80004c98:	89d2                	mv	s3,s4
    80004c9a:	b541                	j	80004b1a <kexec+0x1d6>
    80004c9c:	89d2                	mv	s3,s4
    80004c9e:	bdb5                	j	80004b1a <kexec+0x1d6>

0000000080004ca0 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004ca0:	7179                	addi	sp,sp,-48
    80004ca2:	f406                	sd	ra,40(sp)
    80004ca4:	f022                	sd	s0,32(sp)
    80004ca6:	ec26                	sd	s1,24(sp)
    80004ca8:	e84a                	sd	s2,16(sp)
    80004caa:	1800                	addi	s0,sp,48
    80004cac:	892e                	mv	s2,a1
    80004cae:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004cb0:	fdc40593          	addi	a1,s0,-36
    80004cb4:	ca9fd0ef          	jal	8000295c <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004cb8:	fdc42703          	lw	a4,-36(s0)
    80004cbc:	47bd                	li	a5,15
    80004cbe:	02e7ea63          	bltu	a5,a4,80004cf2 <argfd+0x52>
    80004cc2:	c75fc0ef          	jal	80001936 <myproc>
    80004cc6:	fdc42703          	lw	a4,-36(s0)
    80004cca:	00371793          	slli	a5,a4,0x3
    80004cce:	0d078793          	addi	a5,a5,208
    80004cd2:	953e                	add	a0,a0,a5
    80004cd4:	611c                	ld	a5,0(a0)
    80004cd6:	c385                	beqz	a5,80004cf6 <argfd+0x56>
    return -1;
  if(pfd)
    80004cd8:	00090463          	beqz	s2,80004ce0 <argfd+0x40>
    *pfd = fd;
    80004cdc:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004ce0:	4501                	li	a0,0
  if(pf)
    80004ce2:	c091                	beqz	s1,80004ce6 <argfd+0x46>
    *pf = f;
    80004ce4:	e09c                	sd	a5,0(s1)
}
    80004ce6:	70a2                	ld	ra,40(sp)
    80004ce8:	7402                	ld	s0,32(sp)
    80004cea:	64e2                	ld	s1,24(sp)
    80004cec:	6942                	ld	s2,16(sp)
    80004cee:	6145                	addi	sp,sp,48
    80004cf0:	8082                	ret
    return -1;
    80004cf2:	557d                	li	a0,-1
    80004cf4:	bfcd                	j	80004ce6 <argfd+0x46>
    80004cf6:	557d                	li	a0,-1
    80004cf8:	b7fd                	j	80004ce6 <argfd+0x46>

0000000080004cfa <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004cfa:	1101                	addi	sp,sp,-32
    80004cfc:	ec06                	sd	ra,24(sp)
    80004cfe:	e822                	sd	s0,16(sp)
    80004d00:	e426                	sd	s1,8(sp)
    80004d02:	1000                	addi	s0,sp,32
    80004d04:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004d06:	c31fc0ef          	jal	80001936 <myproc>
    80004d0a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004d0c:	0d050793          	addi	a5,a0,208
    80004d10:	4501                	li	a0,0
    80004d12:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004d14:	6398                	ld	a4,0(a5)
    80004d16:	cb19                	beqz	a4,80004d2c <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004d18:	2505                	addiw	a0,a0,1
    80004d1a:	07a1                	addi	a5,a5,8
    80004d1c:	fed51ce3          	bne	a0,a3,80004d14 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004d20:	557d                	li	a0,-1
}
    80004d22:	60e2                	ld	ra,24(sp)
    80004d24:	6442                	ld	s0,16(sp)
    80004d26:	64a2                	ld	s1,8(sp)
    80004d28:	6105                	addi	sp,sp,32
    80004d2a:	8082                	ret
      p->ofile[fd] = f;
    80004d2c:	00351793          	slli	a5,a0,0x3
    80004d30:	0d078793          	addi	a5,a5,208
    80004d34:	963e                	add	a2,a2,a5
    80004d36:	e204                	sd	s1,0(a2)
      return fd;
    80004d38:	b7ed                	j	80004d22 <fdalloc+0x28>

0000000080004d3a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004d3a:	715d                	addi	sp,sp,-80
    80004d3c:	e486                	sd	ra,72(sp)
    80004d3e:	e0a2                	sd	s0,64(sp)
    80004d40:	fc26                	sd	s1,56(sp)
    80004d42:	f84a                	sd	s2,48(sp)
    80004d44:	f44e                	sd	s3,40(sp)
    80004d46:	f052                	sd	s4,32(sp)
    80004d48:	ec56                	sd	s5,24(sp)
    80004d4a:	e85a                	sd	s6,16(sp)
    80004d4c:	0880                	addi	s0,sp,80
    80004d4e:	892e                	mv	s2,a1
    80004d50:	8a2e                	mv	s4,a1
    80004d52:	8ab2                	mv	s5,a2
    80004d54:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004d56:	fb040593          	addi	a1,s0,-80
    80004d5a:	e85fe0ef          	jal	80003bde <nameiparent>
    80004d5e:	84aa                	mv	s1,a0
    80004d60:	10050763          	beqz	a0,80004e6e <create+0x134>
    return 0;

  ilock(dp);
    80004d64:	e0cfe0ef          	jal	80003370 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004d68:	4601                	li	a2,0
    80004d6a:	fb040593          	addi	a1,s0,-80
    80004d6e:	8526                	mv	a0,s1
    80004d70:	bc1fe0ef          	jal	80003930 <dirlookup>
    80004d74:	89aa                	mv	s3,a0
    80004d76:	c131                	beqz	a0,80004dba <create+0x80>
    iunlockput(dp);
    80004d78:	8526                	mv	a0,s1
    80004d7a:	825fe0ef          	jal	8000359e <iunlockput>
    ilock(ip);
    80004d7e:	854e                	mv	a0,s3
    80004d80:	df0fe0ef          	jal	80003370 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004d84:	4789                	li	a5,2
    80004d86:	02f91563          	bne	s2,a5,80004db0 <create+0x76>
    80004d8a:	0449d783          	lhu	a5,68(s3)
    80004d8e:	37f9                	addiw	a5,a5,-2
    80004d90:	17c2                	slli	a5,a5,0x30
    80004d92:	93c1                	srli	a5,a5,0x30
    80004d94:	4705                	li	a4,1
    80004d96:	00f76d63          	bltu	a4,a5,80004db0 <create+0x76>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004d9a:	854e                	mv	a0,s3
    80004d9c:	60a6                	ld	ra,72(sp)
    80004d9e:	6406                	ld	s0,64(sp)
    80004da0:	74e2                	ld	s1,56(sp)
    80004da2:	7942                	ld	s2,48(sp)
    80004da4:	79a2                	ld	s3,40(sp)
    80004da6:	7a02                	ld	s4,32(sp)
    80004da8:	6ae2                	ld	s5,24(sp)
    80004daa:	6b42                	ld	s6,16(sp)
    80004dac:	6161                	addi	sp,sp,80
    80004dae:	8082                	ret
    iunlockput(ip);
    80004db0:	854e                	mv	a0,s3
    80004db2:	fecfe0ef          	jal	8000359e <iunlockput>
    return 0;
    80004db6:	4981                	li	s3,0
    80004db8:	b7cd                	j	80004d9a <create+0x60>
  if((ip = ialloc(dp->dev, type)) == 0){
    80004dba:	85ca                	mv	a1,s2
    80004dbc:	4088                	lw	a0,0(s1)
    80004dbe:	bfcfe0ef          	jal	800031ba <ialloc>
    80004dc2:	892a                	mv	s2,a0
    80004dc4:	cd15                	beqz	a0,80004e00 <create+0xc6>
  ilock(ip);
    80004dc6:	daafe0ef          	jal	80003370 <ilock>
  ip->major = major;
    80004dca:	05591323          	sh	s5,70(s2)
  ip->minor = minor;
    80004dce:	05691423          	sh	s6,72(s2)
  ip->nlink = 1;
    80004dd2:	4785                	li	a5,1
    80004dd4:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004dd8:	854a                	mv	a0,s2
    80004dda:	cc4fe0ef          	jal	8000329e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004dde:	4705                	li	a4,1
    80004de0:	02ea0463          	beq	s4,a4,80004e08 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004de4:	00492603          	lw	a2,4(s2)
    80004de8:	fb040593          	addi	a1,s0,-80
    80004dec:	8526                	mv	a0,s1
    80004dee:	d2dfe0ef          	jal	80003b1a <dirlink>
    80004df2:	06054263          	bltz	a0,80004e56 <create+0x11c>
  iunlockput(dp);
    80004df6:	8526                	mv	a0,s1
    80004df8:	fa6fe0ef          	jal	8000359e <iunlockput>
  return ip;
    80004dfc:	89ca                	mv	s3,s2
    80004dfe:	bf71                	j	80004d9a <create+0x60>
    iunlockput(dp);
    80004e00:	8526                	mv	a0,s1
    80004e02:	f9cfe0ef          	jal	8000359e <iunlockput>
    return 0;
    80004e06:	bf51                	j	80004d9a <create+0x60>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004e08:	00492603          	lw	a2,4(s2)
    80004e0c:	00004597          	auipc	a1,0x4
    80004e10:	99458593          	addi	a1,a1,-1644 # 800087a0 <etext+0x7a0>
    80004e14:	854a                	mv	a0,s2
    80004e16:	d05fe0ef          	jal	80003b1a <dirlink>
    80004e1a:	02054e63          	bltz	a0,80004e56 <create+0x11c>
    80004e1e:	40d0                	lw	a2,4(s1)
    80004e20:	00004597          	auipc	a1,0x4
    80004e24:	98858593          	addi	a1,a1,-1656 # 800087a8 <etext+0x7a8>
    80004e28:	854a                	mv	a0,s2
    80004e2a:	cf1fe0ef          	jal	80003b1a <dirlink>
    80004e2e:	02054463          	bltz	a0,80004e56 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004e32:	00492603          	lw	a2,4(s2)
    80004e36:	fb040593          	addi	a1,s0,-80
    80004e3a:	8526                	mv	a0,s1
    80004e3c:	cdffe0ef          	jal	80003b1a <dirlink>
    80004e40:	00054b63          	bltz	a0,80004e56 <create+0x11c>
    dp->nlink++;  // for ".."
    80004e44:	04a4d783          	lhu	a5,74(s1)
    80004e48:	2785                	addiw	a5,a5,1
    80004e4a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004e4e:	8526                	mv	a0,s1
    80004e50:	c4efe0ef          	jal	8000329e <iupdate>
    80004e54:	b74d                	j	80004df6 <create+0xbc>
  ip->nlink = 0;
    80004e56:	04091523          	sh	zero,74(s2)
  iupdate(ip);
    80004e5a:	854a                	mv	a0,s2
    80004e5c:	c42fe0ef          	jal	8000329e <iupdate>
  iunlockput(ip);
    80004e60:	854a                	mv	a0,s2
    80004e62:	f3cfe0ef          	jal	8000359e <iunlockput>
  iunlockput(dp);
    80004e66:	8526                	mv	a0,s1
    80004e68:	f36fe0ef          	jal	8000359e <iunlockput>
  return 0;
    80004e6c:	b73d                	j	80004d9a <create+0x60>
    return 0;
    80004e6e:	89aa                	mv	s3,a0
    80004e70:	b72d                	j	80004d9a <create+0x60>

0000000080004e72 <sys_dup>:
{
    80004e72:	7179                	addi	sp,sp,-48
    80004e74:	f406                	sd	ra,40(sp)
    80004e76:	f022                	sd	s0,32(sp)
    80004e78:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004e7a:	fd840613          	addi	a2,s0,-40
    80004e7e:	4581                	li	a1,0
    80004e80:	4501                	li	a0,0
    80004e82:	e1fff0ef          	jal	80004ca0 <argfd>
    return -1;
    80004e86:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004e88:	02054363          	bltz	a0,80004eae <sys_dup+0x3c>
    80004e8c:	ec26                	sd	s1,24(sp)
    80004e8e:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004e90:	fd843483          	ld	s1,-40(s0)
    80004e94:	8526                	mv	a0,s1
    80004e96:	e65ff0ef          	jal	80004cfa <fdalloc>
    80004e9a:	892a                	mv	s2,a0
    return -1;
    80004e9c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004e9e:	00054d63          	bltz	a0,80004eb8 <sys_dup+0x46>
  filedup(f);
    80004ea2:	8526                	mv	a0,s1
    80004ea4:	b4cff0ef          	jal	800041f0 <filedup>
  return fd;
    80004ea8:	87ca                	mv	a5,s2
    80004eaa:	64e2                	ld	s1,24(sp)
    80004eac:	6942                	ld	s2,16(sp)
}
    80004eae:	853e                	mv	a0,a5
    80004eb0:	70a2                	ld	ra,40(sp)
    80004eb2:	7402                	ld	s0,32(sp)
    80004eb4:	6145                	addi	sp,sp,48
    80004eb6:	8082                	ret
    80004eb8:	64e2                	ld	s1,24(sp)
    80004eba:	6942                	ld	s2,16(sp)
    80004ebc:	bfcd                	j	80004eae <sys_dup+0x3c>

0000000080004ebe <sys_read>:
{
    80004ebe:	7179                	addi	sp,sp,-48
    80004ec0:	f406                	sd	ra,40(sp)
    80004ec2:	f022                	sd	s0,32(sp)
    80004ec4:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004ec6:	fd840593          	addi	a1,s0,-40
    80004eca:	4505                	li	a0,1
    80004ecc:	aaffd0ef          	jal	8000297a <argaddr>
  argint(2, &n);
    80004ed0:	fe440593          	addi	a1,s0,-28
    80004ed4:	4509                	li	a0,2
    80004ed6:	a87fd0ef          	jal	8000295c <argint>
  if(argfd(0, 0, &f) < 0)
    80004eda:	fe840613          	addi	a2,s0,-24
    80004ede:	4581                	li	a1,0
    80004ee0:	4501                	li	a0,0
    80004ee2:	dbfff0ef          	jal	80004ca0 <argfd>
    80004ee6:	87aa                	mv	a5,a0
    return -1;
    80004ee8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004eea:	0007ca63          	bltz	a5,80004efe <sys_read+0x40>
  return fileread(f, p, n);
    80004eee:	fe442603          	lw	a2,-28(s0)
    80004ef2:	fd843583          	ld	a1,-40(s0)
    80004ef6:	fe843503          	ld	a0,-24(s0)
    80004efa:	c60ff0ef          	jal	8000435a <fileread>
}
    80004efe:	70a2                	ld	ra,40(sp)
    80004f00:	7402                	ld	s0,32(sp)
    80004f02:	6145                	addi	sp,sp,48
    80004f04:	8082                	ret

0000000080004f06 <sys_write>:
{
    80004f06:	7179                	addi	sp,sp,-48
    80004f08:	f406                	sd	ra,40(sp)
    80004f0a:	f022                	sd	s0,32(sp)
    80004f0c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004f0e:	fd840593          	addi	a1,s0,-40
    80004f12:	4505                	li	a0,1
    80004f14:	a67fd0ef          	jal	8000297a <argaddr>
  argint(2, &n);
    80004f18:	fe440593          	addi	a1,s0,-28
    80004f1c:	4509                	li	a0,2
    80004f1e:	a3ffd0ef          	jal	8000295c <argint>
  if(argfd(0, 0, &f) < 0)
    80004f22:	fe840613          	addi	a2,s0,-24
    80004f26:	4581                	li	a1,0
    80004f28:	4501                	li	a0,0
    80004f2a:	d77ff0ef          	jal	80004ca0 <argfd>
    80004f2e:	87aa                	mv	a5,a0
    return -1;
    80004f30:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004f32:	0007ca63          	bltz	a5,80004f46 <sys_write+0x40>
  return filewrite(f, p, n);
    80004f36:	fe442603          	lw	a2,-28(s0)
    80004f3a:	fd843583          	ld	a1,-40(s0)
    80004f3e:	fe843503          	ld	a0,-24(s0)
    80004f42:	d40ff0ef          	jal	80004482 <filewrite>
}
    80004f46:	70a2                	ld	ra,40(sp)
    80004f48:	7402                	ld	s0,32(sp)
    80004f4a:	6145                	addi	sp,sp,48
    80004f4c:	8082                	ret

0000000080004f4e <sys_close>:
{
    80004f4e:	1101                	addi	sp,sp,-32
    80004f50:	ec06                	sd	ra,24(sp)
    80004f52:	e822                	sd	s0,16(sp)
    80004f54:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004f56:	fe040613          	addi	a2,s0,-32
    80004f5a:	fec40593          	addi	a1,s0,-20
    80004f5e:	4501                	li	a0,0
    80004f60:	d41ff0ef          	jal	80004ca0 <argfd>
    return -1;
    80004f64:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004f66:	02054163          	bltz	a0,80004f88 <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80004f6a:	9cdfc0ef          	jal	80001936 <myproc>
    80004f6e:	fec42783          	lw	a5,-20(s0)
    80004f72:	078e                	slli	a5,a5,0x3
    80004f74:	0d078793          	addi	a5,a5,208
    80004f78:	953e                	add	a0,a0,a5
    80004f7a:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004f7e:	fe043503          	ld	a0,-32(s0)
    80004f82:	ab4ff0ef          	jal	80004236 <fileclose>
  return 0;
    80004f86:	4781                	li	a5,0
}
    80004f88:	853e                	mv	a0,a5
    80004f8a:	60e2                	ld	ra,24(sp)
    80004f8c:	6442                	ld	s0,16(sp)
    80004f8e:	6105                	addi	sp,sp,32
    80004f90:	8082                	ret

0000000080004f92 <sys_fstat>:
{
    80004f92:	1101                	addi	sp,sp,-32
    80004f94:	ec06                	sd	ra,24(sp)
    80004f96:	e822                	sd	s0,16(sp)
    80004f98:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004f9a:	fe040593          	addi	a1,s0,-32
    80004f9e:	4505                	li	a0,1
    80004fa0:	9dbfd0ef          	jal	8000297a <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004fa4:	fe840613          	addi	a2,s0,-24
    80004fa8:	4581                	li	a1,0
    80004faa:	4501                	li	a0,0
    80004fac:	cf5ff0ef          	jal	80004ca0 <argfd>
    80004fb0:	87aa                	mv	a5,a0
    return -1;
    80004fb2:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004fb4:	0007c863          	bltz	a5,80004fc4 <sys_fstat+0x32>
  return filestat(f, st);
    80004fb8:	fe043583          	ld	a1,-32(s0)
    80004fbc:	fe843503          	ld	a0,-24(s0)
    80004fc0:	b38ff0ef          	jal	800042f8 <filestat>
}
    80004fc4:	60e2                	ld	ra,24(sp)
    80004fc6:	6442                	ld	s0,16(sp)
    80004fc8:	6105                	addi	sp,sp,32
    80004fca:	8082                	ret

0000000080004fcc <sys_link>:
{
    80004fcc:	7169                	addi	sp,sp,-304
    80004fce:	f606                	sd	ra,296(sp)
    80004fd0:	f222                	sd	s0,288(sp)
    80004fd2:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004fd4:	08000613          	li	a2,128
    80004fd8:	ed040593          	addi	a1,s0,-304
    80004fdc:	4501                	li	a0,0
    80004fde:	9bbfd0ef          	jal	80002998 <argstr>
    return -1;
    80004fe2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004fe4:	0c054e63          	bltz	a0,800050c0 <sys_link+0xf4>
    80004fe8:	08000613          	li	a2,128
    80004fec:	f5040593          	addi	a1,s0,-176
    80004ff0:	4505                	li	a0,1
    80004ff2:	9a7fd0ef          	jal	80002998 <argstr>
    return -1;
    80004ff6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004ff8:	0c054463          	bltz	a0,800050c0 <sys_link+0xf4>
    80004ffc:	ee26                	sd	s1,280(sp)
  begin_op();
    80004ffe:	da5fe0ef          	jal	80003da2 <begin_op>
  if((ip = namei(old)) == 0){
    80005002:	ed040513          	addi	a0,s0,-304
    80005006:	bbffe0ef          	jal	80003bc4 <namei>
    8000500a:	84aa                	mv	s1,a0
    8000500c:	c53d                	beqz	a0,8000507a <sys_link+0xae>
  ilock(ip);
    8000500e:	b62fe0ef          	jal	80003370 <ilock>
  if(ip->type == T_DIR){
    80005012:	04449703          	lh	a4,68(s1)
    80005016:	4785                	li	a5,1
    80005018:	06f70663          	beq	a4,a5,80005084 <sys_link+0xb8>
    8000501c:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    8000501e:	04a4d783          	lhu	a5,74(s1)
    80005022:	2785                	addiw	a5,a5,1
    80005024:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005028:	8526                	mv	a0,s1
    8000502a:	a74fe0ef          	jal	8000329e <iupdate>
  iunlock(ip);
    8000502e:	8526                	mv	a0,s1
    80005030:	c10fe0ef          	jal	80003440 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005034:	fd040593          	addi	a1,s0,-48
    80005038:	f5040513          	addi	a0,s0,-176
    8000503c:	ba3fe0ef          	jal	80003bde <nameiparent>
    80005040:	892a                	mv	s2,a0
    80005042:	cd21                	beqz	a0,8000509a <sys_link+0xce>
  ilock(dp);
    80005044:	b2cfe0ef          	jal	80003370 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005048:	854a                	mv	a0,s2
    8000504a:	00092703          	lw	a4,0(s2)
    8000504e:	409c                	lw	a5,0(s1)
    80005050:	04f71263          	bne	a4,a5,80005094 <sys_link+0xc8>
    80005054:	40d0                	lw	a2,4(s1)
    80005056:	fd040593          	addi	a1,s0,-48
    8000505a:	ac1fe0ef          	jal	80003b1a <dirlink>
    8000505e:	02054b63          	bltz	a0,80005094 <sys_link+0xc8>
  iunlockput(dp);
    80005062:	854a                	mv	a0,s2
    80005064:	d3afe0ef          	jal	8000359e <iunlockput>
  iput(ip);
    80005068:	8526                	mv	a0,s1
    8000506a:	caafe0ef          	jal	80003514 <iput>
  end_op();
    8000506e:	da5fe0ef          	jal	80003e12 <end_op>
  return 0;
    80005072:	4781                	li	a5,0
    80005074:	64f2                	ld	s1,280(sp)
    80005076:	6952                	ld	s2,272(sp)
    80005078:	a0a1                	j	800050c0 <sys_link+0xf4>
    end_op();
    8000507a:	d99fe0ef          	jal	80003e12 <end_op>
    return -1;
    8000507e:	57fd                	li	a5,-1
    80005080:	64f2                	ld	s1,280(sp)
    80005082:	a83d                	j	800050c0 <sys_link+0xf4>
    iunlockput(ip);
    80005084:	8526                	mv	a0,s1
    80005086:	d18fe0ef          	jal	8000359e <iunlockput>
    end_op();
    8000508a:	d89fe0ef          	jal	80003e12 <end_op>
    return -1;
    8000508e:	57fd                	li	a5,-1
    80005090:	64f2                	ld	s1,280(sp)
    80005092:	a03d                	j	800050c0 <sys_link+0xf4>
    iunlockput(dp);
    80005094:	854a                	mv	a0,s2
    80005096:	d08fe0ef          	jal	8000359e <iunlockput>
  ilock(ip);
    8000509a:	8526                	mv	a0,s1
    8000509c:	ad4fe0ef          	jal	80003370 <ilock>
  ip->nlink--;
    800050a0:	04a4d783          	lhu	a5,74(s1)
    800050a4:	37fd                	addiw	a5,a5,-1
    800050a6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800050aa:	8526                	mv	a0,s1
    800050ac:	9f2fe0ef          	jal	8000329e <iupdate>
  iunlockput(ip);
    800050b0:	8526                	mv	a0,s1
    800050b2:	cecfe0ef          	jal	8000359e <iunlockput>
  end_op();
    800050b6:	d5dfe0ef          	jal	80003e12 <end_op>
  return -1;
    800050ba:	57fd                	li	a5,-1
    800050bc:	64f2                	ld	s1,280(sp)
    800050be:	6952                	ld	s2,272(sp)
}
    800050c0:	853e                	mv	a0,a5
    800050c2:	70b2                	ld	ra,296(sp)
    800050c4:	7412                	ld	s0,288(sp)
    800050c6:	6155                	addi	sp,sp,304
    800050c8:	8082                	ret

00000000800050ca <sys_unlink>:
{
    800050ca:	7151                	addi	sp,sp,-240
    800050cc:	f586                	sd	ra,232(sp)
    800050ce:	f1a2                	sd	s0,224(sp)
    800050d0:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800050d2:	08000613          	li	a2,128
    800050d6:	f3040593          	addi	a1,s0,-208
    800050da:	4501                	li	a0,0
    800050dc:	8bdfd0ef          	jal	80002998 <argstr>
    800050e0:	14054d63          	bltz	a0,8000523a <sys_unlink+0x170>
    800050e4:	eda6                	sd	s1,216(sp)
  begin_op();
    800050e6:	cbdfe0ef          	jal	80003da2 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800050ea:	fb040593          	addi	a1,s0,-80
    800050ee:	f3040513          	addi	a0,s0,-208
    800050f2:	aedfe0ef          	jal	80003bde <nameiparent>
    800050f6:	84aa                	mv	s1,a0
    800050f8:	c955                	beqz	a0,800051ac <sys_unlink+0xe2>
  ilock(dp);
    800050fa:	a76fe0ef          	jal	80003370 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800050fe:	00003597          	auipc	a1,0x3
    80005102:	6a258593          	addi	a1,a1,1698 # 800087a0 <etext+0x7a0>
    80005106:	fb040513          	addi	a0,s0,-80
    8000510a:	811fe0ef          	jal	8000391a <namecmp>
    8000510e:	10050b63          	beqz	a0,80005224 <sys_unlink+0x15a>
    80005112:	00003597          	auipc	a1,0x3
    80005116:	69658593          	addi	a1,a1,1686 # 800087a8 <etext+0x7a8>
    8000511a:	fb040513          	addi	a0,s0,-80
    8000511e:	ffcfe0ef          	jal	8000391a <namecmp>
    80005122:	10050163          	beqz	a0,80005224 <sys_unlink+0x15a>
    80005126:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005128:	f2c40613          	addi	a2,s0,-212
    8000512c:	fb040593          	addi	a1,s0,-80
    80005130:	8526                	mv	a0,s1
    80005132:	ffefe0ef          	jal	80003930 <dirlookup>
    80005136:	892a                	mv	s2,a0
    80005138:	0e050563          	beqz	a0,80005222 <sys_unlink+0x158>
    8000513c:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    8000513e:	a32fe0ef          	jal	80003370 <ilock>
  if(ip->nlink < 1)
    80005142:	04a91783          	lh	a5,74(s2)
    80005146:	06f05863          	blez	a5,800051b6 <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000514a:	04491703          	lh	a4,68(s2)
    8000514e:	4785                	li	a5,1
    80005150:	06f70963          	beq	a4,a5,800051c2 <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    80005154:	fc040993          	addi	s3,s0,-64
    80005158:	4641                	li	a2,16
    8000515a:	4581                	li	a1,0
    8000515c:	854e                	mv	a0,s3
    8000515e:	b9bfb0ef          	jal	80000cf8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005162:	4741                	li	a4,16
    80005164:	f2c42683          	lw	a3,-212(s0)
    80005168:	864e                	mv	a2,s3
    8000516a:	4581                	li	a1,0
    8000516c:	8526                	mv	a0,s1
    8000516e:	eacfe0ef          	jal	8000381a <writei>
    80005172:	47c1                	li	a5,16
    80005174:	08f51863          	bne	a0,a5,80005204 <sys_unlink+0x13a>
  if(ip->type == T_DIR){
    80005178:	04491703          	lh	a4,68(s2)
    8000517c:	4785                	li	a5,1
    8000517e:	08f70963          	beq	a4,a5,80005210 <sys_unlink+0x146>
  iunlockput(dp);
    80005182:	8526                	mv	a0,s1
    80005184:	c1afe0ef          	jal	8000359e <iunlockput>
  ip->nlink--;
    80005188:	04a95783          	lhu	a5,74(s2)
    8000518c:	37fd                	addiw	a5,a5,-1
    8000518e:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005192:	854a                	mv	a0,s2
    80005194:	90afe0ef          	jal	8000329e <iupdate>
  iunlockput(ip);
    80005198:	854a                	mv	a0,s2
    8000519a:	c04fe0ef          	jal	8000359e <iunlockput>
  end_op();
    8000519e:	c75fe0ef          	jal	80003e12 <end_op>
  return 0;
    800051a2:	4501                	li	a0,0
    800051a4:	64ee                	ld	s1,216(sp)
    800051a6:	694e                	ld	s2,208(sp)
    800051a8:	69ae                	ld	s3,200(sp)
    800051aa:	a061                	j	80005232 <sys_unlink+0x168>
    end_op();
    800051ac:	c67fe0ef          	jal	80003e12 <end_op>
    return -1;
    800051b0:	557d                	li	a0,-1
    800051b2:	64ee                	ld	s1,216(sp)
    800051b4:	a8bd                	j	80005232 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    800051b6:	00003517          	auipc	a0,0x3
    800051ba:	5fa50513          	addi	a0,a0,1530 # 800087b0 <etext+0x7b0>
    800051be:	e66fb0ef          	jal	80000824 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800051c2:	04c92703          	lw	a4,76(s2)
    800051c6:	02000793          	li	a5,32
    800051ca:	f8e7f5e3          	bgeu	a5,a4,80005154 <sys_unlink+0x8a>
    800051ce:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800051d0:	4741                	li	a4,16
    800051d2:	86ce                	mv	a3,s3
    800051d4:	f1840613          	addi	a2,s0,-232
    800051d8:	4581                	li	a1,0
    800051da:	854a                	mv	a0,s2
    800051dc:	d4cfe0ef          	jal	80003728 <readi>
    800051e0:	47c1                	li	a5,16
    800051e2:	00f51b63          	bne	a0,a5,800051f8 <sys_unlink+0x12e>
    if(de.inum != 0)
    800051e6:	f1845783          	lhu	a5,-232(s0)
    800051ea:	ebb1                	bnez	a5,8000523e <sys_unlink+0x174>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800051ec:	29c1                	addiw	s3,s3,16
    800051ee:	04c92783          	lw	a5,76(s2)
    800051f2:	fcf9efe3          	bltu	s3,a5,800051d0 <sys_unlink+0x106>
    800051f6:	bfb9                	j	80005154 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    800051f8:	00003517          	auipc	a0,0x3
    800051fc:	5d050513          	addi	a0,a0,1488 # 800087c8 <etext+0x7c8>
    80005200:	e24fb0ef          	jal	80000824 <panic>
    panic("unlink: writei");
    80005204:	00003517          	auipc	a0,0x3
    80005208:	5dc50513          	addi	a0,a0,1500 # 800087e0 <etext+0x7e0>
    8000520c:	e18fb0ef          	jal	80000824 <panic>
    dp->nlink--;
    80005210:	04a4d783          	lhu	a5,74(s1)
    80005214:	37fd                	addiw	a5,a5,-1
    80005216:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000521a:	8526                	mv	a0,s1
    8000521c:	882fe0ef          	jal	8000329e <iupdate>
    80005220:	b78d                	j	80005182 <sys_unlink+0xb8>
    80005222:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005224:	8526                	mv	a0,s1
    80005226:	b78fe0ef          	jal	8000359e <iunlockput>
  end_op();
    8000522a:	be9fe0ef          	jal	80003e12 <end_op>
  return -1;
    8000522e:	557d                	li	a0,-1
    80005230:	64ee                	ld	s1,216(sp)
}
    80005232:	70ae                	ld	ra,232(sp)
    80005234:	740e                	ld	s0,224(sp)
    80005236:	616d                	addi	sp,sp,240
    80005238:	8082                	ret
    return -1;
    8000523a:	557d                	li	a0,-1
    8000523c:	bfdd                	j	80005232 <sys_unlink+0x168>
    iunlockput(ip);
    8000523e:	854a                	mv	a0,s2
    80005240:	b5efe0ef          	jal	8000359e <iunlockput>
    goto bad;
    80005244:	694e                	ld	s2,208(sp)
    80005246:	69ae                	ld	s3,200(sp)
    80005248:	bff1                	j	80005224 <sys_unlink+0x15a>

000000008000524a <sys_open>:

uint64
sys_open(void)
{
    8000524a:	7131                	addi	sp,sp,-192
    8000524c:	fd06                	sd	ra,184(sp)
    8000524e:	f922                	sd	s0,176(sp)
    80005250:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005252:	f4c40593          	addi	a1,s0,-180
    80005256:	4505                	li	a0,1
    80005258:	f04fd0ef          	jal	8000295c <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000525c:	08000613          	li	a2,128
    80005260:	f5040593          	addi	a1,s0,-176
    80005264:	4501                	li	a0,0
    80005266:	f32fd0ef          	jal	80002998 <argstr>
    8000526a:	87aa                	mv	a5,a0
    return -1;
    8000526c:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000526e:	1007c763          	bltz	a5,8000537c <sys_open+0x132>
    80005272:	f526                	sd	s1,168(sp)

  printf("sys_open: path=%s uid=%d gid=%d\n", path, myproc()->creds.uid, myproc()->creds.gid);
    80005274:	ec2fc0ef          	jal	80001936 <myproc>
    80005278:	16852483          	lw	s1,360(a0)
    8000527c:	ebafc0ef          	jal	80001936 <myproc>
    80005280:	16c52683          	lw	a3,364(a0)
    80005284:	8626                	mv	a2,s1
    80005286:	f5040593          	addi	a1,s0,-176
    8000528a:	00003517          	auipc	a0,0x3
    8000528e:	56650513          	addi	a0,a0,1382 # 800087f0 <etext+0x7f0>
    80005292:	a68fb0ef          	jal	800004fa <printf>

  begin_op();
    80005296:	b0dfe0ef          	jal	80003da2 <begin_op>

  if(omode & O_CREATE){
    8000529a:	f4c42783          	lw	a5,-180(s0)
    8000529e:	2007f793          	andi	a5,a5,512
    800052a2:	0e078663          	beqz	a5,8000538e <sys_open+0x144>
    ip = create(path, T_FILE, 0, 0);
    800052a6:	4681                	li	a3,0
    800052a8:	4601                	li	a2,0
    800052aa:	4589                	li	a1,2
    800052ac:	f5040513          	addi	a0,s0,-176
    800052b0:	a8bff0ef          	jal	80004d3a <create>
    800052b4:	84aa                	mv	s1,a0
    if(ip == 0){
    800052b6:	c579                	beqz	a0,80005384 <sys_open+0x13a>
    800052b8:	f14a                	sd	s2,160(sp)
      return -1;
    }
  }

  // === NEW: Check open-time permissions (before filealloc) ===
  struct proc *p = myproc();
    800052ba:	e7cfc0ef          	jal	80001936 <myproc>
    800052be:	892a                	mv	s2,a0
  int need_read  = (omode == O_RDONLY || omode == O_RDWR) ? 1 : 0;
    800052c0:	f4c42783          	lw	a5,-180(s0)
    800052c4:	ffd7f713          	andi	a4,a5,-3
    800052c8:	00173713          	seqz	a4,a4
  int need_write = (omode == O_WRONLY || omode == O_RDWR ||
                    (omode & O_TRUNC)  || (omode & O_APPEND)) ? 2 : 0;
    800052cc:	fff7861b          	addiw	a2,a5,-1
    800052d0:	4685                	li	a3,1
  int need_write = (omode == O_WRONLY || omode == O_RDWR ||
    800052d2:	4589                	li	a1,2
                    (omode & O_TRUNC)  || (omode & O_APPEND)) ? 2 : 0;
    800052d4:	00c6fa63          	bgeu	a3,a2,800052e8 <sys_open+0x9e>
    800052d8:	6685                	lui	a3,0x1
    800052da:	c0068693          	addi	a3,a3,-1024 # c00 <_entry-0x7ffff400>
    800052de:	8ff5                	and	a5,a5,a3
    800052e0:	00f037b3          	snez	a5,a5
    800052e4:	00179593          	slli	a1,a5,0x1

  if (check_permission(ip, need_read | need_write,
    800052e8:	16c92683          	lw	a3,364(s2)
    800052ec:	16892603          	lw	a2,360(s2)
    800052f0:	8dd9                	or	a1,a1,a4
    800052f2:	8526                	mv	a0,s1
    800052f4:	e0bfe0ef          	jal	800040fe <check_permission>
    800052f8:	0c054963          	bltz	a0,800053ca <sys_open+0x180>
    audit_log_event(p->pid, p->creds.uid, SYS_open, "DENIED:open_permission");
    return -1;
  }
  // === END NEW ===

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800052fc:	04449703          	lh	a4,68(s1)
    80005300:	478d                	li	a5,3
    80005302:	00f71763          	bne	a4,a5,80005310 <sys_open+0xc6>
    80005306:	0464d703          	lhu	a4,70(s1)
    8000530a:	47a5                	li	a5,9
    8000530c:	0ee7e363          	bltu	a5,a4,800053f2 <sys_open+0x1a8>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005310:	e83fe0ef          	jal	80004192 <filealloc>
    80005314:	892a                	mv	s2,a0
    80005316:	0e050b63          	beqz	a0,8000540c <sys_open+0x1c2>
    8000531a:	ed4e                	sd	s3,152(sp)
    8000531c:	9dfff0ef          	jal	80004cfa <fdalloc>
    80005320:	89aa                	mv	s3,a0
    80005322:	0e054163          	bltz	a0,80005404 <sys_open+0x1ba>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005326:	04449703          	lh	a4,68(s1)
    8000532a:	478d                	li	a5,3
    8000532c:	0ef70963          	beq	a4,a5,8000541e <sys_open+0x1d4>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005330:	4789                	li	a5,2
    80005332:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005336:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000533a:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000533e:	f4c42783          	lw	a5,-180(s0)
    80005342:	0017f713          	andi	a4,a5,1
    80005346:	00174713          	xori	a4,a4,1
    8000534a:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000534e:	0037f713          	andi	a4,a5,3
    80005352:	00e03733          	snez	a4,a4
    80005356:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000535a:	4007f793          	andi	a5,a5,1024
    8000535e:	c791                	beqz	a5,8000536a <sys_open+0x120>
    80005360:	04449703          	lh	a4,68(s1)
    80005364:	4789                	li	a5,2
    80005366:	0cf70363          	beq	a4,a5,8000542c <sys_open+0x1e2>
    itrunc(ip);
  }

  iunlock(ip);
    8000536a:	8526                	mv	a0,s1
    8000536c:	8d4fe0ef          	jal	80003440 <iunlock>
  end_op();
    80005370:	aa3fe0ef          	jal	80003e12 <end_op>

  return fd;
    80005374:	854e                	mv	a0,s3
    80005376:	74aa                	ld	s1,168(sp)
    80005378:	790a                	ld	s2,160(sp)
    8000537a:	69ea                	ld	s3,152(sp)
}
    8000537c:	70ea                	ld	ra,184(sp)
    8000537e:	744a                	ld	s0,176(sp)
    80005380:	6129                	addi	sp,sp,192
    80005382:	8082                	ret
      end_op();
    80005384:	a8ffe0ef          	jal	80003e12 <end_op>
      return -1;
    80005388:	557d                	li	a0,-1
    8000538a:	74aa                	ld	s1,168(sp)
    8000538c:	bfc5                	j	8000537c <sys_open+0x132>
    if((ip = namei(path)) == 0){
    8000538e:	f5040513          	addi	a0,s0,-176
    80005392:	833fe0ef          	jal	80003bc4 <namei>
    80005396:	84aa                	mv	s1,a0
    80005398:	c505                	beqz	a0,800053c0 <sys_open+0x176>
    ilock(ip);
    8000539a:	fd7fd0ef          	jal	80003370 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000539e:	04449703          	lh	a4,68(s1)
    800053a2:	4785                	li	a5,1
    800053a4:	f0f71ae3          	bne	a4,a5,800052b8 <sys_open+0x6e>
    800053a8:	f4c42783          	lw	a5,-180(s0)
    800053ac:	f00786e3          	beqz	a5,800052b8 <sys_open+0x6e>
      iunlockput(ip);
    800053b0:	8526                	mv	a0,s1
    800053b2:	9ecfe0ef          	jal	8000359e <iunlockput>
      end_op();
    800053b6:	a5dfe0ef          	jal	80003e12 <end_op>
      return -1;
    800053ba:	557d                	li	a0,-1
    800053bc:	74aa                	ld	s1,168(sp)
    800053be:	bf7d                	j	8000537c <sys_open+0x132>
      end_op();
    800053c0:	a53fe0ef          	jal	80003e12 <end_op>
      return -1;
    800053c4:	557d                	li	a0,-1
    800053c6:	74aa                	ld	s1,168(sp)
    800053c8:	bf55                	j	8000537c <sys_open+0x132>
    iunlockput(ip);
    800053ca:	8526                	mv	a0,s1
    800053cc:	9d2fe0ef          	jal	8000359e <iunlockput>
    end_op();
    800053d0:	a43fe0ef          	jal	80003e12 <end_op>
    audit_log_event(p->pid, p->creds.uid, SYS_open, "DENIED:open_permission");
    800053d4:	00003697          	auipc	a3,0x3
    800053d8:	44468693          	addi	a3,a3,1092 # 80008818 <etext+0x818>
    800053dc:	463d                	li	a2,15
    800053de:	16892583          	lw	a1,360(s2)
    800053e2:	03092503          	lw	a0,48(s2)
    800053e6:	3c4010ef          	jal	800067aa <audit_log_event>
    return -1;
    800053ea:	557d                	li	a0,-1
    800053ec:	74aa                	ld	s1,168(sp)
    800053ee:	790a                	ld	s2,160(sp)
    800053f0:	b771                	j	8000537c <sys_open+0x132>
    iunlockput(ip);
    800053f2:	8526                	mv	a0,s1
    800053f4:	9aafe0ef          	jal	8000359e <iunlockput>
    end_op();
    800053f8:	a1bfe0ef          	jal	80003e12 <end_op>
    return -1;
    800053fc:	557d                	li	a0,-1
    800053fe:	74aa                	ld	s1,168(sp)
    80005400:	790a                	ld	s2,160(sp)
    80005402:	bfad                	j	8000537c <sys_open+0x132>
      fileclose(f);
    80005404:	854a                	mv	a0,s2
    80005406:	e31fe0ef          	jal	80004236 <fileclose>
    8000540a:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000540c:	8526                	mv	a0,s1
    8000540e:	990fe0ef          	jal	8000359e <iunlockput>
    end_op();
    80005412:	a01fe0ef          	jal	80003e12 <end_op>
    return -1;
    80005416:	557d                	li	a0,-1
    80005418:	74aa                	ld	s1,168(sp)
    8000541a:	790a                	ld	s2,160(sp)
    8000541c:	b785                	j	8000537c <sys_open+0x132>
    f->type = FD_DEVICE;
    8000541e:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    80005422:	04649783          	lh	a5,70(s1)
    80005426:	02f91223          	sh	a5,36(s2)
    8000542a:	bf01                	j	8000533a <sys_open+0xf0>
    itrunc(ip);
    8000542c:	8526                	mv	a0,s1
    8000542e:	852fe0ef          	jal	80003480 <itrunc>
    80005432:	bf25                	j	8000536a <sys_open+0x120>

0000000080005434 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005434:	7175                	addi	sp,sp,-144
    80005436:	e506                	sd	ra,136(sp)
    80005438:	e122                	sd	s0,128(sp)
    8000543a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000543c:	967fe0ef          	jal	80003da2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005440:	08000613          	li	a2,128
    80005444:	f7040593          	addi	a1,s0,-144
    80005448:	4501                	li	a0,0
    8000544a:	d4efd0ef          	jal	80002998 <argstr>
    8000544e:	02054363          	bltz	a0,80005474 <sys_mkdir+0x40>
    80005452:	4681                	li	a3,0
    80005454:	4601                	li	a2,0
    80005456:	4585                	li	a1,1
    80005458:	f7040513          	addi	a0,s0,-144
    8000545c:	8dfff0ef          	jal	80004d3a <create>
    80005460:	c911                	beqz	a0,80005474 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005462:	93cfe0ef          	jal	8000359e <iunlockput>
  end_op();
    80005466:	9adfe0ef          	jal	80003e12 <end_op>
  return 0;
    8000546a:	4501                	li	a0,0
}
    8000546c:	60aa                	ld	ra,136(sp)
    8000546e:	640a                	ld	s0,128(sp)
    80005470:	6149                	addi	sp,sp,144
    80005472:	8082                	ret
    end_op();
    80005474:	99ffe0ef          	jal	80003e12 <end_op>
    return -1;
    80005478:	557d                	li	a0,-1
    8000547a:	bfcd                	j	8000546c <sys_mkdir+0x38>

000000008000547c <sys_mknod>:

uint64
sys_mknod(void)
{
    8000547c:	7135                	addi	sp,sp,-160
    8000547e:	ed06                	sd	ra,152(sp)
    80005480:	e922                	sd	s0,144(sp)
    80005482:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005484:	91ffe0ef          	jal	80003da2 <begin_op>
  argint(1, &major);
    80005488:	f6c40593          	addi	a1,s0,-148
    8000548c:	4505                	li	a0,1
    8000548e:	ccefd0ef          	jal	8000295c <argint>
  argint(2, &minor);
    80005492:	f6840593          	addi	a1,s0,-152
    80005496:	4509                	li	a0,2
    80005498:	cc4fd0ef          	jal	8000295c <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000549c:	08000613          	li	a2,128
    800054a0:	f7040593          	addi	a1,s0,-144
    800054a4:	4501                	li	a0,0
    800054a6:	cf2fd0ef          	jal	80002998 <argstr>
    800054aa:	02054563          	bltz	a0,800054d4 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800054ae:	f6841683          	lh	a3,-152(s0)
    800054b2:	f6c41603          	lh	a2,-148(s0)
    800054b6:	458d                	li	a1,3
    800054b8:	f7040513          	addi	a0,s0,-144
    800054bc:	87fff0ef          	jal	80004d3a <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800054c0:	c911                	beqz	a0,800054d4 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800054c2:	8dcfe0ef          	jal	8000359e <iunlockput>
  end_op();
    800054c6:	94dfe0ef          	jal	80003e12 <end_op>
  return 0;
    800054ca:	4501                	li	a0,0
}
    800054cc:	60ea                	ld	ra,152(sp)
    800054ce:	644a                	ld	s0,144(sp)
    800054d0:	610d                	addi	sp,sp,160
    800054d2:	8082                	ret
    end_op();
    800054d4:	93ffe0ef          	jal	80003e12 <end_op>
    return -1;
    800054d8:	557d                	li	a0,-1
    800054da:	bfcd                	j	800054cc <sys_mknod+0x50>

00000000800054dc <sys_chdir>:

uint64
sys_chdir(void)
{
    800054dc:	7135                	addi	sp,sp,-160
    800054de:	ed06                	sd	ra,152(sp)
    800054e0:	e922                	sd	s0,144(sp)
    800054e2:	e14a                	sd	s2,128(sp)
    800054e4:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800054e6:	c50fc0ef          	jal	80001936 <myproc>
    800054ea:	892a                	mv	s2,a0
  
  begin_op();
    800054ec:	8b7fe0ef          	jal	80003da2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800054f0:	08000613          	li	a2,128
    800054f4:	f6040593          	addi	a1,s0,-160
    800054f8:	4501                	li	a0,0
    800054fa:	c9efd0ef          	jal	80002998 <argstr>
    800054fe:	04054363          	bltz	a0,80005544 <sys_chdir+0x68>
    80005502:	e526                	sd	s1,136(sp)
    80005504:	f6040513          	addi	a0,s0,-160
    80005508:	ebcfe0ef          	jal	80003bc4 <namei>
    8000550c:	84aa                	mv	s1,a0
    8000550e:	c915                	beqz	a0,80005542 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005510:	e61fd0ef          	jal	80003370 <ilock>
  if(ip->type != T_DIR){
    80005514:	04449703          	lh	a4,68(s1)
    80005518:	4785                	li	a5,1
    8000551a:	02f71963          	bne	a4,a5,8000554c <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000551e:	8526                	mv	a0,s1
    80005520:	f21fd0ef          	jal	80003440 <iunlock>
  iput(p->cwd);
    80005524:	15093503          	ld	a0,336(s2)
    80005528:	fedfd0ef          	jal	80003514 <iput>
  end_op();
    8000552c:	8e7fe0ef          	jal	80003e12 <end_op>
  p->cwd = ip;
    80005530:	14993823          	sd	s1,336(s2)
  return 0;
    80005534:	4501                	li	a0,0
    80005536:	64aa                	ld	s1,136(sp)
}
    80005538:	60ea                	ld	ra,152(sp)
    8000553a:	644a                	ld	s0,144(sp)
    8000553c:	690a                	ld	s2,128(sp)
    8000553e:	610d                	addi	sp,sp,160
    80005540:	8082                	ret
    80005542:	64aa                	ld	s1,136(sp)
    end_op();
    80005544:	8cffe0ef          	jal	80003e12 <end_op>
    return -1;
    80005548:	557d                	li	a0,-1
    8000554a:	b7fd                	j	80005538 <sys_chdir+0x5c>
    iunlockput(ip);
    8000554c:	8526                	mv	a0,s1
    8000554e:	850fe0ef          	jal	8000359e <iunlockput>
    end_op();
    80005552:	8c1fe0ef          	jal	80003e12 <end_op>
    return -1;
    80005556:	557d                	li	a0,-1
    80005558:	64aa                	ld	s1,136(sp)
    8000555a:	bff9                	j	80005538 <sys_chdir+0x5c>

000000008000555c <sys_exec>:

uint64
sys_exec(void)
{
    8000555c:	7105                	addi	sp,sp,-480
    8000555e:	ef86                	sd	ra,472(sp)
    80005560:	eba2                	sd	s0,464(sp)
    80005562:	eb62                	sd	s8,400(sp)
    80005564:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;
  struct proc *p = myproc();
    80005566:	bd0fc0ef          	jal	80001936 <myproc>
    8000556a:	8c2a                	mv	s8,a0

  argaddr(1, &uargv);
    8000556c:	e2840593          	addi	a1,s0,-472
    80005570:	4505                	li	a0,1
    80005572:	c08fd0ef          	jal	8000297a <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005576:	08000613          	li	a2,128
    8000557a:	f3040593          	addi	a1,s0,-208
    8000557e:	4501                	li	a0,0
    80005580:	c18fd0ef          	jal	80002998 <argstr>
    80005584:	87aa                	mv	a5,a0
    return -1;
    80005586:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005588:	1207c663          	bltz	a5,800056b4 <sys_exec+0x158>
    8000558c:	e7a6                	sd	s1,456(sp)
    8000558e:	e3ca                	sd	s2,448(sp)
    80005590:	ff4e                	sd	s3,440(sp)
    80005592:	fb52                	sd	s4,432(sp)
    80005594:	f756                	sd	s5,424(sp)
    80005596:	f35a                	sd	s6,416(sp)
    80005598:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000559a:	e3040a13          	addi	s4,s0,-464
    8000559e:	10000613          	li	a2,256
    800055a2:	4581                	li	a1,0
    800055a4:	8552                	mv	a0,s4
    800055a6:	f52fb0ef          	jal	80000cf8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800055aa:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    800055ac:	89d2                	mv	s3,s4
    800055ae:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800055b0:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800055b4:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    800055b6:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800055ba:	00391793          	slli	a5,s2,0x3
    800055be:	85d6                	mv	a1,s5
    800055c0:	e2843503          	ld	a0,-472(s0)
    800055c4:	953e                	add	a0,a0,a5
    800055c6:	b0cfd0ef          	jal	800028d2 <fetchaddr>
    800055ca:	02054663          	bltz	a0,800055f6 <sys_exec+0x9a>
    if(uarg == 0){
    800055ce:	e2043783          	ld	a5,-480(s0)
    800055d2:	c7a1                	beqz	a5,8000561a <sys_exec+0xbe>
    argv[i] = kalloc();
    800055d4:	d70fb0ef          	jal	80000b44 <kalloc>
    800055d8:	85aa                	mv	a1,a0
    800055da:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800055de:	cd01                	beqz	a0,800055f6 <sys_exec+0x9a>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800055e0:	865a                	mv	a2,s6
    800055e2:	e2043503          	ld	a0,-480(s0)
    800055e6:	b36fd0ef          	jal	8000291c <fetchstr>
    800055ea:	00054663          	bltz	a0,800055f6 <sys_exec+0x9a>
    if(i >= NELEM(argv)){
    800055ee:	0905                	addi	s2,s2,1
    800055f0:	09a1                	addi	s3,s3,8
    800055f2:	fd7914e3          	bne	s2,s7,800055ba <sys_exec+0x5e>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800055f6:	100a0a13          	addi	s4,s4,256
    800055fa:	6088                	ld	a0,0(s1)
    800055fc:	c545                	beqz	a0,800056a4 <sys_exec+0x148>
    kfree(argv[i]);
    800055fe:	c5efb0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005602:	04a1                	addi	s1,s1,8
    80005604:	ff449be3          	bne	s1,s4,800055fa <sys_exec+0x9e>
  return -1;
    80005608:	557d                	li	a0,-1
    8000560a:	64be                	ld	s1,456(sp)
    8000560c:	691e                	ld	s2,448(sp)
    8000560e:	79fa                	ld	s3,440(sp)
    80005610:	7a5a                	ld	s4,432(sp)
    80005612:	7aba                	ld	s5,424(sp)
    80005614:	7b1a                	ld	s6,416(sp)
    80005616:	6bfa                	ld	s7,408(sp)
    80005618:	a871                	j	800056b4 <sys_exec+0x158>
      argv[i] = 0;
    8000561a:	0009079b          	sext.w	a5,s2
    8000561e:	078e                	slli	a5,a5,0x3
    80005620:	fb078793          	addi	a5,a5,-80
    80005624:	97a2                	add	a5,a5,s0
    80005626:	e807b023          	sd	zero,-384(a5)
  struct inode *ip = namei(path);
    8000562a:	f3040513          	addi	a0,s0,-208
    8000562e:	d96fe0ef          	jal	80003bc4 <namei>
    80005632:	892a                	mv	s2,a0
  if (ip) {
    80005634:	c105                	beqz	a0,80005654 <sys_exec+0xf8>
    ilock(ip);
    80005636:	d3bfd0ef          	jal	80003370 <ilock>
    if (check_permission(ip, 4 /*execute*/, p->creds.uid, p->creds.gid) < 0) {
    8000563a:	16cc2683          	lw	a3,364(s8)
    8000563e:	168c2603          	lw	a2,360(s8)
    80005642:	4591                	li	a1,4
    80005644:	854a                	mv	a0,s2
    80005646:	ab9fe0ef          	jal	800040fe <check_permission>
    8000564a:	02054e63          	bltz	a0,80005686 <sys_exec+0x12a>
    iunlockput(ip);
    8000564e:	854a                	mv	a0,s2
    80005650:	f4ffd0ef          	jal	8000359e <iunlockput>
  int ret = kexec(path, argv);
    80005654:	e3040593          	addi	a1,s0,-464
    80005658:	f3040513          	addi	a0,s0,-208
    8000565c:	ae8ff0ef          	jal	80004944 <kexec>
    80005660:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005662:	100a0a13          	addi	s4,s4,256
    80005666:	6088                	ld	a0,0(s1)
    80005668:	c511                	beqz	a0,80005674 <sys_exec+0x118>
    kfree(argv[i]);
    8000566a:	bf2fb0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000566e:	04a1                	addi	s1,s1,8
    80005670:	ff449be3          	bne	s1,s4,80005666 <sys_exec+0x10a>
  return ret;
    80005674:	854a                	mv	a0,s2
    80005676:	64be                	ld	s1,456(sp)
    80005678:	691e                	ld	s2,448(sp)
    8000567a:	79fa                	ld	s3,440(sp)
    8000567c:	7a5a                	ld	s4,432(sp)
    8000567e:	7aba                	ld	s5,424(sp)
    80005680:	7b1a                	ld	s6,416(sp)
    80005682:	6bfa                	ld	s7,408(sp)
    80005684:	a805                	j	800056b4 <sys_exec+0x158>
      iunlockput(ip);
    80005686:	854a                	mv	a0,s2
    80005688:	f17fd0ef          	jal	8000359e <iunlockput>
      audit_log_event(p->pid, p->creds.uid, SYS_exec, "DENIED:exec_permission");
    8000568c:	00003697          	auipc	a3,0x3
    80005690:	1a468693          	addi	a3,a3,420 # 80008830 <etext+0x830>
    80005694:	461d                	li	a2,7
    80005696:	168c2583          	lw	a1,360(s8)
    8000569a:	030c2503          	lw	a0,48(s8)
    8000569e:	10c010ef          	jal	800067aa <audit_log_event>
      goto bad;
    800056a2:	bf91                	j	800055f6 <sys_exec+0x9a>
  return -1;
    800056a4:	557d                	li	a0,-1
    800056a6:	64be                	ld	s1,456(sp)
    800056a8:	691e                	ld	s2,448(sp)
    800056aa:	79fa                	ld	s3,440(sp)
    800056ac:	7a5a                	ld	s4,432(sp)
    800056ae:	7aba                	ld	s5,424(sp)
    800056b0:	7b1a                	ld	s6,416(sp)
    800056b2:	6bfa                	ld	s7,408(sp)
}
    800056b4:	60fe                	ld	ra,472(sp)
    800056b6:	645e                	ld	s0,464(sp)
    800056b8:	6c5a                	ld	s8,400(sp)
    800056ba:	613d                	addi	sp,sp,480
    800056bc:	8082                	ret

00000000800056be <sys_pipe>:

uint64
sys_pipe(void)
{
    800056be:	7139                	addi	sp,sp,-64
    800056c0:	fc06                	sd	ra,56(sp)
    800056c2:	f822                	sd	s0,48(sp)
    800056c4:	f426                	sd	s1,40(sp)
    800056c6:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800056c8:	a6efc0ef          	jal	80001936 <myproc>
    800056cc:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800056ce:	fd840593          	addi	a1,s0,-40
    800056d2:	4501                	li	a0,0
    800056d4:	aa6fd0ef          	jal	8000297a <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800056d8:	fc840593          	addi	a1,s0,-56
    800056dc:	fd040513          	addi	a0,s0,-48
    800056e0:	f35fe0ef          	jal	80004614 <pipealloc>
    return -1;
    800056e4:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800056e6:	0a054763          	bltz	a0,80005794 <sys_pipe+0xd6>
  fd0 = -1;
    800056ea:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800056ee:	fd043503          	ld	a0,-48(s0)
    800056f2:	e08ff0ef          	jal	80004cfa <fdalloc>
    800056f6:	fca42223          	sw	a0,-60(s0)
    800056fa:	08054463          	bltz	a0,80005782 <sys_pipe+0xc4>
    800056fe:	fc843503          	ld	a0,-56(s0)
    80005702:	df8ff0ef          	jal	80004cfa <fdalloc>
    80005706:	fca42023          	sw	a0,-64(s0)
    8000570a:	06054263          	bltz	a0,8000576e <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000570e:	4691                	li	a3,4
    80005710:	fc440613          	addi	a2,s0,-60
    80005714:	fd843583          	ld	a1,-40(s0)
    80005718:	68a8                	ld	a0,80(s1)
    8000571a:	f43fb0ef          	jal	8000165c <copyout>
    8000571e:	00054e63          	bltz	a0,8000573a <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005722:	4691                	li	a3,4
    80005724:	fc040613          	addi	a2,s0,-64
    80005728:	fd843583          	ld	a1,-40(s0)
    8000572c:	95b6                	add	a1,a1,a3
    8000572e:	68a8                	ld	a0,80(s1)
    80005730:	f2dfb0ef          	jal	8000165c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005734:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005736:	04055f63          	bgez	a0,80005794 <sys_pipe+0xd6>
    p->ofile[fd0] = 0;
    8000573a:	fc442783          	lw	a5,-60(s0)
    8000573e:	078e                	slli	a5,a5,0x3
    80005740:	0d078793          	addi	a5,a5,208
    80005744:	97a6                	add	a5,a5,s1
    80005746:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000574a:	fc042783          	lw	a5,-64(s0)
    8000574e:	078e                	slli	a5,a5,0x3
    80005750:	0d078793          	addi	a5,a5,208
    80005754:	97a6                	add	a5,a5,s1
    80005756:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000575a:	fd043503          	ld	a0,-48(s0)
    8000575e:	ad9fe0ef          	jal	80004236 <fileclose>
    fileclose(wf);
    80005762:	fc843503          	ld	a0,-56(s0)
    80005766:	ad1fe0ef          	jal	80004236 <fileclose>
    return -1;
    8000576a:	57fd                	li	a5,-1
    8000576c:	a025                	j	80005794 <sys_pipe+0xd6>
    if(fd0 >= 0)
    8000576e:	fc442783          	lw	a5,-60(s0)
    80005772:	0007c863          	bltz	a5,80005782 <sys_pipe+0xc4>
      p->ofile[fd0] = 0;
    80005776:	078e                	slli	a5,a5,0x3
    80005778:	0d078793          	addi	a5,a5,208
    8000577c:	97a6                	add	a5,a5,s1
    8000577e:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005782:	fd043503          	ld	a0,-48(s0)
    80005786:	ab1fe0ef          	jal	80004236 <fileclose>
    fileclose(wf);
    8000578a:	fc843503          	ld	a0,-56(s0)
    8000578e:	aa9fe0ef          	jal	80004236 <fileclose>
    return -1;
    80005792:	57fd                	li	a5,-1
}
    80005794:	853e                	mv	a0,a5
    80005796:	70e2                	ld	ra,56(sp)
    80005798:	7442                	ld	s0,48(sp)
    8000579a:	74a2                	ld	s1,40(sp)
    8000579c:	6121                	addi	sp,sp,64
    8000579e:	8082                	ret

00000000800057a0 <secure_path>:
#include "proc.h"

// Helper: set permissions on a path (must be called with no locks held)
static void
secure_path(char *path, uint uid, uint gid, uint mode)
{
    800057a0:	7139                	addi	sp,sp,-64
    800057a2:	fc06                	sd	ra,56(sp)
    800057a4:	f822                	sd	s0,48(sp)
    800057a6:	f04a                	sd	s2,32(sp)
    800057a8:	ec4e                	sd	s3,24(sp)
    800057aa:	e852                	sd	s4,16(sp)
    800057ac:	e456                	sd	s5,8(sp)
    800057ae:	0080                	addi	s0,sp,64
    800057b0:	8aaa                	mv	s5,a0
    800057b2:	892e                	mv	s2,a1
    800057b4:	89b2                	mv	s3,a2
    800057b6:	8a36                	mv	s4,a3
    struct inode *ip = namei(path);
    800057b8:	c0cfe0ef          	jal	80003bc4 <namei>
    if (ip == 0) {
    800057bc:	cd0d                	beqz	a0,800057f6 <secure_path+0x56>
    800057be:	f426                	sd	s1,40(sp)
    800057c0:	84aa                	mv	s1,a0
        printf("fsinit_security: warning: %s not found\n", path);
        return;
    }
    ilock(ip);
    800057c2:	baffd0ef          	jal	80003370 <ilock>
    ip->uid  = uid;
    800057c6:	0924a423          	sw	s2,136(s1)
    ip->gid  = gid;
    800057ca:	0934a623          	sw	s3,140(s1)
    ip->mode = mode;
    800057ce:	0944a223          	sw	s4,132(s1)
    iupdate(ip);
    800057d2:	8526                	mv	a0,s1
    800057d4:	acbfd0ef          	jal	8000329e <iupdate>
    iunlock(ip);
    800057d8:	8526                	mv	a0,s1
    800057da:	c67fd0ef          	jal	80003440 <iunlock>

    iput(ip);
    800057de:	8526                	mv	a0,s1
    800057e0:	d35fd0ef          	jal	80003514 <iput>
    800057e4:	74a2                	ld	s1,40(sp)
}
    800057e6:	70e2                	ld	ra,56(sp)
    800057e8:	7442                	ld	s0,48(sp)
    800057ea:	7902                	ld	s2,32(sp)
    800057ec:	69e2                	ld	s3,24(sp)
    800057ee:	6a42                	ld	s4,16(sp)
    800057f0:	6aa2                	ld	s5,8(sp)
    800057f2:	6121                	addi	sp,sp,64
    800057f4:	8082                	ret
        printf("fsinit_security: warning: %s not found\n", path);
    800057f6:	85d6                	mv	a1,s5
    800057f8:	00003517          	auipc	a0,0x3
    800057fc:	05050513          	addi	a0,a0,80 # 80008848 <etext+0x848>
    80005800:	cfbfa0ef          	jal	800004fa <printf>
        return;
    80005804:	b7cd                	j	800057e6 <secure_path+0x46>

0000000080005806 <fsinit_security>:

void
fsinit_security(void)
{
    80005806:	1141                	addi	sp,sp,-16
    80005808:	e406                	sd	ra,8(sp)
    8000580a:	e022                	sd	s0,0(sp)
    8000580c:	0800                	addi	s0,sp,16
    // WHY these specific permissions (course rubric + PoLP):
    //
    // /records:
    //   uid=1 (PATIENT) read-only → mode=0400
    //   DOCTOR also needs read → use group bits: mode=0440, gid=2
    begin_op();
    8000580e:	d94fe0ef          	jal	80003da2 <begin_op>
    secure_path("/records",
    80005812:	12000693          	li	a3,288
    80005816:	4609                	li	a2,2
    80005818:	4585                	li	a1,1
    8000581a:	00003517          	auipc	a0,0x3
    8000581e:	05650513          	addi	a0,a0,86 # 80008870 <etext+0x870>
    80005822:	f7fff0ef          	jal	800057a0 <secure_path>
                ROLE_DOCTOR  /*gid*/,
                0440 /*r--r-----*/);

    // /insulin.log:
    //   uid=2 (DOCTOR) Write, uid=1 (PATIENT) Read
    secure_path("/insulin.log",
    80005826:	1a000693          	li	a3,416
    8000582a:	4605                	li	a2,1
    8000582c:	4589                	li	a1,2
    8000582e:	00003517          	auipc	a0,0x3
    80005832:	05250513          	addi	a0,a0,82 # 80008880 <etext+0x880>
    80005836:	f6bff0ef          	jal	800057a0 <secure_path>
                ROLE_PATIENT /*gid*/,
                0640 /*rw-r-----*/);

    // /config:
    //   UID 0 (ADMIN) only → mode=0600
    secure_path("/config",
    8000583a:	18000693          	li	a3,384
    8000583e:	4601                	li	a2,0
    80005840:	4581                	li	a1,0
    80005842:	00003517          	auipc	a0,0x3
    80005846:	04e50513          	addi	a0,a0,78 # 80008890 <etext+0x890>
    8000584a:	f57ff0ef          	jal	800057a0 <secure_path>
                ROLE_ADMIN, ROLE_ADMIN,
                0600 /*rw-------*/);

    // /syscall.log:
    //   UID 0 (ADMIN) only → mode=0600 (read-write for persistent logging)
    secure_path("/syscall.log",
    8000584e:	18000693          	li	a3,384
    80005852:	4601                	li	a2,0
    80005854:	4581                	li	a1,0
    80005856:	00003517          	auipc	a0,0x3
    8000585a:	04250513          	addi	a0,a0,66 # 80008898 <etext+0x898>
    8000585e:	f43ff0ef          	jal	800057a0 <secure_path>
                ROLE_ADMIN, ROLE_ADMIN,
                0600 /*rw-------*/);
    end_op();
    80005862:	db0fe0ef          	jal	80003e12 <end_op>

    printf("fsinit_security: medical device file permissions applied\n");
    80005866:	00003517          	auipc	a0,0x3
    8000586a:	04250513          	addi	a0,a0,66 # 800088a8 <etext+0x8a8>
    8000586e:	c8dfa0ef          	jal	800004fa <printf>
}
    80005872:	60a2                	ld	ra,8(sp)
    80005874:	6402                	ld	s0,0(sp)
    80005876:	0141                	addi	sp,sp,16
    80005878:	8082                	ret
    8000587a:	0000                	unimp
    8000587c:	0000                	unimp
	...

0000000080005880 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005880:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005882:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005884:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005886:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005888:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000588a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000588c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000588e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005890:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005892:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005894:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005896:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005898:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000589a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000589c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000589e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800058a0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800058a2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800058a4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800058a6:	f3bfc0ef          	jal	800027e0 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800058aa:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800058ac:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800058ae:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800058b0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800058b2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800058b4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800058b6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800058b8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800058ba:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800058bc:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800058be:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800058c0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800058c2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800058c4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800058c6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800058c8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800058ca:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800058cc:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800058ce:	10200073          	sret
    800058d2:	00000013          	nop
    800058d6:	00000013          	nop
    800058da:	00000013          	nop

00000000800058de <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800058de:	1141                	addi	sp,sp,-16
    800058e0:	e406                	sd	ra,8(sp)
    800058e2:	e022                	sd	s0,0(sp)
    800058e4:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800058e6:	0c000737          	lui	a4,0xc000
    800058ea:	4785                	li	a5,1
    800058ec:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800058ee:	c35c                	sw	a5,4(a4)
}
    800058f0:	60a2                	ld	ra,8(sp)
    800058f2:	6402                	ld	s0,0(sp)
    800058f4:	0141                	addi	sp,sp,16
    800058f6:	8082                	ret

00000000800058f8 <plicinithart>:

void
plicinithart(void)
{
    800058f8:	1141                	addi	sp,sp,-16
    800058fa:	e406                	sd	ra,8(sp)
    800058fc:	e022                	sd	s0,0(sp)
    800058fe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005900:	802fc0ef          	jal	80001902 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005904:	0085171b          	slliw	a4,a0,0x8
    80005908:	0c0027b7          	lui	a5,0xc002
    8000590c:	97ba                	add	a5,a5,a4
    8000590e:	40200713          	li	a4,1026
    80005912:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005916:	00d5151b          	slliw	a0,a0,0xd
    8000591a:	0c2017b7          	lui	a5,0xc201
    8000591e:	97aa                	add	a5,a5,a0
    80005920:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005924:	60a2                	ld	ra,8(sp)
    80005926:	6402                	ld	s0,0(sp)
    80005928:	0141                	addi	sp,sp,16
    8000592a:	8082                	ret

000000008000592c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000592c:	1141                	addi	sp,sp,-16
    8000592e:	e406                	sd	ra,8(sp)
    80005930:	e022                	sd	s0,0(sp)
    80005932:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005934:	fcffb0ef          	jal	80001902 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005938:	00d5151b          	slliw	a0,a0,0xd
    8000593c:	0c2017b7          	lui	a5,0xc201
    80005940:	97aa                	add	a5,a5,a0
  return irq;
}
    80005942:	43c8                	lw	a0,4(a5)
    80005944:	60a2                	ld	ra,8(sp)
    80005946:	6402                	ld	s0,0(sp)
    80005948:	0141                	addi	sp,sp,16
    8000594a:	8082                	ret

000000008000594c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000594c:	1101                	addi	sp,sp,-32
    8000594e:	ec06                	sd	ra,24(sp)
    80005950:	e822                	sd	s0,16(sp)
    80005952:	e426                	sd	s1,8(sp)
    80005954:	1000                	addi	s0,sp,32
    80005956:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005958:	fabfb0ef          	jal	80001902 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000595c:	00d5179b          	slliw	a5,a0,0xd
    80005960:	0c201737          	lui	a4,0xc201
    80005964:	97ba                	add	a5,a5,a4
    80005966:	c3c4                	sw	s1,4(a5)
}
    80005968:	60e2                	ld	ra,24(sp)
    8000596a:	6442                	ld	s0,16(sp)
    8000596c:	64a2                	ld	s1,8(sp)
    8000596e:	6105                	addi	sp,sp,32
    80005970:	8082                	ret

0000000080005972 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005972:	1141                	addi	sp,sp,-16
    80005974:	e406                	sd	ra,8(sp)
    80005976:	e022                	sd	s0,0(sp)
    80005978:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000597a:	479d                	li	a5,7
    8000597c:	04a7ca63          	blt	a5,a0,800059d0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005980:	0001d797          	auipc	a5,0x1d
    80005984:	6c878793          	addi	a5,a5,1736 # 80023048 <disk>
    80005988:	97aa                	add	a5,a5,a0
    8000598a:	0187c783          	lbu	a5,24(a5)
    8000598e:	e7b9                	bnez	a5,800059dc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005990:	00451693          	slli	a3,a0,0x4
    80005994:	0001d797          	auipc	a5,0x1d
    80005998:	6b478793          	addi	a5,a5,1716 # 80023048 <disk>
    8000599c:	6398                	ld	a4,0(a5)
    8000599e:	9736                	add	a4,a4,a3
    800059a0:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    800059a4:	6398                	ld	a4,0(a5)
    800059a6:	9736                	add	a4,a4,a3
    800059a8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800059ac:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800059b0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800059b4:	97aa                	add	a5,a5,a0
    800059b6:	4705                	li	a4,1
    800059b8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800059bc:	0001d517          	auipc	a0,0x1d
    800059c0:	6a450513          	addi	a0,a0,1700 # 80023060 <disk+0x18>
    800059c4:	e1afc0ef          	jal	80001fde <wakeup>
}
    800059c8:	60a2                	ld	ra,8(sp)
    800059ca:	6402                	ld	s0,0(sp)
    800059cc:	0141                	addi	sp,sp,16
    800059ce:	8082                	ret
    panic("free_desc 1");
    800059d0:	00003517          	auipc	a0,0x3
    800059d4:	f1850513          	addi	a0,a0,-232 # 800088e8 <etext+0x8e8>
    800059d8:	e4dfa0ef          	jal	80000824 <panic>
    panic("free_desc 2");
    800059dc:	00003517          	auipc	a0,0x3
    800059e0:	f1c50513          	addi	a0,a0,-228 # 800088f8 <etext+0x8f8>
    800059e4:	e41fa0ef          	jal	80000824 <panic>

00000000800059e8 <virtio_disk_init>:
{
    800059e8:	1101                	addi	sp,sp,-32
    800059ea:	ec06                	sd	ra,24(sp)
    800059ec:	e822                	sd	s0,16(sp)
    800059ee:	e426                	sd	s1,8(sp)
    800059f0:	e04a                	sd	s2,0(sp)
    800059f2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800059f4:	00003597          	auipc	a1,0x3
    800059f8:	f1458593          	addi	a1,a1,-236 # 80008908 <etext+0x908>
    800059fc:	0001d517          	auipc	a0,0x1d
    80005a00:	77450513          	addi	a0,a0,1908 # 80023170 <disk+0x128>
    80005a04:	99afb0ef          	jal	80000b9e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005a08:	100017b7          	lui	a5,0x10001
    80005a0c:	4398                	lw	a4,0(a5)
    80005a0e:	2701                	sext.w	a4,a4
    80005a10:	747277b7          	lui	a5,0x74727
    80005a14:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005a18:	14f71863          	bne	a4,a5,80005b68 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005a1c:	100017b7          	lui	a5,0x10001
    80005a20:	43dc                	lw	a5,4(a5)
    80005a22:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005a24:	4709                	li	a4,2
    80005a26:	14e79163          	bne	a5,a4,80005b68 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005a2a:	100017b7          	lui	a5,0x10001
    80005a2e:	479c                	lw	a5,8(a5)
    80005a30:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005a32:	12e79b63          	bne	a5,a4,80005b68 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005a36:	100017b7          	lui	a5,0x10001
    80005a3a:	47d8                	lw	a4,12(a5)
    80005a3c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005a3e:	554d47b7          	lui	a5,0x554d4
    80005a42:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005a46:	12f71163          	bne	a4,a5,80005b68 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005a4a:	100017b7          	lui	a5,0x10001
    80005a4e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005a52:	4705                	li	a4,1
    80005a54:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005a56:	470d                	li	a4,3
    80005a58:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005a5a:	10001737          	lui	a4,0x10001
    80005a5e:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005a60:	c7ffe6b7          	lui	a3,0xc7ffe
    80005a64:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fcfe0f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005a68:	8f75                	and	a4,a4,a3
    80005a6a:	100016b7          	lui	a3,0x10001
    80005a6e:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005a70:	472d                	li	a4,11
    80005a72:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005a74:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005a78:	439c                	lw	a5,0(a5)
    80005a7a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005a7e:	8ba1                	andi	a5,a5,8
    80005a80:	0e078a63          	beqz	a5,80005b74 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005a84:	100017b7          	lui	a5,0x10001
    80005a88:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005a8c:	43fc                	lw	a5,68(a5)
    80005a8e:	2781                	sext.w	a5,a5
    80005a90:	0e079863          	bnez	a5,80005b80 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005a94:	100017b7          	lui	a5,0x10001
    80005a98:	5bdc                	lw	a5,52(a5)
    80005a9a:	2781                	sext.w	a5,a5
  if(max == 0)
    80005a9c:	0e078863          	beqz	a5,80005b8c <virtio_disk_init+0x1a4>
  if(max < NUM)
    80005aa0:	471d                	li	a4,7
    80005aa2:	0ef77b63          	bgeu	a4,a5,80005b98 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    80005aa6:	89efb0ef          	jal	80000b44 <kalloc>
    80005aaa:	0001d497          	auipc	s1,0x1d
    80005aae:	59e48493          	addi	s1,s1,1438 # 80023048 <disk>
    80005ab2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005ab4:	890fb0ef          	jal	80000b44 <kalloc>
    80005ab8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005aba:	88afb0ef          	jal	80000b44 <kalloc>
    80005abe:	87aa                	mv	a5,a0
    80005ac0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005ac2:	6088                	ld	a0,0(s1)
    80005ac4:	0e050063          	beqz	a0,80005ba4 <virtio_disk_init+0x1bc>
    80005ac8:	0001d717          	auipc	a4,0x1d
    80005acc:	58873703          	ld	a4,1416(a4) # 80023050 <disk+0x8>
    80005ad0:	cb71                	beqz	a4,80005ba4 <virtio_disk_init+0x1bc>
    80005ad2:	cbe9                	beqz	a5,80005ba4 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005ad4:	6605                	lui	a2,0x1
    80005ad6:	4581                	li	a1,0
    80005ad8:	a20fb0ef          	jal	80000cf8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005adc:	0001d497          	auipc	s1,0x1d
    80005ae0:	56c48493          	addi	s1,s1,1388 # 80023048 <disk>
    80005ae4:	6605                	lui	a2,0x1
    80005ae6:	4581                	li	a1,0
    80005ae8:	6488                	ld	a0,8(s1)
    80005aea:	a0efb0ef          	jal	80000cf8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005aee:	6605                	lui	a2,0x1
    80005af0:	4581                	li	a1,0
    80005af2:	6888                	ld	a0,16(s1)
    80005af4:	a04fb0ef          	jal	80000cf8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005af8:	100017b7          	lui	a5,0x10001
    80005afc:	4721                	li	a4,8
    80005afe:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005b00:	4098                	lw	a4,0(s1)
    80005b02:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005b06:	40d8                	lw	a4,4(s1)
    80005b08:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005b0c:	649c                	ld	a5,8(s1)
    80005b0e:	0007869b          	sext.w	a3,a5
    80005b12:	10001737          	lui	a4,0x10001
    80005b16:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005b1a:	9781                	srai	a5,a5,0x20
    80005b1c:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005b20:	689c                	ld	a5,16(s1)
    80005b22:	0007869b          	sext.w	a3,a5
    80005b26:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005b2a:	9781                	srai	a5,a5,0x20
    80005b2c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005b30:	4785                	li	a5,1
    80005b32:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005b34:	00f48c23          	sb	a5,24(s1)
    80005b38:	00f48ca3          	sb	a5,25(s1)
    80005b3c:	00f48d23          	sb	a5,26(s1)
    80005b40:	00f48da3          	sb	a5,27(s1)
    80005b44:	00f48e23          	sb	a5,28(s1)
    80005b48:	00f48ea3          	sb	a5,29(s1)
    80005b4c:	00f48f23          	sb	a5,30(s1)
    80005b50:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005b54:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b58:	07272823          	sw	s2,112(a4)
}
    80005b5c:	60e2                	ld	ra,24(sp)
    80005b5e:	6442                	ld	s0,16(sp)
    80005b60:	64a2                	ld	s1,8(sp)
    80005b62:	6902                	ld	s2,0(sp)
    80005b64:	6105                	addi	sp,sp,32
    80005b66:	8082                	ret
    panic("could not find virtio disk");
    80005b68:	00003517          	auipc	a0,0x3
    80005b6c:	db050513          	addi	a0,a0,-592 # 80008918 <etext+0x918>
    80005b70:	cb5fa0ef          	jal	80000824 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005b74:	00003517          	auipc	a0,0x3
    80005b78:	dc450513          	addi	a0,a0,-572 # 80008938 <etext+0x938>
    80005b7c:	ca9fa0ef          	jal	80000824 <panic>
    panic("virtio disk should not be ready");
    80005b80:	00003517          	auipc	a0,0x3
    80005b84:	dd850513          	addi	a0,a0,-552 # 80008958 <etext+0x958>
    80005b88:	c9dfa0ef          	jal	80000824 <panic>
    panic("virtio disk has no queue 0");
    80005b8c:	00003517          	auipc	a0,0x3
    80005b90:	dec50513          	addi	a0,a0,-532 # 80008978 <etext+0x978>
    80005b94:	c91fa0ef          	jal	80000824 <panic>
    panic("virtio disk max queue too short");
    80005b98:	00003517          	auipc	a0,0x3
    80005b9c:	e0050513          	addi	a0,a0,-512 # 80008998 <etext+0x998>
    80005ba0:	c85fa0ef          	jal	80000824 <panic>
    panic("virtio disk kalloc");
    80005ba4:	00003517          	auipc	a0,0x3
    80005ba8:	e1450513          	addi	a0,a0,-492 # 800089b8 <etext+0x9b8>
    80005bac:	c79fa0ef          	jal	80000824 <panic>

0000000080005bb0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005bb0:	711d                	addi	sp,sp,-96
    80005bb2:	ec86                	sd	ra,88(sp)
    80005bb4:	e8a2                	sd	s0,80(sp)
    80005bb6:	e4a6                	sd	s1,72(sp)
    80005bb8:	e0ca                	sd	s2,64(sp)
    80005bba:	fc4e                	sd	s3,56(sp)
    80005bbc:	f852                	sd	s4,48(sp)
    80005bbe:	f456                	sd	s5,40(sp)
    80005bc0:	f05a                	sd	s6,32(sp)
    80005bc2:	ec5e                	sd	s7,24(sp)
    80005bc4:	e862                	sd	s8,16(sp)
    80005bc6:	1080                	addi	s0,sp,96
    80005bc8:	89aa                	mv	s3,a0
    80005bca:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005bcc:	00c52b83          	lw	s7,12(a0)
    80005bd0:	001b9b9b          	slliw	s7,s7,0x1
    80005bd4:	1b82                	slli	s7,s7,0x20
    80005bd6:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005bda:	0001d517          	auipc	a0,0x1d
    80005bde:	59650513          	addi	a0,a0,1430 # 80023170 <disk+0x128>
    80005be2:	846fb0ef          	jal	80000c28 <acquire>
  for(int i = 0; i < NUM; i++){
    80005be6:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005be8:	0001da97          	auipc	s5,0x1d
    80005bec:	460a8a93          	addi	s5,s5,1120 # 80023048 <disk>
  for(int i = 0; i < 3; i++){
    80005bf0:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005bf2:	5c7d                	li	s8,-1
    80005bf4:	a095                	j	80005c58 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    80005bf6:	00fa8733          	add	a4,s5,a5
    80005bfa:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005bfe:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005c00:	0207c563          	bltz	a5,80005c2a <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    80005c04:	2905                	addiw	s2,s2,1
    80005c06:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005c08:	05490c63          	beq	s2,s4,80005c60 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    80005c0c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005c0e:	0001d717          	auipc	a4,0x1d
    80005c12:	43a70713          	addi	a4,a4,1082 # 80023048 <disk>
    80005c16:	4781                	li	a5,0
    if(disk.free[i]){
    80005c18:	01874683          	lbu	a3,24(a4)
    80005c1c:	fee9                	bnez	a3,80005bf6 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    80005c1e:	2785                	addiw	a5,a5,1
    80005c20:	0705                	addi	a4,a4,1
    80005c22:	fe979be3          	bne	a5,s1,80005c18 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005c26:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    80005c2a:	01205d63          	blez	s2,80005c44 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005c2e:	fa042503          	lw	a0,-96(s0)
    80005c32:	d41ff0ef          	jal	80005972 <free_desc>
      for(int j = 0; j < i; j++)
    80005c36:	4785                	li	a5,1
    80005c38:	0127d663          	bge	a5,s2,80005c44 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005c3c:	fa442503          	lw	a0,-92(s0)
    80005c40:	d33ff0ef          	jal	80005972 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005c44:	0001d597          	auipc	a1,0x1d
    80005c48:	52c58593          	addi	a1,a1,1324 # 80023170 <disk+0x128>
    80005c4c:	0001d517          	auipc	a0,0x1d
    80005c50:	41450513          	addi	a0,a0,1044 # 80023060 <disk+0x18>
    80005c54:	b3efc0ef          	jal	80001f92 <sleep>
  for(int i = 0; i < 3; i++){
    80005c58:	fa040613          	addi	a2,s0,-96
    80005c5c:	4901                	li	s2,0
    80005c5e:	b77d                	j	80005c0c <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005c60:	fa042503          	lw	a0,-96(s0)
    80005c64:	00451693          	slli	a3,a0,0x4

  if(write)
    80005c68:	0001d797          	auipc	a5,0x1d
    80005c6c:	3e078793          	addi	a5,a5,992 # 80023048 <disk>
    80005c70:	00451713          	slli	a4,a0,0x4
    80005c74:	0a070713          	addi	a4,a4,160
    80005c78:	973e                	add	a4,a4,a5
    80005c7a:	01603633          	snez	a2,s6
    80005c7e:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005c80:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005c84:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005c88:	6398                	ld	a4,0(a5)
    80005c8a:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005c8c:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005c90:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005c92:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005c94:	6390                	ld	a2,0(a5)
    80005c96:	00d60833          	add	a6,a2,a3
    80005c9a:	4741                	li	a4,16
    80005c9c:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005ca0:	4585                	li	a1,1
    80005ca2:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005ca6:	fa442703          	lw	a4,-92(s0)
    80005caa:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005cae:	0712                	slli	a4,a4,0x4
    80005cb0:	963a                	add	a2,a2,a4
    80005cb2:	05898813          	addi	a6,s3,88
    80005cb6:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005cba:	0007b883          	ld	a7,0(a5)
    80005cbe:	9746                	add	a4,a4,a7
    80005cc0:	40000613          	li	a2,1024
    80005cc4:	c710                	sw	a2,8(a4)
  if(write)
    80005cc6:	001b3613          	seqz	a2,s6
    80005cca:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005cce:	8e4d                	or	a2,a2,a1
    80005cd0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005cd4:	fa842603          	lw	a2,-88(s0)
    80005cd8:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005cdc:	00451813          	slli	a6,a0,0x4
    80005ce0:	02080813          	addi	a6,a6,32
    80005ce4:	983e                	add	a6,a6,a5
    80005ce6:	577d                	li	a4,-1
    80005ce8:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005cec:	0612                	slli	a2,a2,0x4
    80005cee:	98b2                	add	a7,a7,a2
    80005cf0:	03068713          	addi	a4,a3,48
    80005cf4:	973e                	add	a4,a4,a5
    80005cf6:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005cfa:	6398                	ld	a4,0(a5)
    80005cfc:	9732                	add	a4,a4,a2
    80005cfe:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005d00:	4689                	li	a3,2
    80005d02:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005d06:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005d0a:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005d0e:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005d12:	6794                	ld	a3,8(a5)
    80005d14:	0026d703          	lhu	a4,2(a3)
    80005d18:	8b1d                	andi	a4,a4,7
    80005d1a:	0706                	slli	a4,a4,0x1
    80005d1c:	96ba                	add	a3,a3,a4
    80005d1e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005d22:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005d26:	6798                	ld	a4,8(a5)
    80005d28:	00275783          	lhu	a5,2(a4)
    80005d2c:	2785                	addiw	a5,a5,1
    80005d2e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005d32:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005d36:	100017b7          	lui	a5,0x10001
    80005d3a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005d3e:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    80005d42:	0001d917          	auipc	s2,0x1d
    80005d46:	42e90913          	addi	s2,s2,1070 # 80023170 <disk+0x128>
  while(b->disk == 1) {
    80005d4a:	84ae                	mv	s1,a1
    80005d4c:	00b79a63          	bne	a5,a1,80005d60 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005d50:	85ca                	mv	a1,s2
    80005d52:	854e                	mv	a0,s3
    80005d54:	a3efc0ef          	jal	80001f92 <sleep>
  while(b->disk == 1) {
    80005d58:	0049a783          	lw	a5,4(s3)
    80005d5c:	fe978ae3          	beq	a5,s1,80005d50 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005d60:	fa042903          	lw	s2,-96(s0)
    80005d64:	00491713          	slli	a4,s2,0x4
    80005d68:	02070713          	addi	a4,a4,32
    80005d6c:	0001d797          	auipc	a5,0x1d
    80005d70:	2dc78793          	addi	a5,a5,732 # 80023048 <disk>
    80005d74:	97ba                	add	a5,a5,a4
    80005d76:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005d7a:	0001d997          	auipc	s3,0x1d
    80005d7e:	2ce98993          	addi	s3,s3,718 # 80023048 <disk>
    80005d82:	00491713          	slli	a4,s2,0x4
    80005d86:	0009b783          	ld	a5,0(s3)
    80005d8a:	97ba                	add	a5,a5,a4
    80005d8c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005d90:	854a                	mv	a0,s2
    80005d92:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005d96:	bddff0ef          	jal	80005972 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005d9a:	8885                	andi	s1,s1,1
    80005d9c:	f0fd                	bnez	s1,80005d82 <virtio_disk_rw+0x1d2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005d9e:	0001d517          	auipc	a0,0x1d
    80005da2:	3d250513          	addi	a0,a0,978 # 80023170 <disk+0x128>
    80005da6:	f17fa0ef          	jal	80000cbc <release>
}
    80005daa:	60e6                	ld	ra,88(sp)
    80005dac:	6446                	ld	s0,80(sp)
    80005dae:	64a6                	ld	s1,72(sp)
    80005db0:	6906                	ld	s2,64(sp)
    80005db2:	79e2                	ld	s3,56(sp)
    80005db4:	7a42                	ld	s4,48(sp)
    80005db6:	7aa2                	ld	s5,40(sp)
    80005db8:	7b02                	ld	s6,32(sp)
    80005dba:	6be2                	ld	s7,24(sp)
    80005dbc:	6c42                	ld	s8,16(sp)
    80005dbe:	6125                	addi	sp,sp,96
    80005dc0:	8082                	ret

0000000080005dc2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005dc2:	1101                	addi	sp,sp,-32
    80005dc4:	ec06                	sd	ra,24(sp)
    80005dc6:	e822                	sd	s0,16(sp)
    80005dc8:	e426                	sd	s1,8(sp)
    80005dca:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005dcc:	0001d497          	auipc	s1,0x1d
    80005dd0:	27c48493          	addi	s1,s1,636 # 80023048 <disk>
    80005dd4:	0001d517          	auipc	a0,0x1d
    80005dd8:	39c50513          	addi	a0,a0,924 # 80023170 <disk+0x128>
    80005ddc:	e4dfa0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005de0:	100017b7          	lui	a5,0x10001
    80005de4:	53bc                	lw	a5,96(a5)
    80005de6:	8b8d                	andi	a5,a5,3
    80005de8:	10001737          	lui	a4,0x10001
    80005dec:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005dee:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005df2:	689c                	ld	a5,16(s1)
    80005df4:	0204d703          	lhu	a4,32(s1)
    80005df8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005dfc:	04f70863          	beq	a4,a5,80005e4c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80005e00:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005e04:	6898                	ld	a4,16(s1)
    80005e06:	0204d783          	lhu	a5,32(s1)
    80005e0a:	8b9d                	andi	a5,a5,7
    80005e0c:	078e                	slli	a5,a5,0x3
    80005e0e:	97ba                	add	a5,a5,a4
    80005e10:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005e12:	00479713          	slli	a4,a5,0x4
    80005e16:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005e1a:	9726                	add	a4,a4,s1
    80005e1c:	01074703          	lbu	a4,16(a4)
    80005e20:	e329                	bnez	a4,80005e62 <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005e22:	0792                	slli	a5,a5,0x4
    80005e24:	02078793          	addi	a5,a5,32
    80005e28:	97a6                	add	a5,a5,s1
    80005e2a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005e2c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005e30:	9aefc0ef          	jal	80001fde <wakeup>

    disk.used_idx += 1;
    80005e34:	0204d783          	lhu	a5,32(s1)
    80005e38:	2785                	addiw	a5,a5,1
    80005e3a:	17c2                	slli	a5,a5,0x30
    80005e3c:	93c1                	srli	a5,a5,0x30
    80005e3e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005e42:	6898                	ld	a4,16(s1)
    80005e44:	00275703          	lhu	a4,2(a4)
    80005e48:	faf71ce3          	bne	a4,a5,80005e00 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005e4c:	0001d517          	auipc	a0,0x1d
    80005e50:	32450513          	addi	a0,a0,804 # 80023170 <disk+0x128>
    80005e54:	e69fa0ef          	jal	80000cbc <release>
}
    80005e58:	60e2                	ld	ra,24(sp)
    80005e5a:	6442                	ld	s0,16(sp)
    80005e5c:	64a2                	ld	s1,8(sp)
    80005e5e:	6105                	addi	sp,sp,32
    80005e60:	8082                	ret
      panic("virtio_disk_intr status");
    80005e62:	00003517          	auipc	a0,0x3
    80005e66:	b6e50513          	addi	a0,a0,-1170 # 800089d0 <etext+0x9d0>
    80005e6a:	9bbfa0ef          	jal	80000824 <panic>

0000000080005e6e <hash_password>:
// so we use a polynomial hash. Note this in your report as a
// known limitation with a recommendation to use SHA-256.
// =============================================================
void
hash_password(const char *password, char *out_hash)
{
    80005e6e:	7179                	addi	sp,sp,-48
    80005e70:	f406                	sd	ra,40(sp)
    80005e72:	f022                	sd	s0,32(sp)
    80005e74:	1800                	addi	s0,sp,48
    uint64 h = 5381;
    int c;
    const char *p = password;

    while ((c = *p++) != 0) {
    80005e76:	00054703          	lbu	a4,0(a0)
    80005e7a:	cf25                	beqz	a4,80005ef2 <hash_password+0x84>
    80005e7c:	00150793          	addi	a5,a0,1
    uint64 h = 5381;
    80005e80:	6685                	lui	a3,0x1
    80005e82:	50568693          	addi	a3,a3,1285 # 1505 <_entry-0x7fffeafb>
        h = ((h << 5) + h) + c;  // h * 33 + c (djb2)
    80005e86:	00569613          	slli	a2,a3,0x5
    80005e8a:	96b2                	add	a3,a3,a2
    80005e8c:	96ba                	add	a3,a3,a4
    while ((c = *p++) != 0) {
    80005e8e:	0785                	addi	a5,a5,1
    80005e90:	fff7c703          	lbu	a4,-1(a5)
    80005e94:	fb6d                	bnez	a4,80005e86 <hash_password+0x18>
    }

    // Encode as 16-char hex string
    // In production: replace with proper cryptographic hash
    char hex[] = "0123456789abcdef";
    80005e96:	00003797          	auipc	a5,0x3
    80005e9a:	b5278793          	addi	a5,a5,-1198 # 800089e8 <etext+0x9e8>
    80005e9e:	6398                	ld	a4,0(a5)
    80005ea0:	fce43c23          	sd	a4,-40(s0)
    80005ea4:	6798                	ld	a4,8(a5)
    80005ea6:	fee43023          	sd	a4,-32(s0)
    80005eaa:	0107c783          	lbu	a5,16(a5)
    80005eae:	fef40423          	sb	a5,-24(s0)
    for (int i = 0; i < 16; i++) {
    80005eb2:	862e                	mv	a2,a1
    char hex[] = "0123456789abcdef";
    80005eb4:	03c00793          	li	a5,60
    for (int i = 0; i < 16; i++) {
    80005eb8:	5571                	li	a0,-4
        out_hash[i * 2]     = hex[(h >> (60 - i * 4)) & 0xF];
    80005eba:	00f6d733          	srl	a4,a3,a5
    80005ebe:	8b3d                	andi	a4,a4,15
    80005ec0:	1741                	addi	a4,a4,-16
    80005ec2:	9722                	add	a4,a4,s0
    80005ec4:	fe874703          	lbu	a4,-24(a4)
    80005ec8:	00e60023          	sb	a4,0(a2)
        out_hash[i * 2 + 1] = hex[(h >> (56 - i * 4)) & 0xF];
    80005ecc:	37f1                	addiw	a5,a5,-4
    80005ece:	00f6d733          	srl	a4,a3,a5
    80005ed2:	8b3d                	andi	a4,a4,15
    80005ed4:	1741                	addi	a4,a4,-16
    80005ed6:	9722                	add	a4,a4,s0
    80005ed8:	fe874703          	lbu	a4,-24(a4)
    80005edc:	00e600a3          	sb	a4,1(a2)
    for (int i = 0; i < 16; i++) {
    80005ee0:	0609                	addi	a2,a2,2
    80005ee2:	fca79ce3          	bne	a5,a0,80005eba <hash_password+0x4c>
    }
    out_hash[32] = '\0';
    80005ee6:	02058023          	sb	zero,32(a1)
}
    80005eea:	70a2                	ld	ra,40(sp)
    80005eec:	7402                	ld	s0,32(sp)
    80005eee:	6145                	addi	sp,sp,48
    80005ef0:	8082                	ret
    uint64 h = 5381;
    80005ef2:	6685                	lui	a3,0x1
    80005ef4:	50568693          	addi	a3,a3,1285 # 1505 <_entry-0x7fffeafb>
    80005ef8:	bf79                	j	80005e96 <hash_password+0x28>

0000000080005efa <auth_init>:
// auth_init — Called from main() during boot
// Populates the in-memory user table with default credentials
// =============================================================
void
auth_init(void)
{
    80005efa:	7139                	addi	sp,sp,-64
    80005efc:	fc06                	sd	ra,56(sp)
    80005efe:	f822                	sd	s0,48(sp)
    80005f00:	f426                	sd	s1,40(sp)
    80005f02:	f04a                	sd	s2,32(sp)
    80005f04:	ec4e                	sd	s3,24(sp)
    80005f06:	e852                	sd	s4,16(sp)
    80005f08:	e456                	sd	s5,8(sp)
    80005f0a:	e05a                	sd	s6,0(sp)
    80005f0c:	0080                	addi	s0,sp,64
    initlock(&g_users.lock, "auth");
    80005f0e:	0001d497          	auipc	s1,0x1d
    80005f12:	27a48493          	addi	s1,s1,634 # 80023188 <g_users>
    80005f16:	00003597          	auipc	a1,0x3
    80005f1a:	aea58593          	addi	a1,a1,-1302 # 80008a00 <etext+0xa00>
    80005f1e:	0001d517          	auipc	a0,0x1d
    80005f22:	5f250513          	addi	a0,a0,1522 # 80023510 <g_users+0x388>
    80005f26:	c79fa0ef          	jal	80000b9e <initlock>
    g_users.count = 0;

    // Seed default users — in production these come from /etc/passwd
    // ADMIN user
    struct passwd_entry *e = &g_users.entries[g_users.count++];
    80005f2a:	4985                	li	s3,1
    80005f2c:	3934a023          	sw	s3,896(s1)
    safestrcpy(e->username, "admin", AUTH_NAME_LEN);
    80005f30:	02000613          	li	a2,32
    80005f34:	00003597          	auipc	a1,0x3
    80005f38:	ad458593          	addi	a1,a1,-1324 # 80008a08 <etext+0xa08>
    80005f3c:	8526                	mv	a0,s1
    80005f3e:	f0ffa0ef          	jal	80000e4c <safestrcpy>
    hash_password("admin123", e->passhash);
    80005f42:	0001d597          	auipc	a1,0x1d
    80005f46:	26658593          	addi	a1,a1,614 # 800231a8 <g_users+0x20>
    80005f4a:	00003517          	auipc	a0,0x3
    80005f4e:	ac650513          	addi	a0,a0,-1338 # 80008a10 <etext+0xa10>
    80005f52:	f1dff0ef          	jal	80005e6e <hash_password>
    e->uid   = ROLE_ADMIN;
    80005f56:	0604a023          	sw	zero,96(s1)
    e->gid   = 0;
    80005f5a:	0604a223          	sw	zero,100(s1)
    e->role  = ROLE_ADMIN;
    80005f5e:	0604a423          	sw	zero,104(s1)
    e->valid = 1;
    80005f62:	0734a623          	sw	s3,108(s1)

    // PATIENT user
    e = &g_users.entries[g_users.count++];
    80005f66:	3804aa83          	lw	s5,896(s1)
    80005f6a:	001a879b          	addiw	a5,s5,1
    80005f6e:	38f4a023          	sw	a5,896(s1)
    safestrcpy(e->username, "patient", AUTH_NAME_LEN);
    80005f72:	003a9913          	slli	s2,s5,0x3
    80005f76:	41590a33          	sub	s4,s2,s5
    80005f7a:	0a12                	slli	s4,s4,0x4
    80005f7c:	01448b33          	add	s6,s1,s4
    80005f80:	02000613          	li	a2,32
    80005f84:	00003597          	auipc	a1,0x3
    80005f88:	a9c58593          	addi	a1,a1,-1380 # 80008a20 <etext+0xa20>
    80005f8c:	855a                	mv	a0,s6
    80005f8e:	ebffa0ef          	jal	80000e4c <safestrcpy>
    hash_password("patient123", e->passhash);
    80005f92:	020a0593          	addi	a1,s4,32
    80005f96:	95a6                	add	a1,a1,s1
    80005f98:	00003517          	auipc	a0,0x3
    80005f9c:	a9050513          	addi	a0,a0,-1392 # 80008a28 <etext+0xa28>
    80005fa0:	ecfff0ef          	jal	80005e6e <hash_password>
    e->uid   = ROLE_PATIENT;
    80005fa4:	073b2023          	sw	s3,96(s6) # 1060 <_entry-0x7fffefa0>
    e->gid   = 1;
    80005fa8:	073b2223          	sw	s3,100(s6)
    e->role  = ROLE_PATIENT;
    80005fac:	073b2423          	sw	s3,104(s6)
    e->valid = 1;
    80005fb0:	073b2623          	sw	s3,108(s6)

    // DOCTOR user
    e = &g_users.entries[g_users.count++];
    80005fb4:	3804aa83          	lw	s5,896(s1)
    80005fb8:	001a879b          	addiw	a5,s5,1
    80005fbc:	38f4a023          	sw	a5,896(s1)
    safestrcpy(e->username, "doctor", AUTH_NAME_LEN);
    80005fc0:	003a9913          	slli	s2,s5,0x3
    80005fc4:	41590a33          	sub	s4,s2,s5
    80005fc8:	0a12                	slli	s4,s4,0x4
    80005fca:	01448b33          	add	s6,s1,s4
    80005fce:	02000613          	li	a2,32
    80005fd2:	00003597          	auipc	a1,0x3
    80005fd6:	a6658593          	addi	a1,a1,-1434 # 80008a38 <etext+0xa38>
    80005fda:	855a                	mv	a0,s6
    80005fdc:	e71fa0ef          	jal	80000e4c <safestrcpy>
    hash_password("doctor123", e->passhash);
    80005fe0:	020a0593          	addi	a1,s4,32
    80005fe4:	95a6                	add	a1,a1,s1
    80005fe6:	00003517          	auipc	a0,0x3
    80005fea:	a5a50513          	addi	a0,a0,-1446 # 80008a40 <etext+0xa40>
    80005fee:	e81ff0ef          	jal	80005e6e <hash_password>
    e->uid   = ROLE_DOCTOR;
    80005ff2:	4789                	li	a5,2
    80005ff4:	06fb2023          	sw	a5,96(s6)
    e->gid   = 2;
    80005ff8:	06fb2223          	sw	a5,100(s6)
    e->role  = ROLE_DOCTOR;
    80005ffc:	06fb2423          	sw	a5,104(s6)
    e->valid = 1;
    80006000:	073b2623          	sw	s3,108(s6)
}
    80006004:	70e2                	ld	ra,56(sp)
    80006006:	7442                	ld	s0,48(sp)
    80006008:	74a2                	ld	s1,40(sp)
    8000600a:	7902                	ld	s2,32(sp)
    8000600c:	69e2                	ld	s3,24(sp)
    8000600e:	6a42                	ld	s4,16(sp)
    80006010:	6aa2                	ld	s5,8(sp)
    80006012:	6b02                	ld	s6,0(sp)
    80006014:	6121                	addi	sp,sp,64
    80006016:	8082                	ret

0000000080006018 <auth_verify>:
// WHY kernel-side: user space must NEVER see the hash table
// directly — that would allow brute-force without audit trails
// =============================================================
int
auth_verify(const char *username, const char *password)
{
    80006018:	7119                	addi	sp,sp,-128
    8000601a:	fc86                	sd	ra,120(sp)
    8000601c:	f8a2                	sd	s0,112(sp)
    8000601e:	f4a6                	sd	s1,104(sp)
    80006020:	f0ca                	sd	s2,96(sp)
    80006022:	ecce                	sd	s3,88(sp)
    80006024:	e8d2                	sd	s4,80(sp)
    80006026:	e4d6                	sd	s5,72(sp)
    80006028:	0100                	addi	s0,sp,128
    8000602a:	8a2a                	mv	s4,a0
    8000602c:	852e                	mv	a0,a1
    char attempt_hash[AUTH_HASH_LEN];
    hash_password(password, attempt_hash);
    8000602e:	f8040593          	addi	a1,s0,-128
    80006032:	e3dff0ef          	jal	80005e6e <hash_password>

    acquire(&g_users.lock);
    80006036:	0001d517          	auipc	a0,0x1d
    8000603a:	4da50513          	addi	a0,a0,1242 # 80023510 <g_users+0x388>
    8000603e:	bebfa0ef          	jal	80000c28 <acquire>
    for (int i = 0; i < AUTH_MAX_USERS; i++) {
    80006042:	0001d497          	auipc	s1,0x1d
    80006046:	14648493          	addi	s1,s1,326 # 80023188 <g_users>
    8000604a:	4901                	li	s2,0
        struct passwd_entry *e = &g_users.entries[i];
        if (!e->valid) continue;
        if (strncmp(e->username, username, AUTH_NAME_LEN) == 0) {
    8000604c:	02000a93          	li	s5,32
    for (int i = 0; i < AUTH_MAX_USERS; i++) {
    80006050:	49a1                	li	s3,8
    80006052:	a031                	j	8000605e <auth_verify+0x46>
    80006054:	2905                	addiw	s2,s2,1
    80006056:	07048493          	addi	s1,s1,112
    8000605a:	05390f63          	beq	s2,s3,800060b8 <auth_verify+0xa0>
        if (!e->valid) continue;
    8000605e:	54fc                	lw	a5,108(s1)
    80006060:	dbf5                	beqz	a5,80006054 <auth_verify+0x3c>
        if (strncmp(e->username, username, AUTH_NAME_LEN) == 0) {
    80006062:	8656                	mv	a2,s5
    80006064:	85d2                	mv	a1,s4
    80006066:	8526                	mv	a0,s1
    80006068:	d65fa0ef          	jal	80000dcc <strncmp>
    8000606c:	f565                	bnez	a0,80006054 <auth_verify+0x3c>
            if (strncmp(e->passhash, attempt_hash, AUTH_HASH_LEN) == 0) {
    8000606e:	00391793          	slli	a5,s2,0x3
    80006072:	412787b3          	sub	a5,a5,s2
    80006076:	0792                	slli	a5,a5,0x4
    80006078:	02078793          	addi	a5,a5,32
    8000607c:	04000613          	li	a2,64
    80006080:	f8040593          	addi	a1,s0,-128
    80006084:	0001d517          	auipc	a0,0x1d
    80006088:	10450513          	addi	a0,a0,260 # 80023188 <g_users>
    8000608c:	953e                	add	a0,a0,a5
    8000608e:	d3ffa0ef          	jal	80000dcc <strncmp>
    80006092:	e11d                	bnez	a0,800060b8 <auth_verify+0xa0>
                int uid = e->uid;
    80006094:	00391793          	slli	a5,s2,0x3
    80006098:	412787b3          	sub	a5,a5,s2
    8000609c:	0792                	slli	a5,a5,0x4
    8000609e:	0001d717          	auipc	a4,0x1d
    800060a2:	0ea70713          	addi	a4,a4,234 # 80023188 <g_users>
    800060a6:	97ba                	add	a5,a5,a4
    800060a8:	53a4                	lw	s1,96(a5)
                release(&g_users.lock);
    800060aa:	0001d517          	auipc	a0,0x1d
    800060ae:	46650513          	addi	a0,a0,1126 # 80023510 <g_users+0x388>
    800060b2:	c0bfa0ef          	jal	80000cbc <release>
                return uid;  // Success
    800060b6:	a801                	j	800060c6 <auth_verify+0xae>
            }
            break;  // Username matched, password wrong
        }
    }
    release(&g_users.lock);
    800060b8:	0001d517          	auipc	a0,0x1d
    800060bc:	45850513          	addi	a0,a0,1112 # 80023510 <g_users+0x388>
    800060c0:	bfdfa0ef          	jal	80000cbc <release>
    return -1;  // Authentication failed
    800060c4:	54fd                	li	s1,-1
}
    800060c6:	8526                	mv	a0,s1
    800060c8:	70e6                	ld	ra,120(sp)
    800060ca:	7446                	ld	s0,112(sp)
    800060cc:	74a6                	ld	s1,104(sp)
    800060ce:	7906                	ld	s2,96(sp)
    800060d0:	69e6                	ld	s3,88(sp)
    800060d2:	6a46                	ld	s4,80(sp)
    800060d4:	6aa6                	ld	s5,72(sp)
    800060d6:	6109                	addi	sp,sp,128
    800060d8:	8082                	ret

00000000800060da <auth_add_user>:
// =============================================================
// auth_add_user — Add a new user (ADMIN only, enforced by caller)
// =============================================================
int
auth_add_user(const char *username, const char *password, int uid, int gid)
{
    800060da:	711d                	addi	sp,sp,-96
    800060dc:	ec86                	sd	ra,88(sp)
    800060de:	e8a2                	sd	s0,80(sp)
    800060e0:	fc4e                	sd	s3,56(sp)
    800060e2:	ec5e                	sd	s7,24(sp)
    800060e4:	e862                	sd	s8,16(sp)
    800060e6:	e466                	sd	s9,8(sp)
    800060e8:	e06a                	sd	s10,0(sp)
    800060ea:	1080                	addi	s0,sp,96
    800060ec:	8baa                	mv	s7,a0
    800060ee:	8c2e                	mv	s8,a1
    800060f0:	8cb2                	mv	s9,a2
    800060f2:	8d36                	mv	s10,a3
    acquire(&g_users.lock);
    800060f4:	0001d517          	auipc	a0,0x1d
    800060f8:	41c50513          	addi	a0,a0,1052 # 80023510 <g_users+0x388>
    800060fc:	b2dfa0ef          	jal	80000c28 <acquire>

    if (g_users.count >= AUTH_MAX_USERS) {
    80006100:	0001d717          	auipc	a4,0x1d
    80006104:	40872703          	lw	a4,1032(a4) # 80023508 <g_users+0x380>
    80006108:	479d                	li	a5,7
    8000610a:	02e7c163          	blt	a5,a4,8000612c <auth_add_user+0x52>
    8000610e:	e4a6                	sd	s1,72(sp)
    80006110:	e0ca                	sd	s2,64(sp)
    80006112:	f852                	sd	s4,48(sp)
    80006114:	0001d917          	auipc	s2,0x1d
    80006118:	07490913          	addi	s2,s2,116 # 80023188 <g_users>
    8000611c:	0001d997          	auipc	s3,0x1d
    80006120:	3ec98993          	addi	s3,s3,1004 # 80023508 <g_users+0x380>
    80006124:	84ca                	mv	s1,s2
    }

    // Check for duplicate username
    for (int i = 0; i < AUTH_MAX_USERS; i++) {
        if (g_users.entries[i].valid &&
            strncmp(g_users.entries[i].username, username, AUTH_NAME_LEN) == 0) {
    80006126:	02000a13          	li	s4,32
    8000612a:	a829                	j	80006144 <auth_add_user+0x6a>
        release(&g_users.lock);
    8000612c:	0001d517          	auipc	a0,0x1d
    80006130:	3e450513          	addi	a0,a0,996 # 80023510 <g_users+0x388>
    80006134:	b89fa0ef          	jal	80000cbc <release>
        return -1;  // Table full
    80006138:	59fd                	li	s3,-1
    8000613a:	a8a9                	j	80006194 <auth_add_user+0xba>
    for (int i = 0; i < AUTH_MAX_USERS; i++) {
    8000613c:	07048493          	addi	s1,s1,112
    80006140:	03348563          	beq	s1,s3,8000616a <auth_add_user+0x90>
        if (g_users.entries[i].valid &&
    80006144:	54fc                	lw	a5,108(s1)
    80006146:	dbfd                	beqz	a5,8000613c <auth_add_user+0x62>
            strncmp(g_users.entries[i].username, username, AUTH_NAME_LEN) == 0) {
    80006148:	8652                	mv	a2,s4
    8000614a:	85de                	mv	a1,s7
    8000614c:	8526                	mv	a0,s1
    8000614e:	c7ffa0ef          	jal	80000dcc <strncmp>
        if (g_users.entries[i].valid &&
    80006152:	f56d                	bnez	a0,8000613c <auth_add_user+0x62>
            release(&g_users.lock);
    80006154:	0001d517          	auipc	a0,0x1d
    80006158:	3bc50513          	addi	a0,a0,956 # 80023510 <g_users+0x388>
    8000615c:	b61fa0ef          	jal	80000cbc <release>
            return -1;  // User exists
    80006160:	59fd                	li	s3,-1
    80006162:	64a6                	ld	s1,72(sp)
    80006164:	6906                	ld	s2,64(sp)
    80006166:	7a42                	ld	s4,48(sp)
    80006168:	a035                	j	80006194 <auth_add_user+0xba>
        }
    }

    // Find empty slot
    for (int i = 0; i < AUTH_MAX_USERS; i++) {
    8000616a:	4481                	li	s1,0
    8000616c:	47a1                	li	a5,8
        if (!g_users.entries[i].valid) {
    8000616e:	06c92983          	lw	s3,108(s2)
    80006172:	02098b63          	beqz	s3,800061a8 <auth_add_user+0xce>
    for (int i = 0; i < AUTH_MAX_USERS; i++) {
    80006176:	2485                	addiw	s1,s1,1
    80006178:	07090913          	addi	s2,s2,112
    8000617c:	fef499e3          	bne	s1,a5,8000616e <auth_add_user+0x94>
            release(&g_users.lock);
            return 0;
        }
    }

    release(&g_users.lock);
    80006180:	0001d517          	auipc	a0,0x1d
    80006184:	39050513          	addi	a0,a0,912 # 80023510 <g_users+0x388>
    80006188:	b35fa0ef          	jal	80000cbc <release>
    return -1;
    8000618c:	59fd                	li	s3,-1
    8000618e:	64a6                	ld	s1,72(sp)
    80006190:	6906                	ld	s2,64(sp)
    80006192:	7a42                	ld	s4,48(sp)
}
    80006194:	854e                	mv	a0,s3
    80006196:	60e6                	ld	ra,88(sp)
    80006198:	6446                	ld	s0,80(sp)
    8000619a:	79e2                	ld	s3,56(sp)
    8000619c:	6be2                	ld	s7,24(sp)
    8000619e:	6c42                	ld	s8,16(sp)
    800061a0:	6ca2                	ld	s9,8(sp)
    800061a2:	6d02                	ld	s10,0(sp)
    800061a4:	6125                	addi	sp,sp,96
    800061a6:	8082                	ret
    800061a8:	f456                	sd	s5,40(sp)
    800061aa:	f05a                	sd	s6,32(sp)
            safestrcpy(g_users.entries[i].username, username, AUTH_NAME_LEN);
    800061ac:	00349a93          	slli	s5,s1,0x3
    800061b0:	409a85b3          	sub	a1,s5,s1
    800061b4:	00459b13          	slli	s6,a1,0x4
    800061b8:	0001da17          	auipc	s4,0x1d
    800061bc:	fd0a0a13          	addi	s4,s4,-48 # 80023188 <g_users>
    800061c0:	016a0933          	add	s2,s4,s6
    800061c4:	02000613          	li	a2,32
    800061c8:	85de                	mv	a1,s7
    800061ca:	854a                	mv	a0,s2
    800061cc:	c81fa0ef          	jal	80000e4c <safestrcpy>
            hash_password(password, g_users.entries[i].passhash);
    800061d0:	020b0593          	addi	a1,s6,32
    800061d4:	95d2                	add	a1,a1,s4
    800061d6:	8562                	mv	a0,s8
    800061d8:	c97ff0ef          	jal	80005e6e <hash_password>
            g_users.entries[i].uid   = uid;
    800061dc:	07992023          	sw	s9,96(s2)
            g_users.entries[i].gid   = gid;
    800061e0:	07a92223          	sw	s10,100(s2)
            g_users.entries[i].role  = uid;  // role mirrors uid
    800061e4:	07992423          	sw	s9,104(s2)
            g_users.entries[i].valid = 1;
    800061e8:	4705                	li	a4,1
    800061ea:	06e92623          	sw	a4,108(s2)
            g_users.count++;
    800061ee:	380a2783          	lw	a5,896(s4)
    800061f2:	2785                	addiw	a5,a5,1
    800061f4:	38fa2023          	sw	a5,896(s4)
            release(&g_users.lock);
    800061f8:	0001d517          	auipc	a0,0x1d
    800061fc:	31850513          	addi	a0,a0,792 # 80023510 <g_users+0x388>
    80006200:	abdfa0ef          	jal	80000cbc <release>
            return 0;
    80006204:	64a6                	ld	s1,72(sp)
    80006206:	6906                	ld	s2,64(sp)
    80006208:	7a42                	ld	s4,48(sp)
    8000620a:	7aa2                	ld	s5,40(sp)
    8000620c:	7b02                	ld	s6,32(sp)
    8000620e:	b759                	j	80006194 <auth_add_user+0xba>

0000000080006210 <auth_del_user>:
// =============================================================
// auth_del_user — Remove user (ADMIN only)
// =============================================================
int
auth_del_user(const char *username)
{
    80006210:	7139                	addi	sp,sp,-64
    80006212:	fc06                	sd	ra,56(sp)
    80006214:	f822                	sd	s0,48(sp)
    80006216:	f426                	sd	s1,40(sp)
    80006218:	f04a                	sd	s2,32(sp)
    8000621a:	ec4e                	sd	s3,24(sp)
    8000621c:	e852                	sd	s4,16(sp)
    8000621e:	e456                	sd	s5,8(sp)
    80006220:	e05a                	sd	s6,0(sp)
    80006222:	0080                	addi	s0,sp,64
    80006224:	8b2a                	mv	s6,a0
    acquire(&g_users.lock);
    80006226:	0001d517          	auipc	a0,0x1d
    8000622a:	2ea50513          	addi	a0,a0,746 # 80023510 <g_users+0x388>
    8000622e:	9fbfa0ef          	jal	80000c28 <acquire>
    for (int i = 0; i < AUTH_MAX_USERS; i++) {
    80006232:	0001d497          	auipc	s1,0x1d
    80006236:	f5648493          	addi	s1,s1,-170 # 80023188 <g_users>
    8000623a:	4901                	li	s2,0
        if (g_users.entries[i].valid &&
            strncmp(g_users.entries[i].username, username, AUTH_NAME_LEN) == 0) {
    8000623c:	02000a93          	li	s5,32
    for (int i = 0; i < AUTH_MAX_USERS; i++) {
    80006240:	4a21                	li	s4,8
    80006242:	a031                	j	8000624e <auth_del_user+0x3e>
    80006244:	2905                	addiw	s2,s2,1
    80006246:	07048493          	addi	s1,s1,112
    8000624a:	05490363          	beq	s2,s4,80006290 <auth_del_user+0x80>
        if (g_users.entries[i].valid &&
    8000624e:	54fc                	lw	a5,108(s1)
    80006250:	dbf5                	beqz	a5,80006244 <auth_del_user+0x34>
            strncmp(g_users.entries[i].username, username, AUTH_NAME_LEN) == 0) {
    80006252:	8656                	mv	a2,s5
    80006254:	85da                	mv	a1,s6
    80006256:	8526                	mv	a0,s1
    80006258:	b75fa0ef          	jal	80000dcc <strncmp>
    8000625c:	89aa                	mv	s3,a0
        if (g_users.entries[i].valid &&
    8000625e:	f17d                	bnez	a0,80006244 <auth_del_user+0x34>
            g_users.entries[i].valid = 0;
    80006260:	0001d717          	auipc	a4,0x1d
    80006264:	f2870713          	addi	a4,a4,-216 # 80023188 <g_users>
    80006268:	00391793          	slli	a5,s2,0x3
    8000626c:	412787b3          	sub	a5,a5,s2
    80006270:	0792                	slli	a5,a5,0x4
    80006272:	97ba                	add	a5,a5,a4
    80006274:	0607a623          	sw	zero,108(a5)
            g_users.count--;
    80006278:	38072783          	lw	a5,896(a4)
    8000627c:	37fd                	addiw	a5,a5,-1
    8000627e:	38f72023          	sw	a5,896(a4)
            release(&g_users.lock);
    80006282:	0001d517          	auipc	a0,0x1d
    80006286:	28e50513          	addi	a0,a0,654 # 80023510 <g_users+0x388>
    8000628a:	a33fa0ef          	jal	80000cbc <release>
            return 0;
    8000628e:	a801                	j	8000629e <auth_del_user+0x8e>
        }
    }
    release(&g_users.lock);
    80006290:	0001d517          	auipc	a0,0x1d
    80006294:	28050513          	addi	a0,a0,640 # 80023510 <g_users+0x388>
    80006298:	a25fa0ef          	jal	80000cbc <release>
    return -1;  // User not found
    8000629c:	59fd                	li	s3,-1
    8000629e:	854e                	mv	a0,s3
    800062a0:	70e2                	ld	ra,56(sp)
    800062a2:	7442                	ld	s0,48(sp)
    800062a4:	74a2                	ld	s1,40(sp)
    800062a6:	7902                	ld	s2,32(sp)
    800062a8:	69e2                	ld	s3,24(sp)
    800062aa:	6a42                	ld	s4,16(sp)
    800062ac:	6aa2                	ld	s5,8(sp)
    800062ae:	6b02                	ld	s6,0(sp)
    800062b0:	6121                	addi	sp,sp,64
    800062b2:	8082                	ret

00000000800062b4 <sys_login>:
// sys_login — Authenticate user, set proc credentials
// Called by login shell; transitions process from uid=-1 to real uid
// =============================================================
uint64
sys_login(void)
{
    800062b4:	711d                	addi	sp,sp,-96
    800062b6:	ec86                	sd	ra,88(sp)
    800062b8:	e8a2                	sd	s0,80(sp)
    800062ba:	e4a6                	sd	s1,72(sp)
    800062bc:	1080                	addi	s0,sp,96
    char username[32], password[32];

    // Safely copy arguments from user space
    // argstr validates the pointer is in user address space
    if (argstr(0, username, 32) < 0 ||
    800062be:	02000613          	li	a2,32
    800062c2:	fc040593          	addi	a1,s0,-64
    800062c6:	4501                	li	a0,0
    800062c8:	ed0fc0ef          	jal	80002998 <argstr>
        argstr(1, password, 32) < 0)
        return -1;
    800062cc:	54fd                	li	s1,-1
    if (argstr(0, username, 32) < 0 ||
    800062ce:	06054f63          	bltz	a0,8000634c <sys_login+0x98>
        argstr(1, password, 32) < 0)
    800062d2:	02000613          	li	a2,32
    800062d6:	fa040593          	addi	a1,s0,-96
    800062da:	4505                	li	a0,1
    800062dc:	ebcfc0ef          	jal	80002998 <argstr>
    if (argstr(0, username, 32) < 0 ||
    800062e0:	06054663          	bltz	a0,8000634c <sys_login+0x98>

    int uid = auth_verify(username, password);
    800062e4:	fa040593          	addi	a1,s0,-96
    800062e8:	fc040513          	addi	a0,s0,-64
    800062ec:	d2dff0ef          	jal	80006018 <auth_verify>
    800062f0:	84aa                	mv	s1,a0
    if (uid < 0) {
    800062f2:	06054363          	bltz	a0,80006358 <sys_login+0xa4>
    800062f6:	e0ca                	sd	s2,64(sp)
        audit_log_event(myproc()->pid, -1, SYS_login, "FAIL:bad_credentials");
        return -1;
    }

    // Set credentials on the calling process
    struct proc *p = myproc();
    800062f8:	e3efb0ef          	jal	80001936 <myproc>
    800062fc:	892a                	mv	s2,a0
    acquire(&p->lock);
    800062fe:	92bfa0ef          	jal	80000c28 <acquire>
    p->creds.uid           = uid;
    80006302:	16992423          	sw	s1,360(s2)
    p->creds.gid           = uid;   // gid mirrors uid for this project
    80006306:	16992623          	sw	s1,364(s2)
    p->creds.role          = uid;
    8000630a:	16992823          	sw	s1,368(s2)
    p->creds.authenticated = 1;
    8000630e:	4785                	li	a5,1
    80006310:	16f92a23          	sw	a5,372(s2)
    safestrcpy(p->creds.username, username, 32);
    80006314:	02000613          	li	a2,32
    80006318:	fc040593          	addi	a1,s0,-64
    8000631c:	17890513          	addi	a0,s2,376
    80006320:	b2dfa0ef          	jal	80000e4c <safestrcpy>
    // Initialize stack canary (simplified — production uses random value)
    p->stack_canary = 0xDEADBEEFCAFEBABE;
    80006324:	00002797          	auipc	a5,0x2
    80006328:	cdc7b783          	ld	a5,-804(a5) # 80008000 <etext>
    8000632c:	18f93c23          	sd	a5,408(s2)
    
    release(&p->lock);
    80006330:	854a                	mv	a0,s2
    80006332:	98bfa0ef          	jal	80000cbc <release>

    audit_log_event(p->pid, uid, SYS_login, "SUCCESS:login");
    80006336:	00002697          	auipc	a3,0x2
    8000633a:	73268693          	addi	a3,a3,1842 # 80008a68 <etext+0xa68>
    8000633e:	4659                	li	a2,22
    80006340:	85a6                	mv	a1,s1
    80006342:	03092503          	lw	a0,48(s2)
    80006346:	464000ef          	jal	800067aa <audit_log_event>
    8000634a:	6906                	ld	s2,64(sp)
    return uid;
}
    8000634c:	8526                	mv	a0,s1
    8000634e:	60e6                	ld	ra,88(sp)
    80006350:	6446                	ld	s0,80(sp)
    80006352:	64a6                	ld	s1,72(sp)
    80006354:	6125                	addi	sp,sp,96
    80006356:	8082                	ret
        audit_log_event(myproc()->pid, -1, SYS_login, "FAIL:bad_credentials");
    80006358:	ddefb0ef          	jal	80001936 <myproc>
    8000635c:	00002697          	auipc	a3,0x2
    80006360:	6f468693          	addi	a3,a3,1780 # 80008a50 <etext+0xa50>
    80006364:	4659                	li	a2,22
    80006366:	55fd                	li	a1,-1
    80006368:	5908                	lw	a0,48(a0)
    8000636a:	440000ef          	jal	800067aa <audit_log_event>
        return -1;
    8000636e:	54fd                	li	s1,-1
    80006370:	bff1                	j	8000634c <sys_login+0x98>

0000000080006372 <sys_whoami>:
// =============================================================
// sys_whoami — Return current UID to user space
// =============================================================
uint64
sys_whoami(void)
{
    80006372:	1141                	addi	sp,sp,-16
    80006374:	e406                	sd	ra,8(sp)
    80006376:	e022                	sd	s0,0(sp)
    80006378:	0800                	addi	s0,sp,16
    struct proc *p = myproc();
    8000637a:	dbcfb0ef          	jal	80001936 <myproc>
    return p->creds.uid;
}
    8000637e:	16852503          	lw	a0,360(a0)
    80006382:	60a2                	ld	ra,8(sp)
    80006384:	6402                	ld	s0,0(sp)
    80006386:	0141                	addi	sp,sp,16
    80006388:	8082                	ret

000000008000638a <sys_useradd>:
// sys_useradd — Add user (ADMIN only)
// Demonstrates PoLP: only uid=0 can create new accounts
// =============================================================
uint64
sys_useradd(void)
{
    8000638a:	7159                	addi	sp,sp,-112
    8000638c:	f486                	sd	ra,104(sp)
    8000638e:	f0a2                	sd	s0,96(sp)
    80006390:	eca6                	sd	s1,88(sp)
    80006392:	1880                	addi	s0,sp,112
    struct proc *p = myproc();
    80006394:	da2fb0ef          	jal	80001936 <myproc>
    80006398:	84aa                	mv	s1,a0

    // ENFORCE: Only admin can add users
    if (p->creds.uid != ROLE_ADMIN) {
    8000639a:	16852583          	lw	a1,360(a0)
    8000639e:	e5c1                	bnez	a1,80006426 <sys_useradd+0x9c>
    }

    char username[32], password[32];
    int  uid, gid;

    if (argstr(0, username, 32) < 0 ||
    800063a0:	02000613          	li	a2,32
    800063a4:	fc040593          	addi	a1,s0,-64
    800063a8:	4501                	li	a0,0
    800063aa:	deefc0ef          	jal	80002998 <argstr>
        argstr(1, password, 32) < 0 ||
        argint(2, &uid)         < 0 ||
        argint(3, &gid)         < 0)
        return -1;
    800063ae:	57fd                	li	a5,-1
    if (argstr(0, username, 32) < 0 ||
    800063b0:	08054463          	bltz	a0,80006438 <sys_useradd+0xae>
        argstr(1, password, 32) < 0 ||
    800063b4:	02000613          	li	a2,32
    800063b8:	fa040593          	addi	a1,s0,-96
    800063bc:	4505                	li	a0,1
    800063be:	ddafc0ef          	jal	80002998 <argstr>
        return -1;
    800063c2:	57fd                	li	a5,-1
    if (argstr(0, username, 32) < 0 ||
    800063c4:	06054a63          	bltz	a0,80006438 <sys_useradd+0xae>
        argint(2, &uid)         < 0 ||
    800063c8:	f9c40593          	addi	a1,s0,-100
    800063cc:	4509                	li	a0,2
    800063ce:	d8efc0ef          	jal	8000295c <argint>
        return -1;
    800063d2:	57fd                	li	a5,-1
        argstr(1, password, 32) < 0 ||
    800063d4:	06054263          	bltz	a0,80006438 <sys_useradd+0xae>
        argint(3, &gid)         < 0)
    800063d8:	f9840593          	addi	a1,s0,-104
    800063dc:	450d                	li	a0,3
    800063de:	d7efc0ef          	jal	8000295c <argint>
        return -1;
    800063e2:	57fd                	li	a5,-1
        argint(2, &uid)         < 0 ||
    800063e4:	04054a63          	bltz	a0,80006438 <sys_useradd+0xae>
    800063e8:	e8ca                	sd	s2,80(sp)

    int result = auth_add_user(username, password, uid, gid);
    800063ea:	f9842683          	lw	a3,-104(s0)
    800063ee:	f9c42603          	lw	a2,-100(s0)
    800063f2:	fa040593          	addi	a1,s0,-96
    800063f6:	fc040513          	addi	a0,s0,-64
    800063fa:	ce1ff0ef          	jal	800060da <auth_add_user>
    800063fe:	87aa                	mv	a5,a0
    80006400:	892a                	mv	s2,a0
    audit_log_event(p->pid, p->creds.uid, SYS_useradd,
    80006402:	5888                	lw	a0,48(s1)
    80006404:	1684a583          	lw	a1,360(s1)
    80006408:	00002697          	auipc	a3,0x2
    8000640c:	68068693          	addi	a3,a3,1664 # 80008a88 <etext+0xa88>
    80006410:	e789                	bnez	a5,8000641a <sys_useradd+0x90>
    80006412:	00002697          	auipc	a3,0x2
    80006416:	66668693          	addi	a3,a3,1638 # 80008a78 <etext+0xa78>
    8000641a:	465d                	li	a2,23
    8000641c:	38e000ef          	jal	800067aa <audit_log_event>
                    result == 0 ? "SUCCESS:useradd" : "FAIL:useradd");
    return result;
    80006420:	87ca                	mv	a5,s2
    80006422:	6946                	ld	s2,80(sp)
    80006424:	a811                	j	80006438 <sys_useradd+0xae>
        audit_log_event(p->pid, p->creds.uid, SYS_useradd, "DENIED:not_admin");
    80006426:	00002697          	auipc	a3,0x2
    8000642a:	67268693          	addi	a3,a3,1650 # 80008a98 <etext+0xa98>
    8000642e:	465d                	li	a2,23
    80006430:	5908                	lw	a0,48(a0)
    80006432:	378000ef          	jal	800067aa <audit_log_event>
        return -1;
    80006436:	57fd                	li	a5,-1
}
    80006438:	853e                	mv	a0,a5
    8000643a:	70a6                	ld	ra,104(sp)
    8000643c:	7406                	ld	s0,96(sp)
    8000643e:	64e6                	ld	s1,88(sp)
    80006440:	6165                	addi	sp,sp,112
    80006442:	8082                	ret

0000000080006444 <sys_userdel>:
// =============================================================
// sys_userdel — Delete user (ADMIN only)
// =============================================================
uint64
sys_userdel(void)
{
    80006444:	7139                	addi	sp,sp,-64
    80006446:	fc06                	sd	ra,56(sp)
    80006448:	f822                	sd	s0,48(sp)
    8000644a:	f426                	sd	s1,40(sp)
    8000644c:	0080                	addi	s0,sp,64
    struct proc *p = myproc();
    8000644e:	ce8fb0ef          	jal	80001936 <myproc>
    80006452:	84aa                	mv	s1,a0

    if (p->creds.uid != ROLE_ADMIN) {
    80006454:	16852583          	lw	a1,360(a0)
    80006458:	e1a1                	bnez	a1,80006498 <sys_userdel+0x54>
        audit_log_event(p->pid, p->creds.uid, SYS_userdel, "DENIED:not_admin");
        return -1;
    }

    char username[32];
    if (argstr(0, username, 32) < 0)
    8000645a:	02000613          	li	a2,32
    8000645e:	fc040593          	addi	a1,s0,-64
    80006462:	4501                	li	a0,0
    80006464:	d34fc0ef          	jal	80002998 <argstr>
        return -1;
    80006468:	57fd                	li	a5,-1
    if (argstr(0, username, 32) < 0)
    8000646a:	02054163          	bltz	a0,8000648c <sys_userdel+0x48>

    // Prevent deleting own account — safety guard
    if (strncmp(username, p->creds.username, 32) == 0)
    8000646e:	02000613          	li	a2,32
    80006472:	17848593          	addi	a1,s1,376
    80006476:	fc040513          	addi	a0,s0,-64
    8000647a:	953fa0ef          	jal	80000dcc <strncmp>
        return -1;
    8000647e:	57fd                	li	a5,-1
    if (strncmp(username, p->creds.username, 32) == 0)
    80006480:	c511                	beqz	a0,8000648c <sys_userdel+0x48>

    return auth_del_user(username);
    80006482:	fc040513          	addi	a0,s0,-64
    80006486:	d8bff0ef          	jal	80006210 <auth_del_user>
    8000648a:	87aa                	mv	a5,a0
}
    8000648c:	853e                	mv	a0,a5
    8000648e:	70e2                	ld	ra,56(sp)
    80006490:	7442                	ld	s0,48(sp)
    80006492:	74a2                	ld	s1,40(sp)
    80006494:	6121                	addi	sp,sp,64
    80006496:	8082                	ret
        audit_log_event(p->pid, p->creds.uid, SYS_userdel, "DENIED:not_admin");
    80006498:	00002697          	auipc	a3,0x2
    8000649c:	60068693          	addi	a3,a3,1536 # 80008a98 <etext+0xa98>
    800064a0:	4661                	li	a2,24
    800064a2:	5908                	lw	a0,48(a0)
    800064a4:	306000ef          	jal	800067aa <audit_log_event>
        return -1;
    800064a8:	57fd                	li	a5,-1
    800064aa:	b7cd                	j	8000648c <sys_userdel+0x48>

00000000800064ac <sys_passwd>:
// =============================================================
// sys_passwd — Change password (own account, or admin for any)
// =============================================================
uint64
sys_passwd(void)
{
    800064ac:	7135                	addi	sp,sp,-160
    800064ae:	ed06                	sd	ra,152(sp)
    800064b0:	e922                	sd	s0,144(sp)
    800064b2:	e526                	sd	s1,136(sp)
    800064b4:	f4d6                	sd	s5,104(sp)
    800064b6:	1100                	addi	s0,sp,160
    struct proc *p = myproc();
    800064b8:	c7efb0ef          	jal	80001936 <myproc>
    800064bc:	84aa                	mv	s1,a0
    800064be:	8aaa                	mv	s5,a0
    char username[32], old_pw[32], new_pw[32];

    if (argstr(0, username, 32) < 0 ||
    800064c0:	02000613          	li	a2,32
    800064c4:	fa040593          	addi	a1,s0,-96
    800064c8:	4501                	li	a0,0
    800064ca:	ccefc0ef          	jal	80002998 <argstr>
        argstr(1, old_pw,   32) < 0 ||
        argstr(2, new_pw,   32) < 0)
        return -1;
    800064ce:	57fd                	li	a5,-1
    if (argstr(0, username, 32) < 0 ||
    800064d0:	12054463          	bltz	a0,800065f8 <sys_passwd+0x14c>
        argstr(1, old_pw,   32) < 0 ||
    800064d4:	02000613          	li	a2,32
    800064d8:	f8040593          	addi	a1,s0,-128
    800064dc:	4505                	li	a0,1
    800064de:	cbafc0ef          	jal	80002998 <argstr>
        return -1;
    800064e2:	57fd                	li	a5,-1
    if (argstr(0, username, 32) < 0 ||
    800064e4:	10054a63          	bltz	a0,800065f8 <sys_passwd+0x14c>
        argstr(2, new_pw,   32) < 0)
    800064e8:	02000613          	li	a2,32
    800064ec:	f6040593          	addi	a1,s0,-160
    800064f0:	4509                	li	a0,2
    800064f2:	ca6fc0ef          	jal	80002998 <argstr>
        argstr(1, old_pw,   32) < 0 ||
    800064f6:	10054863          	bltz	a0,80006606 <sys_passwd+0x15a>

    // Non-admin can only change their own password
    if (p->creds.uid != ROLE_ADMIN &&
    800064fa:	1684a783          	lw	a5,360(s1)
    800064fe:	e39d                	bnez	a5,80006524 <sys_passwd+0x78>
    80006500:	e14a                	sd	s2,128(sp)
    80006502:	fcce                	sd	s3,120(sp)
    80006504:	f8d2                	sd	s4,112(sp)
            return -1;
        }
    }

    // Update hash in user table
    acquire(&g_users.lock);
    80006506:	0001d517          	auipc	a0,0x1d
    8000650a:	00a50513          	addi	a0,a0,10 # 80023510 <g_users+0x388>
    8000650e:	f1afa0ef          	jal	80000c28 <acquire>
    for (int i = 0; i < AUTH_MAX_USERS; i++) {
    80006512:	0001d497          	auipc	s1,0x1d
    80006516:	c7648493          	addi	s1,s1,-906 # 80023188 <g_users>
    8000651a:	4901                	li	s2,0
        if (g_users.entries[i].valid &&
            strncmp(g_users.entries[i].username, username, 32) == 0) {
    8000651c:	fa040a13          	addi	s4,s0,-96
    for (int i = 0; i < AUTH_MAX_USERS; i++) {
    80006520:	49a1                	li	s3,8
    80006522:	a095                	j	80006586 <sys_passwd+0xda>
        strncmp(username, p->creds.username, 32) != 0) {
    80006524:	02000613          	li	a2,32
    80006528:	17848593          	addi	a1,s1,376
    8000652c:	fa040513          	addi	a0,s0,-96
    80006530:	89dfa0ef          	jal	80000dcc <strncmp>
    if (p->creds.uid != ROLE_ADMIN &&
    80006534:	e905                	bnez	a0,80006564 <sys_passwd+0xb8>
    if (p->creds.uid != ROLE_ADMIN) {
    80006536:	1684a783          	lw	a5,360(s1)
    8000653a:	d3f9                	beqz	a5,80006500 <sys_passwd+0x54>
        if (auth_verify(username, old_pw) < 0) {
    8000653c:	f8040593          	addi	a1,s0,-128
    80006540:	fa040513          	addi	a0,s0,-96
    80006544:	ad5ff0ef          	jal	80006018 <auth_verify>
    80006548:	fa055ce3          	bgez	a0,80006500 <sys_passwd+0x54>
            audit_log_event(p->pid, p->creds.uid, SYS_passwd, "FAIL:wrong_password");
    8000654c:	00002697          	auipc	a3,0x2
    80006550:	57c68693          	addi	a3,a3,1404 # 80008ac8 <etext+0xac8>
    80006554:	4665                	li	a2,25
    80006556:	1684a583          	lw	a1,360(s1)
    8000655a:	5888                	lw	a0,48(s1)
    8000655c:	24e000ef          	jal	800067aa <audit_log_event>
            return -1;
    80006560:	57fd                	li	a5,-1
    80006562:	a859                	j	800065f8 <sys_passwd+0x14c>
        audit_log_event(p->pid, p->creds.uid, SYS_passwd, "DENIED:wrong_user");
    80006564:	00002697          	auipc	a3,0x2
    80006568:	54c68693          	addi	a3,a3,1356 # 80008ab0 <etext+0xab0>
    8000656c:	4665                	li	a2,25
    8000656e:	1684a583          	lw	a1,360(s1)
    80006572:	5888                	lw	a0,48(s1)
    80006574:	236000ef          	jal	800067aa <audit_log_event>
        return -1;
    80006578:	57fd                	li	a5,-1
    8000657a:	a8bd                	j	800065f8 <sys_passwd+0x14c>
    for (int i = 0; i < AUTH_MAX_USERS; i++) {
    8000657c:	2905                	addiw	s2,s2,1
    8000657e:	07048493          	addi	s1,s1,112
    80006582:	07390163          	beq	s2,s3,800065e4 <sys_passwd+0x138>
        if (g_users.entries[i].valid &&
    80006586:	54fc                	lw	a5,108(s1)
    80006588:	dbf5                	beqz	a5,8000657c <sys_passwd+0xd0>
            strncmp(g_users.entries[i].username, username, 32) == 0) {
    8000658a:	02000613          	li	a2,32
    8000658e:	85d2                	mv	a1,s4
    80006590:	8526                	mv	a0,s1
    80006592:	83bfa0ef          	jal	80000dcc <strncmp>
        if (g_users.entries[i].valid &&
    80006596:	f17d                	bnez	a0,8000657c <sys_passwd+0xd0>
            hash_password(new_pw, g_users.entries[i].passhash);
    80006598:	00391793          	slli	a5,s2,0x3
    8000659c:	412787b3          	sub	a5,a5,s2
    800065a0:	0792                	slli	a5,a5,0x4
    800065a2:	02078793          	addi	a5,a5,32
    800065a6:	0001d597          	auipc	a1,0x1d
    800065aa:	be258593          	addi	a1,a1,-1054 # 80023188 <g_users>
    800065ae:	95be                	add	a1,a1,a5
    800065b0:	f6040513          	addi	a0,s0,-160
    800065b4:	8bbff0ef          	jal	80005e6e <hash_password>
            release(&g_users.lock);
    800065b8:	0001d517          	auipc	a0,0x1d
    800065bc:	f5850513          	addi	a0,a0,-168 # 80023510 <g_users+0x388>
    800065c0:	efcfa0ef          	jal	80000cbc <release>
            audit_log_event(p->pid, p->creds.uid, SYS_passwd, "SUCCESS:passwd_changed");
    800065c4:	00002697          	auipc	a3,0x2
    800065c8:	51c68693          	addi	a3,a3,1308 # 80008ae0 <etext+0xae0>
    800065cc:	4665                	li	a2,25
    800065ce:	168aa583          	lw	a1,360(s5)
    800065d2:	030aa503          	lw	a0,48(s5)
    800065d6:	1d4000ef          	jal	800067aa <audit_log_event>
            return 0;
    800065da:	4781                	li	a5,0
    800065dc:	690a                	ld	s2,128(sp)
    800065de:	79e6                	ld	s3,120(sp)
    800065e0:	7a46                	ld	s4,112(sp)
    800065e2:	a819                	j	800065f8 <sys_passwd+0x14c>
        }
    }
    release(&g_users.lock);
    800065e4:	0001d517          	auipc	a0,0x1d
    800065e8:	f2c50513          	addi	a0,a0,-212 # 80023510 <g_users+0x388>
    800065ec:	ed0fa0ef          	jal	80000cbc <release>
    return -1;
    800065f0:	57fd                	li	a5,-1
    800065f2:	690a                	ld	s2,128(sp)
    800065f4:	79e6                	ld	s3,120(sp)
    800065f6:	7a46                	ld	s4,112(sp)
}
    800065f8:	853e                	mv	a0,a5
    800065fa:	60ea                	ld	ra,152(sp)
    800065fc:	644a                	ld	s0,144(sp)
    800065fe:	64aa                	ld	s1,136(sp)
    80006600:	7aa6                	ld	s5,104(sp)
    80006602:	610d                	addi	sp,sp,160
    80006604:	8082                	ret
        return -1;
    80006606:	57fd                	li	a5,-1
    80006608:	bfc5                	j	800065f8 <sys_passwd+0x14c>

000000008000660a <sys_chmod>:
// sys_chmod — Change file mode/permissions
// Only owner or admin (uid=0) may change permissions
// =============================================================
uint64
sys_chmod(void)
{
    8000660a:	7171                	addi	sp,sp,-176
    8000660c:	f506                	sd	ra,168(sp)
    8000660e:	f122                	sd	s0,160(sp)
    80006610:	e94a                	sd	s2,144(sp)
    80006612:	1900                	addi	s0,sp,176
    char path[MAXPATH];
    uint mode;
    struct inode *ip;
    struct proc *p = myproc();
    80006614:	b22fb0ef          	jal	80001936 <myproc>
    80006618:	892a                	mv	s2,a0

    if(argstr(0, path, MAXPATH) < 0)
    8000661a:	08000613          	li	a2,128
    8000661e:	f6040593          	addi	a1,s0,-160
    80006622:	4501                	li	a0,0
    80006624:	b74fc0ef          	jal	80002998 <argstr>
        return -1;
    80006628:	57fd                	li	a5,-1
    if(argstr(0, path, MAXPATH) < 0)
    8000662a:	04054a63          	bltz	a0,8000667e <sys_chmod+0x74>
    if(argint(1, (int*)&mode) < 0)
    8000662e:	f5c40593          	addi	a1,s0,-164
    80006632:	4505                	li	a0,1
    80006634:	b28fc0ef          	jal	8000295c <argint>
        return -1;
    80006638:	57fd                	li	a5,-1
    if(argint(1, (int*)&mode) < 0)
    8000663a:	04054263          	bltz	a0,8000667e <sys_chmod+0x74>
    8000663e:	ed26                	sd	s1,152(sp)

    begin_op();
    80006640:	f62fd0ef          	jal	80003da2 <begin_op>
    if((ip = namei(path)) == 0){
    80006644:	f6040513          	addi	a0,s0,-160
    80006648:	d7cfd0ef          	jal	80003bc4 <namei>
    8000664c:	84aa                	mv	s1,a0
    8000664e:	cd15                	beqz	a0,8000668a <sys_chmod+0x80>
        end_op();
        return -1;  // File not found
    }

    ilock(ip);
    80006650:	d21fc0ef          	jal	80003370 <ilock>

    // Permission check: only owner or admin can change permissions
    if(ip->uid != p->creds.uid && p->creds.uid != ROLE_ADMIN){
    80006654:	16892783          	lw	a5,360(s2)
    80006658:	0884a703          	lw	a4,136(s1)
    8000665c:	00f70363          	beq	a4,a5,80006662 <sys_chmod+0x58>
    80006660:	eb95                	bnez	a5,80006694 <sys_chmod+0x8a>
        iunlockput(ip);
        end_op();
        return -1;  // Permission denied
    }

    ip->mode = mode;
    80006662:	f5c42783          	lw	a5,-164(s0)
    80006666:	08f4a223          	sw	a5,132(s1)
    iupdate(ip);
    8000666a:	8526                	mv	a0,s1
    8000666c:	c33fc0ef          	jal	8000329e <iupdate>

    iunlockput(ip);
    80006670:	8526                	mv	a0,s1
    80006672:	f2dfc0ef          	jal	8000359e <iunlockput>
    end_op();
    80006676:	f9cfd0ef          	jal	80003e12 <end_op>
    return 0;  // Success
    8000667a:	4781                	li	a5,0
    8000667c:	64ea                	ld	s1,152(sp)
}
    8000667e:	853e                	mv	a0,a5
    80006680:	70aa                	ld	ra,168(sp)
    80006682:	740a                	ld	s0,160(sp)
    80006684:	694a                	ld	s2,144(sp)
    80006686:	614d                	addi	sp,sp,176
    80006688:	8082                	ret
        end_op();
    8000668a:	f88fd0ef          	jal	80003e12 <end_op>
        return -1;  // File not found
    8000668e:	57fd                	li	a5,-1
    80006690:	64ea                	ld	s1,152(sp)
    80006692:	b7f5                	j	8000667e <sys_chmod+0x74>
        iunlockput(ip);
    80006694:	8526                	mv	a0,s1
    80006696:	f09fc0ef          	jal	8000359e <iunlockput>
        end_op();
    8000669a:	f78fd0ef          	jal	80003e12 <end_op>
        return -1;  // Permission denied
    8000669e:	57fd                	li	a5,-1
    800066a0:	64ea                	ld	s1,152(sp)
    800066a2:	bff1                	j	8000667e <sys_chmod+0x74>

00000000800066a4 <sys_chown>:
// sys_chown — Change file owner and group
// Only owner or admin (uid=0) may change ownership
// =============================================================
uint64
sys_chown(void)
{
    800066a4:	7171                	addi	sp,sp,-176
    800066a6:	f506                	sd	ra,168(sp)
    800066a8:	f122                	sd	s0,160(sp)
    800066aa:	e94a                	sd	s2,144(sp)
    800066ac:	1900                	addi	s0,sp,176
    char path[MAXPATH];
    int uid, gid;
    struct inode *ip;
    struct proc *p = myproc();
    800066ae:	a88fb0ef          	jal	80001936 <myproc>
    800066b2:	892a                	mv	s2,a0

    if(argstr(0, path, MAXPATH) < 0)
    800066b4:	08000613          	li	a2,128
    800066b8:	f6040593          	addi	a1,s0,-160
    800066bc:	4501                	li	a0,0
    800066be:	adafc0ef          	jal	80002998 <argstr>
        return -1;
    800066c2:	57fd                	li	a5,-1
    if(argstr(0, path, MAXPATH) < 0)
    800066c4:	06054663          	bltz	a0,80006730 <sys_chown+0x8c>
    if(argint(1, &uid) < 0)
    800066c8:	f5c40593          	addi	a1,s0,-164
    800066cc:	4505                	li	a0,1
    800066ce:	a8efc0ef          	jal	8000295c <argint>
        return -1;
    800066d2:	57fd                	li	a5,-1
    if(argint(1, &uid) < 0)
    800066d4:	04054e63          	bltz	a0,80006730 <sys_chown+0x8c>
    if(argint(2, &gid) < 0)
    800066d8:	f5840593          	addi	a1,s0,-168
    800066dc:	4509                	li	a0,2
    800066de:	a7efc0ef          	jal	8000295c <argint>
        return -1;
    800066e2:	57fd                	li	a5,-1
    if(argint(2, &gid) < 0)
    800066e4:	04054663          	bltz	a0,80006730 <sys_chown+0x8c>
    800066e8:	ed26                	sd	s1,152(sp)

    begin_op();
    800066ea:	eb8fd0ef          	jal	80003da2 <begin_op>
    if((ip = namei(path)) == 0){
    800066ee:	f6040513          	addi	a0,s0,-160
    800066f2:	cd2fd0ef          	jal	80003bc4 <namei>
    800066f6:	84aa                	mv	s1,a0
    800066f8:	c131                	beqz	a0,8000673c <sys_chown+0x98>
        end_op();
        return -1;  // File not found
    }

    ilock(ip);
    800066fa:	c77fc0ef          	jal	80003370 <ilock>

    // Permission check: only owner or admin can change ownership
    if(ip->uid != p->creds.uid && p->creds.uid != ROLE_ADMIN){
    800066fe:	16892783          	lw	a5,360(s2)
    80006702:	0884a703          	lw	a4,136(s1)
    80006706:	00f70363          	beq	a4,a5,8000670c <sys_chown+0x68>
    8000670a:	ef95                	bnez	a5,80006746 <sys_chown+0xa2>
        iunlockput(ip);
        end_op();
        return -1;  // Permission denied
    }

    ip->uid = uid;
    8000670c:	f5c42783          	lw	a5,-164(s0)
    80006710:	08f4a423          	sw	a5,136(s1)
    ip->gid = gid;
    80006714:	f5842783          	lw	a5,-168(s0)
    80006718:	08f4a623          	sw	a5,140(s1)
    iupdate(ip);
    8000671c:	8526                	mv	a0,s1
    8000671e:	b81fc0ef          	jal	8000329e <iupdate>

    iunlockput(ip);
    80006722:	8526                	mv	a0,s1
    80006724:	e7bfc0ef          	jal	8000359e <iunlockput>
    end_op();
    80006728:	eeafd0ef          	jal	80003e12 <end_op>
    return 0;  // Success
    8000672c:	4781                	li	a5,0
    8000672e:	64ea                	ld	s1,152(sp)
    80006730:	853e                	mv	a0,a5
    80006732:	70aa                	ld	ra,168(sp)
    80006734:	740a                	ld	s0,160(sp)
    80006736:	694a                	ld	s2,144(sp)
    80006738:	614d                	addi	sp,sp,176
    8000673a:	8082                	ret
        end_op();
    8000673c:	ed6fd0ef          	jal	80003e12 <end_op>
        return -1;  // File not found
    80006740:	57fd                	li	a5,-1
    80006742:	64ea                	ld	s1,152(sp)
    80006744:	b7f5                	j	80006730 <sys_chown+0x8c>
        iunlockput(ip);
    80006746:	8526                	mv	a0,s1
    80006748:	e57fc0ef          	jal	8000359e <iunlockput>
        end_op();
    8000674c:	ec6fd0ef          	jal	80003e12 <end_op>
        return -1;  // Permission denied
    80006750:	57fd                	li	a5,-1
    80006752:	64ea                	ld	s1,152(sp)
    80006754:	bff1                	j	80006730 <sys_chown+0x8c>

0000000080006756 <audit_init>:
// =============================================================
// audit_init — Called from main() at boot
// =============================================================
void
audit_init(void)
{
    80006756:	1141                	addi	sp,sp,-16
    80006758:	e406                	sd	ra,8(sp)
    8000675a:	e022                	sd	s0,0(sp)
    8000675c:	0800                	addi	s0,sp,16
    initlock(&g_audit.lock, "audit");
    8000675e:	00002597          	auipc	a1,0x2
    80006762:	39a58593          	addi	a1,a1,922 # 80008af8 <etext+0xaf8>
    80006766:	00028517          	auipc	a0,0x28
    8000676a:	1d250513          	addi	a0,a0,466 # 8002e938 <g_audit+0xb410>
    8000676e:	c30fa0ef          	jal	80000b9e <initlock>
    g_audit.head  = 0;
    80006772:	00028797          	auipc	a5,0x28
    80006776:	db678793          	addi	a5,a5,-586 # 8002e528 <g_audit+0xb000>
    8000677a:	4007a023          	sw	zero,1024(a5)
    g_audit.tail  = 0;
    8000677e:	4007a223          	sw	zero,1028(a5)
    g_audit.count = 0;
    80006782:	4007a423          	sw	zero,1032(a5)
    // Clear buffer
    for (int i = 0; i < AUDIT_MAX; i++)
    80006786:	0001d797          	auipc	a5,0x1d
    8000678a:	e5278793          	addi	a5,a5,-430 # 800235d8 <g_audit+0xb0>
    8000678e:	00028717          	auipc	a4,0x28
    80006792:	24a70713          	addi	a4,a4,586 # 8002e9d8 <end+0x88>
        g_audit.buf[i].valid = 0;
    80006796:	0007a023          	sw	zero,0(a5)
    for (int i = 0; i < AUDIT_MAX; i++)
    8000679a:	0b478793          	addi	a5,a5,180
    8000679e:	fee79ce3          	bne	a5,a4,80006796 <audit_init+0x40>
}
    800067a2:	60a2                	ld	ra,8(sp)
    800067a4:	6402                	ld	s0,0(sp)
    800067a6:	0141                	addi	sp,sp,16
    800067a8:	8082                	ret

00000000800067aa <audit_log_event>:
// audit_log_event — Write an event to ring buffer AND disk file
// Called from anywhere in the kernel (interrupt-safe via spinlock)
// =============================================================
void
audit_log_event(int pid, int uid, int syscall_num, const char *message)
{
    800067aa:	7131                	addi	sp,sp,-192
    800067ac:	fd06                	sd	ra,184(sp)
    800067ae:	f922                	sd	s0,176(sp)
    800067b0:	f526                	sd	s1,168(sp)
    800067b2:	f14a                	sd	s2,160(sp)
    800067b4:	ed4e                	sd	s3,152(sp)
    800067b6:	e952                	sd	s4,144(sp)
    800067b8:	e556                	sd	s5,136(sp)
    800067ba:	e15a                	sd	s6,128(sp)
    800067bc:	0180                	addi	s0,sp,192
    800067be:	8a2a                	mv	s4,a0
    800067c0:	89ae                	mv	s3,a1
    800067c2:	8932                	mv	s2,a2
    800067c4:	84b6                	mv	s1,a3
    acquire(&g_audit.lock);
    800067c6:	00028517          	auipc	a0,0x28
    800067ca:	17250513          	addi	a0,a0,370 # 8002e938 <g_audit+0xb410>
    800067ce:	c5afa0ef          	jal	80000c28 <acquire>

    struct audit_entry *e = &g_audit.buf[g_audit.head];
    800067d2:	00028a97          	auipc	s5,0x28
    800067d6:	156aaa83          	lw	s5,342(s5) # 8002e928 <g_audit+0xb400>

    e->pid         = pid;
    800067da:	0b400713          	li	a4,180
    800067de:	02ea8733          	mul	a4,s5,a4
    800067e2:	0001d797          	auipc	a5,0x1d
    800067e6:	d4678793          	addi	a5,a5,-698 # 80023528 <g_audit>
    800067ea:	97ba                	add	a5,a5,a4
    800067ec:	0147a023          	sw	s4,0(a5)
    e->uid         = uid;
    800067f0:	0137a223          	sw	s3,4(a5)
    e->syscall_num = syscall_num;
    800067f4:	0127a423          	sw	s2,8(a5)

    // Resolve syscall name
    if (syscall_num >= 0 && syscall_num < (int)NUM_SYSCALLS &&
    800067f8:	47f5                	li	a5,29
    800067fa:	0327e963          	bltu	a5,s2,8000682c <audit_log_event+0x82>
        syscall_names[syscall_num]) {
    800067fe:	00391713          	slli	a4,s2,0x3
    80006802:	00002797          	auipc	a5,0x2
    80006806:	5be78793          	addi	a5,a5,1470 # 80008dc0 <syscall_names>
    8000680a:	97ba                	add	a5,a5,a4
    8000680c:	638c                	ld	a1,0(a5)
    if (syscall_num >= 0 && syscall_num < (int)NUM_SYSCALLS &&
    8000680e:	cd99                	beqz	a1,8000682c <audit_log_event+0x82>
        safestrcpy(e->syscall_name, syscall_names[syscall_num], 32);
    80006810:	0b400793          	li	a5,180
    80006814:	02fa87b3          	mul	a5,s5,a5
    80006818:	02000613          	li	a2,32
    8000681c:	0001d517          	auipc	a0,0x1d
    80006820:	d1850513          	addi	a0,a0,-744 # 80023534 <g_audit+0xc>
    80006824:	953e                	add	a0,a0,a5
    80006826:	e26fa0ef          	jal	80000e4c <safestrcpy>
    8000682a:	a015                	j	8000684e <audit_log_event+0xa4>
    } else {
        safestrcpy(e->syscall_name, "unknown", 32);
    8000682c:	0b400793          	li	a5,180
    80006830:	02fa87b3          	mul	a5,s5,a5
    80006834:	02000613          	li	a2,32
    80006838:	00002597          	auipc	a1,0x2
    8000683c:	2c858593          	addi	a1,a1,712 # 80008b00 <etext+0xb00>
    80006840:	0001d517          	auipc	a0,0x1d
    80006844:	cf450513          	addi	a0,a0,-780 # 80023534 <g_audit+0xc>
    80006848:	953e                	add	a0,a0,a5
    8000684a:	e02fa0ef          	jal	80000e4c <safestrcpy>
    }

    safestrcpy(e->message, message ? message : "", AUDIT_MSG_LEN);
    8000684e:	0b400b13          	li	s6,180
    80006852:	036a8b33          	mul	s6,s5,s6
    80006856:	0001d517          	auipc	a0,0x1d
    8000685a:	cfe50513          	addi	a0,a0,-770 # 80023554 <g_audit+0x2c>
    8000685e:	955a                	add	a0,a0,s6
    80006860:	00002597          	auipc	a1,0x2
    80006864:	fb058593          	addi	a1,a1,-80 # 80008810 <etext+0x810>
    80006868:	c091                	beqz	s1,8000686c <audit_log_event+0xc2>
    8000686a:	85a6                	mv	a1,s1
    8000686c:	08000613          	li	a2,128
    80006870:	ddcfa0ef          	jal	80000e4c <safestrcpy>
    e->timestamp = ticks;  // Kernel tick counter (defined in trap.c)
    80006874:	0b400793          	li	a5,180
    80006878:	02fa8ab3          	mul	s5,s5,a5
    8000687c:	0001d797          	auipc	a5,0x1d
    80006880:	cac78793          	addi	a5,a5,-852 # 80023528 <g_audit>
    80006884:	97d6                	add	a5,a5,s5
    80006886:	00002717          	auipc	a4,0x2
    8000688a:	66272703          	lw	a4,1634(a4) # 80008ee8 <ticks>
    8000688e:	0ae7a623          	sw	a4,172(a5)
    e->valid     = 1;
    80006892:	4705                	li	a4,1
    80006894:	0ae7a823          	sw	a4,176(a5)

    // Advance write pointer (wrap around — ring buffer)
    g_audit.head = (g_audit.head + 1) % AUDIT_MAX;
    80006898:	00028697          	auipc	a3,0x28
    8000689c:	c9068693          	addi	a3,a3,-880 # 8002e528 <g_audit+0xb000>
    800068a0:	4006a783          	lw	a5,1024(a3)
    800068a4:	2785                	addiw	a5,a5,1
    800068a6:	41f7d71b          	sraiw	a4,a5,0x1f
    800068aa:	0187571b          	srliw	a4,a4,0x18
    800068ae:	9fb9                	addw	a5,a5,a4
    800068b0:	0ff7f793          	zext.b	a5,a5
    800068b4:	9f99                	subw	a5,a5,a4
    800068b6:	40f6a023          	sw	a5,1024(a3)

    // If buffer is full, overwrite oldest (tail advances too)
    // WHY: We prefer losing old entries over dropping current events
    if (g_audit.count < AUDIT_MAX) {
    800068ba:	4086a783          	lw	a5,1032(a3)
    800068be:	0ff00713          	li	a4,255
    800068c2:	16f74563          	blt	a4,a5,80006a2c <audit_log_event+0x282>
        g_audit.count++;
    800068c6:	2785                	addiw	a5,a5,1
    800068c8:	00028717          	auipc	a4,0x28
    800068cc:	06f72423          	sw	a5,104(a4) # 8002e930 <g_audit+0xb408>
        // Overwrite: advance tail to discard oldest
        g_audit.tail = (g_audit.tail + 1) % AUDIT_MAX;
        printf("audit: WARNING: ring buffer full, oldest entry dropped\n");
    }

    release(&g_audit.lock);
    800068d0:	00028517          	auipc	a0,0x28
    800068d4:	06850513          	addi	a0,a0,104 # 8002e938 <g_audit+0xb410>
    800068d8:	be4fa0ef          	jal	80000cbc <release>
    
    // ALSO write to disk file (outside lock to avoid holding lock during I/O)
    audit_write_to_file(pid, uid, syscall_num, e->syscall_name, message);
    800068dc:	0001d717          	auipc	a4,0x1d
    800068e0:	c5870713          	addi	a4,a4,-936 # 80023534 <g_audit+0xc>
    800068e4:	975a                	add	a4,a4,s6
    if (pid < 10) line[off++] = '0' + pid;
    800068e6:	47a5                	li	a5,9
    800068e8:	1747ca63          	blt	a5,s4,80006a5c <audit_log_event+0x2b2>
    800068ec:	030a0a1b          	addiw	s4,s4,48
    800068f0:	f5440023          	sb	s4,-192(s0)
    800068f4:	4685                	li	a3,1
    line[off++] = '|';
    800068f6:	0016861b          	addiw	a2,a3,1
    800068fa:	07c00593          	li	a1,124
    800068fe:	fc068793          	addi	a5,a3,-64
    80006902:	97a2                	add	a5,a5,s0
    80006904:	f8b78023          	sb	a1,-128(a5)
    if (uid < 10) line[off++] = '0' + uid;
    80006908:	47a5                	li	a5,9
    8000690a:	1937c463          	blt	a5,s3,80006a92 <audit_log_event+0x2e8>
    8000690e:	00268793          	addi	a5,a3,2
    80006912:	fc060693          	addi	a3,a2,-64
    80006916:	00868633          	add	a2,a3,s0
    8000691a:	0309899b          	addiw	s3,s3,48
    8000691e:	f9360023          	sb	s3,-128(a2)
    line[off++] = '|';
    80006922:	0017861b          	addiw	a2,a5,1
    80006926:	07c00593          	li	a1,124
    8000692a:	fc078693          	addi	a3,a5,-64
    8000692e:	96a2                	add	a3,a3,s0
    80006930:	f8b68023          	sb	a1,-128(a3)
    if (syscall_num < 10) line[off++] = '0' + syscall_num;
    80006934:	46a5                	li	a3,9
    80006936:	1b26c163          	blt	a3,s2,80006ad8 <audit_log_event+0x32e>
    8000693a:	0027859b          	addiw	a1,a5,2
    8000693e:	fc060793          	addi	a5,a2,-64
    80006942:	00878633          	add	a2,a5,s0
    80006946:	0309091b          	addiw	s2,s2,48
    8000694a:	f9260023          	sb	s2,-128(a2)
    line[off++] = '|';
    8000694e:	0015851b          	addiw	a0,a1,1
    80006952:	07c00693          	li	a3,124
    80006956:	fc058793          	addi	a5,a1,-64
    8000695a:	97a2                	add	a5,a5,s0
    8000695c:	f8d78023          	sb	a3,-128(a5)
    for (int i = 0; syscall_name[i] && off < 100; i++)
    80006960:	00074603          	lbu	a2,0(a4)
    80006964:	c215                	beqz	a2,80006988 <audit_log_event+0x1de>
    80006966:	f4040693          	addi	a3,s0,-192
    8000696a:	96aa                	add	a3,a3,a0
    8000696c:	0705                	addi	a4,a4,1
        line[off++] = syscall_name[i];
    8000696e:	0015079b          	addiw	a5,a0,1
    80006972:	853e                	mv	a0,a5
    80006974:	00c68023          	sb	a2,0(a3)
    for (int i = 0; syscall_name[i] && off < 100; i++)
    80006978:	00074603          	lbu	a2,0(a4)
    8000697c:	0685                	addi	a3,a3,1
    8000697e:	0705                	addi	a4,a4,1
    80006980:	0647a793          	slti	a5,a5,100
    80006984:	c391                	beqz	a5,80006988 <audit_log_event+0x1de>
    80006986:	f665                	bnez	a2,8000696e <audit_log_event+0x1c4>
    line[off++] = '|';
    80006988:	0015091b          	addiw	s2,a0,1
    8000698c:	07c00713          	li	a4,124
    80006990:	fc050793          	addi	a5,a0,-64
    80006994:	97a2                	add	a5,a5,s0
    80006996:	f8e78023          	sb	a4,-128(a5)
    for (int i = 0; message[i] && off < 118; i++)
    8000699a:	0004c583          	lbu	a1,0(s1)
    8000699e:	c19d                	beqz	a1,800069c4 <audit_log_event+0x21a>
    800069a0:	f4040613          	addi	a2,s0,-192
    800069a4:	964a                	add	a2,a2,s2
    800069a6:	00148693          	addi	a3,s1,1
        line[off++] = message[i];
    800069aa:	0019079b          	addiw	a5,s2,1
    800069ae:	893e                	mv	s2,a5
    800069b0:	00b60023          	sb	a1,0(a2)
    for (int i = 0; message[i] && off < 118; i++)
    800069b4:	0006c583          	lbu	a1,0(a3)
    800069b8:	0605                	addi	a2,a2,1
    800069ba:	0685                	addi	a3,a3,1
    800069bc:	0767a793          	slti	a5,a5,118
    800069c0:	c391                	beqz	a5,800069c4 <audit_log_event+0x21a>
    800069c2:	f5e5                	bnez	a1,800069aa <audit_log_event+0x200>
    line[off++] = '\n';
    800069c4:	4729                	li	a4,10
    800069c6:	fc090793          	addi	a5,s2,-64
    800069ca:	97a2                	add	a5,a5,s0
    800069cc:	f8e78023          	sb	a4,-128(a5)
    struct inode *ip = namei("syscall.log");
    800069d0:	00002517          	auipc	a0,0x2
    800069d4:	17050513          	addi	a0,a0,368 # 80008b40 <etext+0xb40>
    800069d8:	9ecfd0ef          	jal	80003bc4 <namei>
    800069dc:	84aa                	mv	s1,a0
    if (!ip) return;
    800069de:	cd0d                	beqz	a0,80006a18 <audit_log_event+0x26e>
    begin_op();
    800069e0:	bc2fd0ef          	jal	80003da2 <begin_op>
    ilock(ip);
    800069e4:	8526                	mv	a0,s1
    800069e6:	98bfc0ef          	jal	80003370 <ilock>
    line[off++] = '\n';
    800069ea:	2905                	addiw	s2,s2,1
    if (writei(ip, 0, (uint64)line, ip->size, off) > 0) {
    800069ec:	874a                	mv	a4,s2
    800069ee:	44f4                	lw	a3,76(s1)
    800069f0:	f4040613          	addi	a2,s0,-192
    800069f4:	4581                	li	a1,0
    800069f6:	8526                	mv	a0,s1
    800069f8:	e23fc0ef          	jal	8000381a <writei>
    800069fc:	00a05663          	blez	a0,80006a08 <audit_log_event+0x25e>
        ip->size += off;  // Update size
    80006a00:	44fc                	lw	a5,76(s1)
    80006a02:	012787bb          	addw	a5,a5,s2
    80006a06:	c4fc                	sw	a5,76(s1)
    iunlock(ip);
    80006a08:	8526                	mv	a0,s1
    80006a0a:	a37fc0ef          	jal	80003440 <iunlock>
    end_op();
    80006a0e:	c04fd0ef          	jal	80003e12 <end_op>
    iput(ip);
    80006a12:	8526                	mv	a0,s1
    80006a14:	b01fc0ef          	jal	80003514 <iput>
}
    80006a18:	70ea                	ld	ra,184(sp)
    80006a1a:	744a                	ld	s0,176(sp)
    80006a1c:	74aa                	ld	s1,168(sp)
    80006a1e:	790a                	ld	s2,160(sp)
    80006a20:	69ea                	ld	s3,152(sp)
    80006a22:	6a4a                	ld	s4,144(sp)
    80006a24:	6aaa                	ld	s5,136(sp)
    80006a26:	6b0a                	ld	s6,128(sp)
    80006a28:	6129                	addi	sp,sp,192
    80006a2a:	8082                	ret
        g_audit.tail = (g_audit.tail + 1) % AUDIT_MAX;
    80006a2c:	00028697          	auipc	a3,0x28
    80006a30:	afc68693          	addi	a3,a3,-1284 # 8002e528 <g_audit+0xb000>
    80006a34:	4046a783          	lw	a5,1028(a3)
    80006a38:	2785                	addiw	a5,a5,1
    80006a3a:	41f7d71b          	sraiw	a4,a5,0x1f
    80006a3e:	0187571b          	srliw	a4,a4,0x18
    80006a42:	9fb9                	addw	a5,a5,a4
    80006a44:	0ff7f793          	zext.b	a5,a5
    80006a48:	9f99                	subw	a5,a5,a4
    80006a4a:	40f6a223          	sw	a5,1028(a3)
        printf("audit: WARNING: ring buffer full, oldest entry dropped\n");
    80006a4e:	00002517          	auipc	a0,0x2
    80006a52:	0ba50513          	addi	a0,a0,186 # 80008b08 <etext+0xb08>
    80006a56:	aa5f90ef          	jal	800004fa <printf>
    80006a5a:	bd9d                	j	800068d0 <audit_log_event+0x126>
        line[off++] = '0' + (pid / 10);
    80006a5c:	666667b7          	lui	a5,0x66666
    80006a60:	66778793          	addi	a5,a5,1639 # 66666667 <_entry-0x19999999>
    80006a64:	02fa07b3          	mul	a5,s4,a5
    80006a68:	9789                	srai	a5,a5,0x22
    80006a6a:	41fa569b          	sraiw	a3,s4,0x1f
    80006a6e:	9f95                	subw	a5,a5,a3
    80006a70:	0307869b          	addiw	a3,a5,48
    80006a74:	f4d40023          	sb	a3,-192(s0)
        line[off++] = '0' + (pid % 10);
    80006a78:	0027969b          	slliw	a3,a5,0x2
    80006a7c:	9fb5                	addw	a5,a5,a3
    80006a7e:	0017979b          	slliw	a5,a5,0x1
    80006a82:	40fa0a3b          	subw	s4,s4,a5
    80006a86:	030a0a1b          	addiw	s4,s4,48
    80006a8a:	f54400a3          	sb	s4,-191(s0)
    80006a8e:	4689                	li	a3,2
    80006a90:	b59d                	j	800068f6 <audit_log_event+0x14c>
        line[off++] = '0' + (uid / 10);
    80006a92:	fc060793          	addi	a5,a2,-64
    80006a96:	97a2                	add	a5,a5,s0
    80006a98:	66666637          	lui	a2,0x66666
    80006a9c:	66760613          	addi	a2,a2,1639 # 66666667 <_entry-0x19999999>
    80006aa0:	02c98633          	mul	a2,s3,a2
    80006aa4:	9609                	srai	a2,a2,0x22
    80006aa6:	41f9d59b          	sraiw	a1,s3,0x1f
    80006aaa:	9e0d                	subw	a2,a2,a1
    80006aac:	0306059b          	addiw	a1,a2,48
    80006ab0:	f8b78023          	sb	a1,-128(a5)
        line[off++] = '0' + (uid % 10);
    80006ab4:	00368793          	addi	a5,a3,3
        line[off++] = '0' + (uid / 10);
    80006ab8:	2689                	addiw	a3,a3,2
        line[off++] = '0' + (uid % 10);
    80006aba:	fc068693          	addi	a3,a3,-64
    80006abe:	96a2                	add	a3,a3,s0
    80006ac0:	0026159b          	slliw	a1,a2,0x2
    80006ac4:	9e2d                	addw	a2,a2,a1
    80006ac6:	0016161b          	slliw	a2,a2,0x1
    80006aca:	40c989bb          	subw	s3,s3,a2
    80006ace:	0309899b          	addiw	s3,s3,48
    80006ad2:	f9368023          	sb	s3,-128(a3)
    80006ad6:	b5b1                	j	80006922 <audit_log_event+0x178>
        line[off++] = '0' + (syscall_num / 10);
    80006ad8:	fc060693          	addi	a3,a2,-64
    80006adc:	00868633          	add	a2,a3,s0
    80006ae0:	666666b7          	lui	a3,0x66666
    80006ae4:	66768693          	addi	a3,a3,1639 # 66666667 <_entry-0x19999999>
    80006ae8:	02d906b3          	mul	a3,s2,a3
    80006aec:	9689                	srai	a3,a3,0x22
    80006aee:	41f9559b          	sraiw	a1,s2,0x1f
    80006af2:	9e8d                	subw	a3,a3,a1
    80006af4:	0306859b          	addiw	a1,a3,48
    80006af8:	f8b60023          	sb	a1,-128(a2)
        line[off++] = '0' + (syscall_num % 10);
    80006afc:	0037859b          	addiw	a1,a5,3
        line[off++] = '0' + (syscall_num / 10);
    80006b00:	2789                	addiw	a5,a5,2
        line[off++] = '0' + (syscall_num % 10);
    80006b02:	fc078793          	addi	a5,a5,-64
    80006b06:	97a2                	add	a5,a5,s0
    80006b08:	0026961b          	slliw	a2,a3,0x2
    80006b0c:	9eb1                	addw	a3,a3,a2
    80006b0e:	0016969b          	slliw	a3,a3,0x1
    80006b12:	40d9093b          	subw	s2,s2,a3
    80006b16:	0309091b          	addiw	s2,s2,48
    80006b1a:	f9278023          	sb	s2,-128(a5)
    80006b1e:	bd05                	j	8000694e <audit_log_event+0x1a4>

0000000080006b20 <sys_audit_read>:
// sys_audit_read — Export audit log to user space (ADMIN only)
// Returns -1 (EPERM) if caller is not uid=0
// =============================================================
uint64
sys_audit_read(void)
{
    80006b20:	711d                	addi	sp,sp,-96
    80006b22:	ec86                	sd	ra,88(sp)
    80006b24:	e8a2                	sd	s0,80(sp)
    80006b26:	fc4e                	sd	s3,56(sp)
    80006b28:	ec5e                	sd	s7,24(sp)
    80006b2a:	1080                	addi	s0,sp,96
    struct proc *p = myproc();
    80006b2c:	e0bfa0ef          	jal	80001936 <myproc>
    80006b30:	8baa                	mv	s7,a0

    // WHY hard block on non-admin: audit logs contain sensitive
    // operational data; a patient or doctor reading it could learn
    // timing patterns about the insulin pump's behavior
    if (p->creds.uid != ROLE_ADMIN) {
    80006b32:	16852983          	lw	s3,360(a0)
    80006b36:	04099f63          	bnez	s3,80006b94 <sys_audit_read+0x74>
    }

    // Arguments: user buffer pointer, max bytes to copy
    uint64 user_buf;
    int    max_bytes;
    if (argaddr(0, &user_buf) < 0 || argint(1, &max_bytes) < 0)
    80006b3a:	fa840593          	addi	a1,s0,-88
    80006b3e:	4501                	li	a0,0
    80006b40:	e3bfb0ef          	jal	8000297a <argaddr>
        return -1;
    80006b44:	57fd                	li	a5,-1
    if (argaddr(0, &user_buf) < 0 || argint(1, &max_bytes) < 0)
    80006b46:	0c054a63          	bltz	a0,80006c1a <sys_audit_read+0xfa>
    80006b4a:	fa440593          	addi	a1,s0,-92
    80006b4e:	4505                	li	a0,1
    80006b50:	e0dfb0ef          	jal	8000295c <argint>
        return -1;
    80006b54:	57fd                	li	a5,-1
    if (argaddr(0, &user_buf) < 0 || argint(1, &max_bytes) < 0)
    80006b56:	0c054263          	bltz	a0,80006c1a <sys_audit_read+0xfa>
    80006b5a:	f05a                	sd	s6,32(sp)
    // Serialize ring buffer into text format for user space
    // WHY text format: easier for user-space to display/parse;
    // binary format would require matching structs
    int  written = 0;

    acquire(&g_audit.lock);
    80006b5c:	00028517          	auipc	a0,0x28
    80006b60:	ddc50513          	addi	a0,a0,-548 # 8002e938 <g_audit+0xb410>
    80006b64:	8c4fa0ef          	jal	80000c28 <acquire>

    int idx   = g_audit.tail;
    int count = g_audit.count;
    80006b68:	00028b17          	auipc	s6,0x28
    80006b6c:	dc8b2b03          	lw	s6,-568(s6) # 8002e930 <g_audit+0xb408>

    for (int i = 0; i < count && written < max_bytes - 1; i++) {
    80006b70:	09605d63          	blez	s6,80006c0a <sys_audit_read+0xea>
    80006b74:	e4a6                	sd	s1,72(sp)
    80006b76:	e0ca                	sd	s2,64(sp)
    80006b78:	f852                	sd	s4,48(sp)
    80006b7a:	f456                	sd	s5,40(sp)
    int idx   = g_audit.tail;
    80006b7c:	00028497          	auipc	s1,0x28
    80006b80:	db04a483          	lw	s1,-592(s1) # 8002e92c <g_audit+0xb404>
    for (int i = 0; i < count && written < max_bytes - 1; i++) {
    80006b84:	894e                	mv	s2,s3
        struct audit_entry *e = &g_audit.buf[idx];
        if (e->valid) {
    80006b86:	0001da97          	auipc	s5,0x1d
    80006b8a:	9a2a8a93          	addi	s5,s5,-1630 # 80023528 <g_audit>
    80006b8e:	0b400a13          	li	s4,180
    80006b92:	a805                	j	80006bc2 <sys_audit_read+0xa2>
        audit_log_event(p->pid, p->creds.uid, SYS_audit_read,
    80006b94:	00002697          	auipc	a3,0x2
    80006b98:	fbc68693          	addi	a3,a3,-68 # 80008b50 <etext+0xb50>
    80006b9c:	4675                	li	a2,29
    80006b9e:	85ce                	mv	a1,s3
    80006ba0:	5908                	lw	a0,48(a0)
    80006ba2:	c09ff0ef          	jal	800067aa <audit_log_event>
        return -1;  // EPERM
    80006ba6:	57fd                	li	a5,-1
    80006ba8:	a88d                	j	80006c1a <sys_audit_read+0xfa>
                            (char*)e, sizeof(struct audit_entry)) < 0)
                    break;
                written += sizeof(struct audit_entry);
            }
        }
        idx = (idx + 1) % AUDIT_MAX;
    80006baa:	2485                	addiw	s1,s1,1
    80006bac:	41f4d79b          	sraiw	a5,s1,0x1f
    80006bb0:	0187d79b          	srliw	a5,a5,0x18
    80006bb4:	9cbd                	addw	s1,s1,a5
    80006bb6:	0ff4f493          	zext.b	s1,s1
    80006bba:	9c9d                	subw	s1,s1,a5
    for (int i = 0; i < count && written < max_bytes - 1; i++) {
    80006bbc:	2905                	addiw	s2,s2,1
    80006bbe:	072b0a63          	beq	s6,s2,80006c32 <sys_audit_read+0x112>
    80006bc2:	fa442703          	lw	a4,-92(s0)
    80006bc6:	fff7079b          	addiw	a5,a4,-1
    80006bca:	02f9dc63          	bge	s3,a5,80006c02 <sys_audit_read+0xe2>
        if (e->valid) {
    80006bce:	034487b3          	mul	a5,s1,s4
    80006bd2:	97d6                	add	a5,a5,s5
    80006bd4:	0b07a783          	lw	a5,176(a5)
    80006bd8:	dbe9                	beqz	a5,80006baa <sys_audit_read+0x8a>
            if (written + (int)sizeof(struct audit_entry) <= max_bytes) {
    80006bda:	0b39879b          	addiw	a5,s3,179
    80006bde:	fce7d6e3          	bge	a5,a4,80006baa <sys_audit_read+0x8a>
        struct audit_entry *e = &g_audit.buf[idx];
    80006be2:	03448633          	mul	a2,s1,s4
                if (copyout(p->pagetable, user_buf + written,
    80006be6:	86d2                	mv	a3,s4
    80006be8:	9656                	add	a2,a2,s5
    80006bea:	fa843583          	ld	a1,-88(s0)
    80006bee:	95ce                	add	a1,a1,s3
    80006bf0:	050bb503          	ld	a0,80(s7)
    80006bf4:	a69fa0ef          	jal	8000165c <copyout>
    80006bf8:	02054863          	bltz	a0,80006c28 <sys_audit_read+0x108>
                written += sizeof(struct audit_entry);
    80006bfc:	0b49899b          	addiw	s3,s3,180
    80006c00:	b76d                	j	80006baa <sys_audit_read+0x8a>
    80006c02:	64a6                	ld	s1,72(sp)
    80006c04:	6906                	ld	s2,64(sp)
    80006c06:	7a42                	ld	s4,48(sp)
    80006c08:	7aa2                	ld	s5,40(sp)
    }

    release(&g_audit.lock);
    80006c0a:	00028517          	auipc	a0,0x28
    80006c0e:	d2e50513          	addi	a0,a0,-722 # 8002e938 <g_audit+0xb410>
    80006c12:	8aafa0ef          	jal	80000cbc <release>
    return written;
    80006c16:	87ce                	mv	a5,s3
    80006c18:	7b02                	ld	s6,32(sp)
}
    80006c1a:	853e                	mv	a0,a5
    80006c1c:	60e6                	ld	ra,88(sp)
    80006c1e:	6446                	ld	s0,80(sp)
    80006c20:	79e2                	ld	s3,56(sp)
    80006c22:	6be2                	ld	s7,24(sp)
    80006c24:	6125                	addi	sp,sp,96
    80006c26:	8082                	ret
    80006c28:	64a6                	ld	s1,72(sp)
    80006c2a:	6906                	ld	s2,64(sp)
    80006c2c:	7a42                	ld	s4,48(sp)
    80006c2e:	7aa2                	ld	s5,40(sp)
    80006c30:	bfe9                	j	80006c0a <sys_audit_read+0xea>
    80006c32:	64a6                	ld	s1,72(sp)
    80006c34:	6906                	ld	s2,64(sp)
    80006c36:	7a42                	ld	s4,48(sp)
    80006c38:	7aa2                	ld	s5,40(sp)
    80006c3a:	bfc1                	j	80006c0a <sys_audit_read+0xea>
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
