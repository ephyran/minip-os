unit multiboot;

interface

const
    KERNEL_STACKSIZE = $10000;
    BOOT_MAGIC = $2BADB002;

type
    Pelf_section_header_table_t = ^elf_section_header_table_t;
    elf_section_header_table_t = packed record
        num: Dword;
        size: Dword;
        addr: Dword;
        shndx: Dword;
    end;

    Pboot_info_t = ^boot_info_t;
    boot_info_t = packed record
        flags: Dword;
        mem_lower: Dword;
        mem_upper: Dword;
        boot_device: Dword;
        cmdline: Dword;
        mods_count: Dword;
        mods_addr: Dword;
        elf_sec: elf_section_header_table_t;
        mmap_length: Dword;
        mmap_addr: Dword;
    end;

    Pmodule_t = ^module_t;
    module_t = packed record
        size: Dword;
        base_addr_low: Dword;
        base_addr_high: Dword;
        length_low: Dword;
        length_high: Dword;
        mtype: Dword;
    end;

implementation

end.
