unit strutils;

interface

function _strlen(const str: PChar): Integer;

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

end.
