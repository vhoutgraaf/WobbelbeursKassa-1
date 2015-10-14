unit formbetaalwijze;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Menus, StdCtrls, DBGrids, DbCtrls, c_appsettings, db;

type

  { TfrmBetaalwijze }

  TfrmBetaalwijze = class(TForm)
    grdBetaalwijze: TDBGrid;

    lblBetaalwijzetitel: TLabel;
    navBetaalwijzeGrid: TDBNavigator;
    pnlBetaalwijze: TPanel;

    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);

  private
    { private declarations }

    function VeranderingenOpgeslagenBijVerlaten():boolean;

  public
    { public declarations }
  end;

var
  frmBetaalwijze: TfrmBetaalwijze;

implementation

uses
  m_wobbeldata, m_tools, m_constant, crt;

{$R *.lfm}

{ TfrmBetaalwijze }

procedure TfrmBetaalwijze.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  //
end;

// http://delphi.about.com/od/formsdialogs/a/delphiformlife.htm
// ... OnCloseQuery -> OnClose -> OnDeactivate -> OnHide -> OnDestroy
procedure TfrmBetaalwijze.FormCloseQuery(Sender: TObject; var CanClose: boolean
  );
begin
  CanClose:=true;
  if (VeranderingenOpgeslagenBijVerlaten()) then
  begin
    CanClose:=false;
  end;
end;

procedure TfrmBetaalwijze.FormDeactivate(Sender: TObject);
begin
  VeranderingenOpgeslagenBijVerlaten;

  // om te voorkomen dat de knoppen van het onderliggende scherm doorschijnen
  Delay(m_constant.c_DeactiveDelay_msec);
  Application.ProcessMessages;
end;


procedure TfrmBetaalwijze.FormActivate(Sender: TObject);
begin
  m_tools.CloseOtherScreens(self);
  dmWobbel.tblBetaalwijze.Active:=true;

  self.Color:=AppSettings.GlobalBackgroundColor;
  self.Font.Size:=m_tools.GetIntegerFromIniFile('FONTS','GlobalFontsize',c_defaultFontsize);

end;

procedure TfrmBetaalwijze.FormCreate(Sender: TObject);
begin
//
end;

function TfrmBetaalwijze.VeranderingenOpgeslagenBijVerlaten():boolean;
begin
  Result:=false;
  if (grdBetaalwijze <> nil) and (AppSettings.Vrijwilliger.VrijwilligerIsAdmin) then
  begin
    if ((grdBetaalwijze.DataSource.State = dsEdit)
         or (grdBetaalwijze.DataSource.State = dsInsert)) then
    begin
      if MessageDlg('Wobbel', 'Wijzigingen in de Betaalwijze-tabel zijn nog niet opgeslagen. Alsnog opslaan?', mtConfirmation,
      [mbYes, mbNo],0) = mrYes
      then
      begin
        grdBetaalwijze.DataSource.DataSet.Post;
        Result:=true;
      end
      else
      begin
        grdBetaalwijze.DataSource.DataSet.Cancel;
      end;
    end;
  end;
end;


end.

