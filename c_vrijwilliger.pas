//------------------------------------------------------------------------------
// Name        : c_vrijwillliger
// Purpose     : Implementatie van TVrijwilliger
// Environment : Free Pascal 2.4.2, Windows XP
// Notes       : Bewaart instellingen vna een vrijwilliger (feitelijk niet meer
//               dan een account voor inloggen in de applicatie).
//               dus TODO: refactor naar een andere naam
// Author      : Vincent Houtgraaf, Bunnik
// Date        : aug 2011
// Modified    :
//------------------------------------------------------------------------------
unit c_vrijwilliger;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;


type
  TVrijwilliger = class
    private
      FUserId: integer;
      FUserIsAdmin: boolean;
      FRolnaam:string;
      FInlognaam:string;
      FError: string;


      procedure setVrijwilligerProperties;
      function getUserIsSuperAdmin(): boolean;

    public
      constructor Create;
      destructor Destroy; override;

      function VrijwilligerIsIngelogd: boolean;
      function Inloggen(inlognaam, wachtwoord:string): boolean;
      procedure ResetVrijwilligerprops;
      function Update(vrijwilliger_id:integer; inlognaam, wachtwoord,opmerkingen:string; nawid, rolid: integer; connectedwithbeurs: integer): boolean;

      property VrijwilligerId: integer read FUserId write FUserId;
      property VrijwilligerIsAdmin: boolean read FUserIsAdmin write FUserIsAdmin;
      Property Rolnaam : String read FRolnaam;
      Property Inlognaam : String read FInlognaam;
      property Error: string read FError;
      // beetje flauw want UserIsSuperAdmin is een globale variabele. Maar dan blijft het eenduidig
      property IsSuperAdmin: boolean read GetUserIsSuperAdmin;

      function AantalActieveAccounts: integer;

  end;

var
  UserIsSuperAdmin: boolean;

implementation

uses
  m_querystuff, m_tools, m_constant, c_appsettings,
  ZDataset;


constructor TVrijwilliger.Create;
begin
  inherited;
  FUserId:=-1;
  FUserIsAdmin:=false;
  UserIsSuperAdmin:=false;
  FRolnaam := '';
  FInlognaam := '';
  FError:='';
  // er kunnen argumenten zijn meegegeven aan de applicatie, bijv superadmin. Dus properties zetten in proc.
  setVrijwilligerProperties();
end;

//------------------------------------------------------------------------------
destructor TVrijwilliger.Destroy;
begin
  inherited Destroy;
end;

procedure TVrijwilliger.ResetVrijwilligerprops;
begin
  FUserId:=-1;
  FUserIsAdmin:=false;
  UserIsSuperAdmin:=false;
  FRolnaam := '';
  FInlognaam := '';
  FError:='';
end;

function TVrijwilliger.VrijwilligerIsIngelogd: boolean;
begin
  VrijwilligerIsIngelogd := FUserId<>-1;
end;

procedure TVrijwilliger.setVrijwilligerProperties();
var
  sArg:string;
  i:integer;
begin
  try
    try
      UserIsSuperAdmin:=false;
      For i:=1 to ParamCount do
      begin
        sArg:=ParamStr (i);
        if (sArg = 'superadmin') then
        begin
          UserIsSuperAdmin:=true;
        end;
      end;
    finally
      //q.Free;
    end;
  except
    on E: Exception do
    begin
      MessageError('Fout bij setVrijwilligerProperties: ' + E.Message);
    end;
  end;
end;


function TVrijwilliger.Update(vrijwilliger_id:integer; inlognaam, wachtwoord,opmerkingen:string; nawid, rolid: integer; connectedwithbeurs: integer): boolean;
begin
  Result:=true;
end;

function TVrijwilliger.Inloggen(inlognaam, wachtwoord:string): boolean;
var
  q : TZQuery;
  isIngelogd: boolean;
  aantalHits: integer;
  bid:integer;
  vid,rid,bvid:integer;
  rol:string;
