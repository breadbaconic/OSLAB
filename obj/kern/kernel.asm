
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 07 01 00 00       	call   f0100145 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 14             	sub    $0x14,%esp
		monitor(NULL);
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
f0100047:	8d 5d 14             	lea    0x14(%ebp),%ebx
{
	va_list ap;

	va_start(ap, fmt);
	cprintf("kernel warning at %s:%d: ", file, line);
f010004a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010004d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100051:	8b 45 08             	mov    0x8(%ebp),%eax
f0100054:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100058:	c7 04 24 40 1d 10 f0 	movl   $0xf0101d40,(%esp)
f010005f:	e8 fb 0a 00 00       	call   f0100b5f <cprintf>
	vcprintf(fmt, ap);
f0100064:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100068:	8b 45 10             	mov    0x10(%ebp),%eax
f010006b:	89 04 24             	mov    %eax,(%esp)
f010006e:	e8 b9 0a 00 00       	call   f0100b2c <vcprintf>
	cprintf("\n");
f0100073:	c7 04 24 1a 1e 10 f0 	movl   $0xf0101e1a,(%esp)
f010007a:	e8 e0 0a 00 00       	call   f0100b5f <cprintf>
	va_end(ap);
}
f010007f:	83 c4 14             	add    $0x14,%esp
f0100082:	5b                   	pop    %ebx
f0100083:	5d                   	pop    %ebp
f0100084:	c3                   	ret    

