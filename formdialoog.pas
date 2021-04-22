unit formdialoog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, ButtonPanel;

type

  { TfrmDialoog }

  TfrmDialoog = class(TForm)
    btnpnlDialoog: TButtonPanel;
    lblDialoog1: TLabel;
    lblDialoog2: TLabel;
    lblDialoog3: TLabel;
    lblDialoog4: TLabel;
    lblDialoog5: TLabel;
    lblDialoog6: TLabel;
    lblDialoog7: TLabel;
    lblDialoog8: TLabel;
    pnlDialoog: TPanel;
    procedure CancelButtonClick(Sender: TObject);
    procedure CloseButtonClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
    procedure pnlDialoogResize(Sender: TObject);
  private
    { private declarations }
    FKlikwaarde:integer;
    procedure PositionLabelteksten;
  public
    procedure SetLabeltekst(tekst1, tekst2, tekst3, tekst4, tekst5, tekst6, tekst7, tekst8: string);
    procedure SetLabeltekst(tekst1, tekst2, tekst3, tekst4, tekst5, tekst6, tekst7: string);
    procedure SetLabeltekst(tekst1, tekst2, tekst3, tekst4, tekst5, tekst6: string);
    procedure SetLabeltekst(tekst1, tekst2, tekst3, tekst4, tekst5: string);
    procedure SetLabeltekst(tekst1, tekst2, tekst3, tekst4:string);
    procedure SetLabeltekst(tekst1, tekst2, tekst3:string);
    procedure SetLabeltekst(tekst1, tekst2:string);
    procedure SetLabeltekst(tekst1:string);

    property Klikwaarde: integer read FKlikwaarde write FKlikwaarde;

    procedure OkButtonVisibility(IsButtonVisible:boolean);
    procedure CancelButtonVisibility(IsButtonVisible:boolean);
    { public declarations }
  end; 

var
  frmDialoog: TfrmDialoog;

implementation

uses
  m_tools, m_constant, c_appsettings, crt;

{$R *.lfm}

{ TfrmDialoog }

procedure TfrmDialoog.PositionLabelteksten;
begin
  lblDialoog1.Left:=round((pnlDialoog.Width-lblDialoog1.Canvas.TextWidth(lblDialoog1.Caption))/2);
  lblDialoog2.Left:=round((pnlDialoog.Width-lblDialoog1.Canvas.TextWidth(lblDialoog2.Caption))/2);
  lblDialoog3.Left:=round((pnlDialoog.Width-lblDialoog1.Canvas.TextWidth(lblDialoog3.Caption))/2);
  lblDialoog4.Left:=round((pnlDialoog.Width-lblDialoog1.Canvas.TextWidth(lblDialoog4.Caption))/2);
  lblDialoog5.Left:=round((pnlDialoog.Width-lblDialoog1.Canvas.TextWidth(lblDialoog5.Caption))/2);
  lblDialoog6.Left:=round((pnlDialoog.Width-lblDialoog1.Canvas.TextWidth(lblDialoog6.Caption))/2);
  lblDialoog7.Left:=round((pnlDialoog.Width-lblDialoog1.Canvas.TextWidth(lblDialoog7.Caption))/2);
  lblDialoog8.Left:=round((pnlDialoog.Width-lblDialoog1.Canvas.TextWidth(lblDialoog8.Caption))/2);
end;

procedure TfrmDialoog.SetLabeltekst(tekst1, tekst2, tekst3, tekst4, tekst5, tekst6, tekst7, tekst8: string);
begin
  lblDialoog1.Caption:=tekst1;
  lblDialoog2.Caption:=tekst2;
  lblDialoog3.Caption:=tekst3;
  lblDialoog4.Caption:=tekst4;
  lblDialoog5.Caption:=tekst5;
  lblDialoog6.Caption:=tekst6;
  lblDialoog7.Caption:=tekst7;
  lblDialoog8.Caption:=tekst8;

  PositionLabelteksten;
end;

procedure TfrmDialoog.SetLabeltekst(tekst1, tekst2, tekst3, tekst4, tekst5, tekst6, tekst7: string);
begin
  lblDialoog1.Caption:=tekst1;
  lblDialoog2.Caption:=tekst2;
  lblDialoog3.Caption:=tekst3;
  lblDialoog4.Caption:=tekst4;
  lblDialoog5.Caption:=tekst5;
  lblDialoog6.Caption:=tekst6;
  lblDialoog7.Caption:=tekst7;
  lblDialoog8.Caption:='';

  PositionLabelteksten;
end;

procedure TfrmDialoog.SetLabeltekst(tekst1, tekst2, tekst3, tekst4, tekst5, tekst6: string);
begin
  lblDialoog1.Caption:=tekst1;
  lblDialoog2.Caption:=tekst2;
  lblDialoog3.Caption:=tekst3;
  lblDialoog4.Caption:=tekst4;
  lblDialoog5.Caption:=tekst5;
  lblDialoog6.Caption:=tekst6;
  lblDialoog7.Caption:='';
  lblDialoog8.Caption:='';

  PositionLabelteksten;
