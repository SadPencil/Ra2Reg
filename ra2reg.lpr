program ra2reg;

{$mode objfpc}{$H+}

uses
  Classes,
  Registry,
  SysUtils,
  Windows,
  getopts;

const
  KEY_WOW64_64KEY = $0100;
  SM_CXSCREEN = 0; // width
  SM_CYSCREEN = 1; // height                  
  MB_OK = $00000000;
  MB_ICONINFORMATION = $00000040;
var
  optShowHelp: bool = False;
  optShowMsgBox: bool = True;
  optWriteRa2Ini: bool = False; // True for a fresh install
  optWriteWoldataKey: bool = True;
  optSetCompatibility: bool = True;
  optRegBlowfish: bool = True; // False for Phobos
  optRegRa2: bool = True;
  optRa2Enabled: bool = True;
  optRa2mdEnabled: bool = True;
  optHighResSupport: bool = True;

  function GetSystemMetrics(nIndex: int32): int32; stdcall; external 'user32.dll';
  function DllRegisterServer(): longint; stdcall; external 'Blowfish.dll';

  procedure RegBlowfish();

  begin
    if not optRegBlowfish then exit();

    Writeln('Registering Blowfish.dll file...');
    DllRegisterServer();
  end;

  procedure WriteRa2Ini(appPath: string; screenWidth, screenHeight: int32);
  var
    textFile: Text;
  begin
    if not optWriteRa2Ini then exit();

    if optRa2Enabled then
    begin
      AssignFile(textFile, AppPath + '\RA2.INI');
      rewrite(textFile);
      Writeln(textFile, '[Video]');
      Writeln(textFile, 'AllowHiResModes=yes');
      Writeln(textFile, 'VideoBackBuffer=no');
      Writeln(textFile, 'AllowVRAMSidebar=no');
      Write(textFile, 'ScreenWidth=');
      Writeln(textFile, screenWidth);
      Write(textFile, 'ScreenHeight=');
      Writeln(textFile, screenHeight);
      Close(textFile);
    end;

    if optRa2mdEnabled then
    begin
      AssignFile(textFile, AppPath + '\RA2MD.INI');
      rewrite(textFile);
      Writeln(textFile, '[Video]');
      Writeln(textFile, 'AllowHiResModes=yes');
      Writeln(textFile, 'VideoBackBuffer=no');
      Writeln(textFile, 'AllowVRAMSidebar=no');
      Write(textFile, 'ScreenWidth=');
      Writeln(textFile, screenWidth);
      Write(textFile, 'ScreenHeight=');
      Writeln(textFile, screenHeight);
      Close(textFile);
    end;

  end;

  // Call randomize() before calling this method
  function GetRandomSerial: string;
  const
    RA2_SERIAL_SIZE = 22;
  var
    serial: string;
    i: int32;
  begin
    serial := default(string);
    setlength(serial, RA2_SERIAL_SIZE);
    for i := 1 to RA2_SERIAL_SIZE do
      serial[i] := char(random(10) + 48);
    exit(serial);
  end;

  // Call randomize() before calling this method
  procedure WriteWoldataKey(appPath: string);
  const
    KEY_FILENAME = 'Woldata.key';
    RA2_KEY_SIZE = 128;
  var
    textFile: Text;
    i: int32;
  begin
    if not optWriteWoldataKey then exit();

    Writeln('Generating Woldata.key file...');
    AssignFile(textFile, appPath + '\' + KEY_FILENAME);
    rewrite(textFile);
    for i := 1 to RA2_KEY_SIZE do
      Write(textFile, random(10));
    Close(textFile);
  end;

  procedure WriteRa2Registry(appPath, serial: string);
  var
    regKey32: Tregistry;
  begin
    if not optRegRa2 then exit();
    
    Writeln('Writing registry...');

    regKey32 := Tregistry.Create(KEY_ALL_ACCESS or KEY_WOW64_32KEY);
    regKey32.RootKey := HKEY_LOCAL_MACHINE;

    regKey32.OpenKey('SOFTWARE\Westwood\Red Alert 2', True);
    regKey32.WriteString('Serial', serial);
    regKey32.WriteString('Name', 'Red Alert 2');
    regKey32.WriteString('InstallPath', appPath + '\RA2.EXE');
    regKey32.WriteInteger('SKU', 8448);
    regKey32.WriteInteger('Version', 65542);
    regKey32.CloseKey;

    regKey32.OpenKey('SOFTWARE\Westwood\Yuri''s Revenge', True);
    regKey32.WriteString('Serial', serial);
    regKey32.WriteString('Name', 'Yuri''s Revenge');
    regKey32.WriteString('InstallPath', appPath + '\RA2MD.EXE');
    regKey32.WriteInteger('SKU', 10496);
    regKey32.WriteInteger('Version', 65537);
    regKey32.CloseKey;

    regKey32.Free;
  end;

  procedure SetRa2Compatibility(appPath: string);
  var
    regKey64: Tregistry;
  begin
    if not optSetCompatibility then exit();

    Writeln('Setting application compatibility...');
    regKey64 := Tregistry.Create(KEY_ALL_ACCESS or KEY_WOW64_64KEY);
    regKey64.RootKey := HKEY_LOCAL_MACHINE;
    regKey64.OpenKey(
      'SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers',
      True);
    if optRa2Enabled then
    begin
      regKey64.WriteString(AppPath + '\GAME.EXE', '~ RUNASADMIN HIGHDPIAWARE');
      regKey64.WriteString(AppPath + '\RA2.EXE', '~ RUNASADMIN HIGHDPIAWARE');
    end;
    if optRa2mdEnabled then
    begin
      regKey64.WriteString(AppPath + '\GAMEMD.EXE', '~ RUNASADMIN HIGHDPIAWARE');
      regKey64.WriteString(AppPath + '\RA2MD.EXE', '~ RUNASADMIN HIGHDPIAWARE');
      regKey64.WriteString(AppPath + '\YURI.EXE', '~ RUNASADMIN HIGHDPIAWARE');
    end;
    regKey64.Free;

  end;

  procedure Initialize();

  var
    opt: char;
  begin
    randomize();

    while True do
    begin
      opt := GetOpt('hifcbr2ysw');
      case opt of
        'h': optShowHelp := True;
        'i': optWriteRa2Ini := False;
        'f': optWriteWoldataKey := False;
        'c': optSetCompatibility := False;
        'b': optRegBlowfish := False;
        'r': optRegRa2 := False;
        '2': optRa2Enabled := False;
        'y': optRa2mdEnabled := False;
        's': optHighResSupport := False;
        'w': optShowMsgBox := False;
        '?': optShowHelp := True;
        #0: Break;
        else
          Break;
      end;
    end;
  end;

  procedure ShowHelp();
  const
    helpText =
      'Usage:' + LineEnding + '-h: show this help.' + LineEnding +
      '-2: don''t handle everything about Red Alert 2. Just process Yuri''s Revenge.' +
      LineEnding +
      '-y: don''t handle everything about Yuri''s Revenge. Just process Red Alert 2.' +
      LineEnding + '-i: don''t write RA2(MD).ini file.' + LineEnding +
      '-f: don''t write Woldata.key file for Yuri''s Revenge' +
      LineEnding + '-c: don''t set compatibility for gaming executables' +
      LineEnding + '-b: don''t register Blowfish.dll file' + LineEnding +
      '-r: don''t register Red Alert 2 and Yuri''s Revenge in registry' +
      LineEnding +
      '-s: disable high resolution support and assume the screen is in SVGA (800x600) mode.'
      +
      LineEnding + '-w: don''t show messages in Win32 MessageBox.' +
      LineEnding + LineEnding +
      'For regular Ra2 installation, you don''t need to specify these options. Leave all options as default.'
      + LineEnding + 'For Ares-based mods like Mental Omega, specify "-2if".';
  begin
    Writeln(helpText);

  end;

const
  highResWarningText: string =
    'Warning: your screen resolution is too high. In this situation, there might be crashes without applying Ares. The in-game resolution has been reduced to 1920x1080.';
  highResWarningCaption: string = 'High Resolution Warning';
var
  appPath: string;
  serial: string;
  screenWidth, screenHeight: int32;
  isHighRes: bool;

{$R *.res}

begin
  Writeln('Register for Red Alert 2 and Yuri''s Revenge');
  Writeln('Author: SadPencil');
  Writeln();
  appPath := ExtractFileDir(ParamStr(0));
  Initialize();
  if optShowHelp then
  begin
    ShowHelp();
    exit();
  end;

  Writeln('Generating serial number...');
  serial := GetRandomSerial();

  WriteWoldataKey(appPath);

  WriteRa2Registry(appPath, serial);

  SetRa2Compatibility(appPath);

  RegBlowfish();

  optHighResSupport := optHighResSupport and optWriteRa2Ini;
  if optHighResSupport then
  begin
    Writeln('Enabling high resolution support...');
    screenWidth := GetSystemMetrics(SM_CXSCREEN);
    screenHeight := GetSystemMetrics(SM_CYSCREEN);

  end
  else
  begin
    screenWidth := 800;
    screenHeight := 600;
  end;

  isHighRes := (screenWidth > 1920) or (screenHeight > 1200);
  if isHighRes then
  begin
    screenWidth := 1920;
    screenHeight := 1080;
  end;
  
  WriteRa2Ini(appPath, screenWidth, screenHeight);

  if isHighRes then
  begin
    Writeln(highResWarningText);
    if optShowMsgBox then
      MessageBox(0, PChar(highResWarningText), PChar(highResWarningCaption),
        MB_OK or MB_ICONINFORMATION);
  end;

  if optShowMsgBox then
    MessageBox(0, 'Setup complete.', 'Register for RA2 & YR (by: SadPencil)',
      MB_OK or MB_ICONINFORMATION);

end.