f0100085 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100085:	55                   	push   %ebp
f0100086:	89 e5                	mov    %esp,%ebp
f0100088:	56                   	push   %esi
f0100089:	53                   	push   %ebx
f010008a:	83 ec 10             	sub    $0x10,%esp
f010008d:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100090:	83 3d 40 29 11 f0 00 	cmpl   $0x0,0xf0112940
f0100097:	75 3d                	jne    f01000d6 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f0100099:	89 35 40 29 11 f0    	mov    %esi,0xf0112940

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010009f:	fa                   	cli    
f01000a0:	fc                   	cld    
/*
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
f01000a1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");

	va_start(ap, fmt);
	cprintf("kernel panic at %s:%d: ", file, line);
f01000a4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000a7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01000ae:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000b2:	c7 04 24 5a 1d 10 f0 	movl   $0xf0101d5a,(%esp)
f01000b9:	e8 a1 0a 00 00       	call   f0100b5f <cprintf>
	vcprintf(fmt, ap);
f01000be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000c2:	89 34 24             	mov    %esi,(%esp)
f01000c5:	e8 62 0a 00 00       	call   f0100b2c <vcprintf>
	cprintf("\n");
f01000ca:	c7 04 24 1a 1e 10 f0 	movl   $0xf0101e1a,(%esp)
f01000d1:	e8 89 0a 00 00       	call   f0100b5f <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000dd:	e8 89 07 00 00       	call   f010086b <monitor>
f01000e2:	eb f2                	jmp    f01000d6 <_panic+0x51>

f01000e4 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(volatile int x)
{
f01000e4:	55                   	push   %ebp
f01000e5:	89 e5                	mov    %esp,%ebp
f01000e7:	83 ec 18             	sub    $0x18,%esp
	cprintf("entering test_backtrace %d\n", x);
f01000ea:	8b 45 08             	mov    0x8(%ebp),%eax
f01000ed:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000f1:	c7 04 24 72 1d 10 f0 	movl   $0xf0101d72,(%esp)
f01000f8:	e8 62 0a 00 00       	call   f0100b5f <cprintf>
	if (x > 0)
f01000fd:	8b 45 08             	mov    0x8(%ebp),%eax
f0100100:	85 c0                	test   %eax,%eax
f0100102:	7e 10                	jle    f0100114 <test_backtrace+0x30>
		test_backtrace(x-1);
f0100104:	8b 45 08             	mov    0x8(%ebp),%eax
f0100107:	83 e8 01             	sub    $0x1,%eax
f010010a:	89 04 24             	mov    %eax,(%esp)
f010010d:	e8 d2 ff ff ff       	call   f01000e4 <test_backtrace>
f0100112:	eb 1c                	jmp    f0100130 <test_backtrace+0x4c>
	else
		mon_backtrace(0, 0, 0);
f0100114:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010011b:	00 
f010011c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100123:	00 
f0100124:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010012b:	e8 df 08 00 00       	call   f0100a0f <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f0100130:	8b 45 08             	mov    0x8(%ebp),%eax
f0100133:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100137:	c7 04 24 8e 1d 10 f0 	movl   $0xf0101d8e,(%esp)
f010013e:	e8 1c 0a 00 00       	call   f0100b5f <cprintf>
}
f0100143:	c9                   	leave  
f0100144:	c3                   	ret    

f0100145 <i386_init>:

void
i386_init(void)
{
f0100145:	55                   	push   %ebp
f0100146:	89 e5                	mov    %esp,%ebp
f0100148:	57                   	push   %edi
f0100149:	53                   	push   %ebx
f010014a:	81 ec 20 01 00 00    	sub    $0x120,%esp
	extern char edata[], end[];
    // Lab1 only
    char chnum1 = 0, chnum2 = 0, ntest[256] = {};
f0100150:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)
f0100154:	c6 45 f6 00          	movb   $0x0,-0xa(%ebp)
f0100158:	ba 00 01 00 00       	mov    $0x100,%edx
f010015d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100162:	8d bd f6 fe ff ff    	lea    -0x10a(%ebp),%edi
f0100168:	66 ab                	stos   %ax,%es:(%edi)
f010016a:	83 ea 02             	sub    $0x2,%edx
f010016d:	89 d1                	mov    %edx,%ecx
f010016f:	c1 e9 02             	shr    $0x2,%ecx
f0100172:	f3 ab                	rep stos %eax,%es:(%edi)
f0100174:	f6 c2 02             	test   $0x2,%dl
f0100177:	74 02                	je     f010017b <i386_init+0x36>
f0100179:	66 ab                	stos   %ax,%es:(%edi)
f010017b:	83 e2 01             	and    $0x1,%edx
f010017e:	85 d2                	test   %edx,%edx
f0100180:	74 01                	je     f0100183 <i386_init+0x3e>
f0100182:	aa                   	stos   %al,%es:(%edi)

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100183:	b8 5c 29 11 f0       	mov    $0xf011295c,%eax
f0100188:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f010018d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100191:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100198:	00 
f0100199:	c7 04 24 00 23 11 f0 	movl   $0xf0112300,(%esp)
f01001a0:	e8 b1 16 00 00       	call   f0101856 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01001a5:	e8 c0 03 00 00       	call   f010056a <cons_init>

	cprintf("6828 decimal is %o octal!%n\n%n", 6828, &chnum1, &chnum2);
f01001aa:	8d 45 f6             	lea    -0xa(%ebp),%eax
f01001ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01001b1:	8d 7d f7             	lea    -0x9(%ebp),%edi
f01001b4:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01001b8:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01001bf:	00 
f01001c0:	c7 04 24 d4 1d 10 f0 	movl   $0xf0101dd4,(%esp)
f01001c7:	e8 93 09 00 00       	call   f0100b5f <cprintf>
	
    cprintf("chnum1: %d chnum2: %d\n", chnum1, chnum2);
f01001cc:	0f be 45 f6          	movsbl -0xa(%ebp),%eax
f01001d0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001d4:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
f01001d8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01001dc:	c7 04 24 a9 1d 10 f0 	movl   $0xf0101da9,(%esp)
f01001e3:	e8 77 09 00 00       	call   f0100b5f <cprintf>
    cprintf("%n", NULL);
f01001e8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01001ef:	00 
f01001f0:	c7 04 24 c2 1d 10 f0 	movl   $0xf0101dc2,(%esp)
f01001f7:	e8 63 09 00 00       	call   f0100b5f <cprintf>
    memset(ntest, 0xd, sizeof(ntest) - 1);
f01001fc:	c7 44 24 08 ff 00 00 	movl   $0xff,0x8(%esp)
f0100203:	00 
f0100204:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
f010020b:	00 
f010020c:	8d 9d f6 fe ff ff    	lea    -0x10a(%ebp),%ebx
f0100212:	89 1c 24             	mov    %ebx,(%esp)
f0100215:	e8 3c 16 00 00       	call   f0101856 <memset>
    cprintf("%s%n", ntest, &chnum1); 
f010021a:	89 7c 24 08          	mov    %edi,0x8(%esp)
f010021e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100222:	c7 04 24 c0 1d 10 f0 	movl   $0xf0101dc0,(%esp)
f0100229:	e8 31 09 00 00       	call   f0100b5f <cprintf>
    cprintf("chnum1: %d\n", chnum1);
f010022e:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
f0100232:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100236:	c7 04 24 c5 1d 10 f0 	movl   $0xf0101dc5,(%esp)
f010023d:	e8 1d 09 00 00       	call   f0100b5f <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f0100242:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f0100249:	e8 96 fe ff ff       	call   f01000e4 <test_backtrace>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010024e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100255:	e8 11 06 00 00       	call   f010086b <monitor>
f010025a:	eb f2                	jmp    f010024e <i386_init+0x109>
f010025c:	00 00                	add    %al,(%eax)
	...

f0100260 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100260:	55                   	push   %ebp
f0100261:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100263:	ba 84 00 00 00       	mov    $0x84,%edx
f0100268:	ec                   	in     (%dx),%al
f0100269:	ec                   	in     (%dx),%al
f010026a:	ec                   	in     (%dx),%al
f010026b:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f010026c:	5d                   	pop    %ebp
f010026d:	c3                   	ret    

f010026e <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010026e:	55                   	push   %ebp
f010026f:	89 e5                	mov    %esp,%ebp
f0100271:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100276:	ec                   	in     (%dx),%al
f0100277:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100279:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010027e:	f6 c2 01             	test   $0x1,%dl
f0100281:	74 09                	je     f010028c <serial_proc_data+0x1e>
f0100283:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100288:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100289:	0f b6 c0             	movzbl %al,%eax
}
f010028c:	5d                   	pop    %ebp
f010028d:	c3                   	ret    

f010028e <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010028e:	55                   	push   %ebp
f010028f:	89 e5                	mov    %esp,%ebp
f0100291:	57                   	push   %edi
f0100292:	56                   	push   %esi
f0100293:	53                   	push   %ebx
f0100294:	83 ec 0c             	sub    $0xc,%esp
f0100297:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100299:	bb 24 25 11 f0       	mov    $0xf0112524,%ebx
f010029e:	bf 20 23 11 f0       	mov    $0xf0112320,%edi
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002a3:	eb 1e                	jmp    f01002c3 <cons_intr+0x35>
		if (c == 0)
f01002a5:	85 c0                	test   %eax,%eax
f01002a7:	74 1a                	je     f01002c3 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f01002a9:	8b 13                	mov    (%ebx),%edx
f01002ab:	88 04 17             	mov    %al,(%edi,%edx,1)
f01002ae:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f01002b1:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f01002b6:	0f 94 c2             	sete   %dl
f01002b9:	0f b6 d2             	movzbl %dl,%edx
f01002bc:	83 ea 01             	sub    $0x1,%edx
f01002bf:	21 d0                	and    %edx,%eax
f01002c1:	89 03                	mov    %eax,(%ebx)
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002c3:	ff d6                	call   *%esi
f01002c5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002c8:	75 db                	jne    f01002a5 <cons_intr+0x17>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002ca:	83 c4 0c             	add    $0xc,%esp
f01002cd:	5b                   	pop    %ebx
f01002ce:	5e                   	pop    %esi
f01002cf:	5f                   	pop    %edi
f01002d0:	5d                   	pop    %ebp
f01002d1:	c3                   	ret    

f01002d2 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01002d2:	55                   	push   %ebp
f01002d3:	89 e5                	mov    %esp,%ebp
f01002d5:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01002d8:	b8 5a 06 10 f0       	mov    $0xf010065a,%eax
f01002dd:	e8 ac ff ff ff       	call   f010028e <cons_intr>
}
f01002e2:	c9                   	leave  
f01002e3:	c3                   	ret    

f01002e4 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01002e4:	55                   	push   %ebp
f01002e5:	89 e5                	mov    %esp,%ebp
f01002e7:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f01002ea:	80 3d 04 23 11 f0 00 	cmpb   $0x0,0xf0112304
f01002f1:	74 0a                	je     f01002fd <serial_intr+0x19>
		cons_intr(serial_proc_data);
f01002f3:	b8 6e 02 10 f0       	mov    $0xf010026e,%eax
f01002f8:	e8 91 ff ff ff       	call   f010028e <cons_intr>
}
f01002fd:	c9                   	leave  
f01002fe:	c3                   	ret    

f01002ff <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01002ff:	55                   	push   %ebp
f0100300:	89 e5                	mov    %esp,%ebp
f0100302:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100305:	e8 da ff ff ff       	call   f01002e4 <serial_intr>
	kbd_intr();
f010030a:	e8 c3 ff ff ff       	call   f01002d2 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010030f:	8b 15 20 25 11 f0    	mov    0xf0112520,%edx
f0100315:	b8 00 00 00 00       	mov    $0x0,%eax
f010031a:	3b 15 24 25 11 f0    	cmp    0xf0112524,%edx
f0100320:	74 21                	je     f0100343 <cons_getc+0x44>
		c = cons.buf[cons.rpos++];
f0100322:	0f b6 82 20 23 11 f0 	movzbl -0xfeedce0(%edx),%eax
f0100329:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f010032c:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f0100332:	0f 94 c1             	sete   %cl
f0100335:	0f b6 c9             	movzbl %cl,%ecx
f0100338:	83 e9 01             	sub    $0x1,%ecx
f010033b:	21 ca                	and    %ecx,%edx
f010033d:	89 15 20 25 11 f0    	mov    %edx,0xf0112520
		return c;
	}
	return 0;
}
f0100343:	c9                   	leave  
f0100344:	c3                   	ret    

f0100345 <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f0100345:	55                   	push   %ebp
f0100346:	89 e5                	mov    %esp,%ebp
f0100348:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010034b:	e8 af ff ff ff       	call   f01002ff <cons_getc>
f0100350:	85 c0                	test   %eax,%eax
f0100352:	74 f7                	je     f010034b <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100354:	c9                   	leave  
f0100355:	c3                   	ret    

f0100356 <iscons>:

int
iscons(int fdnum)
{
f0100356:	55                   	push   %ebp
f0100357:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100359:	b8 01 00 00 00       	mov    $0x1,%eax
f010035e:	5d                   	pop    %ebp
f010035f:	c3                   	ret    

f0100360 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100360:	55                   	push   %ebp
f0100361:	89 e5                	mov    %esp,%ebp
f0100363:	57                   	push   %edi
f0100364:	56                   	push   %esi
f0100365:	53                   	push   %ebx
f0100366:	83 ec 2c             	sub    $0x2c,%esp
f0100369:	89 c7                	mov    %eax,%edi
f010036b:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100370:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100371:	a8 20                	test   $0x20,%al
f0100373:	75 21                	jne    f0100396 <cons_putc+0x36>
f0100375:	bb 00 00 00 00       	mov    $0x0,%ebx
f010037a:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f010037f:	e8 dc fe ff ff       	call   f0100260 <delay>
f0100384:	89 f2                	mov    %esi,%edx
f0100386:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100387:	a8 20                	test   $0x20,%al
f0100389:	75 0b                	jne    f0100396 <cons_putc+0x36>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f010038b:	83 c3 01             	add    $0x1,%ebx
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010038e:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f0100394:	75 e9                	jne    f010037f <cons_putc+0x1f>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100396:	89 fa                	mov    %edi,%edx
f0100398:	89 f8                	mov    %edi,%eax
f010039a:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010039d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003a2:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003a3:	b2 79                	mov    $0x79,%dl
f01003a5:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003a6:	84 c0                	test   %al,%al
f01003a8:	78 21                	js     f01003cb <cons_putc+0x6b>
f01003aa:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003af:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f01003b4:	e8 a7 fe ff ff       	call   f0100260 <delay>
f01003b9:	89 f2                	mov    %esi,%edx
f01003bb:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003bc:	84 c0                	test   %al,%al
f01003be:	78 0b                	js     f01003cb <cons_putc+0x6b>
f01003c0:	83 c3 01             	add    $0x1,%ebx
f01003c3:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f01003c9:	75 e9                	jne    f01003b4 <cons_putc+0x54>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003cb:	ba 78 03 00 00       	mov    $0x378,%edx
f01003d0:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01003d4:	ee                   	out    %al,(%dx)
f01003d5:	b2 7a                	mov    $0x7a,%dl
f01003d7:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003dc:	ee                   	out    %al,(%dx)
f01003dd:	b8 08 00 00 00       	mov    $0x8,%eax
f01003e2:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01003e3:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f01003e9:	75 06                	jne    f01003f1 <cons_putc+0x91>
		c |= 0x0700;
f01003eb:	81 cf 00 07 00 00    	or     $0x700,%edi

	switch (c & 0xff) {
f01003f1:	89 f8                	mov    %edi,%eax
f01003f3:	25 ff 00 00 00       	and    $0xff,%eax
f01003f8:	83 f8 09             	cmp    $0x9,%eax
f01003fb:	0f 84 83 00 00 00    	je     f0100484 <cons_putc+0x124>
f0100401:	83 f8 09             	cmp    $0x9,%eax
f0100404:	7f 0c                	jg     f0100412 <cons_putc+0xb2>
f0100406:	83 f8 08             	cmp    $0x8,%eax
f0100409:	0f 85 a9 00 00 00    	jne    f01004b8 <cons_putc+0x158>
f010040f:	90                   	nop
f0100410:	eb 18                	jmp    f010042a <cons_putc+0xca>
f0100412:	83 f8 0a             	cmp    $0xa,%eax
f0100415:	8d 76 00             	lea    0x0(%esi),%esi
f0100418:	74 40                	je     f010045a <cons_putc+0xfa>
f010041a:	83 f8 0d             	cmp    $0xd,%eax
f010041d:	8d 76 00             	lea    0x0(%esi),%esi
f0100420:	0f 85 92 00 00 00    	jne    f01004b8 <cons_putc+0x158>
f0100426:	66 90                	xchg   %ax,%ax
f0100428:	eb 38                	jmp    f0100462 <cons_putc+0x102>
	case '\b':
		if (crt_pos > 0) {
f010042a:	0f b7 05 10 23 11 f0 	movzwl 0xf0112310,%eax
f0100431:	66 85 c0             	test   %ax,%ax
f0100434:	0f 84 e8 00 00 00    	je     f0100522 <cons_putc+0x1c2>
			crt_pos--;
f010043a:	83 e8 01             	sub    $0x1,%eax
f010043d:	66 a3 10 23 11 f0    	mov    %ax,0xf0112310
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100443:	0f b7 c0             	movzwl %ax,%eax
f0100446:	66 81 e7 00 ff       	and    $0xff00,%di
f010044b:	83 cf 20             	or     $0x20,%edi
f010044e:	8b 15 0c 23 11 f0    	mov    0xf011230c,%edx
f0100454:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100458:	eb 7b                	jmp    f01004d5 <cons_putc+0x175>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010045a:	66 83 05 10 23 11 f0 	addw   $0x50,0xf0112310
f0100461:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100462:	0f b7 05 10 23 11 f0 	movzwl 0xf0112310,%eax
f0100469:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010046f:	c1 e8 10             	shr    $0x10,%eax
f0100472:	66 c1 e8 06          	shr    $0x6,%ax
f0100476:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100479:	c1 e0 04             	shl    $0x4,%eax
f010047c:	66 a3 10 23 11 f0    	mov    %ax,0xf0112310
f0100482:	eb 51                	jmp    f01004d5 <cons_putc+0x175>
		break;
	case '\t':
		cons_putc(' ');
f0100484:	b8 20 00 00 00       	mov    $0x20,%eax
f0100489:	e8 d2 fe ff ff       	call   f0100360 <cons_putc>
		cons_putc(' ');
f010048e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100493:	e8 c8 fe ff ff       	call   f0100360 <cons_putc>
		cons_putc(' ');
f0100498:	b8 20 00 00 00       	mov    $0x20,%eax
f010049d:	e8 be fe ff ff       	call   f0100360 <cons_putc>
		cons_putc(' ');
f01004a2:	b8 20 00 00 00       	mov    $0x20,%eax
f01004a7:	e8 b4 fe ff ff       	call   f0100360 <cons_putc>
		cons_putc(' ');
f01004ac:	b8 20 00 00 00       	mov    $0x20,%eax
f01004b1:	e8 aa fe ff ff       	call   f0100360 <cons_putc>
f01004b6:	eb 1d                	jmp    f01004d5 <cons_putc+0x175>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01004b8:	0f b7 05 10 23 11 f0 	movzwl 0xf0112310,%eax
f01004bf:	0f b7 c8             	movzwl %ax,%ecx
f01004c2:	8b 15 0c 23 11 f0    	mov    0xf011230c,%edx
f01004c8:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f01004cc:	83 c0 01             	add    $0x1,%eax
f01004cf:	66 a3 10 23 11 f0    	mov    %ax,0xf0112310
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01004d5:	66 81 3d 10 23 11 f0 	cmpw   $0x7cf,0xf0112310
f01004dc:	cf 07 
f01004de:	76 42                	jbe    f0100522 <cons_putc+0x1c2>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004e0:	a1 0c 23 11 f0       	mov    0xf011230c,%eax
f01004e5:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01004ec:	00 
f01004ed:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004f3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01004f7:	89 04 24             	mov    %eax,(%esp)
f01004fa:	e8 b6 13 00 00       	call   f01018b5 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01004ff:	8b 15 0c 23 11 f0    	mov    0xf011230c,%edx
f0100505:	b8 80 07 00 00       	mov    $0x780,%eax
f010050a:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100510:	83 c0 01             	add    $0x1,%eax
f0100513:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100518:	75 f0                	jne    f010050a <cons_putc+0x1aa>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010051a:	66 83 2d 10 23 11 f0 	subw   $0x50,0xf0112310
f0100521:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100522:	8b 0d 08 23 11 f0    	mov    0xf0112308,%ecx
f0100528:	89 cb                	mov    %ecx,%ebx
f010052a:	b8 0e 00 00 00       	mov    $0xe,%eax
f010052f:	89 ca                	mov    %ecx,%edx
f0100531:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100532:	0f b7 35 10 23 11 f0 	movzwl 0xf0112310,%esi
f0100539:	83 c1 01             	add    $0x1,%ecx
f010053c:	89 f0                	mov    %esi,%eax
f010053e:	66 c1 e8 08          	shr    $0x8,%ax
f0100542:	89 ca                	mov    %ecx,%edx
f0100544:	ee                   	out    %al,(%dx)
f0100545:	b8 0f 00 00 00       	mov    $0xf,%eax
f010054a:	89 da                	mov    %ebx,%edx
f010054c:	ee                   	out    %al,(%dx)
f010054d:	89 f0                	mov    %esi,%eax
f010054f:	89 ca                	mov    %ecx,%edx
f0100551:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100552:	83 c4 2c             	add    $0x2c,%esp
f0100555:	5b                   	pop    %ebx
f0100556:	5e                   	pop    %esi
f0100557:	5f                   	pop    %edi
f0100558:	5d                   	pop    %ebp
f0100559:	c3                   	ret    

f010055a <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010055a:	55                   	push   %ebp
f010055b:	89 e5                	mov    %esp,%ebp
f010055d:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100560:	8b 45 08             	mov    0x8(%ebp),%eax
f0100563:	e8 f8 fd ff ff       	call   f0100360 <cons_putc>
}
f0100568:	c9                   	leave  
f0100569:	c3                   	ret    

f010056a <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010056a:	55                   	push   %ebp
f010056b:	89 e5                	mov    %esp,%ebp
f010056d:	57                   	push   %edi
f010056e:	56                   	push   %esi
f010056f:	53                   	push   %ebx
f0100570:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100573:	b8 00 80 0b f0       	mov    $0xf00b8000,%eax
f0100578:	0f b7 10             	movzwl (%eax),%edx
	*cp = (uint16_t) 0xA55A;
f010057b:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f0100580:	0f b7 00             	movzwl (%eax),%eax
f0100583:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100587:	74 11                	je     f010059a <cons_init+0x30>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100589:	c7 05 08 23 11 f0 b4 	movl   $0x3b4,0xf0112308
f0100590:	03 00 00 
f0100593:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100598:	eb 16                	jmp    f01005b0 <cons_init+0x46>
	} else {
		*cp = was;
f010059a:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01005a1:	c7 05 08 23 11 f0 d4 	movl   $0x3d4,0xf0112308
f01005a8:	03 00 00 
f01005ab:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01005b0:	8b 0d 08 23 11 f0    	mov    0xf0112308,%ecx
f01005b6:	89 cb                	mov    %ecx,%ebx
f01005b8:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005bd:	89 ca                	mov    %ecx,%edx
f01005bf:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005c0:	83 c1 01             	add    $0x1,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005c3:	89 ca                	mov    %ecx,%edx
f01005c5:	ec                   	in     (%dx),%al
f01005c6:	0f b6 f8             	movzbl %al,%edi
f01005c9:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005cc:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005d1:	89 da                	mov    %ebx,%edx
f01005d3:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005d4:	89 ca                	mov    %ecx,%edx
f01005d6:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005d7:	89 35 0c 23 11 f0    	mov    %esi,0xf011230c
	crt_pos = pos;
f01005dd:	0f b6 c8             	movzbl %al,%ecx
f01005e0:	09 cf                	or     %ecx,%edi
f01005e2:	66 89 3d 10 23 11 f0 	mov    %di,0xf0112310
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005e9:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01005ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01005f3:	89 da                	mov    %ebx,%edx
f01005f5:	ee                   	out    %al,(%dx)
f01005f6:	b2 fb                	mov    $0xfb,%dl
f01005f8:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005fd:	ee                   	out    %al,(%dx)
f01005fe:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100603:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100608:	89 ca                	mov    %ecx,%edx
f010060a:	ee                   	out    %al,(%dx)
f010060b:	b2 f9                	mov    $0xf9,%dl
f010060d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100612:	ee                   	out    %al,(%dx)
f0100613:	b2 fb                	mov    $0xfb,%dl
f0100615:	b8 03 00 00 00       	mov    $0x3,%eax
f010061a:	ee                   	out    %al,(%dx)
f010061b:	b2 fc                	mov    $0xfc,%dl
f010061d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100622:	ee                   	out    %al,(%dx)
f0100623:	b2 f9                	mov    $0xf9,%dl
f0100625:	b8 01 00 00 00       	mov    $0x1,%eax
f010062a:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010062b:	b2 fd                	mov    $0xfd,%dl
f010062d:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010062e:	3c ff                	cmp    $0xff,%al
f0100630:	0f 95 c0             	setne  %al
f0100633:	89 c6                	mov    %eax,%esi
f0100635:	a2 04 23 11 f0       	mov    %al,0xf0112304
f010063a:	89 da                	mov    %ebx,%edx
f010063c:	ec                   	in     (%dx),%al
f010063d:	89 ca                	mov    %ecx,%edx
f010063f:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100640:	89 f0                	mov    %esi,%eax
f0100642:	84 c0                	test   %al,%al
f0100644:	75 0c                	jne    f0100652 <cons_init+0xe8>
		cprintf("Serial port does not exist!\n");
f0100646:	c7 04 24 f3 1d 10 f0 	movl   $0xf0101df3,(%esp)
f010064d:	e8 0d 05 00 00       	call   f0100b5f <cprintf>
}
f0100652:	83 c4 1c             	add    $0x1c,%esp
f0100655:	5b                   	pop    %ebx
f0100656:	5e                   	pop    %esi
f0100657:	5f                   	pop    %edi
f0100658:	5d                   	pop    %ebp
f0100659:	c3                   	ret    

f010065a <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010065a:	55                   	push   %ebp
f010065b:	89 e5                	mov    %esp,%ebp
f010065d:	53                   	push   %ebx
f010065e:	83 ec 14             	sub    $0x14,%esp
f0100661:	ba 64 00 00 00       	mov    $0x64,%edx
f0100666:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100667:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010066c:	a8 01                	test   $0x1,%al
f010066e:	0f 84 d9 00 00 00    	je     f010074d <kbd_proc_data+0xf3>
f0100674:	b2 60                	mov    $0x60,%dl
f0100676:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100677:	3c e0                	cmp    $0xe0,%al
f0100679:	75 11                	jne    f010068c <kbd_proc_data+0x32>
		// E0 escape character
		shift |= E0ESC;
f010067b:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
f0100682:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f0100687:	e9 c1 00 00 00       	jmp    f010074d <kbd_proc_data+0xf3>
	} else if (data & 0x80) {
f010068c:	84 c0                	test   %al,%al
f010068e:	79 32                	jns    f01006c2 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100690:	8b 15 00 23 11 f0    	mov    0xf0112300,%edx
f0100696:	f6 c2 40             	test   $0x40,%dl
f0100699:	75 03                	jne    f010069e <kbd_proc_data+0x44>
f010069b:	83 e0 7f             	and    $0x7f,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f010069e:	0f b6 c0             	movzbl %al,%eax
f01006a1:	0f b6 80 20 1e 10 f0 	movzbl -0xfefe1e0(%eax),%eax
f01006a8:	83 c8 40             	or     $0x40,%eax
f01006ab:	0f b6 c0             	movzbl %al,%eax
f01006ae:	f7 d0                	not    %eax
f01006b0:	21 c2                	and    %eax,%edx
f01006b2:	89 15 00 23 11 f0    	mov    %edx,0xf0112300
f01006b8:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f01006bd:	e9 8b 00 00 00       	jmp    f010074d <kbd_proc_data+0xf3>
	} else if (shift & E0ESC) {
f01006c2:	8b 15 00 23 11 f0    	mov    0xf0112300,%edx
f01006c8:	f6 c2 40             	test   $0x40,%dl
f01006cb:	74 0c                	je     f01006d9 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01006cd:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f01006d0:	83 e2 bf             	and    $0xffffffbf,%edx
f01006d3:	89 15 00 23 11 f0    	mov    %edx,0xf0112300
	}

	shift |= shiftcode[data];
f01006d9:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f01006dc:	0f b6 90 20 1e 10 f0 	movzbl -0xfefe1e0(%eax),%edx
f01006e3:	0b 15 00 23 11 f0    	or     0xf0112300,%edx
f01006e9:	0f b6 88 20 1f 10 f0 	movzbl -0xfefe0e0(%eax),%ecx
f01006f0:	31 ca                	xor    %ecx,%edx
f01006f2:	89 15 00 23 11 f0    	mov    %edx,0xf0112300

	c = charcode[shift & (CTL | SHIFT)][data];
f01006f8:	89 d1                	mov    %edx,%ecx
f01006fa:	83 e1 03             	and    $0x3,%ecx
f01006fd:	8b 0c 8d 20 20 10 f0 	mov    -0xfefdfe0(,%ecx,4),%ecx
f0100704:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
	if (shift & CAPSLOCK) {
f0100708:	f6 c2 08             	test   $0x8,%dl
f010070b:	74 1a                	je     f0100727 <kbd_proc_data+0xcd>
		if ('a' <= c && c <= 'z')
f010070d:	89 d9                	mov    %ebx,%ecx
f010070f:	8d 43 9f             	lea    -0x61(%ebx),%eax
f0100712:	83 f8 19             	cmp    $0x19,%eax
f0100715:	77 05                	ja     f010071c <kbd_proc_data+0xc2>
			c += 'A' - 'a';
f0100717:	83 eb 20             	sub    $0x20,%ebx
f010071a:	eb 0b                	jmp    f0100727 <kbd_proc_data+0xcd>
		else if ('A' <= c && c <= 'Z')
f010071c:	83 e9 41             	sub    $0x41,%ecx
f010071f:	83 f9 19             	cmp    $0x19,%ecx
f0100722:	77 03                	ja     f0100727 <kbd_proc_data+0xcd>
			c += 'a' - 'A';
f0100724:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100727:	f7 d2                	not    %edx
f0100729:	f6 c2 06             	test   $0x6,%dl
f010072c:	75 1f                	jne    f010074d <kbd_proc_data+0xf3>
f010072e:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100734:	75 17                	jne    f010074d <kbd_proc_data+0xf3>
		cprintf("Rebooting!\n");
f0100736:	c7 04 24 10 1e 10 f0 	movl   $0xf0101e10,(%esp)
f010073d:	e8 1d 04 00 00       	call   f0100b5f <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100742:	ba 92 00 00 00       	mov    $0x92,%edx
f0100747:	b8 03 00 00 00       	mov    $0x3,%eax
f010074c:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010074d:	89 d8                	mov    %ebx,%eax
f010074f:	83 c4 14             	add    $0x14,%esp
f0100752:	5b                   	pop    %ebx
f0100753:	5d                   	pop    %ebp
f0100754:	c3                   	ret    
	...

f0100760 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f0100760:	55                   	push   %ebp
f0100761:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f0100763:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f0100766:	5d                   	pop    %ebp
f0100767:	c3                   	ret    

f0100768 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100768:	55                   	push   %ebp
f0100769:	89 e5                	mov    %esp,%ebp
f010076b:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010076e:	c7 04 24 30 20 10 f0 	movl   $0xf0102030,(%esp)
f0100775:	e8 e5 03 00 00       	call   f0100b5f <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010077a:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100781:	00 
f0100782:	c7 04 24 ec 20 10 f0 	movl   $0xf01020ec,(%esp)
f0100789:	e8 d1 03 00 00       	call   f0100b5f <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010078e:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100795:	00 
f0100796:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f010079d:	f0 
f010079e:	c7 04 24 14 21 10 f0 	movl   $0xf0102114,(%esp)
f01007a5:	e8 b5 03 00 00       	call   f0100b5f <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007aa:	c7 44 24 08 25 1d 10 	movl   $0x101d25,0x8(%esp)
f01007b1:	00 
f01007b2:	c7 44 24 04 25 1d 10 	movl   $0xf0101d25,0x4(%esp)
f01007b9:	f0 
f01007ba:	c7 04 24 38 21 10 f0 	movl   $0xf0102138,(%esp)
f01007c1:	e8 99 03 00 00       	call   f0100b5f <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007c6:	c7 44 24 08 00 23 11 	movl   $0x112300,0x8(%esp)
f01007cd:	00 
f01007ce:	c7 44 24 04 00 23 11 	movl   $0xf0112300,0x4(%esp)
f01007d5:	f0 
f01007d6:	c7 04 24 5c 21 10 f0 	movl   $0xf010215c,(%esp)
f01007dd:	e8 7d 03 00 00       	call   f0100b5f <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01007e2:	c7 44 24 08 5c 29 11 	movl   $0x11295c,0x8(%esp)
f01007e9:	00 
f01007ea:	c7 44 24 04 5c 29 11 	movl   $0xf011295c,0x4(%esp)
f01007f1:	f0 
f01007f2:	c7 04 24 80 21 10 f0 	movl   $0xf0102180,(%esp)
f01007f9:	e8 61 03 00 00       	call   f0100b5f <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01007fe:	b8 5b 2d 11 f0       	mov    $0xf0112d5b,%eax
f0100803:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100808:	c1 f8 0a             	sar    $0xa,%eax
f010080b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010080f:	c7 04 24 a4 21 10 f0 	movl   $0xf01021a4,(%esp)
f0100816:	e8 44 03 00 00       	call   f0100b5f <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010081b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100820:	c9                   	leave  
f0100821:	c3                   	ret    

f0100822 <mon_help>:
void corruptStack(unsigned int value, char * point);
/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100822:	55                   	push   %ebp
f0100823:	89 e5                	mov    %esp,%ebp
f0100825:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100828:	a1 48 22 10 f0       	mov    0xf0102248,%eax
f010082d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100831:	a1 44 22 10 f0       	mov    0xf0102244,%eax
f0100836:	89 44 24 04          	mov    %eax,0x4(%esp)
f010083a:	c7 04 24 49 20 10 f0 	movl   $0xf0102049,(%esp)
f0100841:	e8 19 03 00 00       	call   f0100b5f <cprintf>
f0100846:	a1 54 22 10 f0       	mov    0xf0102254,%eax
f010084b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010084f:	a1 50 22 10 f0       	mov    0xf0102250,%eax
f0100854:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100858:	c7 04 24 49 20 10 f0 	movl   $0xf0102049,(%esp)
f010085f:	e8 fb 02 00 00       	call   f0100b5f <cprintf>
	return 0;
}
f0100864:	b8 00 00 00 00       	mov    $0x0,%eax
f0100869:	c9                   	leave  
f010086a:	c3                   	ret    

f010086b <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010086b:	55                   	push   %ebp
f010086c:	89 e5                	mov    %esp,%ebp
f010086e:	57                   	push   %edi
f010086f:	56                   	push   %esi
f0100870:	53                   	push   %ebx
f0100871:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100874:	c7 04 24 d0 21 10 f0 	movl   $0xf01021d0,(%esp)
f010087b:	e8 df 02 00 00       	call   f0100b5f <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100880:	c7 04 24 f4 21 10 f0 	movl   $0xf01021f4,(%esp)
f0100887:	e8 d3 02 00 00       	call   f0100b5f <cprintf>

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010088c:	bf 44 22 10 f0       	mov    $0xf0102244,%edi
	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");


	while (1) {
		buf = readline("K> ");
f0100891:	c7 04 24 52 20 10 f0 	movl   $0xf0102052,(%esp)
f0100898:	e8 03 0d 00 00       	call   f01015a0 <readline>
f010089d:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010089f:	85 c0                	test   %eax,%eax
f01008a1:	74 ee                	je     f0100891 <monitor+0x26>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01008a3:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
f01008aa:	be 00 00 00 00       	mov    $0x0,%esi
f01008af:	eb 06                	jmp    f01008b7 <monitor+0x4c>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01008b1:	c6 03 00             	movb   $0x0,(%ebx)
f01008b4:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01008b7:	0f b6 03             	movzbl (%ebx),%eax
f01008ba:	84 c0                	test   %al,%al
f01008bc:	74 6d                	je     f010092b <monitor+0xc0>
f01008be:	0f be c0             	movsbl %al,%eax
f01008c1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008c5:	c7 04 24 56 20 10 f0 	movl   $0xf0102056,(%esp)
f01008cc:	e8 2a 0f 00 00       	call   f01017fb <strchr>
f01008d1:	85 c0                	test   %eax,%eax
f01008d3:	75 dc                	jne    f01008b1 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f01008d5:	80 3b 00             	cmpb   $0x0,(%ebx)
f01008d8:	74 51                	je     f010092b <monitor+0xc0>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01008da:	83 fe 0f             	cmp    $0xf,%esi
f01008dd:	8d 76 00             	lea    0x0(%esi),%esi
f01008e0:	75 16                	jne    f01008f8 <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008e2:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f01008e9:	00 
f01008ea:	c7 04 24 5b 20 10 f0 	movl   $0xf010205b,(%esp)
f01008f1:	e8 69 02 00 00       	call   f0100b5f <cprintf>
f01008f6:	eb 99                	jmp    f0100891 <monitor+0x26>
			return 0;
		}
		argv[argc++] = buf;
f01008f8:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01008fc:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01008ff:	0f b6 03             	movzbl (%ebx),%eax
f0100902:	84 c0                	test   %al,%al
f0100904:	75 0c                	jne    f0100912 <monitor+0xa7>
f0100906:	eb af                	jmp    f01008b7 <monitor+0x4c>
			buf++;
f0100908:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010090b:	0f b6 03             	movzbl (%ebx),%eax
f010090e:	84 c0                	test   %al,%al
f0100910:	74 a5                	je     f01008b7 <monitor+0x4c>
f0100912:	0f be c0             	movsbl %al,%eax
f0100915:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100919:	c7 04 24 56 20 10 f0 	movl   $0xf0102056,(%esp)
f0100920:	e8 d6 0e 00 00       	call   f01017fb <strchr>
f0100925:	85 c0                	test   %eax,%eax
f0100927:	74 df                	je     f0100908 <monitor+0x9d>
f0100929:	eb 8c                	jmp    f01008b7 <monitor+0x4c>
			buf++;
	}
	argv[argc] = 0;
f010092b:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100932:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100933:	85 f6                	test   %esi,%esi
f0100935:	0f 84 56 ff ff ff    	je     f0100891 <monitor+0x26>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010093b:	8b 07                	mov    (%edi),%eax
f010093d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100941:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100944:	89 04 24             	mov    %eax,(%esp)
f0100947:	e8 39 0e 00 00       	call   f0101785 <strcmp>
f010094c:	ba 00 00 00 00       	mov    $0x0,%edx
f0100951:	85 c0                	test   %eax,%eax
f0100953:	74 1d                	je     f0100972 <monitor+0x107>
f0100955:	a1 50 22 10 f0       	mov    0xf0102250,%eax
f010095a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010095e:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100961:	89 04 24             	mov    %eax,(%esp)
f0100964:	e8 1c 0e 00 00       	call   f0101785 <strcmp>
f0100969:	85 c0                	test   %eax,%eax
f010096b:	75 28                	jne    f0100995 <monitor+0x12a>
f010096d:	ba 01 00 00 00       	mov    $0x1,%edx
			return commands[i].func(argc, argv, tf);
f0100972:	6b d2 0c             	imul   $0xc,%edx,%edx
f0100975:	8b 45 08             	mov    0x8(%ebp),%eax
f0100978:	89 44 24 08          	mov    %eax,0x8(%esp)
f010097c:	8d 45 a8             	lea    -0x58(%ebp),%eax
f010097f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100983:	89 34 24             	mov    %esi,(%esp)
f0100986:	ff 92 4c 22 10 f0    	call   *-0xfefddb4(%edx)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f010098c:	85 c0                	test   %eax,%eax
f010098e:	78 1d                	js     f01009ad <monitor+0x142>
f0100990:	e9 fc fe ff ff       	jmp    f0100891 <monitor+0x26>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100995:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100998:	89 44 24 04          	mov    %eax,0x4(%esp)
f010099c:	c7 04 24 78 20 10 f0 	movl   $0xf0102078,(%esp)
f01009a3:	e8 b7 01 00 00       	call   f0100b5f <cprintf>
f01009a8:	e9 e4 fe ff ff       	jmp    f0100891 <monitor+0x26>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01009ad:	83 c4 5c             	add    $0x5c,%esp
f01009b0:	5b                   	pop    %ebx
f01009b1:	5e                   	pop    %esi
f01009b2:	5f                   	pop    %edi
f01009b3:	5d                   	pop    %ebp
f01009b4:	c3                   	ret    

f01009b5 <corruptStack>:
    */
    return 0;
	
}
void corruptStack(unsigned int value, char * point)
{
f01009b5:	55                   	push   %ebp
f01009b6:	89 e5                	mov    %esp,%ebp
f01009b8:	83 ec 18             	sub    $0x18,%esp
f01009bb:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01009be:	89 75 fc             	mov    %esi,-0x4(%ebp)
f01009c1:	8b 75 08             	mov    0x8(%ebp),%esi


   	 // And you must use the "cprintf" function with %n specifier
   	 // you augmented in the "Exercise 9" to do this job.
	//Your code here
    char ntest[value+1];
f01009c4:	8d 46 01             	lea    0x1(%esi),%eax
f01009c7:	8d 56 1f             	lea    0x1f(%esi),%edx
f01009ca:	83 e2 f0             	and    $0xfffffff0,%edx
f01009cd:	29 d4                	sub    %edx,%esp
f01009cf:	8d 5c 24 1b          	lea    0x1b(%esp),%ebx
f01009d3:	83 e3 f0             	and    $0xfffffff0,%ebx
    memset(ntest,0xd,sizeof(ntest));
f01009d6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009da:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
f01009e1:	00 
f01009e2:	89 1c 24             	mov    %ebx,(%esp)
f01009e5:	e8 6c 0e 00 00       	call   f0101856 <memset>
   // char target[value]; 
    ntest[value]='\0';
f01009ea:	c6 04 33 00          	movb   $0x0,(%ebx,%esi,1)
    //strncpy(target,ntest,value);
    cprintf("%s%n\n",ntest,point);
f01009ee:	8b 45 0c             	mov    0xc(%ebp),%eax
f01009f1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01009f9:	c7 04 24 8e 20 10 f0 	movl   $0xf010208e,(%esp)
f0100a00:	e8 5a 01 00 00       	call   f0100b5f <cprintf>
     	
}
f0100a05:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100a08:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100a0b:	89 ec                	mov    %ebp,%esp
f0100a0d:	5d                   	pop    %ebp
f0100a0e:	c3                   	ret    

