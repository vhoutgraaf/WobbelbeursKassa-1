//------------------------------------------------------------------------------
// Name        : c_wobbelgridpanel
// Purpose     : Implementatie van TWobbelGridPanel en bijbehorende class
//               TWobbelGridColumnProps en typedeclaraties
// Environment : Free Pascal 2.4.2, Windows XP
// Notes       : Baseclass direct overervend van TPanel, waarin worden gemaakt
//               een TStringGrid, navigatieknoppen, titel- en
//               statusregel. De class dient te worden overerfd voor goed gebruik.
// Author      : Vincent Houtgraaf, Bunnik
// Date        : aug 2011
// Modified    :
//------------------------------------------------------------------------------
unit c_wobbelgridpanel;

{$mode objfpc}{$H+}

interface

uses
  Controls, Classes, SysUtils, StdCtrls, ExtCtrls, Buttons, Forms, Graphics, Grids,
  contnrs;

type
  TWobbelColContentType = set of (wtString, wtMemo, wtInteger, wtMoney, wtDecimal, wtDateTime);

type
  TWobbelGridStatus = set of (wsEnabledNotEditable, wsEnabledEditable, wsDisabledNotEditable);

type
  TWobbelNavButtons = set of (wbFirst, wbPrev, wbNext, wbLast, wbAdd, wbDelete, wbEdit, wbPost, wbCancel, wbRefresh, wbFontsizePlus, wbFontsizeMinus, wbHint);

type
  TWobbelGridColumnProps = class
    private
      FColIndex: integer;
      FColContentType: TWobbelColContentType;
      FColDefaultvalue: string;
      FMinLen: integer;
      FMaxLen: integer;
      FMinVal: double; //(nog) niet in gebruik
      FMaxVal: double; //(nog) niet in gebruik
      FWidthOri: Integer;
      FColNaam: string;
      FColDescription: string;
      FDatabaseFieldname: string;
      FIsVerplicht: boolean;
    Public
      Constructor Create(ColIndex: integer;
          DatabaseFieldname:string;
          ColType : TWobbelColContentType;
          ColDefaultvalue: string;
          MinLen, MaxLen: integer;
          ColNaam, ColDescription:string;
          WidthOri: integer;
          IsVerplicht:boolean);
      Property ColIndex : integer read FColIndex write FColIndex;
      Property ColType : TWobbelColContentType read FColContentType write FColContentType;
      Property ColDefaultvalue : string read FColDefaultvalue write FColDefaultvalue;
      Property ColNaam : String read FColNaam write FColNaam;
      Property ColDescription : String read FColDescription write FColDescription;
      Property MinLen : integer read FMinLen write FMinLen;
      Property MaxLen : integer read FMaxLen write FMaxLen;
      Property WidthOri : integer read FWidthOri write FWidthOri;
      Property DatabaseFieldname : String read FDatabaseFieldname write FDatabaseFieldname;
      Property IsVerplicht : boolean read FIsVerplicht write FIsVerplicht;

  end;


