unit unitMainClockForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Spin, Buttons, IniFiles, lclintf, Menus, ComCtrls, {MouseAndKeyInput,} LCLType, Types, FileUtil;

type

  { TClockForm }

  TClockForm = class(TForm)
    BackgroundColorButton: TColorButton;
    cbxDateVisible: TCheckBox;
    cbxTimeVisible: TCheckBox;
    cbxSplitterVisible: TCheckBox;
    cmbFormStyle: TComboBox;
    cmbDateFontFace: TComboBox;
    cmbTimeFormat: TComboBox;
    cmbDateFormat: TComboBox;
    cmbTimeFontFace: TComboBox;
    cmbSchemes: TComboBox;
    DateBackgroundColor: TColorButton;
    ClockPanel: TPanel;
    lblFormStyle: TLabel;
    lblFormStyle1: TLabel;
    lblSchemes: TLabel;
    mniShowHideClock: TMenuItem;
    mnuPrefs: TMenuItem;
    btnSaveScheme: TSpeedButton;
    TimeDateSplitterColor: TColorButton;
    edtDateFontSize: TSpinEdit;
    DateFontColor: TColorButton;
    lblSplitterColor: TLabel;
    lblDateFontSize: TLabel;
    lblDateTimeFormatHelp2: TLabel;
    lblDateBgColor: TLabel;
    lblDateFontColor: TLabel;
    lblDateFormat: TLabel;
    tabGeneral: TTabSheet;
    TimeDateSplitter: TSplitter;
    TimeDateMainPanel: TPanel;

    edtFontSize: TSpinEdit;
    FontColorButton: TColorButton;
    lblTimeFormat: TLabel;
    lblTimeFontColor: TLabel;
    Label3: TLabel;
    lblTimeBgColor: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    lblDateTimeFormatHelp: TLabel;
    lblDateTimeFormatHelp1: TLabel;
    MainMenu: TMainMenu;
    pgctrlPrefs: TPageControl;
    DatePanel: TPanel;
    SettingsPanel: TPanel;
    tabDate: TTabSheet;
    tabTime: TTabSheet;
    Timer1: TTimer;

    {$IFDEF DARWIN}
    AppMenu     : TMenuItem;
    AppAboutCmd : TMenuItem;
    AppSep1Cmd  : TMenuItem;
    AppPrefCmd  : TMenuItem;
    trackbarTransparency: TTrackBar;

    procedure AboutCmdClick(Sender: TObject);
    procedure cmbSchemesChange(Sender: TObject);
    {$ENDIF}
    procedure ReloadSchemes();
    procedure LoadSettingsFromFile(FilePath: String; ChangePosition: Boolean = true);
    procedure SaveSettingsToFile(FilePath: String);
    procedure BackgroundColorButtonColorChanged(Sender: TObject);
    procedure btnSaveSchemeClick(Sender: TObject);
    procedure cbxDateVisibleChange(Sender: TObject);
    procedure cbxSplitterVisibleChange(Sender: TObject);
    procedure cbxTimeVisibleChange(Sender: TObject);
    procedure ClockPanelDblClick(Sender: TObject);
    procedure ClockPanelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ClockPanelMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ClockPanelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ClockPanelMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure ClockPanelMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure cmbFormStyleChange(Sender: TObject);
    procedure cmbTimeDateFontFaceChange(Sender: TObject);
    procedure DateBackgroundColorColorChanged(Sender: TObject);
    procedure DateFontColorColorChanged(Sender: TObject);
    procedure DatePanelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DatePanelMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure edtDateFontSizeChange(Sender: TObject);
    procedure FontColorButtonColorChanged(Sender: TObject);
    procedure edtFontSizeChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lblDateTimeFormatHelpClick(Sender: TObject);
    procedure mniShowHideClockClick(Sender: TObject);
    procedure mniShowHideDateClick(Sender: TObject);
    procedure mnuPrefsClick(Sender: TObject);
    procedure TimeDateSplitterColorColorChanged(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure trackbarTransparencyChange(Sender: TObject);
  private
    FSC_MOVE: Boolean;
    FLastX,
      FLastY: Integer;
  public

  end;

var
  ClockForm: TClockForm;

implementation
{$R *.lfm}

{ TClockForm }

{$IFDEF DARWIN}
procedure TClockForm.AboutCmdClick(Sender: TObject);
begin
     ShowMessage('TfnClock was made by Jim Kinsman, see boltquiz.org How many Lightning Bolts do you deserve?');
end;

procedure TClockForm.cmbSchemesChange(Sender: TObject);
begin
    LoadSettingsFromFile(GetUserDir + '.' + ExtractFileName(ParamStr(0)) + '/Schemes/' + cmbSchemes.Text, false);
end;

{$ENDIF}

procedure TClockForm.LoadSettingsFromFile(FilePath: String; ChangePosition: Boolean = true);
var
  Sett : TIniFile;
  s : String;
begin
   If FileExists(FilePath) then
    begin
    //Load from INI
     Sett := TIniFile.Create(FilePath);

     Width := Sett.ReadInteger('MainForm','Width', 218);
     Height := Sett.ReadInteger('MainForm','Height', 230);
     if (ChangePosition) then
      begin
       Left := Sett.ReadInteger('MainForm','Left', 0);
       Top := Sett.ReadInteger('MainForm','Top', 0);
     end;

     s := Sett.ReadString('MainForm', 'FormStyle', 'fsStayOnTop');
     Case s of
       'fsNormal':
       begin
         FormStyle := fsNormal;
         cmbFormStyle.ItemIndex := 1;

       end;
       'fsStayOnTop':
       begin
         FormStyle := fsStayOnTop;
         cmbFormStyle.ItemIndex := 0;
       end;
     end;

     cmbTimeFontFace.Text := Sett.ReadString('Main', 'TimeFontFace', 'default');
     cmbDateFontFace.Text := Sett.ReadString('Main', 'DateFontFace', 'default');
     cmbTimeDateFontFaceChange(cmbTimeFontFace);
     cmbTimeDateFontFaceChange(cmbDateFontFace);

     cmbTimeFormat.Text := Sett.ReadString('Main', 'TimeFormat', 'hh":"nn":"ss');
     cmbDateFormat.Text := Sett.ReadString('Main', 'DateFormat', 'ddd mmm dd yyy');
     Timer1Timer(nil);

     edtFontSize.Value := Sett.ReadInteger('Main', 'ClockFontSize', 33);
     edtFontSizeChange(nil);

     edtDateFontSize.Value := Sett.ReadInteger('Main','DateFontSize', 11);
     edtDateFontSizeChange(nil);

     BackgroundColorButton.ButtonColor := StringToColor(Sett.ReadString('Main', 'ClockBackgroundColor', 'clDefault'));
     BackgroundColorButtonColorChanged(nil);

     DateBackgroundColor.ButtonColor := StringToColor(Sett.ReadString('Main', 'DateBackgroundColor', 'clDefault'));
     DateBackgroundColorColorChanged(nil);

     FontColorButton.ButtonColor := StringToColor(Sett.ReadString('Main', 'ClockFontColor', 'clBlack'));
     FontColorButtonColorChanged(nil);

     DateFontColor.ButtonColor := StringToColor(Sett.ReadString('Main', 'DateFontColor', 'clBlack'));
     DateFontColorColorChanged(nil);

     cbxTimeVisible.Checked := Sett.ReadBool('Main', 'TimeVisible', true);
     cbxTimeVisibleChange(nil);

     cbxDateVisible.Checked := Sett.ReadBool('Main', 'DateVisible', true);
     cbxDateVisibleChange(nil);

     SettingsPanel.Visible := Sett.ReadBool('Main', 'SettingsPanelVisible', true);

     TimeDateSplitter.Color := StringToColor(Sett.ReadString('Main', 'TimeDateSplitterColor', 'clDefault'));
     TimeDateSplitterColor.ButtonColor := TimeDateSplitter.Color;
     cbxSplitterVisible.Checked := Sett.ReadBool('Main', 'SplitterVisible', TimeDateSplitter.Visible);
     cbxSplitterVisibleChange(cbxSplitterVisible);

     TimeDateSplitter.Top := Sett.ReadInteger('Main','TimeDateSplitterTop', 208);

     trackbarTransparency.Position := Sett.ReadInteger('MainForm','Transparency', 0);
     trackbarTransparencyChange(nil);

     Sett.Free;

    end;
end;

procedure TClockForm.FormCreate(Sender: TObject);
var
  Sett : TIniFile;
  s : String;
begin
  FSC_MOVE := False;

  cmbTimeFontFace.Items.Assign(Screen.Fonts);
  cmbDateFontFace.Items.Assign(Screen.Fonts);

  LoadSettingsFromFile(GetUserDir + '.' + ExtractFileName(ParamStr(0)) + '/Schemes/LastUsed.ini', true);

  {$IFDEF DARWIN}
  AppMenu := TMenuItem.Create(Self);  {Application menu}
  AppMenu.Caption := #$EF#$A3#$BF;  {Unicode Apple logo char}
  MainMenu.Items.Insert(0, AppMenu);

  AppAboutCmd := TMenuItem.Create(Self);
  AppAboutCmd.Caption := 'About ' + Application.Name;  //<== BundleName set elsewhere
  AppAboutCmd.OnClick := @AboutCmdClick;
  AppMenu.Add(AppAboutCmd);  {Add About as item in application menu}

  AppSep1Cmd := TMenuItem.Create(Self);
  AppSep1Cmd.Caption := '-';
  AppMenu.Add(AppSep1Cmd);


  //AppPrefCmd := TMenuItem.Create(Self);
  //AppPrefCmd.Caption := 'Preferences...';
  //AppPrefCmd.Shortcut := ShortCut(VK_OEM_COMMA, [ssMeta]);
  //AppPrefCmd.OnClick := OptionsCmdClick;  //<== "Options" on other platforms
  //AppMenu.Add(AppPrefCmd);
  {$ENDIF}

  pgctrlPrefs.ActivePageIndex := 0;
  ReloadSchemes();
end;
procedure TClockForm.ReloadSchemes();
var
  ListOfFiles: TStringList;
  Attributes: Integer;
  cbx1 : Integer;
  i : Integer;
begin
  cbx1 :=1;
  Attributes := faReadOnly;
  if cbx1 = 1 then
    Attributes := Attributes or faHidden;
  ListOfFiles := TStringList.Create;
  try
    FileUtil.FindAllFiles(ListOfFiles, GetUserDir + '.' + ExtractFileName(ParamStr(0))+'/Schemes/', '*.ini', False, Attributes);
    //ListOfFiles.Insert(0, Format('The directory contains %d file(s).', [ListOfFiles.Count]));
    for i := 0 to ListOfFiles.Count-1 do
    begin
      ListOfFiles.Strings[i] := ExtractFileName(ListOfFiles.Strings[i]);
    end;
  finally
    cmbSchemes.Items.Assign(ListOfFiles);
    ListOfFiles.Free;
  end;
end;

procedure TClockForm.SaveSettingsToFile(FilePath: String);
var
  Sett : TIniFile;
  s : String;
begin
   //write to INI
   Sett := TIniFile.Create(FilePath);

   //Time
   Sett.WriteString('Main', 'TimeFormat', cmbTimeFormat.Text);
   Sett.WriteInteger('Main', 'ClockFontSize', edtFontSize.Value);
   Sett.WriteString('Main', 'ClockBackgroundColor', ColorToString(BackgroundColorButton.ButtonColor));
   Sett.WriteString('Main', 'ClockFontColor', ColorToString(FontColorButton.ButtonColor));
   Sett.WriteBool('Main','TimeVisible', cbxTimeVisible.Checked);
   Sett.WriteString('Main', 'TimeFontFace', ClockPanel.Font.Name);

   //Date
   Sett.WriteString('Main', 'DateFormat', cmbDateFormat.Text);
   Sett.WriteInteger('Main', 'DateFontSize', edtDateFontSize.Value);
   Sett.WriteString('Main', 'DateBackgroundColor', ColorToString(DateBackgroundColor.ButtonColor));
   Sett.WriteString('Main', 'DateFontColor', ColorToString(DateFontColor.ButtonColor));
   Sett.WriteBool('Main','DateVisible', cbxDateVisible.Checked);
   Sett.WriteString('Main', 'DateFontFace', DatePanel.Font.Name);

   Sett.WriteInteger('MainForm','Width', Width);
   Sett.WriteInteger('MainForm','Height', Height);
   Sett.WriteInteger('MainForm','Left', Left);
   Sett.WriteInteger('MainForm','Top', Top);

   WriteStr(s, FormStyle);
   Sett.WriteString('MainForm', 'FormStyle', s);
   Sett.WriteInteger('MainForm', 'Transparency', trackbarTransparency.Position);

   Sett.WriteBool('Main', 'SettingsPanelVisible', SettingsPanel.Visible);

   Sett.WriteString('Main', 'TimeDateSplitterColor', ColorToString(TimeDateSplitter.Color));
   Sett.WriteInteger('Main', 'TimeDateSplitterTop', TimeDateSplitter.Top);
   Sett.WriteBool('Main', 'SplitterVisible', TimeDateSplitter.Visible);
   Sett.Free;
end;

procedure TClockForm.FormDestroy(Sender: TObject);
begin
   SaveSettingsToFile(GetUserDir + '.' + ExtractFileName(ParamStr(0)) + '/Schemes/LastUsed.ini');
end;

procedure TClockForm.lblDateTimeFormatHelpClick(Sender: TObject);
begin
    OpenURL('https://www.freepascal.org/docs-html/rtl/sysutils/formatchars.html');
end;

procedure TClockForm.mniShowHideClockClick(Sender: TObject);
begin
   ClockPanelDblClick(nil);
end;

procedure TClockForm.mniShowHideDateClick(Sender: TObject);
begin
  ClockPanelDblClick(nil);
end;

procedure TClockForm.mnuPrefsClick(Sender: TObject);
begin

end;

procedure TClockForm.TimeDateSplitterColorColorChanged(Sender: TObject);
begin
  TimeDateSplitter.Color := TimeDateSplitterColor.ButtonColor;
end;



procedure TClockForm.Timer1Timer(Sender: TObject);
begin
   try
     ClockPanel.Caption:= FormatDateTime(cmbTimeFormat.Text, Now);
   Except
     On Exception Do
     begin
        ClockPanel.Caption := 'Format Error';
     end;
   end;

   try
     DatePanel.Caption:= FormatDateTime(cmbDateFormat.Text, Now);
   Except
     On Exception Do
     begin
        DatePanel.Caption := 'Format Error';
     end;
   end;

   if (DatePanel.Visible) and (ClockPanel.Visible) and (TimeDateSplitter.Top > TimeDateMainPanel.Height - 10) then
       TimeDateSplitter.Top := 208;
end;

procedure TClockForm.trackbarTransparencyChange(Sender: TObject);
begin
  if (trackbarTransparency.Position = 0) then
  begin
      ClockForm.AlphaBlend:= false;
  end else
  begin
     ClockForm.AlphaBlend := true;
     ClockForm.AlphaBlendValue := 255 - trackbarTransparency.Position;
  end;
end;

procedure TClockForm.BackgroundColorButtonColorChanged(Sender: TObject);
begin
   ClockPanel.Color := BackgroundColorButton.ButtonColor;
end;

procedure TClockForm.btnSaveSchemeClick(Sender: TObject);
begin
  //first, remove all .ini from the name
  cmbSchemes.Text := StringReplace(cmbSchemes.Text,'.ini','', [rfReplaceAll]);
  if cmbSchemes.Text <> '' then
   begin
      SaveSettingsToFile(GetUserDir + '.' + ExtractFileName(ParamStr(0))+'/Schemes/'+cmbSchemes.Text+'.ini');
      ReloadSchemes();
   end;
end;

procedure TClockForm.cbxDateVisibleChange(Sender: TObject);
begin
  DatePanel.Visible := cbxDateVisible.Checked;
end;

procedure TClockForm.cbxSplitterVisibleChange(Sender: TObject);
begin
  TimeDateSplitter.Visible := TCheckBox(Sender).Checked;
end;

procedure TClockForm.cbxTimeVisibleChange(Sender: TObject);
begin
  ClockPanel.Visible := cbxTimeVisible.Checked;
end;

procedure TClockForm.ClockPanelDblClick(Sender: TObject);
begin
   SettingsPanel.Visible := not SettingsPanel.Visible;
end;

procedure TClockForm.ClockPanelMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FSC_MOVE := True;
  FLastX := X;
  FLastY := Y;
end;

procedure TClockForm.ClockPanelMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if FSC_MOVE then
  begin
    Self.Left := Self.Left + X - FLastX;
    Self.Top  := Self.Top + Y - FLastY;
  end;
end;

procedure TClockForm.ClockPanelMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FSC_MOVE := False;
end;

procedure TClockForm.ClockPanelMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
   edtFontSize.Value := edtFontSize.Value - 1;
   edtFontSizeChange(nil);
end;

procedure TClockForm.ClockPanelMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  edtFontSize.Value := edtFontSize.Value + 1;
  edtFontSizeChange(nil);
end;

procedure TClockForm.cmbFormStyleChange(Sender: TObject);
var
  fs : String;
begin
  fs := 'fs'+StringReplace(cmbFormStyle.Text,' ','', [rfReplaceAll]);
  case fs of
    'fsStayOnTop': ClockForm.FormStyle := fsStayOnTop;
    'fsNormal': ClockForm.FormStyle := fsNormal;
  end;
end;

procedure TClockForm.cmbTimeDateFontFaceChange(Sender: TObject);
begin
   if (Sender = cmbTimeFontFace) then
   begin
       ClockPanel.Font.Name := TComboBox(Sender).Text;
   end else
   begin
      if (Sender = cmbDateFontFace) then
       DatePanel.Font.Name := TComboBox(Sender).Text;
   end;
end;

procedure TClockForm.DateBackgroundColorColorChanged(Sender: TObject);
begin
    DatePanel.Color := DateBackgroundColor.ButtonColor;
end;

procedure TClockForm.DateFontColorColorChanged(Sender: TObject);
begin
  DatePanel.Font.Color := DateFontColor.ButtonColor;
end;

procedure TClockForm.DatePanelMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ctrl: TControl;
  pt: TPoint;
begin
  Self.Hide;
  ctrl := nil;
  pt := ScreenToClient(Mouse.CursorPos);
  // here I do something wrong
//  ctrl := ControlAtPos(Mouse.CursorPos, [capfRecursive, capfAllowWinControls]);
  ctrl := ControlAtPos(pt, [capfRecursive, capfAllowWinControls]);
  // ctrl is always nil :-(
  if (ctrl <> nil) then
    begin
//      LCLSendMouseDownMsg(ctrl, SmallInt(X), SmallInt(Y), Button, Shift);
//      LCLSendMouseUpMsg(ctrl, SmallInt(X), SmallInt(Y), Button, Shift);
        //MouseInput.Click(Button,[],pt.X,pt.Y);
      //LCLSendMouseDownMsg(ctrl, SmallInt(pt.X), SmallInt(pt.Y), Button, Shift);
      //LCLSendMouseUpMsg(ctrl, SmallInt(pt.X), SmallInt(pt.Y), Button, Shift);
    end;
  Self.Show;
end;

procedure TClockForm.DatePanelMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  if (WheelDelta > 0) then
   begin
     edtDateFontSize.Value := edtDateFontSize.Value + 1;
   end
  else
  begin
     edtDateFontSize.Value := edtDateFontSize.Value - 1;
  end;

  edtDateFontSizeChange(nil);
end;

procedure TClockForm.edtDateFontSizeChange(Sender: TObject);
begin
  DatePanel.Font.Size := edtDateFontSize.Value;
end;

procedure TClockForm.FontColorButtonColorChanged(Sender: TObject);
begin
   ClockPanel.Font.Color := FontColorButton.ButtonColor;
end;

procedure TClockForm.edtFontSizeChange(Sender: TObject);
begin
  ClockPanel.Font.Size := edtFontSize.Value;
end;

procedure TClockForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Self.Show;
  CloseAction := caFree;
end;

end.