begin
  FError:='';
  isIngelogd:=false;
  try
    try
      vid:=-1;
      rid:=-1;
      bvid:=-1;
      rol:='';

      q := m_querystuff.GetSQLite3QueryMdb;

      q.sql.Clear;
      q.SQL.Text := 'select count(*) as aantal ' +
                    ' from vrijwilliger as v ' +
                    ' left join beurs_vrijwilliger as bv on v.vrijwilliger_id=bv.vrijwilligerid and bv.beursid=:BEURSID ' +
                    ' where v.inlognaam=:INLOGNAAM ' +
                    ' and v.wachtwoord=:WACHTWOORD ';
      bid:=AppSettings.Beurs.BeursId;
      q.Params.ParamByName('BEURSID').AsInteger := bid;
      q.Params.ParamByName('INLOGNAAM').AsString := inlognaam;
      q.Params.ParamByName('WACHTWOORD').AsString := wachtwoord;
      q.Open;
      while not q.Eof do
      begin
        aantalHits:=q.FieldByName('aantal').AsInteger;
        break;
      end;
      q.Close;

      if (aantalHits = 0) then
      begin
        FError:='Geen geldige inloggegevens';
        isIngelogd:=false;
        //MessageError(FError);
      end
      else if (aantalHits > 1) then
      begin
        FError:='Meer dan 1 gebruiker gevonden.';
        isIngelogd:=false;
        //MessageError(FError);
      end
      else
      begin
        q.sql.Clear;
        q.SQL.Text := 'select coalesce(v.vrijwilliger_id,-1) as vid, coalesce(v.rolid,-1) as rid, coalesce(r.omschrijving,'''') as rol, coalesce(bv.beurs_vrijwilliger_id,-1) as bvid ' +
                      ' from vrijwilliger as v ' +
                      ' left join rol as r on v.rolid=r.rol_id ' +
                      ' left join beurs_vrijwilliger as bv on v.vrijwilliger_id=bv.vrijwilligerid and bv.beursid=:BEURSID ' +
                      ' where v.inlognaam=:INLOGNAAM ' +
                      ' and v.wachtwoord=:WACHTWOORD ';

        bid:=AppSettings.Beurs.BeursId;
        q.Params.ParamByName('BEURSID').AsInteger := bid;
        q.Params.ParamByName('INLOGNAAM').AsString := inlognaam;
        q.Params.ParamByName('WACHTWOORD').AsString := wachtwoord;
        q.Open;
        while not q.Eof do
        begin
          vid:=q.FieldByName('vid').AsInteger;
          rid:=q.FieldByName('rid').AsInteger;
          bvid:=q.FieldByName('bvid').AsInteger;
          rol:=q.FieldByName('rol').AsString;

          FUserId:=vid;
          FInlognaam:=inlognaam;
          FUserIsAdmin:=rol = m_constant.c_admin;
          FRolnaam:=rol;

          break;
        end;
        q.Close;

        if (bvid = -1) then
        begin
          if (rol = m_constant.c_admin) then
          begin
            isIngelogd:=true;
            //FError:='Als beheerder bent u bevoegd voor de ingestelde beurs.';
          end
          else
          begin
            isIngelogd:=false;
            FError:='Dit account is niet bevoegd voor de ingestelde beurs.';
          end;
        end
        else
        begin
          isIngelogd:=true;
        end;
      end;

      if not isIngelogd then
      begin
        ResetVrijwilligerprops;
      end;
    finally
      q.Free;
      Result:=isIngelogd;
    end;
  except
    on E: Exception do
    begin
      FError:='Fout bij inloggen: ' + E.Message;
      MessageError(FError);
    end;
  end;
end;

function TVrijwilliger.getUserIsSuperAdmin():boolean;
begin
  Result:=UserIsSuperAdmin;
end;

function TVrijwilliger.AantalActieveAccounts: integer;
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
                    ' from vrijwilliger as v ' +
                    ' left join beurs_vrijwilliger as bv on v.vrijwilliger_id=bv.vrijwilligerid and bv.beursid=:BEURSID ';
      q.Params.ParamByName('BEURSID').AsInteger := AppSettings.Beurs.BeursId;
      q.Open;
      while not q.Eof do
      begin
        retVal:=q.FieldByName('aantal').AsInteger;
        break;
      end;
      q.Close;
      if (retVal = 0) then
      begin
        FError:='Geen accounts gevonden voor deze beurs. Voer deze svp eerst in.';
        //MessageError(FError);
      end;
      Result:=retVal;
    finally
      q.Free;
    end;
  except
    on E: Exception do
    begin
      FError:='Fout bij opvragen aantal accounts: ' + E.Message;
      raise(Exception.Create(FError));
    end;
  end;
end;




end.

