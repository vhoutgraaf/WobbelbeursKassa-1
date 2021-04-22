//------------------------------------------------------------------------------
// Name        : c_gridverkoper
// Purpose     : Implementatie van TGridVrijwilliger
// Environment : Free Pascal 2.4.2, Windows XP
// Notes       : Overerft van TWobbelGridPanel. Implementeert een grid met
//               vrijwilligers. Feitelijk is een vrijwilliger in de huidige
//               opzet niet meer dan een account voor ionloggen in deze applicatie,
//               maar er blijft
//               de mogelijkheid om NAW gegevens later in te bouwen.
// Author      : Vincent Houtgraaf, Bunnik
// Date        : aug 2011
// Modified    :
//------------------------------------------------------------------------------
unit c_gridvrijwilliger;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  Controls, ExtCtrls, Buttons, Forms, Graphics,
  Grids,
  c_wobbelgridpanel;

type
TGridVrijwilliger = class(TWobbelGridPanel)
private

  FParent:TWinControl;
  FBeursId: integer;
  FBeursOmschrijving: string;

  procedure btnPostClick(Sender: TObject);
  procedure btnDeleteClick(Sender: TObject);
  procedure btnRefreshClick(Sender: TObject);
  procedure btnCancelClick(Sender: TObject);

  procedure GridValidateEntry(sender: TObject; aCol,
    aRow: Integer; const OldValue: string; var NewValue: String);

  function CheckGridValues(iRowToSkip:integer): boolean;

  procedure WobbelGridClick(Sender: TObject);

  procedure FillRolPicklist();
  function FindIdOfPicklistItemDescription(ARow:integer; out rolid:integer):boolean;

  function DeleteData(vrijwilligerid: integer):boolean;

  function PostData(vrijwilliger_id, rolid:integer; inhuidigebeurs:boolean;
           opmerkingen, inlognaam, wachtwoord: string): boolean;


public
  constructor CreateMe(AOwner: TComponent; AParent: TWInControl; ATop, ALeft, AHeight, BeursId:integer; BeursOmschrijving: string);
  destructor Destroy; override;

  procedure FillGrid;
  function AnyRowIsDirty: boolean;
  function PostData:boolean;

  property BeursId: integer read FBeursId write FBeursId;
  property BeursOmschrijving: string read FBeursOmschrijving write FBeursOmschrijving;
  procedure SetGridProps;

end;



implementation

uses
  ZDataset,
  Dialogs, LCLType,
  m_wobbeldata, m_querystuff, m_tools, m_error, c_appsettings;

constructor TGridVrijwilliger.CreateMe(AOwner: TComponent; AParent: TWinControl; ATop, ALeft, AHeight, BeursId:integer; BeursOmschrijving: string);
var
  navButs: TWobbelNavButtons;
begin
  if (BeursId <= 0) then
  begin
    MessageDlg('Wobbel', 'Er is geen beurs gekozen. Svp eerst een beurs kiezen', mtConfirmation,
              [mbYes],0);
    exit;
  end;

  FBeursId:=BeursId;
  FBeursOmschrijving:=BeursOmschrijving;
  FParent:=AParent;

  Titel:='Inlog accounts beheren';

  navButs:=[wbFirst, wbPrev, wbNext, wbLast, wbAdd, wbDelete, wbEdit, wbPost, wbCancel, wbRefresh];
  inherited Create(AOwner, AParent, ATop, ALeft, AHeight, navButs);

  SetGridProps;
  FillRolPicklist();

  if (WBPOST in navButs) then
  begin
    btnPost.OnClick:=@btnPostClick;
  end;
  if (WBDELETE in navButs) then
  begin
    btnDelete.OnClick:=@btnDeleteClick;
  end;
  if (WBREFRESH in navButs) then
  begin
    btnRefresh.OnClick:=@btnRefreshClick;
  end;
  if (WBCANCEL in navButs) then
  begin
    btnCancel.OnClick:=@btnCancelClick;
  end;

  WobbelGrid.OnValidateEntry:=@GridValidateEntry;
  WobbelGrid.OnClick:=@WobbelGridClick;

  self.SetGridHint('Geef in deze tabel aan welke gebruikersnaam/wachtwoord combinaties toegang hebben tot het Wobbel Kassa');

  FillGrid;
  SetGridStatus([WSENABLEDEDITABLE]);
