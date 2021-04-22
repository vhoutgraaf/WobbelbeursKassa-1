unit formimportkassa;

{
Het idee van importeren is dit:
(Eerst even de namen: de moederdatabase (mdb) is de database waaraan een tweede database wordt toegevoegd;
 de dochterdatabase (ddb) is dus degene die wordt toegevoegd)
- Selecteer via een dialoog de ddb; deze zou een andere kassa moeten voorstellen.
- Er wordt naar gestreefd dat de
   domeintabellen (rol, artikeltype, betaalwijze)
   ondersteunende tabellen (naw, verkoper, artikel, klant, vrijwilliger, beurs, kassa)
   koppeltabellen (beurs_klant, beurs_verkoper, beurs_vrijwilliger)

   in beide databases voorkomen met dezelfde id's zodat uiteindelijk de resultaattabellen
   (kassabedrag, kassastatus,kassaopensluit,transactie, transactieartikel)
   kunnen worden geinsert in de mdb.

   Hiertoe moeten wel bij eventueel nodige aanpassingen van de tabellen, als
   waardes niet voorkomen in de mdb, updates worden gedaan van de tabellen in de ddb.

   Zorg er dus voor dat, als een record niet (compleet) voorkomt in de mdb, het record wordt
   toegevoegd in de mdb en (referenties naar) het overeenkomende
   record in de ddb worden geupdate met de nieuwe pk.
   Hierbij moet worden opgelet dat niet een pk-waarde wordt gebruikt voor insert in de mdb
   die al voorkomt in de ddb.
   Het veiligst is om een pk-waarde te nemen die 1 hoger is dan de hoogst voorkomende waarde in beide
   databases. Dat mag in onze situatie omdat we niet in een multi-user omgeving werken.

   Dus de procedure is:
   - doe alles in een transactie: die van de ddb heeft fk's uitgeschakeld. Die van de mdb heeft fk's ingeschakeld.
   - ga na of er records in de ddb zijn die een pk hebben die niet voorkomen in de mdb.
   - Als deze er zijn: bepaal een pk-waarde die 1 hoger is dan het maximum in de beiode db's
   - Doe een insert in de mdb.
   - Doe een update van alle (referentie naar) de pk in de ddb.
   - Ga de tabellen af in een logische volgorde: te beginnen bij de domeintabellen, eindigend in de resultaat tabellen.

   N.B.1. Een van de handige dingen van SQLite is dat feitelijk alle database kolommen tekst zijn.
   Hierdoor kan gemakkelijk een samenvoeging worden gemaakt van alle kolommen in een tabel om tna te gaan of
   twee records aan elkaar gelijk zijn of verschillen in de niet-pk-velden.

   N.B.2. Let er op dat alleen de records worden toegevoegd die gelden voor de in de Ddb geldende
   actieve beurs en actieve kassa. Dus bij SQL-selecties altijd erop letten dat alleen vigerende
   records worden opgehaald. Let er ook op dat bij controle of het nieuwe record al dan n iet voorkomt
   in de Mdb daarin WEL alle records worden meegnomen in de check. Dus niet dezelfde query gebruiken.





}
{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, ComCtrls,
  Contnrs,
  ZConnection;

type
    TCompareIdObject = class(TObject)
    private
      FId: string;
      FRefId1: string;
      FRefId2: string;
      FTekst: String;
      FTekstTerVergelijking: String;
      FMatchLevel: integer; // 0: perfecte match. 1: voldoende match. -1: onvoldoende match
    public
      constructor Create(AId, ARefId1, ARefId2, ATekst: String; AMatchLevel: integer);
      constructor Create(AId, ATekst: String; AMatchLevel: integer);
      property Id: string read FId write FId;
      property RefId1: string read FRefId1 write FRefId1;
      property RefId2: string read FRefId2 write FRefId2;
      property Tekst: String read FTekst write FTekst;
      property TekstTerVergelijking: String read FTekstTerVergelijking write FTekstTerVergelijking;
      property MatchLevel: integer read FMatchLevel write FMatchLevel;
   end;


type

  { TfrmImportKassa }

  TfrmImportKassa = class(TForm)
    btnFindDatabase: TButton;
    btnImporteerKassa: TButton;
    btnInfo01: TBitBtn;
    cmbImportToBeurs: TComboBox;
    lblMdbReserverKopie: TLabel;
    lblMdbReserverKopieWaarde1: TLabel;
    lblMdb: TLabel;
    lblDdbKopieWaarde: TLabel;
    lblDdbKopie: TLabel;
    lblImportlog: TLabel;
    lblMdbReserverKopieWaarde2: TLabel;
    lblMdbWaarde: TLabel;
    lblKiesDatabase: TLabel;
    lblKiesBeurs: TLabel;
    mmoLog: TMemo;
    pnlImportKassaParams: TPanel;
    pgbar: TProgressBar;
    txtDdbfilename: TEdit;
    procedure btnFindDatabaseClick(Sender: TObject);
    procedure btnImporteerKassaClick(Sender: TObject);
    procedure cmbImportToBeursChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { private declarations }

    FBeursIdMdb:integer;
    FBeursIdDdb:integer;
    FKassaIdMdb:integer;
    FKassaIdDdb:integer;
    FLogscheiding:string;

    function GetImportDatabaseFile():string;

    function AantalActieveBeurzen: integer;
    function AantalActieveKassas: integer;
    function GetCountValue(conn: TZConnection; sql,paramName,paramValue,idcol:string): integer;
    function GetUniekVerkopercode(verkopercode:string;VerkopercodeMaxSize:integer): string;
    function GetUniekKassanr(kassanr:string;kassanrMaxSize:integer): string;
    function GetAfgerondeStartindex(val1, val2:integer):integer;

    function CheckDdbDatabasebestand:boolean;
    function CheckBeursInDdb:boolean;
    function CheckKassaInDdb:boolean;

    function CheckBetaalwijze:boolean;
    function CheckArtikeltype:boolean;
    function CheckRol:boolean;
    function CheckArtikel:boolean;
    function CheckVerkoper:boolean;
    function CheckVrijwilliger:boolean;
    function ImporteerTransacties:boolean;

    procedure AddToLog(s:string);

    procedure ClearOldInfo;
  public
    { public declarations }
  end;

var
  frmImportKassa: TfrmImportKassa;

implementation

uses
  m_tools, c_appsettings, m_constant, m_wobbeldata,
  ZDataset, m_querystuff, m_error, math, crt;
{$R *.lfm}

{ TCompareIdObject }

constructor TCompareIdObject.Create(AId, ARefId1, ARefId2, ATekst: String; AMatchLevel: integer);
begin
  inherited Create;
  FId:=AId;
  FRefId1:=ARefId1;
  FRefId2:=ARefId2;
  FTekst:=ATekst;
  FTekstTerVergelijking:='';
  FMatchLevel:=AMatchLevel;
end;

constructor TCompareIdObject.Create(AId, ATekst: String; AMatchLevel: integer);
begin
  inherited Create;
  FId:=AId;
  FRefId1:='';
  FRefId2:='';
  FTekst:=ATekst;
  FTekstTerVergelijking:='';
  FMatchLevel:=AMatchLevel;
end;


{ TfrmImportKassa }

procedure TfrmImportKassa.FormCloseQuery(Sender: TObject; var CanClose: boolean
  );
begin
//
end;

procedure TfrmImportKassa.FormCreate(Sender: TObject);
begin
  FLogscheiding:='-------------------------------';
  FBeursIdDdb:=-1;
  FBeursIdMdb:=-1;
  FKassaIdMdb:=-1;
  FKassaIdDdb:=-1;

end;

procedure TfrmImportKassa.FormDestroy(Sender: TObject);
begin

end;


procedure TfrmImportKassa.FormDeactivate(Sender: TObject);
begin
//  Screen.FindForm('frmMain').SetFocus;
  // om te voorkomen dat de knoppen van het onderliggende scherm doorschijnen
  Delay(m_constant.c_DeactiveDelay_msec);
  Application.ProcessMessages;
end;


procedure TfrmImportKassa.FormActivate(Sender: TObject);
var
  fsize:integer;
begin
  m_tools.CloseOtherScreens(self);

  AddToLog(m_constant.c_CR+m_constant.c_CR+'Importscherm geopend');


  self.Color:=AppSettings.GlobalBackgroundColor;
  fsize:=m_tools.GetIntegerFromIniFile('FONTS','GlobalFontsize',c_defaultFontsize);
  self.Font.Size:=fsize;

  FBeursIdMdb:=AppSettings.Beurs.BeursId;
  FBeursIdDdb:=-1;

  lblMdbWaarde.Caption:=ExpandFileName(dmWobbel.connWobbelMdb.Database);
  m_tools.FillBeursPicklist(cmbImportToBeurs);
  m_tools.SetPicklistIdOfItemDescription(cmbImportToBeurs, AppSettings.Beurs.BeursOmschrijving);

  txtDdbfilename.Caption:='';
  mmoLog.Clear;
  lblDdbKopieWaarde.Caption:='';
  lblMdbWaarde.Caption:='';
  lblMdbReserverKopieWaarde1.Caption:='';
  lblMdbReserverKopieWaarde2.Caption:='';

  btnInfo01.Hint:='In dit scherm kunnen databases worden toegevoegd aan de hoofddatabase: de database die momenteel in gebruik is '+c_CR+
                  '("'+dmWobbel.connWobbelMdb.Database+'").'+c_CR+
                  'Enkele opmerkingen:'+c_CR+
                  '- Er volgt een melding als de hoofddatabase wordt geselecteerd.'+c_CR+
                  '- Er wordt alleen geimporteerd als de actieve beurs gelijk is in beide databases.'+c_CR+
                  '- Van de te importeren database worden alleen de gegevens toegevoegd van de kassa die in die database als "aktief" is aangemerkt waarvan bovendien de aktieve beurs ' +c_CR+
                  '  dezelfde is als de actieve beurs in de hoofddatabase.'+c_CR+
                  '- Een te importeren kassa wordt altijd toegevoegd aan de lijst met kassa''s in de hoofddatabase, met een kassanr waarin duidelijk is dat het om een import gaat.'+c_CR+
                  '  Ook al is de kassa al aanwezig in de hoofddatabase. Dat is gedaan om problemen te voorkomen als in de hoofddatabase eventueel al transacties zijn ingevoerd.' ;

  btnImporteerKassa.Enabled:=true;
end;

procedure TfrmImportKassa.btnFindDatabaseClick(Sender: TObject);
begin
  txtDdbfilename.Text:=GetImportDatabaseFile;
  ClearOldInfo;
end;

procedure TfrmImportKassa.ClearOldInfo;
begin
  lblDdbKopieWaarde.Caption:='';
  lblMdbReserverKopieWaarde1.Caption:='';
  lblMdbReserverKopieWaarde2.Caption:='';
  pgbar.Position:=0;
  mmoLog.Lines.Clear;
end;

procedure TfrmImportKassa.btnImporteerKassaClick(Sender: TObject);
var
  isOk:boolean;
  sOut1,sOut2:string;
  counter:integer;
begin
  self.Cursor:=crHourGlass;
  Application.ProcessMessages;
  isOk:=true;
  mmoLog.Clear;
  AddToLog(m_constant.c_CR+m_constant.c_CR+'Start import');

  self.Cursor:=crHourGlass;

  try
    // maak een kopie van de Ddb
    lblDdbKopieWaarde.Caption:=m_tools.BackupImportDatabaseFile(txtDdbfilename.Text);
    m_tools.LogfileAdd(m_constant.c_CR+'Database "'+txtDdbfilename.Text+'" wordt geimporteerd. '+m_constant.c_CR+
        c_TAB+'Een kopie hiervan ("'+lblDdbKopieWaarde.Caption+'") wordt hiervoor aangepast. '+m_constant.c_CR+
        c_TAB+'"'+txtDdbfilename.Text+'" blijft dus ongewijzigd.');


    // maak een kopie van de Mdb
    BackupDatabaseFile('PreImport', sOut1,sOut2);
    lblMdbReserverKopieWaarde1.Caption:=sOut1;
    lblMdbReserverKopieWaarde2.Caption:=sOut2;
    m_tools.LogfileAdd(m_constant.c_CR+'Voordat database "'+txtDdbfilename.Text+'" wordt geimporteerd zijn deze backups gemaakt: '+m_constant.c_CR+
        c_TAB+'"'+sOut1+'" en '+m_constant.c_CR+
        c_TAB+'"'+sOut2+'".');

    try
      if (dmWobbel.connWobbelDdb.Connected) then
      begin
        dmWobbel.connWobbelDdb.Disconnect;
      end;
      // werk in de kopie
      dmWobbel.connWobbelDdb.Database:=lblDdbKopieWaarde.Caption;
      dmWobbel.connWobbelDdb.Connect;

      m_tools.OpenTransactie(dmWobbel.connWobbelMdb, true);
      m_tools.OpenTransactie(dmWobbel.connWobbelDdb, false);

      pgbar.Position:=0;
      isOk:=isOk and CheckDdbDatabasebestand;
      pgbar.Position:=10;

      isOk:=isOk and CheckBetaalwijze;
      pgbar.Position:=20;
      isOk:=isOk and CheckArtikeltype;
      pgbar.Position:=30;
      isOk:=isOk and CheckRol;
      pgbar.Position:=40;

      isOk:=isOk and CheckBeursInDdb;
      pgbar.Position:=50;
      isOk:=isOk and CheckKassaInDdb;
      pgbar.Position:=60;

      isOk:=isOk and CheckVerkoper;
      pgbar.Position:=70;
      isOk:=isOk and CheckArtikel;
      pgbar.Position:=80;

      isOk:=isOk and CheckVrijwilliger;
      pgbar.Position:=90;

      isOk:=isOk and ImporteerTransacties;
      pgbar.Position:=100;
      AddToLog(FLogscheiding);

      if (isOk) then
      begin
        // tijdens testen alleen rollback
        //dmWobbel.connWobbelMdb.ExecuteDirect('rollback transaction');
        dmWobbel.connWobbelMdb.ExecuteDirect('commit transaction');
        dmWobbel.connWobbelDdb.ExecuteDirect('commit transaction');
        AddToLog('Import geslaagd');
        //btnImporteerKassa.Enabled:=false;
      end
      else
      begin

        dmWobbel.connWobbelMdb.ExecuteDirect('rollback transaction');
        dmWobbel.connWobbelDdb.ExecuteDirect('rollback transaction');
        AddToLog('Er zijn fouten opgetreden. De import is teruggedraaid');
      end;

    finally
      if (dmWobbel.connWobbelDdb.Connected) then
      begin
        dmWobbel.connWobbelDdb.Disconnect;
      end;
      self.Cursor:=crDefault;
    end;

  except
    on E: Exception do
    begin
      dmWobbel.connWobbelMdb.ExecuteDirect('rollback transaction');
      dmWobbel.connWobbelDdb.ExecuteDirect('rollback transaction');
      AddToLog('Fout bij importeren kassa: ' + E.Message);

      MessageOk('Fout bij importeren kassa: ' + E.Message);
    end;
  end;

end;

function TfrmImportKassa.CheckDdbDatabasebestand:boolean;
var
  isOk:boolean;
begin
  AddToLog(FLogscheiding);
  AddToLog('Controle Importdatabasebestand:');
  // N.B. een uitgebreidere controle is al gedaan bij selecteren van de database
  isOk:=true;

  isOk:=isOk and (txtDdbfilename.Text<>'');
  if (not isOk) then begin
    AddToLog('Fout: Kies eerst een geldige database om te importeren');
    Result:=isOk;
    exit;
  end;
  AddToLog('Importdatabasebestand OK');

  Result:=isOk;
end;

function TfrmImportKassa.CheckBeursInDdb:boolean;
var
  s:string;
  qDdb, qMdb : TZQuery;
  ix:integer;
  VObjectList: TObjectList;
  bAllFound:boolean;
  sql:string;
  iMatchLevel:integer;
  isOk:boolean;
begin
  AddToLog(FLogscheiding);
  AddToLog('Controle te importeren beurs:');
  isOk:=true;

  isOk:=isOk and (FBeursIdMdb<>-1);
  if (not isOk) then begin
    AddToLog('Fout: Kies eerst een geldige beurs om in te importeren');
    Result:=isOk;
    exit;
  end;

  // check of in de te importeren database een aktieve beurs aanwezig is
  isOk:=isOk and (AantalActieveBeurzen = 1);

  if (isOk) then
  begin
    // check of de beurzen overeenkomen
    try
      VObjectList:=TObjectList.Create;
      qDdb := m_querystuff.GetSQLite3QueryDdb;
      qMdb := m_querystuff.GetSQLite3QueryMdb;

      try
        sql:='select beurs_id, datum || '' - '' || coalesce(opmerkingen,''-'') || '' - '' || coalesce(opbrengst, ''-'') || '' - '' || coalesce(isactief, ''-'') as combinedtext from beurs where isactief=1;';
        qDdb.SQL.Clear;
        qDdb.SQL.Text:=sql;
        qDdb.Open;
        while not qDdb.Eof do
        begin
          FBeursIdDdb:=qDdb.FieldByName('beurs_id').AsInteger;
          VObjectList.Add(TCompareIdObject.Create(qDdb.FieldByName('beurs_id').AsString, qDdb.FieldByName('combinedtext').AsString, -1));
          qDdb.Next;
        end;
        qDdb.Close;

        sql:='select beurs_id, datum || '' - '' || coalesce(opmerkingen,''-'') || '' - '' || coalesce(opbrengst, ''-'') || '' - '' || coalesce(isactief, ''-'') as combinedtext from beurs where beurs_id=:BEURSID;';
        qMdb.SQL.Clear;
        qMdb.SQL.Text:=sql;
        qMdb.Params.ParamByName('BEURSID').AsInteger := FBeursIdMdb;
        qMdb.Open;
        while not qMdb.Eof do
        begin
          s:=qMdb.FieldByName('combinedtext').AsString;
          for ix:=0 to VObjectList.Count-1 do
          begin
            if ((VObjectList[ix] as TCompareIdObject).Tekst = s) then
            begin
              (VObjectList[ix] as TCompareIdObject).TekstTerVergelijking:=qMdb.FieldByName('combinedtext').AsString;

              // perfecte match
              (VObjectList[ix] as TCompareIdObject).MatchLevel:=1;
              break;
            end;
          end;

          qMdb.Next;
        end;
        qMdb.Close;


        bAllFound:=true;
        for ix:=0 to VObjectList.Count-1 do
        begin
          iMatchLevel:=(VObjectList[ix] as TCompareIdObject).MatchLevel;
          if (iMatchLevel = 0) then
          begin
            AddToLog('');
            AddToLog('Opmerking: Beurs "' + (VObjectList[ix] as TCompareIdObject).Id + '" heeft hetzelfde ID maar andere invulling in de te importeren database: ');
            AddToLog('    ("beurs_id - datum - opmerkingen - opbrengst - isactief") = ');
            AddToLog('        In de te importeren database: "');
            AddToLog('           ("' + (VObjectList[ix] as TCompareIdObject).Tekst + '")');
            AddToLog('        In de bestaande database: "');
            AddToLog('           ("' + (VObjectList[ix] as TCompareIdObject).TekstTerVergelijking + '")');
          end
          else  if (iMatchLevel = -1) then
          begin
            AddToLog('');
            AddToLog('Fout: Beurs "' + (VObjectList[ix] as TCompareIdObject).Id + '" is anders in de te importeren database: ');
            AddToLog('    ("beurs_id - datum - opmerkingen - opbrengst - isactief") = ');
            AddToLog('    ("' + (VObjectList[ix] as TCompareIdObject).Tekst + '")');

            if ((VObjectList[ix] as TCompareIdObject).TekstTerVergelijking <> '') then
            begin
              AddToLog('    In de bestaande database: ');
              AddToLog('    ("' + (VObjectList[ix] as TCompareIdObject).TekstTerVergelijking + '")');
            end;
          end;
          bAllFound:=bAllFound and (iMatchLevel >= 0);
        end;

        if (bAllFound) then
        begin
          AddToLog('OK: De actieve beurs in de te importeren database komt overeen met de beurs van de huidige database.');
        end;
        isOk:=bAllFound;

      finally
        qDdb.Free;
        qMdb.Free;

        if (VObjectList <> nil) then
        begin
          VObjectList.Free;
        end;
      end;

      //
    except
      on E: Exception do
      begin
        isOk:=false;
        AddToLog('Fout: Bij check van beurs: ' + E.Message);
      end;
    end;
  end;

  if (isOk) then
  begin
    AddToLog('Beurs is OK');
  end;

  Result:=isOk;
end;

function TfrmImportKassa.CheckKassaInDdb:boolean;
var
  isOk:boolean;
  IdNew,MaxIdDdb,MaxIdMdb:integer;
  Ref1IdNew,MaxRef1IdDdb,MaxRef1IdMdb:integer;
  Ref2IdNew,MaxRef2IdDdb,MaxRef2IdMdb:integer;
  qDdb, qDdbTmp, qMdb, qMdbTmp : TZQuery;
  KassanrMaxSize:integer;
  KassanrNieuw:string;
  counter:integer;
begin
  AddToLog(FLogscheiding);
  AddToLog('Controle te importeren kassa:');
  isOk:=true;

  // check of in de te importeren database een aktieve kassa voor de aktieve beurs aanwezig is
  isOk:=isOk and (AantalActieveKassas = 1);
  if (not isOk) then
  begin
    AddToLog('Fout: Verkeerd aantal actieve kassa''s');
    Result:=false;
    exit;
  end;

  // Voeg de actieve kassa uit de ddb toe aan de mdb, met extra opmerking
  // Update de Ddb referenties naar de kassa.

  FKassaIdDdb:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelDdb, 'select kassa_id from kassa where isactief=1', 'kassa_id', 1);
  FKassaIdMdb:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelMdb, 'select kassa_id from kassa where isactief=1', 'kassa_id', 1);

  MaxIdDdb:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelDdb, 'select max(kassa_id) as maxid from kassa', 'maxid', 1);
  MaxIdMdb:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelMdb, 'select max(kassa_id) as maxid from kassa', 'maxid', 1);

  // Altijd een nieuwe kassa aanmaken in de Mdb. Daarmee wordt iedere geimporteerde kassa in de
  // Mdb herkenbaar. Kies dus een kassa_id die uniek is in beide db's, voor het gemak
  // Dit voorkomt tevens dat aan eventueel al bestande transacties in de kassa van de Mdb
  // extra transacties worden toegevoegd. Alles voor de duidelijkheid...
  IdNew:=GetAfgerondeStartindex(MaxIdMdb, MaxIdDdb);

  try
    qDdb := m_querystuff.GetSQLite3QueryDdb;
    qDdbTmp := m_querystuff.GetSQLite3QueryDdb;
    qMdb := m_querystuff.GetSQLite3QueryMdb;
    qMdbTmp := m_querystuff.GetSQLite3QueryMdb;
    try

      qDdb.SQL.Clear;
      qDdb.SQL.Text:='select k.kassa_id, k.beursid, k.kassanr, k.isactief, k.opmerkingen  ' +
                     ' from kassa as k  ' +
                     ' inner join beurs as b on k.beursid=b.beurs_id  ' +
                     ' where k.isactief=1 and b.isactief=1;';
      qDdb.Open;
      while not qDdb.Eof do
      begin
        KassanrMaxSize:=qDdb.FieldByName('kassanr').Size;
        KassanrNieuw:=GetUniekKassanr(qDdb.FieldByName('kassanr').AsString, KassanrMaxSize);

        qMdb.SQL.Clear;
        qMdb.SQL.Text:='insert into kassa (' +
                    ' kassa_id, beursid, kassanr, isactief, opmerkingen' +
                    ' ) values(' +
                    ' :KASSA_ID, :BEURSID, :KASSANR, :ISACTIEF, :OPMERKINGEN ' +
                    ')';
        qMdb.Params.ParamByName('KASSA_ID').AsInteger := IdNew;
        qMdb.Params.ParamByName('BEURSID').AsInteger := FBeursIdMdb;
        qMdb.Params.ParamByName('KASSANR').AsString := KassanrNieuw;
        qMdb.Params.ParamByName('ISACTIEF').AsString := '0';
        qMdb.Params.ParamByName('OPMERKINGEN').AsString := Copy(KassanrNieuw + ' - ' + qDdb.FieldByName('opmerkingen').AsString, 1, qDdb.FieldByName('opmerkingen').Size);
        qMdb.ExecSQL();
        qMdb.Close;

        qDdbTmp.SQL.Clear;
        qDdbTmp.SQL.Text:='update kassa set kassa_id=:KASSAIDNEW, kassanr=:KASSANR where kassa_id=:KASSAIDOLD';
        qDdbTmp.Params.ParamByName('KASSAIDNEW').AsInteger := IdNew;
        qDdbTmp.Params.ParamByName('KASSANR').AsString := KassanrNieuw;
        qDdbTmp.Params.ParamByName('KASSAIDOLD').AsString := qDdb.FieldByName('kassa_id').AsString;
        qDdbTmp.ExecSQL();
        qDdbTmp.Close;

        qDdbTmp.SQL.Clear;
        qDdbTmp.SQL.Text:='update transactie set kassaid = :KASSAIDNEW where kassaid=:KASSAIDOLD';
        qDdbTmp.Params.ParamByName('KASSAIDNEW').AsInteger := IdNew;
        qDdbTmp.Params.ParamByName('KASSAIDOLD').AsString := qDdb.FieldByName('kassa_id').AsString;
        qDdbTmp.ExecSQL();
        qDdbTmp.Close;

        qDdbTmp.SQL.Clear;
        qDdbTmp.SQL.Text:='update kassaopensluit set kassaid = :KASSAIDNEW where kassaid=:KASSAIDOLD';
        qDdbTmp.Params.ParamByName('KASSAIDNEW').AsInteger := IdNew;
        qDdbTmp.Params.ParamByName('KASSAIDOLD').AsString := qDdb.FieldByName('kassa_id').AsString;
        qDdbTmp.ExecSQL();
        qDdbTmp.Close;

        qDdb.Next;
      end;
      qDdb.Close;

      // Voor kassabedrag moet mogelijk een serie records worden overgenomen. Bepaal daarvoor eerst het hoogste
      // kassabedrag_id dat in beide dbs voorkomt. Verhoog de kassabedrag_id's en kassabedragids in alle
      // voorkomende in de Ddb met deze maximale waarde + 1. Of duidelijker: deze maximale waarde + 1 naar boven afgerond
      // naar een honderdtal.
      MaxRef1IdDdb:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelDdb, 'select max(kassabedrag_id) as maxid from kassabedrag', 'maxid', 1);
      MaxRef1IdMdb:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelMdb, 'select max(kassabedrag_id) as maxid from kassabedrag', 'maxid', 1);
      Ref1IdNew:=GetAfgerondeStartindex(MaxRef1IdMdb, MaxRef1IdDdb);


      // van totaalbedrag evt. koma vervangen door punt en vermenigvuldigen met 1.0 om af te dwingen dat het een numerieke waarde is
      qDdb.SQL.Clear;
      qDdb.SQL.Text:='select kb.kassabedrag_id, ' +
                     ' case when kb.totaalbedrag is null or kb.totaalbedrag = '''' then 0 else 1.0 * replace(kb.totaalbedrag,'','',''.'') end as totaalbedrag, ' +
                     ' kb.totaalbedrag as totaalbedragoud, ' +
                     ' kb.opmerkingen ' +
                     ' from kassabedrag as kb ' +
                     ' inner join kassaopensluit as kos on kos.kassabedragid=kb.kassabedrag_id ' +
                     ' inner join kassa as k on kos.kassaid=k.kassa_id ' +
                     ' inner join beurs as b on k.beursid=b.beurs_id ' +
                     ' where k.isactief=1 and b.isactief=1;';
      qDdb.Open;
      counter:=0;
      while not qDdb.Eof do
      begin
        qMdb.SQL.Clear;
        qMdb.SQL.Text:='insert into kassabedrag (' +
                    ' kassabedrag_id, totaalbedrag, opmerkingen' +
                    ' ) values(' +
                    ' :KASSABEDRAG_ID, :TOTAALBEDRAG, :OPMERKINGEN ' +
                    ')';
        qMdb.Params.ParamByName('KASSABEDRAG_ID').AsInteger := Ref1IdNew + counter;
        qMdb.Params.ParamByName('TOTAALBEDRAG').AsFloat := qDdb.FieldByName('totaalbedrag').AsFloat;
        qMdb.Params.ParamByName('OPMERKINGEN').AsString := Copy('import - ' + qDdb.FieldByName('opmerkingen').AsString, 1, qDdb.FieldByName('opmerkingen').Size);
        qMdb.ExecSQL();
        qMdb.Close;

        qDdbTmp.SQL.Clear;
        qDdbTmp.SQL.Text:='update kassabedrag set kassabedrag_id=:KASSABEDRAGIDNEW where kassabedrag_id=:KASSABEDRAGIDOLD';
        qDdbTmp.Params.ParamByName('KASSABEDRAGIDNEW').AsInteger := Ref1IdNew + counter;
        qDdbTmp.Params.ParamByName('KASSABEDRAGIDOLD').AsString := qDdb.FieldByName('kassabedrag_id').AsString;
        qDdbTmp.ExecSQL();
        qDdbTmp.Close;

        qDdbTmp.SQL.Clear;
        qDdbTmp.SQL.Text:='update kassaopensluit set kassabedragid=:KASSABEDRAGIDNEW where kassabedragid=:KASSABEDRAGIDOLD';
        qDdbTmp.Params.ParamByName('KASSABEDRAGIDNEW').AsInteger := Ref1IdNew + counter;
        qDdbTmp.Params.ParamByName('KASSABEDRAGIDOLD').AsString := qDdb.FieldByName('kassabedrag_id').AsString;
        qDdbTmp.ExecSQL();
        qDdbTmp.Close;

        qDdb.Next;

        counter:=counter+1;
      end;
      qDdb.Close;

      // Doe dit ook voor kassaopensluit
      MaxRef2IdDdb:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelDdb, 'select max(kassaopensluit_id) as maxid from kassaopensluit', 'maxid', 1);
      MaxRef2IdMdb:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelMdb, 'select max(kassaopensluit_id) as maxid from kassaopensluit', 'maxid', 1);
      Ref2IdNew:=GetAfgerondeStartindex(MaxRef2IdMdb, MaxRef2IdDdb);

      qDdb.SQL.Clear;
      qDdb.SQL.Text:='select ' +
                     ' kos.kassaopensluit_id, kos.kassabedragid, ' +
                     ' kos.datumtijd, ' +
                     ' kos.kassastatusid, kos.kassaid ' +
                     ' from kassaopensluit as kos ' +
                     ' inner join kassa as k on kos.kassaid=k.kassa_id ' +
                     ' inner join beurs as b on k.beursid=b.beurs_id ' +
                     ' where k.isactief=1 and b.isactief=1;';
      qDdb.Open;
      counter:=0;
      while not qDdb.Eof do
      begin
        qMdb.SQL.Clear;
        qMdb.SQL.Text:='insert into kassaopensluit (' +
                    ' kassaopensluit_id, kassabedragid, datumtijd, kassastatusid, kassaid' +
                    ' ) values(' +
                    ' :KASSAOPENSLUIT_ID, :KASSABEDRAGID, :DATUMTIJD, :KASSASTATUSID, :KASSAID ' +
                    ')';
        qMdb.Params.ParamByName('KASSAOPENSLUIT_ID').AsInteger := Ref2IdNew + counter;
        qMdb.Params.ParamByName('KASSABEDRAGID').AsString := qDdb.FieldByName('kassabedragid').AsString;
//        qMdb.Params.ParamByName('DATUMTIJD').AsString := qDdb.FieldByName('datumtijd').AsString;
        qMdb.Params.ParamByName('DATUMTIJD').AsDateTime := qDdb.FieldByName('datumtijd').AsDateTime;
        qMdb.Params.ParamByName('KASSASTATUSID').AsString := qDdb.FieldByName('kassastatusid').AsString;
        qMdb.Params.ParamByName('KASSAID').AsString := qDdb.FieldByName('kassaid').AsString;
        qMdb.ExecSQL();
        qMdb.Close;

        qDdbTmp.SQL.Clear;
        qDdbTmp.SQL.Text:='update kassaopensluit set kassaopensluit_id=:KASSAOPENSLUITIDNEW where kassaopensluit_id=:KASSAOPENSLUITIDOLD';
        qDdbTmp.Params.ParamByName('KASSAOPENSLUITIDNEW').AsInteger := Ref2IdNew + counter;
        qDdbTmp.Params.ParamByName('KASSAOPENSLUITIDOLD').AsString := qDdb.FieldByName('kassaopensluit_id').AsString;
        qDdbTmp.ExecSQL();
        qDdbTmp.Close;

        qDdb.Next;

        counter:=counter+1;
      end;
      qDdb.Close;


      Result:=true;
    finally
      qDdb.Free;
      qDdbTmp.Free;
      qMdbTmp.Free;
      qMdb.Free;
    end;

    //
  except
    on E: Exception do
    begin
      Result:=false;
      AddToLog('Fout bij check van Kassa: ' + E.Message);
    end;
  end;

  if (Result) then
  begin
    AddToLog('Te importeren kassa OK');
  end;
end;


function TfrmImportKassa.CheckBetaalwijze:boolean;
var
  s:string;
  sql, sqlFilter:string;
  qDdb, qDdbTmp, qMdb : TZQuery;
  ix:integer;
  VObjectListMdb: TObjectList;
  bFound:boolean;
  IdNew,MaxIdDdb,MaxIdMdb:integer;
  iMatchLevel:integer;
begin
  AddToLog(FLogscheiding);
  AddToLog('Controle Betaalwijzes:');
  Result:=true;

  try
    VObjectListMdb:=TObjectList.Create;
    qDdb := m_querystuff.GetSQLite3QueryDdb;
    qDdbTmp:=m_querystuff.GetSQLite3QueryDdb;
    qMdb := m_querystuff.GetSQLite3QueryMdb;
    try
      // opmerkingen niet in combinedtext omdat daarin tekst over import komt te staan en bij een volgende import dus altijd zal verschillen
      sql:='select distinct bw.betaalwijze_id, coalesce(bw.omschrijving,'''') as omschrijving, coalesce(bw.opmerkingen, ''-'') as opmerkingen, bw.betaalwijze_id || '' - '' || coalesce(bw.omschrijving,''-'') as combinedtext ' +
        ' from betaalwijze as bw ';
      sqlFilter:= ' inner join transactie as t on t.betaalwijzeid=bw.betaalwijze_id ' +
                ' inner join kassa as k on t.kassaid=k.kassa_id ' +
                ' inner join beurs as b on k.beursid=b.beurs_id ' +
                ' where k.isactief=1 and b.isactief=1';

      // loop door de oude databasetabel; sla records op
      qMdb.SQL.Clear;
      qMdb.SQL.Text:=sql;
      qMdb.Open;
      while not qMdb.Eof do
      begin
        VObjectListMdb.Add(TCompareIdObject.Create(qMdb.FieldByName('betaalwijze_id').AsString, qMdb.FieldByName('combinedtext').AsString, -1));
        qMdb.Next;
      end;
      qMdb.Close;

      // zijn er records in de te importeren database die niet voorkomen in de bestaande database? Dan toevoegen.
      // Loop door de te importeren tabel en vergelijk met de bestaande.
      qDdb.SQL.Clear;
      qDdb.SQL.Text:=sql+sqlFilter;
      qDdb.Open;
      while not qDdb.Eof do
      begin
        bFound:=false;
        s:=qDdb.FieldByName('betaalwijze_id').AsString;
        for ix:=0 to VObjectListMdb.Count-1 do
        begin
          iMatchLevel:=-1;
          if ((VObjectListMdb[ix] as TCompareIdObject).Id = s) then
          begin
            (VObjectListMdb[ix] as TCompareIdObject).TekstTerVergelijking:=qDdb.FieldByName('combinedtext').AsString;

            // voldoende match
            iMatchLevel:=0;

            // perfecte match?
            if ((VObjectListMdb[ix] as TCompareIdObject).Tekst = qDdb.FieldByName('combinedtext').AsString) then
            begin
              iMatchLevel:=1;
            end;
            (VObjectListMdb[ix] as TCompareIdObject).MatchLevel:=iMatchLevel;

            if (iMatchLevel = 1) then
            begin
              bFound:=true;
            end;

            break;
          end;
        end;
        if (not bFound) then
        begin
          // Bepaal eerst een nieuw id: het id uit de te importeren database bestaat mogelijk
          // al in de oude database (deze kan meer records hebben dan de te importeren database).
          // Meest directe methode: bepaal de maximumwaarde van het id-veld in beide databases en
          // verhoog deze met 1 om een unieke waarde te krijgen.
          MaxIdDdb:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelDdb, 'select max(betaalwijze_id) as maxid from betaalwijze', 'maxid', 1);
          MaxIdMdb:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelMdb, 'select max(betaalwijze_id) as maxid from betaalwijze', 'maxid', 1);
          IdNew:=GetAfgerondeStartindex(MaxIdMdb, MaxIdDdb);

          qMdb.SQL.Clear;
          qMdb.SQL.Text:='insert into betaalwijze (' +
                      ' betaalwijze_id, omschrijving, opmerkingen' +
                      ' ) values(' +
                      ' :BETAALWIJZE_ID, :OMSCHRIJVING, :OPMERKINGEN ' +
                      ')';
          qMdb.Params.ParamByName('BETAALWIJZE_ID').AsInteger := IdNew;
          qMdb.Params.ParamByName('OMSCHRIJVING').AsString := qDdb.FieldByName('omschrijving').AsString;
          qMdb.Params.ParamByName('OPMERKINGEN').AsString := Copy('Toegevoegd tijdens import - ' + qDdb.FieldByName('opmerkingen').AsString, 1, qDdb.FieldByName('opmerkingen').Size);
          qMdb.ExecSQL();
          qMdb.Close;

          // update de aangepaste betaalwijzeid in de te importeren database
          qDdbTmp.SQL.Clear;
          qDdbTmp.SQL.Text:='update betaalwijze set betaalwijze_id=:BETAALWIJZEIDNIEUW where betaalwijze_id=:BETAALWIJZEIDOUD';
          qDdbTmp.Params.ParamByName('BETAALWIJZEIDNIEUW').AsInteger := IdNew;
          qDdbTmp.Params.ParamByName('BETAALWIJZEIDOUD').AsString := qDdb.FieldByName('betaalwijze_id').AsString;
          qDdbTmp.ExecSQL();
          qDdbTmp.Close;

          qDdbTmp.SQL.Clear;
          qDdbTmp.SQL.Text:='update transactie set betaalwijzeid=:BETAALWIJZEIDNIEUW where betaalwijzeid=:BETAALWIJZEIDOUD';
          qDdbTmp.Params.ParamByName('BETAALWIJZEIDNIEUW').AsInteger := IdNew;
          qDdbTmp.Params.ParamByName('BETAALWIJZEIDOUD').AsString := qDdb.FieldByName('betaalwijze_id').AsString;
          qDdbTmp.ExecSQL();
          qDdbTmp.Close;

          AddToLog('Betaalwijze toegevoegd: ');
          AddToLog('    ("ID - Omschrijving - Opmerkingen") = ("' +
                            IntToStr(IdNew) + ' - ' +
                            qDdb.FieldByName('omschrijving').AsString + ' - ' +
                            qDdb.FieldByName('opmerkingen').AsString +
                            '")');
        end;
        qDdb.Next;
      end;
      qDdb.Close;

      AddToLog('Betaalwijzes OK');
      Result:=true;

    finally
      qDdb.Free;
      qDdbTmp.Free;
      qMdb.Free;

      if (VObjectListMdb <> nil) then
      begin
        VObjectListMdb.Free;
      end;
    end;

    //
  except
    on E: Exception do
    begin
      Result:=false;
      AddToLog('Fout bij check van betaalwijzes: ' + E.Message);
    end;
  end;
