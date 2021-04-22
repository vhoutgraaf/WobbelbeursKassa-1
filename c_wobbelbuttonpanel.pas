unit c_wobbelbuttonpanel;

{$mode objfpc}{$H+}

interface

uses
  Controls, Classes, ExtCtrls, StdCtrls, Graphics;

type
TWobbelButtonPanel = class(TPanel)
  private

    FActivePanelColor: TColor;
    FInactivePanelColor:TColor;
    FActivePanelCursor: TCursor;
    FInactivePanelCursor:TCursor;

    FTextOffsetLeft:integer;
    FTextHeight:integer;
    FTextOffsetBottom:integer;

    procedure WobbelPanelClick1(Sender: TObject);
    procedure SetShortcutCombinationTextProps;


  public
    ShortcutCombinationText: TLabel;


    constructor CreateMe(AOwner: TComponent; AParent: TWinControl; ATop, ALeft, AHeight, AWidth: integer; ACaption:string);
    destructor Destroy; override;

    procedure ActivateButtonPanel(IsActive:boolean);
    procedure SetShortcutCombinationText(s:string);

end;

implementation

uses
  SysUtils, m_constant;


constructor TWobbelButtonPanel.CreateMe(AOwner: TComponent; AParent: TWinControl; ATop, ALeft, AHeight, AWidth: integer; ACaption:string);
begin
  inherited Create(AOwner);

  Self.Parent:=AParent;

  FTextOffsetLeft:=10;
  FTextHeight:=30;
  FTextOffsetBottom:=2;

  ShortcutCombinationText:=TLabel.Create(AOwner);
  SetShortcutCombinationTextProps;

  Left:=ALeft;
  Height:=AHeight;
  Top:=ATop;
  Width:=AWidth;
  Anchors:=[akTop, akLeft, akRight];
  BevelInner:=bvRaised;
  BorderWidth:=2;
  BorderStyle:=bsSingle;
  Caption:=ACaption;
  ParentColor:=False;

  FActivePanelColor:=m_constant.c_ActivePanelColor;
  FInactivePanelColor:=m_constant.c_InactivePanelColor;
  FActivePanelCursor:=m_constant.c_ActivePanelCursor;
  FInactivePanelCursor:=m_constant.c_InactivePanelCursor;

  ActivateButtonPanel(false);

  Self.ShowHint:=true;
  self.Hint:='TODO: basissvulling';

  OnClick:=@WobbelPanelClick1;
end;

destructor TWobbelButtonPanel.Destroy;
begin
  inherited Destroy;
end;

procedure TWobbelButtonPanel.WobbelPanelClick1(Sender: TObject);
begin
end;

procedure TWobbelButtonPanel.SetShortcutCombinationTextProps;
begin
  //ShortcutCombinationText.Parent:=Self;
  //ShortcutCombinationText.Anchors:=[akLeft,akBottom];
end;


procedure TWobbelButtonPanel.SetShortcutCombinationText(s:string);
begin
  ShortcutCombinationText.Caption:='';
  //ShortcutCombinationText.Left:=round(self.Width/2-self.Canvas.TextWidth(s)/2);
  //ShortcutCombinationText.Top:=Self.Height-FTextHeight-FTextOffsetBottom;
  if (self.Hint = '') then
  begin
    self.Hint:=s;
  end
  else
  begin
    self.Hint:=s + ' ' + self.Hint;
    //self.Hint:=self.Hint+m_constant.c_CR+s;
  end;
end;

procedure TWobbelButtonPanel.ActivateButtonPanel(IsActive:boolean);
begin
  Enabled:=IsActive;
  if (IsActive) then
  begin
    Color:=FActivePanelColor;
    Cursor:=FActivePanelCursor;
  end
  else
  begin
    Color:=FInactivePanelColor;
    Cursor:=FInactivePanelCursor;
  end;

end;

end.

