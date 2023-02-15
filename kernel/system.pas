unit system;

{$MODE FPC}

interface

  type
    cardinal = 0..$FFFFFFFF;
    hresult = cardinal;
    dword = cardinal;
    integer = longint;

    pchar = ^char;

    TTypeKind = (tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat, tkSet,
    tkMethod, tkSString, tkLString, tkAString, tkWString, tkVariant, tkArray,
    tkRecord, tkInterface, tkClass, tkObject, tkWChar, tkBool, tkInt64, tkQWord,
    tkDynArray, tkInterfaceRaw, tkProcVar, tkUString, tkUChar, tkHelper, tkFile,
    tkClassRef, tkPointer);

    jmp_buf = packed record
      rbx, rbp, r12, r13, r14, r15, rsp, rip: QWord;
      {$IFDEF win64}
      rsi, rdi: QWord;
      xmm6, xmm7, xmm8, xmm9, xmm10, xmm11, xmm12, xmm13, xmm14, xmm15: record
        m1, m2: QWord;
      end;

      mxcsr: LongWord;
      fpucw: word;
      padding: word;
      {$ENDIF win64}
    end;

    Pjmp_buf = ^jmp_buf;
    PExceptAddr = ^TExceptAddr;
    TExceptAddr = record
      buf: Pjmp_buf;
      next: PExceptAddr;
      {$IFDEF CPU16}
      frametype: SmallInt;
      {$ELSE CPU16}
      frametype: LongInt;
      {$ENDIF CPU16}
    end;

    PGuid = ^TGuid;
    TGuid = packed record
      case Integer of
      1:
      (Data1: DWord;
        Data2: word;
        Data3: word;
        Data4: array [0 .. 7] of byte;
      );
      2:
      (D1: DWord;
        D2: word;
        D3: word;
        D4: array [0 .. 7] of byte;
      );
      3:
      (
        time_low: DWord;
        time_mid: word;
        time_hi_and_version: word;
        clock_seq_hi_and_reserved: byte;
        clock_seq_low: byte;
        node: array [0 .. 5] of byte;
      );
    end;

procedure fpc_initializeunits; compilerproc;
procedure fpc_do_exit; compilerproc;

implementation

procedure fpc_initializeunits;
begin
end;

procedure fpc_do_exit;
begin
end;

end.
