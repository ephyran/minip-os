unit console;

interface

procedure _terminalInitialize();
procedure _terminalSetColor(const color: Byte);
procedure _terminalPutEntryAt(const c: Char; const color: Byte; const x: Integer; const y: Integer);
procedure _terminalPutChar(const c: Char);
procedure _terminalWrite(const data: PChar; const size: Integer);
procedure _terminalWriteString(const data: PChar);
procedure _terminalWriteInt(const i: Integer);
procedure _terminalWriteDword(const d: Dword);

implementation

{$IFDEF ARCH_i686}

{$IFDEF CONSOLE_MODE_VGA}
{$INCLUDE ../arch/i686/console_vga.inc}
{$ENDIF}

{$IFDEF CONSOLEMODEVESA}
{$INCLUDE ../arch/i686/console_vesa.inc}
{$ENDIF}

{$ENDIF}

end.
