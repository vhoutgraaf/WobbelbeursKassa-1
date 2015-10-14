//------------------------------------------------------------------------------
// Name        : c_verkoper
// Purpose     : Implementatie van TVerkoper
// Environment : Free Pascal 2.4.2, Windows XP
// Notes       : Bewaart instellingen vna een verkoper.
// Author      : Vincent Houtgraaf, Bunnik
// Date        : aug 2011
// Modified    :
//------------------------------------------------------------------------------
unit c_verkoper;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, CheckLst;

type
  TVerkoper = class
    private
      FVerkoperId: integer;
      FError: string;

      procedure setVerkoperProperties;

    public
      constructor Create;
      destructor Destroy; override;

      procedure ResetVerkoperprops;

      property VerkoperId: integer read FVerkoperId write FVerkoperId;
      property Error: string read FError;

  end;

procedure VulVerkopersKoppelenAanBeursTabellen(beursid:integer;
    var clbGekoppeldeVerkopers: TCheckListBox; var clbOngekoppeldeVerkopers: TCheckListBox);
procedure VerkoperBeursKoppelingenOpslaan(beursid:integer;
    var clbGekoppeldeVerkopers: TCheckListBox; var clbOngekoppeldeVerkopers: TCheckListBox);
procedure SchuifGekoppeldeVerkoperNaarOngekoppeldenLijst(
    var clbGekoppeldeVerkopers: TCheckListBox; var clbOngekoppeldeVerkopers: TCheckListBox);
procedure SchuifOngekoppeldeVerkoperNaarGekoppeldenLijst(
    var clbGekoppeldeVerkopers: TCheckListBox; var clbOngekoppeldeVerkopers: TCheckListBox);


implementation

uses
  m_querystuff, m_tools, m_wobbeldata, m_error,
  ZDataset;


constructor TVerkoper.Create;
begin
  inherited;
  FVerkoperId:=-1;
  FError:='';
  setVerkoperProperties();
end;

//------------------------------------------------------------------------------
destructor TVerkoper.Destroy;
begin
  inherited Destroy;
end;

procedure TVerkoper.ResetVerkoperprops;
begin
  FVerkoperId:=-1;
  FError:='';
end;

procedure TVerkoper.setVerkoperProperties();
//var
  //q : TZQuery;
  //s: string;
  //bFound : boolean;
begin
  try
    try
    finally
      //q.Free;
    end;
  except
    on E: Exception do
    begin
      MessageError('Fout bij setVerkoperProperties: ' + E.Message);
    end;
  end;
end;


// Algemene procs en functies buiten de klasse om
procedure VulVerkopersKoppelenAanBeursTabellen(beursid:integer;
    var clbGekoppeldeVerkopers: TCheckListBox; var clbOngekoppeldeVerkopers: TCheckListBox);
var
  q : TZQuery;
begin
  try
    try
      clbGekoppeldeVerkopers.Clear;
      clbOngekoppeldeVerkopers.Clear;

      q := m_querystuff.GetSQLite3QueryMdb;
      q.SQL.Clear;
      q.SQL.Text:='select v.verkoper_id, v.verkopercode, naw.achternaam ' +
         ' from verkoper as v ' +
         ' left join naw on v.nawid=naw.naw_id ' +
         ' left join beurs_verkoper as bv on bv.verkoperid=v.verkoper_id and bv.beursid=:BEURSID ' +
         ' where (bv.beurs_verkoper_id!='''' and bv.beurs_verkoper_id is not null)';
      q.Params.ParamByName('BEURSID').AsInteger := beursid;
      q.Open;
      while not q.Eof do
      begin
        clbGekoppeldeVerkopers.Items.AddObject(q.FieldByName('verkopercode').AsString + ' (' + q.FieldByName('achternaam').AsString + ')',
                                               TObject(q.FieldByName('verkoper_id').AsInteger));
        q.Next;
      end;
      q.Close;

      q.SQL.Clear;
      q.SQL.Text:='select v.verkoper_id, v.verkopercode, naw.achternaam ' +
         ' from verkoper as v ' +
         ' left join naw on v.nawid=naw.naw_id ' +
         ' left join beurs_verkoper as bv on bv.verkoperid=v.verkoper_id and bv.beursid=:BEURSID ' +
         ' where (bv.beurs_verkoper_id='''' or bv.beurs_verkoper_id is null)';
      q.Params.ParamByName('BEURSID').AsInteger := beursid;
      q.Open;
      while not q.Eof do
      begin
        clbOngekoppeldeVerkopers.Items.AddObject(q.FieldByName('verkopercode').AsString + ' (' + q.FieldByName('achternaam').AsString + ')',
                                                TObject(q.FieldByName('verkoper_id').AsInteger));
        q.Next;
      end;
      q.Close;
    finally
      q.Free;
    end;
  except
    on E: Exception do
    begin
      MessageError('Fout bij vullen lijsten met gekoppelde en vrije verkopers: ' + E.Message);
    end;
  end;
