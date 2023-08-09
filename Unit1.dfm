object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'keyboard hook test'
  ClientHeight = 386
  ClientWidth = 304
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object Label1: TLabel
    Left = 24
    Top = 8
    Width = 251
    Height = 21
    Caption = '1- No need to type in this Memo!'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    StyleElements = [seClient, seBorder]
  end
  object Label2: TLabel
    Left = 24
    Top = 35
    Width = 251
    Height = 42
    Caption = '2- You can press any key, anywhere  outside of this form.'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    WordWrap = True
    StyleElements = [seClient, seBorder]
  end
  object Label3: TLabel
    Left = 24
    Top = 90
    Width = 229
    Height = 21
    Caption = '3- Press Enter to save into file!'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    StyleElements = [seClient, seBorder]
  end
  object Button1: TButton
    Left = 40
    Top = 117
    Width = 249
    Height = 25
    Caption = 'Clear'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 40
    Top = 148
    Width = 249
    Height = 230
    TabOrder = 1
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 120
    Top = 256
  end
end