end;

procedure TfrmDialoog.SetLabeltekst(tekst1, tekst2, tekst3, tekst4, tekst5: string);
begin
  lblDialoog1.Caption:=tekst1;
  lblDialoog2.Caption:=tekst2;
  lblDialoog3.Caption:=tekst3;
  lblDialoog4.Caption:=tekst4;
  lblDialoog5.Caption:=tekst5;
  lblDialoog6.Caption:='';
  lblDialoog7.Caption:='';
  lblDialoog8.Caption:='';

  PositionLabelteksten;
end;

procedure TfrmDialoog.SetLabeltekst(tekst1, tekst2, tekst3, tekst4: string);
begin
  lblDialoog1.Caption:=tekst1;
  lblDialoog2.Caption:=tekst2;
  lblDialoog3.Caption:=tekst3;
  lblDialoog4.Caption:=tekst4;
  lblDialoog5.Caption:='';
  lblDialoog6.Caption:='';
  lblDialoog7.Caption:='';
  lblDialoog8.Caption:='';

  PositionLabelteksten;
end;

procedure TfrmDialoog.SetLabeltekst(tekst1, tekst2, tekst3: string);
begin
  lblDialoog1.Caption:=tekst1;
  lblDialoog2.Caption:=tekst2;
  lblDialoog3.Caption:=tekst3;
  lblDialoog4.Caption:='';
  lblDialoog5.Caption:='';
  lblDialoog6.Caption:='';
  lblDialoog7.Caption:='';
  lblDialoog8.Caption:='';

  PositionLabelteksten;
end;

procedure TfrmDialoog.SetLabeltekst(tekst1, tekst2: string);
begin
  lblDialoog1.Caption:=tekst1;
  lblDialoog2.Caption:=tekst2;
  lblDialoog3.Caption:='';
  lblDialoog4.Caption:='';
  lblDialoog5.Caption:='';
  lblDialoog6.Caption:='';
  lblDialoog7.Caption:='';
  lblDialoog8.Caption:='';

  PositionLabelteksten;
end;

procedure TfrmDialoog.SetLabeltekst(tekst1: string);
begin
  lblDialoog1.Caption:=tekst1;
  lblDialoog2.Caption:='';
  lblDialoog3.Caption:='';
  lblDialoog4.Caption:='';
  lblDialoog5.Caption:='';
  lblDialoog6.Caption:='';
  lblDialoog7.Caption:='';
  lblDialoog8.Caption:='';

  PositionLabelteksten;
end;

procedure TfrmDialoog.pnlDialoogResize(Sender: TObject);
begin
  PositionLabelteksten;
end;


procedure TfrmDialoog.OKButtonClick(Sender: TObject);
begin
  FKlikwaarde:=1
end;

procedure TfrmDialoog.CancelButtonClick(Sender: TObject);
begin
  FKlikwaarde:=2
end;

procedure TfrmDialoog.CloseButtonClick(Sender: TObject);
begin
  FKlikwaarde:=3
end;

procedure TfrmDialoog.FormActivate(Sender: TObject);
var
  fsize:integer;
begin
  self.Color:=AppSettings.GlobalBackgroundColor;
  fsize:=m_tools.GetIntegerFromIniFile('FONTS','GlobalFontsize',c_defaultFontsize);
  self.Font.Size:=fsize;

  lblDialoog1.Font.Size:=fsize+1;
  lblDialoog2.Font.Size:=fsize+1;
  lblDialoog3.Font.Size:=fsize+1;
  lblDialoog4.Font.Size:=fsize+1;
  lblDialoog5.Font.Size:=fsize+1;
  lblDialoog6.Font.Size:=fsize+1;
  lblDialoog7.Font.Size:=fsize+1;
  lblDialoog8.Font.Size:=fsize+1;

  PositionLabelteksten;
end;

procedure TfrmDialoog.FormCreate(Sender: TObject);
begin
  lblDialoog1.Caption:='';
  lblDialoog2.Caption:='';
  lblDialoog3.Caption:='';
  lblDialoog4.Caption:='';
  lblDialoog5.Caption:='';
  lblDialoog6.Caption:='';
  lblDialoog7.Caption:='';
  lblDialoog8.Caption:='';

  FKlikwaarde:=0;
end;

procedure TfrmDialoog.FormDeactivate(Sender: TObject);
begin
  // om te voorkomen dat de knoppen van het onderliggende scherm doorschijnen
  Delay(m_constant.c_DeactiveDelay_msec);
  Application.ProcessMessages;
end;

procedure TfrmDialoog.OkButtonVisibility(IsButtonVisible:boolean);
begin
  self.btnpnlDialoog.OKButton.Visible:=IsButtonVisible;
end;

procedure TfrmDialoog.CancelButtonVisibility(IsButtonVisible:boolean);
begin
  self.btnpnlDialoog.CancelButton.Visible:=IsButtonVisible;
end;

end.

