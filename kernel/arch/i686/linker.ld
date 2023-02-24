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
    .text ALIGN (0x1000) : AT (ADDR (.text) - KERNELHIGH) {
        _text_start = .;
        text = .; _text = .; __text = .;
        *(.text)
        _text_end = .;
    }
    .rodata ALIGN (0x1000) : AT (ADDR (.rodata) - KERNELHIGH) {
        _rodata_start = .;
        rodata = .; _rodata = .; __rodata = .;
        *(.rodata)
        _rodata_end = .;
    }
    .data ALIGN (0x1000) : AT (ADDR (.data) - KERNELHIGH) {
        data = .; _data = .; __data = .;
        *(.data)
        kimage_text = .;
        LONG(text);
        kimage_data = .;
        LONG(data);
        kimage_bss = .;
        LONG(bss);
        kimage_end = .;
        LONG(end);
    }
    .multiboot.data : {
        *(.multiboot.data)
    }
    .bss ALIGN (0x1000) : AT (ADDR (.bss) - 0xC0000000) {
        bss = .; _bss = .; __bss = .;
        *(COMMON)
        *(.bss)
        *(.stack)
    }
    end = .; _end = .; __end = .;
    _kernel_end = .;
}
