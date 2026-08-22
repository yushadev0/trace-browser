object dmVeri: TdmVeri
  OnCreate = DataModuleCreate
  Height = 500
  Width = 1000
  PixelsPerInch = 120
  object FDConn: TFDConnection
    Left = 48
    Top = 40
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 184
    Top = 40
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 344
    Top = 40
  end
  object qryArama: TFDQuery
    Connection = FDConn
    Left = 184
    Top = 120
  end
  object qryGecmis: TFDQuery
    Connection = FDConn
    Left = 264
    Top = 120
  end
  object qryIndirmeler: TFDQuery
    Connection = FDConn
    Left = 360
    Top = 120
  end
  object qryGorevler: TFDQuery
    Connection = FDConn
    Left = 184
    Top = 192
  end
end
