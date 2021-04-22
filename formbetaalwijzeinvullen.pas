unit formbetaalwijzeinvullen;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ButtonPanel;

type

  { TfrmBetaalwijzeInvullen }

  TfrmBetaalwijzeInvullen = class(TForm)
    btnpnlDialoog: TButtonPanel;
    lblStatus: TLabel;
    lblKiesBetaalwijze: TLabel;
    pnlBetaalwijze: TPanel;
    rgBetaalwijzes: TRadioGroup;
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
    procedure RadioButton1Change(Sender: TObject);
  private
    { private declarations }
    FLastSelectedValue: integer;
    FLastSelectedText: string;
    procedure VulBetaalwijzes();
  public
    { public declarations }
    property LastSelectedValue: integer read FLastSelectedValue;
    property LastSelectedText: string read FLastSelectedText;

  end;

var
  frmBetaalwijzeInvullen: TfrmBetaalwijzeInvullen;

implementation

uses
  m_querystuff, m_tools, m_wobbeldata, m_error,
  ZDataset;

{ TfrmBetaalwijzeInvullen }

{$R *.lfm}


procedure TfrmBetaalwijzeInvullen.FormActivate(Sender: TObject);
begin
end;

procedure TfrmBetaalwijzeInvullen.FormCloseQuery(Sender: TObject;
  var CanClose: boolean);
begin
  CanClose:=true;
  if (rgBetaalwijzes.ItemIndex < 0) then
  begin
    CanClose:=false;
  end;
end;

procedure TfrmBetaalwijzeInvullen.FormCreate(Sender: TObject);
begin
  VulBetaalwijzes();
end;

procedure TfrmBetaalwijzeInvullen.FormShow(Sender: TObject);
begin
  FLastSelectedValue:=-1;
  FLastSelectedText:='';
  rgBetaalwijzes.ItemIndex := -1;
  //lblStatus.Caption:=IntToStr(rgBetaalwijzes.ItemIndex);
end;

procedure TfrmBetaalwijzeInvullen.OKButtonClick(Sender: TObject);
var
  ix:integer;
begin
  ix := rgBetaalwijzes.ItemIndex;
  if (ix >= 0) then
  begin
    FLastSelectedValue:=Integer(rgBetaalwijzes.Items.Objects[ix]);
    FLastSelectedText:=rgBetaalwijzes.Items[ix];
    //MessageOk(IntToStr(FLastSelectedValue));
  end
  else
  begin
    MessageError('Kies een betaalwijze');
  end;
end;

procedure TfrmBetaalwijzeInvullen.RadioButton1Change(Sender: TObject);
begin

end;

procedure TfrmBetaalwijzeInvullen.VulBetaalwijzes();
var
  q : TZQuery;
begin
  try
    try
      q := m_querystuff.GetSQLite3QueryMdb;
      q.SQL.Clear;
      q.SQL.Text:='select b.betaalwijze_id, b.omschrijving ' +
         ' from betaalwijze as b ' +
         ' order by b.omschrijving';
      q.Open;
      while not q.Eof do
      begin
        rgBetaalwijzes.Items.AddObject(q.FieldByName('omschrijving').AsString, TObject(q.FieldByName('betaalwijze_id').AsInteger));
        q.Next;
      end;
      q.Close;
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

