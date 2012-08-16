program GAppProxySvc;

uses
  SvcMgr,
  uMain in 'uMain.pas' {MyProxy: TService};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMyProxy, MyProxy);
  Application.Run;
end.