end;


function TfrmImportKassa.CheckArtikeltype:boolean;
var
  s:string;
  sql, sqlFilter:string;
  qDdb, qDdbTmp, qMdb : TZQuery;
  ix:integer;
  VObjectListMdb: TObjectList;
  bFound:boolean;
  IdNew:integer;
  iMatchLevel:integer;
begin
  AddToLog(FLogscheiding);
  AddToLog('Controle Artikeltypes:');
  Result:=true;

  try
    VObjectListMdb:=TObjectList.Create;
    qDdb := m_querystuff.GetSQLite3QueryDdb;
    qDdbTmp:=m_querystuff.GetSQLite3QueryDdb;
    qMdb := m_querystuff.GetSQLite3QueryMdb;
    try
      // opmerkingen niet in combinedtext omdat daarin tekst over import komt te staan en bij een volgende import dus altijd zal verschillen
      sql:='select distinct '+
           ' at.artikeltype_id, coalesce(at.omschrijving,'''') as omschrijving, '+
           ' coalesce(at.opmerkingen, ''-'') as opmerkingen, at.artikeltype_id || '' - '' || coalesce(at.omschrijving,''-'') as combinedtext ' +
           ' from artikeltype as at ';
      sqlFilter:=' inner join artikel as a on at.artikeltype_id=a.artikeltypeid ' +
                 ' inner join transactieartikel as ta on ta.artikelid=a.artikel_id ' +
                 ' inner join transactie as t on ta.transactieid=t.transactie_id ' +
                 ' inner join kassa as k on t.kassaid=k.kassa_id ' +
                 ' inner join beurs as b on k.beursid=b.beurs_id ' +
                 ' where k.isactief=1 and b.isactief=1;';

      // loop door de oude databasetabel; sla records op
      qMdb.SQL.Clear;
      qMdb.SQL.Text:=sql;
      qMdb.Open;
      while not qMdb.Eof do
      begin
        VObjectListMdb.Add(TCompareIdObject.Create(qMdb.FieldByName('artikeltype_id').AsString, qMdb.FieldByName('combinedtext').AsString, -1));
        qMdb.Next;
      end;
      qMdb.Close;

      // zijn er records in de te importeren database die niet voorkomen in de bestaande database? Dan toevoegen.
      // Loop door de te importeren tabel en vergelijk met de bestaande.
      qDdb.SQL.Clear;
      qDdb.SQL.Text:=sql+sqlFilter;
      qDdb.Open;
      while not qDdb.Eof do
      begin
        bFound:=false;
        s:=qDdb.FieldByName('artikeltype_id').AsString;
        for ix:=0 to VObjectListMdb.Count-1 do
        begin
          iMatchLevel:=-1;
          if ((VObjectListMdb[ix] as TCompareIdObject).Id = s) then
          begin
            (VObjectListMdb[ix] as TCompareIdObject).TekstTerVergelijking:=qDdb.FieldByName('combinedtext').AsString;

            // voldoende match
            iMatchLevel:=0;

            // perfecte match?
            if ((VObjectListMdb[ix] as TCompareIdObject).Tekst = qDdb.FieldByName('combinedtext').AsString) then
            begin
              iMatchLevel:=1;
            end;
            (VObjectListMdb[ix] as TCompareIdObject).MatchLevel:=iMatchLevel;

            if (iMatchLevel = 1) then
            begin
              bFound:=true;
            end;

            break;
          end;
        end;

        if (not bFound) then
        begin
          // toevoegen aan de Mdb
          qMdb.SQL.Clear;
          qMdb.SQL.Text:='insert into artikeltype (' +
                      ' artikeltype_id, omschrijving, opmerkingen' +
                      ' ) values(' +
                      ' :ARTIKELTYPE_ID, :OMSCHRIJVING, :OPMERKINGEN ' +
                      ')';
          qMdb.Params.ParamByName('ARTIKELTYPE_ID').AsString := qDdb.FieldByName('artikeltype_id').AsString;
          qMdb.Params.ParamByName('OMSCHRIJVING').AsString := qDdb.FieldByName('omschrijving').AsString;
          qMdb.Params.ParamByName('OPMERKINGEN').AsString := Copy('Toegevoegd tijdens import - ' + qDdb.FieldByName('opmerkingen').AsString, 1, qDdb.FieldByName('opmerkingen').Size);
          qMdb.ExecSQL();
          qMdb.Close;

          AddToLog('');
          AddToLog('Artikeltype "' + (VObjectListMdb[ix] as TCompareIdObject).Id + '" toegevoegd: ');
          AddToLog('    ("ID - Omschrijving - Opmerkingen") = ("' +
                            qDdb.FieldByName('artikeltype_id').AsString + ' - ' +
                            qDdb.FieldByName('omschrijving').AsString + ' - ' +
                            qDdb.FieldByName('opmerkingen').AsString +
                            '")');
        end;



        qDdb.Next;
      end;
      qDdb.Close;

      AddToLog('Artikeltypes OK');
      Result:=true;

    finally
      qDdb.Free;
      qDdbTmp.Free;
      qMdb.Free;
      if (VObjectListMdb <> nil) then
      begin
        VObjectListMdb.Free;
      end;

    end;

    //
  except
    on E: Exception do
    begin
      Result:=false;
      AddToLog('Fout bij check van Artikeltypes: ' + E.Message);
    end;
  end;
end;

function TfrmImportKassa.CheckArtikel:boolean;
var
  s:string;
  sql, sqlFilter:string;
  qDdb, qDdbTmp, qMdb : TZQuery;
  ix:integer;
  VObjectListMdb: TObjectList;
  bFound:boolean;
  IdNew,MaxIdDdb,MaxIdMdb:integer;
  iMatchLevel:integer;
  artikelCounter:integer;
begin
  AddToLog(FLogscheiding);
  AddToLog('Controle Artikelen:');
  Result:=true;

  try
    VObjectListMdb:=TObjectList.Create;
    qDdb := m_querystuff.GetSQLite3QueryDdb;
    qDdbTmp:=m_querystuff.GetSQLite3QueryDdb;
    qMdb := m_querystuff.GetSQLite3QueryMdb;
    try
      // opmerkingen niet in combinedtext omdat daarin tekst over import komt te staan en bij een volgende import dus altijd zal verschillen
      // van prijs evt. koma vervangen door punt en vermenigvuldigen met 1.0 om af te dwingen dat het een numerieke waarde is
      sql:='select distinct ' +
           ' a.artikel_id, coalesce(a.verkoperid,'''') as verkoperid, coalesce(a.artikeltypeid,'''') as artikeltypeid, ' +
           ' coalesce(a.omschrijving,'''') as omschrijving, coalesce(a.opmerkingen,'''') as opmerkingen, ' +
           ' coalesce(a.code, '''') as code, ' +
           ' case when a.prijs is null or a.prijs = '''' then 0 else replace(a.prijs,'','',''.'') end as prijs, ' +
           ' coalesce(a.prijs, '''') as prijsoud, ' +
           ' a.datumtijdinvoer, a.datumtijdwijzigen, ' +
           ' a.artikel_id || '' - '' || coalesce(a.verkoperid,''-'') || '' - '' || coalesce(a.code, ''-'') || '' - '' || coalesce(a.prijs, ''-'') || '' - '' || coalesce(a.omschrijving, ''-'') || '' - '' || coalesce(a.artikeltypeid, ''-'') as combinedtext ' +
           ' from artikel as a ';
      sqlFilter:=' inner join transactieartikel as ta on ta.artikelid=a.artikel_id ' +
                 ' inner join transactie as t on ta.transactieid=t.transactie_id ' +
                 ' inner join kassa as k on t.kassaid=k.kassa_id ' +
                 ' inner join beurs as b on k.beursid=b.beurs_id ' +
                 ' where k.isactief=1 and b.isactief=1;';

      // loop door de oude databasetabel; sla records op
      qMdb.SQL.Clear;
      qMdb.SQL.Text:=sql;
      qMdb.Open;
      while not qMdb.Eof do
      begin
        VObjectListMdb.Add(TCompareIdObject.Create(qMdb.FieldByName('artikel_id').AsString,
                                                qMdb.FieldByName('verkoperid').AsString,
                                                qMdb.FieldByName('artikeltypeid').AsString,
                                                qMdb.FieldByName('combinedtext').AsString, -1));
        qMdb.Next;
      end;
      qMdb.Close;

      // zijn er records in de te importeren database die niet voorkomen in de bestaande database? Dan toevoegen.
      // Loop door de te importeren tabel en vergelijk met de bestaande.
      qDdb.SQL.Clear;
      qDdb.SQL.Text:=sql+sqlFilter;
      qDdb.Open;
      artikelCounter:=0;
      while not qDdb.Eof do
      begin
        bFound:=false;
        s:=qDdb.FieldByName('artikel_id').AsString;
        for ix:=0 to VObjectListMdb.Count-1 do
        begin
          iMatchLevel:=-1;
          if ((VObjectListMdb[ix] as TCompareIdObject).Id = s) then
          begin
            (VObjectListMdb[ix] as TCompareIdObject).TekstTerVergelijking:=qDdb.FieldByName('combinedtext').AsString;

            // voldoende match
            iMatchLevel:=0;

            // perfecte match?
            if ((VObjectListMdb[ix] as TCompareIdObject).Tekst = qDdb.FieldByName('combinedtext').AsString) then
            begin
              iMatchLevel:=1;
            end;
            (VObjectListMdb[ix] as TCompareIdObject).MatchLevel:=iMatchLevel;

            if (iMatchLevel = 1) then
            begin
              bFound:=true;
            end;

            break;
          end;
        end;
        if (not bFound) then
        begin
          // Bepaal eerst een nieuw id: het id uit de te importeren database bestaat mogelijk
          // al in de oude database (deze kan meer records hebben dan de te importeren database).
          // Meest directe methode: bepaal de maximumwaarde van het id-veld in beide databases en
          // verhoog deze met 1 om een unieke waarde te krijgen.
          MaxIdDdb:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelDdb, 'select max(artikel_id) as maxid from artikel', 'maxid', 1);
          MaxIdMdb:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelMdb, 'select max(artikel_id) as maxid from artikel', 'maxid', 1);
          IdNew:=GetAfgerondeStartindex(MaxIdMdb, MaxIdDdb);

          qMdb.SQL.Clear;
          qMdb.SQL.Text:='insert into artikel (' +
                      ' artikel_id, verkoperid, code, prijs, omschrijving, opmerkingen, artikeltypeid' +
                      ' ) values(' +
                      ' :ARTIKEL_ID, :VERKOPERID, :CODE, :PRIJS, :OMSCHRIJVING, :OPMERKINGEN, :ARTIKELTYPEID ' +
                      ')';
          qMdb.Params.ParamByName('ARTIKEL_ID').AsInteger := IdNew;
          qMdb.Params.ParamByName('VERKOPERID').AsString := qDdb.FieldByName('verkoperid').AsString;
          qMdb.Params.ParamByName('CODE').AsString := qDdb.FieldByName('code').AsString;
          qMdb.Params.ParamByName('PRIJS').AsString := qDdb.FieldByName('prijs').AsString;
          qMdb.Params.ParamByName('OMSCHRIJVING').AsString := qDdb.FieldByName('omschrijving').AsString;
          qMdb.Params.ParamByName('OPMERKINGEN').AsString := Copy('Toegevoegd tijdens import - ' + qDdb.FieldByName('opmerkingen').AsString, 1, qDdb.FieldByName('opmerkingen').Size);
          qMdb.Params.ParamByName('ARTIKELTYPEID').AsString := qDdb.FieldByName('artikeltypeid').AsString;


          qMdb.ExecSQL();
          qMdb.Close;

          // update de aangepaste id in de te importeren database
          qDdbTmp.SQL.Clear;
          qDdbTmp.SQL.Text:='update artikel set artikel_id=:ARTIKELIDNIEUW where artikel_id=:ARTIKELIDOUD';
          qDdbTmp.Params.ParamByName('ARTIKELIDNIEUW').AsInteger := IdNew;
          qDdbTmp.Params.ParamByName('ARTIKELIDOUD').AsString := qDdb.FieldByName('artikel_id').AsString;
          qDdbTmp.ExecSQL();
          qDdbTmp.Close;

          qDdbTmp.SQL.Clear;
          qDdbTmp.SQL.Text:='update transactieartikel set artikelid=:ARTIKELIDNIEUW where artikelid=:ARTIKELIDOUD';
          qDdbTmp.Params.ParamByName('ARTIKELIDNIEUW').AsInteger := IdNew;
          qDdbTmp.Params.ParamByName('ARTIKELIDOUD').AsString := qDdb.FieldByName('artikel_id').AsString;
          qDdbTmp.ExecSQL();
          qDdbTmp.Close;

          inc(artikelCounter);
