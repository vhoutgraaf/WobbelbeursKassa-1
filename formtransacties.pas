unit formtransacties;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, ActnList
  , c_appsettings,
  c_gridtransactie, c_gridtransactieartikel,
  c_wobbelgridpanel, c_wobbelbuttonpanel, framewachten;

type

  { TfrmTransacties }

  TfrmTransacties = class(TForm)
    aclstTransacties: TActionList;
    actionNieuweTransactie: TAction;
    actionWijzigTransactie: TAction;
    actionOpslaanTransactie: TAction;
    actionAnnuleerTransactie: TAction;
    btnInfo01: TBitBtn;
    btnInfo02: TBitBtn;
    cmbReferentieInbrengers: TComboBox;
    frmEvenGeduld: TframeWachten;
    grpReferentie: TGroupBox;
    lblReferentieInbrengers: TLabel;
    lblTransactieDetailsTitel: TLabel;
    lblTransactieBetaalwijze: TLabel;
    lblTransactieOpmerkingen: TLabel;
    mmoTransactieOpmerkingen: TMemo;
    lblSelectedTransactie: TLabel;
    lblTransactieWarning1: TLabel;
    lblTransactieWarning2: TLabel;
    pnlTransactieArtikelen: TPanel;
    pnlTransactieContainer: TPanel;
    pnlTransacties: TPanel;
    pnlTransactiesControl: TPanel;
    pnlTransactiesScreen: TPanel;
    pnlTransactieDetails: TPanel;

    pnlWijzigTransactie:TWobbelButtonPanel;
    pnlNieuweTransactie:TWobbelButtonPanel;
    pnlTransactieOpslaan:TWobbelButtonPanel;
    pnlTransactieAnnuleren:TWobbelButtonPanel;
    rgBetaalwijzes: TRadioGroup;

    procedure actionAnnuleerTransactieExecute(Sender: TObject);
    procedure actionNieuweTransactieExecute(Sender: TObject);
    procedure actionOpslaanTransactieExecute(Sender: TObject);
    procedure actionWijzigTransactieExecute(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure frmEvenGeduldClick(Sender: TObject);
    procedure mmoTransactieOpmerkingenChange(Sender: TObject);
    procedure pnlNieuweTransactieClick(Sender: TObject);
    procedure pnlTransactieAnnulerenClick(Sender: TObject);
    procedure pnlTransactieOpslaanClick(Sender: TObject);
    procedure pnlWijzigTransactieClick(Sender: TObject);
    procedure rgBetaalwijzesSelectionChanged(Sender: TObject);
  private
    { private declarations }

    procedure EnableGrid(gridpanel:TWobbelGridPanel; status:TWobbelGridStatus);
    procedure EnableTransactieDetails(enable:boolean);
    procedure TransactieOpslaan();
    procedure TransactieAnnuleren();
    function VeranderingenOpgeslagenBijVerlaten():boolean;

    procedure pnlWijzigTransactieActie;
    procedure pnlNieuweTransactieActie;
    procedure pnlAnnuleerTransactieActie;
    procedure pnlOpslaanTransactieActie;
    procedure FillReferentieInbrengers;

    procedure EvenGeduldTonen;
    procedure EvenGeduldVerbergen;

    procedure VulBetaalwijzesRadiogroep(rg: TRadioGroup);
    function CheckBetaalwijzeIsIngevuld():string;

  public
    { public declarations }

    gridpanelTransactie: TGridTransactie;
    gridpanelTransactieartikel: TGridTransactieartikel;

    procedure SetTotaalPrijs(totaalprijs:double);

    procedure SetSelectedTransactie(
              TransactieId: Integer;
              Totaalbedrag: Double;
              Betaalwijze, Opmerkingen, DatumtijdInvoer, DatumtijdWijziging: string);
    procedure SetPnlWijzigTransactieProps(transactieid:integer);
    procedure SetPnlNieuweTransactieProps();

    procedure ActivateTransactiegrid();
    procedure ActivateTransactieartikelgrid(TransactieId:integer);

  end;

var
  frmTransacties: TfrmTransacties;

implementation

uses
  m_tools, m_constant, crt,
  m_querystuff, ZDataset,
  formwachten,
  formbetaalwijzeinvullen;

{$R *.lfm}

{ TfrmTransacties }

procedure TfrmTransacties.FormActivate(Sender: TObject);
var
  fsize:integer;
  swarning1,swarning2:string;
  transactieid:integer;
begin
  m_tools.CloseOtherScreens(self);

  self.Color:=AppSettings.GlobalBackgroundColor;
  fsize:=m_tools.GetIntegerFromIniFile('FONTS','GlobalFontsize',c_defaultFontsize);
  self.Font.Size:=fsize;

  ActivateTransactiegrid();
  gridpanelTransactie.SetGridRowNrToLast();
  transactieid:=gridpanelTransactie.GetCurrentTransactieId;
  ActivateTransactieartikelgrid(transactieid);
  //SetPnlWijzigTransactieProps(transactieid);

  EnableGrid(gridpanelTransactie, [WSENABLEDNOTEDITABLE]);
  EnableGrid(gridpanelTransactieartikel, [WSDISABLEDNOTEDITABLE]);
  rgBetaalwijzes.ItemIndex := -1;

  EnableTransactieDetails(false);

  swarning1:='';
  swarning2:='';
  if (AppSettings.KortingsFactor <> 1) then
  begin
    swarning1:='LET OP';
    swarning2:='Korting is ' + IntToStr(Round(m_tools.FactorToPercentage(AppSettings.KortingsFactor))) + ' %!';
  end;
  lblTransactieWarning1.Caption:=swarning1;
  lblTransactieWarning2.Caption:=swarning2;
  lblTransactieWarning1.Font.Size:=fsize+2;
  lblTransactieWarning2.Font.Size:=fsize+2;

  gridpanelTransactie.SetGridRowNrToLast();

  TransactieAnnuleren();
  pnlNieuweTransactie.ActivateButtonPanel(true);
  pnlWijzigTransactie.ActivateButtonPanel(gridpanelTransactie.WobbelGrid.RowCount>1);
  pnlTransactieAnnuleren.ActivateButtonPanel(false);
  pnlTransactieOpslaan.ActivateButtonPanel(false);
  pnlTransactieDetails.Color:=appsettings.GridBackgroundColorInactive;

  FillReferentieInbrengers;

  frmEvenGeduld.Visible:=false;

  gridpanelTransactie.SetFocus;
end;

procedure TfrmTransacties.FillReferentieInbrengers;
var
  q : TZQuery;
begin
  try
      try
        cmbReferentieInbrengers.Items.Clear;
        q := m_querystuff.GetSQLite3QueryMdb;

        q.SQL.Clear;
        q.SQL.Text := 'select v.verkoper_id, ' +
            ' v.verkopercode, ' +
            ' naw.achternaam, ' +
            ' case when naw.achternaam is null or naw.achternaam='''' then '''' else naw.achternaam end as omschrijving ' +
            ' from beurs_verkoper as bv ' +
            ' inner join verkoper as v on bv.verkoperid=v.verkoper_id ' +
            ' left join naw on v.nawid=naw.naw_id ' +
            ' where bv.beursid=:BEURSID' +
            ' order by v.verkopercode;';
        q.Params.ParamByName('BEURSID').AsInteger := AppSettings.Beurs.BeursId;
        q.Open;
        while not q.Eof do
        begin
          cmbReferentieInbrengers.Items.Add(q.FieldByName('verkopercode').AsString);
          q.Next;
        end;
        q.Close;
      finally
        q.Free;
      end;
    except
      on E: Exception do
      begin
        //MessageOk('Fout bij invulling verkoper-picklist voor transactieartikelen: ' + E.Message);
      end;
    end;
end;


procedure TfrmTransacties.actionOpslaanTransactieExecute(Sender: TObject);
begin
  pnlOpslaanTransactieActie;
end;

procedure TfrmTransacties.actionWijzigTransactieExecute(Sender: TObject);
begin
  pnlWijzigTransactieActie;
end;

procedure TfrmTransacties.actionAnnuleerTransactieExecute(Sender: TObject);
begin
  pnlAnnuleerTransactieActie;
end;

procedure TfrmTransacties.actionNieuweTransactieExecute(Sender: TObject);
begin
  pnlNieuweTransactieActie;
end;

procedure TfrmTransacties.mmoTransactieOpmerkingenChange(Sender: TObject);
var
  s,stmp:string;
begin
  // voer een wijziging door naar het transactiegrid
  s:='';
  For stmp in mmoTransactieOpmerkingen.Lines do
  begin
    s:= s + stmp;
  end;
  gridpanelTransactie.SetOpmerkingen(s);
end;

function TfrmTransacties.VeranderingenOpgeslagenBijVerlaten():boolean;
begin
  Result:=false;
  if (gridpanelTransactie <> nil) then
  begin
    if (gridpanelTransactieArtikel <> nil) then
    begin
      if (gridpanelTransactie.AnyRowIsDirty or gridpanelTransactieArtikel.AnyRowIsDirty) then
      begin
        if MessageDlg('Wobbel', 'Wijzigingen zijn nog niet opgeslagen. Alsnog opslaan?', mtConfirmation,
        [mbYes, mbNo],0) = mrYes
        then
        begin
          TransactieOpslaan();
          Result:=true;
        end
        else
        begin
          TransactieAnnuleren();
        end;
      end;
    end;
  end;
end;

procedure TfrmTransacties.FormCreate(Sender: TObject);
begin
  //pnlWijzigTransactie:=TWobbelButtonPanel.CreateMe(self, pnlTransactiesControl, 35, 5, 84, 180, 'Wijzig Klant');
  pnlWijzigTransactie:=TWobbelButtonPanel.CreateMe(self, pnlTransactiesControl, 35, 5, 60, 180, 'Wijzig Klant');
  pnlWijzigTransactie.Hint:='Wijzig de klant die in de klanttabel is geselecteerd.';
  pnlWijzigTransactie.SetShortcutCombinationText('(Ctrl+W)');
  pnlWijzigTransactie.OnClick:=@pnlWijzigTransactieClick;

  //pnlNieuweTransactie:=TWobbelButtonPanel.CreateMe(self, pnlTransactiesControl, 139, 5, 84, 180, 'Nieuwe Klant');
  pnlNieuweTransactie:=TWobbelButtonPanel.CreateMe(self, pnlTransactiesControl, 105, 5, 60, 180, 'Nieuwe Klant');
  pnlNieuweTransactie.Hint:='Start met een nieuwe klant.';
  pnlNieuweTransactie.SetShortcutCombinationText('(Ctrl+N)');
  pnlNieuweTransactie.OnClick:=@pnlNieuweTransactieClick;

  //pnlTransactieOpslaan:=TWobbelButtonPanel.CreateMe(self, pnlTransactiesControl, 238, 5, 84, 180, 'Opslaan');
  pnlTransactieOpslaan:=TWobbelButtonPanel.CreateMe(self, pnlTransactiesControl, 175, 5, 60, 180, 'Opslaan');
  pnlTransactieOpslaan.Hint:='Sla de gegevens van de klant op';
  pnlTransactieOpslaan.SetShortcutCombinationText('(Ctrl+S)');
  pnlTransactieOpslaan.OnClick:=@pnlTransactieOpslaanClick;

  //pnlTransactieAnnuleren:=TWobbelButtonPanel.CreateMe(self, pnlTransactiesControl, 339, 5, 84, 180, 'Annuleren');
  pnlTransactieAnnuleren:=TWobbelButtonPanel.CreateMe(self, pnlTransactiesControl, 245, 5, 60, 180, 'Annuleren');
  pnlTransactieAnnuleren.Hint:='Stop de lopende Klant en draai wijzigingen sinds de laatste keer opslaan weer terug.';
  pnlTransactieAnnuleren.SetShortcutCombinationText('(Ctrl+X)');
  pnlTransactieAnnuleren.OnClick:=@pnlTransactieAnnulerenClick;

  //lblTransactieWarning1.Top:=453;
  lblTransactieWarning1.Left:=29;
  //lblTransactieWarning2.Top:=492;
  lblTransactieWarning2.Left:=29;
  lblTransactieWarning1.Top:=335;
  lblTransactieWarning2.Top:=375;

  btnInfo01.Hint:='Vul hier de gegevens van de transactie in.';
  btnInfo02.Hint:='Alleen de knoppen waarvan de acties zinvol zijn op ieder gegeven moment zijn aktief. '+c_CR+
                  'Dit wordt aangegeven met een kleur.';

  VulBetaalwijzesRadiogroep(rgBetaalwijzes);

end;

procedure TfrmTransacties.FormDestroy(Sender: TObject);
begin
  if (pnlWijzigTransactie <> nil) then
  begin
    pnlWijzigTransactie.Free;
  end;
  if (pnlNieuweTransactie <> nil) then
  begin
    pnlNieuweTransactie.Free;
  end;
  if (pnlTransactieOpslaan <> nil) then
  begin
    pnlTransactieOpslaan.Free;
  end;
  if (pnlTransactieAnnuleren <> nil) then
  begin
    pnlTransactieAnnuleren.Free;
  end;
  if (gridpanelTransactieArtikel <> nil) then
  begin
    gridpanelTransactieArtikel.Free;
  end;
  if (gridpanelTransactie <> nil) then
  begin
    gridpanelTransactie.Free;
  end;
end;


procedure TfrmTransacties.FormDeactivate(Sender: TObject);
begin
  VeranderingenOpgeslagenBijVerlaten();

//  self.gridpanelTransactie.WobbelGrid.Clear;

  // om te voorkomen dat de knoppen van het onderliggende scherm doorschijnen
  Delay(m_constant.c_DeactiveDelay_msec);
  Application.ProcessMessages;
end;

procedure TfrmTransacties.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
//
end;

// http://delphi.about.com/od/formsdialogs/a/delphiformlife.htm
// ... OnCloseQuery -> OnClose -> OnDeactivate -> OnHide -> OnDestroy
procedure TfrmTransacties.FormCloseQuery(Sender: TObject; var CanClose: boolean
  );
begin
  CanClose:=true;
  if (VeranderingenOpgeslagenBijVerlaten()) then
  begin
    CanClose:=false;
  end;
end;


procedure TfrmTransacties.FormResize(Sender: TObject);
var
  availWidthLeft, availWidthRight: integer;
  availHeight, transactieDetailsHeight: integer;
  verticalMargin,horizontalMargin: integer;
  valueFromIni:integer;
  n:integer;
begin
  // rechtergedeelte een kwart van de breedte geven .....
  availWidthRight:=Round(pnlTransactiesScreen.Width/4.0);
  if (availWidthRight<200) then
  begin
    availWidthRight:=200;
  end;
  // .... of toch maar constant laten?
  availWidthRight:=200;

  valueFromIni:=m_tools.GetIntegerFromIniFile('TRANSACTIES','TransactieDetailsHeight',90);
  transactieDetailsHeight:=valueFromIni;
  valueFromIni:=m_tools.GetIntegerFromIniFile('TRANSACTIES','HorizontalMargin',30);
  horizontalMargin:=valueFromIni;
  valueFromIni:=m_tools.GetIntegerFromIniFile('TRANSACTIES','VerticalMargin',30);
  verticalMargin:= valueFromIni;

  availWidthLeft:=pnlTransactiesScreen.Width-availWidthRight-horizontalMargin-1;

  pnlTransactieContainer.Left:=1;
  pnlTransactieContainer.Width:=availWidthLeft;
  pnlTransactieContainer.Top:=1;
  pnlTransactieContainer.Height:=pnlTransactiesScreen.Height-2;

  availHeight:= Round((pnlTransactieContainer.Height - 2*verticalMargin - transactieDetailsHeight)/3.0);

  pnlTransactiesControl.Left:=pnlTransactieContainer.Left+pnlTransactieContainer.Width+horizontalMargin+1;
  pnlTransactiesControl.Width:=availWidthRight;
  pnlTransactiesControl.Top:=pnlTransactieContainer.Top;
  pnlTransactiesControl.Height:=pnlTransactieContainer.Height;

  pnlWijzigTransactie.Left:=round((pnlTransactiesControl.Width-pnlWijzigTransactie.Width)/2);
  pnlNieuweTransactie.Left:=round((pnlTransactiesControl.Width-pnlNieuweTransactie.Width)/2);
  pnlTransactieOpslaan.Left:=round((pnlTransactiesControl.Width-pnlTransactieOpslaan.Width)/2);
  pnlTransactieAnnuleren.Left:=round((pnlTransactiesControl.Width-pnlTransactieAnnuleren.Width)/2);

  pnlTransacties.Top:=1;
  pnlTransacties.Height:=availHeight;
  pnlTransacties.Left:=1;
  pnlTransacties.Width:=pnlTransactieContainer.Width-2;

  pnlTransactieDetails.Top:=pnlTransacties.Top+pnlTransacties.Height+verticalMargin;
  pnlTransactieDetails.Height:=transactieDetailsHeight;
  pnlTransactieDetails.Left:=pnlTransacties.Left;
  pnlTransactieDetails.Width:=pnlTransacties.Width;

  rgBetaalwijzes.Top:=10;
  rgBetaalwijzes.Height:=pnlTransactieDetails.Height - 2 * rgBetaalwijzes.Top;
  mmoTransactieOpmerkingen.Top:=rgBetaalwijzes.Top;
  mmoTransactieOpmerkingen.Height:=rgBetaalwijzes.Height;
  lblTransactieBetaalwijze.Top:=rgBetaalwijzes.Top + Round(rgBetaalwijzes.Height/2.0);
  lblTransactieOpmerkingen.Top:=lblTransactieBetaalwijze.Top;

  pnlTransactieArtikelen.Top:=pnlTransactieDetails.Top+pnlTransactieDetails.Height+verticalMargin+1;
  pnlTransactieArtikelen.Height:=2*availHeight;
  pnlTransactieArtikelen.Left:=pnlTransacties.Left;
  pnlTransactieArtikelen.Width:=pnlTransacties.Width;


  n:=Round(pnlTransactiesControl.Height/8.0);
  pnlWijzigTransactie.Top:=35;
  pnlWijzigTransactie.Height:=n-10;
  pnlNieuweTransactie.Top:=pnlWijzigTransactie.Top+pnlWijzigTransactie.Height+10;
  pnlNieuweTransactie.Height:=n-10;
  pnlTransactieOpslaan.Top:=pnlNieuweTransactie.Top+pnlNieuweTransactie.Height+10;
  pnlTransactieOpslaan.Height:=n-10;
  pnlTransactieAnnuleren.Top:=pnlTransactieOpslaan.Top+pnlTransactieOpslaan.Height+10;
  pnlTransactieAnnuleren.Height:=n-10;
  lblTransactieWarning1.Top:=pnlTransactieAnnuleren.Top+pnlTransactieAnnuleren.Height+25;
  lblTransactieWarning2.Top:=lblTransactieWarning1.Top+25;


end;

procedure TfrmTransacties.frmEvenGeduldClick(Sender: TObject);
begin

end;


procedure TfrmTransacties.EnableGrid(gridpanel:TWobbelGridPanel; status:TWobbelGridStatus);
begin
  gridpanel.SetGridStatus(status);
  if (WSENABLEDEDITABLE in gridpanel.WobbelGridStatus) then
  begin
    gridpanel.WobbelGrid.Color:=Appsettings.GridBackgroundColorActive;
  end
  else
  begin
    gridpanel.WobbelGrid.Color:=Appsettings.GridBackgroundColorInactive;
  end;

end;

procedure TfrmTransacties.EnableTransactieDetails(enable:boolean);
begin
  mmoTransactieOpmerkingen.Enabled:=enable;
  rgBetaalwijzes.Enabled:=enable;
end;

procedure TfrmTransacties.pnlNieuweTransactieClick(Sender: TObject);
begin
  pnlNieuweTransactieActie;
end;

procedure TfrmTransacties.pnlTransactieAnnulerenClick(Sender: TObject);
begin
  Screen.Cursor:=crHourGlass;
  pnlAnnuleerTransactieActie;
  Screen.Cursor:=crDefault;
end;

procedure TfrmTransacties.TransactieAnnuleren();
var
  currentRow:integer;
begin
  if ((gridpanelTransactieartikel<>nil) and (gridpanelTransactieartikel.Visible)) then
  begin
    EnableGrid(gridpanelTransactieartikel, [WSDISABLEDNOTEDITABLE]);
  end;
  if ((gridpanelTransactie<>nil) and (gridpanelTransactie.Visible)) then
  begin
    currentRow:=gridpanelTransactie.GetCurrentGridRowNr();
    EnableGrid(gridpanelTransactie, [WSENABLEDNOTEDITABLE]);
    EnableTransactieDetails(false);
    (* deze gaat mis *)gridpanelTransactie.RefreshWobbelGrid();
    // eentje minder omdat GetCurrentGridRowNr het rijnummer incl fixedrows teruggeeft
    gridpanelTransactie.SetGridRowNr(currentRow-1);

    if ((gridpanelTransactieartikel<>nil) and (gridpanelTransactieartikel.Visible)) then
    begin
      EnableGrid(gridpanelTransactieartikel, [WSDISABLEDNOTEDITABLE]);
      gridpanelTransactieartikel.RefreshWobbelGrid();
    end;
  end;

(*
  if ((gridpanelTransactie<>nil) and (gridpanelTransactie.Visible)) then
  begin
    currentRow:=gridpanelTransactie.GetCurrentGridRowNr();
    EnableGrid(gridpanelTransactie, [WSENABLEDNOTEDITABLE]);
    EnableTransactieDetails(false);
    (* deze gaat mis *)gridpanelTransactie.RefreshWobbelGrid();
    // eentje minder omdat GetCurrentGridRowNr het rijnummer incl fixedrows teruggeeft
    gridpanelTransactie.SetGridRowNr(currentRow-1);

    if ((gridpanelTransactieartikel<>nil) and (gridpanelTransactieartikel.Visible)) then
    begin
      EnableGrid(gridpanelTransactieartikel, [WSDISABLEDNOTEDITABLE]);
      gridpanelTransactieartikel.RefreshWobbelGrid();
    end;
  end;
*)
end;

procedure TfrmTransacties.TransactieOpslaan();
var
  currentTransactieRow:integer;
  currentTransactieArtikelRow:integer;
  newTransactieID:integer;
  postOk:boolean;
begin
  if ((gridpanelTransactie<>nil) and (gridpanelTransactie.Visible)) then
  begin
    postOk:=false;

    // totaalbedrag in transactie wordt niet geupdate als 'bedrag' het laatste is wat is aangepast in
    // transactieartikelgrid en er wordt op 'opslaan' geklikt zonder dat de cursor naar een andere cel verplaatst.
    // Verplaats in daarom 'BeweegGrid' het rownr eerst naar de laatste regel om indien nodig een validatecell te forceren.
    // N.B.een niet up-to-date waarde van totaalbedrag bij transactie heeft geen invloed op de totalen
    // omdat bij ieder overzicht de transactieartikelen wordne opgeteld en het totaalbedrag uit tabel
    // transactie nooit daarvoor wordt gebruikt. Achteraf gezien kan dit beter een fictief veld zijn. TODO
    gridpanelTransactieArtikel.BeweegGrid();

    currentTransactieRow:=gridpanelTransactie.GetCurrentGridRowNr();
    newTransactieID:=gridpanelTransactie.PostData;
    if (gridpanelTransactieArtikel.TransactieId = -1) then
    begin
      postOk:=true;
      gridpanelTransactieArtikel.TransactieId:=newTransactieID;
    end;
    EnableGrid(gridpanelTransactie, [WSENABLEDNOTEDITABLE]);
    EnableTransactieDetails(false);

    if ((gridpanelTransactieartikel<>nil) and (gridpanelTransactieartikel.Visible)) then
    begin
      postOk:=gridpanelTransactieartikel.PostData;
      EnableGrid(gridpanelTransactieartikel, [WSDISABLEDNOTEDITABLE]);
    end;
    // hier pas het rownr zetten omdat anders de fillgrid van transactieartiekel wordt getriggerd
    // voordat de nieuwe data wordt opgeslagen
    gridpanelTransactie.RefreshWobbelGrid();
    // eentje minder omdat GetCurrentGridRowNr het rijnummer incl fixedrows teruggeeft
    gridpanelTransactie.SetGridRowNr(currentTransactieRow-1);

    AppSettings.AantalTransactiesNaLaatsteBackup:=AppSettings.AantalTransactiesNaLaatsteBackup+1;
    if (AppSettings.AantalTransactiesNaLaatsteBackup >= AppSettings.MaxAantalTransactiesNaLaatsteBackup) then
    begin
      AppSettings.AantalTransactiesNaLaatsteBackup:=0;
      // Maak een backup na iedere transactie
      BackupDatabaseFile();
    end;

    Screen.Cursor:=crDefault;
    //EvenGeduldVerbergen;

    if (postOk) then
    begin
      MessageOk('Alle wijzigingen zijn opgeslagen.');
    end
    else
    begin
      MessageError('Wijzigingen zijn niet goed opgeslagen. Controleer de laatste transactie s.v.p.');
    end;
  end;
end;

procedure TfrmTransacties.pnlTransactieOpslaanClick(Sender: TObject);
var
  betaalwijzeid: integer;
begin
  try
    betaalwijzeid:=-1;
    if (rgBetaalwijzes.ItemIndex = -1) then
    begin
      gridpanelTransactie.SetBetaalwijze(CheckBetaalwijzeIsIngevuld());
    end;

    Screen.Cursor:=crHourGlass;
    EvenGeduldTonen;
    pnlOpslaanTransactieActie;
    Screen.Cursor:=crDefault;
  finally
    EvenGeduldVerbergen;
  end;
end;

function TfrmTransacties.CheckBetaalwijzeIsIngevuld(): string;
var
  frm: TfrmBetaalwijzeInvullen;
begin
  frm:=TfrmBetaalwijzeInvullen(Application.FindComponent('frmBetaalwijzeInvullen'));
  if (frm = nil) then
  begin
    frm:=TfrmBetaalwijzeInvullen.Create(Self.Owner);
  end;
  m_tools.getPosition(frm);
  frm.ShowModal;
  Result := frm.LastSelectedText;
end;

procedure TfrmTransacties.pnlWijzigTransactieClick(Sender: TObject);
begin
  pnlWijzigTransactieActie;
end;

procedure TfrmTransacties.rgBetaalwijzesSelectionChanged(Sender: TObject);
var
  ix:integer;
  lastSelectedValue:integer;
begin
  ix := rgBetaalwijzes.ItemIndex;
  if (ix >= 0) then
  begin
    lastSelectedValue:=Integer(rgBetaalwijzes.Items.Objects[ix]);
    // voer een wijziging door naar het transactiegrid
    gridpanelTransactie.SetBetaalwijze(rgBetaalwijzes.Items[ix]);
  end;
end;

procedure TfrmTransacties.SetTotaalPrijs(totaalprijs:double);
var
  iCol, iRow:integer;
  bedrag:string;
begin
  if ((gridpanelTransactie<>nil) and (gridpanelTransactie.Visible)) then
  begin
    bedrag:=FormatToMoney(totaalprijs);
    iCol:=gridpanelTransactie.FindWobbelGridColumnIndexByDatabaseFieldName('totaalbedrag');
    iRow:=gridpanelTransactie.EditableRownr;
    if((iRow<>-1) and (gridpanelTransactie.GetGridLastRowNr >= iRow)) then
    begin
      gridpanelTransactie.WobbelGrid.Cells[iCol,iRow]:=bedrag;
      //txtTransactieTotaalbedrag.Text:='€ '+bedrag;

      iCol:=gridpanelTransactie.FindWobbelGridColumnIndexByDatabaseFieldName('isdirty');
      if ((iCol>=0) and not gridpanelTransactie.InitieleVulling) then
      begin
        gridpanelTransactie.WobbelGrid.Cells[iCol, iRow]:='1';
      end;

    end;
  end;
end;




procedure TfrmTransacties.SetSelectedTransactie(
          TransactieId: Integer;
          Totaalbedrag: Double;
          Betaalwijze, Opmerkingen, DatumtijdInvoer, DatumtijdWijziging: string);
begin
  gridpanelTransactie.InitieleVulling:=true;
  SetPnlWijzigTransactieProps(TransactieId);

  //txtTransactieId.Text:=IntToStr(TransactieId);
  //txtTransactieTotaalbedrag.Text:='€ '+FormatToMoney(Totaalbedrag);
  //txtTransactieDatumtijdInvoeren.Text:=DatumtijdInvoer;
  //txtTransactieDatumtijdWijziging.Text:=DatumtijdWijziging;
  mmoTransactieOpmerkingen.Lines.Clear;
  mmoTransactieOpmerkingen.Lines.Add(Opmerkingen);
  m_tools.SetRadioItemOfGroupPicklist(rgBetaalwijzes, Betaalwijze);
  gridpanelTransactie.InitieleVulling:=false;
end;

procedure TfrmTransacties.SetPnlWijzigTransactieProps(transactieid:integer);
begin
  if (transactieid=-1) then
  begin
    pnlWijzigTransactie.Caption:='Wijzig de nieuwe klant'
  end
  else
  begin
    pnlWijzigTransactie.Caption:='Wijzig klant ' + IntToStr(transactieid);
    pnlWijzigTransactie.SetShortcutCombinationText('(Ctrl+W)');
  end;

  lblSelectedTransactie.Caption:=IntToStr(transactieid);
  ActivateTransactieartikelgrid(transactieid);

  //pnlWijzigTransactie.Enabled:=transactieid>=0;

  if (pnlTransactieOpslaan.Enabled) then
  begin
    pnlTransactieOpslaan.ActivateButtonPanel(false);
    pnlTransactieAnnuleren.ActivateButtonPanel(false);
    pnlNieuweTransactie.ActivateButtonPanel(true);
    pnlWijzigTransactie.ActivateButtonPanel(gridpanelTransactie.WobbelGrid.RowCount>1);
  end;
end;


procedure TfrmTransacties.SetPnlNieuweTransactieProps();
begin
  pnlNieuweTransactie.Enabled:=true;
end;

procedure TfrmTransacties.ActivateTransactieartikelgrid(TransactieId:integer);
begin
  if (gridpanelTransactieArtikel = nil) then
  begin
    gridpanelTransactieArtikel:=TGridTransactieArtikel.CreateMe(Self, pnlTransactieArtikelen,
        pnlTransactieArtikelen.Top,
        2,
        pnlTransactieArtikelen.Height-2
        );
  end
  else
  begin
    gridpanelTransactieArtikel.Visible:=true;
  end;
  gridpanelTransactieArtikel.FillGrid(TransactieId);
end;


procedure TfrmTransacties.ActivateTransactiegrid();
begin
  if (gridpanelTransactie = nil) then
  begin
    gridpanelTransactie:=TGridTransactie.CreateMe(Self, pnlTransacties,
        pnlTransacties.Top,
        2,
        pnlTransacties.Height-2
        );
    gridpanelTransactie.Visible:=true;
  end
  else
  begin
    gridpanelTransactie.Visible:=true;
    gridpanelTransactie.RefreshWobbelGrid();
  end;
end;

procedure TfrmTransacties.pnlWijzigTransactieActie;
var
  rows:integer;
begin
  if (pnlWijzigTransactie.Enabled) then
  begin
    if ((gridpanelTransactie<>nil) and (gridpanelTransactie.Visible)) then
    begin
      EnableGrid(gridpanelTransactie, [WSDISABLEDNOTEDITABLE]);
      EnableTransactieDetails(true);
      gridpanelTransactie.EditableRownr:=gridpanelTransactie.WobbelGrid.Row;

      EnableGrid(gridpanelTransactieartikel, [WSENABLEDEDITABLE]);
      rows:=gridpanelTransactieartikel.WobbelGrid.RowCount;
      if (rows=1) then
      begin
        gridpanelTransactieartikel.AddARecord();
      end;
      gridpanelTransactieartikel.FocusToStartupColumn();
    end;
    pnlTransactieOpslaan.ActivateButtonPanel(true);
    pnlTransactieAnnuleren.ActivateButtonPanel(true);
    pnlNieuweTransactie.ActivateButtonPanel(false);
    pnlWijzigTransactie.ActivateButtonPanel(false);
    pnlTransactieDetails.Color:=appsettings.GridBackgroundColorActive;
  end;
end;

procedure TfrmTransacties.pnlNieuweTransactieActie;
var
  rows:integer;
begin
  if (pnlNieuweTransactie.Enabled) then
  begin
    if ((gridpanelTransactie<>nil) and (gridpanelTransactie.Visible)) then
    begin
      rgBetaalwijzes.ItemIndex := -1;

      gridpanelTransactie.SetGridStatus([WSENABLEDEDITABLE]);
      gridpanelTransactie.AddNewTransactie();
      EnableGrid(gridpanelTransactie, [WSDISABLEDNOTEDITABLE]);

      EnableTransactieDetails(true);

      if ((gridpanelTransactieartikel<>nil) and (gridpanelTransactieartikel.Visible)) then
      begin
        EnableGrid(gridpanelTransactieartikel, [WSENABLEDEDITABLE]);
        rows:=gridpanelTransactieartikel.WobbelGrid.RowCount;
        if (rows=1) then
        begin
          gridpanelTransactieartikel.AddARecord();
        end;
        gridpanelTransactieartikel.FocusToStartupColumn();
      end;
    end;
    if (gridpanelTransactieartikel.WobbelGrid.IsVisible and gridpanelTransactieartikel.WobbelGrid.Enabled) then
    begin
      gridpanelTransactieartikel.WobbelGrid.SetFocus;
    end;

    pnlTransactieOpslaan.ActivateButtonPanel(true);
    pnlTransactieAnnuleren.ActivateButtonPanel(true);
    pnlNieuweTransactie.ActivateButtonPanel(false);
    pnlWijzigTransactie.ActivateButtonPanel(false);
    pnlTransactieDetails.Color:=appsettings.GridBackgroundColorActive;
  end;
end;

procedure TfrmTransacties.pnlAnnuleerTransactieActie;
begin
  if (pnlTransactieAnnuleren.Enabled) then
  begin
    TransactieAnnuleren();
    pnlTransactieOpslaan.ActivateButtonPanel(false);
    pnlTransactieAnnuleren.ActivateButtonPanel(false);
    pnlNieuweTransactie.ActivateButtonPanel(true);
    pnlWijzigTransactie.ActivateButtonPanel(gridpanelTransactie.WobbelGrid.RowCount>1);
    pnlTransactieDetails.Color:=appsettings.GridBackgroundColorInactive;
  end;
end;

procedure TfrmTransacties.pnlOpslaanTransactieActie;
begin
  if (pnlTransactieOpslaan.Enabled) then
  begin
    TransactieOpslaan();
    pnlTransactieOpslaan.ActivateButtonPanel(false);
    pnlTransactieAnnuleren.ActivateButtonPanel(false);
    pnlNieuweTransactie.ActivateButtonPanel(true);
    pnlWijzigTransactie.ActivateButtonPanel(gridpanelTransactie.WobbelGrid.RowCount>1);
    pnlTransactieDetails.Color:=appsettings.GridBackgroundColorInactive;
  end;
end;

procedure TfrmTransacties.EvenGeduldTonen;
var
  links: integer;
  vrijeruimte:integer;
  marge:integer;
begin
  marge:=4;
  // originele situatie
  frmEvenGeduld.imgWachten.Top:=56;
  frmEvenGeduld.imgWachten.Height:=208;
  frmEvenGeduld.Top:=103;
  frmEvenGeduld.Height:=333;

  links:=Round(pnlTransactiesControl.Left + pnlTransactiesControl.Width/2.0 - frmEvenGeduld.Width/2.0);
  vrijeruimte:=pnlTransactieAnnuleren.Top + pnlTransactieAnnuleren.Height - pnlWijzigTransactie.Top - frmEvenGeduld.Height - 2*marge;

  if (vrijeruimte <= frmEvenGeduld.Height) then
  begin
    frmEvenGeduld.Top:=pnlWijzigTransactie.Top+marge;
    frmEvenGeduld.Height:=pnlTransactieAnnuleren.Top + pnlTransactieAnnuleren.Height - pnlWijzigTransactie.Top - 2*marge;
    if (frmEvenGeduld.Height < frmEvenGeduld.imgWachten.Height) then
    begin
      frmEvenGeduld.imgWachten.Top:=Round((frmEvenGeduld.Height - frmEvenGeduld.imgWachten.Height)/2.0)-marge;
    end
    else
    begin
      frmEvenGeduld.imgWachten.Top:=Round((frmEvenGeduld.Height-frmEvenGeduld.imgWachten.Height)/2.0)-marge;
    end;
  end
  else
  begin
    frmEvenGeduld.Top:=pnlWijzigTransactie.Top+Round(vrijeruimte / 2.0)-marge;
  end;

  frmEvenGeduld.Left:=links;

  frmEvenGeduld.Visible:=true;
end;

procedure TfrmTransacties.EvenGeduldVerbergen;
begin
  frmEvenGeduld.Visible:=false;
end;


procedure TfrmTransacties.VulBetaalwijzesRadiogroep(rg: TRadioGroup);
var
  q : TZQuery;
  ix:integer;
  rb: TRadioButton;
begin
  try
    try
      ix := rg.Items.Count-1;
      while ix >= 0 do
      begin
        rg.Items.Delete(ix);
        ix := ix - 1;
      end;

      q := m_querystuff.GetSQLite3QueryMdb;
      q.SQL.Clear;
      q.SQL.Text:='select b.betaalwijze_id, b.omschrijving ' +
         ' from betaalwijze as b ' +
         ' order by b.omschrijving';
      q.Open;
      ix:=0;
      while not q.Eof do
      begin
        rg.Items.AddObject(q.FieldByName('omschrijving').AsString, TObject(q.FieldByName('betaalwijze_id').AsInteger));

        ix := ix+1;

        q.Next;
      end;
      q.Close;

      //rb:=TRadioButton(rg.Items[0]);

    finally
      q.Free;
    end;
  except
    on E: Exception do
    begin
      MessageError('Fout bij vullen buttons met betaalwijzes: ' + E.Message);
    end;
  end;
end;


end.

