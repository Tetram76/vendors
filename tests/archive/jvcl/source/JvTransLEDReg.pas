// (rom) no Jedi header because this file will die soon

unit JvTransLedReg;

interface

procedure Register;

implementation

uses
  Classes,
  JvTransLED, JvxConst;
  
{$R ..\resources\JvTransLed.dcr}

procedure Register;
begin
  RegisterComponents(srJvJFreeVCSPalette, [TJvTransLED]);
end;

end.
