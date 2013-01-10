// implement fork from user space

#include <inc/string.h>
#include <inc/lib.h>
// PTE_COW marks copy-on-write page table entries.
// It is one of the bits explicitly allocated to user processes (PTE_AVAIL).
#define PTE_COW		0x800

unsigned int start_high,start_low;
unsigned int end_high,end_low;
long long time_lost,start,end;


//
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	int r;

	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

    if(!(err&FEC_WR)||!(vpd[PDX(addr)]&PTE_P)||!(vpt[PGNUM(addr)]&PTE_COW)){
       panic("pgfault: access was not a write or not a copy-on-write page");

    }
    if((r=sys_page_alloc(0,(void *)PFTEMP,PTE_U|PTE_P|PTE_W))<0){
       panic("pgfault: page alloc failed %e",r); 
    }
    addr = ROUNDDOWN(addr,PGSIZE);
    memmove(PFTEMP,addr,PGSIZE);
    if((r=sys_page_map(0,PFTEMP,0,addr,PTE_U|PTE_P|PTE_W))<0){
       panic("pgfault: page map failed %e",r); 
    }
	//panic("pgfault not implemented");
}

//
// Map our virtual page pn (address pn*PGSIZE) into the target envid
// at the same virtual address.  If the page is writable or copy-on-write,
// the new mapping must be created copy-on-write, and then our mapping must be
// marked copy-on-write as well.  (Exercise: Why do we need to mark ours
// copy-on-write again if it was already copy-on-write at the beginning of
// this function?)
//
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
    void *addr = (void *)((uint32_t)pn*PGSIZE);
    pte_t pte = vpt[PGNUM(addr)];
    //check permissions
    if((pte&PTE_W)||(pte&PTE_COW)){
        if((r=sys_page_map(0,addr,envid,addr,PTE_U|PTE_P|PTE_COW))<0){
            panic("duppage: page mapping failed %e",r);
        }
        if((r=sys_page_map(envid,addr,0,addr,PTE_U|PTE_P|PTE_COW))<0){
            panic("duppage: page mapping failed %e",r);
        }
    }else{
        if((r=sys_page_map(0,addr,envid,addr,PTE_U|PTE_P))<0){
            panic("duppage: page mapping failed %e",r);
        }
    }
	//panic("duppage not implemented");
	return 0;
}

