unit forminfo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls;

type

  { TfrmInfo }

  TfrmInfo = class(TForm)
    mmoInfo: TMemo;
    pnlInfo: TPanel;
    procedure FormActivate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }

    procedure ClearInfo;
    procedure AppendInfo(s:string);

  end;

var
  frmInfo: TfrmInfo;

implementation

uses
   m_tools, m_constant, c_appsettings;


{$R *.lfm}

{ TfrmInfo }

procedure TfrmInfo.FormActivate(Sender: TObject);
var
  fsize:integer;
begin
  Color:=AppSettings.GlobalBackgroundColor;
  fsize:=m_tools.GetIntegerFromIniFile('FONTS','GlobalFontsize',c_defaultFontsize);
  Font.Size:=fsize;
  mmoinfo.Font.Color:=clBlack;
end;

procedure TfrmInfo.ClearInfo;
begin
  mmoInfo.Clear;
end;

procedure TfrmInfo.AppendInfo(s:string);
begin
  mmoInfo.Append(s);
end;

end.

