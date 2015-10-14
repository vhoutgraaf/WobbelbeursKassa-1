//------------------------------------------------------------------------------
// Name        : mainform.pas
// Purpose     : Implementatie van het hoofdscherm TfrmMain.
// Environment : Free Pascal 2.4.2, Windows XP
// Notes       :
// Author      : Vincent Houtgraaf, Bunnik
// Date        : aug 2011
// Modified    :
//------------------------------------------------------------------------------
unit formmain;

{$mode objfpc}{$H+}
{$DEFINE DEVELOP}



interface


uses
  Classes, SysUtils, sqlite3conn, FileUtil, Forms, Controls, Graphics,
  Dialogs, DbCtrls, StdCtrls, ExtCtrls,
  Grids, Menus, Buttons,
  LCLType, ActnList,
  c_appsettings, m_wobbeldata, c_wobbelbuttonpanel;

type
  TWobbelActiveerTransactieButtonStatus = set of (absStart, absIngelogd, absDatabaseGeselecteerd, absBeursGekozen, absVerkopersPresentInBeurs, absAccountsPresent, absKassaGekozen, absKassaGeopend);

type
  { TfrmMain }

  TfrmMain = class(TForm)
    aclstMain: TActionList;
    btnGebruikersbeheer: TButton;
    chkGebruikersbeheer: TCheckBox;
    grpboxBeursInstellen: TGroupBox;
    grpboxTransacties: TGroupBox;
    grpboxSelecteerDatabase: TGroupBox;
    grpboxInloggen: TGroupBox;
    lblActieveMDbNaam: TLabel;
    lblActief: TLabel;
    OpenTransactiescherm: TAction;
    OpenKassaOpensluitscherm: TAction;
    OpenKassascherm: TAction;
    OpenVerkoperssscherm: TAction;
    OpenBeursscherm: TAction;
    OpenDatabasescherm: TAction;
    OpenInlogscherm: TAction;
    btnInfo01: TBitBtn;
    btnOpenDatabase: TButton;
    btnOpenInloggen: TButton;
    btnOpenBeurs: TButton;
    btnOpenKassa: TButton;
    btnOpenKassabedrag: TButton;
    btnOpenVerkopersInBeursPresent: TButton;
    chkBeursGekozen: TCheckBox;
    chkDatabaseGeselecteerd: TCheckBox;
    chkIngelogd: TCheckBox;
    chkKassaGekozen: TCheckBox;
    chkKassaGeopend: TCheckBox;
    chkVerkopersInBeursPresent: TCheckBox;
    grpChecks: TGroupBox;
    lblWelkom: TLabel;
    pnlActiveerTransactie: TWobbelButtonPanel;

    procedure btnGebruikersbeheerClick(Sender: TObject);
    procedure btnOpenDatabaseClick(Sender: TObject);
    procedure btnOpenBeursClick(Sender: TObject);
    procedure btnOpenInloggenClick(Sender: TObject);
    procedure btnOpenKassabedragClick(Sender: TObject);
    procedure btnOpenKassaClick(Sender: TObject);
    procedure btnOpenVerkopersInBeursPresentClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure lblActiefMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure OpenBeursschermExecute(Sender: TObject);
    procedure OpenDatabaseschermExecute(Sender: TObject);
    procedure OpenInlogschermExecute(Sender: TObject);
    procedure OpenKassaOpensluitschermExecute(Sender: TObject);
    procedure OpenKassaschermExecute(Sender: TObject);
    procedure OpenTransactieschermExecute(Sender: TObject);
    procedure OpenVerkoperssschermExecute(Sender: TObject);
    procedure pnlActiveerTransactieClick(Sender: TObject);

  private
    { private declarations }
    FWobbelActiveerTransactieButtonStatus: TWobbelActiveerTransactieButtonStatus;

    function CheckKassaIsGesloten():boolean;

  public
    { public declarations }
    procedure SetTitle;
    function showInstellingenPopup:boolean;

    property WobbelActiveerTransactieButtonStatus: TWobbelActiveerTransactieButtonStatus read FWobbelActiveerTransactieButtonStatus write FWobbelActiveerTransactieButtonStatus;
    procedure SetActiveerTransactieButtonCaption(atbc: TWobbelActiveerTransactieButtonStatus; bToevoegen: boolean);

    procedure UpdateBeursProperties;
    procedure UpdateKassaProperties;

  end;


