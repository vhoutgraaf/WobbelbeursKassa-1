//------------------------------------------------------------------------------
// Name        : m_querystuff
// Purpose     : stuff for queries.
// Environment : Free Pascal 2.4.2, Windows XP
// Notes       : -
// Author      : Vincent Houtgraaf, Bunnik
// Date        : aug 2011
// Modified    :
//------------------------------------------------------------------------------
unit m_querystuff;

{$mode objfpc}{$H+}

interface


uses
  Classes, SysUtils,
  ZDataset,
  m_wobbeldata;


function GetSQLite3QueryMdb : TZQuery;
function GetSQLite3QueryDdb : TZQuery;


implementation

uses m_tools;


function GetSQLite3QueryMdb : TZQuery;
var AQuery : TZQuery;
begin
  try
    AQuery := nil;
    try
      AQuery := TZQuery.Create(nil);
      if (dmWobbel.connWobbelMdb <> nil) then
      begin
        AQuery.Connection := dmWobbel.connWobbelMdb;
      end;
    //  AQuery.Transaction := FTransaction;
    finally
      GetSQLite3QueryMdb := AQuery;
    end;
  except
    on E: Exception do
    begin
      MessageError('Fout bij uitvoeren GetSQLite3Query: ' + E.Message);
    end;
  end;
end;

function GetSQLite3QueryDdb : TZQuery;
var AQuery : TZQuery;
begin
  try
    AQuery := nil;
    try
      AQuery := TZQuery.Create(nil);
      if (dmWobbel.connWobbelDdb <> nil) then
      begin
        AQuery.Connection := dmWobbel.connWobbelDdb;
      end;
    finally
      GetSQLite3QueryDdb := AQuery;
    end;
  except
    on E: Exception do
    begin
      MessageError('Fout bij uitvoeren GetSQLite3ImportQuery: ' + E.Message);
    end;
  end;
end;

end.

