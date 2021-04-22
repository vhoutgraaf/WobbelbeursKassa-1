//------------------------------------------------------------------------------
// Name        : m_wobbeldata
// Purpose     : store for dataobjects.
// Environment : Free Pascal 2.4.2, Windows XP
// Notes       : -
// Author      : Vincent Houtgraaf, Bunnik
// Date        : aug 2011
// Modified    :
//------------------------------------------------------------------------------
unit m_wobbeldata;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, FileUtil, Dialogs, Menus,
  ZConnection, ZDataset,
  c_appsettings;

type

  { TdmWobbel }

  TdmWobbel = class(TDataModule)

    connWobbelMdb: TZConnection;
    connWobbelDdb: TZConnection;
    dlgExporteerSQLNaarXls: TSaveDialog;
    dsOverzicht: TDatasource;
    dsKassabedrag: TDatasource;
    dlgDatabase: TOpenDialog;
    dsBetaalwijze: TDatasource;
    dsArtikeltype: TDatasource;
    mnuGrafiekTransactieTijd: TMenuItem;
    mnuAbout: TMenuItem;
    mnuOpenHelp: TMenuItem;
    mnuOverzichtTotaalExport: TMenuItem;
    mnuOverzichtTransactiesPerInbrenger: TMenuItem;
    mnuOverzichtBeurs: TMenuItem;
    mnuImportExport: TMenuItem;
    mnuVerkopersBeheren: TMenuItem;
    mnuLoginAccounts: TMenuItem;
    mnuOverzichtKassas: TMenuItem;
    mnuOverzichtVerkoper: TMenuItem;
    mnuOverzichtVerkoperPerKassa: TMenuItem;
    mnuOverzichten: TMenuItem;
    mnuInstellingenBeheer: TMenuItem;
    mnuImporteerKassa: TMenuItem;
    mnuBeheer: TMenuItem;
    mnuKassaBedrag: TMenuItem;
    mnuItemTransacties: TMenuItem;
    mnuDatabase: TMenuItem;
    mnuItemKassa: TMenuItem;
    mnuItemBeurs: TMenuItem;
    mnuItemInloggen: TMenuItem;
    mnuInloggen: TMenuItem;
    mnuArtikeltypes: TMenuItem;
    mnuBetaalwijzes: TMenuItem;
    mnuAlgemeen: TMenuItem;
    mnuInstellingen: TMenuItem;
    mnuHelp: TMenuItem;
    mnMain: TMainMenu;
    dlgSelectDatabaseExtraBackupDirectory: TSelectDirectoryDialog;
    tblBetaalwijze: TZQuery;
    tblArtikeltype: TZQuery;
    vwKassabedrag: TZQuery;
    vwOverzicht: TZQuery;
    procedure DataModuleCreate(Sender: TObject);
    procedure mnuAboutClick(Sender: TObject);
    procedure mnuGrafiekTransactieTijdClick(Sender: TObject);
    procedure mnuLoginAccountsClick(Sender: TObject);
    procedure mnuDatabaseClick(Sender: TObject);
    procedure mnuImporteerKassaClick(Sender: TObject);
    procedure mnuInstellingenBeheerClick(Sender: TObject);
    procedure mnuInstellingenClick(Sender: TObject);
    procedure mnuArtikeltypesClick(Sender: TObject);
    procedure mnuBetaalwijzesClick(Sender: TObject);
    procedure mnuBeursClick(Sender: TObject);
    procedure mnuBeursKassaClick(Sender: TObject);
    procedure mnuInloggenClick(Sender: TObject);
    procedure mnuItemTransactiesClick(Sender: TObject);
    procedure mnuKassaBedragClick(Sender: TObject);
    procedure mnuKassaImporterenClick(Sender: TObject);
    procedure mnuOpenHelpClick(Sender: TObject);
    procedure mnuOverzichtBeursClick(Sender: TObject);
    procedure mnuOverzichtKassasClick(Sender: TObject);
    procedure mnuOverzichtTotaalExportClick(Sender: TObject);
    procedure mnuOverzichtVerkoperPerKassaClick(Sender: TObject);
    procedure mnuOverzichtVerkoperClick(Sender: TObject);
    procedure mnuOverzichtTransactiesPerInbrengerClick(Sender: TObject);
    procedure mnuVerkopersBeherenClick(Sender: TObject);
    procedure mnuVerkopersKoppelenClick(Sender: TObject);

  private
    { private declarations }

    FShowKassaBedragFormModal:boolean;
    function checkAuthorizedForScreen(AlleenVoorAdmin:boolean): boolean;


  public
    { public declarations }

    procedure EnableOpenDatabase(kan:boolean);
    procedure OpenDatabase();

    procedure EnableOpenInloggen(kan:boolean);
    procedure OpenInloggen;

    procedure EnableOpenBeurs(kan:boolean);
    procedure OpenBeurs();

    procedure EnableOpenVerkopersBeheren(kan:boolean);
    procedure OpenVerkopersBeheren;

    procedure EnableOpenVerkopersKoppelen(kan:boolean);
    procedure OpenVerkopersKoppelen;

    procedure EnableOpenBeursKassa(kan:boolean);
    procedure OpenBeursKassa();

    procedure OpenAccountsBeheren;
    procedure EnableOpenAccountsBeheren(kan:boolean);

    procedure EnableOpenKassaOpenSluit(kan:boolean);
    procedure OpenKassaOpenSluit(ShowInModal:boolean);

    procedure EnableOpenTransacties(kan:boolean);
    procedure OpenTransacties();

    procedure EnableOpenInstellingenAlgemeen(kan:boolean);
    procedure OpenInstellingenAlgemeen();

    procedure EnableOpenArtikeltypes(kan:boolean);
    procedure OpenArtikeltypes;

    procedure EnableOpenBetaalwijzes(kan:boolean);
    procedure OpenBetaalwijzes;

    procedure EnableOpenInstellingenBeheer(kan:boolean);
    procedure OpenInstellingenBeheer;

    procedure EnableOpenKassaImporteren(kan:boolean);
    procedure OpenKassaImporteren;

    procedure EnableOpenOverzichtPerKassa(kan:boolean);
    procedure OpenOverzichtPerKassa;

    procedure EnableOpenOverzichtBeurs(kan:boolean);
    procedure OpenOverzichtBeurs;

    procedure EnableOpenOverzichtOpbrengstPerInbrenger(kan:boolean);
    procedure OpenOverzichtOpbrengstPerInbrenger;

    procedure EnableOpenOverzichtOpbrengstPerInbrengerPerKassa(kan:boolean);
    procedure OpenOverzichtOpbrengstPerInbrengerPerKassa;

    procedure EnableOpenOverzichtTransactiesPerInbrenger(kan:boolean);
    procedure OpenOverzichtTransactiesPerInbrenger;

    procedure EnableOpenOverzichtTotaalExport(kan:boolean);
    procedure OpenOverzichtTotaalExport;

    procedure EnableOpenGrafiek01(kan:boolean);
    procedure OpenGrafiek01;

    function checkForBeurs(AlleenVoorAdmin:boolean): boolean;
    function checkForKassa(AlleenVoorAdmin:boolean): boolean;

