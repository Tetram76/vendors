{**********************************************************************}
{                                                                      }
{    "The contents of this file are subject to the Mozilla Public      }
{    License Version 1.1 (the "License"); you may not use this         }
{    file except in compliance with the License. You may obtain        }
{    a copy of the License at http://www.mozilla.org/MPL/              }
{                                                                      }
{    Software distributed under the License is distributed on an       }
{    "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express       }
{    or implied. See the License for the specific language             }
{    governing rights and limitations under the License.               }
{                                                                      }
{    Copyright Creative IT.                                            }
{    Current maintainer: Eric Grange                                   }
{                                                                      }
{**********************************************************************}
unit DSimpleDWScript;

interface

uses
   Windows, SysUtils, Classes, StrUtils,
   dwsFileSystem, dwsGlobalVarsFunctions, dwsExprList,
   dwsCompiler, dwsHtmlFilter, dwsComp, dwsExprs, dwsUtils, dwsXPlatform,
   dwsWebEnvironment, dwsSystemInfoLibModule, dwsCPUUsage, dwsWebLibModule,
   dwsDataBase, dwsDataBaseLibModule, dwsSynSQLiteDatabase,
   dwsJSONConnector, dwsJSON, dwsErrors, dwsFunctions, dwsSymbols;

type

   TCompiledProgram = record
      Name : String;
      Prog : IdwsProgram;
   end;

   TCompiledProgramHash = class (TSimpleHash<TCompiledProgram>)
      protected
         function SameItem(const item1, item2 : TCompiledProgram) : Boolean; override;
         function GetItemHashCode(const item1 : TCompiledProgram) : Integer; override;
   end;

   TSimpleDWScript = class(TDataModule)
      DelphiWebScript: TDelphiWebScript;
      dwsHtmlFilter: TdwsHtmlFilter;
      dwsGlobalVarsFunctions: TdwsGlobalVarsFunctions;
      dwsRestrictedFileSystem: TdwsRestrictedFileSystem;
      dwsFileIO: TdwsUnit;
      procedure DataModuleCreate(Sender: TObject);
      procedure DataModuleDestroy(Sender: TObject);

      procedure DoInclude(const scriptName: String; var scriptSource: String);
      function  DoNeedUnit(const unitName : String; var unitSource : String) : IdwsUnit;
      function dwsFileIOFunctionsDeleteFileFastEval(args: TExprBaseList): Variant;
    function dwsFileIOFunctionsFileExistsFastEval(args: TExprBaseList): Variant;

   private
      FScriptTimeoutMilliseconds : Integer;
      FCPUUsageLimit : Integer;
      FCPUAffinity : Cardinal;

      FPathVariables : TStrings;

      FSystemInfo : TdwsSystemInfoLibModule;
      FHotPath : String;
      FWebEnv : TdwsWebLib;
      FDataBase : TdwsDatabaseLib;
      FJSON : TdwsJSONLibModule;

      FCompiledPrograms : TCompiledProgramHash;
      FCompiledProgramsLock : TFixedCriticalSection;

      FCompilerLock : TFixedCriticalSection;

      FFlushMatching : String;

   protected
      procedure TryAcquireDWS(const fileName : String; var prog : IdwsProgram);
      procedure CompileDWS(const fileName : String; var prog : IdwsProgram);

      procedure AddNotMatching(const cp : TCompiledProgram);

      procedure SetCPUUsageLimit(const val : Integer);
      procedure SetCPUAffinity(const val : Cardinal);

      function WaitForCPULimit : Boolean;

   public
      procedure HandleDWS(const fileName : String; request : TWebRequest; response : TWebResponse);

      // flush the cache of fileName that begin by matchBegin
      procedure FlushDWSCache(const matchingBegin : String = '');

      procedure LoadCPUOptions(options : TdwsJSONValue);
      procedure LoadDWScriptOptions(options : TdwsJSONValue);

      function ApplyPathVariables(const aPath : String) : String;

      property ScriptTimeoutMilliseconds : Integer read FScriptTimeoutMilliseconds write FScriptTimeoutMilliseconds;

      property CPUUsageLimit : Integer read FCPUUsageLimit write SetCPUUsageLimit;
      property CPUAffinity : Cardinal read FCPUAffinity write SetCPUAffinity;
      property PathVariables : TStrings read FPathVariables;
  end;

const
   cDefaultCPUOptions =
      '{'
         // Percentage (0-100) of total system usage
         // f.i. 25 on a quad core is reached by a full core and 3 cores idle
         // zero = no limit
         +'"UsageLimit":0,'
         // Core affinity
         // bitwise CPU affinity flags
         // zero = no affinity
         +'"Affinity":0'
      +'}';

   cDefaultDWScriptOptions =
      '{'
         // Script timeout in milliseconds
         // zero = no limit (not recommended)
         +'"TimeoutMSec": 3000,'
         // Size of stack growth chunks
         +'"StackChunkSize": 300,'
         // Maximum stack size per script
         +'"StackMaxSize": 10000,'
         // Maximum recursion depth per script
         +'"MaxRecursionDepth": 512,'
         // Library paths (outside of www folder)
         // By default, assumes a '.lib' subfolder of the folder where the exe is
         +'"LibraryPaths": ["%www%\\.lib"]'
      +'}';

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
implementation
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

{$R *.dfm}

procedure TSimpleDWScript.DataModuleCreate(Sender: TObject);
begin
   FPathVariables:=TFastCompareTextList.Create;

   FSystemInfo:=TdwsSystemInfoLibModule.Create(Self);
   FSystemInfo.dwsSystemInfo.Script:=DelphiWebScript;

   FDataBase:=TdwsDatabaseLib.Create(Self);
   FDataBase.dwsDatabase.Script:=DelphiWebScript;
   TdwsDataBase.OnApplyPathVariables:=ApplyPathVariables;

   FWebEnv:=TdwsWebLib.Create(Self);
   FWebEnv.dwsWeb.Script:=DelphiWebScript;

   FJSON:=TdwsJSONLibModule.Create(Self);
   FJSON.Script:=DelphiWebScript;

   FCompiledPrograms:=TCompiledProgramHash.Create;
   FCompiledProgramsLock:=TFixedCriticalSection.Create;
   FCompilerLock:=TFixedCriticalSection.Create;

   FScriptTimeoutMilliseconds:=3000;
end;

procedure TSimpleDWScript.DataModuleDestroy(Sender: TObject);
begin
   FlushDWSCache;

   FCompilerLock.Free;
   FCompiledProgramsLock.Free;
   FCompiledPrograms.Free;
   FPathVariables.Free;
end;

// HandleDWS
//
procedure TSimpleDWScript.HandleDWS(const fileName : String; request : TWebRequest; response : TWebResponse);

   procedure Handle503(response : TWebResponse);
   begin
      response.StatusCode:=503;
      response.ContentData:='CPU Usage limit reached, please try again later';
      response.ContentType:='text/plain';
   end;

   procedure Handle500(response : TWebResponse; msgs : TdwsMessageList);
   begin
      response.StatusCode:=500;
      response.ContentText['plain']:=msgs.AsInfo;
   end;

   procedure HandleScriptResult(response : TWebResponse; scriptResult : TdwsResult);
   begin
      if StrBeginsWithA(response.ContentType, 'text/') then
         response.ContentData:=scriptResult.ToUTF8String
      else response.ContentData:=scriptResult.ToDataString;
   end;

var
   prog : IdwsProgram;
   exec : IdwsProgramExecution;
   webenv : TWebEnvironment;
begin
   if (CPUUsageLimit>0) and not WaitForCPULimit then begin
      Handle503(response);
      Exit;
   end;

   TryAcquireDWS(fileName, prog);
   if prog=nil then
      CompileDWS(fileName, prog);

   if prog.Msgs.HasErrors then
      Handle500(response, prog.Msgs)
   else begin
      exec:=prog.CreateNewExecution;

      webenv:=TWebEnvironment.Create;
      webenv.WebRequest:=request;
      webenv.WebResponse:=response;
      exec.Environment:=webenv;
      try
         exec.BeginProgram;
         exec.RunProgram(ScriptTimeoutMilliseconds);
         exec.EndProgram;
      finally
         exec.Environment:=nil;
      end;

      if exec.Msgs.Count>0 then
         Handle500(response, exec.Msgs)
      else if response.ContentData='' then
         HandleScriptResult(response, exec.Result);
   end;
end;

// FlushDWSCache
//
procedure TSimpleDWScript.FlushDWSCache(const matchingBegin : String = '');
var
   oldHash : TCompiledProgramHash;
begin
   FCompiledProgramsLock.Enter;
   try
      if matchingBegin='' then
         FCompiledPrograms.Clear
      else begin
         FFlushMatching:=matchingBegin;
         oldHash:=FCompiledPrograms;
         try
            FCompiledPrograms:=TCompiledProgramHash.Create;
            oldHash.Enumerate(AddNotMatching);
         finally
            oldHash.Free;
         end;
      end;
   finally
      FCompiledProgramsLock.Leave;
   end;
end;

// LoadCPUOptions
//
procedure TSimpleDWScript.LoadCPUOptions(options : TdwsJSONValue);
var
   cpu : TdwsJSONValue;
begin
   cpu:=TdwsJSONValue.ParseString(cDefaultCPUOptions);
   try
      cpu.Extend(options);

      CPUUsageLimit:=cpu['UsageLimit'].AsInteger;
      CPUAffinity:=cpu['Affinity'].AsInteger;
   finally
      cpu.Free;
   end;
end;

// LoadDWScriptOptions
//
procedure TSimpleDWScript.LoadDWScriptOptions(options : TdwsJSONValue);
var
   dws, libs : TdwsJSONValue;
   i : Integer;
   path : String;
begin
   dws:=TdwsJSONValue.ParseString(cDefaultDWScriptOptions);
   try
      dws.Extend(options);

      ScriptTimeoutMilliseconds:=dws['TimeoutMSec'].AsInteger;

      DelphiWebScript.Config.MaxDataSize:=dws['StackMaxSize'].AsInteger;
      DelphiWebScript.Config.MaxRecursionDepth:=dws['MaxRecursionDepth'].AsInteger;

      libs:=dws['LibraryPaths'];
      dwsRestrictedFileSystem.Paths.Clear;
      for i:=0 to libs.ElementCount-1 do begin
         path:=libs.Elements[i].AsString;
         if path<>'' then begin
            path:=ApplyPathVariables(path);
            dwsRestrictedFileSystem.Paths.Add(IncludeTrailingPathDelimiter(path));
         end;
      end;

   finally
      dws.Free;
   end;
end;

// TryAcquireDWS
//
procedure TSimpleDWScript.TryAcquireDWS(const fileName : String; var prog : IdwsProgram);
var
   cp : TCompiledProgram;
begin
   cp.Name:=fileName;
   FCompiledProgramsLock.Enter;
   try
      if FCompiledPrograms.Match(cp) then
         prog:=cp.Prog;
   finally
      FCompiledProgramsLock.Leave;
   end;
end;

// CompileDWS
//
procedure TSimpleDWScript.CompileDWS(const fileName : String; var prog : IdwsProgram);
var
   code : String;
   cp : TCompiledProgram;
begin
   code:=LoadTextFromFile(fileName);

   FCompilerLock.Enter;
   try
      // check after compiler lock in case of simultaneous requests
      TryAcquireDWS(fileName, prog);
      if prog<>nil then Exit;

      FHotPath:=ExtractFilePath(fileName);

      prog:=DelphiWebScript.Compile(code);

      cp.Name:=fileName;
      cp.Prog:=prog;

      FCompiledProgramsLock.Enter;
      try
         FCompiledPrograms.Add(cp);
      finally
         FCompiledProgramsLock.Leave;
      end;
   finally
      FCompilerLock.Leave;
   end;
end;

// AddNotMatching
//
procedure TSimpleDWScript.AddNotMatching(const cp : TCompiledProgram);
begin
   if cp.Prog.Msgs.HasErrors or not StrBeginsWith(cp.Name, FFlushMatching) then
      FCompiledPrograms.Add(cp);
end;

// DoInclude
//
procedure TSimpleDWScript.DoInclude(const scriptName: String; var scriptSource: String);
begin
   if FHotPath<>'' then
      scriptSource:=LoadTextFromFile(FHotPath+scriptName);
end;

// DoNeedUnit
//
function TSimpleDWScript.DoNeedUnit(const unitName : String; var unitSource : String) : IdwsUnit;
begin
   Result:=nil;
   DoInclude(unitName+'.pas', unitSource);
end;

// SetCPUUsageLimit
//
procedure TSimpleDWScript.SetCPUUsageLimit(const val : Integer);
begin
   FCPUUsageLimit:=val;
   if FCPUUsageLimit>0 then
      SystemCPU.Track;
end;

// SetCPUAffinity
//
procedure TSimpleDWScript.SetCPUAffinity(const val : Cardinal);
var
   hProcess : THandle;
   {$if CompilerVersion<23.0}
   procMask, systemMask : DWORD;
   {$else}
   procMask, systemMask : DWORD_PTR;
   {$ifend}
begin
   hProcess:=GetCurrentProcess;
   GetProcessAffinityMask(hProcess, procMask, systemMask);
   procMask:=systemMask and val;
   if procMask=0 then
      procMask:=systemMask;
   SetProcessAffinityMask(hProcess, procMask);
end;

// WaitForCPULimit
//
function TSimpleDWScript.WaitForCPULimit : Boolean;
var
   i : Integer;
begin
   i:=0;
   while SystemCPU.ProcessUsage>CPUUsageLimit do begin
      Sleep(100);
      Inc(i);
      if i=15 then Exit(False);
   end;
   Result:=True;
end;

// ApplyPathVariables
//
function TSimpleDWScript.ApplyPathVariables(const aPath : String) : String;
var
   p1, p2 : Integer;
begin
   Result:=aPath;
   p1:=Pos('%', Result);
   while p1>0 do begin
      p2:=PosEx('%', Result, p1+1);
      if p2<p1 then Break;
      Result:= Copy(Result, 1, p1-1)
              +FPathVariables.Values[Copy(Result, p1+1, p2-p1-1)]
              +Copy(Result, p2+1);
      p1:=PosEx('%', Result, p1);
   end;
end;

// ------------------
// ------------------ TCompiledProgramHash ------------------
// ------------------

// SameItem
//
function TCompiledProgramHash.SameItem(const item1, item2 : TCompiledProgram) : Boolean;
begin
   Result:=UnicodeSameText(item1.Name, item2.Name)
end;

// GetItemHashCode
//
function TCompiledProgramHash.GetItemHashCode(const item1 : TCompiledProgram) : Integer;
begin
   Result:=SimpleStringHash(item1.Name);
end;

function TSimpleDWScript.dwsFileIOFunctionsDeleteFileFastEval(
  args: TExprBaseList): Variant;
var
   fileName : String;
begin
   fileName:=ApplyPathVariables(args.AsString[0]);
   Result:=DeleteFile(fileName);
end;

function TSimpleDWScript.dwsFileIOFunctionsFileExistsFastEval(
  args: TExprBaseList): Variant;
var
   fileName : String;
begin
   fileName:=ApplyPathVariables(args.AsString[0]);
   Result:=FileExists(fileName);
end;

end.
