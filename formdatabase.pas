unit formdatabase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Spin, Buttons, c_appsettings;

type

  { TfrmDatabase }

  TfrmDatabase = class(TForm)
    btnDBBackup: TButton;
    btnFindDatabase: TButton;
    btnFindDatabaseExtraBackupLocatie: TButton;
    btnInfo01: TBitBtn;
    btnMaakBackupNu: TButton;
    grbDatabaseBackupInterval: TGroupBox;
    grbKiesDatabase: TGroupBox;
    grpDatabaseExtraBackupLocatie: TGroupBox;
    lblDBBackup: TLabel;
    speDBBackup: TSpinEdit;
    txtDatabaseExtraBackupDirectory: TEdit;
    txtDatabasefilename: TEdit;
    procedure btnDBBackupClick(Sender: TObject);
    procedure btnFindDatabaseClick(Sender: TObject);
    procedure btnFindDatabaseExtraBackupLocatieClick(Sender: TObject);
    procedure btnMaakBackupNuClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmDatabase: TfrmDatabase;

implementation

uses
  Crt, IniFiles, m_tools, m_constant, m_wobbeldata;

{$R *.lfm}

{ TfrmDatabase }

procedure TfrmDatabase.btnFindDatabaseClick(Sender: TObject);
var
  oldName:string;
begin
  try
    oldName:=txtDatabasefilename.Text;
    txtDatabasefilename.Text:=GetNewDatabaseFile;
    if (oldName <> txtDatabasefilename.Text) then
    begin
      MessageOk('De wijzigingen zijn opgeslagen');
    end;
  except
    on E: Exception do
    begin
        MessageError('Foutmelding: ' + E.Message);
    end;
  end;
end;

procedure TfrmDatabase.btnFindDatabaseExtraBackupLocatieClick(Sender: TObject);
var
  isOk:boolean;
  FileVar: TextFile;
  dirName,fName:string;

begin
  try
    isOk:=false;
    dmWobbel.dlgSelectDatabaseExtraBackupDirectory.FileName:=txtDatabaseExtraBackupDirectory.Text;
    while not isOk do
    begin
      if dmWobbel.dlgSelectDatabaseExtraBackupDirectory.Execute then
      begin
        dirName:=dmWobbel.dlgSelectDatabaseExtraBackupDirectory.Filename;
        isOk:=DirectoryExists(dirName);
        if (isOk) then
        begin
          // test of de directory beschrijfbaar is
          fName:=dirName+DirectorySeparator+'test_'+FormatDateTime('mmdd_hhnnss',Now)+'.txt';
          while (FileExists(fName)) do
          begin
            fName:=dirName+DirectorySeparator+'test_'+FormatDateTime('mmdd_hhnnss',Now)+'.txt';
            Delay(1000);
          end;
          try
            try
              AssignFile(FileVar, fName);
              Rewrite(FileVar);
              Writeln(FileVar,'Hello');
            finally
              CloseFile(FileVar);
            end;
          except
            on E: Exception do
            begin
              isOk:=false;
              MessageError('Deze directory is niet beschrijfbaar: ' + E.Message);
            end;
          end;
        end;
        if (isOk) then
        begin
          txtDatabaseExtraBackupDirectory.Text:=dirName;
          m_tools.SetValueInIniFile('INIT','DirectoryVoorExtraDatabaseBackup',dirName);
        end;
      end
      else
      begin
        break;
      end;
    end;

    MessageOk('De wijzigingen zijn opgeslagen');
  except
    on E: Exception do
    begin
        MessageError('Foutmelding: ' + E.Message);
    end;
  end;
end;

procedure TfrmDatabase.btnMaakBackupNuClick(Sender: TObject);
var
  sRet: string;
  sOut1,sOut2:string;