end;


var
  dmWobbel: TdmWobbel;


implementation

{$R *.lfm}

{ TdmWobbel }

uses
  forms,
  m_tools,
  formdatabase, formhelp, formabout, forminstellingen, forminstellingenbeheer,
  formbeursoverzicht, formbeurskassaoverzicht,
  formaccounts, formbetaalwijze, formartikeltype, forminloggen,
  formverkopersbeheren, formverkoperskoppelen,
  formtransacties, formkassaopensluit,
  formimportkassa,
  formoverzichtkassas, formoverzichtverkopers, formoverzichtverkoperperkassa,
  formoverzichtbeurs, formoverzichttransactiesperverkop, formoverzichttotaalexport,
  formgrafiek_transactietijd;

procedure TdmWobbel.DataModuleCreate(Sender: TObject);
begin
  FShowKassaBedragFormModal:=false;
end;

procedure TdmWobbel.mnuAboutClick(Sender: TObject);
var
  frm: TfrmAbout;
begin
  frm:=TfrmAbout(Application.FindComponent('frmAbout'));


  if (frm = nil) then
  begin
    frm:=TfrmAbout.Create(Self.Owner);
  end;
  m_tools.getPosition(frm);
  frm.Show;
end;

procedure TdmWobbel.mnuGrafiekTransactieTijdClick(Sender: TObject);
var
  frm: TfrmTransactiesTegenTijd;