end;

procedure VerkoperBeursKoppelingenOpslaan(beursid:integer;
    var clbGekoppeldeVerkopers: TCheckListBox; var clbOngekoppeldeVerkopers: TCheckListBox);
var
  q : TZQuery;
  idlijst2remove: string;
  ix: integer;
begin
  try
    try
      q := m_querystuff.GetSQLite3QueryMdb;
      q.SQL.Clear;

      idlijst2remove:='';
      //MessageOk(IntToStr(clbGekoppeldeVerkopers.Items.Count));
      for ix:=clbGekoppeldeVerkopers.Items.Count-1 downto 0 do
      begin
        if (Length(idlijst2remove)=0) then
        begin
          idlijst2remove:=IntToStr(Integer(clbGekoppeldeVerkopers.Items.Objects[ix]));
        end
        else
        begin
          idlijst2remove:=idlijst2remove+','+IntToStr(Integer(clbGekoppeldeVerkopers.Items.Objects[ix]));
        end;
      end;
      for ix:=clbOngekoppeldeVerkopers.Items.Count-1 downto 0 do
      begin
        if (Length(idlijst2remove)=0) then
        begin
          idlijst2remove:=IntToStr(Integer(clbOngekoppeldeVerkopers.Items.Objects[ix]));
        end
        else
        begin
          idlijst2remove:=idlijst2remove+','+IntToStr(Integer(clbOngekoppeldeVerkopers.Items.Objects[ix]));
        end;
      end;

      m_tools.OpenTransactie(dmWobbel.connWobbelMdb);
      if (Length(idlijst2remove)>0) then
      begin
        idlijst2remove:='('+idlijst2remove+')';
        q.SQL.Text:='delete from beurs_verkoper where beursid=:BEURSID and verkoperid in ' + idlijst2remove;
        q.Params.ParamByName('BEURSID').AsInteger := beursid;
        q.ExecSQL;
        q.Close;
      end;

      for ix:=clbGekoppeldeVerkopers.Items.Count-1 downto 0 do
      begin
        q.SQL.Clear;
        q.SQL.Text:='insert into beurs_verkoper (beursid, verkoperid) values (:BEURSID, :VERKOPERID);';
        q.Params.ParamByName('BEURSID').AsInteger := beursid;
        q.Params.ParamByName('VERKOPERID').AsInteger := Integer(clbGekoppeldeVerkopers.Items.Objects[ix]);
        q.ExecSQL;
        q.Close;
      end;
      dmWobbel.connWobbelMdb.ExecuteDirect('commit transaction');

      MessageOk('De wijzigingen zijn opgeslagen');
    finally
      q.Free;
      VulVerkopersKoppelenAanBeursTabellen(beursid, clbGekoppeldeVerkopers, clbOngekoppeldeVerkopers);
    end;
  except
    on E: Exception do
    begin
      dmWobbel.connWobbelMdb.ExecuteDirect('rollback transaction');
      MessageError('Fout bij setVerkoperProperties: ' + E.Message);
    end;
  end;
end;

procedure SchuifGekoppeldeVerkoperNaarOngekoppeldenLijst(
    var clbGekoppeldeVerkopers: TCheckListBox; var clbOngekoppeldeVerkopers: TCheckListBox);
var
  ix: integer;
//  ID: integer;
begin
  for ix:=clbGekoppeldeVerkopers.Items.Count-1 downto 0 do
  begin
    if clbGekoppeldeVerkopers.Checked[ix] then
    begin
//      ID:=Integer(clbGekoppeldeVerkopers.Items.Objects[ix]);
      MessageOk(IntToStr(Integer(clbGekoppeldeVerkopers.Items.Objects[ix])));
      clbOngekoppeldeVerkopers.Items.AddObject(clbGekoppeldeVerkopers.Items[ix],
                                               TObject(Integer(clbGekoppeldeVerkopers.Items.Objects[ix])));

      clbGekoppeldeVerkopers.Items.Delete(ix);
    end;
  end;
end;

procedure SchuifOngekoppeldeVerkoperNaarGekoppeldenLijst(
    var clbGekoppeldeVerkopers: TCheckListBox; var clbOngekoppeldeVerkopers: TCheckListBox);
var
  ix: integer;
//  ID: integer;
begin
  for ix:=clbOngekoppeldeVerkopers.Items.Count-1 downto 0 do
  begin
    if clbOngekoppeldeVerkopers.Checked[ix] then
    begin
      //ID:=Integer(clbOngekoppeldeVerkopers.Items.Objects[ix]);
      MessageOk(IntToStr(Integer(clbOngekoppeldeVerkopers.Items.Objects[ix])));
      clbGekoppeldeVerkopers.Items.AddObject(clbOngekoppeldeVerkopers.Items[ix],
                                               TObject(Integer(clbOngekoppeldeVerkopers.Items.Objects[ix])));

      clbOngekoppeldeVerkopers.Items.Delete(ix);
    end;
  end;
end;



end.

