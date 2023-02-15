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

uses strutils;

type
    PWord = ^Word;
    vga_color = (
                    VGA_BLACK = 0,
                    VGA_BLUE = 1,
                    VGA_GREEN = 2,
                    VGA_CYAN = 3,
                    VGA_RED = 4,
                    VGA_MAGENTA = 5,
                    VGA_BROWN = 6,
                    VGA_LIGHT_GREY = 7,
                    VGA_DARK_GREY = 8,
                    VGA_LIGHT_BLUE = 9,
                    VGA_LIGHT_GREEN = 10,
                    VGA_LIGHT_CYAN = 11,
                    VGA_LIGHT_RED = 12,
                    VGA_LIGHT_MAGENTA = 13,
                    VGA_LIGHT_BROWN = 13,
                    VGA_WHITE = 14
                );

const
    VGA_WIDTH: Integer = 80;
    VGA_HEIGHT: Integer = 25;

var
    terminalRow: Integer = 0;
    terminalCol: Integer = 0;
    terminalColor: Byte = 0;
    terminalBuffer: PWord = PWord($C03FF000);
    textInterruptMode: Boolean = False;

function _vgaEntryColor(const foreground: vga_color; const background: vga_color): Byte; inline;
begin
    _vgaEntryColor := Byte(foreground) or (Byte(background) << 4);
end;

function _vgaEntry(const entry: Byte; const color: Byte): Word; inline;
begin
    _vgaEntry := Word(entry) or (Word(color) << 8);
end;

procedure _terminalInitialize();
var
    index: Integer;
    y: Integer;
    x: Integer;
begin
    terminalColor := _vgaEntryColor(vga_color.VGA_LIGHT_GREY, vga_color.VGA_BLACK);

    for y := 0 to (VGA_HEIGHT - 1) do
    begin
        for x := 0 to (VGA_WIDTH - 1) do
        begin
            index := (y * VGA_WIDTH) + x;
            terminalBuffer[index] := _vgaEntry(Byte(' '), terminalColor);
        end;
    end;
end;

procedure _terminalSetColor(const color: Byte);
begin
    terminalColor := color;
end;

procedure _terminalPutEntryAt(const c: Char; const color: Byte; const x: Integer; const y: Integer);
var
    index: Integer;
begin
    index := y * VGA_WIDTH + x;
    terminalBuffer[index] := _vgaEntry(Byte(c), color);
end;

procedure _terminalPutChar(const c: Char);
begin
    if (textInterruptMode <> False) then
    begin
        Case c of
            Char(110):
                begin
                    terminalCol := -1;
                    inc(terminalRow);
                end;
            Char(116):
                begin
                    terminalCol := terminalCol + 4;
                end;
        end;

        textInterruptMode := False;
    end
    else
    begin
        Case c of
            Char(92): textInterruptMode := True;
            Char(10):
                begin
                    terminalCol := -1;
                    inc(terminalRow);
                end;
            Char(127):
                begin
                    dec(terminalCol);
                    _terminalPutEntryAt(Char(' '), terminalColor, terminalCol, terminalRow);
                end;
            else
            begin
                _terminalPutEntryAt(c, terminalColor, terminalCol, terminalRow);
                inc(terminalCol);
            end;
        end;
    end;

    if (terminalCol = VGA_WIDTH) then
    begin
        terminalCol := 0;
        inc(terminalRow);
        if (terminalRow = VGA_HEIGHT) then
            terminalRow := 0;
    end;
end;

procedure _terminalWrite(const data: PChar; const size: Integer);
var
    i: Integer;
begin
    for i := 0 to size do
    begin
        _terminalPutChar(data[i]);
    end;
end;

procedure _terminalWriteString(const data: PChar);
begin
    _terminalWrite(data, _strlen(data));
end;

procedure _terminalWriteInt(const i: Integer);
var
    buffer: array[0..11] of Char;
    str: PChar;
    digit: Dword;
    sign: Boolean;
begin
    str := @buffer[11];
    str^ := #0;
    if (i < 0) then
    begin
        digit := -i;
        sign := True;
    end
    else
    begin
        digit := i;
        sign := False;
    end;

    repeat
        Dec(str);
        str^ := Char((digit mod 10) + Byte('0'));
        digit := digit div 10;
    until (digit = 0);

    if (sign) then
    begin
        dec(str);
        str^ := '-';
    end;

    _terminalWriteString(str);
end;

procedure _terminalWriteDword(const d: Dword);
var
    buffer: array [0..11] of Char;
    str: PChar;
    digit: Dword;
begin
    for digit := 0 to 10 do
        buffer[digit] := '0';

    str := @buffer[11];
    str^ := #0;

    digit := d;
    repeat
        dec(str);
        str^ := Char((digit mod 10) + Byte('0'));
        digit := digit div 10;
    until (digit = 0);

    _terminalWriteString(str);
end;

end.
