object MyProxy: TMyProxy
  OldCreateOrder = False
  OnCreate = ServiceCreate
  OnDestroy = ServiceDestroy
  DisplayName = 'GAppProxy'
  OnStop = ServiceStop
  Left = 341
  Top = 159
  Height = 150
  Width = 215
end
