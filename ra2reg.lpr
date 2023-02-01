program ra2reg;

{$mode objfpc}{$H+}

uses
 {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads,        {$ENDIF}        {$ENDIF}
  Classes,
  Registry,
  SysUtils;

//const
//  KEY_WOW64_64KEY = $0100;
//  SM_CXSCREEN = 0; // width
//  SM_CYSCREEN = 1; // height
var
  AppPath: string;
  new_key_32: Tregistry;
  //new_key_64: Tregistry;
  new_text: Text;
  i: int32;
  Serial: string;
  //Width, Height: int32;

{$R *.res}

  function DllRegisterServer(): longint; stdcall; external 'Blowfish.dll';
  //function GetSystemMetrics(nIndex: int32): int32; stdcall; external 'user32.dll';

begin
  Writeln('Installer for Red Alert 2 and Yuri''s Revenge');
  Writeln('Author: Sad Pencil');
  writeln();
  AppPath := ExtractFileDir(ParamStr(0));

  randomize();
  Writeln('Generating serial number...');
  serial := default(string);
  setlength(serial, 22);
  for i := 1 to 22 do
    Serial[i] := char(random(10) + 48);

  Writeln('Generating Woldata.key file...');

  AssignFile(new_text, AppPath + '\Woldata.key');
  rewrite(new_text);
  for i := 1 to 128 do
    Write(new_text, random(10));
  Close(new_text);


  Writeln('Writing registry...');
  new_key_32 := Tregistry.Create(KEY_ALL_ACCESS or KEY_WOW64_32KEY);
  new_key_32.RootKey := HKEY_LOCAL_MACHINE;
  new_key_32.openkey('SOFTWARE\Westwood\Red Alert 2', True);
  new_key_32.WriteString('Serial', Serial);
  new_key_32.WriteString('Name', 'Red Alert 2');
  new_key_32.WriteString('InstallPath', AppPath + '\RA2.EXE');
  new_key_32.WriteInteger('SKU', 8448);
  new_key_32.WriteInteger('Version', 65542);
  new_key_32.closekey;
  new_key_32.openkey('SOFTWARE\Westwood\Yuri''s Revenge', True);
  new_key_32.WriteString('Serial', Serial);
  new_key_32.WriteString('Name', 'Yuri''s Revenge');
  new_key_32.WriteString('InstallPath', AppPath + '\RA2MD.EXE');
  new_key_32.WriteInteger('SKU', 10496);
  new_key_32.WriteInteger('Version', 65537);
  new_key_32.closekey;
  new_key_32.Free;

  //Writeln('Setting application compatibility...');
  //new_key_64 := Tregistry.Create(KEY_ALL_ACCESS or KEY_WOW64_64KEY);
  //new_key_64.RootKey := HKEY_LOCAL_MACHINE;
  //new_key_64.openkey(
  //  'SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers',
  //  True);
  //new_key_64.WriteString(AppPath + '\GAME.EXE', '~ RUNASADMIN HIGHDPIAWARE WIN7RTM');
  //new_key_64.WriteString(AppPath + '\GAMEMD.EXE', '~ RUNASADMIN HIGHDPIAWARE WIN7RTM');
  //new_key_64.WriteString(AppPath + '\RA2.EXE', '~ RUNASADMIN HIGHDPIAWARE WIN7RTM');
  //new_key_64.WriteString(AppPath + '\RA2MD.EXE', '~ RUNASADMIN HIGHDPIAWARE WIN7RTM');
  //new_key_64.WriteString(AppPath + '\YURI.EXE', '~ RUNASADMIN HIGHDPIAWARE WIN7RTM');
  //new_key_64.Free;

  Writeln('Registering Blowfish.dll file...');
  DllRegisterServer();

  //Writeln('Enabling high resolution support...');
  //Width := GetSystemMetrics(SM_CXSCREEN);
  //Height := GetSystemMetrics(SM_CYSCREEN);

  //AssignFile(new_text, AppPath + '\RA2.INI');
  //rewrite(new_text);
  //Writeln(new_Text, '[Video]');
  //Writeln(new_text, 'AllowHiResModes=yes');
  //Writeln(new_text, 'VideoBackBuffer=no');
  //Writeln(new_text, 'AllowVRAMSidebar=no');
  //Write(new_text, 'ScreenWidth=');
  //Writeln(new_text, Width);
  //Write(new_text, 'ScreenHeight=');
  //Writeln(new_text, Height);
  //Close(new_text);
  //AssignFile(new_text, AppPath + '\RA2MD.INI');
  //rewrite(new_text);
  //Writeln(new_Text, '[Video]');
  //Writeln(new_text, 'AllowHiResModes=yes');
  //Writeln(new_text, 'VideoBackBuffer=no');
  //Writeln(new_text, 'AllowVRAMSidebar=no');
  //Write(new_text, 'ScreenWidth=');
  //Writeln(new_text, Width);
  //Write(new_text, 'ScreenHeight=');
  //Writeln(new_text, Height);
  //Close(new_text);

end.