var
  frmMain: TfrmMain;

implementation

uses
  formdialoog, c_beurs, m_tools, m_constant;

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
var
  dbNaam:String;
begin
  pnlActiveerTransactie:=TWobbelButtonPanel.CreateMe(self, grpChecks, 40, 136, 60, 182, 'Open transactiescherm');
  pnlActiveerTransactie.Parent:=grpboxTransacties;
  pnlActiveerTransactie.Hint:='Als aan alle voorwaarden is voldaan kan het Transactiescherm worden geopend met deze knop.';
  pnlActiveerTransactie.SetShortcutCombinationText('(Ctrl+T)');
  pnlActiveerTransactie.OnClick:=@pnlActiveerTransactieClick;

  // startsituatie
  WobbelActiveerTransactieButtonStatus:=[absStart];
  SetActiveerTransactieButtonCaption([absStart], true);

  // Database connectie leggen
  if (dmWobbel.connWobbelMdb.Connected) then
  begin
    dmWobbel.connWobbelMdb.Disconnect;
  end;
  dmWobbel.connWobbelMdb.Database:='';
  dbNaam := GetDatabaseFile(true);
  if (dbNaam <> '') then
  begin
    SetActiveerTransactieButtonCaption([absDatabaseGeselecteerd], true);
    AppSettings:=TAppSettings.Create;

    UpdateBeursProperties;
    if (AppSettings.Beurs.BeursIsOk) then
    begin
      //UpdateKassaProperties;
    end;
  end
  else
  begin
    SetActiveerTransactieButtonCaption([absDatabaseGeselecteerd], false);
  end;
  SetTitle;

  btnOpenDatabase.Hint:='Selecteer hier welke database moet worden gebruikt.';
  btnOpenInloggen.Hint:='In- en uitloggen.';
  btnOpenBeurs.Hint:='Geef aan welke beurs in gebruik is.';
  btnOpenKassa.Hint:='Beheer de kassa''s die in de geselecteerde beurs in gebruik zijn.'+c_CR+
                     'Geef hier ook aan welkee van deze kassa''s de actieve kassa is.';
  btnOpenKassabedrag.Hint:='Beheer de open- en sluitbedragen van de geselecteerde kassa.'+c_CR+
                            'Voordat transacties kunnen worden ingevoerd moet worden ingevuld welk bedrag in kas is'+c_CR+
                           'Net zo kan het programma pas worden gesloten als is ingevuld welk bedrag in kas is.';
  btnOpenVerkopersInBeursPresent.Hint:='Beheer de inbrengers die meedoen met de geselecteerde beurs.';
  btnGebruikersbeheer.Hint:='Beheer de accounts voor toegang tot de kassa.';

  btnInfo01.Hint:='Er kunnen pas transacties worden ingevoerd als aan alle voorwaarden is voldaan.'+c_CR+
                  'Dat is het geval als alle selectievakken zijn aangevinkt.'+c_CR+
                  'Voor kassagebruik zijn de vakken in geel aan te passen; voor beheer is alles beschikbaar.';

  FilenameTotalLengthTooLong();

end;

procedure TfrmMain.FormActivate(Sender: TObject);
begin
  self.Color:=AppSettings.GlobalBackgroundColor;
  self.Font.Size:=AppSettings.GlobalFontSize;

  SetActiveerTransactieButtonCaption([absIngelogd], AppSettings.Vrijwilliger.VrijwilligerIsIngelogd);
  if not AppSettings.Vrijwilliger.VrijwilligerIsIngelogd then
  begin
    Application.MainForm.Menu.Items.Items[0].Items[1].Caption:='Inloggen';
  end
  else
  begin
    Application.MainForm.Menu.Items.Items[0].Items[1].Caption:='Uitloggen';
  end;

  UpdateBeursProperties;
  if (AppSettings.Beurs.BeursIsOk) then
  begin
    UpdateKassaProperties;
  end;

  SetTitle;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CheckKassaIsGesloten;
end;


procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  if (pnlActiveerTransactie <> nil) then
  begin
    pnlActiveerTransactie.Free;
  end;
  if (AppSettings <> nil) then
  begin
    AppSettings.Free;
  end;