//          AddToLog('Artikel toegevoegd: ');
//          AddToLog('    ("ID - verkoperid - code - prijs - omschrijving - artikeltypeid") = ("' +
//                            IntToStr(IdNew) + ' - ' +
//                            qDdb.FieldByName('verkoperid').AsString + ' - ' +
//                            qDdb.FieldByName('code').AsString + ' - ' +
//                            qDdb.FieldByName('prijs').AsString + ' - ' +
//                            qDdb.FieldByName('omschrijving').AsString + ' - ' +
//                            qDdb.FieldByName('artikeltypeid').AsString +
//                            '")');
        end;
        qDdb.Next;
      end;
      qDdb.Close;


      if (artikelCounter = 0) then
      begin
        AddToLog('Geen artikelen toegevoegd');
      end
      else if (artikelCounter = 1) then
      begin
        AddToLog('1 artikel toegevoegd');
      end
      else
      begin
        AddToLog(IntToStr(artikelCounter) + ' artikelen toegevoegd');
      end;

      AddToLog('Artikelen OK');
      Result:=true;

    finally
      qDdb.Free;
      qDdbTmp.Free;
      qMdb.Free;
      if (VObjectListMdb <> nil) then
      begin
        VObjectListMdb.Free;
      end;

    end;

    //
  except
    on E: Exception do
    begin
      Result:=false;
      AddToLog('Fout bij check van Artikelen: ' + E.Message);
    end;
  end;