type
TWobbelGridPanel = class(TPanel)
  private

    FbtnMargin : integer;
    FbtnWidth  : integer;
    FbtnHeight : integer;
    FbtnTop    :integer;
    FpnlMargin :integer;
    FStatusHeight : integer;
    FTitelHeight : integer;

    FTop       :integer;
    FLeft      :integer;
    FHeight    :integer;

    FWobbelGridStatus: TWobbelGridStatus;

    FButtonsShown: TWobbelNavButtons;

    FParent: TWinControl;

    FTitel:string;
    FAfterInit: boolean;

    procedure SetTitelProps;
    procedure SetGridProps;
    procedure SetNavProps;
    procedure SetStatuslineProps;

    procedure WobbelGridValidateEntry1(sender: TObject; aCol,
      aRow: Integer; const OldValue: string; var NewValue: String);
    procedure WobbelGridSelectCell1(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
    procedure WobbelGridDblClick1(Sender: TObject);
    procedure WobbelGridKeyDown1(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure WobbelGridPrepareCanvas1(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);

  public
    WobbelGrid: TStringGrid;
    lstColTypes: TObjectList;
    Statusline: TLabel;
    Titellabel: TLabel;

    btnFirst  : TBitBtn;
    btnPrev   : TBitBtn;
    btnNext   : TBitBtn;
    btnLast   : TBitBtn;
    btnEdit   : TBitBtn;
    btnInsert : TBitBtn;
    btnPost   : TBitBtn;
    btnDelete : TBitBtn;
    btnCancel : TBitBtn;
    btnRefresh: TBitBtn;
    btnFontsizePlus: TBitBtn;
    btnFontsizeMinus: TBitBtn;
    btnHint: TBitBtn;

    constructor Create(AOwner: TComponent; AParent: TWinControl; ATop, ALeft, AHeight:integer);
    constructor Create(AOwner: TComponent; AParent: TWinControl; ATop, ALeft, AHeight:integer; navButs: TWobbelNavButtons);
    procedure Init(AOwner: TComponent; AParent: TWinControl; ATop, ALeft, AHeight:integer);
    destructor Destroy; override;

    property Titel : String read FTitel write FTitel;
    property WobbelGridStatus: TWobbelGridStatus read FWobbelGridStatus;

    procedure btnFirstClick(Sender: TObject);
    procedure btnPrevClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure btnLastClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnInsertClick(Sender: TObject);
    procedure btnFontsizePlusClick(Sender: TObject);
    procedure btnFontsizeMinusClick(Sender: TObject);

    function WobbelGridValidateCellentry(aCol, aRow: Integer; const OldValue: string; var NewValue: String): boolean;
    procedure AddARecord();
    procedure DoSelectCell(aCol, aRow: Integer);

    procedure SetGridStatus(status:TWobbelGridStatus);

    function FindWobbelGridColumnIndexByColIndex(aCol: Integer): integer;
    function FindWobbelGridColumnIndexByDatabaseFieldName(ColName: string): integer;

    procedure SetFontSize(delta:integer);

    function GetCurrentGridRowNr:integer;
    procedure SetGridRowNr(iRow:integer);
    procedure SetGridRowNrToLast();
    procedure SetGridRowNrToFirst();


    function GetCurrentGridColNr:integer;
    procedure SetGridColNr(iCol:integer);

    procedure SetGridHint(s:string);

    function GetGridFirstRowNr(): integer;
    function GetGridLastRowNr(): integer;


end;



implementation


uses
  math,
  LCLType,
  fpImage,
  m_tools,
  m_constant;


constructor TWobbelGridPanel.Create(AOwner: TComponent; AParent: TWinControl; ATop, ALeft, AHeight:integer);
begin
  FAfterInit:=false;
  inherited Create(AOwner);
  FButtonsShown:=[wbFirst, wbPrev, wbNext, wbLast, wbAdd, wbDelete, wbEdit, wbPost, wbCancel, wbRefresh];
  Init(AOwner, AParent, ATop, ALeft, AHeight);
  FAfterInit:=true;
end;

constructor TWobbelGridPanel.Create(AOwner: TComponent; AParent: TWinControl; ATop, ALeft, AHeight:integer; navButs: TWobbelNavButtons);
begin
  FAfterInit:=false;
  inherited Create(AOwner);
  FButtonsShown:=navButs;
  Init(AOwner, AParent, ATop, ALeft, AHeight);
  FAfterInit:=true;
end;

procedure TWobbelGridPanel.Init(AOwner: TComponent; AParent: TWinControl; ATop, ALeft, AHeight:integer);
begin
  FbtnMargin:=0;
  FbtnWidth:=25;
  FbtnHeight:=25;
  FStatusHeight:=25;
  FTitelHeight:=25;
  FbtnTop:=0;
  FpnlMargin:=2;
  FTop:=ATop;
  FLeft:=ALeft;
  FHeight:=AHeight;
  FParent:=AParent;

  FWobbelGridStatus:=[wsEnabledEditable];

  Self.Color:=clDefault;
  Self.Width:=AParent.Width;//*FbtnWidth+9*FbtnMargin;
  Self.Height:=AHeight;//FbtnHeight;
  Self.Parent:=AParent;
  Self.Top:=ATop;
  Self.Left:=ALeft;

  Self.Align:=alClient;

  WobbelGrid:=TStringGrid.Create(AOwner);

  if (WBFIRST in FButtonsShown) then
     btnFirst:=TBitBtn.Create(AOwner);
  if (WBPREV in FButtonsShown) then
    btnPrev:=TBitBtn.Create(AOwner);
  if (WBNEXT in FButtonsShown) then
    btnNext:=TBitBtn.Create(AOwner);
  if (WBLAST in FButtonsShown) then
    btnLast:=TBitBtn.Create(AOwner);
  if (WBEDIT in FButtonsShown) then
    btnEdit:=TBitBtn.Create(AOwner);
  if (WBADD in FButtonsShown) then
    btnInsert:=TBitBtn.Create(AOwner);
  if (WBPOST in FButtonsShown) then
    btnPost:=TBitBtn.Create(AOwner);
  if (WBDELETE in FButtonsShown) then
    btnDelete:=TBitBtn.Create(AOwner);
  if (WBCANCEL in FButtonsShown) then
    btnCancel:=TBitBtn.Create(AOwner);
  if (WBREFRESH in FButtonsShown) then
    btnRefresh:=TBitBtn.Create(AOwner);

  //if (WBFONTSIZEPLUS in FButtonsShown) then
    btnFontsizePlus:=TBitBtn.Create(AOwner);
  //if (WBFONTSIZEMINUS in FButtonsShown) then
    btnFontsizeMinus:=TBitBtn.Create(AOwner);

    btnHint:=TBitBtn.Create(AOwner);

  Statusline:=TLabel.Create(AOwner);
  Titellabel:=TLabel.Create(AOwner);

  SetTitelProps;
  SetGridProps;
  SetNavProps;
  SetStatuslineProps;

  lstColTypes:=TObjectList.create(true);

  SetGridStatus([WSDISABLEDNOTEDITABLE]);

  WobbelGrid.Color:=clInfoBk;
end;

//------------------------------------------------------------------------------
destructor TWobbelGridPanel.Destroy;
begin
  lstColTypes.Free;
  lstColTypes:=nil;

  inherited Destroy;
end;

procedure TWobbelGridPanel.SetGridProps;
var
  ix: integer;
begin
  WobbelGrid.Top:=Titellabel.Top+Titellabel.Height+FpnlMargin;
  WobbelGrid.Left:=Self.Left+FpnlMargin;
  WobbelGrid.Width:=FParent.Width-FpnlMargin-FpnlMargin;
  WobbelGrid.Height:=FHeight-FTitelHeight-FbtnHeight-FStatusHeight-FpnlMargin;
  WobbelGrid.Anchors:=[akTop,akLeft,akRight,akBottom];
  WobbelGrid.Parent:=Self;
  WobbelGrid.FixedCols:=1;
  WobbelGrid.FixedRows:=1;
  //WobbelGrid.FixedColor:=clRed;

  WobbelGrid.Options:=WobbelGrid.Options-[goFixedVertLine];
  WobbelGrid.Options:=WobbelGrid.Options-[goFixedHorzLine];
  WobbelGrid.Options:=WobbelGrid.Options-[goRowSelect];WobbelGrid.Options:=WobbelGrid.Options+[goRowSelect];
  WobbelGrid.Options:=WobbelGrid.Options-[goRowSizing];WobbelGrid.Options:=WobbelGrid.Options+[goRowSizing];
  WobbelGrid.Options:=WobbelGrid.Options-[goRangeSelect];
  WobbelGrid.Options:=WobbelGrid.Options-[goAlwaysShowEditor];WobbelGrid.Options:=WobbelGrid.Options+[goAlwaysShowEditor];
  WobbelGrid.Options:=WobbelGrid.Options-[goDrawFocusSelected];WobbelGrid.Options:=WobbelGrid.Options+[goDrawFocusSelected];

  for ix:=WobbelGrid.RowCount-1 downto 1 do
  begin
    WobbelGrid.DeleteRow(ix);
  end;
  WobbelGrid.FocusColor:=clSkyBlue;

  WobbelGrid.OnValidateEntry:=@WobbelGridValidateEntry1;
  WobbelGrid.OnSelectCell:=@WobbelGridSelectCell1;
  WobbelGrid.OnDblClick:=@WobbelGridDblClick1;
  WobbelGrid.OnKeyDown:=@WobbelGridKeyDown1;
  WobbelGrid.OnPrepareCanvas:=@WobbelGridPrepareCanvas1;

end;

procedure TWobbelGridPanel.SetNavProps;
var
  btnTop:integer;
  btnLeft:integer;
begin
  btnTop:=WobbelGrid.Height+WobbelGrid.Top;
  btnLeft:=WobbelGrid.Left;

  if (WBFIRST in FButtonsShown) then
  begin
    btnFirst.Width:=FbtnWidth;
    btnFirst.Height:=FbtnHeight;
    btnFirst.Top:=btnTop;
    btnFirst.Left:=btnLeft;
    if (FileExists('img/resultset_first.bmp')) then
    begin
      btnFirst.Glyph.LoadFromFile('img/resultset_first.bmp');
    end
    else
    begin
      btnFirst.Caption:='Eerste';
      btnFirst.Width:=btnFirst.Width + 30;
    end;
    btnFirst.Parent:=Self;
    btnFirst.OnClick:=@btnFirstClick;
    btnFirst.Hint:='Ga naar eerste regel';
    btnFirst.ShowHint:=true;
    btnFirst.Anchors:=[akLeft,akBottom];
    btnLeft:=btnFirst.Left + btnFirst.Width + FbtnMargin;
  end;
  if (WBPREV in FButtonsShown) then
  begin
    btnPrev.Width:=FbtnWidth;
    btnPrev.Height:=FbtnHeight;
    btnPrev.Top:=btnTop;
    btnPrev.Left:=btnLeft;
    if (FileExists('img/resultset_previous.bmp')) then
    begin
      btnPrev.Glyph.LoadFromFile('img/resultset_previous.bmp');
    end
    else
    begin
      btnPrev.Caption:='Vorige';
      btnPrev.Width:=btnPrev.Width + 30;
    end;
    btnPrev.Parent:=Self;
    btnPrev.OnClick:=@btnPrevClick;
    btnPrev.Hint:='Ga naar vorige regel';
    btnPrev.ShowHint:=true;
    btnPrev.Anchors:=[akLeft,akBottom];
    btnLeft:=btnPrev.Left + btnPrev.Width + FbtnMargin;
  end;
  if (WBNEXT in FButtonsShown) then
  begin
    btnNext.Width:=FbtnWidth;
    btnNext.Height:=FbtnHeight;
    btnNext.Top:=btnTop;
    btnNext.Left:=btnLeft;
    if (FileExists('img/resultset_next.bmp')) then
    begin
      btnNext.Glyph.LoadFromFile('img/resultset_next.bmp');
    end
    else
    begin
      btnNext.Caption:='Volgende';
      btnNext.Width:=btnNext.Width + 30;
    end;
    btnNext.Parent:=Self;
    btnNext.OnClick:=@btnNextClick;
    btnNext.Hint:='Ga naar volgende regel';
    btnNext.ShowHint:=true;
    btnNext.Anchors:=[akLeft,akBottom];
    btnLeft:=btnNext.Left + btnNext.Width + FbtnMargin;
  end;
  if (WBLAST in FButtonsShown) then
  begin
    btnLast.Width:=FbtnWidth;
    btnLast.Height:=FbtnHeight;
    btnLast.Top:=btnTop;
    btnLast.Left:=btnLeft;
    if (FileExists('img/resultset_last.bmp')) then
    begin
      btnLast.Glyph.LoadFromFile('img/resultset_last.bmp');
    end
    else
    begin
      btnLast.Caption:='Laatste';
      btnLast.Width:=btnLast.Width + 30;
    end;
    btnLast.Parent:=Self;
    btnLast.OnClick:=@btnLastClick;
    btnLast.Hint:='Ga naar laatste regel';
    btnLast.ShowHint:=true;
    btnLast.Anchors:=[akLeft,akBottom];
    btnLeft:=btnLast.Left + btnLast.Width + FbtnMargin;
  end;
  if (WBEDIT in FButtonsShown) then
  begin
    btnEdit.Width:=2*FbtnWidth;
    btnEdit.Height:=FbtnHeight;
    btnEdit.Top:=btnTop;
    btnEdit.Left:=btnLeft;
    if (FileExists('img/dbnavedit.bmp')) then
    begin
      btnEdit.Glyph.LoadFromFile('img/dbnavedit.bmp');
    end
    else
    begin
      btnEdit.Caption:='Wijzigen';
      btnEdit.Width:=btnEdit.Width + 30;
    end;
    btnEdit.Parent:=Self;
    btnEdit.OnClick:=@btnEditClick;
    btnEdit.Hint:='Starten met tabelwijzigingen';
    btnEdit.ShowHint:=true;
    btnEdit.Anchors:=[akLeft,akBottom];
    btnLeft:=btnEdit.Left + btnEdit.Width + FbtnMargin;
  end;
  if (WBADD in FButtonsShown) then
  begin
    btnInsert.Width:=2*FbtnWidth;
    btnInsert.Height:=FbtnHeight;
    btnInsert.Top:=btnTop;
    btnInsert.Left:=btnLeft;
    if (FileExists('img/dbnavinsert.bmp')) then
    begin
      btnInsert.Glyph.LoadFromFile('img/dbnavinsert.bmp');
    end
    else
    begin
      btnInsert.Caption:='Toevoegen';
      btnInsert.Width:=btnEdit.Width + 30;
    end;
    btnInsert.Parent:=Self;
    btnInsert.OnClick:=@btnInsertClick;
    btnInsert.Hint:='Nieuwe regel toevoegen';
    btnInsert.ShowHint:=true;
    btnInsert.Anchors:=[akLeft,akBottom];
    btnLeft:=btnInsert.Left + btnInsert.Width + FbtnMargin;
  end;
  if (WBPOST in FButtonsShown) then
  begin
    btnPost.Width:=2*FbtnWidth;
    btnPost.Height:=FbtnHeight;
    btnPost.Top:=btnTop;
    btnPost.Left:=btnLeft;
    if (FileExists('img/dbnavpost.bmp')) then
    begin
      btnPost.Glyph.LoadFromFile('img/dbnavpost.bmp');
    end
    else
    begin
      btnPost.Caption:='Opslaan';
      btnPost.Width:=btnPost.Width + 30;
    end;
    btnPost.Parent:=Self;
    btnPost.Hint:='Wijzigingen opslaan in de database';
    btnPost.ShowHint:=true;
    btnPost.Anchors:=[akLeft,akBottom];
    btnLeft:=btnPost.Left + btnPost.Width + FbtnMargin;
  end;
  if (WBDELETE in FButtonsShown) then
  begin
    btnDelete.Width:=2*FbtnWidth;
    btnDelete.Height:=FbtnHeight;
    btnDelete.Top:=btnTop;
    btnDelete.Left:=btnLeft;
    if (FileExists('img/dbnavdelete.bmp')) then
    begin
      btnDelete.Glyph.LoadFromFile('img/dbnavdelete.bmp');
    end
    else
    begin
      btnDelete.Caption:='Verwijderen';
      btnDelete.Width:=btnDelete.Width + 30;
    end;
    btnDelete.Parent:=Self;
    btnDelete.Hint:='Verwijder geselecteerde regel';
    btnDelete.ShowHint:=true;
    btnDelete.Anchors:=[akLeft,akBottom];
    btnLeft:=btnDelete.Left + btnDelete.Width + FbtnMargin;
  end;
  if (WBCANCEL in FButtonsShown) then
  begin
    btnCancel.Width:=2*FbtnWidth;
    btnCancel.Height:=FbtnHeight;
    btnCancel.Top:=btnTop;
    btnCancel.Left:=btnLeft;
    if (FileExists('img/dbnavcancel.bmp')) then
    begin
      btnCancel.Glyph.LoadFromFile('img/dbnavcancel.bmp');
    end
    else
    begin
      btnCancel.Caption:='Annuleren';
      btnCancel.Width:=btnCancel.Width + 30;
    end;
    btnCancel.Parent:=Self;
    btnCancel.Hint:='Alle wijzigingen sinds de laatste keer opslaan ongedaan maken';
    btnCancel.ShowHint:=true;
    btnCancel.Anchors:=[akLeft,akBottom];
    btnLeft:=btnCancel.Left + btnCancel.Width + FbtnMargin;
  end;
  if (WBREFRESH in FButtonsShown) then
  begin
    btnRefresh.Width:=2*FbtnWidth;
    btnRefresh.Height:=FbtnHeight;
    btnRefresh.Top:=btnTop;
    btnRefresh.Left:=btnLeft;
    if (FileExists('img/dbnavrefresh.bmp')) then
    begin
      btnRefresh.Glyph.LoadFromFile('img/dbnavrefresh.bmp');
    end
    else
    begin
      btnRefresh.Caption:='Verversen';
      btnRefresh.Width:=btnRefresh.Width + 30;
    end;
    btnRefresh.Parent:=Self;
    btnRefresh.Hint:='Tabel opnieuw laden. Wijzigingen sinds de laatste keer opslaan worden niet opgeslagen!';
    btnRefresh.ShowHint:=true;
    btnRefresh.Anchors:=[akLeft,akBottom];
    btnLeft:=btnRefresh.Left + btnRefresh.Width + FbtnMargin;
  end;
  if (true or (WBFONTSIZEMINUS in FButtonsShown)) then
  begin
    btnFontsizeMinus.Width:=2*FbtnWidth;
    btnFontsizeMinus.Height:=FbtnHeight;
    btnFontsizeMinus.Top:=btnTop;
    btnFontsizeMinus.Left:=btnLeft + 20 + FbtnMargin;//btnRight-btnFontsizeMinus.Width;
    if (FileExists('img/font_minus.bmp')) then
    begin
      btnFontsizeMinus.Glyph.LoadFromFile('img/font_minus.bmp');
    end
    else
    begin
      btnFontsizeMinus.Caption:='Fontgrootte verkleinen';
      btnFontsizeMinus.Width:=btnFontsizeMinus.Width + 60;
    end;
    btnFontsizeMinus.OnClick:=@btnFontsizeMinusClick;
    btnFontsizeMinus.Parent:=Self;
    btnFontsizeMinus.Hint:='Fontgrootte verkleinen';
    btnFontsizeMinus.ShowHint:=true;
    btnFontsizeMinus.Anchors:=[akLeft,akBottom];
    //btnRight:=btnFontsizeMinus.Left - FbtnMargin;
    btnLeft:=btnFontsizeMinus.Left + btnFontsizeMinus.Width + FbtnMargin;
  end;
  if (true or (WBFONTSIZEPLUS in FButtonsShown)) then
  begin
    btnFontsizePlus.Width:=2*FbtnWidth;
    btnFontsizePlus.Height:=FbtnHeight;
    btnFontsizePlus.Top:=btnTop;
    btnFontsizePlus.Left:=btnLeft;//btnRight-btnFontsizePlus.Width;
    if (FileExists('img/font_plus.bmp')) then
    begin
      btnFontsizePlus.Glyph.LoadFromFile('img/font_plus.bmp');
    end
    else
    begin
      btnFontsizePlus.Caption:='Fontgrootte vergroten';
      btnFontsizePlus.Width:=btnFontsizePlus.Width + 60;
    end;
    btnFontsizePlus.OnClick:=@btnFontsizePlusClick;
    btnFontsizePlus.Parent:=Self;
    btnFontsizePlus.Hint:='Fontgrootte vergroten';
    btnFontsizePlus.ShowHint:=true;
    btnFontsizePlus.Anchors:=[akLeft,akBottom];
    //btnRight:=btnFontsizePlus.Left - FbtnMargin;
    btnLeft:=btnFontsizePlus.Left + btnFontsizePlus.Width + FbtnMargin;
  end;
  if (true or (WBHINT in FButtonsShown)) then
  begin
    btnHint.Width:=2*FbtnWidth;
    btnHint.Height:=FbtnHeight;
    btnHint.Top:=btnTop;
    btnHint.Left:=btnLeft;
    if (FileExists('img/info.bmp')) then
    begin
      btnHint.Glyph.LoadFromFile('img/info.bmp');
    end
    else
    begin
      btnHint.Caption:='Info';
      btnHint.Width:=btnHint.Width + 60;
    end;
    btnHint.Parent:=Self;
    btnHint.Hint:='TODO: in te vullen door instantie';
    btnHint.ShowHint:=true;
    btnHint.Anchors:=[akLeft,akBottom];
    btnLeft:=btnHint.Left + btnHint.Width + FbtnMargin;
  end;

end;

procedure TWobbelGridPanel.SetGridHint(s:string);
begin
  btnHint.Hint:=s;
end;

procedure TWobbelGridPanel.SetStatuslineProps;
begin
  StatusLine.Parent:=Self;
  StatusLine.Left:=WobbelGrid.Left;
  StatusLine.Top:=FTitelHeight+WobbelGrid.Height+WobbelGrid.Top+FbtnHeight;
  StatusLine.Anchors:=[akLeft,akBottom];
end;

procedure TWobbelGridPanel.SetTitelProps;
begin
  Titellabel.Parent:=Self;
  Titellabel.Left:=Self.Left+FpnlMargin;
  Titellabel.Top:=FpnlMargin;
  Titellabel.Height:=FTitelHeight;
  Titellabel.Caption:=FTitel;
  Titellabel.Font.Color:=clBlue;
  Titellabel.Font.Bold:=true;
  Titellabel.Font.Size:=c_defaultFontsize;
  Titellabel.Anchors:=[akLeft,akTop];
end;

procedure TWobbelGridPanel.SetFontSize(delta:integer);
var
  i:integer;
  fsize,fsizedefault:Integer;
  fsizename:string;
  factor, exponent:float;
  newwidth:integer;
begin
  try
    fsizedefault:=m_tools.GetIntegerFromIniFile('FONTS','GlobalFontsize',c_defaultFontsize);
    fsizename:='FontSize'+FTitel;
    fsize:=m_tools.GetIntegerFromIniFile('FONTS',fsizename,fsizedefault);
    fsize:=fsize+delta;
    if (fsize<5) then
    begin
      fsize:=5;
    end;
    m_tools.SetValueInIniFile('FONTS',fsizename,IntToStr(fsize));

    if (WobbelGrid <> nil) then
    begin
      Titellabel.Font.Size:=fsize;
      WobbelGrid.TitleFont.Size:=fsize;

      exponent:=abs(float((fsize-int(c_defaultFontsize))));
      factor:=1.0;
      if (fsize > c_defaultFontsize) then
      begin
        factor:=power(1.1, exponent);
      end
      else if (fsize < c_defaultFontsize) then
      begin
        factor:=power(0.9, exponent);
      end;

      for i:=0 to WobbelGrid.Columns.Count-1 do
      begin
        WobbelGrid.Columns[i].Font.Size:=fsize;
        WobbelGrid.Columns[i].Title.Font.Size:=fsize;
        newwidth:=LongInt(Round(TWobbelGridColumnProps(lstColTypes.Items[i]).WidthOri * factor));
        WobbelGrid.Columns[i].Width:=newwidth;
      end;
    end;
  except
  end;
end;

procedure TWobbelGridPanel.btnFirstClick(Sender: TObject);
begin
  WobbelGrid.Row:=0;
end;

procedure TWobbelGridPanel.btnPrevClick(Sender: TObject);
var
  ix:integer;
begin
  ix:=WobbelGrid.Row-1;
  if (ix<0) then
  begin
    ix:=0;
  end;
  WobbelGrid.Row:=ix;
end;

procedure TWobbelGridPanel.btnNextClick(Sender: TObject);
var
  ix:integer;
begin
  // als het grid niet editable is, geen record toevoegen
  if ((WSENABLEDNOTEDITABLE in FWobbelGridStatus) or (WSENABLEDEDITABLE in FWobbelGridStatus)) then
  begin
    ix:=WobbelGrid.Row+1;
    if (ix>WobbelGrid.RowCount-1) then
    begin
      if (WSENABLEDEDITABLE in FWobbelGridStatus) then
      begin
        WobbelGrid.RowCount:=WobbelGrid.RowCount+1;
        //ix:=WobbelGrid.RowCount-1;
      end
      else
      begin
        ix:=WobbelGrid.Row;
      end;
    end;
    WobbelGrid.Row:=ix;
  end;
end;

procedure TWobbelGridPanel.btnLastClick(Sender: TObject);
begin
  WobbelGrid.Row:=WobbelGrid.RowCount-1;
end;

procedure TWobbelGridPanel.btnEditClick(Sender: TObject);
begin
  SetGridStatus([WSENABLEDEDITABLE]);
end;

procedure TWobbelGridPanel.AddARecord();
var
  ix:integer;
begin
  if (WSENABLEDEDITABLE in FWobbelGridStatus) then
  begin
    WobbelGrid.RowCount:=WobbelGrid.RowCount+1;

    // Zet voor iedere kolom een default waarde.
    try
      for ix:=0 to lstColTypes.Count-1 do
      begin
        WobbelGrid.Cells[WobbelGrid.FixedCols+ix, WobbelGrid.RowCount-1]:=TWobbelGridColumnProps(lstColTypes.Items[ix]).ColDefaultvalue;
      end;
    except
    end;
    // naar de nieuwe row
    WobbelGrid.Row:=WobbelGrid.RowCount-1;
    ix:=WobbelGrid.Row;
    ix:=WobbelGrid.RowCount;
  end;
end;

procedure TWobbelGridPanel.btnInsertClick(Sender: TObject);
begin
  AddARecord();
end;

procedure TWobbelGridPanel.btnFontsizePlusClick(Sender: TObject);
begin
  SetFontSize(1);
end;
procedure TWobbelGridPanel.btnFontsizeMinusClick(Sender: TObject);
begin
  SetFontSize(-1);
end;

procedure TWobbelGridPanel.SetGridStatus(status:TWobbelGridStatus);
begin
  FWobbelGridStatus:=status;

  if (WSENABLEDEDITABLE in FWobbelGridStatus) then
  begin
    WobbelGrid.Enabled:=true;
    WobbelGrid.Options:=WobbelGrid.Options+[goEditing];
    WobbelGrid.FocusColor:=clBlue;
    //WobbelGrid.SetFocus;
    if (WobbelGrid.IsVisible and WobbelGrid.Enabled) then
    begin
      WobbelGrid.SetFocus;
    end;
    WobbelGrid.Options:=WobbelGrid.Options-[goRowSelect];
  end;
  if (WSENABLEDNOTEDITABLE in FWobbelGridStatus) then
  begin
    WobbelGrid.Enabled:=true;
    WobbelGrid.Options:=WobbelGrid.Options-[goEditing];
    WobbelGrid.FocusColor:=clRed;
    WobbelGrid.Options:=WobbelGrid.Options-[goRowSelect];
    WobbelGrid.Options:=WobbelGrid.Options+[goRowSelect];
  end;
  if (WSDISABLEDNOTEDITABLE in FWobbelGridStatus) then
  begin
    WobbelGrid.Enabled:=false;
    WobbelGrid.Options:=WobbelGrid.Options-[goEditing];
    WobbelGrid.FocusColor:=clRed;
    WobbelGrid.Options:=WobbelGrid.Options-[goRowSelect];
    WobbelGrid.Options:=WobbelGrid.Options+[goRowSelect];
  end;

  if ((WSENABLEDNOTEDITABLE in FWobbelGridStatus) or (WSENABLEDEDITABLE in FWobbelGridStatus)) then
  begin
    WobbelGrid.Enabled:=true;

    if (WBEDIT in FButtonsShown) then
      btnEdit.Enabled:=false;
  //  if (WBADD in FButtonsShown) then
  //    btnInsert.Enabled:=false;
    if (WBPOST in FButtonsShown) then
      btnPost.Enabled:=true;
    if (WBDELETE in FButtonsShown) then
      btnDelete.Enabled:=false;
    if (WBCANCEL in FButtonsShown) then
      btnCancel.Enabled:=true;

    btnFirst.Enabled:=true;
    btnPrev.Enabled:=true;
    btnNext.Enabled:=true;
    btnLast.Enabled:=true;
  end;

  if (WSDISABLEDNOTEDITABLE in FWobbelGridStatus) then
  begin
    WobbelGrid.Enabled:=false;

    if (WBEDIT in FButtonsShown) then
      btnEdit.Enabled:=false;
  //  if (WBADD in FButtonsShown) then
  //    btnInsert.Enabled:=false;
    if (WBPOST in FButtonsShown) then
      btnPost.Enabled:=false;
    if (WBDELETE in FButtonsShown) then
      btnDelete.Enabled:=false;
    if (WBCANCEL in FButtonsShown) then
      btnCancel.Enabled:=false;

    btnFirst.Enabled:=false;
    btnPrev.Enabled:=false;
    btnNext.Enabled:=false;
    btnLast.Enabled:=false;
  end;

end;

function TWobbelGridPanel.WobbelGridValidateCellentry(
            aCol, aRow: Integer; const OldValue: string; var NewValue: String): boolean;
var
  coltype: TWobbelColContentType;
  len: integer;
  isOk:boolean;
  ListIndex:integer;
  sSalvaged:string;
  bReplace:boolean;
{$IFDEF DEVELOP}
  sDev: string;
  iDev:integer;
{$ENDIF}
begin
  {$IFDEF DEVELOP}
  sDev:='';
  for iDev:=0 to lstColTypes.Count-1 do
  begin
    sDev:=sDev+'; '+IntToStr(TWobbelGridColumn(lstColTypes.Items[iDev]).ColIndex)+':'+TWobbelGridColumn(lstColTypes.Items[iDev]).ColNaam;
  end;
  MessageOk(sDev);
  {$ENDIF}


  isOk:=true;
  bReplace:=false;
  ListIndex:=FindWobbelGridColumnIndexByColIndex(aCol);
  if (ListIndex < 0) then
  begin
    MessageError('Kan geen kolomeigenschappen vinden bij valideren celwaarde');
    exit;
  end;

  sSalvaged:=OldValue;
  len:=Length(NewValue);
  if (len > TWobbelGridColumnProps(lstColTypes[ListIndex]).FMaxLen) then
  begin
    MessageError('Teveel tekens ingevoerd bij "' + TWobbelGridColumnProps(lstColTypes.Items[ListIndex]).ColNaam + '": maximaal ' + IntToStr(TWobbelGridColumnProps(lstColTypes.Items[ListIndex]).MaxLen));
    isOk:=false;
    sSalvaged:=LeftStr(NewValue,TWobbelGridColumnProps(lstColTypes.Items[ListIndex]).MaxLen);
  end;

  {$IFDEF DEVELOP}
  sDev:='Colnaam: ' + TWobbelGridColumn(lstColTypes.Items[ListIndex]).ColNaam;
  for iDev:=0 to aRow-1 do
  begin
    sDev:=sDev+'; waarde[' + IntToStr(aCol) + ',' + IntToStr(iDev) + ']=' + WobbelGrid.Cells[aCol, iDev];
  end;
  MessageOk(sDev);
  {$ENDIF}

  if (isOk) then
  begin
    coltype:=TWobbelGridColumnProps(lstColTypes.Items[ListIndex]).ColType;
    if (WTSTRING in coltype) then
    begin
    //
    end
    else if (WTINTEGER in coltype) then
    begin
      if ((len>0) and not IsInteger(NewValue)) then
      begin
        MessageError('Geen geheel getal ingevoerd bij "' + TWobbelGridColumnProps(lstColTypes.Items[ListIndex]).ColNaam + '"');
        isOk:=false;
      end;
    end
    else if (WTDECIMAL in coltype) then
    begin
      if ((len>0) and not IsDouble(NewValue)) then
      begin
        MessageError('Geen geldig decimaal getal ingevoerd bij "' + TWobbelGridColumnProps(lstColTypes.Items[ListIndex]).ColNaam + '"');
        isOk:=false;
      end;
    end
    else if (wtMoney in coltype) then
    begin
      sSalvaged:=StringReplace(StringReplace(NewValue, ',', DefaultFormatSettings.DecimalSeparator, [rfReplaceAll]), '.', DefaultFormatSettings.DecimalSeparator, [rfReplaceAll]);
      if ((len>0) and not IsDouble(sSalvaged)) then
      begin
        MessageError('Geen geldig decimaal getal ingevoerd bij "' + TWobbelGridColumnProps(lstColTypes.Items[ListIndex]).ColNaam + '"');
        isOk:=false;
      end
      else
      begin
        sSalvaged:=FormatToMoney(sSalvaged);
      end;
      bReplace:=true;
    end
    else if (WTDATETIME in coltype) then
    begin
    end;
  end;

  if ((not isOk) or bReplace) then
  begin
    WobbelGrid.Cells[aCol, aRow]:=sSalvaged;
    // werkt niet:
    //WobbelGrid.Row:=aRow;
    //WobbelGrid.Col:=aCol;
  end;
  WobbelGridValidateCellentry:=isOk;
end;

procedure TWobbelGridPanel.WobbelGridValidateEntry1(sender: TObject; aCol,
  aRow: Integer; const OldValue: string; var NewValue: String);
begin
  WobbelGridValidateCellentry(aCol, aRow, OldValue, NewValue);
end;


procedure TWobbelGridPanel.DoSelectCell(aCol, aRow: Integer);
var
  ListIndex:integer;
begin
  if (FAfterInit) then
  begin
    ListIndex:=FindWobbelGridColumnIndexByColIndex(aCol);
    if (ListIndex >= 0) then
    begin
      if (TWobbelGridColumnProps(lstColTypes[ListIndex]).ColDescription = '') then
      begin
        StatusLine.Caption:=TWobbelGridColumnProps(lstColTypes[ListIndex]).ColNaam;
      end
      else
      begin
        StatusLine.Caption:=TWobbelGridColumnProps(lstColTypes[ListIndex]).ColNaam + ': ' +
                            TWobbelGridColumnProps(lstColTypes[ListIndex]).ColDescription;
      end;
    end;
  end;
end;


procedure TWobbelGridPanel.WobbelGridSelectCell1(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
begin
  if (WSDISABLEDNOTEDITABLE in FWobbelGridStatus) then
  begin
    exit;
  end;

  DoSelectCell(aCol, aRow);
end;

procedure TWobbelGridPanel.WobbelGridDblClick1(Sender: TObject);
begin
  if (WSDISABLEDNOTEDITABLE in FWobbelGridStatus) then
  begin
    exit;
  end;

  //SetGridStatus([WSENABLEDEDITABLE]);
end;

procedure TWobbelGridPanel.WobbelGridKeyDown1(Sender: TObject; var Key: Word;
Shift: TShiftState);
var
  ix, iCol:integer;
  //s1, s2, s3:string;
  //ListIndex: integer;
  //coltype: TWobbelColContentType;
  bAlleVerplichteVeldenIngevuld:boolean;
begin
  if (WSDISABLEDNOTEDITABLE in FWobbelGridStatus) then
  begin
    exit;
  end;

  // Hoe kan je bij een picklist het geselecteerde item zetten?
  // lastig om dit goed te krijgen.
  if (false) then
  begin
    //if (((Key = VK_DOWN) or (Key = VK_UP)) and (WobbelGrid.Row<>WobbelGrid.RowCount-1)) then
    //begin
    //  if (WobbelGrid.Columns.Items[WobbelGrid.Col-WobbelGrid.FixedCols].ButtonStyle = cbsPickList) then
    //  begin
    //    s1:=WobbelGrid.Cells[WobbelGrid.Col, WobbelGrid.Row];
    //    if (Key = VK_DOWN) then
    //    begin
    //      for ix:=0 to WobbelGrid.Columns.Items[WobbelGrid.Col-WobbelGrid.FixedCols].PickList.Count-2 do
    //      begin
    //        s2:=WobbelGrid.Columns.Items[WobbelGrid.Col-WobbelGrid.FixedCols].PickList.Strings[ix];
    //        if (s1=s2) then
    //        begin
    //          s3:=WobbelGrid.Columns.Items[WobbelGrid.Col-WobbelGrid.FixedCols].PickList.Strings[ix+1];
    //          WobbelGrid.Cells[WobbelGrid.Col, WobbelGrid.Row]:=s3;
    //          break;
    //        end;
    //      end;
    //      WobbelGrid.Row:=WobbelGrid.Row-1;
    //    end
    //    else
    //    begin
    //      for ix:=WobbelGrid.Columns.Items[WobbelGrid.Col-WobbelGrid.FixedCols].PickList.Count-1 downto 1 do
    //      begin
    //        s2:=WobbelGrid.Columns.Items[WobbelGrid.Col-WobbelGrid.FixedCols].PickList.Strings[ix];
    //        if (s1=s2) then
    //        begin
    //          s3:=WobbelGrid.Columns.Items[WobbelGrid.Col-WobbelGrid.FixedCols].PickList.Strings[ix-1];
    //          WobbelGrid.Cells[WobbelGrid.Col, WobbelGrid.Row]:=s3;
    //          break;
    //        end;
    //      end;
    //      WobbelGrid.Row:=WobbelGrid.Row+1;
    //    end;
    //  end;
    //end;
  end
  else
  begin
    // Voeg een nieuwe regel toe als in de laatste regel nog eens op pijltje-naar-
    // beneden wordt geklikt
    if ((Key = VK_DOWN) and (WobbelGrid.Row=WobbelGrid.RowCount-1)) then
    begin
      bAlleVerplichteVeldenIngevuld:=true;
      for ix:=0 to lstColTypes.Count-1 do
      begin
        if (TWobbelGridColumnProps(lstColTypes.Items[ix]).IsVerplicht) then
        begin
          bAlleVerplichteVeldenIngevuld:=bAlleVerplichteVeldenIngevuld and
            (WobbelGrid.Cells[WobbelGrid.FixedCols+ix, WobbelGrid.RowCount-1] <> '')
        end;
      end;
      if (bAlleVerplichteVeldenIngevuld) then
      begin
        AddARecord();
      end
      else
      begin
        MessageError('Niet alle verplichte velden zijn ingevuld');
      end;
      //WobbelGrid.SetFocus;
      if (WobbelGrid.IsVisible and WobbelGrid.Enabled) then
      begin
        WobbelGrid.SetFocus;
      end;
    end
    else if (Key = VK_RETURN) then
    begin
      iCol:=WobbelGrid.Col;
      if (iCol=0) then
      begin
        iCol:=0;
      end;
      WobbelGrid.Col:=iCol;
      //WobbelGrid.SetFocus;
      if (WobbelGrid.IsVisible and WobbelGrid.Enabled) then
      begin
        WobbelGrid.SetFocus;
      end;
    end
    else
    begin
      // Lastig goed te krijgen: het idee was om bij numerieke kolommen alleen getallen, +-.,eE toe te laten. Uitschakelen dan maar.
      (*
      ListIndex:=FindWobbelGridColumnIndexByColIndex(Wobbelgrid.Col);
      coltype:=TWobbelGridColumnProps(lstColTypes.Items[ListIndex]).ColType;
      if (wtMoney in coltype) or (wtInteger in coltype) or (wtDecimal in coltype) then
      begin
        if (Key in [VK_0, VK_1, VK_2, VK_3, VK_4, VK_5, VK_6, VK_7, VK_8, VK_9, VK_E, VK_OEM_PLUS, VK_OEM_MINUS, VK_OEM_COMMA, VK_OEM_PERIOD]) then
        begin
        end
        else
        begin
          MessageOk('Niet numeriek');
          WobbelGrid.Row:=aRow;
          WobbelGrid.Col:=aCol;
          //WobbelGrid.SelectCell(self,aRow,aCol,cancel);
          WobbelGrid.Cols[0].Cells[0,1].SetFocus;
        end;
      end;
      *)
    end;
  end;

end;

procedure TWobbelGridPanel.WobbelGridPrepareCanvas1(sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
var
  ListIndex: integer;
  coltype: TWobbelColContentType;
  MyTextStyle: TTextStyle;
begin
  ListIndex:=FindWobbelGridColumnIndexByColIndex(Wobbelgrid.Col);
  coltype:=TWobbelGridColumnProps(lstColTypes.Items[ListIndex]).ColType;
  if (wtMemo in coltype) then
  begin
    MyTextStyle := WobbelGrid.Canvas.TextStyle;
    MyTextStyle.SingleLine := false;
    WobbelGrid.Canvas.TextStyle := MyTextStyle;
  end;
end;


function TWobbelGridPanel.FindWobbelGridColumnIndexByColIndex(aCol: Integer): integer;
var
  ix:integer;
  iRet:integer;
  testCol: integer;
begin
  iRet:=-1;
  testCol:=aCol-WobbelGrid.FixedCols;
  for ix:=0 to lstColTypes.Count-1 do
  begin
    if TWobbelGridColumnProps(lstColTypes.Items[ix]).ColIndex = testCol then
    begin
      iRet:=ix;
      break;
    end;
  end;
  FindWobbelGridColumnIndexByColIndex:=iRet;
end;

function TWobbelGridPanel.FindWobbelGridColumnIndexByDatabaseFieldName(ColName: string): integer;
var
  ix:integer;
  iRet:integer;
  sTest: string;
begin
  iRet:=-1;
  sTest:=AnsiLowerCase(ColName);
  for ix:=0 to lstColTypes.Count-1 do
  begin
    if AnsiLowerCase(TWobbelGridColumnProps(lstColTypes.Items[ix]).DatabaseFieldname) = sTest then
    begin
      iRet:=ix + WobbelGrid.FixedCols;
      break;
    end;
  end;
  FindWobbelGridColumnIndexByDatabaseFieldName:=iRet;
end;

function TWobbelGridPanel.GetCurrentGridRowNr:integer;
begin
  //result:=WobbelGrid.FixedRows+WobbelGrid.Row;
  result:=WobbelGrid.Row;
end;

procedure TWobbelGridPanel.SetGridRowNr(iRow:integer);
begin
  WobbelGrid.Row:=WobbelGrid.FixedRows+iRow;
end;

procedure TWobbelGridPanel.SetGridRowNrToLast();
begin
  WobbelGrid.Row:=WobbelGrid.RowCount-1;
end;

function TWobbelGridPanel.GetGridLastRowNr(): integer;
begin
  Result:=WobbelGrid.RowCount-1;
end;

procedure TWobbelGridPanel.SetGridRowNrToFirst();
begin
  WobbelGrid.Row:=WobbelGrid.FixedRows;
end;

function TWobbelGridPanel.GetGridFirstRowNr(): integer;
begin
  Result:=WobbelGrid.FixedRows;
end;

function TWobbelGridPanel.GetCurrentGridColNr:integer;
begin
  result:=WobbelGrid.FixedCols+WobbelGrid.Col;
end;

procedure TWobbelGridPanel.SetGridColNr(iCol:integer);
begin
  WobbelGrid.Col:=WobbelGrid.FixedCols+iCol;
end;

//TWobbelGridColumnProps
Constructor TWobbelGridColumnProps.Create(ColIndex: integer;
            DatabaseFieldname:string;
            ColType : TWobbelColContentType;
            ColDefaultvalue: string;
            MinLen, MaxLen: integer;
            ColNaam, ColDescription:string;
            WidthOri: integer;
            IsVerplicht:boolean);
begin
  inherited Create;
  FColIndex:=ColIndex;
  FColContentType:=ColType;
  FColDefaultvalue:=ColDefaultvalue;
  FMinLen:=MinLen;
  FMaxLen:=MaxLen;
  FMinVal:=-1;// niet in gebruik
  FMaxVal:=-1;// niet in gebruik
  FWidthOri:=WidthOri;
  FColNaam:=ColNaam;
  FColDescription:=ColDescription;
  FDatabaseFieldname:=DatabaseFieldname;
  FIsVerplicht:=IsVerplicht;
end;

end.