end;



function TfrmMain.CheckKassaIsGesloten():boolean;
var
  frmDialoog: TfrmDialoog;
  loopCount:integer;
begin
  Result:=false;
  loopCount:=0;
//  if (AppSettings.Vrijwilliger.VrijwilligerIsIngelogd) then // mag ook
  if not (lsNietIngelogd in AppSettings.WobbelLoginStatus) then
  begin
    while ((AppSettings.Kassa.KassaStatusIsGeopend)) do
    begin
      try
        frmDialoog:=TfrmDialoog.Create(nil);
        frmDialoog.SetLabeltekst('','','','De kassa is nog niet afgesloten. Svp dit eerst doen');
        frmDialoog.CancelButtonVisibility(false);
        m_tools.getPosition(frmDialoog);
        frmDialoog.ShowModal;
        dmWobbel.OpenKassaOpenSluit(true);
      finally
        if (frmDialoog<>nil) then
        begin
          frmDialoog.Free;
          frmDialoog:=nil;
        end;
      end;
      loopCount:=loopCount+1;
    end;
  end;
end;

(*
procedure TfrmMain.EmbeddedFormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  // Do all embedded form closing processig...
  ShowMessage('Embedded form is closing...');
end;

procedure TfrmMain.TFormMain.MenuItemStatesClick(Sender: TObject);
var FormInPanel: TForm;
begin
  //...
  FormInPanel.OnClose := @EmbeddedFormClose;
end;
*)

procedure TfrmMain.FormDeactivate(Sender: TObject);
begin
  //CheckKassaIsGesloten;
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
  grpChecks.Left:=Round(self.Width/2.0-grpChecks.Width/2.0);
  grpChecks.Top:=Round(self.Height/2.0-grpChecks.Height/2.0);
  lblWelkom.Left:=Round(self.Width/2.0-lblWelkom.Width/2.0);
  lblWelkom.Top:=Round(grpChecks.Top-lblWelkom.Height-4);
end;

procedure TfrmMain.lblActiefMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  lblActief.Hint:='Pad: ' + ExtractFileDir(ExpandFileName(dmWobbel.connWobbelMdb.Database)) + m_constant.c_CR +
                  'Database: ' + ExtractFileName(dmWobbel.connWobbelMdb.Database);
end;

procedure TfrmMain.OpenBeursschermExecute(Sender: TObject);
begin
  dmWobbel.OpenBeurs();
end;

procedure TfrmMain.OpenDatabaseschermExecute(Sender: TObject);
begin
  dmWobbel.OpenDatabase();
end;

procedure TfrmMain.OpenInlogschermExecute(Sender: TObject);
begin
  dmWobbel.OpenInloggen();
end;

procedure TfrmMain.OpenKassaOpensluitschermExecute(Sender: TObject);
begin
  dmWobbel.OpenKassaOpenSluit(false);
end;

procedure TfrmMain.OpenKassaschermExecute(Sender: TObject);
begin
  dmWobbel.OpenBeursKassa();
end;

procedure TfrmMain.OpenTransactieschermExecute(Sender: TObject);
begin
  dmWobbel.OpenTransacties();
end;

procedure TfrmMain.OpenVerkoperssschermExecute(Sender: TObject);
begin
  dmWobbel.OpenVerkopersBeheren();
end;


procedure TfrmMain.UpdateBeursProperties;
begin
  AppSettings.Beurs.setBeursProperties;
  SetActiveerTransactieButtonCaption([absBeursGekozen], AppSettings.Beurs.BeursIsOk);
  SetActiveerTransactieButtonCaption([absVerkopersPresentInBeurs], AppSettings.Beurs.AantalVerkopersInActieveBeurs>0);
  SetActiveerTransactieButtonCaption([absAccountsPresent], AppSettings.Vrijwilliger.AantalActieveAccounts>1);
end;

procedure TfrmMain.UpdateKassaProperties;
begin
  AppSettings.Kassa.setKassaProperties(AppSettings.Beurs.BeursId);
  SetActiveerTransactieButtonCaption([absKassaGekozen], AppSettings.Kassa.KassaIsGekozen);

  AppSettings.Kassa.setKassaStatus(AppSettings.Beurs.BeursId);
  SetActiveerTransactieButtonCaption([absKassaGeopend], AppSettings.Kassa.KassaStatusIsGeopend);
