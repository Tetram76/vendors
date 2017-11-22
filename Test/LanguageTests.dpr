program LanguageTests;

{$SetPEFlags $0001}

{$IFNDEF VER200}
{.$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$ENDIF}

uses
  FastMM4,
  Classes,
  Forms,
  Windows,
  TestFrameWork,
  GUITestRunner,
  SysUtils,
  dwsXPlatform,
  dwsMathComplexFunctions in '..\Source\dwsMathComplexFunctions.pas',
  dwsMath3DFunctions in '..\Source\dwsMath3DFunctions.pas',
  dwsDebugFunctions in '..\Source\dwsDebugFunctions.pas',
  dwsLinq,
  dwsLinqSql in '..\Libraries\LinqLib\dwsLinqSql.pas',
  dwsLinqJson in '..\Libraries\LinqLib\dwsLinqJson.pas',
  dwsDocBuilder in '..\Libraries\DocBuilder\dwsDocBuilder.pas',
  UScriptTests in 'UScriptTests.pas',
  UAlgorithmsTests in 'UAlgorithmsTests.pas',
  UdwsUnitTests in 'UdwsUnitTests.pas',
  UdwsUnitTestsStatic in 'UdwsUnitTestsStatic.pas',
  UHTMLFilterTests in 'UHTMLFilterTests.pas',
  UCornerCasesTests in 'UCornerCasesTests.pas',
  UdwsClassesTests in 'UdwsClassesTests.pas',
  dwsClasses in '..\Libraries\ClassesLib\dwsClasses.pas',
  UdwsDataBaseTests in 'UdwsDataBaseTests.pas',
  UdwsFunctionsTests in 'UdwsFunctionsTests.pas',
  UCOMConnectorTests in 'UCOMConnectorTests.pas',
  UTestDispatcher in 'UTestDispatcher.pas',
  UDebuggerTests in 'UDebuggerTests.pas',
  UdwsUtilsTests in 'UdwsUtilsTests.pas',
  UMemoryTests in 'UMemoryTests.pas',
  UBuildTests in 'UBuildTests.pas',
  USourceUtilsTests in 'USourceUtilsTests.pas',
  ULocalizerTests in 'ULocalizerTests.pas',
  dwsRTTIFunctions,
  dwsRTTIConnector,
  dwsStringResult,
  dwsMetrics,
  UJSONTests in 'UJSONTests.pas',
  UJSONConnectorTests in 'UJSONConnectorTests.pas',
  UTokenizerTests in 'UTokenizerTests.pas',
  ULanguageExtensionTests in 'ULanguageExtensionTests.pas',
  UJITTests in 'UJITTests.pas',
  UJITx86Tests in 'UJITx86Tests.pas',
  dwsSymbolsLibModule in '..\Libraries\SymbolsLib\dwsSymbolsLibModule.pas',
  UExternalFunctionTests in 'UExternalFunctionTests.pas',
  UdwsCryptoTests in 'UdwsCryptoTests.pas',
  UdwsEncodingTests in 'UdwsEncodingTests.pas',
  UInstantiateTests in 'UInstantiateTests.pas',
  UdwsWebUtilsTests in 'UdwsWebUtilsTests.pas',
  UdwsGraphicsTests in 'UdwsGraphicsTests.pas',
  dwsJSONPath in '..\Source\dwsJSONPath.pas',
  dwsDateTime in '..\Source\dwsDateTime.pas',
  dwsGlobalVars in '..\Source\dwsGlobalVars.pas',
  UBigIntegerTests in 'UBigIntegerTests.pas',
  dwsMPIR.Bundle in '..\Libraries\BigIntegersLib\dwsMPIR.Bundle.pas',
  dwsEncoding in '..\Source\dwsEncoding.pas',
  dwsInfo in '..\Source\dwsInfo.pas',
  dwsEvaluate in '..\Source\dwsEvaluate.pas',
  dwsFilter in '..\Source\dwsFilter.pas',
  dwsScriptSource in '..\Source\dwsScriptSource.pas',
  dwsSymbolDictionary in '..\Source\dwsSymbolDictionary.pas',
  dwsContextMap in '..\Source\dwsContextMap.pas',
  dwsUnifiedConstants in '..\Source\dwsUnifiedConstants.pas',
  USymbolDictionaryTests in 'USymbolDictionaryTests.pas',
  dwsGenericSymbols in '..\Source\dwsGenericSymbols.pas',
  dwsSpecializationContext in '..\Source\dwsSpecializationContext.pas',
  dwsGenericExprs in '..\Source\dwsGenericExprs.pas',
  dwsSpecializationMap in '..\Source\dwsSpecializationMap.pas',
  dwsUnicode in '..\Source\dwsUnicode.pas',
  UdwsSystemInfoTests in 'UdwsSystemInfoTests.pas',
  dwsSHA512 in '..\Libraries\CryptoLib\dwsSHA512.pas';

{$R *.res}

var
{$IF RTLVersion >= 23}
   procAffinity, systAffinity : NativeUInt;
{$ELSE}
   procAffinity, systAffinity : DWORD;
{$IFEND}
begin
   ReportMemoryLeaksOnShutdown:=True;
   DirectSet8087CW($133F);
   GetProcessAffinityMask(GetCurrentProcess, procAffinity, systAffinity);
   SetProcessAffinityMask(GetCurrentProcess, systAffinity);
   Application.Initialize;
   Application.UpdateFormatSettings := False;
   SetDecimalSeparator('.');
   GUITestRunner.RunRegisteredTests;
end.