end;


function TfrmImportKassa.CheckVerkoper:boolean;
var
  VerkoperId,Verkopercode:string;
  qDdb, qDdbTmp, qMdb : TZQuery;
  ix:integer;
  VObjectListMdb: TObjectList;
  bVerkoperIdFound,bVerkopercodeFound:boolean;
  newId,MaxIdDdb,MaxIdMdb:integer;
  NawIdDdb,NawIdMdb:integer;
  newNawId:string;
  VerkopercodeUniek:string;
  sql, sqlFilter:string;
  VerkopercodeMaxSize:integer;
  iMatchLevel:integer;
begin
  AddToLog(FLogscheiding);
  AddToLog('Controle Verkopers:');
  Result:=true;

  try
    VObjectListMdb:=TObjectList.Create;
    qDdb := m_querystuff.GetSQLite3QueryDdb;
    qDdbTmp:=m_querystuff.GetSQLite3QueryDdb;
    qMdb := m_querystuff.GetSQLite3QueryMdb;
    try
      // opmerkingen niet in combinedtext omdat daarin tekst over import komt te staan en bij een volgende import dus altijd zal verschillen
      sql:='select distinct ' +
          ' v.verkoper_id, coalesce(v.nawid,'''') as nawid, coalesce(v.verkopercode,'''') as verkopercode, ' +
          ' coalesce(v.saldobetalingcontant,'''') as saldobetalingcontant, coalesce(v.rekeningnummer,'''') as rekeningnummer, ' +
          ' coalesce(v.rekeningopnaam,'''') as rekeningopnaam, coalesce(v.rekeningbanknaam,'''') as rekeningbanknaam, ' +
          ' coalesce(v.rekeningplaats,'''') as rekeningplaats, coalesce(v.opmerkingen,'''') as verkoperopmerkingen, ' +
          ' coalesce(n.naw_id,'''') as naw_id, coalesce(n.aanhef,'''') as aanhef, coalesce(n.voorletters,'''') as voorletters, ' +
          ' coalesce(n.tussenvoegsel,'''') as tussenvoegsel, coalesce(n.achternaam,'''') as achternaam, ' +
          ' coalesce(n.straat,'''') as straat, coalesce(n.huisnr,'''') as huisnr, ' +
          ' coalesce(n.huisnrtoevoeging,'''') as huisnrtoevoeging, coalesce(n.postcode,'''') as postcode, ' +
          ' coalesce(n.woonplaats,'''') as woonplaats, coalesce(n.telefoonmobiel1,'''') as telefoonmobiel1, ' +
          ' coalesce(n.telefoonmobiel2,'''') as telefoonmobiel2, coalesce(n.telefoonvast,'''') as telefoonvast, ' +
          ' coalesce(n.email,'''') as email, coalesce(n.datumtijdinvoeren,'''') as nawdatumtijdinvoeren, ' +
          ' coalesce(n.datumtijdwijzigen,'''') as nawdatumtijdwijzigen, ' +
          ' coalesce(bv.beurs_verkoper_id,'''') as beurs_verkoper_id, coalesce(bv.opmerkingen,'''') as beursverkoperopmerkingen, ' +
          ' coalesce(v.verkopercode, ''-'') || '' - '' || v.verkoper_id || '' - '' || coalesce(v.nawid, ''-'') || '' - '' || coalesce(v.saldobetalingcontant, ''-'') || '' - '' || coalesce(v.rekeningnummer, ''-'') || '' - '' || coalesce(v.rekeningopnaam, ''-'') || '' - '' || coalesce(v.rekeningbanknaam, ''-'') || '' - '' || coalesce(v.rekeningplaats, ''-'') || '' - '' || n.naw_id || '' - '' || coalesce(n.aanhef, ''-'') || '' - '' || coalesce(n.voorletters, ''-'') || '' - '' || coalesce(n.tussenvoegsel, ''-'') || '' - '' || coalesce(n.achternaam, ''-'') || '' - '' || coalesce(n.straat, ''-'') || '' - '' || coalesce(n.huisnr, ''-'') || '' - '' || coalesce(n.huisnrtoevoeging, ''-'') || '' - '' || coalesce(n.postcode, ''-'') || '' - '' || coalesce(n.woonplaats, ''-'') || '' - '' || coalesce(n.telefoonmobiel1, ''-'') || '' - '' || coalesce(n.telefoonmobiel2, ''-'') || '' - '' || coalesce(n.telefoonvast, ''-'') || '' - '' || coalesce(n.email, ''-'') as combinedtext ' +
          ' from verkoper as v ' +
          ' left join naw as n on v.nawid=n.naw_id ' +
          ' left join beurs_verkoper as bv on v.verkoper_id=bv.verkoperid ';
      sqlFilter:=' inner join artikel as a on a.verkoperid=v.verkoper_id ' +
                ' inner join transactieartikel as ta on ta.artikelid=a.artikel_id ' +
                ' inner join transactie as t on ta.transactieid=t.transactie_id ' +
                ' inner join kassa as k on t.kassaid=k.kassa_id ' +
                ' inner join beurs as b on k.beursid=b.beurs_id ' +
                ' where k.isactief=1 and b.isactief=1';


      // loop door de oude databasetabel; sla records op
      qMdb.SQL.Clear;
      qMdb.SQL.Text:=sql;
      qMdb.Open;
      while not qMdb.Eof do
      begin
        VObjectListMdb.Add(TCompareIdObject.Create(qMdb.FieldByName('verkoper_id').AsString,
                                                   qMdb.FieldByName('verkopercode').AsString,
                                                   qMdb.FieldByName('nawid').AsString,
                                                   qMdb.FieldByName('combinedtext').AsString,
                                                   -1));
        qMdb.Next;
      end;
      qMdb.Close;

      // Zijn er records in de te importeren database die niet voorkomen in de bestaande database? Dan toevoegen.
      // Check op verkoper_id EN op Verkopercode. De laatste is ommers de waarde die uniek moet zijn over de hele
      // beurs omdat dit het bepalende id is van de verkoper. Ieder artikel is gemerkt met Verkopercode.
      // Loop door de te importeren tabel en vergelijk met de bestaande.
      qDdb.SQL.Clear;
      qDdb.SQL.Text:=sql+sqlFilter;
      qDdb.Open;
      while not qDdb.Eof do
      begin
        bVerkoperIdFound:=false;
        VerkoperId:=qDdb.FieldByName('verkoper_id').AsString;
        Verkopercode:=qDdb.FieldByName('verkopercode').AsString;
        VerkopercodeMaxSize:=qDdb.FieldByName('verkopercode').Size;
        for ix:=0 to VObjectListMdb.Count-1 do
        begin
          iMatchLevel:=-1;
          if ((VObjectListMdb[ix] as TCompareIdObject).Id = VerkoperId) then
          begin
            (VObjectListMdb[ix] as TCompareIdObject).TekstTerVergelijking:=qDdb.FieldByName('combinedtext').AsString;

            // voldoende match
            iMatchLevel:=0;

            // we hebben een match op verkoperid, maar is de rest gelijk?
            if (qDdb.FieldByName('combinedtext').AsString = (VObjectListMdb[ix] as TCompareIdObject).Tekst) then
            begin
              iMatchLevel:=2;
              (*
              AddToLog('');
              AddToLog('Opmerking: Verkoper "' + VerkoperId + '" heeft hetzelfde ID maar andere invulling in de te importeren database: ');
              AddToLog('    ("Verkopercode - ID - nawid - saldobetalingcontant - rekeningnummer - rekeningopnaam - rekeningbanknaam - rekeningplaats - naw_id - aanhef - voorletters - tussenvoegsel - achternaam - straat - huisnr - huisnrtoevoeging - postcode - woonplaats - telefoonmobiel1 - telefoonmobiel2 - telefoonvast - email") = ');
              AddToLog('        In de te importeren database: "');
              AddToLog('           ("' + qDdb.FieldByName('combinedtext').AsString + '")');
              AddToLog('        In de bestaande database: "');
              AddToLog('           ("' + (VObjectListMdb[ix] as TCompareIdObject).Tekst + '")');
              *)
            end;
            (VObjectListMdb[ix] as TCompareIdObject).MatchLevel:=iMatchLevel;

            bVerkoperIdFound:=true;
            break;
          end;
        end;
        bVerkopercodeFound:=false;
        for ix:=0 to VObjectListMdb.Count-1 do
        begin
          iMatchLevel:=-1;
          if ((VObjectListMdb[ix] as TCompareIdObject).RefId1 = Verkopercode) then
          begin
            (VObjectListMdb[ix] as TCompareIdObject).TekstTerVergelijking:=qDdb.FieldByName('combinedtext').AsString;

            // voldoende match
            iMatchLevel:=1;

            // we hebben een match op Verkopercode, maar is de rest gelijk?
            if (qDdb.FieldByName('combinedtext').AsString = (VObjectListMdb[ix] as TCompareIdObject).Tekst) then
            begin
              iMatchLevel:=2;

              (*
              AddToLog('');
              AddToLog('Opmerking: Verkoper "' + Verkopercode + '" heeft dezelfde Verkopercode maar andere invulling in de te importeren database: ');
              AddToLog('    ("Verkopercode - ID - nawid - saldobetalingcontant - rekeningnummer - rekeningopnaam - rekeningbanknaam - rekeningplaats - naw_id - aanhef - voorletters - tussenvoegsel - achternaam - straat - huisnr - huisnrtoevoeging - postcode - woonplaats - telefoonmobiel1 - telefoonmobiel2 - telefoonvast - email") = ');
              AddToLog('        In de te importeren database: "');
              AddToLog('           ("' + qDdb.FieldByName('combinedtext').AsString + '")');
              AddToLog('        In de bestaande database: "');
              AddToLog('           ("' + (VObjectListMdb[ix] as TCompareIdObject).Tekst + '")');
              *)
            end;
            (VObjectListMdb[ix] as TCompareIdObject).MatchLevel:=iMatchLevel;

            bVerkopercodeFound:=true;
            break;
          end;
        end;


        if ((not bVerkoperIdFound) or (not bVerkopercodeFound)) then
        begin
          // Bepaal eerst een nieuw verkoperid: het id uit de te importeren database bestaat mogelijk
          // al in de oude database (deze kan meer records hebben dan de te importeren database).
          // Meest directe methode: bepaal de maximumwaarde van het id-veld in beide databases en
          // verhoog deze met 1 om een unieke waarde te krijgen.
          MaxIdDdb:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelDdb, 'select max(verkoper_id) as maxid from verkoper', 'maxid', 1);
          MaxIdMdb:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelMdb, 'select max(verkoper_id) as maxid from verkoper', 'maxid', 1);
          newId:=GetAfgerondeStartindex(MaxIdMdb, MaxIdDdb);

          // doe hetzelfde voor naw
          newNawId:='';
          if (qDdb.FieldByName('naw_id').AsString <> '') then
          begin
            NawIdDdb:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelDdb, 'select max(naw_id) as maxid from naw', 'maxid', 1);
            NawIdMdb:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelMdb, 'select max(naw_id) as maxid from naw', 'maxid', 1);
            newNawId:=IntToStr(GetAfgerondeStartindex(NawIdMdb, NawIdDdb));
          end;

          // Als alleen verkoperid anders is: kopieer naar de Mdb met een nieuw verkoperid en een nieuw verkopercode: die moet uniek blijven
          // Als Verkopercode anders is: kopieer naar de Mdb met een nieuw verkoperid. Voor de eenduidigheid: ook een nieuw Verkopercode
          VerkopercodeUniek:=GetUniekVerkopercode(verkopercode,VerkopercodeMaxSize);

          if (newNawId <> '') then
          begin
            qMdb.SQL.Clear;
            qMdb.SQL.Text:='insert into naw (' +
                        ' naw_id, aanhef, voorletters, tussenvoegsel, achternaam, straat, huisnr, huisnrtoevoeging, postcode, woonplaats, telefoonmobiel1, telefoonmobiel2, telefoonvast, email' +
                        ' ) values(' +
                        ' :NAW_ID, :AANHEF, :VOORLETTERS, :TUSSENVOEGSEL, :ACHTERNAAM, :STRAAT, :HUISNR, :HUISNRTOEVOEGING, :POSTCODE, :WOONPLAATS, :TELEFOONMOBIEL1, :TELEFOONMOBIEL2, :TELEFOONVAST, :EMAIL ' +
                        ')';
            qMdb.Params.ParamByName('NAW_ID').AsString := newNawId;
            qMdb.Params.ParamByName('AANHEF').AsString := qDdb.FieldByName('aanhef').AsString;
            qMdb.Params.ParamByName('VOORLETTERS').AsString := qDdb.FieldByName('voorletters').AsString;
            qMdb.Params.ParamByName('TUSSENVOEGSEL').AsString := qDdb.FieldByName('tussenvoegsel').AsString;
            qMdb.Params.ParamByName('ACHTERNAAM').AsString := qDdb.FieldByName('achternaam').AsString;
            qMdb.Params.ParamByName('STRAAT').AsString := qDdb.FieldByName('straat').AsString;
            qMdb.Params.ParamByName('HUISNR').AsString := qDdb.FieldByName('huisnr').AsString;
            qMdb.Params.ParamByName('HUISNRTOEVOEGING').AsString := qDdb.FieldByName('huisnrtoevoeging').AsString;
            qMdb.Params.ParamByName('POSTCODE').AsString := qDdb.FieldByName('postcode').AsString;
            qMdb.Params.ParamByName('WOONPLAATS').AsString := qDdb.FieldByName('woonplaats').AsString;
            qMdb.Params.ParamByName('TELEFOONMOBIEL1').AsString := qDdb.FieldByName('telefoonmobiel1').AsString;
            qMdb.Params.ParamByName('TELEFOONMOBIEL2').AsString := qDdb.FieldByName('telefoonmobiel2').AsString;
            qMdb.Params.ParamByName('TELEFOONVAST').AsString := qDdb.FieldByName('telefoonvast').AsString;
            qMdb.Params.ParamByName('EMAIL').AsString := qDdb.FieldByName('email').AsString;
            qMdb.ExecSQL();
            qMdb.Close;

            // update de aangepaste id in de te importeren database
            qDdbTmp.SQL.Clear;
            qDdbTmp.SQL.Text:='update naw set naw_id=:NAWIDNIEUW where naw_id=:NAWIDOUD';
            qDdbTmp.Params.ParamByName('NAWIDNIEUW').AsString := newNawId;
            qDdbTmp.Params.ParamByName('NAWIDOUD').AsString := qDdb.FieldByName('naw_id').AsString;
            qDdbTmp.ExecSQL();
            qDdbTmp.Close;

            qDdbTmp.SQL.Clear;
            qDdbTmp.SQL.Text:='update verkoper set nawid=:NAWIDNIEUW where nawid=:NAWIDOUD';
            qDdbTmp.Params.ParamByName('NAWIDNIEUW').AsString := newNawId;
            qDdbTmp.Params.ParamByName('NAWIDOUD').AsString := qDdb.FieldByName('naw_id').AsString;
            qDdbTmp.ExecSQL();
            qDdbTmp.Close;

            qDdbTmp.SQL.Clear;
            qDdbTmp.SQL.Text:='update vrijwilliger set nawid=:NAWIDNIEUW where nawid=:NAWIDOUD';
            qDdbTmp.Params.ParamByName('NAWIDNIEUW').AsString := newNawId;
            qDdbTmp.Params.ParamByName('NAWIDOUD').AsString := qDdb.FieldByName('naw_id').AsString;
            qDdbTmp.ExecSQL();
            qDdbTmp.Close;
          end;


          // verkoperid:
          qMdb.SQL.Clear;
          qMdb.SQL.Text:='insert into verkoper (' +
                      ' verkoper_id, nawid, verkopercode, saldobetalingcontant, rekeningnummer, rekeningopnaam, rekeningbanknaam, rekeningplaats, opmerkingen' +
                      ' ) values(' +
                      ' :VERKOPER_ID, :NAWID, :VERKOPERCODE, :SALDOBETALINGCONTANT, :REKENINGNUMMER, :REKENINGOPNAAM, :REKENINGBANKNAAM, :REKENINGPLAATS, :OPMERKINGEN ' +
                      ')';
          qMdb.Params.ParamByName('VERKOPER_ID').AsInteger := newId;
          qMdb.Params.ParamByName('NAWID').AsString := newNawId;
          qMdb.Params.ParamByName('VERKOPERCODE').AsString := VerkopercodeUniek;
          qMdb.Params.ParamByName('SALDOBETALINGCONTANT').AsString := qDdb.FieldByName('saldobetalingcontant').AsString;
          qMdb.Params.ParamByName('REKENINGNUMMER').AsString := qDdb.FieldByName('rekeningnummer').AsString;
          qMdb.Params.ParamByName('REKENINGOPNAAM').AsString := qDdb.FieldByName('rekeningopnaam').AsString;
          qMdb.Params.ParamByName('REKENINGBANKNAAM').AsString := qDdb.FieldByName('rekeningbanknaam').AsString;
          qMdb.Params.ParamByName('REKENINGPLAATS').AsString := qDdb.FieldByName('rekeningplaats').AsString;
          qMdb.Params.ParamByName('OPMERKINGEN').AsString := Copy('Toegevoegd tijdens import - ' + qDdb.FieldByName('verkoperopmerkingen').AsString, 1, qDdb.FieldByName('verkoperopmerkingen').Size);
          qMdb.ExecSQL();
          qMdb.Close;

          if (qDdb.FieldByName('beurs_verkoper_id').AsString <> '') then
          begin
            qMdb.SQL.Clear;
            qMdb.SQL.Text:='insert into beurs_verkoper (' +
                        ' beursid,verkoperid,opmerkingen' +
                        ' ) values(' +
                        ' :BEURSID,:VERKOPERID,:OPMERKINGEN ' +
                        ')';
            qMdb.Params.ParamByName('BEURSID').AsInteger := FBeursIdMdb;
            qMdb.Params.ParamByName('VERKOPERID').AsInteger := newId;
            qMdb.Params.ParamByName('OPMERKINGEN').AsString := Copy('import - van kassa ' + IntToStr(FKassaIdDdb), 1, qDdb.FieldByName('beursverkoperopmerkingen').Size);
            qMdb.ExecSQL();
            qMdb.Close;
          end;

          // update de aangepaste id in de te importeren database
          qDdbTmp.SQL.Clear;
          qDdbTmp.SQL.Text:='update verkoper set verkoper_id=:VERKOPERIDNIEUW where verkoper_id=:VERKOPERIDOUD';
          qDdbTmp.Params.ParamByName('VERKOPERIDNIEUW').AsInteger := newId;
          qDdbTmp.Params.ParamByName('VERKOPERIDOUD').AsString := qDdb.FieldByName('verkoper_id').AsString;
          qDdbTmp.ExecSQL();
          qDdbTmp.Close;

          qDdbTmp.SQL.Clear;
          qDdbTmp.SQL.Text:='update artikel set verkoperid=:VERKOPERIDNIEUW where verkoperid=:VERKOPERIDOUD';
          qDdbTmp.Params.ParamByName('VERKOPERIDNIEUW').AsInteger := newId;
          qDdbTmp.Params.ParamByName('VERKOPERIDOUD').AsString := qDdb.FieldByName('verkoper_id').AsString;
          qDdbTmp.ExecSQL();
          qDdbTmp.Close;

          qDdbTmp.SQL.Clear;
          qDdbTmp.SQL.Text:='update beurs_verkoper set verkoperid=:VERKOPERIDNIEUW where verkoperid=:VERKOPERIDOUD';
          qDdbTmp.Params.ParamByName('VERKOPERIDNIEUW').AsInteger := newId;
          qDdbTmp.Params.ParamByName('VERKOPERIDOUD').AsString := qDdb.FieldByName('verkoper_id').AsString;
          qDdbTmp.ExecSQL();
          qDdbTmp.Close;

          // Verkopercode
          qDdbTmp.SQL.Clear;
          qDdbTmp.SQL.Text:='update verkoper set verkopercode=:VERKOPERCODENIEUW where verkopercode=:VERKOPERCODEOUD';
          qDdbTmp.Params.ParamByName('VERKOPERCODENIEUW').AsString := verkopercodeUniek;
          qDdbTmp.Params.ParamByName('VERKOPERCODEOUD').AsString := qDdb.FieldByName('verkopercode').AsString;
          qDdbTmp.ExecSQL();
          qDdbTmp.Close;


          AddToLog('Verkoper toegevoegd: ');
          AddToLog('    ("Verkopercode - ID") = ("' +
                            VerkopercodeUniek + ' - ' +
                            IntToStr(MaxIdDdb) +
                            '")');
        end;
        qDdb.Next;
      end;
      qDdb.Close;

      AddToLog('Verkopers OK');
      Result:=true;

    finally
      qDdb.Free;
      qDdbTmp.Free;
      qMdb.Free;
      if (VObjectListMdb <> nil) then
      begin
        VObjectListMdb.Free;
      end;

    end;

    //
  except
    on E: Exception do
    begin
      Result:=false;
      AddToLog('Fout bij check van verkopers: ' + E.Message);
    end;
  end;
