unit kernel;

interface

uses
    multiboot;

procedure _main(binfo: Pboot_info_t; bmagic: DWORD); stdcall;

implementation

uses
    console;

procedure _main(binfo: Pboot_info_t; bmagic: DWORD); stdcall; [public, alias: '_main'];
var
    memoryMap: Pmodule_t;
begin
    _terminalInitialize();
    _terminalWriteString('minip-OS booted successfully!\n');
    _terminalWriteString('TBD: figure out how to handle location of mmap_* stuff from higher half.\n');

    if (bmagic <> BOOT_MAGIC) then
    begin
        _terminalWriteString('Halting; must be booted with multiboot-compliant bootloader.\n');
        asm
            cli
            hlt
        end;
    end
    else
    while True do
    begin
    end;
end;

end.
