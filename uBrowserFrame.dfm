object TBrowserFrame: TTBrowserFrame
  Left = 0
  Top = 0
  Width = 640
  Height = 480
  TabOrder = 0
  object CEFWindowParent1: TCEFWindowParent
    Left = 0
    Top = 0
    Width = 640
    Height = 480
    Align = alClient
    TabOrder = 0
  end
  object Chromium1: TChromium
    OnAddressChange = Chromium1AddressChange
    OnTitleChange = Chromium1TitleChange
    OnBeforePopup = Chromium1BeforePopup
    OnAfterCreated = Chromium1AfterCreated
    Left = 576
    Top = 83
  end
end