end;

function TfrmImportKassa.CheckRol:boolean;
var
  s:string;
  sql, sqlFilter:string;
  qDdb, qDdbTmp, qMdb : TZQuery;
  ix:integer;
  VObjectListMdb: TObjectList;
  bFound:boolean;
  IdNew,MaxIdDdb,MaxIdMdb:integer;
  iMatchLevel:integer;
begin
  AddToLog(FLogscheiding);
  AddToLog('Controle Rollen:');
  Result:=true;

  try
    VObjectListMdb:=TObjectList.Create;
    qDdb := m_querystuff.GetSQLite3QueryDdb;
    qDdbTmp:=m_querystuff.GetSQLite3QueryDdb;
    qMdb := m_querystuff.GetSQLite3QueryMdb;
    try
      // opmerkingen niet in combinedtext omdat daarin tekst over import komt te staan en bij een volgende import dus altijd zal verschillen
      sql:=' select distinct ' +
           ' r.rol_id, coalesce(r.omschrijving,'''') as omschrijving, coalesce(r.opmerkingen,'''') as opmerkingen, r.rol_id || '' - '' || coalesce(r.omschrijving, ''-'') as combinedtext ' +
           ' from rol as r ';
      sqlFilter:=' inner join vrijwilliger as vw on r.rol_id=vw.rolid ' +
                 ' inner join transactie as t on vw.vrijwilliger_id=t.vrijwilligerid ' +
                 ' inner join kassa as k on t.kassaid=k.kassa_id ' +
                 ' inner join beurs as b on k.beursid=b.beurs_id ' +
                 ' where k.isactief=1 and b.isactief=1 ';

      // loop door de oude databasetabel; sla records op
      qMdb.SQL.Clear;
      qMdb.SQL.Text:=sql;
      qMdb.Open;
      while not qMdb.Eof do
      begin
        VObjectListMdb.Add(TCompareIdObject.Create(qMdb.FieldByName('rol_id').AsString, qMdb.FieldByName('combinedtext').AsString, -1));
        qMdb.Next;
      end;
      qMdb.Close;

      // zijn er records in de te importeren database die niet voorkomen in de bestaande database? Dan toevoegen.
      // Loop door de te importeren tabel en vergelijk met de bestaande.
      qDdb.SQL.Clear;
      qDdb.SQL.Text:=sql+sqlFilter;
      qDdb.Open;
      while not qDdb.Eof do
      begin
        bFound:=false;
        s:=qDdb.FieldByName('rol_id').AsString;
        for ix:=0 to VObjectListMdb.Count-1 do
        begin
          iMatchLevel:=-1;
          if ((VObjectListMdb[ix] as TCompareIdObject).Id = s) then
          begin
            (VObjectListMdb[ix] as TCompareIdObject).TekstTerVergelijking:=qDdb.FieldByName('combinedtext').AsString;

            // voldoende match
            iMatchLevel:=0;

            // perfecte match?
            s:=qDdb.FieldByName('combinedtext').AsString;
            if ((VObjectListMdb[ix] as TCompareIdObject).Tekst = s) then
            begin
              iMatchLevel:=1;
            end;
            (VObjectListMdb[ix] as TCompareIdObject).MatchLevel:=iMatchLevel;

            if (iMatchLevel = 1) then
            begin
              bFound:=true;
            end;

            break;
          end;
        end;
        if (not bFound) then
        begin
          // Bepaal eerst een nieuw id: het id uit de te importeren database bestaat mogelijk
          // al in de oude database (deze kan meer records hebben dan de te importeren database).
          // Meest directe methode: bepaal de maximumwaarde van het id-veld in beide databases en
          // verhoog deze met 1 om een unieke waarde te krijgen.
          MaxIdDdb:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelDdb, 'select max(rol_id) as maxid from rol', 'maxid', 1);
          MaxIdMdb:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelMdb, 'select max(rol_id) as maxid from rol', 'maxid', 1);
          IdNew:=GetAfgerondeStartindex(MaxIdMdb, MaxIdDdb);

          qMdb.SQL.Clear;
          qMdb.SQL.Text:='insert into rol (' +
                      ' rol_id, omschrijving, opmerkingen' +
                      ' ) values(' +
                      ' :ROL_ID, :OMSCHRIJVING, :OPMERKINGEN ' +
                      ')';
          qMdb.Params.ParamByName('ROL_ID').AsInteger := IdNew;
          qMdb.Params.ParamByName('OMSCHRIJVING').AsString := qDdb.FieldByName('omschrijving').AsString;
          qMdb.Params.ParamByName('OPMERKINGEN').AsString := Copy('Toegevoegd tijdens import - ' + qDdb.FieldByName('opmerkingen').AsString, 1, qDdb.FieldByName('opmerkingen').Size);
          qMdb.ExecSQL();
          qMdb.Close;

          // update de aangepaste rolid in de te importeren database
          qDdbTmp.SQL.Clear;
          qDdbTmp.SQL.Text:='update rol set rol_id=:ROLIDNIEUW where rol_id=:ROLIDOUD';
          qDdbTmp.Params.ParamByName('ROLIDNIEUW').AsInteger := IdNew;
          qDdbTmp.Params.ParamByName('ROLIDOUD').AsString := qDdb.FieldByName('rol_id').AsString;
          qDdbTmp.ExecSQL();
          qDdbTmp.Close;

          qDdbTmp.SQL.Clear;
          qDdbTmp.SQL.Text:='update vrijwilliger set rolid=:ROLIDNIEUW where rolid=:ROLIDOUD';
          qDdbTmp.Params.ParamByName('ROLIDNIEUW').AsInteger := IdNew;
          qDdbTmp.Params.ParamByName('ROLIDOUD').AsString := qDdb.FieldByName('rol_id').AsString;
          qDdbTmp.ExecSQL();
          qDdbTmp.Close;

          AddToLog('Rol toegevoegd: ');
          AddToLog('    ("ID - Omschrijving - Opmerkingen") = ("' +
                            IntToStr(MaxIdDdb) + ' - ' +
                            qDdb.FieldByName('omschrijving').AsString + ' - ' +
                            qDdb.FieldByName('opmerkingen').AsString +
                            '")');
        end;
        qDdb.Next;
      end;
      qDdb.Close;

      AddToLog('Rollen OK');
      Result:=true;

    finally
      qDdb.Free;
      qDdbTmp.Free;
      qMdb.Free;
      if (VObjectListMdb <> nil) then
      begin
        VObjectListMdb.Free;
      end;

    end;

    //
  except
    on E: Exception do
    begin
      Result:=false;
      AddToLog('Fout bij check van Rollen: ' + E.Message);
    end;
  end;
