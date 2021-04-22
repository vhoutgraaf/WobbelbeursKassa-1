//------------------------------------------------------------------------------
// Name        : c_kassa
// Purpose     : Implementatie van TKassa
// Environment : Free Pascal 2.4.2, Windows XP
// Notes       : Bewaart instellingen van een kassa.
// Author      : Vincent Houtgraaf, Bunnik
// Date        : aug 2011
// Modified    :
//------------------------------------------------------------------------------
unit c_kassa;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils; 

const
  defaultKassaNr = '';

type
  TKassaStatus = set of (ksOnbepaald, ksGeopend, ksGesloten);

type
  TKassa = class
    private
      FKassaId: integer;
      FKassaStatus: TKassaStatus;
      FKassaOpmerkingen: string;
      FKassaNr: string;
      FError: string;


    public
      constructor Create;
      destructor Destroy;override;

      function KassaIsGekozen: boolean;
      function AantalActieveKassas: integer;
      function setKassaProperties(beursid: integer):boolean;
      function setKassaStatus(beursid: integer):boolean;

      function KassaStatusIsGeopend:boolean;
      function KassaStatusIsGesloten:boolean;
      function KassaStatusIsOnbepaald:boolean;

      property KassaStatus: TKassaStatus read FKassaStatus write FKassaStatus;
      property KassaId: integer read FKassaId write FKassaId;
      property KassaOpmerkingen: string read FKassaOpmerkingen write FKassaOpmerkingen;
      property KassaNr: string read FKassaNr write FKassaNr;
      property Error: string read FError;
  end;


implementation

uses
  m_querystuff, m_tools,
  ZDataset,
  c_appsettings;

constructor TKassa.Create;
begin
  inherited;
  FKassaId:=-1;
  FKassaStatus:=[ksOnbepaald];
  FError:='';
  FKassaNr:=defaultKassaNr;
  FKassaOpmerkingen:='';
end;

//------------------------------------------------------------------------------
destructor TKassa.Destroy;
begin
  inherited Destroy;
end;


function TKassa.setKassaProperties(beursid: integer):boolean;
var
  q : TZQuery;
  bFound : boolean;
  retVal: boolean;
  kassanrIni:string;
begin
  // Als er geen beurs is gedefinieerd: kappen
  if (beursid < 0) then
  begin
    exit(false);
  end;

  // als de inifile een kassa heeft gedefinieerd: check of deze voorkomt in de database.
  // zoja: zet deze als actieve kassa. zonee: geef een foutmelding: kies een kassa.
  // Als er niets in de inifile staat: ga na wat er in de database als actieve kassa is gezet
  retVal:=true;
  try
    try
      FKassaId:=-1;
      FKassaNr:=defaultKassaNr;
      FKassaOpmerkingen:='';
      FError:='';

      q := m_querystuff.GetSQLite3QueryMdb;
      q.SQL.Clear;

      //Check of een beursid is ingesteld in de inifile
      kassanrIni:=m_tools.GetStringFromIniFile('INIT','KassaNummer','');
      if (kassanrIni <> '') then
      begin
        FKassaId:=-1;
        // check of deze datum voorkomt in de database
        q.SQL.Text := 'select k.kassa_id, k.kassanr, k.opmerkingen ' +
            ' from kassa as k, beurs as b ' +
            ' where k.beursid=b.beurs_id ' +
            ' and b.isactief=1 ' +
            ' and b.beurs_id=:BEURSID ' +
            ' and k.kassanr=:KASSANUMMER ';
        q.Params.ParamByName('KASSANUMMER').AsString := kassanrIni;
        q.Params.ParamByName('BEURSID').AsInteger := beursid;
        q.Open;
        while not q.Eof do
        begin
          FKassaId:=q.FieldByName('kassa_id').AsInteger;
          FKassaNr:=kassanrIni;
          FKassaOpmerkingen:=q.FieldByName('opmerkingen').AsString;
          break;
        end;
        if (FKassaId <> -1) then
        begin
          // zet deze kassaid als actieve kassa
          q.SQL.Clear;
          q.SQL.Text:='update kassa set isactief=0';
          q.ExecSQL();

          q.SQL.Clear;
          q.SQL.Text:='update kassa set ' +
                      ' isactief=1 ' +
                      ' where kassa_id=:KASSA_ID';
          q.Params.ParamByName('KASSA_ID').AsInteger := FKassaId;
          q.ExecSQL();

        end
        else
        begin
          FError:='De kassa in de inifile komt niet voor in de database. Svp een andere kiezen';
          q.SQL.Clear;
          q.SQL.Text:='update kassa set isactief=0';
          q.ExecSQL();
          if not ((lsNietIngelogd in AppSettings.WobbelLoginStatus) or (lsIngelogdAdmin in AppSettings.WobbelLoginStatus)) then
          begin
            MessageError(FError);
          end;
          retVal:=false;
        end;
      end
      else
      begin
        if (AantalActieveKassas <> 1) then
        begin
          if not ((lsNietIngelogd in AppSettings.WobbelLoginStatus) or (lsIngelogdAdmin in AppSettings.WobbelLoginStatus)) then
          begin
            MessageError(FError);
          end;
          retVal:=false;
        end
        else
        begin
          bFound:=false;
          q.SQL.Text := 'select k.kassa_id, k.kassanr, k.isactief, k.opmerkingen ' +
              ' from kassa as k, beurs as b ' +
              ' where k.beursid=b.beurs_id ' +
              ' and b.isactief=1 ' +
              ' and k.isactief=1 ';
          q.Open;
          while not q.Eof do
          begin
            FKassaId:=q.FieldByName('kassa_id').AsInteger;
            FKassaNr:=q.FieldByName('kassanr').AsString;
            FKassaOpmerkingen:=q.FieldByName('opmerkingen').AsString;
            bFound:=true;
            m_tools.SetValueInIniFile('INIT','KassaNummer',FKassaNr);
            break;
          end;
          q.Close;
          if not bFound then
          begin
            FError:='Geen actieve kassa gevonden voor deze beurs.';
            //MessageError(FError);
            retVal:=false;
          end;
        end
      end;
    finally
      q.Free;
      setKassaProperties:=retVal;
    end;
  except
    on E: Exception do
    begin
      FError:='Fout bij opvragen kassa-id: ' + E.Message;
      MessageError(FError);
    end;
  end;
