# Declare constants for the multiboot header.
.set ALIGN,     1 << 0           # align loaded modules on page boundaries
.set MEMINFO,   1 << 1           # provide memory map
.set GRAPHICS,  1 << 2
.set ADDR,		1 << 16
.set FLAGS,    ALIGN | MEMINFO   # this is the Multiboot 'flag' field
.set MAGIC,    0x1BADB002        # 'magic number' lets bootloader find the header
.set CHECKSUM, -(MAGIC + FLAGS)  # checksum of above, to prove we are multiboot
.set STACKSIZE, 0x10000

# Declare a multiboot header that marks the program as a kernel.
.section .multiboot.data, "aw"
.align 4
.long MAGIC
.long FLAGS
.long CHECKSUM

.section .data, "aw"
_copyMultiboot:
.align 4
.long MAGIC
.long FLAGS
.long CHECKSUM

# Allocate the initial stack.
.section .stack, "aw", @nobits
stack_bottom:
.skip STACKSIZE
stack_top:

.section .bss, "aw", @nobits
	.align 4096
boot_page_directory:
	.skip 4096
boot_page_table1:
	.skip 4096
# Further page tables may be required if the kernel > 3 MiB.

.section .multiboot.text, "a"
.global _start
.type _start, @function
_start:
	movl $(boot_page_table1 - 0xC0000000), %edi
	movl $0, %esi
	# Map all but VGA buffer
	movl $1023, %ecx

1:
	# Only map the kernel.
	cmpl $_kernel_start, %esi
	jl 2f
	cmpl $(_kernel_end - 0xC0000000), %esi
	jge 3f

	# Map physical address as present, writable.
	movl %esi, %edx
	orl $0x003, %edx
	movl %edx, (%edi)

2:
	addl $4096, %esi
	addl $4, %edi
	loop 1b

3:
	# Map VGA
	movl $(0x000B8000 | 0x003), boot_page_table1 - 0xC0000000 + 1023 * 4

	# Map the page table to both virtual addresses 0x00000000 and 0xC0000000.
	movl $(boot_page_table1 - 0xC0000000 + 0x003), boot_page_directory - 0xC0000000 + 0
	movl $(boot_page_table1 - 0xC0000000 + 0x003), boot_page_directory - 0xC0000000 + 768 * 4

	# Set cr3 to the address of the boot_page_directory.
	movl $(boot_page_directory - 0xC0000000), %ecx
	movl %ecx, %cr3

	movl %cr4, %ecx
	orl $0x00000010, %ecx
	movl %ecx, %cr4

	# Enable paging and the write-protect bit.
	movl %cr0, %ecx
	orl $0x80010000, %ecx
	movl %ecx, %cr0

	# Jump to higher half with an absolute jump.
	lea _startInHigherHalf, %ecx
	jmp *%ecx

.section .text

.type _startInHigherHalf, @function
_startInHigherHalf:
	# Unmap the identity mapping as it is now unnecessary.
	movl $0, boot_page_directory + 0

	# Reload crc3 to force a TLB flush so the changes to take effect.
	movl %cr3, %ecx
	movl %ecx, %cr3

	# Set up the stack.
	mov $stack_top, %esp

	# Update ebx to higher half multiboot info instead of the out of reach lower half
	mov $_copyMultiboot, %ebx

	push %eax
	push %ebx

	# Enter the high-level kernel.
	call _main

	# Infinite loop if the system has nothing more to do.
	cli
1:	hlt
	jmp 1b

