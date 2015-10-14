//------------------------------------------------------------------------------
// Name        : c_beurs
// Purpose     : Implementatie van TBeurs
// Environment : Free Pascal 2.4.2, Windows XP
// Notes       : Bewaart instellingen vna een beurs.
// Author      : Vincent Houtgraaf, Bunnik
// Date        : aug 2011
// Modified    :
//------------------------------------------------------------------------------
unit c_beurs;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils; 

const
  defaultBeursOmschrijving = 'Geen beurs gekozen';
type
  TBeurs = class
    private
      FBeursId: integer;
      FBeursOmschrijving: string;
      FError: string;
      FAantalVerkopersInActieveBeurs:integer;


    public
      constructor Create;
      destructor Destroy;override;

      function BeursIsOk: boolean;
      function AantalActieveBeurzen: integer;
      function setBeursProperties:boolean;
      function AantalTransactiesInActieveBeurs: integer;
      procedure SetAantalVerkopersInActieveBeurs;

      property AantalVerkopersInActieveBeurs: integer read FAantalVerkopersInActieveBeurs;
      property BeursId: integer read FBeursId write FBeursId;
      property BeursOmschrijving: string read FBeursOmschrijving write FBeursOmschrijving;
      property Error: string read FError;
  end;

  PBeurs = ^TBeurs;

implementation

uses
  m_querystuff, m_tools,
  ZDataset,
  c_appsettings;

constructor TBeurs.Create;
begin
  inherited;
  FBeursId:=-1;
  FError:='';
  FAantalVerkopersInActieveBeurs:=-1;
  FBeursOmschrijving:=defaultBeursOmschrijving;
end;

//------------------------------------------------------------------------------
destructor TBeurs.Destroy;
begin
  inherited Destroy;
end;


function TBeurs.setBeursProperties():boolean;
var
  q : TZQuery;
  bFound : boolean;
  retVal: boolean;
  beursdatumIni:string;
begin
  retVal:=true;
  // als de inifile een beurs heeft gedefinieerd: check of deze voorkomt in de database.
  // zoja: zet deze als actieve beurs. zonee: geef een foutmelding: kies een beurs.
  // Als er niets in de inifile staat: ga na wat er in de database als actieve beurs is gezet
  try
    try
      FBeursId:=-1;
      FBeursOmschrijving:=defaultBeursOmschrijving;
      FError:='';

      q := m_querystuff.GetSQLite3QueryMdb;
      q.SQL.Clear;

      //Check of een beursid is ingesteld in de inifile
      beursdatumIni:=m_tools.GetStringFromIniFile('INIT','BeursDatum','');
      if (beursdatumIni <> '') then
      begin
        FBeursId:=-1;
        // check of deze datum voorkomt in de database
        q.SQL.Text := 'select beurs_id, datum,opmerkingen from beurs where datum=:BEURSDATUM';
        q.Params.ParamByName('BEURSDATUM').AsString := beursdatumIni;
        q.Open;
        while not q.Eof do
        begin
          FBeursId:=q.FieldByName('beurs_id').AsInteger;
          FBeursOmschrijving:=m_tools.getBeursOmschrijving(q.FieldByName('datum').AsString, q.FieldByName('opmerkingen').AsString);
          break;
        end;
        if (FBeursId <> -1) then
        begin
          // zet deze beursid als actieve beurs
          q.SQL.Clear;
          q.SQL.Text:='update beurs set isactief=0';
          q.ExecSQL();

          q.SQL.Clear;
          q.SQL.Text:='update beurs set ' +
                      ' isactief=1 ' +
                      ' where beurs_id=:BEURS_ID';
          q.Params.ParamByName('BEURS_ID').AsInteger := FBeursId;
          q.ExecSQL();
        end
        else
        begin
          FError:='De beurs in de inifile komt niet voor in de database. Svp een andere kiezen';
          // reset een eventueel al in de database gekozen beurs
          q.SQL.Clear;
          q.SQL.Text:='update beurs set isactief=0';
          q.ExecSQL();
          MessageError(FError);
          retVal:=false;
        end;
      end
      else
      begin
        if (AantalActieveBeurzen <> 1) then
        begin
          if not (lsIngelogdAdmin in AppSettings.WobbelLoginStatus) then
          begin
            MessageError(FError);
          end;
          retVal:=false;
        end
        else
        begin
          bFound:=false;
          q.SQL.Text := 'select beurs_id,datum,opmerkingen,opbrengst from beurs where isactief=1;';
          q.Open;
          while not q.Eof do
          begin
            FBeursId:=q.FieldByName('beurs_id').AsInteger;
            FBeursOmschrijving:=m_tools.getBeursOmschrijving(q.FieldByName('datum').AsString, q.FieldByName('opmerkingen').AsString);
            beursdatumIni:=q.FieldByName('datum').AsString;
            bFound:=true;
            m_tools.SetValueInIniFile('INIT','BeursDatum',beursdatumIni);
            break;
          end;
          q.Close;
          if not bFound then
          begin
            FError:='Geen actieve beurs gevonden. Kies svp eerst een beurs.';
            MessageError(FError);
            retVal:=false;
          end;
        end;
      end;

      SetAantalVerkopersInActieveBeurs;
    finally
      q.Free;
      setBeursProperties:=retVal;
    end;
  except
    on E: Exception do
    begin
      FError:='Fout bij opvragen beurs-id: ' + E.Message;
      MessageError(FError);
    end;
  end;
