object frmBookmarkEdit: TfrmBookmarkEdit
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Yer Imi Ekle'
  ClientHeight = 175
  ClientWidth = 420
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 17
  object lblBaslikEtiket: TLabel
    Left = 16
    Top = 16
    Width = 21
    Height = 17
    Caption = 'Ad:'
  end
  object lblURLEtiket: TLabel
    Left = 16
    Top = 68
    Width = 29
    Height = 17
    Caption = 'URL:'
  end
  object lblURL: TLabel
    Left = 16
    Top = 88
    Width = 388
    Height = 17
    AutoSize = False
    Caption = 'lblURL'
    EllipsisPosition = epEndEllipsis
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGrayText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object edtBaslik: TEdit
    Left = 16
    Top = 36
    Width = 388
    Height = 25
    TabOrder = 0
  end
  object btnKaydet: TButton
    Left = 337
    Top = 134
    Width = 67
    Height = 25
    Caption = 'Kaydet'
    Default = True
    ModalResult = 1
    TabOrder = 1
    OnClick = btnKaydetClick
  end
  object btnIptal: TButton
    Left = 256
    Top = 134
    Width = 75
    Height = 25
    Caption = 'Iptal'
    Cancel = True
    TabOrder = 2
    OnClick = btnIptalClick
  end
  object btnKaldir: TButton
    Left = 16
    Top = 134
    Width = 100
    Height = 25
    Caption = 'Kaldir'
    TabOrder = 3
    Visible = False
    OnClick = btnKaldirClick
  end
end