end;


function TfrmImportKassa.CheckVrijwilliger:boolean;
var
  s:string;
  sql, sqlFilter:string;
  qDdb, qDdbTmp, qMdb : TZQuery;
  ix:integer;
  VObjectListMdb: TObjectList;
  bFound:boolean;
  IdNew,MaxIdDdb,MaxIdMdb:integer;
  iMatchLevel:integer;
begin
  AddToLog(FLogscheiding);
  AddToLog('Controle Vrijwilligers:');
  Result:=true;

  try
    VObjectListMdb:=TObjectList.Create;
    qDdb := m_querystuff.GetSQLite3QueryDdb;
    qDdbTmp:=m_querystuff.GetSQLite3QueryDdb;
    qMdb := m_querystuff.GetSQLite3QueryMdb;
    try
      // opmerkingen niet in combinedtext omdat daarin tekst over import komt te staan en bij een volgende import dus altijd zal verschillen
      sql:='select distinct ' +
           ' vw.vrijwilliger_id, coalesce(vw.nawid, '''') as nawid, coalesce(vw.rolid, '''') as rolid, ' +
           ' coalesce(vw.opmerkingen, '''') as opmerkingen, coalesce(vw.inlognaam, '''') as inlognaam, ' +
           ' coalesce(vw.wachtwoord, '''') as wachtwoord, ' +
           ' coalesce(bv.beurs_vrijwilliger_id,'''') as bvid, '+
           ' coalesce(bv.opmerkingen,'''') as beursvrijwilligeropmerkingen, ' +
           ' coalesce(vw.inlognaam, ''-'') || '' - '' || coalesce(vw.wachtwoord, ''-'') || '' - '' || vw.vrijwilliger_id || '' - '' || coalesce(vw.nawid, ''-'') || '' - '' || coalesce(vw.rolid, ''-'') as combinedtext ' +
           ' from vrijwilliger as vw ' +
           ' left join beurs_vrijwilliger as bv on vw.vrijwilliger_id=bv.vrijwilligerid ';
      sqlFilter:=' inner join transactie as t on vw.vrijwilliger_id=t.vrijwilligerid ' +
                 ' inner join kassa as k on t.kassaid=k.kassa_id ' +
                 ' inner join beurs as b on k.beursid=b.beurs_id ' +
                 ' where k.isactief=1 and b.isactief=1';


      // loop door de oude databasetabel; sla records op
      qMdb.SQL.Clear;
      qMdb.SQL.Text:=sql;
      qMdb.Open;
      while not qMdb.Eof do
      begin
        VObjectListMdb.Add(TCompareIdObject.Create(qMdb.FieldByName('vrijwilliger_id').AsString,
                                                   qMdb.FieldByName('nawid').AsString,
                                                   qMdb.FieldByName('rolid').AsString,
                                                   qMdb.FieldByName('combinedtext').AsString,
                                                   -1));
        qMdb.Next;
      end;
      qMdb.Close;

      // zijn er records in de te importeren database die niet voorkomen in de bestaande database? Dan toevoegen.
      // Loop door de te importeren tabel en vergelijk met de bestaande.
      qDdb.SQL.Clear;
      qDdb.SQL.Text:=sql+sqlFilter;
      qDdb.Open;
      while not qDdb.Eof do
      begin
        bFound:=false;
        s:=qDdb.FieldByName('vrijwilliger_id').AsString;
        for ix:=0 to VObjectListMdb.Count-1 do
        begin
          iMatchLevel:=-1;
          if ((VObjectListMdb[ix] as TCompareIdObject).Id = s) then
          begin
            (VObjectListMdb[ix] as TCompareIdObject).TekstTerVergelijking:=qDdb.FieldByName('combinedtext').AsString;

            // voldoende match
            iMatchLevel:=0;

            // perfecte match?
            s:=qDdb.FieldByName('combinedtext').AsString;
            if ((VObjectListMdb[ix] as TCompareIdObject).Tekst = s) then
            begin
              iMatchLevel:=1;
            end;
            (VObjectListMdb[ix] as TCompareIdObject).MatchLevel:=iMatchLevel;

            if (iMatchLevel = 1) then
            begin
              bFound:=true;
            end;

            break;
          end;
        end;
        if (not bFound) then
        begin
          // Bepaal eerst een nieuw id: het id uit de te importeren database bestaat mogelijk
          // al in de oude database (deze kan meer records hebben dan de te importeren database).
          // Meest directe methode: bepaal de maximumwaarde van het id-veld in beide databases en
          // verhoog deze met 1 om een unieke waarde te krijgen.
          MaxIdDdb:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelDdb, 'select max(vrijwilliger_id) as maxid from vrijwilliger', 'maxid', 1);
          MaxIdMdb:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelMdb, 'select max(vrijwilliger_id) as maxid from vrijwilliger', 'maxid', 1);
          IdNew:=GetAfgerondeStartindex(MaxIdMdb, MaxIdDdb);

          qMdb.SQL.Clear;
          qMdb.SQL.Text:='insert into vrijwilliger (' +
                      ' vrijwilliger_id, rolid, opmerkingen, inlognaam, wachtwoord' +
                      ' ) values(' +
                      ' :VRIJWILLIGER_ID, :ROLID, :OPMERKINGEN, :INLOGNAAM, :WACHTWOORD ' +
                      ')';
          qMdb.Params.ParamByName('VRIJWILLIGER_ID').AsInteger := IdNew;
          qMdb.Params.ParamByName('ROLID').AsString := qDdb.FieldByName('rolid').AsString;
          qMdb.Params.ParamByName('OPMERKINGEN').AsString := Copy('Toegevoegd tijdens import - ' + qDdb.FieldByName('opmerkingen').AsString, 1, qDdb.FieldByName('opmerkingen').Size);
          qMdb.Params.ParamByName('INLOGNAAM').AsString := qDdb.FieldByName('inlognaam').AsString;
          qMdb.Params.ParamByName('WACHTWOORD').AsString := qDdb.FieldByName('wachtwoord').AsString;
          qMdb.ExecSQL();
          qMdb.Close;

          if (qDdb.FieldByName('bvid').AsString <> '') then
          begin
            qMdb.SQL.Clear;
            qMdb.SQL.Text:='insert into beurs_vrijwilliger (' +
                        ' beursid,vrijwilligerid,opmerkingen' +
                        ' ) values(' +
                        ' :BEURSID,:VRIJWILLIGERID,:OPMERKINGEN ' +
                        ')';
            qMdb.Params.ParamByName('BEURSID').AsInteger := FBeursIdMdb;
            qMdb.Params.ParamByName('VRIJWILLIGERID').AsInteger := IdNew;
            qMdb.Params.ParamByName('OPMERKINGEN').AsString := Copy('import - van kassa ' + IntToStr(FKassaIdDdb), 1, qDdb.FieldByName('beursvrijwilligeropmerkingen').Size);
            qMdb.ExecSQL();
            qMdb.Close;
          end;

          // update de aangepaste id in de te importeren database
          qDdbTmp.SQL.Clear;
          qDdbTmp.SQL.Text:='update vrijwilliger set vrijwilliger_id=:VRIJWILLIGERIDNIEUW where vrijwilliger_id=:VRIJWILLIGERIDOUD';
          qDdbTmp.Params.ParamByName('VRIJWILLIGERIDNIEUW').AsInteger := IdNew;
          qDdbTmp.Params.ParamByName('VRIJWILLIGERIDOUD').AsString := qDdb.FieldByName('vrijwilliger_id').AsString;
          qDdbTmp.ExecSQL();
          qDdbTmp.Close;

          // update de aangepaste id in de te importeren database
          qDdbTmp.SQL.Clear;
          qDdbTmp.SQL.Text:='update beurs_vrijwilliger set vrijwilligerid=:VRIJWILLIGERIDNIEUW where vrijwilligerid=:VRIJWILLIGERIDOUD';
          qDdbTmp.Params.ParamByName('VRIJWILLIGERIDNIEUW').AsInteger := IdNew;
          qDdbTmp.Params.ParamByName('VRIJWILLIGERIDOUD').AsString := qDdb.FieldByName('vrijwilliger_id').AsString;
          qDdbTmp.ExecSQL();
          qDdbTmp.Close;

          // update de aangepaste id in de te importeren database
          qDdbTmp.SQL.Clear;
          qDdbTmp.SQL.Text:='update transactie set vrijwilligerid=:VRIJWILLIGERIDNIEUW where vrijwilligerid=:VRIJWILLIGERIDOUD';
          qDdbTmp.Params.ParamByName('VRIJWILLIGERIDNIEUW').AsInteger := IdNew;
          qDdbTmp.Params.ParamByName('VRIJWILLIGERIDOUD').AsString := qDdb.FieldByName('vrijwilliger_id').AsString;
          qDdbTmp.ExecSQL();
          qDdbTmp.Close;


          AddToLog('Vrijwilliger toegevoegd: ');
          AddToLog('    ("ID - Inlognaam - Opmerkingen") = ("' +
                            IntToStr(IdNew) + ' - ' +
                            qDdb.FieldByName('inlognaam').AsString + ' - ' +
                            qDdb.FieldByName('opmerkingen').AsString +
                            '")');
        end;
        qDdb.Next;
      end;
      qDdb.Close;

      AddToLog('Vrijwilligers OK');
      Result:=true;

    finally
      qDdb.Free;
      qDdbTmp.Free;
      qMdb.Free;
      if (VObjectListMdb <> nil) then
      begin
        VObjectListMdb.Free;
      end;
    end;

    //
  except
    on E: Exception do
    begin
      Result:=false;
      AddToLog('Fout bij check van Vrijwilligers: ' + E.Message);
    end;
  end;
end;


function TfrmImportKassa.ImporteerTransacties:boolean;
var
  qDdb, qDdbTmp, qMdb : TZQuery;
  TIdNew,MaxTIdDdb,MaxTIdMdb:integer;
  TAIdNew,MaxTAIdDdb,MaxTAIdMdb:integer;
  KIdNew,MaxKIdDdb,MaxKIdMdb:integer;
  Totaal_KCounter, Totaal_TAcounter,Totaal_TCounter:integer;
  KCounter, TAcounter,TCounter:integer;

begin
  AddToLog(FLogscheiding);
  AddToLog('Overnemen transacties:');
  Result:=true;

  try
    qDdb := m_querystuff.GetSQLite3QueryDdb;
    qDdbTmp:=m_querystuff.GetSQLite3QueryDdb;
    qMdb := m_querystuff.GetSQLite3QueryMdb;
    try


      // Voor transacties en transactieartikelen moeten wrs vele records worden overgenomen. Bepaal daarvoor eerst het hoogste
      // kassabedrag_id dat in beide dbs voorkomt. Verhoog de kassabedrag_id's en kassabedragids in alle
      // voorkomende in de Ddb met deze maximale waarde + 1. Of duidelijker: deze maximale waarde + 1 naar boven afgerond
      // naar een honderdtal.
      MaxTIdMdb:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelDdb, 'select max(transactie_id) as maxid from transactie', 'maxid', 1);
      MaxTIdDdb:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelMdb, 'select max(transactie_id) as maxid from transactie', 'maxid', 1);
      TIdNew:=GetAfgerondeStartindex(MaxTIdMdb, MaxTIdDdb);

      MaxTAIdMdb:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelDdb, 'select max(transactieartikel_id) as maxid from transactieartikel', 'maxid', 1);
      MaxTAIdDdb:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelMdb, 'select max(transactieartikel_id) as maxid from transactieartikel', 'maxid', 1);
      TAIdNew:=GetAfgerondeStartindex(MaxTAIdMdb, MaxTAIdDdb);

      MaxKIdMdb:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelDdb, 'select max(klant_id) as maxid from klant', 'maxid', 1);
      MaxKIdDdb:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelMdb, 'select max(klant_id) as maxid from klant', 'maxid', 1);
      KIdNew:=GetAfgerondeStartindex(MaxKIdMdb, MaxKIdDdb);

      qDdb.SQL.Clear;
      qDdb.SQL.Text:='select distinct ' +
      ' kl.klant_id,coalesce(kl.opmerkingen,'''') as opmerkingen, ' +
      ' coalesce(bk.beurs_klant_id,'''') as beurs_klant_id, coalesce(bk.opmerkingen,'''') as beursklantopmerkingen ' +
      ' from klant as kl ' +
      ' inner join transactie as t on t.klantid=kl.klant_id ' +
      ' inner join kassa as k on t.kassaid=k.kassa_id ' +
      ' inner join beurs as b on k.beursid=b.beurs_id ' +
      ' left join beurs_klant as bk on kl.klant_id=bk.klantid ' +
      ' where k.isactief=1 and b.isactief=1';

      qDdb.Open;
      KCounter:=0;
      Totaal_KCounter:=KCounter;
      while not qDdb.Eof do
      begin
        qMdb.SQL.Clear;
        qMdb.SQL.Text:='insert into klant (' +
                    ' klant_id,opmerkingen' +
                    ' ) values(' +
                    ' :KLANT_ID,:OPMERKINGEN ' +
                    ')';
        qMdb.Params.ParamByName('KLANT_ID').AsInteger := KIdNew + KCounter;
        qMdb.Params.ParamByName('OPMERKINGEN').AsString := Copy('import - ' + qDdb.FieldByName('opmerkingen').AsString, 1, qDdb.FieldByName('opmerkingen').Size);
	qMdb.ExecSQL();
        qMdb.Close;

        if (qDdb.FieldByName('beurs_klant_id').AsString <> '') then
        begin
          qMdb.SQL.Clear;
          qMdb.SQL.Text:='insert into beurs_klant (' +
                      ' beursid,klantid,opmerkingen' +
                      ' ) values(' +
                      ' :BEURSID,:KLANTID,:OPMERKINGEN ' +
                      ')';
          qMdb.Params.ParamByName('BEURSID').AsInteger := FBeursIdMdb;
          qMdb.Params.ParamByName('KLANTID').AsInteger := KIdNew + KCounter;
          qMdb.Params.ParamByName('OPMERKINGEN').AsString := Copy('import - van kassa ' + IntToStr(FKassaIdDdb), 1, qDdb.FieldByName('beursklantopmerkingen').Size);
          qMdb.ExecSQL();
          qMdb.Close;
        end;

        qDdbTmp.SQL.Clear;
        qDdbTmp.SQL.Text:='update klant set klant_id=:KLANTIDNEW where klant_id=:KLANTIDOLD';
        qDdbTmp.Params.ParamByName('KLANTIDNEW').AsInteger := KIdNew + KCounter;
        qDdbTmp.Params.ParamByName('KLANTIDOLD').AsString := qDdb.FieldByName('klant_id').AsString;
        qDdbTmp.ExecSQL();
        qDdbTmp.Close;

        qDdbTmp.SQL.Clear;
        qDdbTmp.SQL.Text:='update transactie set klantid=:KLANTIDNEW where klantid=:KLANTIDOLD';
        qDdbTmp.Params.ParamByName('KLANTIDNEW').AsInteger := KIdNew + KCounter;
        qDdbTmp.Params.ParamByName('KLANTIDOLD').AsString := qDdb.FieldByName('klant_id').AsString;
        qDdbTmp.ExecSQL();
        qDdbTmp.Close;

        qDdbTmp.SQL.Clear;
        qDdbTmp.SQL.Text:='update beurs_klant set klantid=:KLANTIDNEW where klantid=:KLANTIDOLD';
        qDdbTmp.Params.ParamByName('KLANTIDNEW').AsInteger := KIdNew + KCounter;
        qDdbTmp.Params.ParamByName('KLANTIDOLD').AsString := qDdb.FieldByName('klant_id').AsString;
        qDdbTmp.ExecSQL();
        qDdbTmp.Close;

        qDdb.Next;

        KCounter:=KCounter+1;
      end;
      qDdb.Close;
      Totaal_KCounter:=Totaal_KCounter+KCounter;



      qDdb.SQL.Clear;
      // van totaalbedrag evt. koma vervangen door punt en vermenigvuldigen met 1.0 om af te dwingen dat het een numerieke waarde is
      qDdb.SQL.Text:='select distinct t.transactie_id,coalesce(t.klantid,'''') as klantid, ' +
                     ' coalesce(t.kassaid,'''') as kassaid, coalesce(t.vrijwilligerid,'''') as vrijwilligerid, ' +
                     ' coalesce(t.betaalwijzeid,'''') as betaalwijzeid, ' +
                     ' case when t.totaalbedrag is null or t.totaalbedrag = '''' then 0 else replace(t.totaalbedrag,'','',''.'') end as totaalbedrag, ' +
                     ' coalesce(t.totaalbedrag,'''') as totaalbedragoud, ' +
                     ' coalesce(t.opmerkingen,'''') as opmerkingen, t.datumtijdinvoer, t.datumtijdwijzigen ' +
                     ' from transactie as t ' +
                     ' inner join kassa as k on t.kassaid=k.kassa_id ' +
                     ' inner join beurs as b on k.beursid=b.beurs_id ' +
                     ' where k.isactief=1 and b.isactief=1;';
      qDdb.Open;
      TCounter:=0;
      Totaal_TCounter:=TCounter;
      Totaal_TAcounter:=TCounter;
      while not qDdb.Eof do
      begin
        qMdb.SQL.Clear;
        qMdb.SQL.Text:='insert into transactie (' +
                    ' transactie_id,klantid,kassaid,vrijwilligerid,betaalwijzeid,totaalbedrag,opmerkingen,datumtijdinvoer,datumtijdwijzigen' +
                    ' ) values(' +
                    ' :TRANSACTIE_ID,:KLANTID,:KASSAID,:VRIJWILLIGERID,:BETAALWIJZEID,:TOTAALBEDRAG,:OPMERKINGEN,:DATUMTIJDINVOER,:DATUMTIJDWIJZIGEN ' +
                    ')';
        qMdb.Params.ParamByName('TRANSACTIE_ID').AsInteger := TIdNew + TCounter;
        qMdb.Params.ParamByName('KLANTID').AsString := qDdb.FieldByName('klantid').AsString;
        qMdb.Params.ParamByName('KASSAID').AsString := qDdb.FieldByName('kassaid').AsString;
        qMdb.Params.ParamByName('VRIJWILLIGERID').AsString := qDdb.FieldByName('vrijwilligerid').AsString;
        qMdb.Params.ParamByName('BETAALWIJZEID').AsString := qDdb.FieldByName('betaalwijzeid').AsString;
        qMdb.Params.ParamByName('TOTAALBEDRAG').AsString := qDdb.FieldByName('totaalbedrag').AsString;
        qMdb.Params.ParamByName('OPMERKINGEN').AsString := Copy('import - ' + qDdb.FieldByName('opmerkingen').AsString, 1, qDdb.FieldByName('opmerkingen').Size);
        qMdb.Params.ParamByName('DATUMTIJDINVOER').AsDateTime := qDdb.FieldByName('datumtijdinvoer').AsDateTime;
        qMdb.Params.ParamByName('DATUMTIJDWIJZIGEN').AsDateTime := qDdb.FieldByName('datumtijdwijzigen').AsDateTime;
	qMdb.ExecSQL();
        qMdb.Close;

        qDdbTmp.SQL.Clear;
        qDdbTmp.SQL.Text:='update transactie set transactie_id=:TRANSACTIEIDNEW where transactie_id=:TRANSACTIEIDOLD';
        qDdbTmp.Params.ParamByName('TRANSACTIEIDNEW').AsInteger := TIdNew + TCounter;
        qDdbTmp.Params.ParamByName('TRANSACTIEIDOLD').AsString := qDdb.FieldByName('transactie_id').AsString;
        qDdbTmp.ExecSQL();
        qDdbTmp.Close;

        qDdbTmp.SQL.Clear;
        qDdbTmp.SQL.Text:='update transactieartikel set transactieid=:TRANSACTIEIDNEW where transactieid=:TRANSACTIEIDOLD';
        qDdbTmp.Params.ParamByName('TRANSACTIEIDNEW').AsInteger := TIdNew + TCounter;
        qDdbTmp.Params.ParamByName('TRANSACTIEIDOLD').AsString := qDdb.FieldByName('transactie_id').AsString;
        qDdbTmp.ExecSQL();
        qDdbTmp.Close;

        qDdb.Next;

        TCounter:=TCounter+1;
      end;
      qDdb.Close;
      Totaal_TCounter:=Totaal_TCounter+TCounter;



      qDdb.SQL.Clear;
      qDdb.SQL.Text:='select distinct ta.transactieartikel_id, ta.transactieid, ' +
                     ' coalesce(ta.artikelid,'''') as artikelid, coalesce(ta.volgnr,'''') as volgnr, coalesce(ta.kortingsfactor,'''') as kortingsfactor ' +
                     ' from transactieartikel as ta ' +
                     ' inner join transactie as t on ta.transactieid=t.transactie_id ' +
                     ' inner join kassa as k on t.kassaid=k.kassa_id ' +
                     ' inner join beurs as b on k.beursid=b.beurs_id ' +
                     ' where k.isactief=1 and b.isactief=1;';
      qDdb.Open;
      TAcounter:=0;
      while not qDdb.Eof do
      begin
        qMdb.SQL.Clear;
        qMdb.SQL.Text:='insert into transactieartikel (' +
                    ' transactieartikel_id,transactieid,artikelid,volgnr,kortingsfactor' +
                    ' ) values(' +
                    ' :TRANSACTIEARTIKEL_ID,:TRANSACTIEID,:ARTIKELID,:VOLGNR,:KORTINGSFACTOR ' +
                    ')';
        qMdb.Params.ParamByName('TRANSACTIEARTIKEL_ID').AsInteger := TAIdNew + TAcounter;
        qMdb.Params.ParamByName('TRANSACTIEID').AsInteger := qDdb.FieldByName('transactieid').AsInteger;
        qMdb.Params.ParamByName('ARTIKELID').AsString := qDdb.FieldByName('artikelid').AsString;
        qMdb.Params.ParamByName('VOLGNR').AsString := qDdb.FieldByName('volgnr').AsString;
        qMdb.Params.ParamByName('KORTINGSFACTOR').AsString := qDdb.FieldByName('kortingsfactor').AsString;
        qMdb.ExecSQL();
        qMdb.Close;

        qDdbTmp.SQL.Clear;
        qDdbTmp.SQL.Text:='update transactieartikel set transactieartikel_id=:TRANSACTIEARTIKELIDNEW where transactieartikel_id=:TRANSACTIEARTIKELIDOLD';
        qDdbTmp.Params.ParamByName('TRANSACTIEARTIKELIDNEW').AsInteger := TAIdNew + TAcounter;
        qDdbTmp.Params.ParamByName('TRANSACTIEARTIKELIDOLD').AsString := qDdb.FieldByName('transactieartikel_id').AsString;
        qDdbTmp.ExecSQL();
        qDdbTmp.Close;


        qDdb.Next;

        TAcounter:=TAcounter+1;
      end;
      qDdb.Close;
      Totaal_TACounter:=Totaal_TACounter+TACounter;

      if (Totaal_TCounter = 0) then
      begin
        AddToLog('Geen Transacties gekopieerd');
      end
      else
      begin
        AddToLog(IntToStr(Totaal_TCounter) + ' Transacties gekopieerd');
      end;
      if (Totaal_TACounter = 0) then
      begin
        AddToLog('Geen Transactieartikelen gekopieerd');
      end
      else
      begin
        AddToLog(IntToStr(Totaal_TACounter) + ' Transactieartikelen gekopieerd');
      end;
      Result:=true;

    finally
      qDdb.Free;
      qDdbTmp.Free;
      qMdb.Free;
    end;

    //
  except
    on E: Exception do
    begin
      Result:=false;
      AddToLog('Fout bij check van Transacties: ' + E.Message);
    end;
  end;
