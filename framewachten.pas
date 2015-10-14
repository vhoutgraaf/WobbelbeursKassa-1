unit framewachten;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls;

type

  { TframeWachten }

  TframeWachten = class(TFrame)
    imgWachten: TImage;
    procedure imgWachtenClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

implementation

{$R *.lfm}

{ TframeWachten }

procedure TframeWachten.imgWachtenClick(Sender: TObject);
begin

end;

end.

