//
//  Assembly.c
//  Assembler
//
//  Created by evelyn on 2022-10-15.
//

#include <stdio.h>
#include <sys/mman.h>
#include <string.h>

#include <mach/mach.h>

const void* assembly(const unsigned char code[], size_t codesize) {

    puts("uwu");
    
    mach_vm_address_t addr = 0;
    mach_vm_allocate(mach_task_self(), &addr, vm_page_size, VM_FLAGS_ANYWHERE);
    mach_vm_protect(mach_task_self(), addr, vm_page_size, 0, VM_PROT_READ | VM_PROT_WRITE);
    memcpy((void *)addr, code, codesize);
    mach_vm_protect(mach_task_self(), addr, vm_page_size, 0, VM_PROT_READ | VM_PROT_EXECUTE);
    //now cast the address to a function pointer and call it
    const void* (*myFunction)(void) = (typeof(myFunction))addr;
    return myFunction();
}
