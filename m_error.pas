//------------------------------------------------------------------------------
// Name        : m_error
// Purpose     : Implementatie van functie voor uniforme ErrorMessages.
// Environment : Free Pascal 2.4.2, Windows XP
// Notes       : -
// Author      : Vincent Houtgraaf, Bunnik
// Date        : aug 2011
// Modified    :
//------------------------------------------------------------------------------
unit m_error;

{$mode objfpc}{$H+}

interface

uses SysUtils;//, m_utils;

const
  NrOfErrors = 3;

  Err_UNKNOWN = 1;
  Err_XDirectoryDoesNotExist = 2;
  Err_NoValidRemoteExececuteProgram = 3;

type
  TErrorMsg = record
    Msg: string;
    NrArg: integer;
  end;

type
  EWobbelError = class(Exception)
  private
    FErrorCode: Integer;
    FStatusCode: String;
  public
    constructor Create(const Msg: string);

    property ErrorCode: Integer read FErrorCode;
    property StatusCode: string read FStatuscode; // The "String" Errocode // FirmOS
  end;

const
  ErrMsg: array[1..NrOfErrors] of TErrorMsg = (
    (Msg: 'Unknown error.'; NrArg: 0),
    (Msg: '%s directory does not exist.'; NrArg: 1),
    (Msg: 'No valid remote exececute program.'; NrArg: 0)
    );

  procedure MsgErrorF(ErrorCode: integer; Args: array of string);

  function  ErrorMsg(ErrorCode: integer; Args: array of string): string;

implementation

uses
  m_tools (*, m_wobbelglobals*);

constructor EWobbelError.Create(const Msg: string);
begin
  inherited Create(Msg);
end;


//------------------------------------------------------------------------------
// Vervangt %s in de Msg door de elementen van de array.
function ErrorMsg(ErrorCode: integer; Args: array of string): string;
var
  Msg: string;
  i: integer;
begin
  Msg:=ErrMsg[ErrorCode].Msg;
  for i := 0 to ErrMsg[ErrorCode].NrArg-1 do
  begin
    if i<=High(Args) then
      Msg:=SubstFirst(Msg,'%s',Args[i])
    else
      Msg:=SubstFirst(Msg,'%s','');
  end;
  Msg:=StringReplace(Msg,'  ',' ',[rfReplaceAll]);
  if Length(Msg)>0 then
    Msg[1]:=UpCase(Msg[1]);
  ErrorMsg:=Msg;
end;

//------------------------------------------------------------------------------
procedure MsgErrorF(ErrorCode: integer; Args: array of string);
begin
  MsgError(ErrorMsg(ErrorCode,Args));
end;

end.