f0100a0f <mon_backtrace>:
}

    struct Eipdebuginfo info;
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100a0f:	55                   	push   %ebp
f0100a10:	89 e5                	mov    %esp,%ebp
f0100a12:	57                   	push   %edi
f0100a13:	56                   	push   %esi
f0100a14:	53                   	push   %ebx
f0100a15:	81 ec cc 01 00 00    	sub    $0x1cc,%esp
	// Your code here.
	int i=0,j=0;
    int ebp=read_ebp();
f0100a1b:	89 ee                	mov    %ebp,%esi
    int ebps[100];
    int eip=*((int *)ebp+1);
f0100a1d:	8b 7e 04             	mov    0x4(%esi),%edi
    
    while(ebp!=0){
f0100a20:	85 f6                	test   %esi,%esi
f0100a22:	0f 84 b6 00 00 00    	je     f0100ade <mon_backtrace+0xcf>
f0100a28:	8d 85 58 fe ff ff    	lea    -0x1a8(%ebp),%eax
f0100a2e:	89 85 54 fe ff ff    	mov    %eax,-0x1ac(%ebp)
    	cprintf("ebp %x eip %x args ",ebp,eip);
f0100a34:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0100a38:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100a3c:	c7 04 24 94 20 10 f0 	movl   $0xf0102094,(%esp)
f0100a43:	e8 17 01 00 00       	call   f0100b5f <cprintf>
f0100a48:	bb 00 00 00 00       	mov    $0x0,%ebx
    	for(i=0;i<5;i++){
	    	cprintf("%08x ",*((int *)ebp+2+i));
f0100a4d:	8b 44 9e 08          	mov    0x8(%esi,%ebx,4),%eax
f0100a51:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a55:	c7 04 24 a8 20 10 f0 	movl   $0xf01020a8,(%esp)
f0100a5c:	e8 fe 00 00 00       	call   f0100b5f <cprintf>
    int ebps[100];
    int eip=*((int *)ebp+1);
    
    while(ebp!=0){
    	cprintf("ebp %x eip %x args ",ebp,eip);
    	for(i=0;i<5;i++){
f0100a61:	83 c3 01             	add    $0x1,%ebx
f0100a64:	83 fb 05             	cmp    $0x5,%ebx
f0100a67:	75 e4                	jne    f0100a4d <mon_backtrace+0x3e>
	    	cprintf("%08x ",*((int *)ebp+2+i));
    	}        
        cprintf("\n");
f0100a69:	c7 04 24 1a 1e 10 f0 	movl   $0xf0101e1a,(%esp)
f0100a70:	e8 ea 00 00 00       	call   f0100b5f <cprintf>
        
	debuginfo_eip((int)eip,&info);
f0100a75:	c7 44 24 04 44 29 11 	movl   $0xf0112944,0x4(%esp)
f0100a7c:	f0 
f0100a7d:	89 3c 24             	mov    %edi,(%esp)
f0100a80:	e8 49 02 00 00       	call   f0100cce <debuginfo_eip>
    
        cprintf("%s:%d: %.*s+%d\n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,(int )eip-(int )info.eip_fn_addr);
f0100a85:	b8 54 29 11 f0       	mov    $0xf0112954,%eax
f0100a8a:	2b 38                	sub    (%eax),%edi
f0100a8c:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0100a90:	a1 4c 29 11 f0       	mov    0xf011294c,%eax
f0100a95:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100a99:	a1 50 29 11 f0       	mov    0xf0112950,%eax
f0100a9e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100aa2:	a1 48 29 11 f0       	mov    0xf0112948,%eax
f0100aa7:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100aab:	a1 44 29 11 f0       	mov    0xf0112944,%eax
f0100ab0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ab4:	c7 04 24 ae 20 10 f0 	movl   $0xf01020ae,(%esp)
f0100abb:	e8 9f 00 00 00       	call   f0100b5f <cprintf>
        ebps[j++]=ebp;
f0100ac0:	8b 85 54 fe ff ff    	mov    -0x1ac(%ebp),%eax
f0100ac6:	89 30                	mov    %esi,(%eax)
        ebp=*((int *)ebp);
f0100ac8:	8b 36                	mov    (%esi),%esi
        eip=*((int *)ebp+1);
f0100aca:	8b 7e 04             	mov    0x4(%esi),%edi
f0100acd:	83 c0 04             	add    $0x4,%eax
f0100ad0:	89 85 54 fe ff ff    	mov    %eax,-0x1ac(%ebp)
	int i=0,j=0;
    int ebp=read_ebp();
    int ebps[100];
    int eip=*((int *)ebp+1);
    
    while(ebp!=0){
f0100ad6:	85 f6                	test   %esi,%esi
f0100ad8:	0f 85 56 ff ff ff    	jne    f0100a34 <mon_backtrace+0x25>
        ebps[j++]=ebp;
        ebp=*((int *)ebp);
        eip=*((int *)ebp+1);
    }
    
	corruptStack(0x3,(char *)((int *)ebps[2]+2));
f0100ade:	8b 85 60 fe ff ff    	mov    -0x1a0(%ebp),%eax
f0100ae4:	83 c0 08             	add    $0x8,%eax
f0100ae7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100aeb:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
f0100af2:	e8 be fe ff ff       	call   f01009b5 <corruptStack>
	corruptStack(0x5,(char *)((int *)ebps[5]+2));
f0100af7:	8b 9d 6c fe ff ff    	mov    -0x194(%ebp),%ebx
f0100afd:	8d 43 08             	lea    0x8(%ebx),%eax
f0100b00:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b04:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f0100b0b:	e8 a5 fe ff ff       	call   f01009b5 <corruptStack>
	*(int *)ebps[4]=*(int *)ebps[5];	
f0100b10:	8b 13                	mov    (%ebx),%edx
f0100b12:	8b 85 68 fe ff ff    	mov    -0x198(%ebp),%eax
f0100b18:	89 10                	mov    %edx,(%eax)
	
	*(int *)a4=
    */
    return 0;
	
}
f0100b1a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b1f:	81 c4 cc 01 00 00    	add    $0x1cc,%esp
f0100b25:	5b                   	pop    %ebx
f0100b26:	5e                   	pop    %esi
f0100b27:	5f                   	pop    %edi
f0100b28:	5d                   	pop    %ebp
f0100b29:	c3                   	ret    
	...

f0100b2c <vcprintf>:
	*cnt=*cnt+1;
}

int
vcprintf(const char *fmt, va_list ap)
{
f0100b2c:	55                   	push   %ebp
f0100b2d:	89 e5                	mov    %esp,%ebp
f0100b2f:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0100b32:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100b39:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100b3c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100b40:	8b 45 08             	mov    0x8(%ebp),%eax
f0100b43:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100b47:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100b4a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b4e:	c7 04 24 79 0b 10 f0 	movl   $0xf0100b79,(%esp)
f0100b55:	e8 fa 04 00 00       	call   f0101054 <vprintfmt>
	return cnt;
}
f0100b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100b5d:	c9                   	leave  
f0100b5e:	c3                   	ret    

f0100b5f <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100b5f:	55                   	push   %ebp
f0100b60:	89 e5                	mov    %esp,%ebp
f0100b62:	83 ec 18             	sub    $0x18,%esp
	vprintfmt((void*)putch, &cnt, fmt, ap);
	return cnt;
}

int
cprintf(const char *fmt, ...)
f0100b65:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0100b68:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b6c:	8b 45 08             	mov    0x8(%ebp),%eax
f0100b6f:	89 04 24             	mov    %eax,(%esp)
f0100b72:	e8 b5 ff ff ff       	call   f0100b2c <vcprintf>
	va_end(ap);

	return cnt;
}
f0100b77:	c9                   	leave  
f0100b78:	c3                   	ret    

