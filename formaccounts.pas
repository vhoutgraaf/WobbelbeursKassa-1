unit formaccounts;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Menus, c_appsettings, c_gridvrijwilliger;

type

  { TfrmAccounts }

  TfrmAccounts = class(TForm)

    gridpanelAccounts: TGridVrijwilliger;
    pnlAccounts: TPanel;

    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure ActivateAccountsgrid;
    procedure FormDeactivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
    { private declarations }

  function VeranderingenOpgeslagenBijVerlaten:boolean;

  public
    { public declarations }
  end;

var
  frmAccounts: TfrmAccounts;

implementation

uses
  c_wobbelgridpanel, m_tools, m_constant, crt;

{$R *.lfm}

{ TfrmAccounts }


procedure TfrmAccounts.FormCreate(Sender: TObject);
begin
//  ActivateAccountsgrid();
end;

procedure TfrmAccounts.FormDestroy(Sender: TObject);
begin
  if (gridpanelAccounts <> nil) then
  begin
    gridpanelAccounts.Free;
  end;
end;


procedure TfrmAccounts.FormActivate(Sender: TObject);
begin
  m_tools.CloseOtherScreens(self);

  ActivateAccountsgrid();

  self.Color:=AppSettings.GlobalBackgroundColor;
  self.Font.Size:=m_tools.GetIntegerFromIniFile('FONTS','GlobalFontsize',c_defaultFontsize);
end;


procedure TfrmAccounts.ActivateAccountsgrid();
begin
  if (AppSettings.Vrijwilliger.VrijwilligerIsAdmin) then
  begin
    if (gridpanelAccounts = nil) then
    begin
      gridpanelAccounts:=TGridVrijwilliger.CreateMe(Self, pnlAccounts,
          pnlAccounts.Top,
          2,
          pnlAccounts.Height-2,
          AppSettings.Beurs.BeursId, AppSettings.Beurs.BeursOmschrijving);
    end
    else
    begin
      gridpanelAccounts.Visible:=true;
      gridpanelAccounts.BeursId:=AppSettings.Beurs.BeursId; //nieuw
      gridpanelAccounts.BeursOmschrijving:=AppSettings.Beurs.BeursOmschrijving;//nieuw
      gridpanelAccounts.SetGridProps; //nieuw
      gridpanelAccounts.FillGrid;
    end;
    gridpanelAccounts.SetGridStatus([WSENABLEDEDITABLE]);
  end
  else
  begin
    if (gridpanelAccounts <> nil) then
    begin
      gridpanelAccounts.Visible:=false;
    end;
  end;
end;


function TfrmAccounts.VeranderingenOpgeslagenBijVerlaten:boolean;
begin
  Result:=false;
  if (gridpanelAccounts <> nil) and (AppSettings.Vrijwilliger.VrijwilligerIsAdmin) then
  begin
    if (gridpanelAccounts.AnyRowIsDirty) then
    begin
      if MessageDlg('Wobbel', 'Wijzigingen in de Accounts-tabel zijn nog niet opgeslagen. Alsnog opslaan?', mtConfirmation,
      [mbYes, mbNo],0) = mrYes
      then
      begin
        gridpanelAccounts.PostData;
        Result:=true;
      end
      else
      begin
        gridpanelAccounts.FillGrid;
      end;
    end;
  end;
end;

procedure TfrmAccounts.FormDeactivate(Sender: TObject);
begin
  VeranderingenOpgeslagenBijVerlaten;

  // om te voorkomen dat de knoppen van het onderliggende scherm doorschijnen
  Delay(m_constant.c_DeactiveDelay_msec);
  Application.ProcessMessages;
end;

procedure TfrmAccounts.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
//
end;

// http://delphi.about.com/od/formsdialogs/a/delphiformlife.htm
// ... OnCloseQuery -> OnClose -> OnDeactivate -> OnHide -> OnDestroy
procedure TfrmAccounts.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose:=true;
  if (VeranderingenOpgeslagenBijVerlaten()) then
  begin
    CanClose:=false;
  end;
end;


end.