begin
  if (not self.checkForBeurs(true)) then
  begin
    exit;
  end;

  frm:=TfrmTransactiesTegenTijd(Application.FindComponent('frmTransactiesTegenTijd'));
  if (frm = nil) then
  begin
    frm:=TfrmTransactiesTegenTijd.Create(Self.Owner);
  end;
  m_tools.getPosition(frm);
  frm.Show;
end;

procedure TdmWobbel.mnuLoginAccountsClick(Sender: TObject);
var
  frm: TfrmAccounts;
begin
  if (not self.checkForBeurs(true)) then
  begin
    exit;
  end;

  frm:=TfrmAccounts(Application.FindComponent('frmAccounts'));
  if (frm = nil) then
  begin
    frm:=TfrmAccounts.Create(Self.Owner);
  end;
  m_tools.getPosition(frm);
  frm.Show;
end;

function TdmWobbel.checkAuthorizedForScreen(AlleenVoorAdmin:boolean): boolean;
var
  isOk: boolean;
begin
  isOk:=true;
  if (AlleenVoorAdmin and (not (AppSettings.Vrijwilliger.VrijwilligerIsAdmin or AppSettings.Vrijwilliger.IsSuperAdmin))) then
  begin
    MessageOk('Alleen een beheerder heeft rechten voor dit scherm');
    isOk:=false;
  end;

  if (isOk and (not DatabaseFileIsOk(dmWobbel.connWobbelMdb.Database))) then
  begin
    MessageOk('Er is nog geen database bestand geselecteerd. Svp corrigeren');
    isOk:=false;
    OpenInloggen();
  end;

  Result:=isOk;
end;

function TdmWobbel.checkForBeurs(AlleenVoorAdmin:boolean): boolean;
var
  isOk: boolean;
begin
  isOk:=self.checkAuthorizedForScreen(AlleenVoorAdmin);
  if (isOk and (not AppSettings.Beurs.BeursIsOk)) then
  begin
    MessageOk('Er is nog geen beurs geselecteerd. Svp corrigeren');
    isOk:=false;
    //OpenBeurs();
  end;

  Result:=isOk;
end;

function TdmWobbel.checkForKassa(AlleenVoorAdmin:boolean): boolean;
var
  isOk: boolean;
begin
  isOk:=self.checkForBeurs(AlleenVoorAdmin);
  if (isOk and (not AppSettings.Kassa.KassaIsGekozen)) then
  begin
    MessageOk('Er is nog geen kassa geselecteerd. Svp corrigeren');
    isOk:=false;
    self.OpenBeursKassa();
  end;

  Result:=isOk;
end;

procedure TdmWobbel.EnableOpenDatabase(kan:boolean);
begin
  self.mnMain.Items.Items[0].Items[0].Enabled:=kan;
end;
procedure TdmWobbel.OpenDatabase;
begin
  self.mnMain.Items.Items[0].Items[0].Click;
end;

procedure TdmWobbel.EnableOpenInloggen(kan:boolean);
begin
  self.mnMain.Items.Items[0].Items[1].Enabled:=kan;
end;
procedure TdmWobbel.OpenInloggen;
begin
  self.mnMain.Items.Items[0].Items[1].Click;
end;

procedure TdmWobbel.EnableOpenBeurs(kan:boolean);
begin
  self.mnMain.Items.Items[0].Items[2].Enabled:=kan;
end;
procedure TdmWobbel.OpenBeurs;
begin
  self.mnMain.Items.Items[0].Items[2].Click;
end;

procedure TdmWobbel.EnableOpenVerkopersBeheren(kan:boolean);
begin
  self.mnMain.Items.Items[0].Items[3].Enabled:=kan;
end;
procedure TdmWobbel.OpenVerkopersBeheren;
begin
  self.mnMain.Items.Items[0].Items[3].Click;
end;

procedure TdmWobbel.EnableOpenBeursKassa(kan:boolean);
begin
  self.mnMain.Items.Items[0].Items[4].Enabled:=kan;
