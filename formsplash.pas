unit formsplash;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls;

type

  { TfrmSplash }

  TfrmSplash = class(TForm)
    imgSplash1: TImage;
    lblSplash0: TLabel;
    lblSplash1: TLabel;
    pnlSplash: TPanel;
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  frmSplash: TfrmSplash;

implementation

{$R *.lfm}

end.