end;

destructor TGridVrijwilliger.Destroy;
begin
  inherited Destroy;
end;

procedure TGridVrijwilliger.SetGridProps;
var
  index: integer;
  q:TZQuery;
  bVal:boolean;
  ml_vrijwilliger_id,ml_inlognaam,ml_wachtwoord,ml_opmerkingen,ml_rol: integer;
begin
  index:=-1;

  try
    ml_vrijwilliger_id:=10;
    ml_inlognaam:=255;
    ml_wachtwoord:=255;
    ml_opmerkingen:=255;
    ml_rol:=255;

    q := m_querystuff.GetSQLite3QueryMdb;
    q.SQL.Clear;

    q.SQL.Text:='select ' +
      ' v.vrijwilliger_id, ' +
      ' v.inlognaam, ' +
      ' v.wachtwoord, ' +
      ' v.opmerkingen, ' +
      ' v.nawid, ' +
      ' v.rolid, ' +
      ' r.omschrijving as rolomschrijving, ' +
      ' r.opmerkingen as rolopmerkingen ' +
      ' from vrijwilliger as v ' +
      ' left join rol as r on v.rolid = r.rol_id ' +
      ' limit 1';
    q.Open;
    ml_vrijwilliger_id:=m_tools.getMaxTableFieldSize('vrijwilliger_id', q);
    ml_inlognaam:=m_tools.getMaxTableFieldSize('inlognaam', q);
    ml_wachtwoord:=m_tools.getMaxTableFieldSize('wachtwoord', q);
    ml_opmerkingen:=m_tools.getMaxTableFieldSize('opmerkingen', q);
    ml_rol:=m_tools.getMaxTableFieldSize('rolomschrijving', q);
    q.Close;
  finally
    q.Free;
  end;



  //MessageOk('colcount vrijwilligers: ' + IntToStr(WobbelGrid.Columns.Count) + '; fixedcol:' + IntToStr(WobbelGrid.FixedCols));
  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='VrijwilligerId';
  WobbelGrid.Columns.Items[index].Visible:=false;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'vrijwilliger_id', [wtInteger], '', 1, ml_vrijwilliger_id, 'VrijwilligerId', 'interne unieke id van de vrijwilliger', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Inlognaam';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Title.Font.Color:=clRed;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=1;
  WobbelGrid.Columns.Items[index].MaxSize:=255;
  WobbelGrid.Columns.Items[index].Width:=100;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'inlognaam', [wtString], '', 1, ml_inlognaam, 'Inlognaam', 'naam om mee in te kunnen loggen', WobbelGrid.Columns.Items[index].Width, true));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Wachtwoord';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=0;
  WobbelGrid.Columns.Items[index].MaxSize:=255;
  WobbelGrid.Columns.Items[index].Width:=100;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'wachtwoord', [wtString], '', 0, ml_wachtwoord, 'Wachtwoord', 'wachtwoord om mee in te kunnen loggen. Mag leeg blijven', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Opmerkingen';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=0;
  WobbelGrid.Columns.Items[index].MaxSize:=255;
  WobbelGrid.Columns.Items[index].Width:=100;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'opmerkingen', [wtMemo], '', 0, ml_opmerkingen, 'Opmerkingen', 'bij de vrijwilliger', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='Rol';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Title.Font.Color:=clRed;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=0;
  WobbelGrid.Columns.Items[index].MaxSize:=255;
  WobbelGrid.Columns.Items[index].Width:=200;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'rolid', [wtString], '', 0, ml_rol, 'rolid', 'interne id van de rol die het account heeft', WobbelGrid.Columns.Items[index].Width, true));
  WobbelGrid.Columns.Items[index].ButtonStyle:=cbsPickList;

  inc(index);
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='In actuele beurs';
  WobbelGrid.Columns.Items[index].Title.Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].Alignment:=taCenter;
  WobbelGrid.Columns.Items[index].MinSize:=1;
  WobbelGrid.Columns.Items[index].MaxSize:=1;
  WobbelGrid.Columns.Items[index].Width:=110;
  WobbelGrid.Columns.Items[index].ButtonStyle:=cbsCheckboxColumn;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'connectedwithbeurs', [wtinteger], '1', 1, 1, 'In actuele beurs', 'aangevinkt als het account voor de actuele beurs ("'+FBeursOmschrijving+'") geldig is', WobbelGrid.Columns.Items[index].Width, false));

  inc(index);
  bVal:=AppSettings.Vrijwilliger.IsSuperAdmin;
  WobbelGrid.Columns.Add;
  WobbelGrid.Columns.Items[index].Title.Caption:='IsDirty';
  WobbelGrid.Columns.Items[index].Visible:=bVal;
  WobbelGrid.Columns.Items[index].ReadOnly:=true;
  lstColTypes.Add(TWobbelGridColumnProps.Create(index, 'isdirty', [wtInteger], '1', 1, 1, 'IsDirty', '', WobbelGrid.Columns.Items[index].Width, false));