f0100b79 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100b79:	55                   	push   %ebp
f0100b7a:	89 e5                	mov    %esp,%ebp
f0100b7c:	53                   	push   %ebx
f0100b7d:	83 ec 14             	sub    $0x14,%esp
f0100b80:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	cputchar(ch);
f0100b83:	8b 45 08             	mov    0x8(%ebp),%eax
f0100b86:	89 04 24             	mov    %eax,(%esp)
f0100b89:	e8 cc f9 ff ff       	call   f010055a <cputchar>
	*cnt=*cnt+1;
f0100b8e:	83 03 01             	addl   $0x1,(%ebx)
}
f0100b91:	83 c4 14             	add    $0x14,%esp
f0100b94:	5b                   	pop    %ebx
f0100b95:	5d                   	pop    %ebp
f0100b96:	c3                   	ret    
	...

f0100ba0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100ba0:	55                   	push   %ebp
f0100ba1:	89 e5                	mov    %esp,%ebp
f0100ba3:	57                   	push   %edi
f0100ba4:	56                   	push   %esi
f0100ba5:	53                   	push   %ebx
f0100ba6:	83 ec 14             	sub    $0x14,%esp
f0100ba9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100bac:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0100baf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100bb2:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100bb5:	8b 1a                	mov    (%edx),%ebx
f0100bb7:	8b 01                	mov    (%ecx),%eax
f0100bb9:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0100bbc:	39 c3                	cmp    %eax,%ebx
f0100bbe:	0f 8f 9c 00 00 00    	jg     f0100c60 <stab_binsearch+0xc0>
f0100bc4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f0100bcb:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100bce:	01 d8                	add    %ebx,%eax
f0100bd0:	89 c7                	mov    %eax,%edi
f0100bd2:	c1 ef 1f             	shr    $0x1f,%edi
f0100bd5:	01 c7                	add    %eax,%edi
f0100bd7:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100bd9:	39 df                	cmp    %ebx,%edi
f0100bdb:	7c 33                	jl     f0100c10 <stab_binsearch+0x70>
f0100bdd:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100be0:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0100be3:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0100be8:	39 f0                	cmp    %esi,%eax
f0100bea:	0f 84 bc 00 00 00    	je     f0100cac <stab_binsearch+0x10c>
f0100bf0:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
f0100bf4:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
f0100bf8:	89 f8                	mov    %edi,%eax
			m--;
f0100bfa:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100bfd:	39 d8                	cmp    %ebx,%eax
f0100bff:	7c 0f                	jl     f0100c10 <stab_binsearch+0x70>
f0100c01:	0f b6 0a             	movzbl (%edx),%ecx
f0100c04:	83 ea 0c             	sub    $0xc,%edx
f0100c07:	39 f1                	cmp    %esi,%ecx
f0100c09:	75 ef                	jne    f0100bfa <stab_binsearch+0x5a>
f0100c0b:	e9 9e 00 00 00       	jmp    f0100cae <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100c10:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0100c13:	eb 3c                	jmp    f0100c51 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0100c15:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0100c18:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0100c1a:	8d 5f 01             	lea    0x1(%edi),%ebx
f0100c1d:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0100c24:	eb 2b                	jmp    f0100c51 <stab_binsearch+0xb1>
		} else if (stabs[m].n_value > addr) {
f0100c26:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100c29:	76 14                	jbe    f0100c3f <stab_binsearch+0x9f>
			*region_right = m - 1;
f0100c2b:	83 e8 01             	sub    $0x1,%eax
f0100c2e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100c31:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100c34:	89 02                	mov    %eax,(%edx)
f0100c36:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0100c3d:	eb 12                	jmp    f0100c51 <stab_binsearch+0xb1>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100c3f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0100c42:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0100c44:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100c48:	89 c3                	mov    %eax,%ebx
f0100c4a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100c51:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0100c54:	0f 8d 71 ff ff ff    	jge    f0100bcb <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100c5a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100c5e:	75 0f                	jne    f0100c6f <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f0100c60:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100c63:	8b 03                	mov    (%ebx),%eax
f0100c65:	83 e8 01             	sub    $0x1,%eax
f0100c68:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100c6b:	89 02                	mov    %eax,(%edx)
f0100c6d:	eb 57                	jmp    f0100cc6 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100c6f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100c72:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100c74:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100c77:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100c79:	39 c1                	cmp    %eax,%ecx
f0100c7b:	7d 28                	jge    f0100ca5 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0100c7d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100c80:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0100c83:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0100c88:	39 f2                	cmp    %esi,%edx
f0100c8a:	74 19                	je     f0100ca5 <stab_binsearch+0x105>
f0100c8c:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f0100c90:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		     l--)
f0100c94:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100c97:	39 c1                	cmp    %eax,%ecx
f0100c99:	7d 0a                	jge    f0100ca5 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0100c9b:	0f b6 1a             	movzbl (%edx),%ebx
f0100c9e:	83 ea 0c             	sub    $0xc,%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100ca1:	39 f3                	cmp    %esi,%ebx
f0100ca3:	75 ef                	jne    f0100c94 <stab_binsearch+0xf4>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
f0100ca5:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100ca8:	89 02                	mov    %eax,(%edx)
f0100caa:	eb 1a                	jmp    f0100cc6 <stab_binsearch+0x126>
	}
}
f0100cac:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100cae:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100cb1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0100cb4:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100cb8:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100cbb:	0f 82 54 ff ff ff    	jb     f0100c15 <stab_binsearch+0x75>
f0100cc1:	e9 60 ff ff ff       	jmp    f0100c26 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0100cc6:	83 c4 14             	add    $0x14,%esp
f0100cc9:	5b                   	pop    %ebx
f0100cca:	5e                   	pop    %esi
f0100ccb:	5f                   	pop    %edi
f0100ccc:	5d                   	pop    %ebp
f0100ccd:	c3                   	ret    

f0100cce <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100cce:	55                   	push   %ebp
f0100ccf:	89 e5                	mov    %esp,%ebp
f0100cd1:	83 ec 48             	sub    $0x48,%esp
f0100cd4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0100cd7:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0100cda:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0100cdd:	8b 75 08             	mov    0x8(%ebp),%esi
f0100ce0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100ce3:	c7 03 5c 22 10 f0    	movl   $0xf010225c,(%ebx)
	info->eip_line = 0;
f0100ce9:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100cf0:	c7 43 08 5c 22 10 f0 	movl   $0xf010225c,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100cf7:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100cfe:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100d01:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100d08:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100d0e:	76 12                	jbe    f0100d22 <debuginfo_eip+0x54>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100d10:	b8 8d 7e 10 f0       	mov    $0xf0107e8d,%eax
f0100d15:	3d f9 63 10 f0       	cmp    $0xf01063f9,%eax
f0100d1a:	0f 86 aa 01 00 00    	jbe    f0100eca <debuginfo_eip+0x1fc>
f0100d20:	eb 1c                	jmp    f0100d3e <debuginfo_eip+0x70>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100d22:	c7 44 24 08 66 22 10 	movl   $0xf0102266,0x8(%esp)
f0100d29:	f0 
f0100d2a:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0100d31:	00 
f0100d32:	c7 04 24 73 22 10 f0 	movl   $0xf0102273,(%esp)
f0100d39:	e8 47 f3 ff ff       	call   f0100085 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100d3e:	80 3d 8c 7e 10 f0 00 	cmpb   $0x0,0xf0107e8c
f0100d45:	0f 85 7f 01 00 00    	jne    f0100eca <debuginfo_eip+0x1fc>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100d4b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100d52:	b8 f8 63 10 f0       	mov    $0xf01063f8,%eax
f0100d57:	2d 10 25 10 f0       	sub    $0xf0102510,%eax
f0100d5c:	c1 f8 02             	sar    $0x2,%eax
f0100d5f:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100d65:	83 e8 01             	sub    $0x1,%eax
f0100d68:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100d6b:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100d6e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100d71:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100d75:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0100d7c:	b8 10 25 10 f0       	mov    $0xf0102510,%eax
f0100d81:	e8 1a fe ff ff       	call   f0100ba0 <stab_binsearch>
	if (lfile == 0)