end;

function TKassa.AantalActieveKassas: integer;
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
      q.SQL.Text := 'select count(*) as aantal ' +
          ' from kassa as k, beurs as b ' +
          ' where k.beursid=b.beurs_id ' +
          ' and b.isactief=1 ' +
          ' and k.isactief=1 ';
      q.Open;
      while not q.Eof do
      begin
        retVal:=q.FieldByName('aantal').AsInteger;
        break;
      end;
      q.Close;
      if (retVal = 0) then
      begin
        FError:='Geen actieve kassa gevonden voor deze beurs. Kies svp eerst een kassa.';
        //MessageError(FError);
      end
      else if (retVal = 1) then
      begin
//
      end
      else
      begin
        FError:='Meer dan 1 actieve kassa geselecteerd voor deze beurs. Kies svp eerst een kassa.';
        //MessageError(FError);
      end
    finally
      q.Free;
      AantalActieveKassas:=retVal;
    end;
  except
    on E: Exception do
    begin
      FError:='Fout bij opvragen aantal actieve kassa''s: ' + E.Message;
      raise(Exception.Create(FError));
    end;
  end;
end;


function TKassa.setKassaStatus(beursid: integer):boolean;
var
  q : TZQuery;
  bFound : boolean;
  retVal: boolean;
  //kassabedrag: double;
  //kassastatusdatumtijd: string;
  kassastatustmp: string;
begin
  // Als er geen beurs is gedefinieerd: kappen
  if (beursid < 0) then
  begin
    exit(false);
  end;
  // Als er geen kassa is gedefinieerd: kappen
  if (FKassaId < 0) then
  begin
    exit(false);
  end;

  retVal:=true;
  try
    try
      FError:='';
      FKassaStatus:=[ksOnbepaald];
      //kassabedrag:=-1;
      //kassastatusdatumtijd:='';
      kassastatustmp:='';

      q := m_querystuff.GetSQLite3QueryMdb;
      q.SQL.Clear;

      bFound:=false;
      q.SQL.Text := 'select ' +
          ' k.kassanr ' +
          ' , kos.datumtijd ' +
          ' , case when kos.kassastatusid is null then (select status from kassastatus where kassastatus_id=0) else ks.status end as status ' +
          ' , case when kb.totaalbedrag is null then -1 else kb.totaalbedrag end as bedrag ' +
          ' from beurs as b ' +
          ' inner join kassa as k on b.beurs_id=k.beursid ' +
          ' left join kassaopensluit as kos on k.kassa_id=kos.kassaid ' +
          ' left join kassastatus as ks on kos.kassastatusid=ks.kassastatus_id ' +
          ' left join kassabedrag as kb on kos.kassabedragid=kb.kassabedrag_id ' +
          ' where b.isactief=1 and k.isactief=1 ' +
          ' and b.beurs_id=:BEURSID ' +
          ' and k.kassa_id=:KASSAID ' +
          ' order by kos.datumtijd desc ' +
          ' limit 1 ';
      q.Params.ParamByName('KASSAID').AsInteger := FKassaId;
      q.Params.ParamByName('BEURSID').AsInteger := beursid;
      q.Open;
      while not q.Eof do
      begin
        //kassabedrag:=q.FieldByName('bedrag').AsFloat;
        //kassastatusdatumtijd:=q.FieldByName('datumtijd').AsString;
        kassastatustmp:=q.FieldByName('status').AsString;
        bFound:=true;
        break;
      end;
      q.Close;
      if bFound then
      begin
        if (kassastatustmp = 'onbepaald') then
        begin
          FKassaStatus:=[ksOnbepaald];
        end
        else if (kassastatustmp = 'geopend') then
        begin
          FKassaStatus:=[ksGeopend];
        end
        else if (kassastatustmp = 'gesloten') then
        begin
          FKassaStatus:=[ksGesloten];
        end;
      end
      else
      begin
        retVal:=false;
      end;
    finally
      q.Free;
      Result:=retVal;
    end;
  except
    on E: Exception do
    begin
      FError:='Fout bij opvragen kassastatus: ' + E.Message;
      MessageError(FError);
    end;
  end;
end;


function TKassa.KassaIsGekozen: boolean;
begin
  Result:=FKassaId <> -1;
end;

function TKassa.KassaStatusIsOnbepaald:boolean;
begin
  Result:=(ksOnbepaald in FKassaStatus);
end;

function TKassa.KassaStatusIsGeopend:boolean;
begin
  Result:=(ksGeopend in FKassaStatus);
end;

function TKassa.KassaStatusIsGesloten:boolean;
begin
  Result:=(ksGesloten in FKassaStatus);
end;


end.

