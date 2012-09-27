// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.
//oslab 2012
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

    struct Eipdebuginfo info;
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	int i=0,j=0;
    int ebp=read_ebp();
    int ebps[100];
    int eip=*((int *)ebp+1);
    
    while(ebp!=0){
    	cprintf("ebp %x eip %x args ",ebp,eip);
    	for(i=0;i<5;i++){
	    	cprintf("%08x ",*((int *)ebp+2+i));
    	}        
        cprintf("\n");
        
	debuginfo_eip((int)eip,&info);
    
        cprintf("%s:%d: %.*s+%d\n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,(int )eip-(int )info.eip_fn_addr);
        ebps[j++]=ebp;
        ebp=*((int *)ebp);
        eip=*((int *)ebp+1);
    }
    
	corruptStack(0x3,(char *)((int *)ebps[2]+2));
	corruptStack(0x5,(char *)((int *)ebps[5]+2));
	*(int *)ebps[4]=*(int *)ebps[5];	
/*
    int base=ebps[0]&0x000000ff;
    int gap=ebps[1]-ebps[0];

    corruptStack(gap*1,(char *)ebps[0]);
     cprintf("\n%x\t%x\t%x\n",base,gap*1,*(int *)ebps[0]);
    *(int *)ebps[0]=(base+(*(int *)ebps[0]));//28
	
    base=ebps[1]&0x000000ff;
    corruptStack(gap*3,(char *)ebps[1]);
    cprintf("\n%x\t%x\t%x\n",base,gap*3,*(int *)ebps[1]);
    *(int *)ebps[1]=(base+(*(int *)ebps[1]));//88

   int a4=ebps[3];
    corruptStack(gap*2,(char *)ebps[4]);
    cprintf("\n%x\t%x\t%x\n",base,gap*2,*(int *)ebps[4]);
    *(int *)ebps[4]=(base+(*(int *)ebps[4]));//68

    base=ebps[4]&0x000000ff;//88
 	corruptStack(gap*2,(char *)ebps[3]);
   cprintf("\n%x\t%x\t%x\n",base,gap*2,*(int *)ebps[3]);
*((int *)ebps[4]+1)=    0xf0100112;
*((int *)ebps[4]+2)=    0x2;
*(int *)ebps[4]=(base+(*(int *)ebps[3]));//C8
	
	*(int *)a4=
    */
    return 0;
	
}
void corruptStack(unsigned int value, char * point)
{


   	 // And you must use the "cprintf" function with %n specifier
   	 // you augmented in the "Exercise 9" to do this job.
	//Your code here
    char ntest[value+1];
    memset(ntest,0xd,sizeof(ntest));
   // char target[value]; 
    ntest[value]='\0';
    //strncpy(target,ntest,value);
    cprintf("%s%n\n",ntest,point);
     	
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