f0100d86:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d89:	85 c0                	test   %eax,%eax
f0100d8b:	0f 84 39 01 00 00    	je     f0100eca <debuginfo_eip+0x1fc>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100d91:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100d94:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d97:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100d9a:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100d9d:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100da0:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100da4:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0100dab:	b8 10 25 10 f0       	mov    $0xf0102510,%eax
f0100db0:	e8 eb fd ff ff       	call   f0100ba0 <stab_binsearch>

	if (lfun <= rfun) {
f0100db5:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100db8:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0100dbb:	7f 3c                	jg     f0100df9 <debuginfo_eip+0x12b>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100dbd:	6b c0 0c             	imul   $0xc,%eax,%eax
f0100dc0:	8b 80 10 25 10 f0    	mov    -0xfefdaf0(%eax),%eax
f0100dc6:	ba 8d 7e 10 f0       	mov    $0xf0107e8d,%edx
f0100dcb:	81 ea f9 63 10 f0    	sub    $0xf01063f9,%edx
f0100dd1:	39 d0                	cmp    %edx,%eax
f0100dd3:	73 08                	jae    f0100ddd <debuginfo_eip+0x10f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100dd5:	05 f9 63 10 f0       	add    $0xf01063f9,%eax
f0100dda:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100ddd:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100de0:	6b d0 0c             	imul   $0xc,%eax,%edx
f0100de3:	8b 92 18 25 10 f0    	mov    -0xfefdae8(%edx),%edx
f0100de9:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100dec:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100dee:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100df1:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100df4:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100df7:	eb 0f                	jmp    f0100e08 <debuginfo_eip+0x13a>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100df9:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100dfc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100dff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100e02:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e05:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100e08:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0100e0f:	00 
f0100e10:	8b 43 08             	mov    0x8(%ebx),%eax
f0100e13:	89 04 24             	mov    %eax,(%esp)
f0100e16:	e8 10 0a 00 00       	call   f010182b <strfind>
f0100e1b:	2b 43 08             	sub    0x8(%ebx),%eax
f0100e1e:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
		
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100e21:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100e24:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100e27:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e2b:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0100e32:	b8 10 25 10 f0       	mov    $0xf0102510,%eax
f0100e37:	e8 64 fd ff ff       	call   f0100ba0 <stab_binsearch>
    if(lline<=rline){
f0100e3c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100e3f:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0100e42:	7f 1e                	jg     f0100e62 <debuginfo_eip+0x194>
        info->eip_line=(int)stabs[lline].n_desc;
f0100e44:	6b c0 0c             	imul   $0xc,%eax,%eax
f0100e47:	0f b7 80 16 25 10 f0 	movzwl -0xfefdaea(%eax),%eax
f0100e4e:	89 43 04             	mov    %eax,0x4(%ebx)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
f0100e51:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e54:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100e57:	6b d0 0c             	imul   $0xc,%eax,%edx
f0100e5a:	81 c2 18 25 10 f0    	add    $0xf0102518,%edx
f0100e60:	eb 0f                	jmp    f0100e71 <debuginfo_eip+0x1a3>
		
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if(lline<=rline){
        info->eip_line=(int)stabs[lline].n_desc;
    }else{
        info->eip_line=-1;
f0100e62:	c7 43 04 ff ff ff ff 	movl   $0xffffffff,0x4(%ebx)
f0100e69:	eb e6                	jmp    f0100e51 <debuginfo_eip+0x183>
f0100e6b:	83 e8 01             	sub    $0x1,%eax
f0100e6e:	83 ea 0c             	sub    $0xc,%edx
f0100e71:	89 c6                	mov    %eax,%esi
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100e73:	39 f8                	cmp    %edi,%eax
f0100e75:	7c 22                	jl     f0100e99 <debuginfo_eip+0x1cb>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100e77:	0f b6 4a fc          	movzbl -0x4(%edx),%ecx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100e7b:	80 f9 84             	cmp    $0x84,%cl
f0100e7e:	74 64                	je     f0100ee4 <debuginfo_eip+0x216>
f0100e80:	80 f9 64             	cmp    $0x64,%cl
f0100e83:	75 e6                	jne    f0100e6b <debuginfo_eip+0x19d>
f0100e85:	83 3a 00             	cmpl   $0x0,(%edx)
f0100e88:	74 e1                	je     f0100e6b <debuginfo_eip+0x19d>
f0100e8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0100e90:	eb 52                	jmp    f0100ee4 <debuginfo_eip+0x216>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100e92:	05 f9 63 10 f0       	add    $0xf01063f9,%eax
f0100e97:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100e99:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100e9c:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0100e9f:	7d 31                	jge    f0100ed2 <debuginfo_eip+0x204>
		for (lline = lfun + 1;
f0100ea1:	83 c0 01             	add    $0x1,%eax
f0100ea4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100ea7:	ba 10 25 10 f0       	mov    $0xf0102510,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100eac:	eb 08                	jmp    f0100eb6 <debuginfo_eip+0x1e8>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100eae:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0100eb2:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100eb6:	8b 45 d4             	mov    -0x2c(%ebp),%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100eb9:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0100ebc:	7d 14                	jge    f0100ed2 <debuginfo_eip+0x204>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100ebe:	6b c0 0c             	imul   $0xc,%eax,%eax
f0100ec1:	80 7c 10 04 a0       	cmpb   $0xa0,0x4(%eax,%edx,1)
f0100ec6:	74 e6                	je     f0100eae <debuginfo_eip+0x1e0>
f0100ec8:	eb 08                	jmp    f0100ed2 <debuginfo_eip+0x204>
f0100eca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ecf:	90                   	nop
f0100ed0:	eb 05                	jmp    f0100ed7 <debuginfo_eip+0x209>
f0100ed2:	b8 00 00 00 00       	mov    $0x0,%eax
		     lline++)
			info->eip_fn_narg++;

	return 0;
}
f0100ed7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0100eda:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0100edd:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0100ee0:	89 ec                	mov    %ebp,%esp
f0100ee2:	5d                   	pop    %ebp
f0100ee3:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100ee4:	6b c6 0c             	imul   $0xc,%esi,%eax
f0100ee7:	8b 80 10 25 10 f0    	mov    -0xfefdaf0(%eax),%eax
f0100eed:	ba 8d 7e 10 f0       	mov    $0xf0107e8d,%edx
f0100ef2:	81 ea f9 63 10 f0    	sub    $0xf01063f9,%edx
f0100ef8:	39 d0                	cmp    %edx,%eax
f0100efa:	72 96                	jb     f0100e92 <debuginfo_eip+0x1c4>
f0100efc:	eb 9b                	jmp    f0100e99 <debuginfo_eip+0x1cb>
	...

f0100f00 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100f00:	55                   	push   %ebp
f0100f01:	89 e5                	mov    %esp,%ebp
f0100f03:	57                   	push   %edi
f0100f04:	56                   	push   %esi
f0100f05:	53                   	push   %ebx
f0100f06:	83 ec 4c             	sub    $0x4c,%esp
f0100f09:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100f0c:	89 d6                	mov    %edx,%esi
f0100f0e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f11:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100f14:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100f17:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100f1a:	8b 45 10             	mov    0x10(%ebp),%eax
f0100f1d:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100f20:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100f23:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100f26:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100f2b:	39 d1                	cmp    %edx,%ecx
f0100f2d:	72 15                	jb     f0100f44 <printnum+0x44>
f0100f2f:	77 07                	ja     f0100f38 <printnum+0x38>
f0100f31:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100f34:	39 d0                	cmp    %edx,%eax
f0100f36:	76 0c                	jbe    f0100f44 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
        iter++;
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100f38:	83 eb 01             	sub    $0x1,%ebx
f0100f3b:	85 db                	test   %ebx,%ebx
f0100f3d:	8d 76 00             	lea    0x0(%esi),%esi
f0100f40:	7f 68                	jg     f0100faa <printnum+0xaa>
f0100f42:	eb 77                	jmp    f0100fbb <printnum+0xbb>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100f44:	89 7c 24 10          	mov    %edi,0x10(%esp)
f0100f48:	83 eb 01             	sub    $0x1,%ebx
f0100f4b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100f4f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100f53:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0100f57:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f0100f5b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0100f5e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0100f61:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100f64:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100f68:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100f6f:	00 
f0100f70:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100f73:	89 04 24             	mov    %eax,(%esp)
f0100f76:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100f79:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100f7d:	e8 3e 0b 00 00       	call   f0101ac0 <__udivdi3>
f0100f82:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100f85:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100f88:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100f8c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100f90:	89 04 24             	mov    %eax,(%esp)
f0100f93:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100f97:	89 f2                	mov    %esi,%edx
f0100f99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f9c:	e8 5f ff ff ff       	call   f0100f00 <printnum>
        iter++;
f0100fa1:	83 05 28 25 11 f0 01 	addl   $0x1,0xf0112528
f0100fa8:	eb 11                	jmp    f0100fbb <printnum+0xbb>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100faa:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100fae:	89 3c 24             	mov    %edi,(%esp)
f0100fb1:	ff 55 e4             	call   *-0x1c(%ebp)
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
        iter++;
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100fb4:	83 eb 01             	sub    $0x1,%ebx
f0100fb7:	85 db                	test   %ebx,%ebx
f0100fb9:	7f ef                	jg     f0100faa <printnum+0xaa>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100fbb:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100fbf:	8b 74 24 04          	mov    0x4(%esp),%esi
f0100fc3:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100fc6:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100fca:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100fd1:	00 
f0100fd2:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100fd5:	89 14 24             	mov    %edx,(%esp)
f0100fd8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100fdb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100fdf:	e8 0c 0c 00 00       	call   f0101bf0 <__umoddi3>
f0100fe4:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100fe8:	0f be 80 81 22 10 f0 	movsbl -0xfefdd7f(%eax),%eax
f0100fef:	89 04 24             	mov    %eax,(%esp)
f0100ff2:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0100ff5:	83 c4 4c             	add    $0x4c,%esp
f0100ff8:	5b                   	pop    %ebx
f0100ff9:	5e                   	pop    %esi
f0100ffa:	5f                   	pop    %edi
f0100ffb:	5d                   	pop    %ebp
f0100ffc:	c3                   	ret    

f0100ffd <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100ffd:	55                   	push   %ebp
f0100ffe:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0101000:	83 fa 01             	cmp    $0x1,%edx
f0101003:	7e 0e                	jle    f0101013 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0101005:	8b 10                	mov    (%eax),%edx
f0101007:	8d 4a 08             	lea    0x8(%edx),%ecx
f010100a:	89 08                	mov    %ecx,(%eax)
f010100c:	8b 02                	mov    (%edx),%eax
f010100e:	8b 52 04             	mov    0x4(%edx),%edx
f0101011:	eb 22                	jmp    f0101035 <getuint+0x38>
	else if (lflag)
f0101013:	85 d2                	test   %edx,%edx
f0101015:	74 10                	je     f0101027 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0101017:	8b 10                	mov    (%eax),%edx
f0101019:	8d 4a 04             	lea    0x4(%edx),%ecx
f010101c:	89 08                	mov    %ecx,(%eax)
f010101e:	8b 02                	mov    (%edx),%eax
f0101020:	ba 00 00 00 00       	mov    $0x0,%edx
f0101025:	eb 0e                	jmp    f0101035 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0101027:	8b 10                	mov    (%eax),%edx
f0101029:	8d 4a 04             	lea    0x4(%edx),%ecx
f010102c:	89 08                	mov    %ecx,(%eax)
f010102e:	8b 02                	mov    (%edx),%eax
f0101030:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0101035:	5d                   	pop    %ebp
f0101036:	c3                   	ret    

f0101037 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0101037:	55                   	push   %ebp
f0101038:	89 e5                	mov    %esp,%ebp
f010103a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010103d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0101041:	8b 10                	mov    (%eax),%edx
f0101043:	3b 50 04             	cmp    0x4(%eax),%edx
f0101046:	73 0a                	jae    f0101052 <sprintputch+0x1b>
		*b->buf++ = ch;
f0101048:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010104b:	88 0a                	mov    %cl,(%edx)
f010104d:	83 c2 01             	add    $0x1,%edx
f0101050:	89 10                	mov    %edx,(%eax)
}
f0101052:	5d                   	pop    %ebp
f0101053:	c3                   	ret    

f0101054 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0101054:	55                   	push   %ebp
f0101055:	89 e5                	mov    %esp,%ebp
f0101057:	57                   	push   %edi
f0101058:	56                   	push   %esi
f0101059:	53                   	push   %ebx
f010105a:	83 ec 4c             	sub    $0x4c,%esp
f010105d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
    iter=0;
f0101060:	c7 05 28 25 11 f0 00 	movl   $0x0,0xf0112528
f0101067:	00 00 00 
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f010106a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0101071:	eb 1c                	jmp    f010108f <vprintfmt+0x3b>
	char padc;
    iter=0;
    
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0101073:	85 c0                	test   %eax,%eax
f0101075:	0f 84 72 04 00 00    	je     f01014ed <vprintfmt+0x499>
				return;
			putch(ch, putdat);
f010107b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010107e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101082:	89 04 24             	mov    %eax,(%esp)
f0101085:	ff 55 08             	call   *0x8(%ebp)
            iter++;
f0101088:	83 05 28 25 11 f0 01 	addl   $0x1,0xf0112528
	int base, lflag, width, precision, altflag;
	char padc;
    iter=0;
    
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010108f:	0f b6 03             	movzbl (%ebx),%eax
f0101092:	83 c3 01             	add    $0x1,%ebx
f0101095:	83 f8 25             	cmp    $0x25,%eax
f0101098:	75 d9                	jne    f0101073 <vprintfmt+0x1f>
f010109a:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010109f:	b9 00 00 00 00       	mov    $0x0,%ecx
f01010a4:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f01010a8:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01010af:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f01010b4:	eb 06                	jmp    f01010bc <vprintfmt+0x68>
f01010b6:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f01010ba:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010bc:	0f b6 13             	movzbl (%ebx),%edx
f01010bf:	0f b6 c2             	movzbl %dl,%eax
f01010c2:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01010c5:	8d 43 01             	lea    0x1(%ebx),%eax
f01010c8:	83 ea 23             	sub    $0x23,%edx
f01010cb:	80 fa 55             	cmp    $0x55,%dl
f01010ce:	0f 87 f8 03 00 00    	ja     f01014cc <vprintfmt+0x478>
f01010d4:	0f b6 d2             	movzbl %dl,%edx
f01010d7:	ff 24 95 8c 23 10 f0 	jmp    *-0xfefdc74(,%edx,4)
f01010de:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f01010e2:	eb d6                	jmp    f01010ba <vprintfmt+0x66>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01010e4:	8b 7d dc             	mov    -0x24(%ebp),%edi
f01010e7:	83 ef 30             	sub    $0x30,%edi
				ch = *fmt;
f01010ea:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f01010ed:	8d 5a d0             	lea    -0x30(%edx),%ebx
f01010f0:	83 fb 09             	cmp    $0x9,%ebx
f01010f3:	77 38                	ja     f010112d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01010f5:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
f01010f8:	8d 1c bf             	lea    (%edi,%edi,4),%ebx
f01010fb:	8d 7c 5a d0          	lea    -0x30(%edx,%ebx,2),%edi
				ch = *fmt;
f01010ff:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0101102:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0101105:	83 fb 09             	cmp    $0x9,%ebx
f0101108:	76 eb                	jbe    f01010f5 <vprintfmt+0xa1>
f010110a:	eb 21                	jmp    f010112d <vprintfmt+0xd9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f010110c:	8b 55 14             	mov    0x14(%ebp),%edx
f010110f:	8d 5a 04             	lea    0x4(%edx),%ebx
f0101112:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0101115:	8b 3a                	mov    (%edx),%edi
			goto process_precision;
f0101117:	eb 14                	jmp    f010112d <vprintfmt+0xd9>

		case '.':
			if (width < 0)
f0101119:	89 f2                	mov    %esi,%edx
f010111b:	c1 fa 1f             	sar    $0x1f,%edx
f010111e:	f7 d2                	not    %edx
f0101120:	21 d6                	and    %edx,%esi
f0101122:	eb 96                	jmp    f01010ba <vprintfmt+0x66>
f0101124:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
f010112b:	eb 8d                	jmp    f01010ba <vprintfmt+0x66>

		process_precision:
			if (width < 0)
f010112d:	85 f6                	test   %esi,%esi
f010112f:	79 89                	jns    f01010ba <vprintfmt+0x66>
f0101131:	89 fe                	mov    %edi,%esi
f0101133:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0101136:	eb 82                	jmp    f01010ba <vprintfmt+0x66>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0101138:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
f010113b:	e9 7a ff ff ff       	jmp    f01010ba <vprintfmt+0x66>
f0101140:	89 45 d4             	mov    %eax,-0x2c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0101143:	8b 45 14             	mov    0x14(%ebp),%eax
f0101146:	8d 50 04             	lea    0x4(%eax),%edx
f0101149:	89 55 14             	mov    %edx,0x14(%ebp)
f010114c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010114f:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101153:	8b 00                	mov    (%eax),%eax
f0101155:	89 04 24             	mov    %eax,(%esp)
f0101158:	ff 55 08             	call   *0x8(%ebp)
f010115b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			break;
f010115e:	e9 2c ff ff ff       	jmp    f010108f <vprintfmt+0x3b>
f0101163:	89 45 d4             	mov    %eax,-0x2c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0101166:	8b 45 14             	mov    0x14(%ebp),%eax
f0101169:	8d 50 04             	lea    0x4(%eax),%edx
f010116c:	89 55 14             	mov    %edx,0x14(%ebp)
f010116f:	8b 00                	mov    (%eax),%eax
f0101171:	89 c2                	mov    %eax,%edx
f0101173:	c1 fa 1f             	sar    $0x1f,%edx
f0101176:	31 d0                	xor    %edx,%eax
f0101178:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010117a:	83 f8 06             	cmp    $0x6,%eax
f010117d:	7f 0b                	jg     f010118a <vprintfmt+0x136>
f010117f:	8b 14 85 e4 24 10 f0 	mov    -0xfefdb1c(,%eax,4),%edx
f0101186:	85 d2                	test   %edx,%edx
f0101188:	75 26                	jne    f01011b0 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
f010118a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010118e:	c7 44 24 08 92 22 10 	movl   $0xf0102292,0x8(%esp)
f0101195:	f0 
f0101196:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101199:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010119d:	8b 45 08             	mov    0x8(%ebp),%eax
f01011a0:	89 04 24             	mov    %eax,(%esp)
f01011a3:	e8 cd 03 00 00       	call   f0101575 <printfmt>
f01011a8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01011ab:	e9 df fe ff ff       	jmp    f010108f <vprintfmt+0x3b>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f01011b0:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01011b4:	c7 44 24 08 9b 22 10 	movl   $0xf010229b,0x8(%esp)
f01011bb:	f0 
f01011bc:	8b 55 0c             	mov    0xc(%ebp),%edx
f01011bf:	89 54 24 04          	mov    %edx,0x4(%esp)
f01011c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01011c6:	89 0c 24             	mov    %ecx,(%esp)
f01011c9:	e8 a7 03 00 00       	call   f0101575 <printfmt>
f01011ce:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01011d1:	e9 b9 fe ff ff       	jmp    f010108f <vprintfmt+0x3b>
f01011d6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01011d9:	89 c3                	mov    %eax,%ebx
f01011db:	89 75 cc             	mov    %esi,-0x34(%ebp)
f01011de:	89 f9                	mov    %edi,%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL){
f01011e0:	8b 45 14             	mov    0x14(%ebp),%eax
f01011e3:	8d 50 04             	lea    0x4(%eax),%edx
f01011e6:	89 55 14             	mov    %edx,0x14(%ebp)
f01011e9:	8b 00                	mov    (%eax),%eax
f01011eb:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01011ee:	85 c0                	test   %eax,%eax
f01011f0:	75 0e                	jne    f0101200 <vprintfmt+0x1ac>
				p = "(null)";
                iter+=6;
f01011f2:	83 05 28 25 11 f0 06 	addl   $0x6,0xf0112528
f01011f9:	c7 45 dc 9e 22 10 f0 	movl   $0xf010229e,-0x24(%ebp)
            }
			if (width > 0 && padc != '-')
