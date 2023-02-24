unit strutils;

interface

function _strlen(const str: PChar): Integer;
function _strcmp(dest: PChar; src: PChar): Integer;

implementation

function _strlen(const str: PChar): Integer;
var
    len: Integer = 0;
begin
    while (str[len] <> Char($0)) do
    begin
        inc(len);
    end;

    _strlen := len;
end;

function _strcmp(dest: PChar; src: PChar): Integer;
begin
    while((dest^ <> Char($0)) and (dest^ = src^)) do
    begin
        inc(dest);
        inc(src);
    end;

    _strcmp := Integer(dest^) - Integer(src^);
end;

function _strcpy(dest: PChar; src: PChar): PChar;
begin

end;

end.