end;

procedure TfrmMain.SetActiveerTransactieButtonCaption(atbc: TWobbelActiveerTransactieButtonStatus; bToevoegen: boolean);
var
  isAdmin:boolean;
  isSuperAdmin:boolean;
begin

  if (absStart in atbc) then
  begin
    if (bToevoegen) then
    begin
      WobbelActiveerTransactieButtonStatus:=WobbelActiveerTransactieButtonStatus+[absStart];
    end
    else
    begin
      WobbelActiveerTransactieButtonStatus:=WobbelActiveerTransactieButtonStatus-[absStart];
    end;
  end
  else if (absIngelogd in atbc) then
  begin
    if (bToevoegen) then
    begin
      WobbelActiveerTransactieButtonStatus:=WobbelActiveerTransactieButtonStatus+[absIngelogd];
    end
    else
    begin
      WobbelActiveerTransactieButtonStatus:=WobbelActiveerTransactieButtonStatus-[absIngelogd];
    end;
  end
  else if (absDatabaseGeselecteerd in atbc) then
  begin
    if (bToevoegen) then
    begin
      WobbelActiveerTransactieButtonStatus:=WobbelActiveerTransactieButtonStatus+[absDatabaseGeselecteerd];
    end
    else
    begin
      WobbelActiveerTransactieButtonStatus:=WobbelActiveerTransactieButtonStatus-[absDatabaseGeselecteerd];
    end;
  end
  else if (absBeursGekozen in atbc) then
  begin
    if (bToevoegen) then
    begin
      WobbelActiveerTransactieButtonStatus:=WobbelActiveerTransactieButtonStatus+[absBeursGekozen];
    end
    else
    begin
      WobbelActiveerTransactieButtonStatus:=WobbelActiveerTransactieButtonStatus-[absBeursGekozen];
    end;
  end
  else if (absVerkopersPresentInBeurs in atbc) then
  begin
    if (bToevoegen) then
    begin
      WobbelActiveerTransactieButtonStatus:=WobbelActiveerTransactieButtonStatus+[absVerkopersPresentInBeurs];
    end
    else
    begin
      WobbelActiveerTransactieButtonStatus:=WobbelActiveerTransactieButtonStatus-[absVerkopersPresentInBeurs];
    end;
  end
  else if (absAccountsPresent in atbc) then
  begin
    if (bToevoegen) then
    begin
      WobbelActiveerTransactieButtonStatus:=WobbelActiveerTransactieButtonStatus+[absAccountsPresent];
    end
    else
    begin
      WobbelActiveerTransactieButtonStatus:=WobbelActiveerTransactieButtonStatus-[absAccountsPresent];
    end;
  end
  else if (absKassaGekozen in atbc) then
  begin
    if (bToevoegen) then
    begin
      WobbelActiveerTransactieButtonStatus:=WobbelActiveerTransactieButtonStatus+[absKassaGekozen];
    end
    else
    begin
      WobbelActiveerTransactieButtonStatus:=WobbelActiveerTransactieButtonStatus-[absKassaGekozen];
    end;
  end
  else if (absKassaGeopend in atbc) then
  begin
    if (bToevoegen) then
    begin
      WobbelActiveerTransactieButtonStatus:=WobbelActiveerTransactieButtonStatus+[absKassaGeopend];
    end
    else
    begin
      WobbelActiveerTransactieButtonStatus:=WobbelActiveerTransactieButtonStatus-[absKassaGeopend];
    end;
  end;

  chkDatabaseGeselecteerd.Checked:=false;
  chkIngelogd.Checked:=false;
  chkBeursGekozen.Checked:=false;
  chkVerkopersInBeursPresent.Checked:=false;
  chkKassaGekozen.Checked:=false;
  chkKassaGeopend.Checked:=false;
  chkGebruikersbeheer.Checked:=false;

  btnOpenDatabase.Enabled:=false;
  dmWobbel.EnableOpenInstellingenAlgemeen(true);
  btnOpenInloggen.Enabled:=false;
  btnOpenBeurs.Enabled:=false;
  btnOpenVerkopersInBeursPresent.Enabled:=false;
  btnGebruikersbeheer.Enabled:=false;

  btnOpenKassa.Enabled:=false;
  btnOpenKassabedrag.Enabled:=false;


  dmWobbel.EnableOpenInloggen(false);
  dmWobbel.EnableOpenBeurs(false);
  dmWobbel.EnableOpenVerkopersBeheren(false);
  dmWobbel.EnableOpenBeursKassa(false);
  dmWobbel.EnableOpenKassaOpenSluit(false);
  dmWobbel.EnableOpenTransacties(false);

  isAdmin:=false;
  isSuperAdmin:=false;
  if ((AppSettings <> nil) and (AppSettings.Vrijwilliger <> nil)) then
  begin
    isAdmin:=AppSettings.Vrijwilliger.VrijwilligerIsAdmin;
    isSuperAdmin:=AppSettings.Vrijwilliger.IsSuperAdmin;
  end;

  dmWobbel.EnableOpenDatabase(isAdmin or isSuperAdmin);
  dmWobbel.EnableOpenAccountsBeheren(isAdmin or isSuperAdmin);
  dmWobbel.EnableOpenArtikeltypes(isAdmin or isSuperAdmin);
  dmWobbel.EnableOpenBetaalwijzes(isAdmin or isSuperAdmin);
  dmWobbel.EnableOpenInstellingenBeheer(isAdmin or isSuperAdmin);
  dmWobbel.EnableOpenKassaImporteren(isAdmin or isSuperAdmin);
  dmWobbel.EnableOpenOverzichtPerKassa(isAdmin or isSuperAdmin);
  dmWobbel.EnableOpenOverzichtBeurs(isAdmin or isSuperAdmin);
  dmWobbel.EnableOpenOverzichtOpbrengstPerInbrenger(isAdmin or isSuperAdmin);
  dmWobbel.EnableOpenOverzichtOpbrengstPerInbrengerPerKassa(false);
  dmWobbel.EnableOpenOverzichtTransactiesPerInbrenger(isAdmin or isSuperAdmin);
  dmWobbel.EnableOpenOverzichtTotaalExport(isAdmin or isSuperAdmin);
  dmWobbel.EnableOpenGrafiek01(isSuperAdmin);

  if (absKassaGeopend in WobbelActiveerTransactieButtonStatus) then
  begin
    chkKassaGeopend.Checked:=true;
  end;
  if (absKassaGekozen in WobbelActiveerTransactieButtonStatus) then
  begin
    chkKassaGekozen.Checked:=true;
    btnOpenKassa.Enabled:=isAdmin;
    btnOpenKassabedrag.Enabled:=AppSettings.Vrijwilliger.VrijwilligerIsIngelogd;
    dmWobbel.EnableOpenBeursKassa(btnOpenKassa.Enabled);
    dmWobbel.EnableOpenKassaOpenSluit(btnOpenKassabedrag.Enabled);
  end;
  if (absBeursGekozen in WobbelActiveerTransactieButtonStatus) then
  begin
    chkBeursGekozen.Checked:=true;

    btnOpenKassa.Enabled:=isAdmin;
    dmWobbel.EnableOpenBeursKassa(btnOpenKassa.Enabled);

    btnOpenVerkopersInBeursPresent.Enabled:=isAdmin;
    dmWobbel.EnableOpenVerkopersBeheren(btnOpenVerkopersInBeursPresent.Enabled);
    //dmWobbel.EnableOpenVerkopersKoppelen(btnOpenVerkopersInBeursPresent.Enabled);
  end;
  if (absVerkopersPresentInBeurs in WobbelActiveerTransactieButtonStatus) then
  begin
    chkVerkopersInBeursPresent.Checked:=true;
  end;
  if (absAccountsPresent in WobbelActiveerTransactieButtonStatus) then
  begin
    chkGebruikersbeheer.Checked:=true;
  end;
  if (absIngelogd in WobbelActiveerTransactieButtonStatus) then
  begin
    chkIngelogd.Checked:=true;
    btnOpenBeurs.Enabled:=isAdmin;
    dmWobbel.EnableOpenBeurs(btnOpenBeurs.Enabled);
    btnOpenDatabase.Enabled:=isAdmin;

    btnGebruikersbeheer.Enabled:=isAdmin;
  end;
  if (absDatabaseGeselecteerd in WobbelActiveerTransactieButtonStatus) then
  begin
    chkDatabaseGeselecteerd.Checked:=true;
    btnOpenInloggen.Enabled:=true;
    dmWobbel.EnableOpenInloggen(btnOpenInloggen.Enabled);
  end;

  pnlActiveerTransactie.ActivateButtonPanel(chkIngelogd.Checked
    and chkDatabaseGeselecteerd.Checked
    and chkBeursGekozen.Checked
    and chkVerkopersInBeursPresent.Checked
    and chkKassaGekozen.Checked
    and chkKassaGeopend.Checked);
  dmWobbel.EnableOpenTransacties(pnlActiveerTransactie.Enabled);