end;
procedure TdmWobbel.OpenBeursKassa;
begin
  self.mnMain.Items.Items[0].Items[4].Click;
end;

procedure TdmWobbel.EnableOpenAccountsBeheren(kan:boolean);
begin
  self.mnMain.Items.Items[0].Items[5].Enabled:=kan;
end;
procedure TdmWobbel.OpenAccountsBeheren;
begin
  self.mnMain.Items.Items[0].Items[5].Click;
end;

procedure TdmWobbel.EnableOpenVerkopersKoppelen(kan:boolean);
begin
//  self.mnMain.Items.Items[2].Items[1].Items[1].Enabled:=kan;
end;
procedure TdmWobbel.OpenVerkopersKoppelen;
begin
//  self.mnMain.Items.Items[2].Items[1].Items[1].Click;
end;

procedure TdmWobbel.EnableOpenKassaOpenSluit(kan:boolean);
begin
  self.mnMain.Items.Items[0].Items[6].Enabled:=kan;
end;
procedure TdmWobbel.OpenKassaOpenSluit(ShowInModal:boolean);
begin
  FShowKassaBedragFormModal:=ShowInModal;
  self.mnMain.Items.Items[0].Items[6].Click;
end;

procedure TdmWobbel.EnableOpenTransacties(kan:boolean);
begin
  self.mnMain.Items.Items[0].Items[7].Enabled:=kan;
end;
procedure TdmWobbel.OpenTransacties();
begin
  self.mnMain.Items.Items[0].Items[7].Click;
end;




procedure TdmWobbel.EnableOpenInstellingenAlgemeen(kan:boolean);
begin
  self.mnMain.Items.Items[1].Items[0].Enabled:=kan;
end;
procedure TdmWobbel.OpenInstellingenAlgemeen;
begin
  self.mnMain.Items.Items[1].Items[0].Click;
end;



procedure TdmWobbel.EnableOpenArtikeltypes(kan:boolean);
begin
  self.mnMain.Items.Items[2].Items[0].Enabled:=kan;
end;
procedure TdmWobbel.OpenArtikeltypes;
begin
  self.mnMain.Items.Items[2].Items[0].Click;
end;

procedure TdmWobbel.EnableOpenBetaalwijzes(kan:boolean);
begin
  self.mnMain.Items.Items[2].Items[1].Enabled:=kan;
end;
procedure TdmWobbel.OpenBetaalwijzes;
begin
  self.mnMain.Items.Items[2].Items[1].Click;
end;

procedure TdmWobbel.EnableOpenInstellingenBeheer(kan:boolean);
begin
  self.mnMain.Items.Items[2].Items[2].Enabled:=kan;
end;
procedure TdmWobbel.OpenInstellingenBeheer;
begin
  self.mnMain.Items.Items[2].Items[2].Click;
end;


procedure TdmWobbel.EnableOpenKassaImporteren(kan:boolean);
begin
  self.mnMain.Items.Items[3].Items[0].Enabled:=kan;
end;
procedure TdmWobbel.OpenKassaImporteren;
begin
  self.mnMain.Items.Items[3].Items[0].Click;
end;

procedure TdmWobbel.EnableOpenOverzichtPerKassa(kan:boolean);
begin
  self.mnMain.Items.Items[3].Items[1].Enabled:=kan;
end;
procedure TdmWobbel.OpenOverzichtPerKassa;
begin
  self.mnMain.Items.Items[3].Items[1].Click;
end;

procedure TdmWobbel.EnableOpenOverzichtBeurs(kan:boolean);
begin
  self.mnMain.Items.Items[3].Items[2].Enabled:=kan;
end;
procedure TdmWobbel.OpenOverzichtBeurs;
begin
  self.mnMain.Items.Items[3].Items[2].Click;
end;

procedure TdmWobbel.EnableOpenOverzichtOpbrengstPerInbrenger(kan:boolean);
begin
  self.mnMain.Items.Items[3].Items[3].Enabled:=kan;
end;
procedure TdmWobbel.OpenOverzichtOpbrengstPerInbrenger;
begin
  self.mnMain.Items.Items[3].Items[3].Click;
end;