//
// User-level fork with copy-on-write.
// Set up our page fault handler appropriately.
// Create a child.
// Copy our address space and page fault handler setup to the child.
// Then mark the child as runnable and return.
//
// Returns: child's envid to the parent, 0 to the child, < 0 on error.
// It is also OK to panic on error.
//
// Hint:
//   Use vpd, vpt, and duppage.
//   Remember to fix "thisenv" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
    //calculate the time(may cause some error when grading for it will occupy some registers)
    /*
    asm("rdtsc \n\t");
    asm("movl %%eax, %0\n\t":"=g"(start_low));
    asm("movl %%edx, %0\n\t":"=g"(start_high));
    //cprintf("start_high:\t%08x start_low:\t%08x\n",start_high,start_low);
    start = start_high;
    start = (start<<32)|start_low;
    */
    // LAB 4: Your code here.
    set_pgfault_handler(pgfault);
    envid_t envid;
    uint32_t addr;
    int r;
    if((envid = sys_exofork())<0){
        panic("fork: sys_exofork %e",envid);
    }
    if(envid==0){
       thisenv = &envs[ENVX(sys_getenvid())];
       return 0;
    }
    for(addr = UTEXT;addr < UXSTACKTOP-PGSIZE;addr+=PGSIZE){
        if((vpd[PDX(addr)]&PTE_P)&&(vpt[PGNUM(addr)]&(PTE_P|PTE_U))){
            duppage(envid,PGNUM(addr));
        }
    }
    if((r=sys_page_alloc(envid,(void *)(UXSTACKTOP - PGSIZE),PTE_U|PTE_P|PTE_W))<0){
        panic("fork: page alloc failed %e",r);
    }

    extern void _pgfault_upcall(void);
    sys_env_set_pgfault_upcall(envid,_pgfault_upcall);

    if((r=sys_env_set_status(envid,ENV_RUNNABLE))<0){
        panic("fork: set status failed %e",r);
    }
    /*
    asm("rdtsc \n\t");
    asm("movl %%eax, %0\n\t":"=g"(end_low));
    asm("movl %%edx, %0\n\t":"=g"(end_high));
    cprintf("end_high:\t%08x end_low:\t%08x\n",end_high,end_low);
    end = end_high;
    end = (end<<32)|end_low;
    cprintf("[alex]fork clock cycle is:\t%010u\n",(unsigned)(end-start));
    */
    return envid;
	//panic("fork not implemented");
}
//duppage used by sfork
static int
sduppage(envid_t envid, unsigned pn, int instack){
    int r;
    void *addr = (void *)(pn * PGSIZE);
    pte_t pte = vpt[PGNUM(addr)];
    if(instack==1||(pte & PTE_COW)){
        if((r=sys_page_map(0,addr,envid,addr,PTE_U|PTE_P|PTE_COW))<0){
            panic("sduppage: page mapping failed %e",r);
        }
        if((r=sys_page_map(envid,addr,0,addr,PTE_U|PTE_P|PTE_COW))<0){
            panic("sduppage: page mapping failed %e",r);
        }
    }else  if(pte&PTE_W){
            if((r = sys_page_map(0,addr,envid,addr,PTE_P|PTE_U|PTE_W))<0){
                panic("sduppage: page mapping failed %e",r);
             }
    }else{
            if((r = sys_page_map(0,addr,envid,addr,PTE_P|PTE_U))<0){
                panic("sduppage: page mapping failed %e",r);
            }
     }
    
    return 0;
}
// Challenge!
int
sfork(void)
{
    asm("rdtsc \n\t");
    asm("movl %%eax, %0\n\t":"=g"(start_low));
    asm("movl %%edx, %0\n\t":"=g"(start_high));
   // cprintf("start_high:\t%08x start_low:\t%08x\n",start_high,start_low);
    start = start_high;
    start = (start<<32)|start_low;
    int r;
    uint32_t addr;
    set_pgfault_handler(pgfault);
    envid_t envid = sys_exofork();
    if(envid < 0){
        panic("sfork: fork failed");
    }
    if(envid == 0){
        thisenv = &envs[ENVX(sys_getenvid())];
        return 0;
    }
    int instack = 1;
    for(addr = USTACKTOP - PGSIZE;addr >= UTEXT; addr -= PGSIZE ){
        if((vpd[PDX(addr)]&PTE_P)>0 && (vpt[PGNUM(addr)]&PTE_P)>0 && (vpt[PGNUM(addr)]&PTE_U)>0){
            sduppage(envid,PGNUM(addr),instack);
        }else{
            //not in stack any more
            instack = 0;
        }
    }

    if((r = sys_page_alloc(envid,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P))<0){
        panic("sfork: sys_page_alloc failed %e",r);
    }
    extern void _pgfault_upcall(void);
    if((r = sys_env_set_pgfault_upcall(envid,_pgfault_upcall))<0){
        panic("sfork: sys_env_set_pgfault_upcall failed %e",r);
    }
    if((r = sys_env_set_status(envid,ENV_RUNNABLE))<0){
        panic("sfork: sys_env_set_status failed %e",r);
    }
	//panic("sfork not implemented");
    asm("rdtsc \n\t");
    asm("movl %%eax, %0\n\t":"=g"(end_low));
    asm("movl %%edx, %0\n\t":"=g"(end_high));
   // cprintf("end_high:\t%08x end_low:\t%08x\n",end_high,end_low);
    end = end_high;
    end = (end<<32)|end_low;
    cprintf("[alex]sfork clock cycle is:\t%010u\n",(unsigned)(end-start));
	return envid;
}