end;


procedure TfrmMain.pnlActiveerTransactieClick(Sender: TObject);
begin
  if (showInstellingenPopup) then
  begin
    dmWobbel.OpenTransacties();
  end;
end;


procedure TfrmMain.SetTitle;
var
  s: string;
begin
  s:='Wobbelbeurs Kassa / ';
  if (AppSettings.Beurs.BeursOmschrijving <> c_beurs.defaultBeursOmschrijving) then
  begin
    s:=s+'Beurs:' + AppSettings.Beurs.BeursOmschrijving;
  end;
  if (AppSettings.Kassa.KassaIsGekozen) then
  begin
    s:=s+' / Kassa:'+AppSettings.Kassa.KassaNr;
  end;
  if (AppSettings.Vrijwilliger.Inlognaam <> '') then
  begin
    s:=s+'/ Ingelogd als ''' + AppSettings.Vrijwilliger.Inlognaam + ''' met rol ''' + AppSettings.Vrijwilliger.Rolnaam + '''';
  end
  else
  begin
    s:=s+'. Niet ingelogd';
  end;
  frmMain.Caption := s;

  lblActieveMDbNaam.Font.Size:=self.Font.Size+1;
  lblActieveMDbNaam.Caption:=ExtractFileName(dmWobbel.connWobbelMdb.Database);
end;


function TfrmMain.showInstellingenPopup:boolean;
var
  frmDialoog: TfrmDialoog;
  iDialoogRetval:integer;
  bRetval:boolean;
begin
  bRetval:=false;
  try
    frmDialoog:=TfrmDialoog.Create(nil);
    frmDialoog.SetLabeltekst('De huidige instellingen zijn:',
            'Database: ' + ExtractFileName(dmWobbel.connWobbelMdb.Database),
            'Beurs: ' + AppSettings.Beurs.BeursOmschrijving,
            'Kassa: ' + AppSettings.Kassa.KassaNr,
            '',
            'Is dit correct? Zo nee, klik op ''Afbreken'',',
            'een beheerder kan de waarden aanpassen.',
            'Zo ja, klik op ''Ok''.');
    m_tools.getPosition(frmDialoog);
    iDialoogRetval:=frmDialoog.ShowModal;
    if (iDialoogRetval=1) then  // Ok geklikt
    begin
      bRetval:=true;
    end;
  finally
    if (frmDialoog<>nil) then
    begin
      frmDialoog.Free;
      frmDialoog:=nil;
    end;
  end;
  Result:=bRetval;
end;


procedure TfrmMain.btnOpenDatabaseClick(Sender: TObject);
begin
  dmWobbel.OpenDatabase();
end;

procedure TfrmMain.btnGebruikersbeheerClick(Sender: TObject);
begin
  dmWobbel.OpenAccountsBeheren;
end;

procedure TfrmMain.btnOpenBeursClick(Sender: TObject);
begin
  dmWobbel.OpenBeurs();
end;

procedure TfrmMain.btnOpenInloggenClick(Sender: TObject);
begin
  dmWobbel.OpenInloggen();
end;

procedure TfrmMain.btnOpenKassabedragClick(Sender: TObject);
begin
  dmWobbel.OpenKassaOpenSluit(false);
end;

procedure TfrmMain.btnOpenKassaClick(Sender: TObject);
begin
  dmWobbel.OpenBeursKassa();
end;

procedure TfrmMain.btnOpenVerkopersInBeursPresentClick(Sender: TObject);
begin
  dmWobbel.OpenVerkopersBeheren();
end;


end.

