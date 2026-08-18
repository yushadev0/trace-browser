object MainFrm: TMainFrm
  Left = 0
  Top = 0
  Caption = 'Trace'
  ClientHeight = 479
  ClientWidth = 624
  Color = clBtnFace
  CustomTitleBar.Control = TitleBarPanel1
  CustomTitleBar.Enabled = True
  CustomTitleBar.Height = 38
  CustomTitleBar.SystemHeight = False
  CustomTitleBar.ShowCaption = False
  CustomTitleBar.ShowIcon = False
  CustomTitleBar.BackgroundColor = clWhite
  CustomTitleBar.ForegroundColor = 65793
  CustomTitleBar.InactiveBackgroundColor = clWhite
  CustomTitleBar.InactiveForegroundColor = 10066329
  CustomTitleBar.ButtonForegroundColor = 65793
  CustomTitleBar.ButtonBackgroundColor = clWhite
  CustomTitleBar.ButtonHoverForegroundColor = 65793
  CustomTitleBar.ButtonHoverBackgroundColor = 16053492
  CustomTitleBar.ButtonPressedForegroundColor = 65793
  CustomTitleBar.ButtonPressedBackgroundColor = 15395562
  CustomTitleBar.ButtonInactiveForegroundColor = 10066329
  CustomTitleBar.ButtonInactiveBackgroundColor = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  GlassFrame.Enabled = True
  GlassFrame.Top = 38
  StyleElements = []
  OnShow = FormShow
  TextHeight = 15
  object TitleBarPanel1: TTitleBarPanel
    Left = 0
    Top = 0
    Width = 624
    Height = 35
    CustomButtons = <>
    object PageControl1: TPageControl
      Left = 0
      Top = 0
      Width = 624
      Height = 35
      ActivePage = TabSheet1
      Align = alClient
      TabOrder = 0
      object TabSheet1: TTabSheet
        Caption = 'TabSheet1'
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 35
    Width = 624
    Height = 40
    Align = alTop
    BevelOuter = bvNone
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 1
    ExplicitTop = 50
    object btnBack: TSpeedButton
      Left = 0
      Top = 0
      Width = 65
      Height = 40
      Align = alLeft
      Caption = 'geri'
      ExplicitLeft = -6
      ExplicitHeight = 50
    end
    object btnForward: TSpeedButton
      Left = 65
      Top = 0
      Width = 65
      Height = 40
      Align = alLeft
      Caption = 'ileri'
      ExplicitLeft = 8
      ExplicitHeight = 81
    end
    object btnReload: TSpeedButton
      Left = 130
      Top = 0
      Width = 65
      Height = 40
      Align = alLeft
      Caption = 'tazele'
      ExplicitLeft = 136
      ExplicitTop = 3
      ExplicitHeight = 300
    end
    object SpeedButton1: TSpeedButton
      AlignWithMargins = True
      Left = 556
      Top = 3
      Width = 65
      Height = 34
      Align = alRight
      Caption = 'a'
      ExplicitLeft = 136
      ExplicitHeight = 300
    end
    object edtURL: TEdit
      Left = 195
      Top = 0
      Width = 121
      Height = 40
      Align = alLeft
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      Text = 'edtURL'
      OnKeyPress = edtURLKeyPress
      ExplicitLeft = 224
      ExplicitTop = 32
      ExplicitHeight = 23
    end
  end
end
