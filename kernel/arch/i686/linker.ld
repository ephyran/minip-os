OUTPUT_FORMAT(elf32-i386)
ENTRY (_start)

KERNELBOOT = 0x00100000;
KERNELHIGH = 0xC0000000;

SECTIONS {
    . = KERNELBOOT;
    _kernel_start = .;
    .multiboot.data : {
        *(.multiboot.data)
    }
    .multiboot.text : {
        *(.multiboot.text)
    }
    . += KERNELHIGH;
    _no_rw_start = .;
    .text ALIGN (0x1000) : AT (ADDR (.text) - KERNELHIGH) {
        text = .; _text = .; __text = .;
        *(.text)
        kimage_text = .;
        LONG(text);
    }
    .rodata ALIGN (0x1000) : AT (ADDR (.rodata) - KERNELHIGH) {
        rodata = .; _rodata = .; __rodata = .;
        *(.rodata)
    }
    _no_rw_end = .;
    .data ALIGN (0x1000) : AT (ADDR (.data) - KERNELHIGH) {
        data = .; _data = .; __data = .;
        *(.data)
        kimage_data = .;
        LONG(data);
    }
    .multiboot.data : {
        *(.multiboot.data)
    }
    .bss ALIGN (0x1000) : AT (ADDR (.bss) - 0xC0000000) {
        bss = .; _bss = .; __bss = .;
        *(COMMON)
        *(.bss)
        kimage_bss = .;
        LONG(bss);
        kimage_end = .;
        LONG(end);
        *(.stack)
    }
    end = .; _end = .; __end = .;
    _kernel_end = .;
}
