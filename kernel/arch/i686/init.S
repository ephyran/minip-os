.set ALIGN,     1 << 0
.set MEMINFO,   1 << 1      # provide memory map... now if only I could access it
.set FLAGS,     ALIGN | MEMINFO
.set MAGIC,     0x1BADB002
.set CHECKSUM,  -(MAGIC + FLAGS)
.set STACKSIZE, 0x10000

.section .multiboot.data, "aw"
.align 4
.long MAGIC
.long FLAGS
.long CHECKSUM

# Unfortunately, we lose the multiboot info upon unmapping the first 1MiB...
# Hence, keep copy of basic stuff here
.section .data, "aw"
_copyMultiboot:
    .align 4
    .long MAGIC
    .long FLAGS
    .long CHECKSUM

.section .stack, "aw", @nobits
_stackBottom:
    .skip STACKSIZE
_stackTop:

.section .bss, "aw", @nobits
    .align 4096
_bootDirectory:
    .skip 4096
_pageTable1:
    .skip 4096

.section .multiboot.text, "a"
.global _start
.type _start, @function
_start:
    movl    $(_pageTable1 - 0xC0000000), %edi
    movl    $0, %esi

    # Map all of first MiB except VGA buffer
    movl    $1023, %ecx

_mapKernel:
    cmpl    $_kernel_start, %esi
    jl      _fillBlock
    cmpl    $(_kernel_end - 0xC0000000), %esi
    jge     _initPaging

    movl    %esi, %edx
    orl     $0x003, %edx
    movl    %edx, (%edi)

    cmpl    $(_text_start - 0xC0000000), %esi
    jg      _isInTextRange

    cmpl    $(_rodata_start - 0xC0000000), %esi
    jg      _isInRodataRange

_isInTextRange:
    cmpl    $(_text_end - 0xC0000000), %esi         # If at end of text section...
    jge     _endIfWritable                          # Jump to end of if
    jmp     _isNotWritable                          # Otherwise set RW bit to 0

_isInRodataRange:
    cmpl    $(_rodata_end - 0xC0000000), %esi       # If at end of rodata section...
    jge     _endIfWritable                          # Jump to end of if
    jmp     _isNotWritable                          # Otherwise set RW bit to 0

_isNotWritable:
    movl    %esi, %edx
    orl     $0x001, %edx
    movl    %edx, (%edi)

_endIfWritable:

_fillBlock:
    addl    $4096, %esi
    addl    $4, %edi
    loop    _mapKernel

_initPaging:
    # Map VGA, P+RW
    movl    $(0x000B8000 | 0x003), _pageTable1 - 0xC0000000 + 1023 * 4

    # Map the page table to both virtual addresses 0x00000000 and 0xC0000000
    movl    $(_pageTable1 - 0xC0000000 + 0x003), _bootDirectory - 0xC0000000 + 0
    movl    $(_pageTable1 - 0xC0000000 + 0x003), _bootDirectory - 0xC0000000 + 768 * 4

    # Set cr3 to address of boot page directory
    movl    $(_bootDirectory - 0xC0000000), %ecx
    movl    %ecx, %cr3

    movl    %cr4, %ecx
    orl     $0x00000010, %ecx
    movl    %ecx, %cr4

    # Enable paging and RW protection
    movl    %cr0, %ecx
    orl     $0x80010000, %ecx
    movl    %ecx, %cr0

    # Jump into higher half with absolute jump
    lea     _startInHigherHalf, %ecx
    jmp     *%ecx

.section .text
.type _startInHigherHalf, @function
_startInHigherHalf:
    # Unmap the identity mapping as it is now unnecessary.
    movl    $0, _bootDirectory + 0

    # Reload crc3 to force a TLB flush so the changes to take effect.
    movl    %cr3, %ecx
    movl    %ecx, %cr3

    # Set up the stack.
    mov     $_stackTop, %esp

    # Update ebx to higher half multiboot info instead of the out of reach lower half
    mov     $_copyMultiboot, %ebx

    push    %eax
    push    %ebx

    # Enter the high-level kernel.
    call    _main

    # Infinite loop if the system has nothing more to do.
    cli
1:  hlt
    jmp     1b