end;

function TBeurs.AantalActieveBeurzen: integer;
var
  q : TZQuery;
  retVal:integer;
begin
  try
    try
      retVal:=-1;
      FError:='';

      q := m_querystuff.GetSQLite3QueryMdb;
      q.SQL.Clear;
      q.SQL.Text := 'select count(*) as aantal from beurs where isactief=1;';
      q.Open;
      while not q.Eof do
      begin
        retVal:=q.FieldByName('aantal').AsInteger;
        break;
      end;
      q.Close;
      if (retVal = 0) then
      begin
        FError:='Geen actieve beurs gevonden. Kies svp eerst een beurs';
        //MessageError(FError);
      end
      else if (retVal = 1) then
      begin
//
      end
      else
      begin
        FError:='Meer dan 1 actieve beurs geselecteerd. Kies svp eerst een beurs';
        //MessageError(FError);
      end
    finally
      q.Free;
      AantalActieveBeurzen:=retVal;
    end;
  except
    on E: Exception do
    begin
      FError:='Fout bij opvragen aantal actieve beurzen: ' + E.Message;
      raise(Exception.Create(FError));
    end;
  end;
end;

function TBeurs.AantalTransactiesInActieveBeurs: integer;
var
  q : TZQuery;
begin
  Result:=0;
  try
    try
      FError:='';

      q := m_querystuff.GetSQLite3QueryMdb;
      q.SQL.Clear;
      q.SQL.Text := ' select count(*) as aantal ' +
          ' from beurs as b, kassa as k, transactie as t ' +
          ' where b.beurs_id=k.beursid ' +
          ' and t.kassaid=k.kassa_id ' +
          ' and b.isactief=1 ' +
          ' and k.isactief=1;';
      q.Open;
      while not q.Eof do
      begin
        Result:=q.FieldByName('aantal').AsInteger;
        break;
      end;
      q.Close;
    finally
      q.Free;
    end;
  except
    on E: Exception do
    begin
      Result:=-1;
      FError:='Fout bij opvragen aantal transacties in actieve beurs: ' + E.Message;
      raise(Exception.Create(FError));
    end;
  end;
end;

procedure TBeurs.SetAantalVerkopersInActieveBeurs;
var
  q : TZQuery;
begin
  FAantalVerkopersInActieveBeurs:=0;
  try
    try
      FError:='';

      q := m_querystuff.GetSQLite3QueryMdb;
      q.SQL.Clear;
      q.SQL.Text := ' select count(*) as aantal ' +
          ' from beurs_verkoper as bv, verkoper as v, beurs as b ' +
          ' where bv.verkoperid=v.verkoper_id ' +
          ' and bv.beursid = b.beurs_id ' +
          ' and b.isactief=1;';
      q.Open;
      FAantalVerkopersInActieveBeurs:=q.FieldByName('aantal').AsInteger;
      q.Close;
    finally
      q.Free;
    end;
  except
    on E: Exception do
    begin
      FAantalVerkopersInActieveBeurs:=-1;
      FError:='Fout bij opvragen aantal verkopers in actieve beurs: ' + E.Message;
      raise(Exception.Create(FError));
    end;
  end;
end;


function TBeurs.BeursIsOk: boolean;
begin
  BeursIsOk:=FBeursId <> -1;
end;

end.