end;

procedure TGridVrijwilliger.FillRolPicklist();
var
  q : TZQuery;
  s: string;
  iCol, iColCorrected: integer;
begin
  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('rolid');
  if (iCol < 0) then
  begin
    Raise EWobbelError.Create('Geen rolid kolom gevonden in account grid');
  end;
  iColCorrected:=iCol-WobbelGrid.FixedCols;

  try
    try
      q := m_querystuff.GetSQLite3QueryMdb;
      WobbelGrid.Columns.Items[iColCorrected].PickList.Clear;

      q.SQL.Clear;
      q.SQL.Text := 'select rol_id, omschrijving, opmerkingen from rol order by rol_id;';
      q.Open;
      while not q.Eof do
      begin
        s := MakePicklistItemDescription(q.FieldByName('omschrijving').AsString, q.FieldByName('opmerkingen').AsString);
        WobbelGrid.Columns.Items[iColCorrected].PickList.AddObject(s, TObject(q.FieldByName('rol_id').AsInteger));
        q.Next;
      end;

      q.Close;
    finally
      q.Free;
    end;
  except
    on E: Exception do
    begin
      MessageOk('Fout bij invulling rollen-picklist voor accounts: ' + E.Message);
    end;
  end;
end;

function TGridVrijwilliger.FindIdOfPicklistItemDescription(ARow:integer; out rolid:integer):boolean;
var
  iCol, iColCorrected: integer;
  rolDescription, sTest:string;
  ix:integer;
begin
  FindIdOfPicklistItemDescription:=true;
  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('rolid');
  iColCorrected:=iCol-WobbelGrid.FixedCols;
  rolDescription:=WobbelGrid.Cells[iCol,ARow];

  rolid:=-1;
  ix:=0;
  for ix:=0 to WobbelGrid.Columns.Items[iColCorrected].PickList.Count-1 do
  begin
    sTest:=WobbelGrid.Columns.Items[iColCorrected].PickList.Strings[ix];
    if (sTest = rolDescription) then
    begin
      rolid:=Integer(WobbelGrid.Columns.Items[iColCorrected].PickList.Objects[ix]);
      //MessageOk(sTest);
      break;
    end;
  end;
  if (rolid=-1) then
  begin
    FindIdOfPicklistItemDescription:=false;
    MessageError('De regel met rol "'+rolDescription+'" kan niet worden opgeslagen: de waarde is ongeldig. Kies een waarde uit de lijst!!');
  end;
end;

procedure TGridVrijwilliger.FillGrid;
var
  q: TZQuery;
  rowCounter: integer;
  colCounter: integer;
  ix: integer;
  s: string;