procedure TdmWobbel.EnableOpenOverzichtOpbrengstPerInbrengerPerKassa(kan:boolean);
begin
  self.mnMain.Items.Items[3].Items[4].Enabled:=kan;
end;
procedure TdmWobbel.OpenOverzichtOpbrengstPerInbrengerPerKassa;
begin
  self.mnMain.Items.Items[3].Items[4].Click;
end;

procedure TdmWobbel.EnableOpenOverzichtTransactiesPerInbrenger(kan:boolean);
begin
  self.mnMain.Items.Items[3].Items[5].Enabled:=kan;
end;
procedure TdmWobbel.OpenOverzichtTransactiesPerInbrenger;
begin
  self.mnMain.Items.Items[3].Items[5].Click;
end;

procedure TdmWobbel.EnableOpenOverzichtTotaalExport(kan:boolean);
begin
  self.mnMain.Items.Items[3].Items[6].Enabled:=kan;
end;
procedure TdmWobbel.OpenOverzichtTotaalExport;
begin
  self.mnMain.Items.Items[3].Items[6].Click;
end;


procedure TdmWobbel.EnableOpenGrafiek01(kan:boolean);
begin
  self.mnMain.Items.Items[3].Items[7].Visible:=kan;
  self.mnMain.Items.Items[3].Items[7].Enabled:=kan;
end;
procedure TdmWobbel.OpenGrafiek01;
begin
  self.mnMain.Items.Items[3].Items[7].Click;
end;



procedure TdmWobbel.mnuImporteerKassaClick(Sender: TObject);
var
  frm: TfrmImportKassa;
begin
  if (not checkForBeurs(true)) then
  begin
    exit;
  end;

  frm:=TfrmImportKassa(Application.FindComponent('frmImportKassa'));
  if (frm = nil) then
  begin
    frm:=TfrmImportKassa.Create(Self.Owner);
  end;
  m_tools.getPosition(frm);
  frm.Show;
end;

procedure TdmWobbel.mnuInstellingenBeheerClick(Sender: TObject);
var
  frm: TfrmInstellingenBeheer;
begin
  if (not checkAuthorizedForScreen(true)) then
  begin
    exit;
  end;

  frm:=TfrmInstellingenBeheer(Application.FindComponent('frmInstellingenBeheer'));

  if (frm = nil) then
  begin
    frm:=TfrmInstellingenBeheer.Create(Self.Owner);
  end;
  m_tools.getPosition(frm);
  frm.Show;
end;


procedure TdmWobbel.mnuInstellingenClick(Sender: TObject);
var
  frm: TfrmInstellingen;
begin
  if (not checkAuthorizedForScreen(false)) then
  begin
    exit;
  end;

  frm:=TfrmInstellingen(Application.FindComponent('frmInstellingen'));

  if (frm = nil) then
  begin
    frm:=TfrmInstellingen.Create(Self.Owner);
  end;
  m_tools.getPosition(frm);
  frm.Show;
end;

procedure TdmWobbel.mnuArtikeltypesClick(Sender: TObject);
var
  frm: TfrmArtikeltype;
begin
  if (not checkAuthorizedForScreen(true)) then
  begin
    exit;
  end;

  frm:=TfrmArtikeltype(Application.FindComponent('frmArtikeltype'));

  if (frm = nil) then
  begin
    frm:=TfrmArtikeltype.Create(Self.Owner);
  end;
  m_tools.getPosition(frm);
  frm.Show;
end;

procedure TdmWobbel.mnuBetaalwijzesClick(Sender: TObject);
var
  frm: TfrmBetaalwijze;
begin
  if (not checkAuthorizedForScreen(true)) then
  begin
    exit;
  end;

  frm:=TfrmBetaalwijze(Application.FindComponent('frmBetaalwijze'));

  if (frm = nil) then
  begin
    frm:=TfrmBetaalwijze.Create(Self.Owner);
  end;
  m_tools.getPosition(frm);
  frm.Show;
end;

procedure TdmWobbel.mnuBeursClick(Sender: TObject);
var
  frm: TfrmBeursoverzicht;
begin
  if (not checkAuthorizedForScreen(true)) then
  begin
    exit;
  end;

  frm:=TfrmBeursoverzicht(Application.FindComponent('frmBeursoverzicht'));
  if (frm = nil) then
  begin
    frm:=TfrmBeursoverzicht.Create(Self.Owner);
  end;
  m_tools.getPosition(frm);
  frm.Show;
