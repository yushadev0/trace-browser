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
    OnEnter = CEFWindowParent1Enter
  end
  object Chromium1: TChromium
    OnProcessMessageReceived = Chromium1ProcessMessageReceived
    OnLoadEnd = Chromium1LoadEnd
    OnLoadingStateChange = Chromium1LoadingStateChange
    OnBeforeContextMenu = Chromium1BeforeContextMenu
    OnContextMenuCommand = Chromium1ContextMenuCommand
    OnPreKeyEvent = Chromium1PreKeyEvent
    OnAddressChange = Chromium1AddressChange
    OnTitleChange = Chromium1TitleChange
    OnFullScreenModeChange = Chromium1FullscreenModeChange
    OnBeforePopup = Chromium1BeforePopup
    OnAfterCreated = Chromium1AfterCreated
    OnBeforeBrowse = Chromium1BeforeBrowse
    OnOpenUrlFromTab = Chromium1OpenUrlFromTab
    OnBeforeDownload = Chromium1BeforeDownload
    OnDownloadUpdated = Chromium1DownloadUpdated
    Left = 576
    Top = 83
  end
end
