// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>

#define CMDBUF_SIZE	80	// enough for one VGA text line


struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
};
#define NCOMMANDS (sizeof(commands)/sizeof(commands[0]))

unsigned read_eip();
void corruptStack(unsigned int value, char * point);
/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	uintptr_t eipget = read_eip();
	unsigned int ebpget = read_ebp();
	unsigned int espget = read_esp();
	int count=0;
	int * ebpzero=0;
	int * ebptwo=0;
	unsigned int ebpfive=0;
	while (ebpget != 0){
		
	    	cprintf("ebp %x  eip %x args %08x %08x %08x %08x %08x\n", ebpget,*(int *)(ebpget + 4) , *(int *)(ebpget + 8), *(int *)(ebpget + 12), *(int *)(ebpget + 16), *(int *)(ebpget + 20), *(int *)(ebpget + 24));
	
		struct Eipdebuginfo eip_info;

		int inforet = debuginfo_eip( eipget, &eip_info);

		if (inforet == 0){
		
			char *fn_name = "";
		
			strncpy(fn_name, eip_info.eip_fn_name, eip_info.eip_fn_namelen);

			int addroffset = eipget - eip_info.eip_fn_addr;
	
			cprintf("   %s:%d: %s+%u\n",eip_info.eip_file,eip_info.eip_line ,fn_name , addroffset);
	
		} else {
			cprintf("error");
		}
		
		if(count==2)
			ebpzero=(int *)ebpget;	
		if(count==4)
			ebptwo=(int *)ebpget;	
		if(count==6)
			ebpfive=ebpget;
		eipget = *(int *)(ebpget + 4);
		ebpget = *(int *)ebpget;
		count++;

	}
	int a=2;
	corruptStack(3, (char *)(ebpzero+2 ));
	corruptStack(ebpfive, (char *)ebptwo);
	return 0;
}
void corruptStack(unsigned int value, char * point)
{


    // And you must uie the "cprintf" function with %n specifier
    // you augmented in the "Exercise 9" to do this job.

     	char str[256] = {};
    	int nstr = 0;
	
	memset(str, '\0', 256);
	memset(str, 0xd, (value & 0xff));
	cprintf("%s%n", str,(char *)point + 0);


	memset(str, '\0', 256);
	memset(str, 0xd, ((value/0x100) & 0xff));
	cprintf("%s%n", str,(char *)point + 1);

	memset(str, '\0', 256);
	memset(str, 0xd, ((value/0x10000) & 0xff));
	cprintf("%s%n", str,(char *)point + 2);

	memset(str, '\0', 256);
	memset(str, 0xd, ((value/0x1000000) & 0xff));
	cprintf("%s%n", str,(char *)point + 3);
}


/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void
monitor(struct Trapframe *tf)
{
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
	return callerpc;
}
