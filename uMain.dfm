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
    Top = 69
    Width = 936
    Height = 40
    Align = alTop
    BevelOuter = bvNone
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 0
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
    object svgGorevYon: TSkSvg
      Left = 894
      Top = 11
      Width = 22
      Height = 22
      Cursor = crHandPoint
      OnClick = svgGorevYonClick
      Svg.OverrideColor = claWhitesmoke
      Svg.Source = 
        '<svg viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg"><p' +
        'ath fill="#000000" d="M498.472,223.88l-17.143-17.468L386.3,124.1' +
        '58c-8.627-7.452-19.646-11.558-31.024-11.558H157.146c-11.703,0-22' +
        '.95,4.314-31.667,12.139L15.712,223.313C5.73,232.293,0,245.144,0,' +
        '258.575v93.417C0,378.137,21.263,399.4,47.4,399.4h417.2c26.137,0,' +
        '47.4-21.263,47.4-47.407v-94.945C512,244.577,507.196,232.798,498.' +
        '472,223.88z M349.463,233.51l-1.293,5.433c-10.224,42.873-48.126,7' +
        '2.812-92.174,72.812c-44.047,0-81.943-29.939-92.166-72.812l-1.292' +
        '-5.433h-20.096l-65.857,0.628l77.657-72.472c1.182-1.106,2.724-1.7' +
        '14,4.341-1.714h195.068c1.549,0,3.042,0.56,4.204,1.582l82.972,71.' +
        '975H349.463z"/></svg>'
    end
    object svgAyarlar: TSkSvg
      Left = 858
      Top = 11
      Width = 22
      Height = 22
      Cursor = crHandPoint
      OnClick = svgAyarlarClick
      Svg.OverrideColor = claWhitesmoke
      Svg.Source = 
        '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><pat' +
        'h fill="#000000" d="M19.14,12.94c0.04,-0.3,0.06,-0.61,0.06,-0.94' +
        'c0,-0.32,-0.02,-0.64,-0.07,-0.94l2.03,-1.58c0.18,-0.14,0.23,-0.4' +
        '1,0.12,-0.61l-1.92,-3.32c-0.12,-0.22,-0.37,-0.29,-0.59,-0.22l-2.' +
        '39,0.96c-0.5,-0.38,-1.03,-0.7,-1.62,-0.94L14.4,2.81c-0.04,-0.24,' +
        '-0.24,-0.41,-0.48,-0.41h-3.84c-0.24,0,-0.43,0.17,-0.47,0.41L9.25' +
        ',5.35C8.66,5.59,8.12,5.92,7.63,6.29L5.24,5.33c-0.22,-0.08,-0.47,' +
        '0,-0.59,0.22L2.74,8.87C2.62,9.08,2.66,9.34,2.86,9.48l2.03,1.58C4' +
        '.84,11.36,4.8,11.69,4.8,12s0.02,0.64,0.07,0.94l-2.03,1.58c-0.18,' +
        '0.14,-0.23,0.41,-0.12,0.61l1.92,3.32c0.12,0.22,0.37,0.29,0.59,0.' +
        '22l2.39,-0.96c0.5,0.38,1.03,0.7,1.62,0.94l0.36,2.54c0.05,0.24,0.' +
        '24,0.41,0.48,0.41h3.84c0.24,0,0.44,-0.17,0.47,-0.41l0.36,-2.54c0' +
        '.59,-0.24,1.13,-0.56,1.62,-0.94l2.39,0.96c0.22,0.08,0.47,0,0.59,' +
        '-0.22l1.92,-3.32c0.12,-0.22,0.07,-0.47,-0.12,-0.61L19.14,12.94zM' +
        '12,15.6c-1.98,0,-3.6,-1.62,-3.6,-3.6s1.62,-3.6,3.6,-3.6s3.6,1.62' +
        ',3.6,3.6S13.98,15.6,12,15.6z"/></svg>'
    end
    object SkSvg1: TSkSvg
      Left = 818
      Top = 12
      Width = 22
      Height = 22
      Cursor = crHandPoint
      Svg.OverrideColor = claWhitesmoke
      Svg.Source = 
        '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><pat' +
        'h fill="#000000" d="M19.14,12.94c0.04,-0.3,0.06,-0.61,0.06,-0.94' +
        'c0,-0.32,-0.02,-0.64,-0.07,-0.94l2.03,-1.58c0.18,-0.14,0.23,-0.4' +
        '1,0.12,-0.61l-1.92,-3.32c-0.12,-0.22,-0.37,-0.29,-0.59,-0.22l-2.' +
        '39,0.96c-0.5,-0.38,-1.03,-0.7,-1.62,-0.94L14.4,2.81c-0.04,-0.24,' +
        '-0.24,-0.41,-0.48,-0.41h-3.84c-0.24,0,-0.43,0.17,-0.47,0.41L9.25' +
        ',5.35C8.66,5.59,8.12,5.92,7.63,6.29L5.24,5.33c-0.22,-0.08,-0.47,' +
        '0,-0.59,0.22L2.74,8.87C2.62,9.08,2.66,9.34,2.86,9.48l2.03,1.58C4' +
        '.84,11.36,4.8,11.69,4.8,12s0.02,0.64,0.07,0.94l-2.03,1.58c-0.18,' +
        '0.14,-0.23,0.41,-0.12,0.61l1.92,3.32c0.12,0.22,0.37,0.29,0.59,0.' +
        '22l2.39,-0.96c0.5,0.38,1.03,0.7,1.62,0.94l0.36,2.54c0.05,0.24,0.' +
        '24,0.41,0.48,0.41h3.84c0.24,0,0.44,-0.17,0.47,-0.41l0.36,-2.54c0' +
        '.59,-0.24,1.13,-0.56,1.62,-0.94l2.39,0.96c0.22,0.08,0.47,0,0.59,' +
        '-0.22l1.92,-3.32c0.12,-0.22,0.07,-0.47,-0.12,-0.61L19.14,12.94zM' +
        '12,15.6c-1.98,0,-3.6,-1.62,-3.6,-3.6s1.62,-3.6,3.6,-3.6s3.6,1.62' +
        ',3.6,3.6S13.98,15.6,12,15.6z"/></svg>'
    end
    object svgYildiz: TSkSvg
      Left = 822
      Top = 12
      Width = 22
      Height = 22
      Cursor = crHandPoint
      OnClick = svgYildizClick
      Svg.OverrideColor = claWhitesmoke
      Svg.Source =
        '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><pat' +
        'h fill="none" stroke="#000000" stroke-width="1.5" stroke-linejoi' +
        'n="round" d="M12 2L14.9 8.6L22 9.2L16.7 13.9L18.2 21L12 17.3L5.8' +
        ' 21L7.3 13.9L2 9.2L9.1 8.6Z"/></svg>'
    end
    object edtURL: TEdit
      Left = 136
      Top = 9
      Width = 650
      Height = 23
      BorderStyle = bsNone
      Color = 1973790
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      Text = 'edtURL'
      OnChange = edtURLChange
      OnEnter = edtURLEnter
      OnExit = edtURLExit
      OnKeyDown = edtURLKeyDown
      OnKeyPress = edtURLKeyPress
    end
  end
  object pnlTarayici: TPanel
    Left = 0
    Top = 139
    Width = 936
    Height = 422
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
  end
  object Panel2: TPanel
    Left = 0
    Top = 29
    Width = 936
    Height = 40
    Margins.Top = 30
    Align = alTop
    BevelOuter = bvNone
    Caption = 'Panel2'
    ShowCaption = False
    TabOrder = 2
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
    end
  end
  object TitleBarPanel1: TTitleBarPanel
    Left = 0
    Top = 0
    Width = 936
    Height = 29
    CustomButtons = <>
    object svgIndirilenler: TSkSvg
      Left = 800
      Top = 5
      Width = 18
      Height = 18
      Cursor = crHandPoint
      OnClick = svgIndirilenlerClick
      Svg.OverrideColor = claWhitesmoke
      Svg.Source =
        '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><pat' +
        'h fill="#000000" d="M12 3a1 1 0 0 1 1 1v9.586l3.293-3.293a1 1 0 ' +
        '1 1 1.414 1.414l-5 5a1 1 0 0 1-1.414 0l-5-5a1 1 0 1 1 1.414-1.41' +
        '4L11 13.586V4a1 1 0 0 1 1-1zM5 19a1 1 0 1 0 0 2h14a1 1 0 1 0 0-2' +
        'H5z"/></svg>'
    end
    object svgGecmis: TSkSvg
      Left = 764
      Top = 5
      Width = 18
      Height = 18
      Cursor = crHandPoint
      OnClick = svgGecmisClick
      Svg.OverrideColor = claWhitesmoke
      Svg.Source =
        '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><pat' +
        'h fill="#000000" d="M13 3a9 9 0 1 0 8.94 10H19.9A7 7 0 1 1 13 5c' +
        '1.68 0 3.22.59 4.43 1.57L14 10h7V3l-2.35 2.35A8.96 8.96 0 0 0 13' +
        ' 3zm-1 4v6l5 3 .9-1.5-4.15-2.47V7H12z"/></svg>'
    end
  end
  object lstOneriler: TListBox
    Left = 520
    Top = 248
    Width = 121
    Height = 97
    Style = lbOwnerDrawFixed
    BorderStyle = bsNone
    Color = 2367776
    ItemHeight = 46
    TabOrder = 4
    Visible = False
    OnClick = lstOnerilerClick
    OnDrawItem = lstOnerilerDrawItem
  end
  object pnlBookmarks: TPanel
    Left = 0
    Top = 109
    Width = 936
    Height = 30
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 5
  end
  object tmrArama: TTimer
    Enabled = False
    Interval = 250
    OnTimer = tmrAramaTimer
    Left = 872
    Top = 125
  end
  object tmrOdak: TTimer
    Enabled = False
    Interval = 50
    OnTimer = tmrOdakTimer
    Left = 872
    Top = 181
  end
  object tmrTaskMgr: TTimer
    OnTimer = tmrTaskMgrTimer
    Left = 872
    Top = 245
  end
  object imgFavicons: TImageList
    ColorDepth = cd32Bit
    Left = 32
    Top = 155
  end
end