f0101200:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0101204:	7e 06                	jle    f010120c <vprintfmt+0x1b8>
f0101206:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f010120a:	75 13                	jne    f010121f <vprintfmt+0x1cb>
				for (width -= strnlen(p, precision); width > 0; width--){
					putch(padc, putdat);
                    iter++;
                }
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--){
f010120c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010120f:	0f be 02             	movsbl (%edx),%eax
f0101212:	85 c0                	test   %eax,%eax
f0101214:	0f 85 a4 00 00 00    	jne    f01012be <vprintfmt+0x26a>
f010121a:	e9 93 00 00 00       	jmp    f01012b2 <vprintfmt+0x25e>
			if ((p = va_arg(ap, char *)) == NULL){
				p = "(null)";
                iter+=6;
            }
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--){
f010121f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101223:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0101226:	89 0c 24             	mov    %ecx,(%esp)
f0101229:	e8 6d 04 00 00       	call   f010169b <strnlen>
f010122e:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0101231:	29 c6                	sub    %eax,%esi
f0101233:	85 f6                	test   %esi,%esi
f0101235:	7e d5                	jle    f010120c <vprintfmt+0x1b8>
					putch(padc, putdat);
f0101237:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f010123b:	89 7d cc             	mov    %edi,-0x34(%ebp)
f010123e:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101241:	89 5d c8             	mov    %ebx,-0x38(%ebp)
f0101244:	89 c3                	mov    %eax,%ebx
f0101246:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010124a:	89 1c 24             	mov    %ebx,(%esp)
f010124d:	ff 55 08             	call   *0x8(%ebp)
                    iter++;
f0101250:	83 05 28 25 11 f0 01 	addl   $0x1,0xf0112528
			if ((p = va_arg(ap, char *)) == NULL){
				p = "(null)";
                iter+=6;
            }
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--){
f0101257:	83 ee 01             	sub    $0x1,%esi
f010125a:	85 f6                	test   %esi,%esi
f010125c:	7f e8                	jg     f0101246 <vprintfmt+0x1f2>
f010125e:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0101261:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0101264:	be 00 00 00 00       	mov    $0x0,%esi
f0101269:	eb a1                	jmp    f010120c <vprintfmt+0x1b8>
					putch(padc, putdat);
                    iter++;
                }
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--){
			    iter++;
f010126b:	83 05 28 25 11 f0 01 	addl   $0x1,0xf0112528
                if (altflag && (ch < ' ' || ch > '~'))
f0101272:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101276:	74 1b                	je     f0101293 <vprintfmt+0x23f>
f0101278:	8d 50 e0             	lea    -0x20(%eax),%edx
f010127b:	83 fa 5e             	cmp    $0x5e,%edx
f010127e:	76 13                	jbe    f0101293 <vprintfmt+0x23f>
					putch('?', putdat);
f0101280:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101283:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101287:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f010128e:	ff 55 08             	call   *0x8(%ebp)
					putch(padc, putdat);
                    iter++;
                }
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--){
			    iter++;
                if (altflag && (ch < ' ' || ch > '~'))
f0101291:	eb 0d                	jmp    f01012a0 <vprintfmt+0x24c>
					putch('?', putdat);
				else
					putch(ch, putdat);
f0101293:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101296:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010129a:	89 04 24             	mov    %eax,(%esp)
f010129d:	ff 55 08             	call   *0x8(%ebp)
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--){
					putch(padc, putdat);
                    iter++;
                }
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--){
f01012a0:	83 ee 01             	sub    $0x1,%esi
f01012a3:	0f be 03             	movsbl (%ebx),%eax
f01012a6:	85 c0                	test   %eax,%eax
f01012a8:	74 05                	je     f01012af <vprintfmt+0x25b>
f01012aa:	83 c3 01             	add    $0x1,%ebx
f01012ad:	eb 1a                	jmp    f01012c9 <vprintfmt+0x275>
f01012af:	8b 5d d8             	mov    -0x28(%ebp),%ebx
                if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
            }
			for (; width > 0; width--){
f01012b2:	85 f6                	test   %esi,%esi
f01012b4:	7f 21                	jg     f01012d7 <vprintfmt+0x283>
f01012b6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01012b9:	e9 d1 fd ff ff       	jmp    f010108f <vprintfmt+0x3b>
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--){
					putch(padc, putdat);
                    iter++;
                }
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--){
f01012be:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01012c1:	83 c2 01             	add    $0x1,%edx
f01012c4:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f01012c7:	89 d3                	mov    %edx,%ebx
f01012c9:	85 ff                	test   %edi,%edi
f01012cb:	78 9e                	js     f010126b <vprintfmt+0x217>
f01012cd:	83 ef 01             	sub    $0x1,%edi
f01012d0:	79 99                	jns    f010126b <vprintfmt+0x217>
f01012d2:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f01012d5:	eb db                	jmp    f01012b2 <vprintfmt+0x25e>
f01012d7:	8b 7d 08             	mov    0x8(%ebp),%edi
f01012da:	89 5d e0             	mov    %ebx,-0x20(%ebp)
f01012dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
					putch('?', putdat);
				else
					putch(ch, putdat);
            }
			for (; width > 0; width--){
				putch(' ', putdat);
f01012e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01012e4:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01012eb:	ff d7                	call   *%edi
                iter++;
f01012ed:	83 05 28 25 11 f0 01 	addl   $0x1,0xf0112528
                if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
            }
			for (; width > 0; width--){
f01012f4:	83 ee 01             	sub    $0x1,%esi
f01012f7:	85 f6                	test   %esi,%esi
f01012f9:	7f e5                	jg     f01012e0 <vprintfmt+0x28c>
f01012fb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01012fe:	e9 8c fd ff ff       	jmp    f010108f <vprintfmt+0x3b>
f0101303:	89 45 d4             	mov    %eax,-0x2c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101306:	83 f9 01             	cmp    $0x1,%ecx
f0101309:	7e 16                	jle    f0101321 <vprintfmt+0x2cd>
		return va_arg(*ap, long long);
f010130b:	8b 45 14             	mov    0x14(%ebp),%eax
f010130e:	8d 50 08             	lea    0x8(%eax),%edx
f0101311:	89 55 14             	mov    %edx,0x14(%ebp)
f0101314:	8b 10                	mov    (%eax),%edx
f0101316:	8b 48 04             	mov    0x4(%eax),%ecx
f0101319:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010131c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f010131f:	eb 32                	jmp    f0101353 <vprintfmt+0x2ff>
	else if (lflag)
f0101321:	85 c9                	test   %ecx,%ecx
f0101323:	74 18                	je     f010133d <vprintfmt+0x2e9>
		return va_arg(*ap, long);
f0101325:	8b 45 14             	mov    0x14(%ebp),%eax
f0101328:	8d 50 04             	lea    0x4(%eax),%edx
f010132b:	89 55 14             	mov    %edx,0x14(%ebp)
f010132e:	8b 00                	mov    (%eax),%eax
f0101330:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101333:	89 c1                	mov    %eax,%ecx
f0101335:	c1 f9 1f             	sar    $0x1f,%ecx
f0101338:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f010133b:	eb 16                	jmp    f0101353 <vprintfmt+0x2ff>
	else
		return va_arg(*ap, int);
f010133d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101340:	8d 50 04             	lea    0x4(%eax),%edx
f0101343:	89 55 14             	mov    %edx,0x14(%ebp)
f0101346:	8b 00                	mov    (%eax),%eax
f0101348:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010134b:	89 c2                	mov    %eax,%edx
f010134d:	c1 fa 1f             	sar    $0x1f,%edx
f0101350:	89 55 e4             	mov    %edx,-0x1c(%ebp)
            }
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0101353:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101356:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101359:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long) num < 0) {
f010135e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101362:	0f 89 9b 00 00 00    	jns    f0101403 <vprintfmt+0x3af>
				putch('-', putdat);
f0101368:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010136b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010136f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0101376:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0101379:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010137c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010137f:	f7 d8                	neg    %eax
f0101381:	83 d2 00             	adc    $0x0,%edx
f0101384:	f7 da                	neg    %edx
f0101386:	b9 0a 00 00 00       	mov    $0xa,%ecx
f010138b:	eb 76                	jmp    f0101403 <vprintfmt+0x3af>
f010138d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0101390:	89 ca                	mov    %ecx,%edx
f0101392:	8d 45 14             	lea    0x14(%ebp),%eax
f0101395:	e8 63 fc ff ff       	call   f0100ffd <getuint>
f010139a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			base = 10;
			goto number;
f010139f:	eb 62                	jmp    f0101403 <vprintfmt+0x3af>
f01013a1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
			// Replace this with your code.
		//	putch('X', putdat);
		//	putch('X', putdat);
		//	putch('X', putdat);
		//	break;
            num=getuint(&ap,lflag);
f01013a4:	89 ca                	mov    %ecx,%edx
f01013a6:	8d 45 14             	lea    0x14(%ebp),%eax
f01013a9:	e8 4f fc ff ff       	call   f0100ffd <getuint>
f01013ae:	b9 08 00 00 00       	mov    $0x8,%ecx
            base = 8;
            goto number;
f01013b3:	eb 4e                	jmp    f0101403 <vprintfmt+0x3af>
f01013b5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		// pointer
		case 'p':
			putch('0', putdat);
f01013b8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01013bb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01013bf:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01013c6:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01013c9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01013cc:	89 54 24 04          	mov    %edx,0x4(%esp)
f01013d0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01013d7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f01013da:	8b 45 14             	mov    0x14(%ebp),%eax
f01013dd:	8d 50 04             	lea    0x4(%eax),%edx
f01013e0:	89 55 14             	mov    %edx,0x14(%ebp)
f01013e3:	8b 00                	mov    (%eax),%eax
f01013e5:	ba 00 00 00 00       	mov    $0x0,%edx
f01013ea:	b9 10 00 00 00       	mov    $0x10,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01013ef:	eb 12                	jmp    f0101403 <vprintfmt+0x3af>
f01013f1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01013f4:	89 ca                	mov    %ecx,%edx
f01013f6:	8d 45 14             	lea    0x14(%ebp),%eax
f01013f9:	e8 ff fb ff ff       	call   f0100ffd <getuint>
f01013fe:	b9 10 00 00 00       	mov    $0x10,%ecx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f0101403:	0f be 5d d8          	movsbl -0x28(%ebp),%ebx
f0101407:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f010140b:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010140f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101413:	89 04 24             	mov    %eax,(%esp)
f0101416:	89 54 24 04          	mov    %edx,0x4(%esp)
f010141a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010141d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101420:	e8 db fa ff ff       	call   f0100f00 <printnum>
            iter++;
f0101425:	83 05 28 25 11 f0 01 	addl   $0x1,0xf0112528
f010142c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			break;
f010142f:	e9 5b fc ff ff       	jmp    f010108f <vprintfmt+0x3b>
f0101434:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101437:	8b 55 dc             	mov    -0x24(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010143a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010143d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101441:	89 14 24             	mov    %edx,(%esp)
f0101444:	ff 55 08             	call   *0x8(%ebp)
f0101447:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
			break;
f010144a:	e9 40 fc ff ff       	jmp    f010108f <vprintfmt+0x3b>
f010144f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

		    const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
		    const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";
            signed char *arg=NULL;
		    // Your code here
			if((arg = va_arg(ap,signed char *)) == NULL){
f0101452:	8b 45 14             	mov    0x14(%ebp),%eax
f0101455:	8d 50 04             	lea    0x4(%eax),%edx
f0101458:	89 55 14             	mov    %edx,0x14(%ebp)
f010145b:	8b 18                	mov    (%eax),%ebx
f010145d:	85 db                	test   %ebx,%ebx
f010145f:	75 2a                	jne    f010148b <vprintfmt+0x437>
				printfmt(putch, putdat, "%s", null_error);
f0101461:	c7 44 24 0c 10 23 10 	movl   $0xf0102310,0xc(%esp)
f0101468:	f0 
f0101469:	c7 44 24 08 9b 22 10 	movl   $0xf010229b,0x8(%esp)
f0101470:	f0 
f0101471:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101474:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101478:	8b 55 08             	mov    0x8(%ebp),%edx
f010147b:	89 14 24             	mov    %edx,(%esp)
f010147e:	e8 f2 00 00 00       	call   f0101575 <printfmt>
f0101483:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
                break;
f0101486:	e9 04 fc ff ff       	jmp    f010108f <vprintfmt+0x3b>
            }
            if(iter>127||iter<0){
f010148b:	a1 28 25 11 f0       	mov    0xf0112528,%eax
f0101490:	83 f8 7f             	cmp    $0x7f,%eax
f0101493:	76 2d                	jbe    f01014c2 <vprintfmt+0x46e>
             //   printfmt(putch,putdat,"%d",iter);
				printfmt(putch, putdat, "%s",overflow_error);
f0101495:	c7 44 24 0c 48 23 10 	movl   $0xf0102348,0xc(%esp)
f010149c:	f0 
f010149d:	c7 44 24 08 9b 22 10 	movl   $0xf010229b,0x8(%esp)
f01014a4:	f0 
f01014a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01014a8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01014ac:	8b 45 08             	mov    0x8(%ebp),%eax
f01014af:	89 04 24             	mov    %eax,(%esp)
f01014b2:	e8 be 00 00 00       	call   f0101575 <printfmt>
                *arg=-1;
f01014b7:	c6 03 ff             	movb   $0xff,(%ebx)
f01014ba:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
                break;
f01014bd:	e9 cd fb ff ff       	jmp    f010108f <vprintfmt+0x3b>
            }
            *arg=iter;
f01014c2:	88 03                	mov    %al,(%ebx)
f01014c4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
		    break;
f01014c7:	e9 c3 fb ff ff       	jmp    f010108f <vprintfmt+0x3b>
		}
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01014cc:	8b 55 0c             	mov    0xc(%ebp),%edx
f01014cf:	89 54 24 04          	mov    %edx,0x4(%esp)
f01014d3:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01014da:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01014dd:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01014e0:	80 38 25             	cmpb   $0x25,(%eax)
f01014e3:	0f 84 a6 fb ff ff    	je     f010108f <vprintfmt+0x3b>
f01014e9:	89 c3                	mov    %eax,%ebx
f01014eb:	eb f0                	jmp    f01014dd <vprintfmt+0x489>
				/* do nothing */;
			break;
		}
	}
}
f01014ed:	83 c4 4c             	add    $0x4c,%esp
f01014f0:	5b                   	pop    %ebx
f01014f1:	5e                   	pop    %esi
f01014f2:	5f                   	pop    %edi
f01014f3:	5d                   	pop    %ebp
f01014f4:	c3                   	ret    

f01014f5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01014f5:	55                   	push   %ebp
f01014f6:	89 e5                	mov    %esp,%ebp
f01014f8:	83 ec 28             	sub    $0x28,%esp
f01014fb:	8b 45 08             	mov    0x8(%ebp),%eax
f01014fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f0101501:	85 c0                	test   %eax,%eax
f0101503:	74 04                	je     f0101509 <vsnprintf+0x14>
f0101505:	85 d2                	test   %edx,%edx
f0101507:	7f 07                	jg     f0101510 <vsnprintf+0x1b>
f0101509:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010150e:	eb 3b                	jmp    f010154b <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101510:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101513:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f0101517:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010151a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101521:	8b 45 14             	mov    0x14(%ebp),%eax
f0101524:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101528:	8b 45 10             	mov    0x10(%ebp),%eax
f010152b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010152f:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101532:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101536:	c7 04 24 37 10 10 f0 	movl   $0xf0101037,(%esp)
f010153d:	e8 12 fb ff ff       	call   f0101054 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101542:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101545:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101548:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f010154b:	c9                   	leave  
f010154c:	c3                   	ret    

f010154d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010154d:	55                   	push   %ebp
f010154e:	89 e5                	mov    %esp,%ebp
f0101550:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
f0101553:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f0101556:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010155a:	8b 45 10             	mov    0x10(%ebp),%eax
f010155d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101561:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101564:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101568:	8b 45 08             	mov    0x8(%ebp),%eax
f010156b:	89 04 24             	mov    %eax,(%esp)
f010156e:	e8 82 ff ff ff       	call   f01014f5 <vsnprintf>
	va_end(ap);

	return rc;
}
f0101573:	c9                   	leave  
f0101574:	c3                   	ret    

f0101575 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0101575:	55                   	push   %ebp
f0101576:	89 e5                	mov    %esp,%ebp
f0101578:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
f010157b:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f010157e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101582:	8b 45 10             	mov    0x10(%ebp),%eax
f0101585:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101589:	8b 45 0c             	mov    0xc(%ebp),%eax
f010158c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101590:	8b 45 08             	mov    0x8(%ebp),%eax
f0101593:	89 04 24             	mov    %eax,(%esp)
f0101596:	e8 b9 fa ff ff       	call   f0101054 <vprintfmt>
	va_end(ap);
}
f010159b:	c9                   	leave  
f010159c:	c3                   	ret    
f010159d:	00 00                	add    %al,(%eax)
	...

f01015a0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01015a0:	55                   	push   %ebp
f01015a1:	89 e5                	mov    %esp,%ebp
f01015a3:	57                   	push   %edi
f01015a4:	56                   	push   %esi
f01015a5:	53                   	push   %ebx
f01015a6:	83 ec 1c             	sub    $0x1c,%esp
f01015a9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01015ac:	85 c0                	test   %eax,%eax
f01015ae:	74 10                	je     f01015c0 <readline+0x20>
		cprintf("%s", prompt);
f01015b0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015b4:	c7 04 24 9b 22 10 f0 	movl   $0xf010229b,(%esp)
f01015bb:	e8 9f f5 ff ff       	call   f0100b5f <cprintf>

	i = 0;
	echoing = iscons(0);
f01015c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015c7:	e8 8a ed ff ff       	call   f0100356 <iscons>
f01015cc:	89 c7                	mov    %eax,%edi
f01015ce:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f01015d3:	e8 6d ed ff ff       	call   f0100345 <getchar>
f01015d8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01015da:	85 c0                	test   %eax,%eax
f01015dc:	79 17                	jns    f01015f5 <readline+0x55>
			cprintf("read error: %e\n", c);
f01015de:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015e2:	c7 04 24 00 25 10 f0 	movl   $0xf0102500,(%esp)
f01015e9:	e8 71 f5 ff ff       	call   f0100b5f <cprintf>
f01015ee:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
f01015f3:	eb 76                	jmp    f010166b <readline+0xcb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01015f5:	83 f8 08             	cmp    $0x8,%eax
f01015f8:	74 08                	je     f0101602 <readline+0x62>
f01015fa:	83 f8 7f             	cmp    $0x7f,%eax
f01015fd:	8d 76 00             	lea    0x0(%esi),%esi
f0101600:	75 19                	jne    f010161b <readline+0x7b>
f0101602:	85 f6                	test   %esi,%esi
f0101604:	7e 15                	jle    f010161b <readline+0x7b>
			if (echoing)
f0101606:	85 ff                	test   %edi,%edi
f0101608:	74 0c                	je     f0101616 <readline+0x76>
				cputchar('\b');
f010160a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0101611:	e8 44 ef ff ff       	call   f010055a <cputchar>
			i--;
f0101616:	83 ee 01             	sub    $0x1,%esi
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101619:	eb b8                	jmp    f01015d3 <readline+0x33>
			if (echoing)
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
f010161b:	83 fb 1f             	cmp    $0x1f,%ebx
f010161e:	66 90                	xchg   %ax,%ax
f0101620:	7e 23                	jle    f0101645 <readline+0xa5>
f0101622:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101628:	7f 1b                	jg     f0101645 <readline+0xa5>
			if (echoing)
f010162a:	85 ff                	test   %edi,%edi
f010162c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101630:	74 08                	je     f010163a <readline+0x9a>
				cputchar(c);
f0101632:	89 1c 24             	mov    %ebx,(%esp)
f0101635:	e8 20 ef ff ff       	call   f010055a <cputchar>
			buf[i++] = c;
f010163a:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f0101640:	83 c6 01             	add    $0x1,%esi
f0101643:	eb 8e                	jmp    f01015d3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0101645:	83 fb 0a             	cmp    $0xa,%ebx
f0101648:	74 05                	je     f010164f <readline+0xaf>
f010164a:	83 fb 0d             	cmp    $0xd,%ebx
f010164d:	75 84                	jne    f01015d3 <readline+0x33>
			if (echoing)
f010164f:	85 ff                	test   %edi,%edi
f0101651:	74 0c                	je     f010165f <readline+0xbf>
				cputchar('\n');
f0101653:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f010165a:	e8 fb ee ff ff       	call   f010055a <cputchar>
			buf[i] = 0;
f010165f:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
f0101666:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
			return buf;
		}
	}
}
f010166b:	83 c4 1c             	add    $0x1c,%esp
f010166e:	5b                   	pop    %ebx
f010166f:	5e                   	pop    %esi
f0101670:	5f                   	pop    %edi
f0101671:	5d                   	pop    %ebp
f0101672:	c3                   	ret    
	...

f0101680 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101680:	55                   	push   %ebp
f0101681:	89 e5                	mov    %esp,%ebp
f0101683:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101686:	b8 00 00 00 00       	mov    $0x0,%eax
f010168b:	80 3a 00             	cmpb   $0x0,(%edx)
f010168e:	74 09                	je     f0101699 <strlen+0x19>
		n++;
f0101690:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101693:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101697:	75 f7                	jne    f0101690 <strlen+0x10>
		n++;
	return n;
}
f0101699:	5d                   	pop    %ebp
f010169a:	c3                   	ret    

f010169b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010169b:	55                   	push   %ebp
f010169c:	89 e5                	mov    %esp,%ebp
f010169e:	53                   	push   %ebx
f010169f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01016a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01016a5:	85 c9                	test   %ecx,%ecx
f01016a7:	74 19                	je     f01016c2 <strnlen+0x27>
f01016a9:	80 3b 00             	cmpb   $0x0,(%ebx)
f01016ac:	74 14                	je     f01016c2 <strnlen+0x27>
f01016ae:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01016b3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01016b6:	39 c8                	cmp    %ecx,%eax
f01016b8:	74 0d                	je     f01016c7 <strnlen+0x2c>
f01016ba:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f01016be:	75 f3                	jne    f01016b3 <strnlen+0x18>
f01016c0:	eb 05                	jmp    f01016c7 <strnlen+0x2c>
f01016c2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01016c7:	5b                   	pop    %ebx
f01016c8:	5d                   	pop    %ebp
f01016c9:	c3                   	ret    

f01016ca <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01016ca:	55                   	push   %ebp
f01016cb:	89 e5                	mov    %esp,%ebp
f01016cd:	53                   	push   %ebx
f01016ce:	8b 45 08             	mov    0x8(%ebp),%eax
f01016d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01016d4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01016d9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01016dd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01016e0:	83 c2 01             	add    $0x1,%edx
f01016e3:	84 c9                	test   %cl,%cl
f01016e5:	75 f2                	jne    f01016d9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01016e7:	5b                   	pop    %ebx
f01016e8:	5d                   	pop    %ebp
f01016e9:	c3                   	ret    

f01016ea <strcat>:

char *
strcat(char *dst, const char *src)
{
f01016ea:	55                   	push   %ebp
f01016eb:	89 e5                	mov    %esp,%ebp
f01016ed:	53                   	push   %ebx
f01016ee:	83 ec 08             	sub    $0x8,%esp
f01016f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01016f4:	89 1c 24             	mov    %ebx,(%esp)
f01016f7:	e8 84 ff ff ff       	call   f0101680 <strlen>
	strcpy(dst + len, src);
f01016fc:	8b 55 0c             	mov    0xc(%ebp),%edx
f01016ff:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101703:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0101706:	89 04 24             	mov    %eax,(%esp)
f0101709:	e8 bc ff ff ff       	call   f01016ca <strcpy>
	return dst;
}
f010170e:	89 d8                	mov    %ebx,%eax
f0101710:	83 c4 08             	add    $0x8,%esp
f0101713:	5b                   	pop    %ebx
f0101714:	5d                   	pop    %ebp
f0101715:	c3                   	ret    