end;

procedure TfrmImportKassa.cmbImportToBeursChange(Sender: TObject);
begin
  FBeursIdMdb:=Integer(cmbImportToBeurs.Items.Objects[cmbImportToBeurs.ItemIndex]);
end;

function TfrmImportKassa.GetImportDatabaseFile():string;
var
  isOk:boolean;
  currentDatabaseFilename:string;
begin
  currentDatabaseFilename:=dmWobbel.connWobbelMdb.Database;
  Result:='';

  isOk:=false;

  while not isOk do
  begin
    if dmWobbel.dlgDatabase.Execute then
    begin
      isOk:=DatabaseFileIsOk(dmWobbel.dlgDatabase.Filename);
      if (dmWobbel.dlgDatabase.Filename = currentDatabaseFilename) then
      begin
        MessageError('Deze database is in gebruik door de applicatie! Kies een andere s.v.p.');
        isOk:=false;
      end;

      if (isOk) then
      begin
        Result:=dmWobbel.dlgDatabase.Filename;
        {
        if (dmWobbel.connWobbelDdb.Connected) then
        begin
          dmWobbel.connWobbelDdb.Disconnect;
        end;
        dmWobbel.connWobbelDdb.Database:=dmWobbel.dlgDatabase.Filename;
        //dmWobbel.connWobbelDdb.Connect;
        }
      end;
    end
    else
    begin
      break;
    end;
  end;
