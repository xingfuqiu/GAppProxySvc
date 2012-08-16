unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs,
  ShellAPI, TlHelp32;

type
  TMyProxy = class(TService)
    procedure ServiceCreate(Sender: TObject);
    procedure ServiceDestroy(Sender: TObject);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
  private
    function KillTask(ExeFileName: string): Integer;
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  MyProxy: TMyProxy;

implementation

{$R *.DFM}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  MyProxy.Controller(CtrlCode);
end;

function TMyProxy.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TMyProxy.ServiceCreate(Sender: TObject);
var
  fileName: String;
begin
  fileName := ExtractFilePath(ParamStr(0))+'proxy.exe';
  if Not FileExists(fileName) then
  begin
    OutputDebugString('代理程序不存在，请检查！');
  end else
  begin
    OutputDebugString('准备启动代理程序，进入代理状态！');
    ShellExecute(0, 'Open', pChar(fileName), nil, nil, SW_HIDE);
  end;
end;
//******************************************************************************
// 杀进程
//******************************************************************************
function TMyProxy.KillTask(ExeFileName: string): Integer;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  Result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);

  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
      UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
      UpperCase(ExeFileName))) then
      Result := Integer(TerminateProcess(
        OpenProcess(PROCESS_TERMINATE,
        BOOL(0),
        FProcessEntry32.th32ProcessID),
        0));
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

procedure TMyProxy.ServiceDestroy(Sender: TObject);
begin
  OutputDebugString('退出代理状态！');
  KillTask('proxy.exe');
end;

procedure TMyProxy.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  OutputDebugString('退出代理状态！');
  KillTask('proxy.exe');
end;

end.
