object MainFrm: TMainFrm
  Left = 0
  Top = 0
  Caption = 'Trace'
  ClientHeight = 561
  ClientWidth = 936
  Color = 328965
  CustomTitleBar.Control = TitleBarPanel1
  CustomTitleBar.Enabled = True
  CustomTitleBar.Height = 30
  CustomTitleBar.SystemHeight = False
  CustomTitleBar.ShowCaption = False
  CustomTitleBar.ShowIcon = False
  CustomTitleBar.SystemColors = False
  CustomTitleBar.SystemButtons = False
  CustomTitleBar.BackgroundColor = 328965
  CustomTitleBar.ForegroundColor = 65793
  CustomTitleBar.InactiveBackgroundColor = 3815994
  CustomTitleBar.InactiveForegroundColor = 10066329
  CustomTitleBar.ButtonForegroundColor = clCream
  CustomTitleBar.ButtonBackgroundColor = 328965
  CustomTitleBar.ButtonHoverForegroundColor = clCream
  CustomTitleBar.ButtonHoverBackgroundColor = 3815994
  CustomTitleBar.ButtonPressedForegroundColor = clCream
  CustomTitleBar.ButtonPressedBackgroundColor = 328965
  CustomTitleBar.ButtonInactiveForegroundColor = clCream
  CustomTitleBar.ButtonInactiveBackgroundColor = 3815994
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  GlassFrame.Enabled = True
  GlassFrame.Top = 30
  WindowState = wsMaximized
  StyleElements = []
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  OnShow = FormShow
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 70
    Width = 936
    Height = 40
    Align = alTop
    BevelOuter = bvNone
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 0
    ExplicitTop = 37
    object skNav: TSkPaintBox
      Left = 0
      Top = 0
      Width = 936
      Height = 40
      Align = alClient
      OnMouseDown = skNavMouseDown
      OnDraw = skNavDraw
      ExplicitHeight = 35
    end
    object svgGeri: TSkSvg
      Left = 11
      Top = 11
      Width = 24
      Height = 24
      Cursor = crHandPoint
      OnClick = svgGeriClick
      Svg.OverrideColor = claWhitesmoke
      Svg.Source = 
        '<?xml version="1.0" encoding="utf-8"?><!-- Uploaded to: SVG Repo' +
        ', www.svgrepo.com, Generator: SVG Repo Mixer Tools -->'#13#10'<svg wid' +
        'th="800px" height="800px" viewBox="0 0 1024 1024" xmlns="http://' +
        'www.w3.org/2000/svg"><path fill="#000000" d="M224 480h640a32 32 ' +
        '0 1 1 0 64H224a32 32 0 0 1 0-64z"/><path fill="#000000" d="m237.' +
        '248 512 265.408 265.344a32 32 0 0 1-45.312 45.312l-288-288a32 32' +
        ' 0 0 1 0-45.312l288-288a32 32 0 1 1 45.312 45.312L237.248 512z"/' +
        '></svg>'
    end
    object svgIleri: TSkSvg
      Left = 48
      Top = 11
      Width = 24
      Height = 24
      Cursor = crHandPoint
      OnClick = svgIleriClick
      Svg.OverrideColor = claWhitesmoke
      Svg.Source = 
        '<?xml version="1.0" encoding="utf-8"?>'#13#10'<!-- Uploaded to: SVG Re' +
        'po, www.svgrepo.com, Generator: SVG Repo Mixer Tools -->'#13#10'<svg w' +
        'idth="800px" height="800px" viewBox="0 0 1024 1024" xmlns="http:' +
        '//www.w3.org/2000/svg">'#13#10'  <!-- D'#246'nd'#252'rme i'#351'lemini tam merkezden ' +
        '(512, 512) yap'#305'yoruz ki d'#305#351'ar'#305' u'#231'mas'#305'n -->'#13#10'  <g transform="rota' +
        'te(180 512 512)">'#13#10'    <path fill="#000000" d="M224 480h640a32 3' +
        '2 0 1 1 0 64H224a32 32 0 0 1 0-64z"/>'#13#10'    <path fill="#000000" ' +
        'd="m237.248 512 265.408 265.344a32 32 0 0 1-45.312 45.312l-288-2' +
        '88a32 32 0 0 1 0-45.312l288-288a32 32 0 1 1 45.312 45.312L237.24' +
        '8 512z"/>'#13#10'  </g>'#13#10'</svg>'
    end
    object svgTazele: TSkSvg
      Left = 88
      Top = 12
      Width = 22
      Height = 22
      Cursor = crHandPoint
      OnClick = svgTazeleClick
      Svg.OverrideColor = claWhitesmoke
      Svg.Source = 
        '<?xml version="1.0" encoding="utf-8"?><!-- Uploaded to: SVG Repo' +
        ', www.svgrepo.com, Generator: SVG Repo Mixer Tools -->'#13#10'<svg wid' +
        'th="800px" height="800px" viewBox="0 0 24 24" fill="none" xmlns=' +
        '"http://www.w3.org/2000/svg">'#13#10'<path d="M21 12C21 16.9706 16.970' +
        '6 21 12 21C9.69494 21 7.59227 20.1334 6 18.7083L3 16M3 12C3 7.02' +
        '944 7.02944 3 12 3C14.3051 3 16.4077 3.86656 18 5.29168L21 8M3 2' +
        '1V16M3 16H8M21 3V8M21 8H16" stroke="#000000" stroke-width="2" st' +
        'roke-linecap="round" stroke-linejoin="round"/>'#13#10'</svg>'
    end
    object edtURL: TEdit
      Left = 136
      Top = 6
      Width = 650
      Height = 26
      BorderStyle = bsNone
      Color = 1973790
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -17
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      Text = 'edtURL'
      OnKeyPress = edtURLKeyPress
    end
  end
  object pnlTarayici: TPanel
    Left = 0
    Top = 110
    Width = 936
    Height = 451
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 77
    ExplicitHeight = 484
  end
  object Panel2: TPanel
    Left = 0
    Top = 30
    Width = 936
    Height = 40
    Margins.Top = 30
    Align = alTop
    BevelOuter = bvNone
    Caption = 'Panel2'
    ShowCaption = False
    TabOrder = 2
    ExplicitTop = 0
    ExplicitWidth = 954
    object skTabs: TSkAnimatedPaintBox
      Left = 0
      Top = 0
      Width = 936
      Height = 40
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alClient
      OnMouseDown = skTabsMouseDown
      OnMouseLeave = skTabsMouseLeave
      OnMouseMove = skTabsMouseMove
      OnMouseUp = skTabsMouseUp
      OnAnimationDraw = skTabsAnimationDraw
      ExplicitTop = -3
    end
  end
  object TitleBarPanel1: TTitleBarPanel
    Left = 0
    Top = 0
    Width = 936
    Height = 30
    CustomButtons = <>
    ExplicitWidth = 930
  end
end