f0101716 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101716:	55                   	push   %ebp
f0101717:	89 e5                	mov    %esp,%ebp
f0101719:	56                   	push   %esi
f010171a:	53                   	push   %ebx
f010171b:	8b 45 08             	mov    0x8(%ebp),%eax
f010171e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101721:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101724:	85 f6                	test   %esi,%esi
f0101726:	74 18                	je     f0101740 <strncpy+0x2a>
f0101728:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f010172d:	0f b6 1a             	movzbl (%edx),%ebx
f0101730:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101733:	80 3a 01             	cmpb   $0x1,(%edx)
f0101736:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101739:	83 c1 01             	add    $0x1,%ecx
f010173c:	39 ce                	cmp    %ecx,%esi
f010173e:	77 ed                	ja     f010172d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101740:	5b                   	pop    %ebx
f0101741:	5e                   	pop    %esi
f0101742:	5d                   	pop    %ebp
f0101743:	c3                   	ret    

f0101744 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101744:	55                   	push   %ebp
f0101745:	89 e5                	mov    %esp,%ebp
f0101747:	56                   	push   %esi
f0101748:	53                   	push   %ebx
f0101749:	8b 75 08             	mov    0x8(%ebp),%esi
f010174c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010174f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101752:	89 f0                	mov    %esi,%eax
f0101754:	85 c9                	test   %ecx,%ecx
f0101756:	74 27                	je     f010177f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
f0101758:	83 e9 01             	sub    $0x1,%ecx
f010175b:	74 1d                	je     f010177a <strlcpy+0x36>
f010175d:	0f b6 1a             	movzbl (%edx),%ebx
f0101760:	84 db                	test   %bl,%bl
f0101762:	74 16                	je     f010177a <strlcpy+0x36>
			*dst++ = *src++;
f0101764:	88 18                	mov    %bl,(%eax)
f0101766:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101769:	83 e9 01             	sub    $0x1,%ecx
f010176c:	74 0e                	je     f010177c <strlcpy+0x38>
			*dst++ = *src++;
f010176e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101771:	0f b6 1a             	movzbl (%edx),%ebx
f0101774:	84 db                	test   %bl,%bl
f0101776:	75 ec                	jne    f0101764 <strlcpy+0x20>
f0101778:	eb 02                	jmp    f010177c <strlcpy+0x38>
f010177a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f010177c:	c6 00 00             	movb   $0x0,(%eax)
f010177f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f0101781:	5b                   	pop    %ebx
f0101782:	5e                   	pop    %esi
f0101783:	5d                   	pop    %ebp
f0101784:	c3                   	ret    

f0101785 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101785:	55                   	push   %ebp
f0101786:	89 e5                	mov    %esp,%ebp
f0101788:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010178b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010178e:	0f b6 01             	movzbl (%ecx),%eax
f0101791:	84 c0                	test   %al,%al
f0101793:	74 15                	je     f01017aa <strcmp+0x25>
f0101795:	3a 02                	cmp    (%edx),%al
f0101797:	75 11                	jne    f01017aa <strcmp+0x25>
		p++, q++;
f0101799:	83 c1 01             	add    $0x1,%ecx
f010179c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010179f:	0f b6 01             	movzbl (%ecx),%eax
f01017a2:	84 c0                	test   %al,%al
f01017a4:	74 04                	je     f01017aa <strcmp+0x25>
f01017a6:	3a 02                	cmp    (%edx),%al
f01017a8:	74 ef                	je     f0101799 <strcmp+0x14>
f01017aa:	0f b6 c0             	movzbl %al,%eax
f01017ad:	0f b6 12             	movzbl (%edx),%edx
f01017b0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01017b2:	5d                   	pop    %ebp
f01017b3:	c3                   	ret    

f01017b4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01017b4:	55                   	push   %ebp
f01017b5:	89 e5                	mov    %esp,%ebp
f01017b7:	53                   	push   %ebx
f01017b8:	8b 55 08             	mov    0x8(%ebp),%edx
f01017bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01017be:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f01017c1:	85 c0                	test   %eax,%eax
f01017c3:	74 23                	je     f01017e8 <strncmp+0x34>
f01017c5:	0f b6 1a             	movzbl (%edx),%ebx
f01017c8:	84 db                	test   %bl,%bl
f01017ca:	74 25                	je     f01017f1 <strncmp+0x3d>
f01017cc:	3a 19                	cmp    (%ecx),%bl
f01017ce:	75 21                	jne    f01017f1 <strncmp+0x3d>
f01017d0:	83 e8 01             	sub    $0x1,%eax
f01017d3:	74 13                	je     f01017e8 <strncmp+0x34>
		n--, p++, q++;
f01017d5:	83 c2 01             	add    $0x1,%edx
f01017d8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01017db:	0f b6 1a             	movzbl (%edx),%ebx
f01017de:	84 db                	test   %bl,%bl
f01017e0:	74 0f                	je     f01017f1 <strncmp+0x3d>
f01017e2:	3a 19                	cmp    (%ecx),%bl
f01017e4:	74 ea                	je     f01017d0 <strncmp+0x1c>
f01017e6:	eb 09                	jmp    f01017f1 <strncmp+0x3d>
f01017e8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01017ed:	5b                   	pop    %ebx
f01017ee:	5d                   	pop    %ebp
f01017ef:	90                   	nop
f01017f0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01017f1:	0f b6 02             	movzbl (%edx),%eax
f01017f4:	0f b6 11             	movzbl (%ecx),%edx
f01017f7:	29 d0                	sub    %edx,%eax
f01017f9:	eb f2                	jmp    f01017ed <strncmp+0x39>

f01017fb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01017fb:	55                   	push   %ebp
f01017fc:	89 e5                	mov    %esp,%ebp
f01017fe:	8b 45 08             	mov    0x8(%ebp),%eax
f0101801:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101805:	0f b6 10             	movzbl (%eax),%edx
f0101808:	84 d2                	test   %dl,%dl
f010180a:	74 18                	je     f0101824 <strchr+0x29>
		if (*s == c)
f010180c:	38 ca                	cmp    %cl,%dl
f010180e:	75 0a                	jne    f010181a <strchr+0x1f>
f0101810:	eb 17                	jmp    f0101829 <strchr+0x2e>
f0101812:	38 ca                	cmp    %cl,%dl
f0101814:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101818:	74 0f                	je     f0101829 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010181a:	83 c0 01             	add    $0x1,%eax
f010181d:	0f b6 10             	movzbl (%eax),%edx
f0101820:	84 d2                	test   %dl,%dl
f0101822:	75 ee                	jne    f0101812 <strchr+0x17>
f0101824:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f0101829:	5d                   	pop    %ebp
f010182a:	c3                   	ret    

f010182b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010182b:	55                   	push   %ebp
f010182c:	89 e5                	mov    %esp,%ebp
f010182e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101831:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101835:	0f b6 10             	movzbl (%eax),%edx
f0101838:	84 d2                	test   %dl,%dl
f010183a:	74 18                	je     f0101854 <strfind+0x29>
		if (*s == c)
f010183c:	38 ca                	cmp    %cl,%dl
f010183e:	75 0a                	jne    f010184a <strfind+0x1f>
f0101840:	eb 12                	jmp    f0101854 <strfind+0x29>
f0101842:	38 ca                	cmp    %cl,%dl
f0101844:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101848:	74 0a                	je     f0101854 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010184a:	83 c0 01             	add    $0x1,%eax
f010184d:	0f b6 10             	movzbl (%eax),%edx
f0101850:	84 d2                	test   %dl,%dl
f0101852:	75 ee                	jne    f0101842 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0101854:	5d                   	pop    %ebp
f0101855:	c3                   	ret    

f0101856 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101856:	55                   	push   %ebp
f0101857:	89 e5                	mov    %esp,%ebp
f0101859:	83 ec 0c             	sub    $0xc,%esp
f010185c:	89 1c 24             	mov    %ebx,(%esp)
f010185f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101863:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101867:	8b 7d 08             	mov    0x8(%ebp),%edi
f010186a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010186d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101870:	85 c9                	test   %ecx,%ecx
f0101872:	74 30                	je     f01018a4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101874:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010187a:	75 25                	jne    f01018a1 <memset+0x4b>
f010187c:	f6 c1 03             	test   $0x3,%cl
f010187f:	75 20                	jne    f01018a1 <memset+0x4b>
		c &= 0xFF;
f0101881:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101884:	89 d3                	mov    %edx,%ebx
f0101886:	c1 e3 08             	shl    $0x8,%ebx
f0101889:	89 d6                	mov    %edx,%esi
f010188b:	c1 e6 18             	shl    $0x18,%esi
f010188e:	89 d0                	mov    %edx,%eax
f0101890:	c1 e0 10             	shl    $0x10,%eax
f0101893:	09 f0                	or     %esi,%eax
f0101895:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
f0101897:	09 d8                	or     %ebx,%eax
f0101899:	c1 e9 02             	shr    $0x2,%ecx
f010189c:	fc                   	cld    
f010189d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010189f:	eb 03                	jmp    f01018a4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01018a1:	fc                   	cld    
f01018a2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01018a4:	89 f8                	mov    %edi,%eax
f01018a6:	8b 1c 24             	mov    (%esp),%ebx
f01018a9:	8b 74 24 04          	mov    0x4(%esp),%esi
f01018ad:	8b 7c 24 08          	mov    0x8(%esp),%edi
f01018b1:	89 ec                	mov    %ebp,%esp
f01018b3:	5d                   	pop    %ebp
f01018b4:	c3                   	ret    

f01018b5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01018b5:	55                   	push   %ebp
f01018b6:	89 e5                	mov    %esp,%ebp
f01018b8:	83 ec 08             	sub    $0x8,%esp
f01018bb:	89 34 24             	mov    %esi,(%esp)
f01018be:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01018c2:	8b 45 08             	mov    0x8(%ebp),%eax
f01018c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
f01018c8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
f01018cb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
f01018cd:	39 c6                	cmp    %eax,%esi
f01018cf:	73 35                	jae    f0101906 <memmove+0x51>
f01018d1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01018d4:	39 d0                	cmp    %edx,%eax
f01018d6:	73 2e                	jae    f0101906 <memmove+0x51>
		s += n;
		d += n;
f01018d8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01018da:	f6 c2 03             	test   $0x3,%dl
f01018dd:	75 1b                	jne    f01018fa <memmove+0x45>
f01018df:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01018e5:	75 13                	jne    f01018fa <memmove+0x45>
f01018e7:	f6 c1 03             	test   $0x3,%cl
f01018ea:	75 0e                	jne    f01018fa <memmove+0x45>
			asm volatile("std; rep movsl\n"
f01018ec:	83 ef 04             	sub    $0x4,%edi
f01018ef:	8d 72 fc             	lea    -0x4(%edx),%esi
f01018f2:	c1 e9 02             	shr    $0x2,%ecx
f01018f5:	fd                   	std    
f01018f6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01018f8:	eb 09                	jmp    f0101903 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01018fa:	83 ef 01             	sub    $0x1,%edi
f01018fd:	8d 72 ff             	lea    -0x1(%edx),%esi
f0101900:	fd                   	std    
f0101901:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101903:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101904:	eb 20                	jmp    f0101926 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101906:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010190c:	75 15                	jne    f0101923 <memmove+0x6e>
f010190e:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101914:	75 0d                	jne    f0101923 <memmove+0x6e>
f0101916:	f6 c1 03             	test   $0x3,%cl
f0101919:	75 08                	jne    f0101923 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
f010191b:	c1 e9 02             	shr    $0x2,%ecx
f010191e:	fc                   	cld    
f010191f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101921:	eb 03                	jmp    f0101926 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101923:	fc                   	cld    
f0101924:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101926:	8b 34 24             	mov    (%esp),%esi
f0101929:	8b 7c 24 04          	mov    0x4(%esp),%edi
f010192d:	89 ec                	mov    %ebp,%esp
f010192f:	5d                   	pop    %ebp
f0101930:	c3                   	ret    

f0101931 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101931:	55                   	push   %ebp
f0101932:	89 e5                	mov    %esp,%ebp
f0101934:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0101937:	8b 45 10             	mov    0x10(%ebp),%eax
f010193a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010193e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101941:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101945:	8b 45 08             	mov    0x8(%ebp),%eax
f0101948:	89 04 24             	mov    %eax,(%esp)
f010194b:	e8 65 ff ff ff       	call   f01018b5 <memmove>
}
f0101950:	c9                   	leave  
f0101951:	c3                   	ret    

f0101952 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101952:	55                   	push   %ebp
f0101953:	89 e5                	mov    %esp,%ebp
f0101955:	57                   	push   %edi
f0101956:	56                   	push   %esi
f0101957:	53                   	push   %ebx
f0101958:	8b 75 08             	mov    0x8(%ebp),%esi
f010195b:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010195e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101961:	85 c9                	test   %ecx,%ecx
f0101963:	74 36                	je     f010199b <memcmp+0x49>
		if (*s1 != *s2)
f0101965:	0f b6 06             	movzbl (%esi),%eax
f0101968:	0f b6 1f             	movzbl (%edi),%ebx
f010196b:	38 d8                	cmp    %bl,%al
f010196d:	74 20                	je     f010198f <memcmp+0x3d>
f010196f:	eb 14                	jmp    f0101985 <memcmp+0x33>
f0101971:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
f0101976:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
f010197b:	83 c2 01             	add    $0x1,%edx
f010197e:	83 e9 01             	sub    $0x1,%ecx
f0101981:	38 d8                	cmp    %bl,%al
f0101983:	74 12                	je     f0101997 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
f0101985:	0f b6 c0             	movzbl %al,%eax
f0101988:	0f b6 db             	movzbl %bl,%ebx
f010198b:	29 d8                	sub    %ebx,%eax
f010198d:	eb 11                	jmp    f01019a0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010198f:	83 e9 01             	sub    $0x1,%ecx
f0101992:	ba 00 00 00 00       	mov    $0x0,%edx
f0101997:	85 c9                	test   %ecx,%ecx
f0101999:	75 d6                	jne    f0101971 <memcmp+0x1f>
f010199b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f01019a0:	5b                   	pop    %ebx
f01019a1:	5e                   	pop    %esi
f01019a2:	5f                   	pop    %edi
f01019a3:	5d                   	pop    %ebp
f01019a4:	c3                   	ret    

f01019a5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01019a5:	55                   	push   %ebp
f01019a6:	89 e5                	mov    %esp,%ebp
f01019a8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01019ab:	89 c2                	mov    %eax,%edx
f01019ad:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01019b0:	39 d0                	cmp    %edx,%eax
f01019b2:	73 15                	jae    f01019c9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f01019b4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f01019b8:	38 08                	cmp    %cl,(%eax)
f01019ba:	75 06                	jne    f01019c2 <memfind+0x1d>
f01019bc:	eb 0b                	jmp    f01019c9 <memfind+0x24>
f01019be:	38 08                	cmp    %cl,(%eax)
f01019c0:	74 07                	je     f01019c9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01019c2:	83 c0 01             	add    $0x1,%eax
f01019c5:	39 c2                	cmp    %eax,%edx
f01019c7:	77 f5                	ja     f01019be <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01019c9:	5d                   	pop    %ebp
f01019ca:	c3                   	ret    

f01019cb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01019cb:	55                   	push   %ebp
f01019cc:	89 e5                	mov    %esp,%ebp
f01019ce:	57                   	push   %edi
f01019cf:	56                   	push   %esi
f01019d0:	53                   	push   %ebx
f01019d1:	83 ec 04             	sub    $0x4,%esp
f01019d4:	8b 55 08             	mov    0x8(%ebp),%edx
f01019d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01019da:	0f b6 02             	movzbl (%edx),%eax
f01019dd:	3c 20                	cmp    $0x20,%al
f01019df:	74 04                	je     f01019e5 <strtol+0x1a>
f01019e1:	3c 09                	cmp    $0x9,%al
f01019e3:	75 0e                	jne    f01019f3 <strtol+0x28>
		s++;
f01019e5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01019e8:	0f b6 02             	movzbl (%edx),%eax
f01019eb:	3c 20                	cmp    $0x20,%al
f01019ed:	74 f6                	je     f01019e5 <strtol+0x1a>
f01019ef:	3c 09                	cmp    $0x9,%al
f01019f1:	74 f2                	je     f01019e5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f01019f3:	3c 2b                	cmp    $0x2b,%al
f01019f5:	75 0c                	jne    f0101a03 <strtol+0x38>
		s++;
f01019f7:	83 c2 01             	add    $0x1,%edx
f01019fa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0101a01:	eb 15                	jmp    f0101a18 <strtol+0x4d>
	else if (*s == '-')
f0101a03:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0101a0a:	3c 2d                	cmp    $0x2d,%al
f0101a0c:	75 0a                	jne    f0101a18 <strtol+0x4d>
		s++, neg = 1;
f0101a0e:	83 c2 01             	add    $0x1,%edx
f0101a11:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101a18:	85 db                	test   %ebx,%ebx
f0101a1a:	0f 94 c0             	sete   %al
f0101a1d:	74 05                	je     f0101a24 <strtol+0x59>
f0101a1f:	83 fb 10             	cmp    $0x10,%ebx
f0101a22:	75 18                	jne    f0101a3c <strtol+0x71>
f0101a24:	80 3a 30             	cmpb   $0x30,(%edx)
f0101a27:	75 13                	jne    f0101a3c <strtol+0x71>
f0101a29:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0101a2d:	8d 76 00             	lea    0x0(%esi),%esi
f0101a30:	75 0a                	jne    f0101a3c <strtol+0x71>
		s += 2, base = 16;