end;

procedure TdmWobbel.mnuBeursKassaClick(Sender: TObject);
var
  frm: TfrmBeursKassaoverzicht;
begin
  if (not checkForBeurs(true)) then
  begin
    exit;
  end;

  frm:=TfrmBeursKassaoverzicht(Application.FindComponent('frmKassaoverzicht'));
  if (frm = nil) then
  begin
    frm:=TfrmBeursKassaoverzicht.Create(Self.Owner);
  end;
  m_tools.getPosition(frm);
  frm.Show;
end;

procedure TdmWobbel.mnuInloggenClick(Sender: TObject);
var
  frm: TfrmInloggen;
begin
  frm:=TfrmInloggen(Application.FindComponent('frmInloggen'));
  if (frm = nil) then
  begin
    frm:=TfrmInloggen.Create(Self.Owner);
  end;
  m_tools.getPosition(frm);
  frm.Show;
end;

procedure TdmWobbel.mnuItemTransactiesClick(Sender: TObject);
var
  frm: TfrmTransacties;
begin
  if (not checkForKassa(false)) then
  begin
    exit;
  end;

  frm:=TfrmTransacties(Application.FindComponent('frmTransacties'));
  if (frm = nil) then
  begin
    frm:=TfrmTransacties.Create(Self.Owner);
  end;
  m_tools.getPosition(frm);
  frm.Show;
end;

procedure TdmWobbel.mnuKassaBedragClick(Sender: TObject);
var
  frm: TfrmKassaOpenSluit;
begin
  if (not checkForKassa(false)) then
  begin
    exit;
  end;

  frm:=TfrmKassaOpenSluit(Application.FindComponent('frmKassaOpenSluit'));
  if (frm = nil) then
  begin
    frm:=TfrmKassaOpenSluit.Create(Self.Owner);
  end;
  m_tools.getPosition(frm);
  if (FShowKassaBedragFormModal) then
  begin
    frm.FormIsModal:=true;
    frm.ShowModal;
  end
  else
  begin
    frm.FormIsModal:=false;
    frm.Show;
  end;
end;

procedure TdmWobbel.mnuKassaImporterenClick(Sender: TObject);
var
  frm: TfrmImportKassa;
begin
  if (not checkForBeurs(true)) then
  begin
    exit;
  end;

  frm:=TfrmImportKassa(Application.FindComponent('frmImportKassa'));
  if (frm = nil) then
  begin
    frm:=TfrmImportKassa.Create(Self.Owner);
  end;
  m_tools.getPosition(frm);
  frm.Show;
end;

procedure TdmWobbel.mnuOpenHelpClick(Sender: TObject);
var
  frm: TfrmHelp;
begin
  frm:=TfrmHelp(Application.FindComponent('frmHelp'));


  if (frm = nil) then
  begin
    frm:=TfrmHelp.Create(Self.Owner);
  end;
  m_tools.getPosition(frm);
  frm.Show;
end;

procedure TdmWobbel.mnuOverzichtBeursClick(Sender: TObject);
var
  frm: TfrmOverzichtBeurs;
begin
  if (not checkAuthorizedForScreen(true)) then
  begin
    exit;
  end;

  if (not checkForBeurs(true)) then
  begin
    exit;
  end;

  frm:=TfrmOverzichtBeurs(Application.FindComponent('frmOverzichtBeurs'));
  if (frm = nil) then
  begin
    frm:=TfrmOverzichtBeurs.Create(Self.Owner);
  end;
  m_tools.getPosition(frm);
  frm.Show;
end;


procedure TdmWobbel.mnuOverzichtKassasClick(Sender: TObject);
var
  frm: TfrmOverzichtKassas;
begin
  if (not checkAuthorizedForScreen(true)) then
  begin
    exit;
  end;

  if (not checkForBeurs(true)) then
  begin
    exit;
  end;

  frm:=TfrmOverzichtKassas(Application.FindComponent('frmOverzichtKassas'));
  if (frm = nil) then
  begin
    frm:=TfrmOverzichtKassas.Create(Self.Owner);
  end;
  m_tools.getPosition(frm);
  frm.Show;