begin
  try
    sRet:=BackupDatabaseFile(sOut1,sOut2);
    if (sRet <> '') then
    begin
      MessageOk('Backup in "'+sRet+'"');
    end;
  except
    on E: Exception do
    begin
        MessageError('Foutmelding: ' + E.Message);
    end;
  end;
end;

procedure TfrmDatabase.btnDBBackupClick(Sender: TObject);
var
  Ini:TINIFile;
begin
  try
    try
      Ini := TINIFile.Create(GetDefaultWobbelInifilename);
      INI.WriteInteger('INIT','MaxAantalTransactiesNaLaatsteBackup',speDBBackup.Value);
    finally
      Ini.Free;
    end;
    MessageOk('De wijzigingen zijn opgeslagen');
  except
    on E: Exception do
    begin
        MessageError('Foutmelding: ' + E.Message);
    end;
  end;
end;

procedure TfrmDatabase.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
//
end;

procedure TfrmDatabase.FormActivate(Sender: TObject);
var
  Ini:TINIFile;
begin
  m_tools.CloseOtherScreens(self);

  try
    Ini := TINIFile.Create(GetDefaultWobbelInifilename);
    speDBBackup.Value:=INI.ReadFloat('INIT','MaxAantalTransactiesNaLaatsteBackup',c_defaultMaxAantalTransactiesNaLaatsteBackup);

    txtDatabaseExtraBackupDirectory.Text:=INI.ReadString('INIT','DirectoryVoorExtraDatabaseBackup','');

  finally
    Ini.Free;
  end;

  self.Color:=AppSettings.GlobalBackgroundColor;
  self.Font.Size:=m_tools.GetIntegerFromIniFile('FONTS','GlobalFontsize',c_defaultFontsize);

  txtDatabasefilename.Text:=dmWobbel.connWobbelMdb.Database;

  btnFindDatabase.Enabled:=AppSettings.Vrijwilliger.VrijwilligerIsAdmin;
  txtDatabasefilename.Enabled:=btnFindDatabase.Enabled;
  btnMaakBackupNu.Enabled:=AppSettings.Vrijwilliger.VrijwilligerIsIngelogd;

  btnDBBackup.Enabled:=AppSettings.Vrijwilliger.VrijwilligerIsAdmin;
  speDBBackup.Enabled:=btnDBBackup.Enabled;

  btnFindDatabaseExtraBackupLocatie.Enabled:=AppSettings.Vrijwilliger.VrijwilligerIsAdmin;
  txtDatabaseExtraBackupDirectory.Enabled:=btnFindDatabaseExtraBackupLocatie.Enabled;
end;


procedure TfrmDatabase.FormCreate(Sender: TObject);
begin
  btnFindDatabase.Hint:='Selecteer het te gebruiken databasebestand.';
  btnDBBackup.Hint:='Geef hier aan om de hoeveel ingevoerde / gewijzigde transacties een backup van de database dient te worden gemaakt.'+c_CR+
                    'De backupbestanden hebben dezelfde naam als de geselecteerde database met een datum / tijd toevoeging in de naam.';
  btnMaakBackupNu.Hint:='Maak een backup van de database. De gemaakte backups worden aangegeven bij succes.';
  btnFindDatabaseExtraBackupLocatie.Hint:='In de folder die hier wordt ingesteld worden extra backups gemaakt van de database, op dezelfde momenten als wanneer in de hoofdfolder wordt gebackupt.'+c_CR+
                                          'Tip: geef hier een lokatie op die zo mogelijk op een ander schijf staat als de hoofdfolder.';
  btnInfo01.Hint:='Instellingen voor de database.';
end;

procedure TfrmDatabase.FormDestroy(Sender: TObject);
begin

end;

procedure TfrmDatabase.FormDeactivate(Sender: TObject);
begin
  // om te voorkomen dat de knoppen van het onderliggende scherm doorschijnen
  Delay(m_constant.c_DeactiveDelay_msec);
  Application.ProcessMessages;
end;


end.