f0101a32:	83 c2 02             	add    $0x2,%edx
f0101a35:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101a3a:	eb 15                	jmp    f0101a51 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101a3c:	84 c0                	test   %al,%al
f0101a3e:	66 90                	xchg   %ax,%ax
f0101a40:	74 0f                	je     f0101a51 <strtol+0x86>
f0101a42:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0101a47:	80 3a 30             	cmpb   $0x30,(%edx)
f0101a4a:	75 05                	jne    f0101a51 <strtol+0x86>
		s++, base = 8;
f0101a4c:	83 c2 01             	add    $0x1,%edx
f0101a4f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101a51:	b8 00 00 00 00       	mov    $0x0,%eax
f0101a56:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101a58:	0f b6 0a             	movzbl (%edx),%ecx
f0101a5b:	89 cf                	mov    %ecx,%edi
f0101a5d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0101a60:	80 fb 09             	cmp    $0x9,%bl
f0101a63:	77 08                	ja     f0101a6d <strtol+0xa2>
			dig = *s - '0';
f0101a65:	0f be c9             	movsbl %cl,%ecx
f0101a68:	83 e9 30             	sub    $0x30,%ecx
f0101a6b:	eb 1e                	jmp    f0101a8b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
f0101a6d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
f0101a70:	80 fb 19             	cmp    $0x19,%bl
f0101a73:	77 08                	ja     f0101a7d <strtol+0xb2>
			dig = *s - 'a' + 10;
f0101a75:	0f be c9             	movsbl %cl,%ecx
f0101a78:	83 e9 57             	sub    $0x57,%ecx
f0101a7b:	eb 0e                	jmp    f0101a8b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
f0101a7d:	8d 5f bf             	lea    -0x41(%edi),%ebx
f0101a80:	80 fb 19             	cmp    $0x19,%bl
f0101a83:	77 15                	ja     f0101a9a <strtol+0xcf>
			dig = *s - 'A' + 10;
f0101a85:	0f be c9             	movsbl %cl,%ecx
f0101a88:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0101a8b:	39 f1                	cmp    %esi,%ecx
f0101a8d:	7d 0b                	jge    f0101a9a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
f0101a8f:	83 c2 01             	add    $0x1,%edx
f0101a92:	0f af c6             	imul   %esi,%eax
f0101a95:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0101a98:	eb be                	jmp    f0101a58 <strtol+0x8d>
f0101a9a:	89 c1                	mov    %eax,%ecx

	if (endptr)
f0101a9c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101aa0:	74 05                	je     f0101aa7 <strtol+0xdc>
		*endptr = (char *) s;
f0101aa2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101aa5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0101aa7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0101aab:	74 04                	je     f0101ab1 <strtol+0xe6>
f0101aad:	89 c8                	mov    %ecx,%eax
f0101aaf:	f7 d8                	neg    %eax
}
f0101ab1:	83 c4 04             	add    $0x4,%esp
f0101ab4:	5b                   	pop    %ebx
f0101ab5:	5e                   	pop    %esi
f0101ab6:	5f                   	pop    %edi
f0101ab7:	5d                   	pop    %ebp
f0101ab8:	c3                   	ret    
f0101ab9:	00 00                	add    %al,(%eax)
f0101abb:	00 00                	add    %al,(%eax)
f0101abd:	00 00                	add    %al,(%eax)
	...

f0101ac0 <__udivdi3>:
f0101ac0:	55                   	push   %ebp
f0101ac1:	89 e5                	mov    %esp,%ebp
f0101ac3:	57                   	push   %edi
f0101ac4:	56                   	push   %esi
f0101ac5:	83 ec 10             	sub    $0x10,%esp
f0101ac8:	8b 45 14             	mov    0x14(%ebp),%eax
f0101acb:	8b 55 08             	mov    0x8(%ebp),%edx
f0101ace:	8b 75 10             	mov    0x10(%ebp),%esi
f0101ad1:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101ad4:	85 c0                	test   %eax,%eax
f0101ad6:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0101ad9:	75 35                	jne    f0101b10 <__udivdi3+0x50>
f0101adb:	39 fe                	cmp    %edi,%esi
f0101add:	77 61                	ja     f0101b40 <__udivdi3+0x80>
f0101adf:	85 f6                	test   %esi,%esi
f0101ae1:	75 0b                	jne    f0101aee <__udivdi3+0x2e>
f0101ae3:	b8 01 00 00 00       	mov    $0x1,%eax
f0101ae8:	31 d2                	xor    %edx,%edx
f0101aea:	f7 f6                	div    %esi
f0101aec:	89 c6                	mov    %eax,%esi
f0101aee:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0101af1:	31 d2                	xor    %edx,%edx
f0101af3:	89 f8                	mov    %edi,%eax
f0101af5:	f7 f6                	div    %esi
f0101af7:	89 c7                	mov    %eax,%edi
f0101af9:	89 c8                	mov    %ecx,%eax
f0101afb:	f7 f6                	div    %esi
f0101afd:	89 c1                	mov    %eax,%ecx
f0101aff:	89 fa                	mov    %edi,%edx
f0101b01:	89 c8                	mov    %ecx,%eax
f0101b03:	83 c4 10             	add    $0x10,%esp
f0101b06:	5e                   	pop    %esi
f0101b07:	5f                   	pop    %edi
f0101b08:	5d                   	pop    %ebp
f0101b09:	c3                   	ret    
f0101b0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101b10:	39 f8                	cmp    %edi,%eax
f0101b12:	77 1c                	ja     f0101b30 <__udivdi3+0x70>
f0101b14:	0f bd d0             	bsr    %eax,%edx
f0101b17:	83 f2 1f             	xor    $0x1f,%edx
f0101b1a:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0101b1d:	75 39                	jne    f0101b58 <__udivdi3+0x98>
f0101b1f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0101b22:	0f 86 a0 00 00 00    	jbe    f0101bc8 <__udivdi3+0x108>
f0101b28:	39 f8                	cmp    %edi,%eax
f0101b2a:	0f 82 98 00 00 00    	jb     f0101bc8 <__udivdi3+0x108>
f0101b30:	31 ff                	xor    %edi,%edi
f0101b32:	31 c9                	xor    %ecx,%ecx
f0101b34:	89 c8                	mov    %ecx,%eax
f0101b36:	89 fa                	mov    %edi,%edx
f0101b38:	83 c4 10             	add    $0x10,%esp
f0101b3b:	5e                   	pop    %esi
f0101b3c:	5f                   	pop    %edi
f0101b3d:	5d                   	pop    %ebp
f0101b3e:	c3                   	ret    
f0101b3f:	90                   	nop
f0101b40:	89 d1                	mov    %edx,%ecx
f0101b42:	89 fa                	mov    %edi,%edx
f0101b44:	89 c8                	mov    %ecx,%eax
f0101b46:	31 ff                	xor    %edi,%edi
f0101b48:	f7 f6                	div    %esi
f0101b4a:	89 c1                	mov    %eax,%ecx
f0101b4c:	89 fa                	mov    %edi,%edx
f0101b4e:	89 c8                	mov    %ecx,%eax
f0101b50:	83 c4 10             	add    $0x10,%esp
f0101b53:	5e                   	pop    %esi
f0101b54:	5f                   	pop    %edi
f0101b55:	5d                   	pop    %ebp
f0101b56:	c3                   	ret    
f0101b57:	90                   	nop
f0101b58:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0101b5c:	89 f2                	mov    %esi,%edx
f0101b5e:	d3 e0                	shl    %cl,%eax
f0101b60:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101b63:	b8 20 00 00 00       	mov    $0x20,%eax
f0101b68:	2b 45 f4             	sub    -0xc(%ebp),%eax
f0101b6b:	89 c1                	mov    %eax,%ecx
f0101b6d:	d3 ea                	shr    %cl,%edx
f0101b6f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0101b73:	0b 55 ec             	or     -0x14(%ebp),%edx
f0101b76:	d3 e6                	shl    %cl,%esi
f0101b78:	89 c1                	mov    %eax,%ecx
f0101b7a:	89 75 e8             	mov    %esi,-0x18(%ebp)
f0101b7d:	89 fe                	mov    %edi,%esi
f0101b7f:	d3 ee                	shr    %cl,%esi
f0101b81:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0101b85:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101b88:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0101b8b:	d3 e7                	shl    %cl,%edi
f0101b8d:	89 c1                	mov    %eax,%ecx
f0101b8f:	d3 ea                	shr    %cl,%edx
f0101b91:	09 d7                	or     %edx,%edi
f0101b93:	89 f2                	mov    %esi,%edx
f0101b95:	89 f8                	mov    %edi,%eax
f0101b97:	f7 75 ec             	divl   -0x14(%ebp)
f0101b9a:	89 d6                	mov    %edx,%esi
f0101b9c:	89 c7                	mov    %eax,%edi
f0101b9e:	f7 65 e8             	mull   -0x18(%ebp)
f0101ba1:	39 d6                	cmp    %edx,%esi
f0101ba3:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101ba6:	72 30                	jb     f0101bd8 <__udivdi3+0x118>
f0101ba8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0101bab:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0101baf:	d3 e2                	shl    %cl,%edx
f0101bb1:	39 c2                	cmp    %eax,%edx
f0101bb3:	73 05                	jae    f0101bba <__udivdi3+0xfa>
f0101bb5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f0101bb8:	74 1e                	je     f0101bd8 <__udivdi3+0x118>
f0101bba:	89 f9                	mov    %edi,%ecx
f0101bbc:	31 ff                	xor    %edi,%edi
f0101bbe:	e9 71 ff ff ff       	jmp    f0101b34 <__udivdi3+0x74>
f0101bc3:	90                   	nop
f0101bc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101bc8:	31 ff                	xor    %edi,%edi
f0101bca:	b9 01 00 00 00       	mov    $0x1,%ecx
f0101bcf:	e9 60 ff ff ff       	jmp    f0101b34 <__udivdi3+0x74>
f0101bd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101bd8:	8d 4f ff             	lea    -0x1(%edi),%ecx
f0101bdb:	31 ff                	xor    %edi,%edi
f0101bdd:	89 c8                	mov    %ecx,%eax
f0101bdf:	89 fa                	mov    %edi,%edx
f0101be1:	83 c4 10             	add    $0x10,%esp
f0101be4:	5e                   	pop    %esi
f0101be5:	5f                   	pop    %edi
f0101be6:	5d                   	pop    %ebp
f0101be7:	c3                   	ret    
	...

f0101bf0 <__umoddi3>:
f0101bf0:	55                   	push   %ebp
f0101bf1:	89 e5                	mov    %esp,%ebp
f0101bf3:	57                   	push   %edi
f0101bf4:	56                   	push   %esi
f0101bf5:	83 ec 20             	sub    $0x20,%esp
f0101bf8:	8b 55 14             	mov    0x14(%ebp),%edx
f0101bfb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101bfe:	8b 7d 10             	mov    0x10(%ebp),%edi
f0101c01:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101c04:	85 d2                	test   %edx,%edx
f0101c06:	89 c8                	mov    %ecx,%eax
f0101c08:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0101c0b:	75 13                	jne    f0101c20 <__umoddi3+0x30>
f0101c0d:	39 f7                	cmp    %esi,%edi
f0101c0f:	76 3f                	jbe    f0101c50 <__umoddi3+0x60>
f0101c11:	89 f2                	mov    %esi,%edx
f0101c13:	f7 f7                	div    %edi
f0101c15:	89 d0                	mov    %edx,%eax
f0101c17:	31 d2                	xor    %edx,%edx
f0101c19:	83 c4 20             	add    $0x20,%esp
f0101c1c:	5e                   	pop    %esi
f0101c1d:	5f                   	pop    %edi
f0101c1e:	5d                   	pop    %ebp
f0101c1f:	c3                   	ret    
f0101c20:	39 f2                	cmp    %esi,%edx
f0101c22:	77 4c                	ja     f0101c70 <__umoddi3+0x80>
f0101c24:	0f bd ca             	bsr    %edx,%ecx
f0101c27:	83 f1 1f             	xor    $0x1f,%ecx
f0101c2a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101c2d:	75 51                	jne    f0101c80 <__umoddi3+0x90>
f0101c2f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
f0101c32:	0f 87 e0 00 00 00    	ja     f0101d18 <__umoddi3+0x128>
f0101c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101c3b:	29 f8                	sub    %edi,%eax
f0101c3d:	19 d6                	sbb    %edx,%esi
f0101c3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101c45:	89 f2                	mov    %esi,%edx
f0101c47:	83 c4 20             	add    $0x20,%esp
f0101c4a:	5e                   	pop    %esi
f0101c4b:	5f                   	pop    %edi
f0101c4c:	5d                   	pop    %ebp
f0101c4d:	c3                   	ret    
f0101c4e:	66 90                	xchg   %ax,%ax
f0101c50:	85 ff                	test   %edi,%edi
f0101c52:	75 0b                	jne    f0101c5f <__umoddi3+0x6f>
f0101c54:	b8 01 00 00 00       	mov    $0x1,%eax
f0101c59:	31 d2                	xor    %edx,%edx
f0101c5b:	f7 f7                	div    %edi
f0101c5d:	89 c7                	mov    %eax,%edi
f0101c5f:	89 f0                	mov    %esi,%eax
f0101c61:	31 d2                	xor    %edx,%edx
f0101c63:	f7 f7                	div    %edi
f0101c65:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101c68:	f7 f7                	div    %edi
f0101c6a:	eb a9                	jmp    f0101c15 <__umoddi3+0x25>
f0101c6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101c70:	89 c8                	mov    %ecx,%eax
f0101c72:	89 f2                	mov    %esi,%edx
f0101c74:	83 c4 20             	add    $0x20,%esp
f0101c77:	5e                   	pop    %esi
f0101c78:	5f                   	pop    %edi
f0101c79:	5d                   	pop    %ebp
f0101c7a:	c3                   	ret    
f0101c7b:	90                   	nop
f0101c7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101c80:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101c84:	d3 e2                	shl    %cl,%edx
f0101c86:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0101c89:	ba 20 00 00 00       	mov    $0x20,%edx
f0101c8e:	2b 55 f0             	sub    -0x10(%ebp),%edx
f0101c91:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101c94:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101c98:	89 fa                	mov    %edi,%edx
f0101c9a:	d3 ea                	shr    %cl,%edx
f0101c9c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101ca0:	0b 55 f4             	or     -0xc(%ebp),%edx
f0101ca3:	d3 e7                	shl    %cl,%edi
f0101ca5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101ca9:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0101cac:	89 f2                	mov    %esi,%edx
f0101cae:	89 7d e8             	mov    %edi,-0x18(%ebp)
f0101cb1:	89 c7                	mov    %eax,%edi
f0101cb3:	d3 ea                	shr    %cl,%edx
f0101cb5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101cb9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101cbc:	89 c2                	mov    %eax,%edx
f0101cbe:	d3 e6                	shl    %cl,%esi
f0101cc0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101cc4:	d3 ea                	shr    %cl,%edx
f0101cc6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101cca:	09 d6                	or     %edx,%esi
f0101ccc:	89 f0                	mov    %esi,%eax
f0101cce:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0101cd1:	d3 e7                	shl    %cl,%edi
f0101cd3:	89 f2                	mov    %esi,%edx
f0101cd5:	f7 75 f4             	divl   -0xc(%ebp)
f0101cd8:	89 d6                	mov    %edx,%esi
f0101cda:	f7 65 e8             	mull   -0x18(%ebp)
f0101cdd:	39 d6                	cmp    %edx,%esi
f0101cdf:	72 2b                	jb     f0101d0c <__umoddi3+0x11c>
f0101ce1:	39 c7                	cmp    %eax,%edi
f0101ce3:	72 23                	jb     f0101d08 <__umoddi3+0x118>
f0101ce5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101ce9:	29 c7                	sub    %eax,%edi
f0101ceb:	19 d6                	sbb    %edx,%esi
f0101ced:	89 f0                	mov    %esi,%eax
f0101cef:	89 f2                	mov    %esi,%edx
f0101cf1:	d3 ef                	shr    %cl,%edi
f0101cf3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101cf7:	d3 e0                	shl    %cl,%eax
f0101cf9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101cfd:	09 f8                	or     %edi,%eax
f0101cff:	d3 ea                	shr    %cl,%edx
f0101d01:	83 c4 20             	add    $0x20,%esp
f0101d04:	5e                   	pop    %esi
f0101d05:	5f                   	pop    %edi
f0101d06:	5d                   	pop    %ebp
f0101d07:	c3                   	ret    
f0101d08:	39 d6                	cmp    %edx,%esi
f0101d0a:	75 d9                	jne    f0101ce5 <__umoddi3+0xf5>
f0101d0c:	2b 45 e8             	sub    -0x18(%ebp),%eax
f0101d0f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f0101d12:	eb d1                	jmp    f0101ce5 <__umoddi3+0xf5>
f0101d14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101d18:	39 f2                	cmp    %esi,%edx
f0101d1a:	0f 82 18 ff ff ff    	jb     f0101c38 <__umoddi3+0x48>
f0101d20:	e9 1d ff ff ff       	jmp    f0101c42 <__umoddi3+0x52>