end;


function TfrmImportKassa.AantalActieveBeurzen: integer;
var
  q : TZQuery;
  retVal:integer;
begin
  try
    try
      retVal:=-1;

      q := m_querystuff.GetSQLite3QueryDdb;
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
        AddToLog('Fout: Geen actieve beurs gevonden in de te importeren database. Svp handmatig nagaan.');
        exit;
      end
      else if (retVal = 1) then
      begin
        AddToLog('Ok: 1 actieve beurs gevonden in de te importeren database.');
      end
      else
      begin
        AddToLog('Fout: Meer dan 1 actieve beurs gevonden in de te importeren database. Svp handmatig nagaan.');
      end
    finally
      q.Free;
      AantalActieveBeurzen:=retVal;
    end;
  except
    on E: Exception do
    begin
      AddToLog('Fout: bij opvragen aantal actieve beurzen: ' + E.Message);
    end;
  end;
end;

function TfrmImportKassa.AantalActieveKassas(): integer;
var
  q : TZQuery;
  retVal:integer;
begin

  try
    q := m_querystuff.GetSQLite3QueryDdb;
    try
      retVal:=-1;

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
        AddToLog('Fout: Geen actieve kassa gevonden voor de actieve beurs van de te importeren database. Svp handmatig nagaan.');
      end
      else if (retVal = 1) then
      begin
        AddToLog('Ok: 1 actieve kassa gevonden voor de actieve beurs van de te importeren database.');
      end
      else
      begin
        AddToLog('Fout: Meer dan 1 actieve kassa gevonden voor de actieve beurs van de te importeren database. Svp handmatig nagaan.');
      end
    finally
      q.Free;
      AantalActieveKassas:=retVal;
    end;
  except
    on E: Exception do
    begin
      AddToLog('Fout: bij opvragen aantal actieve kassa''s: ' + E.Message);
    end;
  end;
end;



function TfrmImportKassa.GetCountValue(conn: TZConnection; sql,paramName,paramValue,idcol:string): integer;
var
  q : TZQuery;
begin
  try
    try
      Result:=-1;
      q:=TZQuery.Create(nil);
      q.Connection := conn;

      q.SQL.Clear;
      q.SQL.Text:=sql;
      q.Params.ParamByName(AnsiUpperCase(paramName)).AsString := paramValue;
      q.Open;
      while not q.Eof do
      begin
        Result:=q.FieldByName(idcol).AsInteger;
        break;
      end;
      q.Close;
    finally
      q.Free;
    end;
  except
    on E: Exception do
    begin
      AddToLog('Fout: in GetCountValue: ' + E.Message);
    end;
  end;
end;

function TfrmImportKassa.GetUniekVerkopercode(verkopercode:string;VerkopercodeMaxSize:integer): string;
var
  s, werkVerkopercode:string;
  aantal,aantalInDdb,counter:integer;

  function getNewVerkopercode(verkopercode: string; counter:integer; VerkopercodeMaxSize:integer):string;
  var
    s: string;
  begin
    s:=verkopercode + ' - import nr. ' + IntToStr(counter);
    Result:=s;
    // max VerkopercodeMaxSize tekens
    if (Length(s) > VerkopercodeMaxSize) then
    begin
      Result:=Copy(s, 1, VerkopercodeMaxSize);
    end;
  end;

begin
  counter:=1;
  aantal:=1;
  werkVerkopercode:=getNewVerkopercode(verkopercode,counter,VerkopercodeMaxSize);
  while(aantal = 1) do
  begin
    aantal:=GetCountValue(dmWobbel.connWobbelMdb, 'select count(*) as aantal from verkoper where verkopercode=:VERKOPERCODE', 'VERKOPERCODE', werkVerkopercode, 'aantal');
    if (aantal = 0) then
    begin
      // werkVerkopercode is uniek in huidige database. Als het niet de eerste doorgang van de lus is:
      // Ook uniek in de te importeren database?
      if (counter = 1) then
      begin
        Result:=werkVerkopercode;
        exit;
      end
      else
      begin
        aantalInDdb:=GetCountValue(dmWobbel.connWobbelDdb, 'select count(*) as aantal from verkoper where verkopercode=:VERKOPERCODE', 'VERKOPERCODE', werkVerkopercode, 'aantal');
        if (aantalInDdb = 0) then
        begin
          Result:=werkVerkopercode;
          exit;
        end;
      end;
    end;
    if (aantal > 1) then
    begin
      // huh?
      s:='Fout: er zijn meerdere "verkopercode" waardes gevonden in de huidige database: "'+werkVerkopercode+'"';
      AddToLog(s);
      Raise EWobbelError.Create(s);
    end;
    if (aantal < 0) then
    begin
      // huh?
      s:='Fout: onbekende fout opgetreden in "GetUniekVerkopercode" voor waarde "'+werkVerkopercode+'". Neem contact op met de applicatiebeheerder';
      AddToLog(s);
      Raise EWobbelError.Create(s);
    end;

    counter:=counter+1;
    // maak een nieuwe verkopercode
    werkVerkopercode:=getNewVerkopercode(verkopercode,counter,VerkopercodeMaxSize);
  end;
  Result:=werkVerkopercode;
end;


function TfrmImportKassa.GetUniekKassanr(kassanr:string;kassanrMaxSize:integer): string;
var
  s, werkkassanr:string;
  aantal,counter:integer;

  function getNewKassanr(kassanr: string; counter:integer; kassanrMaxSize:integer):string;
  var
    s: string;
  begin
    s:='Import nr.' + IntToStr(counter) + ' "' + kassanr + '"';
    Result:=s;
    if (Length(s) > kassanrMaxSize) then
    begin
      Result:=Copy(s, 1, kassanrMaxSize);
    end;
  end;

begin
  counter:=1;
  aantal:=1;
  werkkassanr:=getNewKassanr(kassanr,counter,kassanrMaxSize);
  while(aantal = 1) do
  begin
    aantal:=GetCountValue(dmWobbel.connWobbelMdb, 'select count(*) as aantal from kassa where kassanr=:KASSANR', 'KASSANR', werkkassanr, 'aantal');
    if (aantal = 0) then
    begin
      // werkkassanr is uniek in huidige database. Als het niet de eerste doorgang van de lus is:
      // Ook uniek in de te importeren database?
      if (counter = 1) then
      begin
        Result:=werkkassanr;
        exit;
      end
      else
      begin
        aantal:=GetCountValue(dmWobbel.connWobbelDdb, 'select count(*) as aantal from kassa where kassanr=:KASSANR', 'KASSANR', werkkassanr, 'aantal');
        if (aantal = 0) then
        begin
          Result:=werkkassanr;
          exit;
        end;
      end;
    end;
    if (aantal > 1) then
    begin
      // huh?
      s:='Fout: er zijn meerdere "kassanr" waardes gevonden in de huidige database: "'+werkkassanr+'"';
      AddToLog(s);
      Raise EWobbelError.Create(s);
    end;
    if (aantal < 0) then
    begin
      // huh?
      s:='Fout: onbekende fout opgetreden in "GetUniekKassaNr" voor waarde "'+werkkassanr+'". Neem contact op met de applicatiebeheerder';
      AddToLog(s);
      Raise EWobbelError.Create(s);
    end;

    counter:=counter+1;
    // maak een nieuw kassanr
    werkkassanr:=getNewKassanr(kassanr,counter,kassanrMaxSize);
  end;
  Result:=werkkassanr;
end;

function TfrmImportKassa.GetAfgerondeStartindex(val1, val2:integer):integer;
var
  valTmp:integer;
begin
  // bepaal een waarde die begint bij het eerstvolgende honderdtal
  valTmp:=math.Max(val1+1, val2+1);

  Result:=math.ceil(100.0 * math.ceil(valTmp/100.0));

  if (Result < valTmp) then
  begin
    Result:=valTmp;
  end;
end;

procedure TfrmImportKassa.AddToLog(s:string);
begin
  mmoLog.Lines.Add(s);
  m_tools.LogfileAdd( s);
end;


end.