begin
  try
    try
      for ix:=WobbelGrid.RowCount-1 downto 1 do
      begin
        WobbelGrid.DeleteRow(ix);
      end;

      q := m_querystuff.GetSQLite3QueryMdb;
      q.SQL.Clear;

      q.SQL.Text:='select ' +
          ' v.vrijwilliger_id, ' +
          ' v.inlognaam, ' +
          ' v.wachtwoord, ' +
          ' v.opmerkingen, ' +
          ' v.nawid, ' +
          ' v.rolid, ' +
          ' r.omschrijving as rolomschrijving, ' +
          ' r.opmerkingen as rolopmerkingen, ' +
          ' case when bv.beursid is null or bv.beursid = '''' then 0 else 1 end as connectedwithbeurs ' +
          ' from vrijwilliger as v' +
          ' left join beurs_vrijwilliger as bv on v.vrijwilliger_id = bv.vrijwilligerid and bv.beursid=:BEURSID' +
          ' left join rol as r on v.rolid = r.rol_id';
      q.Params.ParamByName('BEURSID').AsInteger := FBeursId;
      q.Open;
      rowCounter:=WobbelGrid.FixedRows;
      while not q.Eof do
      begin
        if (WobbelGrid.RowCount <= rowCounter) then
        begin
          WobbelGrid.RowCount:=WobbelGrid.RowCount+1;
        end;

        colCounter:=WobbelGrid.FixedCols;
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('vrijwilliger_id').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('inlognaam').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('wachtwoord').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('opmerkingen').AsString;
        inc(colCounter);
        s := MakePicklistItemDescription(q.FieldByName('rolomschrijving').AsString, q.FieldByName('rolopmerkingen').AsString);
        WobbelGrid.Cells[colCounter,rowCounter]:=s;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:=q.FieldByName('connectedwithbeurs').AsString;
        inc(colCounter);
        WobbelGrid.Cells[colCounter,rowCounter]:='0';

        inc(rowCounter);
        q.Next;
      end;
      q.Close;

      self.SetFontSize(0);
    finally
      q.Free;
  end;
  except
    on E: Exception do
    begin
      MessageError('Fout bij vullen vrijwilligeraccount tabel vanuit de database: ' + E.Message);
    end;
  end;
end;


function TGridVrijwilliger.PostData(vrijwilliger_id, rolid:integer; inhuidigebeurs:boolean;
         opmerkingen, inlognaam, wachtwoord: string): boolean;
var
  q : TZQuery;
  vrijwilligeridCurrent: integer;
  sTmp: string;
  bRet:boolean;
begin
  bRet:=true;

  if (inlognaam = '') then
  begin
    PostData:=false;
    MessageError('Inlognaam moet een waarde hebben. De regel met een lege inlognaam wordt niet toegevoegd aan de database.');
    exit;
  end;

  try
    try
      vrijwilligeridCurrent:=vrijwilliger_id;

      q := m_querystuff.GetSQLite3QueryMdb;

      m_tools.OpenTransactie(dmWobbel.connWobbelMdb);
      q.SQL.Clear;

      if (vrijwilligeridCurrent >= 0) then
      begin
         q.SQL.Text:='update vrijwilliger set ' +
                     ' rolid=:ROLID, ' +
                     ' inlognaam=:INLOGNAAM, ' +
                     ' wachtwoord=:WACHTWOORD, ' +
                     ' opmerkingen=:OPMERKINGEN ' +
                     ' where vrijwilliger_id=:VRIJWILLIGER_ID';
         q.Params.ParamByName('ROLID').AsInteger := rolid;
         q.Params.ParamByName('INLOGNAAM').AsString := inlognaam;
         q.Params.ParamByName('WACHTWOORD').AsString := wachtwoord;
         q.Params.ParamByName('OPMERKINGEN').AsString := opmerkingen;
         q.Params.ParamByName('VRIJWILLIGER_ID').AsInteger := vrijwilligeridCurrent;
         q.ExecSQL();
       end
       else
       begin
         q.SQL.Text:='insert into vrijwilliger (' +
                     ' rolid, ' +
                     ' inlognaam, ' +
                     ' wachtwoord, ' +
                     ' opmerkingen' +
                     ' ) values(' +
                     ' :ROLID, ' +
                     ' :INLOGNAAM, ' +
                     ' :WACHTWOORD, ' +
                     ' :OPMERKINGEN)';
         q.Params.ParamByName('ROLID').AsInteger := rolid;
         q.Params.ParamByName('INLOGNAAM').AsString := inlognaam;
         q.Params.ParamByName('WACHTWOORD').AsString := wachtwoord;
         q.Params.ParamByName('OPMERKINGEN').AsString := opmerkingen;
         q.ExecSQL();
         q.Close;

         // lijkt niet te werken binnen een transactie
         //vrijwilligeridCurrent:=m_tools.GetIntValueFromDb(dmWobbel.connWobbelDdb, 'select last_insert_rowid() as maxid', 'maxid', 1);

         q.SQL.Clear;
         q.SQL.Text:='select max(vrijwilliger_id) as vrijwilligerid from vrijwilliger';
         q.Open;
         vrijwilligeridCurrent:=-1;
         while not q.Eof do
         begin
           sTmp:=q.FieldByName('vrijwilligerid').AsString;
           if (sTmp='') then
           begin
             vrijwilligeridCurrent:=1;
           end
           else
           begin
             vrijwilligeridCurrent:=StrToInt(sTmp);
           end;
           vrijwilligeridCurrent:=q.FieldByName('vrijwilligerid').AsInteger;
           break;
         end;
         q.Close;
         if (vrijwilligeridCurrent = -1) then
         begin
           Raise EWobbelError.Create('Invoerfout vrijwilliger');
         end;
       end;

       q.SQL.Clear;
       q.SQL.Text:='delete from beurs_vrijwilliger where ' +
                   ' beursid=:BEURSID and ' +
                   ' vrijwilligerid=:VRIJWILLIGERID';
       q.Params.ParamByName('BEURSID').AsInteger := FBeursId;
       q.Params.ParamByName('VRIJWILLIGERID').AsInteger := vrijwilligeridCurrent;
       q.ExecSQL();
       q.Close;
       if (inhuidigebeurs) then
       begin
         q.SQL.Clear;
         q.SQL.Text:='insert into beurs_vrijwilliger (' +
                     ' beursid, ' +
                     ' vrijwilligerid ' +
                     ' ) values(' +
                     ' :BEURSID, ' +
                     ' :VRIJWILLIGERID)';
         q.Params.ParamByName('BEURSID').AsInteger := FBeursId;
         q.Params.ParamByName('VRIJWILLIGERID').AsInteger := vrijwilligeridCurrent;
         q.ExecSQL();
         q.Close;
       end;

       dmWobbel.connWobbelMdb.ExecuteDirect('commit transaction');
    finally
      q.Free;
    end;
  except
    on E: Exception do
    begin
      bRet:=false;
      dmWobbel.connWobbelMdb.ExecuteDirect('rollback transaction');
      MessageError('Fout bij aanpassen data in de database: ' + E.Message);
    end;
  end;
  PostData:=bRet;
end;

function TGridVrijwilliger.PostData:boolean;
var
  iRow, iCol: integer;
  iRowStop:integer;
  vrijwilligerid:integer;
  bRet, bPostOk : boolean;
  postCount: integer;
  inhuidigebeurs:boolean;
  rolid:integer;
  sTest:string;
  invalidrowcount:integer;
begin
  bRet:=true;
  if (not CheckGridValues(-1)) then
  begin
    PostData:=false;
    exit;
  end;
  postCount:=0;
  invalidrowcount:=0;
  iRowStop:=WobbelGrid.RowCount-1;
  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('isdirty');
  for iRow:=WobbelGrid.FixedRows to iRowStop do
  begin
    if (WobbelGrid.Cells[iCol, iRow] = '1') then
    begin
      //MessageOk('isdirty:' + WobbelGrid.Cells[iCol, iRow]);
      vrijwilligerid:=-1;
      if (WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('vrijwilliger_id'), iRow] <> '') then
      begin
        vrijwilligerid:=StrToInt(WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('vrijwilliger_id'), iRow]);
      end;

      inhuidigebeurs:=false;
      sTest:=WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('connectedwithbeurs'), iRow];
      //MessageOk(sTest);
      if (sTest = '1') then
      begin
        inhuidigebeurs:=true;
      end;

      if (FindIdOfPicklistItemDescription(iRow, rolid)) then
      begin
        bPostOk:=PostData(
            vrijwilligerid,
            rolid,
            inhuidigebeurs,
            WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('opmerkingen'), iRow],
            WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('inlognaam'), iRow],
            WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('wachtwoord'), iRow]
            );
        if bPostOk then
        begin
          inc(postCount);
          WobbelGrid.Cells[FindWobbelGridColumnIndexByDatabaseFieldName('isdirty'),iRow]:='0';
        end
        else
        begin
          inc(invalidrowcount);
        end;
      end
      else
      begin
        inc(invalidrowcount);
      end;
      bRet:=bRet and bPostOk;
    end;
  end;
  if (postCount>0) then
  begin
    if (invalidrowcount>0) then
    begin
      MessageOk('De wijzigingen in de vrijwilliger-account gegevens zijn opgeslagen, behalve de regel(s) met ongeldige invoer.');
    end
    else
    begin
      MessageOk('Alle wijzigingen in de vrijwilliger-account gegevens zijn opgeslagen.');
    end;
    SetGridStatus([WSDISABLEDNOTEDITABLE]);

    if (WobbelGrid.IsVisible) then
    begin
      if (WobbelGrid.Enabled) then
      begin
        WobbelGrid.SetFocus;
      end;
      FillGrid;
    end;
  end;
  PostData:=bRet;
end;

function TGridVrijwilliger.AnyRowIsDirty: boolean;
var
  iRow, iCol: integer;
  iRowStop:integer;
  bRet: boolean;
begin
  bRet:=false;
  iRowStop:=WobbelGrid.RowCount-1;
  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('isdirty');
  if (iCol>=0) then
  begin
    for iRow:=WobbelGrid.FixedRows to iRowStop do
    begin
        if (WobbelGrid.Cells[iCol, iRow] = '1') then
        begin
          bRet:=true;
          break;
        end;
    end;
  end;
  AnyRowIsDirty:=bRet;
end;


procedure TGridVrijwilliger.GridValidateEntry(sender: TObject; aCol,
  aRow: Integer; const OldValue: string; var NewValue: String);
var
  iCol:integer;
begin
  if (WobbelGridValidateCellentry(aCol, aRow, OldValue, NewValue)) then
  begin
    iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('isdirty');
    if (iCol >= 0) then
    begin
      WobbelGrid.Cells[iCol,WobbelGrid.Row]:='1';
    end;
  end;
end;

// extra actie nodig voor checkboxkolommen
procedure TGridVrijwilliger.WobbelGridClick(Sender: TObject);
var
  iCol:integer;
begin
  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('connectedwithbeurs');
  if (WobbelGrid.Col = iCol) then
  begin
    iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('isdirty');
    if (iCol >= 0) then
    begin
      WobbelGrid.Cells[iCol,WobbelGrid.Row]:='1';
    end;
  end;
end;

function TGridVrijwilliger.CheckGridValues(iRowToSkip:integer): boolean;
var
  iRow: integer;
  iRowStop:integer;
  uniekList:TStringList;
  iColUniek: integer;
  sTest:string;
  uniekIndexInList:integer;
  uniekDubbelCount:integer;
  bRet:boolean;
begin
  bRet:=true;
  try
    uniekList:=TStringList.Create;

    uniekDubbelCount:=0;
    iRowStop:=WobbelGrid.RowCount-1;
    iColUniek:=FindWobbelGridColumnIndexByDatabaseFieldName('inlognaam');
    //messageOk(TWobbelGridColumnProps(lstColTypes.Items[FindWobbelGridColumnIndexByColIndex(WobbelGrid.Col)]).ColNaam);

    if (iRowToSkip >= 0) then
    begin
      MessageOk(WobbelGrid.Cells[iColUniek,iRowToSkip]);
    end;
    for iRow:=WobbelGrid.FixedRows to iRowStop do
    begin
      if (iRow <> iRowToSkip) then
      begin
        sTest:=WobbelGrid.Cells[iColUniek, iRow];
        if (uniekList.Find(sTest, uniekIndexInList)) then
        begin
          inc(uniekDubbelCount);
        end;
        uniekList.Add(sTest);
      end;
    end;

    CheckGridValues:=true;
    if (uniekDubbelCount>0) then
    begin
      bRet:=false;
      MessageOk('Kassanr moet uniek zijn per beurs. De waarden worden zo niet opgeslagen in de database. Kies een andere waarde svp.');
    end;

  finally
    if (uniekList<>nil) then
    begin
      uniekList.Free;
      uniekList:=nil;
    end;
  end;
  CheckGridValues:=bRet;
end;


function TGridVrijwilliger.DeleteData(vrijwilligerid: integer):boolean;
var
  q : TZQuery;
  isOk: boolean;
begin
  isOk:=true;

  try
    try
      q := m_querystuff.GetSQLite3QueryMdb;
      m_tools.OpenTransactie(dmWobbel.connWobbelMdb);

      q.SQL.Clear;
      q.SQL.Text := 'delete from beurs_vrijwilliger where vrijwilligerid=:VRIJWILLIGERID;';
      q.Params.ParamByName('VRIJWILLIGERID').AsInteger := vrijwilligerid;
      q.ExecSQL;

      q.SQL.Clear;
      q.SQL.Text := 'delete from vrijwilliger where vrijwilliger_id=:VRIJWILLIGERID;';
      q.Params.ParamByName('VRIJWILLIGERID').AsInteger := vrijwilligerid;
      q.ExecSQL;

    finally
      q.Free;
      dmWobbel.connWobbelMdb.ExecuteDirect('commit transaction');
      DeleteData:=isOk;
    end;
  except
    on E: Exception do
    begin
      isOk:=false;
      dmWobbel.connWobbelMdb.ExecuteDirect('rollback transaction');
      MessageError('Fout bij verwijderen vrijwilliger: ' + E.Message);
    end;
  end;
  DeleteData:=isOk;
end;


procedure TGridVrijwilliger.btnPostClick(Sender: TObject);
begin
  PostData;
end;

procedure TGridVrijwilliger.btnDeleteClick(Sender: TObject);
var
  vrijwilligerid: integer;
  sVrijwilligerid: string;
  iCol:integer;
  sInlognaam:string;
begin
  if (not CheckGridValues(WobbelGrid.Row)) then
  begin
    exit;
  end;
  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('vrijwilliger_id');
  if (iCol < 0) then
  begin
    Raise EWobbelError.Create('Geen vrijwilliger_id kolom gevonden');
  end;
  sVrijwilligerid:=WobbelGrid.Cells[iCol, WobbelGrid.Row];

  sInlognaam:='';
  iCol:=FindWobbelGridColumnIndexByDatabaseFieldName('inlognaam');
  if (iCol >= 0) then
  begin
    sInlognaam:=WobbelGrid.Cells[iCol, WobbelGrid.Row];
  end;

  if (sVrijwilligerid <> '') then
  begin
    vrijwilligerid:=StrToInt(sVrijwilligerid);
    if MessageDlg('Wobbel', 'Weet u zeker dat u het account "' + sInlognaam + '" wilt verwijderen?', mtConfirmation,
       [mbYes, mbNo],0) = mrYes
    then
    begin
      if (DeleteData(vrijwilligerid)) then
      begin
        MessageOk('Account "' + sInlognaam + '" is verwijderd');
        FillGrid;
      end;
    end;
  end
  else
  begin
    //MessageError('Deze verkoper is nog niet in de database ingevoerd');
    WobbelGrid.DeleteRow(WobbelGrid.Row);
    FillGrid;
  end;
end;

procedure TGridVrijwilliger.btnRefreshClick(Sender: TObject);
begin
  FillGrid;
end;

procedure TGridVrijwilliger.btnCancelClick(Sender: TObject);
begin
  SetGridStatus([WSDISABLEDNOTEDITABLE]);
  FillGrid;
end;



end.