end;

procedure TdmWobbel.mnuOverzichtTotaalExportClick(Sender: TObject);
var
  frm: TfrmOverzichtTotaalExport;
begin
  if (not checkAuthorizedForScreen(true)) then
  begin
    exit;
  end;

  if (not checkForBeurs(true)) then
  begin
    exit;
  end;

  frm:=TfrmOverzichtTotaalExport(Application.FindComponent('frmOverzichtTotaalExport'));
  if (frm = nil) then
  begin
    frm:=TfrmOverzichtTotaalExport.Create(Self.Owner);
  end;
  m_tools.getPosition(frm);
  frm.Show;
end;

procedure TdmWobbel.mnuOverzichtVerkoperPerKassaClick(Sender: TObject);
var
  frm: TfrmOverzichtVerkoperPerKassa;
begin
  if (not checkAuthorizedForScreen(true)) then
  begin
    exit;
  end;

  if (not checkForBeurs(true)) then
  begin
    exit;
  end;

  frm:=TfrmOverzichtVerkoperPerKassa(Application.FindComponent('frmOverzichtVerkoperPerKassa'));
  if (frm = nil) then
  begin
    frm:=TfrmOverzichtVerkoperPerKassa.Create(Self.Owner);
  end;
  m_tools.getPosition(frm);
  frm.Show;
end;

procedure TdmWobbel.mnuOverzichtVerkoperClick(Sender: TObject);
var
  frm: TfrmOverzichtVerkopers;
begin
  if (not checkAuthorizedForScreen(true)) then
  begin
    exit;
  end;

  if (not checkForBeurs(true)) then
  begin
    exit;
  end;

  frm:=TfrmOverzichtVerkopers(Application.FindComponent('frmOverzichtVerkopers'));
  if (frm = nil) then
  begin
    frm:=TfrmOverzichtVerkopers.Create(Self.Owner);
  end;
  m_tools.getPosition(frm);
  frm.Show;
end;

procedure TdmWobbel.mnuOverzichtTransactiesPerInbrengerClick(Sender: TObject);
var
  frm: TfrmOverzichtTransactiesPerVerkoper;
begin
  if (not checkAuthorizedForScreen(true)) then
  begin
    exit;
  end;

  if (not checkForBeurs(true)) then
  begin
    exit;
  end;

  frm:=TfrmOverzichtTransactiesPerVerkoper(Application.FindComponent('frmOverzichtTransactiesPerVerkoper'));
  if (frm = nil) then
  begin
    frm:=TfrmOverzichtTransactiesPerVerkoper.Create(Self.Owner);
  end;
  m_tools.getPosition(frm);
  frm.Show;
end;

procedure TdmWobbel.mnuVerkopersBeherenClick(Sender: TObject);
var
  frm: TfrmVerkopersbeheren;
begin
  if (not checkForBeurs(true)) then
  begin
    exit;
  end;

  frm:=TfrmVerkopersbeheren(Application.FindComponent('frmVerkopersbeheren'));
  if (frm = nil) then
  begin
    frm:=TfrmVerkopersbeheren.Create(Self.Owner);
  end;
  m_tools.getPosition(frm);
  frm.Show;
end;


procedure TdmWobbel.mnuVerkopersKoppelenClick(Sender: TObject);
var
  frm: TfrmVerkoperskoppelen;
begin
  if (not checkForBeurs(true)) then
  begin
    exit;
  end;

  frm:=TfrmVerkoperskoppelen(Application.FindComponent('frmVerkoperskoppelen'));

  if (frm = nil) then
  begin
    frm:=TfrmVerkoperskoppelen.Create(Self.Owner);
  end;
  m_tools.getPosition(frm);
  frm.Show;
end;

procedure TdmWobbel.mnuDatabaseClick(Sender: TObject);
var
  frm: TfrmDatabase;
begin
  if (not checkAuthorizedForScreen(true)) then
  begin
    exit;
  end;

  frm:=TfrmDatabase(Application.FindComponent('frmDatabase'));
  if (frm = nil) then
  begin
    frm:=TfrmDatabase.Create(Self.Owner);
  end;
  m_tools.getPosition(frm);
  frm.Show;
end;


end.

