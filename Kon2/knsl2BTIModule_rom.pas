unit knsl2BTIModule;


interface
uses
Windows, Classes, SysUtils,SyncObjs,stdctrls,comctrls,utltypes,utlbox,utlconst,knsl2meter,utlmtimer
,knsl5tracer, utlTimeDate, knsl5config,knsl3EventBox,utldatabase,Math;
type
    CBTIMeter = class(CMeter)
    Private
     //IsUpdate  : byte;
     OldCodeHi : byte;
     CodeIdChannel : integer;     
     OldCodeLo : byte;
     Addr      : byte;
     TempCurrP : byte;
     LastTarif : byte;
     Depth     : word;
     m_wSecCode: Word;
     m_MonData : TMemoryStream;
     m_nKE     : Double;
    Private
     procedure SetCurrQry;
     procedure SetGraphQry;
     procedure RunMeter;override;
     procedure InitMeter(var pL2:SL2TAG);override;
     function  SelfHandler(var pMsg:CMessage):Boolean;override;
     function  LoHandler(var pMsg0:CMessage):Boolean;override;
     function  HiHandler(var pMsg:CMessage):Boolean;override;
     constructor Create;
     destructor Destroy; override;
     //procedure CreateEnergySumReq(var nReq: CQueryPrimitive);
     procedure CreateEnergyDayReq(var nReq: CQueryPrimitive);
     procedure CreateEnergyMonReq(var nReq: CQueryPrimitive);
     procedure CreateNakEnDayReq(var nReq: CQueryPrimitive);
     procedure CreateNakEnMonthReq(var nReq: CQueryPrimitive);
     procedure CreateSresEnrReq(var nReq: CQueryPrimitive);
     procedure CreateSresEnrDayReq(var nReq: CQueryPrimitive);
     procedure REQ_RASH_HOR_V(var nReq: CQueryPrimitive);
     procedure REQ_RASH_DAY_V(var nReq: CQueryPrimitive);
     procedure REQ_RASH_MON_V(var nReq: CQueryPrimitive);
     procedure CreateOneSliceReq;
     procedure CreateAktPowerReq(var nReq: CQueryPrimitive);
     procedure CreateReaPowerReq(var nReq: CQueryPrimitive);
     procedure CreateVoltReq(var nReq: CQueryPrimitive);
     procedure CreateCurrReq(var nReq: CQueryPrimitive);
     procedure CreateKoefPowerReq(var nReq: CQueryPrimitive);
     procedure Create3MinPowerReq(var nReq: CQueryPrimitive);
     procedure CreateFreqReq(var nReq: CQueryPrimitive);
     procedure CreateVzljotReq(var nReq: CQueryPrimitive);
     procedure CreateNakEnReq(var nReq:CQueryPrimitive);
     procedure CreateDateTimeReq(var nReq: CQueryPrimitive);
     procedure CreateKorrTimeReq(var nReq: CQueryPrimitive);
     procedure CreateMaxPowerReq(var nReq: CQueryPrimitive);
     procedure CreateJrnlReq(var nReq: CQueryPrimitive);
     procedure CreateCurrentParamsReqEx(var nReq: CQueryPrimitive);
     procedure CreateCurrentParamsRash(var nReq: CQueryPrimitive);
     procedure CreateCurrentParamsMonEx(var nReq: CQueryPrimitive);
     procedure CreateTranzMeterReq(var nReq: CQueryPrimitive);
     procedure CreateCC301Answer(var buf : array of byte; nID : integer);
     procedure ReadEnergyDay(var pMsg:CMessage);
     procedure ReadEnergyMon(var pMsg:CMessage);
     procedure ReadSresEnr(var pMsg:CMessage);
     procedure ReadSresEnrDay(var pMsg:CMessage);
//     procedure ReadNakEnDay(var pMsg:CMessage);
     function  ReadNakEnDay(var pMsg:CMessage):Boolean;
     procedure ReadNakEnMonth(var pMsg:CMessage);
     procedure ReadMaxPower(var pMsg:CMessage);
     procedure ReadVzljotParam(var pMsg:CMessage);
     procedure ReadPulsarParam(var pMsg:CMessage);
     procedure ReadCurrentParam(var pMsg:CMessage);
     procedure ReadDateTime(var pMsg:CMessage);
     procedure ReadKorrTime(var pMsg:CMessage);
     procedure ReadJrnl(var pMsg:CMessage);
     procedure ReadJrnlEx(var pMsg:CMessage);
     procedure ReadPrirDayDbl(var pMsg:CMessage);
     procedure ReadPrirEnMonthDbl(var pMsg:CMessage);
     procedure Read30SrezEnergDbl(var pMsg:CMessage);
     procedure Read30SrezEnergDayDbl(var pMsg:CMessage);
     procedure ReadEnMonthDbl(var pMsg:CMessage);
     procedure ReadEnDayDbl(var pMsg:CMessage);
     procedure ReadAllCurrParams(var pMsg:CMessage);
     procedure ReadCurrAllPulsar(var pMsg:CMessage);
     procedure CreateMonFileReadReq(StartAdr, NumToRead : integer);
     procedure ReadMonitorParams(var pMsg:CMessage);
     function  GetValue(var pMsg:CMessage;i:integer):Single;
     function  GetDWValue(var pMsg:CMessage;i:integer):DWORD;
     procedure WriteI(var pMsg:CMessage;i:integer);
     procedure WriteU(var pMsg:CMessage;i:integer);
     procedure WriteP(var pMsg:CMessage;i:integer);
     procedure WriteE(var pMsg:CMessage;i:integer);
     procedure ReadPrirDayTranz(var pMsg:CMessage; TimePoz: integer);
     procedure Read3PowerTranz(var pMsg:CMessage; TimePoz: integer);
     procedure ReadVoltTranz(var pMsg:CMessage; TimePoz: integer);
     procedure ReadCurrTranz(var pMsg:CMessage; TimePoz: integer);
     function  ReadCC301TranzAns(var pMsg:CMessage):boolean;
     procedure ReadBadTranz(var pMsg:CMessage);
     procedure ReadOneSliceAnswer(var pMsg:CMessage);
     procedure RES_RASH_HOR_V(var pMsg:CMessage);
     function  IsTrueValue(var dbVal:Double):Boolean;
     procedure ReadCurrentParams(var pMsg:CMessage);
     function  CheckControlFields(var pMsg : CMessage):boolean;
     function  CRC(var buf : array of byte; count : word):boolean;
     function  CRC301(var buf : array of byte; cnt : word):boolean;
     procedure CreateMSG(var buffer : array of byte; length : word; fnc : word);
     procedure EncodeFormatBTIFloat(const buf1 : PBYTEARRAY; buf2 : PBYTEARRAY);
     procedure CreateMSGHead(var pMsg : CHMessage; length : word);
     procedure CreateOutMSG(param : double; sm : byte; tar : byte);
     procedure WriteDate();
     procedure OnEnterAction;
     procedure OnFinalAction;
     procedure OnConnectComplette(var pMsg:CMessage);
     procedure OnDisconnectComplette(var pMsg:CMessage);
     procedure HandQryRoutine(var pMsg:CMessage);
     procedure OnFinHandQryRoutine(var pMsg:CMessage);
     function  SwitchCurrParam(param: word; i : byte):word;
     procedure AddEnergyDayGraphQry(dt_Date1, dt_Date2 : TDateTime);
     procedure AddEnergyMonthGrpahQry(dt_Date1, dt_Date2 : TDateTime);
     procedure AddSresEnergGrpahQry(byType:Byte;dt_Date1, dt_Date2 : TDateTime);
     procedure AddNakEnDayGrpahQry(byType:Byte;dt_Date1, dt_Date2 : TDateTime);
     procedure AddNakEnMonthGrpahQry(byType:Byte;dt_Date1, dt_Date2 : TDateTime);
     procedure AddMaxMonthEnGrpahQry(dt_Date1, dt_Date2 : TDateTime);
     procedure AddEventsGraphQry(var pMsg : CMessage);
     procedure AddCurrParamExQry(PID: integer; Date1 : TDateTime);
     procedure AddCurrParamMonQry(PID: integer; Date1 : TDateTime);
     procedure AddVzljotParamsQry(dt_Date1, dt_Date2 : TDateTime);
     procedure FNCCorTime(var pMsg : CMessage);
     procedure PrepareFloat(var flValue:Single);
     procedure StopComplette(var pMsg:CMessage;wFnc:Word);
     procedure LayerSuspend;
     procedure LayerResume;
     procedure SendQryBoolInit(nFCrcRb,nFEkom,nInnerF:Integer;nParam:Integer);
    End;

const srCRCHi:array[0..255] of byte = (
$00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40, $01, $C0, $80, $41,
$00, $C1, $81, $40, $00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40,
$00, $C1, $81, $40, $01, $C0, $80, $41, $00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41,
$00, $C1, $81, $40, $01, $C0, $80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40, $01, $C0, $80, $41,
$00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40,
$01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40, $01, $C0, $80, $41, $00, $C1, $81, $40,
$00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40,
$01, $C0, $80, $41, $00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40,
$00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40, $01, $C0, $80, $41,
$00, $C1, $81, $40, $00, $C1, $81, $40, $01, $C0, $80, $41, $00, $C1, $81, $40, $01, $C0, $80, $41,
$01, $C0, $80, $41, $00, $C1, $81, $40, $01, $C0, $80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40,
$01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40, $01, $C0, $80, $41,
$00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40);

      srCRCLo:array[0..255] of byte = (
$00, $C0, $C1, $01, $C3, $03, $02, $C2, $C6, $06, $07, $C7, $05, $C5, $C4, $04, $CC, $0C, $0D, $CD,
$0F, $CF, $CE, $0E, $0A, $CA, $CB, $0B, $C9, $09, $08, $C8, $D8, $18, $19, $D9, $1B, $DB, $DA, $1A,
$1E, $DE, $DF, $1F, $DD, $1D, $1C, $DC, $14, $D4, $D5, $15, $D7, $17, $16, $D6, $D2, $12, $13, $D3,
$11, $D1, $D0, $10, $F0, $30, $31, $F1, $33, $F3, $F2, $32, $36, $F6, $F7, $37, $F5, $35, $34, $F4,
$3C, $FC, $FD, $3D, $FF, $3F, $3E, $FE, $FA, $3A, $3B, $FB, $39, $F9, $F8, $38, $28, $E8, $E9, $29,
$EB, $2B, $2A, $EA, $EE, $2E, $2F, $EF, $2D, $ED, $EC, $2C, $E4, $24, $25, $E5, $27, $E7, $E6, $26,
$22, $E2, $E3, $23, $E1, $21, $20, $E0, $A0, $60, $61, $A1, $63, $A3, $A2, $62, $66, $A6, $A7, $67,
$A5, $65, $64, $A4, $6C, $AC, $AD, $6D, $AF, $6F, $6E, $AE, $AA, $6A, $6B, $AB, $69, $A9, $A8, $68,
$78, $B8, $B9, $79, $BB, $7B, $7A, $BA, $BE, $7E, $7F, $BF, $7D, $BD, $BC, $7C, $B4, $74, $75, $B5,
$77, $B7, $B6, $76, $72, $B2, $B3, $73, $B1, $71, $70, $B0, $50, $90, $91, $51, $93, $53, $52, $92,
$96, $56, $57, $97, $55, $95, $94, $54, $9C, $5C, $5D, $9D, $5F, $9F, $9E, $5E, $5A, $9A, $9B, $5B,
$99, $59, $58, $98, $88, $48, $49, $89, $4B, $8B, $8A, $4A, $4E, $8E, $8F, $4F, $8D, $4D, $4C, $8C,
$44, $84, $85, $45, $87, $47, $46, $86, $82, $42, $43, $83, $41, $81, $80, $40);

      __SetMask : array [0..7] of byte = ($01, $02, $04, $08, $10, $20, $40, $80);
implementation
constructor CBTIMeter.Create;                                                    
Begin

End;
destructor CBTIMeter.Destroy;
Begin
    inherited;
End;
procedure CBTIMeter.InitMeter(var pL2:SL2TAG);
Begin
    //m_MonData := TMemoryStream.Create;
    IsUpdate := 0;
    Addr := 1;
    m_wSecCode := 0;
    {if m_nP.m_sbyHandScenr=0 then
    Begin
     SetCurrQry;
     SetGraphQry;
    end;
    if m_nP.m_sbyHandScenr=1 then
    Begin
     SetHandScenario;
     SetHandScenarioGraph;
    end;}
    //move(pL2, m_nP, sizeof(pL2));
    SetHandScenario;
    SetHandScenarioGraph;
    TraceL(2,m_nP.m_swMID,'(__)CL2MD::>Null    Meter Created:'+
    ' PortID:'+IntToStr(m_nP.m_sbyPortID)+
    ' Rep:'+IntToStr(m_byRep)+
    ' Group:'+IntToStr(m_nP.m_sbyGroupID));
End;
procedure CBTIMeter.PrepareFloat(var flValue:Single);
Begin
    if blIsKTRout=1 then flValue := flValue*(m_nP.m_sfKI*m_nP.m_sfKU);
End;
procedure CBTIMeter.AddEnergyDayGraphQry(dt_Date1, dt_Date2 : TDateTime);
var TempDate    : TDateTime;
    i, Specc2   : integer;
begin
   Specc2 := 0;
   for i := 0 to m_nObserver.pm_sInil2CmdTbl.m_swAmCommand - 1 do
     if m_nObserver.pm_sInil2CmdTbl.m_sCommand[i].m_swCmdID = QRY_ENERGY_DAY_EP then
     begin
       Specc2 := m_nObserver.pm_sInil2CmdTbl.m_sCommand[i].m_swSpecc2;
       break;
     end;
   if (cDateTimeR.CompareDay(dt_Date2, Now) = 1 ) then
     dt_Date2 := Now;
   while cDateTimeR.CompareDay(dt_Date1, dt_Date2) <> 1 do
   begin
     i        := 0;
     TempDate := Now;
     while (cDateTimeR.CompareDay(dt_Date2, TempDate) <> 1) do
     begin  //В цикле считаю количество дней от текущего
       cDateTimeR.DecDate(TempDate);
       Dec(i);
       if i < -90 then
         exit;
     end;
     m_nObserver.AddGraphParam(QRY_ENERGY_DAY_EP, abs(i + 1), 1, Specc2, 1);
     //m_nObserver.AddGraphParam(QRY_ENERGY_DAY_EP, abs(i + 1), 2, 0, 1);
     //m_nObserver.AddGraphParam(QRY_ENERGY_DAY_EP, abs(i + 1), 3, 0, 1);
     //m_nObserver.AddGraphParam(QRY_ENERGY_DAY_EP, abs(i + 1), 4, 0, 1);
     cDateTimeR.DecDate(dt_Date2);
   end;
end;

procedure CBTIMeter.AddEnergyMonthGrpahQry(dt_Date1, dt_Date2 : TDateTime);
var TempDate    : TDateTime;
    i, Specc2   : integer;
begin
   Specc2 := 0;
   for i := 0 to m_nObserver.pm_sInil2CmdTbl.m_swAmCommand - 1 do
     if m_nObserver.pm_sInil2CmdTbl.m_sCommand[i].m_swCmdID = QRY_ENERGY_MON_EP then
     begin
       Specc2 := m_nObserver.pm_sInil2CmdTbl.m_sCommand[i].m_swSpecc2;
       break;
     end;
   if (cDateTimeR.CompareMonth(dt_Date2, Now) = 1 ) then
     dt_Date2 := Now;
   while cDateTimeR.CompareMonth(dt_Date1, dt_Date2) <> 1 do
   begin
     i        := 0;
     TempDate := Now;
     while (cDateTimeR.CompareMonth(dt_Date2, TempDate) <> 1) do
     begin
       cDateTimeR.DecMonth(TempDate);
       Dec(i);
       if i < -24 then
         exit;
     end;
     m_nObserver.AddGraphParam(QRY_ENERGY_MON_EP, abs(i + 1), 1, Specc2, 1);
     //m_nObserver.AddGraphParam(QRY_ENERGY_MON_EP, abs(i + 1), 2, 0, 1);
     //m_nObserver.AddGraphParam(QRY_ENERGY_MON_EP, abs(i + 1), 3, 0, 1);
     //m_nObserver.AddGraphParam(QRY_ENERGY_MON_EP, abs(i + 1), 4, 0, 1);
     cDateTimeR.DecMonth(dt_Date2);
   end;
end;

procedure CBTIMeter.AddSresEnergGrpahQry(byType:Byte;dt_Date1, dt_Date2 : TDateTime);
var TempDate    : TDateTime;
    i, Specc2   : integer;
begin
   Specc2 := 0;
   if (m_nP.m_sbyType=MET_PULCR) then byType := QRY_RASH_HOR_V;
   if (byType>=QRY_SRES_ENR_EP)and(byType<=QRY_SRES_ENR_RM) then byType := QRY_SRES_ENR_EP;
   if (byType=QRY_RASH_HOR_V) then byType := QRY_RASH_HOR_V;
   for i := 0 to m_nObserver.pm_sInil2CmdTbl.m_swAmCommand - 1 do
     if (m_nObserver.pm_sInil2CmdTbl.m_sCommand[i].m_swCmdID = QRY_SRES_ENR_DAY_EP) or
        (m_nObserver.pm_sInil2CmdTbl.m_sCommand[i].m_swCmdID = QRY_RASH_HOR_V) or
        (m_nObserver.pm_sInil2CmdTbl.m_sCommand[i].m_swCmdID = QRY_SRES_ENR_EP) then
     begin
       Specc2 := m_nObserver.pm_sInil2CmdTbl.m_sCommand[i].m_swSpecc2;
       break;
     end;
   if (cDateTimeR.CompareDay(dt_Date2, Now) = 1 ) then
     dt_Date2 := Now;
   while cDateTimeR.CompareDay(dt_Date1, dt_Date2) <> 1 do
   begin
     i        := 0;
     TempDate := Now;
     while (cDateTimeR.CompareDay(dt_Date2, TempDate) <> 1) do
     begin  //В цикле считаю количество дней от текущего
       cDateTimeR.DecDate(TempDate);
       Dec(i);
       if i < -365 then
         exit;
     end;
     if (Specc2 = 3) then
       m_nObserver.AddGraphParam(byType, abs(i + 1), 1, 1, 1)
     else
       m_nObserver.AddGraphParam(byType, abs(i + 1), 1, Specc2, 1);

     //m_nObserver.AddGraphParam(QRY_SRES_ENR_DAY_EP, abs(i + 1), 1, Specc2, 1);
     //m_nObserver.AddGraphParam(QRY_ENERGY_MON_EP, abs(i + 1), 2, 0, 1);
     //m_nObserver.AddGraphParam(QRY_ENERGY_MON_EP, abs(i + 1), 3, 0, 1);
     //m_nObserver.AddGraphParam(QRY_ENERGY_MON_EP, abs(i + 1), 4, 0, 1);
     cDateTimeR.DecDate(dt_Date2);
   end;
end;

procedure CBTIMeter.AddNakEnDayGrpahQry(byType:Byte;dt_Date1, dt_Date2 : TDateTime);
var TempDate    : TDateTime;
    i, Specc2   : integer;
begin
   Specc2 := 0;
   if (byType>=QRY_NAK_EN_DAY_EP)and(byType<=QRY_NAK_EN_DAY_RM) then byType := QRY_NAK_EN_DAY_EP;
   if (byType=QRY_RASH_DAY_V) then byType := QRY_RASH_DAY_V;
   for i := 0 to m_nObserver.pm_sInil2CmdTbl.m_swAmCommand - 1 do
     if (m_nObserver.pm_sInil2CmdTbl.m_sCommand[i].m_swCmdID = QRY_NAK_EN_DAY_EP) or
        (m_nObserver.pm_sInil2CmdTbl.m_sCommand[i].m_swCmdID = QRY_RASH_DAY_V) then
     begin
       Specc2 := m_nObserver.pm_sInil2CmdTbl.m_sCommand[i].m_swSpecc2;
       break;
     end;
   if (cDateTimeR.CompareDay(dt_Date2, Now) = 1 ) then
     dt_Date2 := Now;
   while cDateTimeR.CompareDay(dt_Date1, dt_Date2) <> 1 do
   begin
     i        := 0;
     TempDate := Now;
     while (cDateTimeR.CompareDay(dt_Date2, TempDate) <> 1) do
     begin  //В цикле считаю количество дней от текущего
       cDateTimeR.DecDate(TempDate);
       Dec(i);
       if i < -90 then
         exit;
     end;
     m_nObserver.AddGraphParam(byType, abs(i + 1), 1, Specc2, 1);
     //m_nObserver.AddGraphParam(QRY_NAK_EN_DAY_EP, abs(i + 1), 2, 0, 1);
     //m_nObserver.AddGraphParam(QRY_NAK_EN_DAY_EP, abs(i + 1), 3, 0, 1);
     //m_nObserver.AddGraphParam(QRY_NAK_EN_DAY_EP, abs(i + 1), 4, 0, 1);
     cDateTimeR.DecDate(dt_Date2);
   end;
end;
procedure CBTIMeter.AddNakEnMonthGrpahQry(byType:Byte;dt_Date1, dt_Date2 : TDateTime);
var TempDate    : TDateTime;
    i, Specc2   : integer;
begin
   Specc2 := 0;
   if (byType>=QRY_NAK_EN_MONTH_EP)and(byType<=QRY_NAK_EN_MONTH_RM) then byType := QRY_NAK_EN_MONTH_EP;
   if (byType=QRY_RASH_MON_V) then byType := QRY_RASH_MON_V;
   for i := 0 to m_nObserver.pm_sInil2CmdTbl.m_swAmCommand - 1 do
     if (m_nObserver.pm_sInil2CmdTbl.m_sCommand[i].m_swCmdID = QRY_NAK_EN_MONTH_EP) or
        (m_nObserver.pm_sInil2CmdTbl.m_sCommand[i].m_swCmdID = QRY_RASH_MON_V) then
     begin
       Specc2 := m_nObserver.pm_sInil2CmdTbl.m_sCommand[i].m_swSpecc2;
       break;
     end;
   if (cDateTimeR.CompareMonth(dt_Date2, Now) = 1 ) then
     dt_Date2 := Now;
   while cDateTimeR.CompareMonth(dt_Date1, dt_Date2) <> 1 do
   begin
     i        := 0;
     TempDate := Now;
     while (cDateTimeR.CompareMonth(dt_Date2, TempDate) <> 1) do
     begin
       cDateTimeR.DecMonth(TempDate);
       Dec(i);
       if i < -24 then
         exit;
     end;
     m_nObserver.AddGraphParam(byType, abs(i + 1), 1, Specc2, 1);
     //m_nObserver.AddGraphParam(QRY_NAK_EN_MONTH_EP, abs(i + 1), 2, 0, 1);
     //m_nObserver.AddGraphParam(QRY_NAK_EN_MONTH_EP, abs(i + 1), 3, 0, 1);
     //m_nObserver.AddGraphParam(QRY_NAK_EN_MONTH_EP, abs(i + 1), 4, 0, 1);
     cDateTimeR.DecMonth(dt_Date2);
   end;
end;

procedure CBTIMeter.AddMaxMonthEnGrpahQry(dt_Date1, dt_Date2 : TDateTime);
var TempDate    : TDateTime;
    i, Specc2   : integer;
begin
   Specc2 := 0;
   for i := 0 to m_nObserver.pm_sInil2CmdTbl.m_swAmCommand - 1 do
     if m_nObserver.pm_sInil2CmdTbl.m_sCommand[i].m_swCmdID = QRY_MAX_POWER_EP then
     begin
       Specc2 := m_nObserver.pm_sInil2CmdTbl.m_sCommand[i].m_swSpecc2;
       break;
     end;
   if (cDateTimeR.CompareMonth(dt_Date2, Now) = 1 ) then
     dt_Date2 := Now;
   while cDateTimeR.CompareMonth(dt_Date1, dt_Date2) <> 1 do
   begin
     i        := 0;
     TempDate := Now;
     while (cDateTimeR.CompareMonth(dt_Date2, TempDate) <> 1) do
     begin
       cDateTimeR.DecMonth(TempDate);
       Dec(i);
       if i < -24 then
         exit;
     end;
     m_nObserver.AddGraphParam(QRY_MAX_POWER_EP, abs(i + 1), 1, Specc2, 1);
     //m_nObserver.AddGraphParam(QRY_NAK_EN_MONTH_EP, abs(i + 1), 2, 0, 1);
     //m_nObserver.AddGraphParam(QRY_NAK_EN_MONTH_EP, abs(i + 1), 3, 0, 1);
     //m_nObserver.AddGraphParam(QRY_NAK_EN_MONTH_EP, abs(i + 1), 4, 0, 1);
     cDateTimeR.DecMonth(dt_Date2);
   end;
end;
{
  QFH_JUR_0                    = $0000000000010000;
  QFH_JUR_1                    = $0000000000020000;
  QFH_JUR_2                    = $0000000000040000;
  QFH_JUR_3                    = $0000000000080000;
}

procedure CBTIMeter.AddEventsGraphQry(var pMsg : CMessage);
Var
    Date1, Date2     : TDateTime;
    szDT,JID         : integer;
    Year, Month, Day : word;
    pDS              : CMessageData;
    nJIM             : int64;
begin
   m_nObserver.ClearGraphQry;
   szDT := sizeof(TDateTime);
   Move(pMsg.m_sbyInfo[0],pDS,sizeof(CMessageData));
   Move(pDS.m_sbyInfo[0],Date1,szDT);
   Move(pDS.m_sbyInfo[szDT],Date2,szDT);

   Move(pDS.m_sbyInfo[2*szDT],nJIM,sizeof(int64));
   JID := 0;
   if (nJIM and QFH_JUR_0)<>0 then JID:=0;
   if (nJIM and QFH_JUR_1)<>0 then JID:=1;
   if (nJIM and QFH_JUR_2)<>0 then JID:=2;
   if (nJIM and QFH_JUR_3)<>0 then JID:=3;
   DecodeDate(Date1, Year, Month, Day);
   m_nObserver.AddGraphParam(QRY_JRNL_T1 + JID, 250, Day, Month, 1);
   //m_nObserver.AddGraphParam(QRY_JRNL_T2, 20, Day, Month, 1);
   //m_nObserver.AddGraphParam(QRY_JRNL_T3, 20, Day, Month, 1);
end;

procedure CBTIMeter.AddCurrParamExQry(PID: integer; Date1 : TDateTime);
begin
   m_nObserver.AddGraphParam(PID, trunc(Now) - trunc(Date1), 0, $FF, 1);
end;

procedure CBTIMeter.AddCurrParamMonQry(PID: integer; Date1 : TDateTime);
begin
   m_nObserver.AddGraphParam(PID, trunc(Now) - trunc(Date1), 0, $FF - 1, 1);
end;

procedure CBTIMeter.AddVzljotParamsQry(dt_Date1, dt_Date2 : TDateTime);
var i, sm        : integer;
    spec1, spec2 : integer;
    TempDate     : TDateTime;
begin
   sm := 0;
   TempDate := dt_Date1;
   while trunc(Now) <> trunc(TempDate)  do
   begin
     Inc(sm);
     cDateTimeR.IncDate(TempDate);
   end;
   TempDate := dt_Date1;
   while trunc(TempDate) >= trunc(dt_Date1) do
   begin
     m_nObserver.AddGraphParam(QRY_POD_TRYB_HEAT, sm, 0, 0, 1);
     Inc(sm);
     cDateTimeR.DecDate(TempDate);
   end;
end;

procedure CBTIMeter.SetCurrQry;
Begin
    with m_nObserver do
    Begin
      ClearCurrQry;
    End;
End;
procedure CBTIMeter.SetGraphQry;
Begin
End;

function  CBTIMeter.SwitchCurrParam(param: word; i : byte):word;
begin
   case param of
     QRY_MGAKT_POW_S   : {Result := param + i;}if (i = 3) then Result := param else Result := param + i + 1;
     QRY_MGREA_POW_S   : {Result := param + i;}if (i = 3) then Result := param else Result := param + i + 1;
     QRY_U_PARAM_A     : Result := param + i;
     QRY_I_PARAM_A     : Result := param + i;
     QRY_KOEF_POW_A    : Result := param + i;
     QRY_ENERGY_SUM_EP : begin Result := param + i div 4; m_nRxMsg.m_sbyInfo[8] := i mod 4 + 1; end;
     QRY_FREQ_NET      : Result := param;
     QRY_E3MIN_POW_EP  : Result := param + i;
   end;
end;

procedure CBTIMeter.EncodeFormatBTIFloat(const buf1 : PBYTEARRAY; buf2 : PBYTEARRAY);
begin
   buf2[3] := buf1[0];
   buf2[2] := buf1[1];
   buf2[1] := buf1[2];
   buf2[0] := buf1[3];
end;

procedure CBTIMeter.CreateMSGHead(var pMsg : CHMessage; length : word);
begin
   pMsg.m_swLen         := length + 11;
   pMsg.m_swObjID       := m_nP.m_swMID;
   pMsg.m_sbyFrom       := DIR_BTITOL1;
   pMsg.m_sbyFor        := DIR_BTITOL1;
   pMsg.m_sbyType       := PH_DATARD_REQ;
   pMsg.m_sbyTypeIntID  := m_nP.m_sbyPortID;
   pMsg.m_sbyIntID      := m_nP.m_sbyPortID;
   pMsg.m_sbyServerID   := HIP_BTI;
   pMsg.m_sbyDirID      := IsUpdate;
   SendOutStat(pMsg.m_swLen);
   pMsg.m_sbyServerID   := 0;
end;

procedure CBTIMeter.CreateMSG(var buffer : array of byte; length : word; fnc : word);
begin
   buffer[0]          := $55;
   buffer[1]          := Addr or $80;                //Adr YSPD
   buffer[2]          := length div $100;
   buffer[3]          := length mod $100;
   buffer[4]          := fnc div $100;
   buffer[5]          := fnc mod $100;
   CodeIdChannel := StrToInt(m_nP.m_sddPHAddres);
   buffer[length - 4] := CodeIdChannel;//Hi(m_wSecCode);//Hi(CodeIdChannel); //  //random(255);    //CODE HI
   OldCodeHi          := buffer[length - 4];
    buffer[length - 3] := 12; //Lo(CodeIdChannel); //Lo(CodeIdChannel); //12;{Lo(m_wSecCode);} //random(255);    //CODE LO
   OldCodeLo          := buffer[length - 3];
   CRC(buffer, length - 2);
   m_wSecCode := m_wSecCode + $100;
end;
{
procedure CBTIMeter.WriteDate();
var i            : shortint;
Year, Month, Day : word;
TempDate         : TDateTime;
begin
    TempDate := Now;
    case TempCurrP of
      QRY_NAK_EN_MONTH_EP, QRY_ENERGY_MON_EP, QRY_MAX_POWER_EP:
      begin
        for i := 0 to Depth - 1 do
          cDateTimeR.DecMonth(TempDate);
        DecodeDate(TempDate, Year, Month, Day);
        m_nRxMsg.m_sbyInfo[2] := Year - 2000;
        m_nRxMsg.m_sbyInfo[3] := Month;
        m_nRxMsg.m_sbyInfo[4] := cDateTimeR.DayPerMonth(Month, Year);
        m_nRxMsg.m_sbyInfo[5] := 0;
        m_nRxMsg.m_sbyInfo[6] := 0;
        m_nRxMsg.m_sbyInfo[7] := 0;
      end;
      QRY_ENERGY_DAY_EP, QRY_NAK_EN_DAY_EP:
      begin
        for i := 0 to Depth - 1 do
          cDateTimeR.DecDate(TempDate);
        DecodeDate(TempDate, Year, Month, Day);
        m_nRxMsg.m_sbyInfo[2] := Year - 2000;
        m_nRxMsg.m_sbyInfo[3] := Month;
        m_nRxMsg.m_sbyInfo[4] := Day;
        m_nRxMsg.m_sbyInfo[5] := 0;
        m_nRxMsg.m_sbyInfo[6] := 0;
        m_nRxMsg.m_sbyInfo[7] := 0;
      end;
    end;
end;
}
procedure CBTIMeter.WriteDate();
var i, temp          : shortint;
    Year, Month, Day : word;
    TempDate         : TDateTime;
    sm               : shortint;
begin
    //move(m_nTxMsg.m_sbyInfo[3], temp, 1);
    TempDate := Now;
    case TempCurrP of
  //    if QRY_NAK_EN_MONTH_EP = 0 then QRY_NAK_EN_MONTH_EP
      QRY_NAK_EN_MONTH_EP, QRY_ENERGY_MON_EP,QRY_RASH_MON_V:
      begin
        if TempCurrP = QRY_ENERGY_MON_EP then
          cDateTimeR.IncMonth(TempDate);
        //for i := temp to -1 do
        for i := 0 to Depth - 1 do
          cDateTimeR.DecMonth(TempDate);
        DecodeDate(TempDate, Year, Month, Day);
        m_nRxMsg.m_sbyInfo[2] := Year - 2000;
        m_nRxMsg.m_sbyInfo[3] := Month;
        m_nRxMsg.m_sbyInfo[4] := 1;
        m_nRxMsg.m_sbyInfo[5] := 00;
        m_nRxMsg.m_sbyInfo[6] := 00;
        m_nRxMsg.m_sbyInfo[7] := 00;
      end;
      QRY_ENERGY_DAY_EP, QRY_NAK_EN_DAY_EP,QRY_RASH_DAY_V:
      begin
        if TempCurrP = QRY_ENERGY_DAY_EP then
          cDateTimeR.IncDate(TempDate);
        //for i := temp to -1 do
        for i := 0 to Depth - 1 do
          cDateTimeR.DecDate(TempDate);
        DecodeDate(TempDate, Year, Month, Day);
        m_nRxMsg.m_sbyInfo[2] := Year - 2000;
        m_nRxMsg.m_sbyInfo[3] := Month;
        m_nRxMsg.m_sbyInfo[4] := Day;
        m_nRxMsg.m_sbyInfo[5] := 00;
        m_nRxMsg.m_sbyInfo[6] := 00;
        m_nRxMsg.m_sbyInfo[7] := 00;
      end;
    end;
end;


procedure CBTIMeter.CreateOutMSG(param : double; sm : byte; tar : byte);
begin                         //sm - вид энергии; tar - тарифф
   m_nRxMsg.m_sbyType    := DL_DATARD_IND;
   m_nRxMsg.m_sbyFor     := DIR_L2TOL3;
   m_nRxMsg.m_swObjID    := m_nP.m_swMID;
   m_nRxMsg.m_swLen      := 11 + 9 + sizeof(double);
   m_nRxMsg.m_sbyInfo[0] := 9 + sizeof(double);
   m_nRxMsg.m_sbyInfo[1] := TempCurrP + sm;
   m_nRxMsg.m_sbyInfo[8] := tar;
   move(param, m_nRxMsg.m_sbyInfo[9], sizeof(double));
   m_nRxMsg.m_sbyDirID   := IsUpdate;
   m_nRxMsg.m_sbyServerID:= 0;
end;

procedure  CBTIMeter.ReadEnergyDay(var pMsg:CMessage);
var param     : single;
        i     : integer;
    LengthMSG : integer;
    tmp       : double;
begin
  try
   i := 0;
   LengthMSG := pMsg.m_sbyInfo[2]*$100 + pMsg.m_sbyInfo[3];
   if pMsg.m_sbyInfo[LengthMSG-10]=1 then  begin
      if EventBox<>Nil then EventBox.FixEvents(ET_CRITICAL,'Энергия в сутки : ответ неполный, отсутствуют некоторые данные!!!');
      TraceL(2,m_nP.m_swMID,'(__)CL2MD::>Энергия в сутки : ответ неполный, отсутствуют некоторые данные!!!');
      exit;
   end;
      
   while i*4 < LengthMSG - 16 do
   begin
     EncodeFormatBTIFloat(@pMsg.m_sbyInfo[6 + i*4], @param);
     PrepareFloat(param);
     try
       param := param {/ 1000};
     except
       param := 0;
     end;
     tmp := param;
     CreateOutMSG(tmp, i div 5, i mod 5{ + 1});
     WriteDate();
     Inc(i);
     FPUT(BOX_L3_BY, @m_nRxMsg);
   end;
  finally
   m_nRepTimer.OffTimer;
   SendSyncEvent;
  end; 
end;

procedure  CBTIMeter.ReadEnergyMon(var pMsg:CMessage);
var param     : single;
    i         : integer;
    LengthMSG : integer;
    tmp       : double;
begin
  try
   i := 0;
   LengthMSG := pMsg.m_sbyInfo[2]*$100 + pMsg.m_sbyInfo[3];
   if pMsg.m_sbyInfo[LengthMSG-10]=1 then  begin
      if EventBox<>Nil then EventBox.FixEvents(ET_CRITICAL,'Энергия в месяц : ответ неполный, отсутствуют некоторые данные!!!');
      TraceL(2,m_nP.m_swMID,'(__)CL2MD::>Энергия в месяц : ответ неполный, отсутствуют некоторые данные!!!');
      exit;
   end;   
   while i*4 < LengthMSG - 16 do
   begin
     EncodeFormatBTIFloat(@pMsg.m_sbyInfo[6 + i*4], @param);
     PrepareFloat(param);
     try
       param := param {/ 1000};
     except
       param := 0;
     end;
     tmp := param;
     CreateOutMSG(tmp, i div 5, i mod 5{ + 1});
     WriteDate();
     Inc(i);
     FPUT(BOX_L3_BY, @m_nRxMsg);
   end;
  finally
   m_nRepTimer.OffTimer;
   SendSyncEvent;
  end
end;

function  CBTIMeter.ReadNakEnDay(var pMsg:CMessage):Boolean;
var param     : single;
        i     : integer;
    LengthMSG : integer;
    tmp       : double;
begin
  try
   Result:=True;
   i := 0;
   LengthMSG := pMsg.m_sbyInfo[2]*$100 + pMsg.m_sbyInfo[3];
   
   while i*4 < LengthMSG - 16 do
   begin
     EncodeFormatBTIFloat(@pMsg.m_sbyInfo[6 + i*4], @param);
     PrepareFloat(param);
     try
       param := param {/ 1000};
     except
       param := 0;
     end;
     tmp := param;
     TraceL(2,0,'(__)CL2MD::>Полученные данные из канала :'+ FloatToStr(tmp));
     CreateOutMSG(tmp, i div 5, i mod 5{ + 1});
     WriteDate();
     FPUT(BOX_L3_BY, @m_nRxMsg);
     Inc(i);
   end;
  finally
    m_nRepTimer.OffTimer;
    SendSyncEvent;
  end;
end;

procedure  CBTIMeter.ReadNakEnMonth(var pMsg:CMessage);
var param     : single;
        i     : integer;
    LengthMSG : integer;
    tmp       : double;
begin
  try
   i := 0;
   LengthMSG := pMsg.m_sbyInfo[2]*$100 + pMsg.m_sbyInfo[3];

   if pMsg.m_sbyInfo[LengthMSG-10]=1 then  begin
      if EventBox<>Nil then EventBox.FixEvents(ET_CRITICAL,'Месячный архив : ответ неполный, отсутствуют некоторые данные!!!');
      TraceL(2,m_nP.m_swMID,'(__)CL2MD::>Месячный архив : ответ неполный, отсутствуют некоторые данные!!!');
      exit;
   end;

   while i*4 < LengthMSG - 16 do
   begin
     EncodeFormatBTIFloat(@pMsg.m_sbyInfo[6 + i*4], @param);
     PrepareFloat(param);
     try
       param := param {/ 1000};
     except
       param := 0;
     end;
     tmp := param;
     CreateOutMSG(tmp, i div 5, i mod 5 {+ 1});
     WriteDate();
     FPUT(BOX_L3_BY, @m_nRxMsg);
     Inc(i);
   end;
  finally
    m_nRepTimer.OffTimer;
    SendSyncEvent;
  end;
end;

procedure  CBTIMeter.ReadSresEnr(var pMsg:CMessage);
var param     : single;
        i     : integer;
    LengthMSG : integer;
    tmp       : double;
begin
  try
   i := 0;
   LengthMSG := pMsg.m_sbyInfo[2]*$100 + pMsg.m_sbyInfo[3];
   if pMsg.m_sbyInfo[LengthMSG-10]=1 then  begin
      if EventBox<>Nil then EventBox.FixEvents(ET_CRITICAL,'30-минутный интервальный архив : ответ неполный, отсутствуют некоторые данные!!!');
      TraceL(2,m_nP.m_swMID,'(__)CL2MD::>30-минутный интервальный архив : ответ неполный, отсутствуют некоторые данные!!!');
      exit;
   end;
   while i*4 < LengthMSG - 16 do
   begin
     EncodeFormatBTIFloat(@pMsg.m_sbyInfo[6 + i*4], @param);
     //PrepareFloat(param);
     try
         param := param / 2{000};
     except
         param := 0;
     end;
     tmp := param;
     CreateOutMSG(tmp, i, 0);
     m_nRxMsg.m_sbyInfo[2] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 5];
     m_nRxMsg.m_sbyInfo[3] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 6];
     m_nRxMsg.m_sbyInfo[4] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 7];
     m_nRxMsg.m_sbyInfo[5] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 8];
     m_nRxMsg.m_sbyInfo[6] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 9];
     m_nRxMsg.m_sbyInfo[7] := 0;
     //m_nRxMsg.m_sbyInfo[8] := m_nRxMsg.m_sbyInfo[5] * 2 + (m_nRxMsg.m_sbyInfo[6] div 30);
     m_nRxMsg.m_sbyInfo[8] := 0;
     m_nRxMsg.m_sbyServerID := m_nRxMsg.m_sbyInfo[5] * 2 + (m_nRxMsg.m_sbyInfo[6] div 30);
     Inc(i);
     FPUT(BOX_L3_BY, @m_nRxMsg);
   end;
  finally
    m_nRepTimer.OffTimer;
    SendSyncEvent;
  end;
end;

procedure  CBTIMeter.ReadSresEnrDay(var pMsg:CMessage);
var i,j         : byte;
    param       : single;
    dwParam     : DWORD;
    tmp         : double;
    LengthMSG   : integer;
begin
  try
   j     := 0;
   LengthMSG := pMsg.m_sbyInfo[2]*$100 + pMsg.m_sbyInfo[3];
   if pMsg.m_sbyInfo[LengthMSG-10]=1 then  begin
      if EventBox<>Nil then EventBox.FixEvents(ET_CRITICAL,'30-минутный архив: ответ неполный, отсутствуют некоторые данные!!!');
      TraceL(2,m_nP.m_swMID,'(__)CL2MD::>30-минутный архив : ответ неполный, отсутствуют некоторые данные!!!');
      exit;
   end;

   param := 0;
   CreateOutMSG(param, 0, 0);
   while j*192 < LengthMSG - 16 do
   begin
     for i := 47 downto 0 do
     begin       {Проверить как сохраняются и читаются архивы}
       EncodeFormatBTIFloat(@pMsg.m_sbyInfo[6 + i*4 + j*192], @param);
       move(param, dwParam, sizeof(dwParam));
       //if dwParam = $FFFFFFFF then
       //  continue;
       //PrepareFloat(param);

       try
         param := param / 2 {/ 1000};
       except
         param := 0;
       end;
       tmp                   := param;

       m_nRxMsg.m_swLen      := 11 + 9 + sizeof(double);
       m_nRxMsg.m_sbyInfo[0] := 9 + sizeof(double);
       m_nRxMsg.m_sbyInfo[1] := QRY_SRES_ENR_EP + j;
       //m_nRxMsg.m_sbyInfo[8] := i;

       m_nRxMsg.m_sbyInfo[8] := 0;
       m_nRxMsg.m_sbyServerID := i;
       if dwParam = $FFFFFFFF then
       Begin
        tmp := 0;
        m_nRxMsg.m_sbyServerID := m_nRxMsg.m_sbyServerID or $80;
       End;

       move(tmp, m_nRxMsg.m_sbyInfo[9], sizeof(double));
       m_nRxMsg.m_swLen      := 11 + 9 + sizeof(double);
       m_nRxMsg.m_sbyDirID   := 1;
       m_nRxMsg.m_sbyInfo[2] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 5];
       m_nRxMsg.m_sbyInfo[3] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 6];
       m_nRxMsg.m_sbyInfo[4] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 7];
       m_nRxMsg.m_sbyInfo[5] := 0;
       m_nRxMsg.m_sbyInfo[6] := 0;
       m_nRxMsg.m_sbyInfo[7] := 0;
       //Sleep(1);
       FPUT(BOX_L3_BY, @m_nRxMsg);
     end;
     Inc(j);
   end;
  finally
    m_nRepTimer.OffTimer;
    SendSyncEvent;
  end;
end;

procedure  CBTIMeter.ReadMaxPower(var pMsg:CMessage);
var param            : single;
        i            : integer;
    LengthMSG        : integer;
    tmp              : double;
    Year, Month, Day : word;
    TempDate         : TDateTime;
begin
   LengthMSG := pMsg.m_sbyInfo[2]*$100 + pMsg.m_sbyInfo[3];
   TempDate  := Now;
   for i := 0 to m_nTxMsg.m_sbyInfo[11] - 1 do
     cDateTimeR.DecMonth(TempDate);
   DecodeDate(TempDate, Year, Month, Day);
   i := 0;
   while i*6 < LengthMSG - 16 do
   begin
     EncodeFormatBTIFloat(@pMsg.m_sbyInfo[6 + i*6], @param);
     try
       param := param {/ 1000};
     except
       param := 0;
     end;
     tmp := param;
     if pMsg.m_sbyInfo[11+i*6] = $FF then
     begin
       Inc(i);
       continue;
     end;
     CreateOutMSG(tmp, i  div 4, i mod 4 + 1);
     m_nRxMsg.m_sbyInfo[2] := Year - 2000;
     m_nRxMsg.m_sbyInfo[3] := Month;
     m_nRxMsg.m_sbyInfo[4] := pMsg.m_sbyInfo[10+i*6];
     m_nRxMsg.m_sbyInfo[5] := pMsg.m_sbyInfo[11+i*6] div 2;
     m_nRxMsg.m_sbyInfo[6] := (pMsg.m_sbyInfo[11+i*6] mod 2) * 30;
     m_nRxMsg.m_sbyInfo[7] := 0;
     WriteDate();
     FPUT(BOX_L3_BY, @m_nRxMsg);
     Inc(i);
   end;
   m_nRepTimer.OffTimer;
   SendSyncEvent;
end;

procedure  CBTIMeter.ReadVzljotParam(var pMsg:CMessage);
var i                   : integer;
    param               : single;
    tmp                 : double;
    Depth               : Integer;
    year, month, day    : word;
    TempDate            : TDateTime;
begin
   Depth    := m_nTxMsg.m_sbyInfo[10]*$100 + m_nTxMsg.m_sbyInfo[11];
   TempDate := Now;
   for i := 0 to Depth - 1 do
     cDateTimeR.DecDate(TempDate);
   i := 0;
   DecodeDate(TempDate, year, month, day); year := year - 2000;
   while i*4 < pMsg.m_sbyInfo[2]*$100 + pMsg.m_sbyInfo[3] do
   begin
     move(pMsg.m_sbyInfo[6 + i*4], param, 4);
     tmp := param;
     CreateOutMSG(tmp, 0, 1);
     m_nRxMsg.m_sbyInfo[1] := QRY_POD_TRYB_HEAT + i;
     m_nRxMsg.m_sbyInfo[2] := year;
     m_nRxMsg.m_sbyInfo[3] := month;
     m_nRxMsg.m_sbyInfo[4] := day;
     m_nRxMsg.m_sbyInfo[5] := 0;
     m_nRxMsg.m_sbyInfo[6] := 0;
     m_nRxMsg.m_sbyInfo[7] := 0;
     FPUT(BOX_L3_BY, @m_nRxMsg);
     Inc(i);
   end;
   FinalAction;
end;
procedure  CBTIMeter.ReadPulsarParam(var pMsg:CMessage);
var i                   : integer;
    param               : single;
    tmp                 : double;
    Depth               : Integer;
    year, month, day    : word;
    TempDate            : TDateTime;
begin
   Depth    := m_nTxMsg.m_sbyInfo[10]*$100 + m_nTxMsg.m_sbyInfo[11];
   TempDate := Now;
   for i := 0 to Depth - 1 do
     cDateTimeR.DecDate(TempDate);
   i := 0;
   DecodeDate(TempDate, year, month, day); year := year - 2000;
   while i*4 < pMsg.m_sbyInfo[2]*$100 + pMsg.m_sbyInfo[3] do
   begin
     move(pMsg.m_sbyInfo[6 + i*4], param, 4);
     tmp := param;
     CreateOutMSG(tmp, 0, 1);
     m_nRxMsg.m_sbyInfo[1] := QRY_SUM_RASH_V + i;
     m_nRxMsg.m_sbyInfo[2] := year;
     m_nRxMsg.m_sbyInfo[3] := month;
     m_nRxMsg.m_sbyInfo[4] := day;
     m_nRxMsg.m_sbyInfo[5] := 0;
     m_nRxMsg.m_sbyInfo[6] := 0;
     m_nRxMsg.m_sbyInfo[7] := 0;
     FPUT(BOX_L3_BY, @m_nRxMsg);
     Inc(i);
   end;
   FinalAction;
end;



procedure  CBTIMeter.ReadCurrentParam(var pMsg:CMessage);
var param     : single;
    i         : integer;
    LengthMSG : integer;
    tmp       : double;
    byParam   : Byte;
    Year,Month,Day,Hour,Min,Sec,mSec:Word;
begin
   if (TempCurrP >= QRY_SUM_KORR_MONTH) and (TempCurrP <= QRY_WORK_TIME_ERR) then
   begin
     ReadVzljotParam(pMsg);
     exit;
   end;
   if (TempCurrP>=QRY_SUM_RASH_V) and (TempCurrP<=QRY_RASH_AVE_V) then
   begin
     ReadPulsarParam(pMsg);
     exit;
   end;
   i := 0;
   LengthMSG := pMsg.m_sbyInfo[2]*$100 + pMsg.m_sbyInfo[3];
   while i*4 < LengthMSG - 16 do
   begin

     DecodeDate(Now,Year,Month,Day);
     DecodeTime(Now,Hour,Min,Sec,mSec);
     m_nRxMsg.m_sbyInfo[2] := Year-2000;
     m_nRxMsg.m_sbyInfo[3] := Month;
     m_nRxMsg.m_sbyInfo[4] := Day;
     m_nRxMsg.m_sbyInfo[5] := Hour;
     m_nRxMsg.m_sbyInfo[6] := Min;
     m_nRxMsg.m_sbyInfo[7] := Sec;

     if (i=0) then
     Begin
      byParam := SwitchCurrParam(TempCurrP, 0);
      if (byParam>=QRY_ENERGY_SUM_EP)and(byParam<=QRY_ENERGY_SUM_RM) then
      Begin
       CreateOutMSG(0, 0, 0);
       m_nRxMsg.m_sbyInfo[8] := 0;
       FPUT(BOX_L3_BY, @m_nRxMsg);
      End;
     End;

     EncodeFormatBTIFloat(@pMsg.m_sbyInfo[6 + i*4], @param);
     tmp := param;
     CreateOutMSG(tmp, 0, 0);  //ds
     byParam               := SwitchCurrParam(TempCurrP, i);
     m_nRxMsg.m_sbyInfo[1] := byParam;
     {
     m_nRxMsg.m_sbyInfo[2] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 5];
     m_nRxMsg.m_sbyInfo[3] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 6];
     m_nRxMsg.m_sbyInfo[4] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 7];
     m_nRxMsg.m_sbyInfo[5] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 8];
     m_nRxMsg.m_sbyInfo[6] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 9];
     m_nRxMsg.m_sbyInfo[7] := 0;
     }
     FPUT(BOX_L3_BY, @m_nRxMsg);
     Inc(i);
   end;
   m_nRepTimer.OffTimer;
   SendSyncEvent;
end;

procedure  CBTIMeter.ReadDateTime(var pMsg:CMessage);
var Year, Month, Day, Hour, Min, Sec, ms : word;
    nReq                                 : CQueryPrimitive;
begin
   DecodeDate(Now, Year, Month, Day);
   DecodeTime(Now, Hour, Min, Sec, ms);
   CreateOutMSG(0, 0, 0);
   m_nRxMsg.m_sbyInfo[0] := 8;
   m_nRxMsg.m_sbyInfo[1] := TempCurrP;
   m_nRxMsg.m_sbyInfo[2] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 11];
   m_nRxMsg.m_sbyInfo[3] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 12];
   m_nRxMsg.m_sbyInfo[4] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 13];
   m_nRxMsg.m_sbyInfo[5] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 14];
   m_nRxMsg.m_sbyInfo[6] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 15];
   m_nRxMsg.m_sbyInfo[7] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 16];
   FPUT(BOX_L3_BY, @m_nRxMsg);
   //FNCCorTime(pMsg);
   if ((m_nRxMsg.m_sbyInfo[2] <> (Year-2000)) or (m_nRxMsg.m_sbyInfo[3] <> Month) or
   (m_nRxMsg.m_sbyInfo[4] <> Day) or (m_nRxMsg.m_sbyInfo[5] <> Hour) or (m_nRxMsg.m_sbyInfo[6] <> Min) or
   ((abs(m_nRxMsg.m_sbyInfo[7] - Sec) > 5))) then
   Begin
    if (m_nCF.cbm_sCorrDir.ItemIndex = 1) then CreateKorrTimeReq(nReq)
     else
    if (m_nCF.cbm_sCorrDir.ItemIndex = 0) then FNCCorTime(pMsg);
   End;
   m_nRepTimer.OffTimer;
   SendSyncEvent();
end;
procedure CBTIMeter.FNCCorTime(var pMsg : CMessage);
var Time             : _SYSTEMTIME;
    Date             : TDateTime;
begin
   Time.wMilliseconds := 0;
   Time.wSecond    := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 16];
   Time.wMinute    := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 15];
   Time.wHour      := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 14];
   Time.wDay       := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 13];
   Time.wMonth     := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 12];
   Time.wYear      := 2000+pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 11];
   Date            := EncodeDate(Time.wYear, Time.wMonth, Time.wDay);
   Time.wDayOfWeek := DayOfWeek(Date);
   SetLocalTime(Time);
end;
procedure  CBTIMeter.ReadKorrTime(var pMsg:CMessage);
begin
   CreateOutMSG(0, 0, 0);
   m_nRxMsg.m_sbyInfo[0] := 8;
   m_nRxMsg.m_sbyInfo[1] := TempCurrP;
   m_nRxMsg.m_sbyInfo[2] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 10];
   m_nRxMsg.m_sbyInfo[3] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 11];
   m_nRxMsg.m_sbyInfo[4] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 12];
   m_nRxMsg.m_sbyInfo[5] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 13];
   m_nRxMsg.m_sbyInfo[6] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 14];
   m_nRxMsg.m_sbyInfo[7] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 15];
   FPUT(BOX_L3_BY, @m_nRxMsg);
   {m_nRepTimer.OffTimer;}
   SendSyncEvent();
end;

procedure CBTIMeter.ReadJrnl(var pMsg:CMessage);
var Nd               : word;
    i                : integer;
    LengthMsg        : word;
begin
   LengthMSG := pMsg.m_sbyInfo[2]*$100 + pMsg.m_sbyInfo[3];
   m_nRxMsg.m_swLen := 15 + 11;
   m_nRxMsg.m_sbyType     := PH_EVENTS_INT;
   m_nRxMsg.m_sbyFor      := DIR_L2TOL3;
   m_nRxMsg.m_swObjID     := m_nP.m_swMID;
   i := 0;
   m_nRxMsg.m_sbyServerID := DEV_BTI_SRV;
   while i*10 < LengthMSG - 18 do
   begin
     m_nRxMsg.m_sbyInfo[0]  := 15;
     m_nRxMsg.m_sbyInfo[1] := QRY_JRNL_T1 + m_nTxMsg.m_sbyInfo[6] - 1;
     m_nRxMsg.m_sbyInfo[2]  := pMsg.m_sbyInfo[6 + 9 + i*10];
     m_nRxMsg.m_sbyInfo[3]  := pMsg.m_sbyInfo[6 + 8 + i*10];
     m_nRxMsg.m_sbyInfo[4]  := pMsg.m_sbyInfo[6 + 7 + i*10];
     m_nRxMsg.m_sbyInfo[5]  := pMsg.m_sbyInfo[6 + 6 + i*10];
     m_nRxMsg.m_sbyInfo[6]  := pMsg.m_sbyInfo[6 + 5 + i*10];
     m_nRxMsg.m_sbyInfo[7]  := 0;
     m_nRxMsg.m_sbyInfo[8]  := m_nTxMsg.m_sbyInfo[6];
     move(pMsg.m_sbyInfo[6 + i*10], m_nRxMsg.m_sbyInfo[9], 5);
     FPUT(BOX_L3_BY, @m_nRxMsg);
     Inc(i);
   end;
   FinalAction;
end;


procedure CBTIMeter.ReadJrnlEx(var pMsg:CMessage);
var Nd               : word;
    i                : integer;
    LengthMsg        : word;
begin
   LengthMSG := pMsg.m_sbyInfo[2]*$100 + pMsg.m_sbyInfo[3];
   m_nRxMsg.m_swLen := 15 + 11;
   m_nRxMsg.m_sbyType     := PH_EVENTS_INT;
   m_nRxMsg.m_sbyFor      := DIR_L2TOL3;
   m_nRxMsg.m_swObjID     := m_nP.m_swMID;
   i := 0;
   m_nRxMsg.m_sbyServerID := DEV_BTI_SRV;
   while i*11 < LengthMSG - 18 do
   begin
     m_nRxMsg.m_sbyInfo[0]  := 15;
     m_nRxMsg.m_sbyInfo[1] := QRY_JRNL_T1 + m_nTxMsg.m_sbyInfo[6] - 1;
     m_nRxMsg.m_sbyInfo[2]  := pMsg.m_sbyInfo[6 + 10 + i*11];
     m_nRxMsg.m_sbyInfo[3]  := pMsg.m_sbyInfo[6 + 9 + i*11];
     m_nRxMsg.m_sbyInfo[4]  := pMsg.m_sbyInfo[6 + 8 + i*11];
     m_nRxMsg.m_sbyInfo[5]  := pMsg.m_sbyInfo[6 + 7 + i*11];
     m_nRxMsg.m_sbyInfo[6]  := pMsg.m_sbyInfo[6 + 6 + i*11];
     m_nRxMsg.m_sbyInfo[7]  := pMsg.m_sbyInfo[6 + 5 + i*11];
     m_nRxMsg.m_sbyInfo[8]  := m_nTxMsg.m_sbyInfo[6];
     move(pMsg.m_sbyInfo[6 + i*11], m_nRxMsg.m_sbyInfo[9], 5);
     FPUT(BOX_L3_BY, @m_nRxMsg);
     Inc(i);
   end;
   FinalAction;
end;
{0040 : ReadEnergyDay(pMsg);
          $0042 : ReadEnergyMon(pMsg);
          $0052 : ReadSresEnr(pMsg);
          $0054 : ReadSresEnrDay(pMsg);
          $0080 : ReadNakEnMonth(pMsg);
          $0081 : ReadNakEnDay(pMsg); }
procedure CBTIMeter.ReadPrirDayDbl(var pMsg:CMessage);
var i         : integer;
    LengthMSG : integer;
    tmp       : double;
begin
   i := 0;
   LengthMSG := pMsg.m_sbyInfo[2]*$100 + pMsg.m_sbyInfo[3];
   while i*8 < LengthMSG - 16 do
   begin
     move(pMsg.m_sbyInfo[6 + i*8], tmp, 8);
     CreateOutMSG(tmp, i div 5, i mod 5{ + 1});
     WriteDate();
     Inc(i);
     FPUT(BOX_L3_BY, @m_nRxMsg);
   end;
   m_nRepTimer.OffTimer;
   SendSyncEvent;
end;

procedure CBTIMeter.ReadPrirEnMonthDbl(var pMsg:CMessage);
var i         : integer;
    LengthMSG : integer;
    tmp       : double;
begin
   i := 0;
   LengthMSG := pMsg.m_sbyInfo[2]*$100 + pMsg.m_sbyInfo[3];
   while i*8 < LengthMSG - 16 do
   begin
     move(pMsg.m_sbyInfo[6 + i*8], tmp, 8);
     CreateOutMSG(tmp, i div 5, i mod 5{ + 1});
     WriteDate();
     Inc(i);
     FPUT(BOX_L3_BY, @m_nRxMsg);
   end;
   m_nRepTimer.OffTimer;
   SendSyncEvent;
end;

procedure CBTIMeter.Read30SrezEnergDbl(var pMsg:CMessage);
var i         : integer;
    LengthMSG : integer;
    tmp       : double;
begin
   i := 0;
   LengthMSG := pMsg.m_sbyInfo[2]*$100 + pMsg.m_sbyInfo[3];
   while i*8 < LengthMSG - 16 do
   begin
     move(pMsg.m_sbyInfo[6 + i*8], tmp, 8);
     CreateOutMSG(tmp, i, 0);
     m_nRxMsg.m_sbyInfo[2] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 5];
     m_nRxMsg.m_sbyInfo[3] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 6];
     m_nRxMsg.m_sbyInfo[4] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 7];
     m_nRxMsg.m_sbyInfo[5] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 8];
     m_nRxMsg.m_sbyInfo[6] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 9];
     m_nRxMsg.m_sbyInfo[7] := 0;
     //m_nRxMsg.m_sbyInfo[8] := m_nRxMsg.m_sbyInfo[5] * 2 + (m_nRxMsg.m_sbyInfo[6] div 30);
     m_nRxMsg.m_sbyInfo[8] := 0;
     m_nRxMsg.m_sbyServerID := m_nRxMsg.m_sbyInfo[5] * 2 + (m_nRxMsg.m_sbyInfo[6] div 30);
     Inc(i);
     FPUT(BOX_L3_BY, @m_nRxMsg);
   end;
   m_nRepTimer.OffTimer;
   SendSyncEvent;
end;

procedure CBTIMeter.Read30SrezEnergDayDbl(var pMsg:CMessage);
var i,j         : byte;
    dwParam     : DWORD;
    tmpR        : real48;
    tmp         : double;
    LengthMSG   : integer;
begin
   j    := 0;
   LengthMSG := pMsg.m_sbyInfo[2]*$100 + pMsg.m_sbyInfo[3];
   tmp  := 0;
   CreateOutMSG(tmp, 0, 0);
   while j*288 < LengthMSG - 16 do
   begin
     for i := 47 downto 0 do
     begin       {Проверить как сохраняются и читаются архивы}
       //EncodeFormatBTIFloat(@pMsg.m_sbyInfo[6 + i*4 + j*192], @param);
       move(pMsg.m_sbyInfo[6 + i*6 + j*288], tmpR, 6);
       move(tmpR, dwParam, sizeof(dwParam));
       tmp := tmpR;
       //if dwParam = $FFFFFFFF then
       //  continue;
       //PrepareFloat(param);
       try
         tmp := tmp / 2 {/ 1000};
       except
         tmp := 0;
       end;
       IsTrueValue(tmp);
       m_nRxMsg.m_swLen      := 11 + 9 + sizeof(double);
       m_nRxMsg.m_sbyInfo[0] := 9 + sizeof(double);
       m_nRxMsg.m_sbyInfo[1] := QRY_SRES_ENR_EP + j;
       //m_nRxMsg.m_sbyInfo[8] := i;

       m_nRxMsg.m_sbyInfo[8] := 0;
       m_nRxMsg.m_sbyServerID := i;
       if dwParam = $FFFFFFFF then
       Begin
        tmp := 0;
        m_nRxMsg.m_sbyServerID := m_nRxMsg.m_sbyServerID or $80;
       End;

       move(tmp, m_nRxMsg.m_sbyInfo[9], sizeof(double));
       m_nRxMsg.m_swLen      := 11 + 9 + sizeof(double);
       m_nRxMsg.m_sbyDirID   := 1;
       m_nRxMsg.m_sbyInfo[2] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 5];
       m_nRxMsg.m_sbyInfo[3] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 6];
       m_nRxMsg.m_sbyInfo[4] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 7];
       m_nRxMsg.m_sbyInfo[5] := 0;
       m_nRxMsg.m_sbyInfo[6] := 0;
       m_nRxMsg.m_sbyInfo[7] := 0;
       //Sleep(1);
       FPUT(BOX_L3_BY, @m_nRxMsg);
     end;
     Inc(j);
   end;
   m_nRepTimer.OffTimer;
   SendSyncEvent;
end;
procedure CBTIMeter.RES_RASH_HOR_V(var pMsg:CMessage);
var i,j         : byte;
    dwParam     : DWORD;
    tmpR        : real48;
    tmp         : double;
    LengthMSG   : integer;
begin
   j    := 0;
   LengthMSG := pMsg.m_sbyInfo[2]*$100 + pMsg.m_sbyInfo[3];
   tmp  := 0;
   CreateOutMSG(tmp, 0, 0);
   while j*288 < LengthMSG - 16 do
   begin
     for i := 47 downto 0 do
     begin       {Проверить как сохраняются и читаются архивы}
       //EncodeFormatBTIFloat(@pMsg.m_sbyInfo[6 + i*4 + j*192], @param);
       move(pMsg.m_sbyInfo[6 + i*6 + j*288], tmpR, 6);
       move(tmpR, dwParam, sizeof(dwParam));
       tmp := tmpR;
       //if dwParam = $FFFFFFFF then
       //  continue;
       //PrepareFloat(param);
       try
         tmp := tmp / 2 {/ 1000};
       except
         tmp := 0;
       end;
       IsTrueValue(tmp);
       m_nRxMsg.m_swLen      := 11 + 9 + sizeof(double);
       m_nRxMsg.m_sbyInfo[0] := 9 + sizeof(double);
       m_nRxMsg.m_sbyInfo[1] := QRY_RASH_HOR_V + j;
       //m_nRxMsg.m_sbyInfo[8] := i;

       m_nRxMsg.m_sbyInfo[8] := 0;
       m_nRxMsg.m_sbyServerID := i;
       if dwParam = $FFFFFFFF then
       Begin
        tmp := 0;
        m_nRxMsg.m_sbyServerID := m_nRxMsg.m_sbyServerID or $80;
       End;

       move(tmp, m_nRxMsg.m_sbyInfo[9], sizeof(double));
       m_nRxMsg.m_swLen      := 11 + 9 + sizeof(double);
       m_nRxMsg.m_sbyDirID   := 1;
       m_nRxMsg.m_sbyInfo[2] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 5];
       m_nRxMsg.m_sbyInfo[3] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 6];
       m_nRxMsg.m_sbyInfo[4] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 7];
       m_nRxMsg.m_sbyInfo[5] := 0;
       m_nRxMsg.m_sbyInfo[6] := 0;
       m_nRxMsg.m_sbyInfo[7] := 0;
       //Sleep(1);
       FPUT(BOX_L3_BY, @m_nRxMsg);
     end;
     Inc(j);
   end;
   m_nRepTimer.OffTimer;
   SendSyncEvent;
end;
function CBTIMeter.IsTrueValue(var dbVal:Double):Boolean;
Begin
   Result := True;
   if IsNaN(dbVal) or IsInfinite(dbVal) or (abs(dbVal)<0.000001) or (abs(dbVal)>1000000000) then
   Begin
    dbVal  := 0.0;
    Result := False;
   End;
End;

procedure CBTIMeter.ReadOneSliceAnswer(var pMsg:CMessage);
var rDate               : TDateTime;
    slN, i, mask        : integer;
    tmp                 : double;
    year, month, day,
    hour, min, sec, ms  : word;
begin
   move(pMsg.m_sbyInfo[6], rDate, sizeof(TDateTime));
   slN := pMsg.m_sbyInfo[6 + sizeof(TDateTime)];
   DecodeDate(rDate + slN * EncodeTime(0, 30, 0, 0), year, month, day);
   DecodeTime(rDate + slN * EncodeTime(0, 30, 0, 0), hour, min, sec, ms);
   tmp  := 0;
   CreateOutMSG(tmp, 0, 0);
   for i := 0 to 3 do
   begin
      move(pMsg.m_sbyInfo[6 + sizeof(TDateTime) + 1 + i* (sizeof(Double) + 1)], tmp, sizeof(Double));
      mask := pMsg.m_sbyInfo[6 + sizeof(TDateTime) + 1 + i* (sizeof(Double) + 1) + sizeof(Double)];

      m_nRxMsg.m_swLen      := 11 + 9 + sizeof(double);
      m_nRxMsg.m_sbyInfo[0] := 9 + sizeof(double);
      m_nRxMsg.m_sbyInfo[1] := QRY_SRES_ENR_EP + i;
      m_nRxMsg.m_sbyInfo[8] := 0;
      if mask > 0 then
        m_nRxMsg.m_sbyServerID := slN
      else
        m_nRxMsg.m_sbyServerID := slN or $80;
      move(tmp, m_nRxMsg.m_sbyInfo[9], sizeof(double));
      m_nRxMsg.m_sbyDirID   := 0;
      m_nRxMsg.m_sbyInfo[2] := year - 2000;
      m_nRxMsg.m_sbyInfo[3] := month;
      m_nRxMsg.m_sbyInfo[4] := day;
      m_nRxMsg.m_sbyInfo[5] := hour;
      m_nRxMsg.m_sbyInfo[6] := min;
      m_nRxMsg.m_sbyInfo[7] := sec;
      FPUT(BOX_L3_BY, @m_nRxMsg);
   end;
   m_nRepTimer.OffTimer;
   SendSyncEvent;
end;

procedure CBTIMeter.ReadEnMonthDbl(var pMsg:CMessage);
var i         : integer;
    LengthMSG : integer;
    tmp       : double;
begin
   i := 0;
   LengthMSG := pMsg.m_sbyInfo[2]*$100 + pMsg.m_sbyInfo[3];
   while i*8 < LengthMSG - 16 do
   begin
     move(pMsg.m_sbyInfo[6 + i*8], tmp, 8);
     CreateOutMSG(tmp, i div 5, i mod 5 {+ 1});
     WriteDate();
     FPUT(BOX_L3_BY, @m_nRxMsg);
     Inc(i);
   end;
   m_nRepTimer.OffTimer;
   SendSyncEvent;
end;



procedure CBTIMeter.ReadEnDayDbl(var pMsg:CMessage);
var i         : integer;
    LengthMSG : integer;
    tmp       : double;
begin
   i := 0;
   LengthMSG := pMsg.m_sbyInfo[2]*$100 + pMsg.m_sbyInfo[3];
   while i*8 < LengthMSG - 16 do
   begin
     move(pMsg.m_sbyInfo[6 + i*8], tmp, 8);
     CreateOutMSG(tmp, i div 5, i mod 5 {+ 1});
     WriteDate();
     FPUT(BOX_L3_BY, @m_nRxMsg);
     Inc(i);
   end;
   m_nRepTimer.OffTimer;
   SendSyncEvent;
end;



procedure CBTIMeter.ReadAllCurrParams(var pMsg:CMessage);
var i, tar                : integer;
    fValue                : single;
    outVal                : double;
    y, m, d, h, mn, s, ms : word;
begin
   if pMsg.m_swLen = 11 + 136 + 16 then
   begin
     DecodeDate(Now, y, m, d);
     DecodeTime(Now, h, mn, s, ms);
     m_nRxMsg.m_sbyInfo[2] := y - 2000;
     m_nRxMsg.m_sbyInfo[3] := m;
     m_nRxMsg.m_sbyInfo[4] := d;
     m_nRxMsg.m_sbyInfo[5] := h;
     m_nRxMsg.m_sbyInfo[6] := mn;
     m_nRxMsg.m_sbyInfo[7] := s;
     for i := 0 to 33 do
     begin
       move(pMsg.m_sbyInfo[6 + i*4], fValue, 4);
       outVal := fValue;
       case i of
         0, 1, 2, 3     : begin TempCurrP := QRY_ENERGY_SUM_EP; tar := i + 1; end;      //Накопленная энергия А+ (Т1-Т4)
         4, 5, 6, 7     : begin TempCurrP := QRY_ENERGY_SUM_EM; tar := i + 1 - 4; end;  //Накопленная энергия А- (Т1-Т4)
         8, 9, 10, 11   : begin TempCurrP := QRY_ENERGY_SUM_RP; tar := i + 1 - 8; end;  //Накопленная энергия R+ (Т1-Т4)
         12, 13, 14, 15 : begin TempCurrP := QRY_ENERGY_SUM_RM; tar := i + 1 - 12; end; //Накопленная энергия R- (Т1-Т4)
         16, 17, 18, 19 : begin TempCurrP := QRY_MGAKT_POW_S + i - 16; tar := 0; end;   //Мощность Р+ (S, A, B, C)
         20, 21, 22, 23 : begin TempCurrP := QRY_MGREA_POW_S + i - 20; tar := 0; end;   //Мощность Q+ (S, A, B, C)
         24, 25, 26     : begin TempCurrP := QRY_U_PARAM_A + i - 24; tar := 0; end;     //Напряжение (A, B, C)
         27, 28, 29     : begin TempCurrP := QRY_I_PARAM_A + i - 27; tar := 0; end;     //Ток (A, B, C)
         30             : begin TempCurrP := QRY_FREQ_NET; tar := 0; end;               //Частота
         31, 32, 33     : begin TempCurrP := QRY_KOEF_POW_A + i - 31; tar := 0; end;    //Коэффициенты мощности
       end;
       CreateOutMsg(outVal, 0, tar);
       FPUT(BOX_L3_BY, @m_nRxMsg);
     end;
   end;
   FinalAction;
end;
{
 QRY_SUM_RASH_V              = 129;   //Расход общий (м3)
  QRY_RASH_HOR_V              = 130;   //Расход в час (м3)
  QRY_RASH_DAY_V              = 131;   //Расход в сутки (м3)
  QRY_RASH_MON_V              = 132;   //Расход в месяц (м3)
  QRY_RASH_AVE_V              = 133;   //Расход средний (м3/ч)
}
procedure CBTIMeter.ReadCurrAllPulsar(var pMsg:CMessage);
var i, tar                : integer;
    fValue                : single;
    outVal                : double;
    y, m, d, h, mn, s, ms : word;
begin
   if pMsg.m_swLen = 11 + 80 + 16 then
   begin
     DecodeDate(Now, y, m, d);
     DecodeTime(Now, h, mn, s, ms);
     m_nRxMsg.m_sbyInfo[2] := y - 2000;
     m_nRxMsg.m_sbyInfo[3] := m;
     m_nRxMsg.m_sbyInfo[4] := d;
     m_nRxMsg.m_sbyInfo[5] := h;
     m_nRxMsg.m_sbyInfo[6] := mn;
     m_nRxMsg.m_sbyInfo[7] := s;
     for i := 0 to 20-1 do
     begin
       move(pMsg.m_sbyInfo[6 + i*4], fValue, 4);
       outVal := fValue;
       if (i>=0)and(i<=4)  then begin TempCurrP := QRY_SUM_RASH_V; tar := i - 0;  end;
       if (i>=5)and(i<=9)  then begin TempCurrP := QRY_RASH_DAY_V; tar := i - 5;  end;
       if (i>=10)and(i<=14)then begin TempCurrP := QRY_RASH_MON_V; tar := i - 10; end;
       if (i>=15)and(i<=19)then begin TempCurrP := QRY_RASH_AVE_V; tar := i - 15; end;
       if (TempCurrP=QRY_SUM_RASH_V)or(TempCurrP=QRY_RASH_AVE_V) then
       Begin
        CreateOutMsg(outVal, 0, tar);
        FPUT(BOX_L3_BY, @m_nRxMsg);
       End;
     end;
   end;
   FinalAction;
end;
procedure CBTIMeter.CreateMonFileReadReq(StartAdr, NumToRead : integer);
begin
   m_nTxMsg.m_sbyInfo[6] := StrToInt(m_nP.m_sddPHAddres) div $100;
   m_nTxMsg.m_sbyInfo[7] := StrToInt(m_nP.m_sddPHAddres) mod $100;
   m_nTxMsg.m_sbyInfo[8] := TempCurrP;
   m_nTxMsg.m_sbyInfo[9] := Depth;
   move(StartAdr, m_nTxMsg.m_sbyInfo[10], 4);
   m_nTxMsg.m_sbyInfo[14] := NumToRead mod $100;
   m_nTxMsg.m_sbyInfo[15] := NumToRead div $100;
   CreateMsg(m_nTxMsg.m_sbyInfo[0], 20, $FF1B);
   CreateMsgHead(m_nTxMsg, 20);
   FPUT(BOX_L1, @m_nTxMsg);
   m_nRepTimer.OnTimer(m_nP.m_swRepTime);
end;

procedure CBTIMeter.ReadMonitorParams(var pMsg:CMessage);
var StartPoz, NumToRead : Integer;
    Year, Month, Day, Hour,
    Min, Sec, ms        : Word;
    nMSize : Integer;
begin
   move(pMsg.m_sbyInfo[7], StartPoz, 4);
   NumToRead := pMsg.m_sbyInfo[11] + pMsg.m_sbyInfo[12]*$100;
   if m_MonData.Size <> StartPoz then  //Проверка правильности пришедшей инфы
     exit;
   move(pMsg.m_sbyInfo[13], nMSize, 4);
   m_MonData.Write(pMsg.m_sbyInfo[17], NumToRead);
   if EventBox<>Nil then EventBox.FixEvents(ET_RELEASE,'Получено '+IntToStr(m_MonData.Size)+' байт из '+IntToStr(nMSize));
   if pMsg.m_sbyInfo[6] = 0 then       //Проверка конца файла
      CreateMonFileReadReq(m_MonData.Size, 1024)
   else if pMsg.m_sbyInfo[6] = 2 then
     FinalAction
   else
   begin
     m_MonData.SaveToFile(m_strExePath+'arch.rar');
     if Assigned(m_MonData) then Begin m_MonData.Free;m_MonData := Nil; End;
     DecodeDate(trunc(Now) - Depth, Year, Month, Day);
     DecodeTime(trunc(Now) - Depth, Hour, Min, Sec, ms);
     m_nRxMsg.m_swLen       := 9 + 11;
     m_nRxMsg.m_sbyType     := PH_MON_ANS_IND;
     m_nRxMsg.m_sbyFor      := DIR_L2TOL3;
     m_nRxMsg.m_swObjID     := m_nP.m_swMID;
     m_nRxMsg.m_sbyServerID := DEV_BTI_SRV;
     m_nRxMsg.m_sbyInfo[0]  := 9;
     m_nRxMsg.m_sbyInfo[1]  := TempCurrP;
     m_nRxMsg.m_sbyInfo[2]  := Year - 2000;
     m_nRxMsg.m_sbyInfo[3]  := Month;
     m_nRxMsg.m_sbyInfo[4]  := Day;
     m_nRxMsg.m_sbyInfo[5]  := Hour;
     m_nRxMsg.m_sbyInfo[6]  := Min;
     m_nRxMsg.m_sbyInfo[7]  := Sec;
     m_nRxMsg.m_sbyInfo[8]  := 0;
     FPUT(BOX_L3_BY, @m_nRxMsg);
     FinalAction;
     if EventBox<>Nil then EventBox.FixEvents(ET_NORMAL,'Данные мониторинга получены.');
   end;
end;

function CBTIMeter.GetValue(var pMsg:CMessage;i:integer):Single;
Var
    byBuff : array[0..3] of Byte;
    fValue,nIV : Single;
Begin
    byBuff[0] := pMsg.m_sbyInfo[6 + 4 + i*4];
    byBuff[1] := pMsg.m_sbyInfo[6 + 5 + i*4];
    byBuff[2] := pMsg.m_sbyInfo[6 + 6 + i*4];
    byBuff[3] := pMsg.m_sbyInfo[6 + 7 + i*4];
    Move(byBuff[0],Result,sizeof(Single));
End;

function CBTIMeter.GetDWValue(var pMsg:CMessage;i:integer):DWORD;
begin
   move(pMsg.m_sbyInfo[6 + 4 + i*4], Result, sizeof(DWORD));
end;

procedure CBTIMeter.WriteI(var pMsg:CMessage;i:integer);
Var
    fValue : Double;
begin
    fValue := RV(GetValue(pMsg,i));
    fValue := fValue*m_nP.m_sfKI;
    Move(fValue,m_nRxMsg.m_sbyInfo[9],sizeof(fValue));
end;

procedure CBTIMeter.WriteU(var pMsg:CMessage;i:integer);
Var
    fValue : Double;
begin
    fValue := RV(GetValue(pMsg,i));
    fValue := fValue*m_nP.m_sfKU;
    Move(fValue,m_nRxMsg.m_sbyInfo[9],sizeof(fValue));
end;

procedure CBTIMeter.WriteP(var pMsg:CMessage;i:integer);
Var
    fValue : Double;
begin
    fValue := RVK(GetValue(pMsg,i));
    fValue := fValue*m_nP.m_sfKI*m_nP.m_sfKU/1000;
    Move(fValue,m_nRxMsg.m_sbyInfo[9],sizeof(fValue));
end;

procedure CBTIMeter.WriteE(var pMsg:CMessage;i:integer);
Var
    Value  : single;
    fValue : double;
    dwTemp : DWORD;
    pArray : PBYTEARRAY;
begin
    try
    fValue     := GetDWValue(pMsg,i)*m_nP.m_sfMeterKoeff;

    if fValue<=0.0000001 then
     fValue := 0;
    fValue := fValue*m_nP.m_sfKI*m_nP.m_sfKU;
    Move(fValue,m_nRxMsg.m_sbyInfo[9],sizeof(fValue));
    except

    end;
end;
{i := 0;
   LengthMSG := pMsg.m_sbyInfo[2]*$100 + pMsg.m_sbyInfo[3];
   while i*8 < LengthMSG - 16 do
   begin
     move(pMsg.m_sbyInfo[6 + i*8], tmp, 8);
     CreateOutMSG(tmp, i, 0);
     m_nRxMsg.m_sbyInfo[2] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 5];
     m_nRxMsg.m_sbyInfo[3] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 6];
     m_nRxMsg.m_sbyInfo[4] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 7];
     m_nRxMsg.m_sbyInfo[5] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 8];
     m_nRxMsg.m_sbyInfo[6] := pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 9];
     m_nRxMsg.m_sbyInfo[7] := 0;
     //m_nRxMsg.m_sbyInfo[8] := m_nRxMsg.m_sbyInfo[5] * 2 + (m_nRxMsg.m_sbyInfo[6] div 30);
     m_nRxMsg.m_sbyInfo[8] := 0;
     m_nRxMsg.m_sbyServerID := m_nRxMsg.m_sbyInfo[5] * 2 + (m_nRxMsg.m_sbyInfo[6] div 30);
     Inc(i);
     FPUT(BOX_L3_BY, @m_nRxMsg);
   end;
   m_nRepTimer.OffTimer;
   SendSyncEvent;

    CreateOutMSG(param : double; sm : byte; tar : byte);

    m_nRxMsg.m_sbyInfo[0] := 9 + sizeof(double);
   m_nRxMsg.m_sbyInfo[1] := TempCurrP + sm;
   m_nRxMsg.m_sbyInfo[8] := tar;}
procedure CBTIMeter.ReadPrirDayTranz(var pMsg:CMessage; TimePoz: integer);
var i     : integer;
    Year, Month, Day,
    Hour, Min, Sec, ms : word;
begin
   //DecodeDate(trunc(Now) + 1, Year, Month, Day);
   //DecodeTime(trunc(Now) + 1, Hour, Min, Sec, ms);
   DecodeDate(trunc(Now) + 0, Year, Month, Day);
   DecodeTime(trunc(Now) + 0, Hour, Min, Sec, ms);
   TempCurrP := QRY_ENERGY_DAY_EP;
   for i := 0 to 3 do
   begin
     CreateOutMSG(0, i, 0);
     WriteE(pMsg,i);
     m_nRxMsg.m_sbyInfo[2] := Year - 2000;
     m_nRxMsg.m_sbyInfo[3] := Month;
     m_nRxMsg.m_sbyInfo[4] := Day;
     m_nRxMsg.m_sbyInfo[5] := Hour;
     m_nRxMsg.m_sbyInfo[6] := Min;
     m_nRxMsg.m_sbyInfo[7] := Sec;
     FPUT(BOX_L3_BY, @m_nRxMsg);

     CreateOutMSG(0, i, 1);
     WriteE(pMsg,i);

     FPUT(BOX_L3_BY, @m_nRxMsg);

     CreateOutMSG(0, i, 2);
     FillChar(m_nRxMsg.m_sbyInfo[9], 0, 6);
     FPUT(BOX_L3_BY, @m_nRxMsg);

     CreateOutMSG(0, i, 3);
     FPUT(BOX_L3_BY, @m_nRxMsg);

     CreateOutMSG(0, i, 4);
     FPUT(BOX_L3_BY, @m_nRxMsg);
   end;
   FinalAction;
end;

procedure CBTIMeter.Read3PowerTranz(var pMsg:CMessage; TimePoz: integer);
var i : integer;
begin
   TempCurrP := QRY_E3MIN_POW_EP;
   for i := 0 to 3 do
   begin
     CreateOutMSG(0, i, 0);
     WriteP(pMsg,i);
     move(pMsg.m_sbyInfo[TimePoz], m_nRxMsg.m_sbyInfo[2], 6);
     FPUT(BOX_L3_BY, @m_nRxMsg);

     {
     CreateOutMSG(0, i, 1);
     WriteP(pMsg,i);
     move(pMsg.m_sbyInfo[TimePoz], m_nRxMsg.m_sbyInfo[2], 6);
     FPUT(BOX_L3_BY, @m_nRxMsg);

     CreateOutMSG(0, i, 2);
     FillChar(m_nRxMsg.m_sbyInfo[9], 0, 6);
     FPUT(BOX_L3_BY, @m_nRxMsg);

     CreateOutMSG(0, i, 3);
     FPUT(BOX_L3_BY, @m_nRxMsg);

     CreateOutMSG(0, i, 4);
     FPUT(BOX_L3_BY, @m_nRxMsg);
     }
   end;
   FinalAction;
end;

procedure CBTIMeter.ReadVoltTranz(var pMsg:CMessage; TimePoz: integer);
var i : integer;
begin
   TempCurrP := QRY_U_PARAM_A;
   for i := 0 to 2 do
   begin
     CreateOutMSG(0, i, 0);
     WriteU(pMsg,i);
     move(pMsg.m_sbyInfo[TimePoz], m_nRxMsg.m_sbyInfo[2], 6);
     FPUT(BOX_L3_BY, @m_nRxMsg);
   end;
   FinalAction;
end;

procedure CBTIMeter.ReadCurrTranz(var pMsg:CMessage; TimePoz: integer);
var i : integer;
begin
   TempCurrP := QRY_I_PARAM_A;
   for i := 0 to 2 do
   begin
     CreateOutMSG(0, i, 0);
     WriteI(pMsg,i);
     move(pMsg.m_sbyInfo[TimePoz], m_nRxMsg.m_sbyInfo[2], 6);
     FPUT(BOX_L3_BY, @m_nRxMsg);
   end;
   FinalAction;
end;

function CBTIMeter.ReadCC301TranzAns(var pMsg:CMessage):boolean;
begin
   if CRC301(pMsg.m_sbyInfo[6], pMsg.m_swLen - 11 - 16 - 6 - 2) then
   begin
     Result := true;
     case pMsg.m_sbyInfo[8] of
       2  : ReadPrirDayTranz(pMsg, pMsg.m_swLen - 11 - 6 - 10);
       5  : Read3PowerTranz(pMsg, pMsg.m_swLen - 11 - 6 - 10);
       10 : ReadVoltTranz(pMsg, pMsg.m_swLen - 11 - 6 - 10);
       11 : ReadCurrTranz(pMsg, pMsg.m_swLen - 11 - 6 - 10);
       24 : m_nKE := (pMsg.m_sbyInfo[8] + pMsg.m_sbyInfo[9]*$100)/1000000;
     end;
   end
   else Result := false;
end;

procedure CBTIMeter.ReadBadTranz(var pMsg:CMessage);
begin
   Self.m_byRep := m_nP.m_sbyRepMsg;
   m_nRepTimer.OnTimer(m_nP.m_swRepTime);
end;

procedure CBTIMeter.ReadCurrentParams(var pMsg:CMessage);
var TempDate       : TDateTime;
    PID, i, j      : integer;
    prm            : single;
    temp           : double;
    mask           : int64;
    y, m, d,
    h, mn, s, ms   : word;
begin
   i := 0;
   TempDate := EncodeDate(pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 5] + 2000, pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 6], pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 7]) +
               EncodeTime(pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 8], pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 9], 0, 0);
   while i*199 <= pMsg.m_swLen - 16 do
   begin
     TempCurrP := pMsg.m_sbyInfo[6 + i*199];
     move(pMsg.m_sbyInfo[6 + i*199 + 193], mask, 6);
     for j := 47 downto 0 do
     begin
       move(pMsg.m_sbyInfo[7 + i*199 + j*4], prm, 4);
       temp := prm;
       DecodeDate(TempDate + j*EncodeTime(0, 30, 0, 0), y, m, d);
       DecodeTime(TempDate + j*EncodeTime(0, 30, 0, 0), h, mn, s, ms);
       CreateOutMSG(temp, 0, 0);
       if IsBitInMask(mask, j) then
         m_nRxMsg.m_sbyServerID := j
       else
         m_nRxMsg.m_sbyServerID := j or $80;
       m_nRxMsg.m_sbyInfo[2] := y - 2000;
       m_nRxMsg.m_sbyInfo[3] := m;
       m_nRxMsg.m_sbyInfo[4] := d;
       m_nRxMsg.m_sbyInfo[5] := h;
       m_nRxMsg.m_sbyInfo[6] := mn;
       m_nRxMsg.m_sbyInfo[7] := s;
       m_nRxMsg.m_sbyDirID   := 1;
       FPUT(BOX_L3_BY, @m_nRxMsg);
     end;
     Inc(i);
   end;
   FinalAction;
end;
{procedure CBTIMeter.CreateEnergySumReq(var nReq: CQueryPrimitive);
Begin

End;}

//Tranz
procedure CBTIMeter.CreateEnergyDayReq(var nReq: CQueryPrimitive);
Begin             ///!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   TempCurrP              := nReq.m_swParamID;
   LastTarif              := nReq.m_swSpecc1;
   Depth                  := abs(nReq.m_swSpecc0);
   m_nTxMsg.m_sbyInfo[6]  := (StrToInt(m_nP.m_sddPHAddres)*4 + 1) div $100;
   m_nTxMsg.m_sbyInfo[7]  := (StrToInt(m_nP.m_sddPHAddres)*4 + 1) mod $100;      //Km
   m_nTxMsg.m_sbyInfo[8]  := 0; m_nTxMsg.m_sbyInfo[9] := 4; //NK
   m_nTxMsg.m_sbyInfo[10] := abs(nReq.m_swSpecc0) div $100;
   m_nTxMsg.m_sbyInfo[11] := abs(nReq.m_swSpecc0) mod $100; //Depth
   m_nTxMsg.m_sbyInfo[12] := 0;                             //Tariff
   m_nTxMsg.m_sbyInfo[13] := 5;                             //NT
   if nReq.m_swSpecc2 = 2 then
   begin
     CreateTranzMeterReq(nReq);
     exit;
   end;
   if nReq.m_swSpecc2 <> 1 then
     CreateMsg(m_nTxMsg.m_sbyInfo[0], 18, $0040)
   else
     CreateMsg(m_nTxMsg.m_sbyInfo[0], 18, $FF0C);
   CreateMSGHead(m_nTxMsg, 18);
   FPUT(BOX_L1, @m_nTxMsg);
   TraceM(2,m_nTxMsg.m_swObjID,'(__)CBTIM::>Out DRQ:',@m_nTxMsg);
End;             ///!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

procedure CBTIMeter.CreateEnergyMonReq(var nReq: CQueryPrimitive);
Begin
   TempCurrP              := nReq.m_swParamID;
   LastTarif              := nReq.m_swSpecc1;
   Depth                  := abs(nReq.m_swSpecc0);
   m_nTxMsg.m_sbyInfo[6]  := (StrToInt(m_nP.m_sddPHAddres)*4 + 1) div $100;
   m_nTxMsg.m_sbyInfo[7]  := (StrToInt(m_nP.m_sddPHAddres)*4 + 1) mod $100;      //Km
   m_nTxMsg.m_sbyInfo[8]  := 0; m_nTxMsg.m_sbyInfo[9] := 4; //NK
   m_nTxMsg.m_sbyInfo[10] := abs(nReq.m_swSpecc0) div $100;
   m_nTxMsg.m_sbyInfo[11] := abs(nReq.m_swSpecc0) mod $100;      //Depth
   m_nTxMsg.m_sbyInfo[12] := 0;               //Tariff
   m_nTxMsg.m_sbyInfo[13] := 5;                             //NT
   if nReq.m_swSpecc2 <> 1 then
     CreateMsg(m_nTxMsg.m_sbyInfo[0], 18, $0042)
   else
     CreateMsg(m_nTxMsg.m_sbyInfo[0], 18, $FF0D);
   CreateMSGHead(m_nTxMsg, 18);
   FPUT(BOX_L1, @m_nTxMsg);
   TraceM(2,m_nTxMsg.m_swObjID,'(__)CBTIM::>Out DRQ:',@m_nTxMsg);
End;

procedure CBTIMeter.CreateNakEnDayReq(var nReq: CQueryPrimitive);
Begin
   TempCurrP              := nReq.m_swParamID;
   LastTarif              := nReq.m_swSpecc1;
   Depth                  := abs(nReq.m_swSpecc0);
   m_nTxMsg.m_sbyInfo[6]  := (StrToInt(m_nP.m_sddPHAddres)*4 + 1) div $100;
   m_nTxMsg.m_sbyInfo[7]  := (StrToInt(m_nP.m_sddPHAddres)*4 + 1) mod $100;      //Km
   m_nTxMsg.m_sbyInfo[8]  := 0; m_nTxMsg.m_sbyInfo[9] := 4; //NK
   m_nTxMsg.m_sbyInfo[10] := abs(nReq.m_swSpecc0) div $100;
   m_nTxMsg.m_sbyInfo[11] := abs(nReq.m_swSpecc0) mod $100;      //Depth
   m_nTxMsg.m_sbyInfo[12] := 0;               //Tariff
   m_nTxMsg.m_sbyInfo[13] := 5;                             //NT
   if nReq.m_swSpecc2 <> 1 then
     CreateMsg(m_nTxMsg.m_sbyInfo[0], 18, $0081)
   else
     CreateMsg(m_nTxMsg.m_sbyInfo[0], 18, $FF11);
   CreateMSGHead(m_nTxMsg, 18);
   FPUT(BOX_L1, @m_nTxMsg);
   TraceM(2,m_nTxMsg.m_swObjID,'(__)CBTIM::>Out DRQ:',@m_nTxMsg);
End;
procedure CBTIMeter.REQ_RASH_DAY_V(var nReq: CQueryPrimitive);
Begin
   TempCurrP              := nReq.m_swParamID;
   LastTarif              := nReq.m_swSpecc1;
   Depth                  := abs(nReq.m_swSpecc0);
   m_nTxMsg.m_sbyInfo[6]  := (StrToInt(m_nP.m_sddPHAddres)*4 + 1) div $100;
   m_nTxMsg.m_sbyInfo[7]  := (StrToInt(m_nP.m_sddPHAddres)*4 + 1) mod $100;      //Km
   m_nTxMsg.m_sbyInfo[8]  := 0; m_nTxMsg.m_sbyInfo[9] := 1; //NK
   m_nTxMsg.m_sbyInfo[10] := abs(nReq.m_swSpecc0) div $100;
   m_nTxMsg.m_sbyInfo[11] := abs(nReq.m_swSpecc0) mod $100;      //Depth
   m_nTxMsg.m_sbyInfo[12] := 0;               //Tariff
   m_nTxMsg.m_sbyInfo[13] := 5;                             //NT
     CreateMsg(m_nTxMsg.m_sbyInfo[0], 18, $FF22);
   CreateMSGHead(m_nTxMsg, 18);
   FPUT(BOX_L1, @m_nTxMsg);
   TraceM(2,m_nTxMsg.m_swObjID,'(__)CBTIM::>Out DRQ:',@m_nTxMsg);
End;
procedure CBTIMeter.REQ_RASH_MON_V(var nReq: CQueryPrimitive);
Begin
   TempCurrP              := nReq.m_swParamID;
   LastTarif              := nReq.m_swSpecc1;
   Depth                  := abs(nReq.m_swSpecc0);
   m_nTxMsg.m_sbyInfo[6]  := (StrToInt(m_nP.m_sddPHAddres)*4 + 1) div $100;
   m_nTxMsg.m_sbyInfo[7]  := (StrToInt(m_nP.m_sddPHAddres)*4 + 1) mod $100;      //Km
   m_nTxMsg.m_sbyInfo[8]  := 0; m_nTxMsg.m_sbyInfo[9] := 1; //NK
   m_nTxMsg.m_sbyInfo[10] := abs(nReq.m_swSpecc0) div $100;
   m_nTxMsg.m_sbyInfo[11] := abs(nReq.m_swSpecc0) mod $100;      //Depth
   m_nTxMsg.m_sbyInfo[12] := 0;               //Tariff
   m_nTxMsg.m_sbyInfo[13] := 5;                             //NT
     CreateMsg(m_nTxMsg.m_sbyInfo[0], 18, $FF23);
   CreateMSGHead(m_nTxMsg, 18);
   FPUT(BOX_L1, @m_nTxMsg);
   TraceM(2,m_nTxMsg.m_swObjID,'(__)CBTIM::>Out DRQ:',@m_nTxMsg);
End;
procedure CBTIMeter.CreateNakEnMonthReq(var nReq: CQueryPrimitive);
Begin
   TempCurrP              := nReq.m_swParamID;
   LastTarif              := nReq.m_swSpecc1;
   Depth                  := abs(nReq.m_swSpecc0);
   m_nTxMsg.m_sbyInfo[6]  := (StrToInt(m_nP.m_sddPHAddres)*4 + 1) div $100;
   m_nTxMsg.m_sbyInfo[7]  := (StrToInt(m_nP.m_sddPHAddres)*4 + 1) mod $100;      //Km
   m_nTxMsg.m_sbyInfo[8]  := 0; m_nTxMsg.m_sbyInfo[9] := 4; //NK
   m_nTxMsg.m_sbyInfo[10] := abs(nReq.m_swSpecc0) div $100;
   m_nTxMsg.m_sbyInfo[11] := abs(nReq.m_swSpecc0) mod $100;      //Depth
   m_nTxMsg.m_sbyInfo[12] := 0;               //Tariff
   m_nTxMsg.m_sbyInfo[13] := 5;                             //NT
   if nReq.m_swSpecc2 <> 1 then
     CreateMsg(m_nTxMsg.m_sbyInfo[0], 18, $0080)
   else
     CreateMsg(m_nTxMsg.m_sbyInfo[0], 18, $FF10);
   CreateMSGHead(m_nTxMsg, 18);
   FPUT(BOX_L1, @m_nTxMsg);
   TraceM(2,m_nTxMsg.m_swObjID,'(__)CBTIM::>Out DRQ:',@m_nTxMsg);
End;

procedure CBTIMeter.CreateSresEnrReq(var nReq: CQueryPrimitive);
Begin
   TempCurrP              := nReq.m_swParamID;
   Depth                  := abs(nReq.m_swSpecc0);
   m_nTxMsg.m_sbyInfo[6]  := (StrToInt(m_nP.m_sddPHAddres)*4 + 1) div $100;
   m_nTxMsg.m_sbyInfo[7]  := (StrToInt(m_nP.m_sddPHAddres)*4 + 1) mod $100;      //Km
   m_nTxMsg.m_sbyInfo[8]  := 0; m_nTxMsg.m_sbyInfo[9] := 4; //NK
   m_nTxMsg.m_sbyInfo[10] := abs(nReq.m_swSpecc0) div $100;
   m_nTxMsg.m_sbyInfo[11] := abs(nReq.m_swSpecc0) mod $100;      //Depth
   case nReq.m_swSpecc2 of
     1 : CreateMsg(m_nTxMsg.m_sbyInfo[0], 16, $FF0E);
     3 : begin CreateOneSliceReq; exit; end;
     else CreateMsg(m_nTxMsg.m_sbyInfo[0], 16, $0052);
   end;
   CreateMSGHead(m_nTxMsg, 16);
   FPUT(BOX_L1, @m_nTxMsg);
   TraceM(2,m_nTxMsg.m_swObjID,'(__)CBTIM::>Out DRQ:',@m_nTxMsg);
End;

procedure CBTIMeter.CreateSresEnrDayReq(var nReq: CQueryPrimitive);
Begin
   TempCurrP              := nReq.m_swSpecc1 + QRY_SRES_ENR_EP - 1;
   LastTarif              := nReq.m_swSpecc1;
   Depth                  := abs(nReq.m_swSpecc0);
   m_nTxMsg.m_sbyInfo[6]  := (StrToInt(m_nP.m_sddPHAddres)*4 + 1) div $100;
   m_nTxMsg.m_sbyInfo[7]  := (StrToInt(m_nP.m_sddPHAddres)*4 + 1) mod $100;      //Km
   m_nTxMsg.m_sbyInfo[8]  := 0;
   m_nTxMsg.m_sbyInfo[9]  := 4; //NK
   m_nTxMsg.m_sbyInfo[10] := abs(nReq.m_swSpecc0) div $100;
   m_nTxMsg.m_sbyInfo[11] := abs(nReq.m_swSpecc0) mod $100;      //Depth
   case nReq.m_swSpecc2 of
     1 : CreateMsg(m_nTxMsg.m_sbyInfo[0], 16, $FF0F);
     3 : begin CreateOneSliceReq; exit; end;
   else CreateMsg(m_nTxMsg.m_sbyInfo[0], 16, $0054);
   end;
   CreateMSGHead(m_nTxMsg, 16);
   FPUT(BOX_L1, @m_nTxMsg);
   TraceM(2,m_nTxMsg.m_swObjID,'(__)CBTIM::>Out DRQ:',@m_nTxMsg);
End;
procedure CBTIMeter.REQ_RASH_HOR_V(var nReq: CQueryPrimitive);
Begin
   TempCurrP              := nReq.m_swSpecc1 + QRY_RASH_HOR_V - 1;
   LastTarif              := nReq.m_swSpecc1;
   Depth                  := abs(nReq.m_swSpecc0);
   m_nTxMsg.m_sbyInfo[6]  := (StrToInt(m_nP.m_sddPHAddres)*4 + 1) div $100;
   m_nTxMsg.m_sbyInfo[7]  := (StrToInt(m_nP.m_sddPHAddres)*4 + 1) mod $100;      //Km
   m_nTxMsg.m_sbyInfo[8]  := 0;
   m_nTxMsg.m_sbyInfo[9]  := 1; //NK
   m_nTxMsg.m_sbyInfo[10] := abs(nReq.m_swSpecc0) div $100;
   m_nTxMsg.m_sbyInfo[11] := abs(nReq.m_swSpecc0) mod $100;      //Depth
   CreateMsg(m_nTxMsg.m_sbyInfo[0], 16, $FF21);
   CreateMSGHead(m_nTxMsg, 16);
   FPUT(BOX_L1, @m_nTxMsg);
   TraceM(2,m_nTxMsg.m_swObjID,'(__)CBTIM::>Out DRQ:',@m_nTxMsg);
End;

procedure CBTIMeter.CreateOneSliceReq;
var t_date : TDateTime;
begin
   t_date := Now - EncodeTime(0, 30, 0, 0);
   m_nTxMsg.m_sbyInfo[6]  := StrToInt(m_nP.m_sddPHAddres) div $100;
   m_nTxMsg.m_sbyInfo[7]  := StrToInt(m_nP.m_sddPHAddres) mod $100;
   m_nTxMsg.m_sbyInfo[8 + sizeof(TDateTime)] := trunc(frac(t_date) / EncodeTime(0, 30, 0, 0));
   t_date := trunc(t_date);
   move(t_date, m_nTxMsg.m_sbyInfo[8], sizeof(TDateTime));
   CreateMsg(m_nTxMsg.m_sbyInfo[0], 10 + 2 + sizeof(TDateTime) + 1, $FF20);
   CreateMSGHead(m_nTxMsg, 10 + 2 + sizeof(TDateTime) + 1);
   FPUT(BOX_L1, @m_nTxMsg);
end;

procedure CBTIMeter.CreateAktPowerReq(var nReq: CQueryPrimitive);
var i : integer;
Begin
   TempCurrP              := nReq.m_swParamID;
   LastTarif              := 0;
   m_nTxMsg.m_sbyInfo[6]  := (StrToInt(m_nP.m_sddPHAddres) + 1) div $100;
   m_nTxMsg.m_sbyInfo[7]  := (StrToInt(m_nP.m_sddPHAddres) + 1)  mod $100;      //Km
   m_nTxMsg.m_sbyInfo[8]  := 0;
   m_nTxMsg.m_sbyInfo[9]  := 1; //NK
   m_nTxMsg.m_sbyInfo[13] := 0; m_nTxMsg.m_sbyInfo[14] := 0;
   m_nTxMsg.m_sbyInfo[12] := (m_nTxMsg.m_sbyInfo[12] and $00) or __SetMask[0] or __SetMask[1] or
                             __SetMask[2] or __SetMask[3];
   for i := 15 to 19 do
     m_nTxMsg.m_sbyInfo[i] := 0;
   if nReq.m_swSpecc2 <> 1 then
     CreateMsg(m_nTxMsg.m_sbyInfo[0], 24, $00F1)
   else
     CreateMsg(m_nTxMsg.m_sbyInfo[0], 24, $FF1A);
   CreateMSGHead(m_nTxMsg, 24);
   FPUT(BOX_L1, @m_nTxMsg);
   TraceM(2,m_nTxMsg.m_swObjID,'(__)CBTIM::>Out DRQ:',@m_nTxMsg);
End;

procedure CBTIMeter.CreateReaPowerReq(var nReq: CQueryPrimitive);
var i : integer;
Begin
   TempCurrP              := nReq.m_swParamID;
   LastTarif              := 0;
   m_nTxMsg.m_sbyInfo[6]  := (StrToInt(m_nP.m_sddPHAddres) + 1) div $100;
   m_nTxMsg.m_sbyInfo[7]  := (StrToInt(m_nP.m_sddPHAddres) + 1) mod $100;      //Km
   m_nTxMsg.m_sbyInfo[8]  := 0;
   m_nTxMsg.m_sbyInfo[9]  := 1; //NK
   m_nTxMsg.m_sbyInfo[13] := 0; m_nTxMsg.m_sbyInfo[14] := 0;
   m_nTxMsg.m_sbyInfo[12] := (m_nTxMsg.m_sbyInfo[12] and $00) or __SetMask[4] or __SetMask[5] or
                             __SetMask[6] or __SetMask[7];
   for i := 15 to 19 do
     m_nTxMsg.m_sbyInfo[i] := 0;
   if nReq.m_swSpecc2 <> 1 then
     CreateMsg(m_nTxMsg.m_sbyInfo[0], 24, $00F1)
   else
     CreateMsg(m_nTxMsg.m_sbyInfo[0], 24, $FF1A);
   CreateMSGHead(m_nTxMsg, 24);
   FPUT(BOX_L1, @m_nTxMsg);
   TraceM(2,m_nTxMsg.m_swObjID,'(__)CBTIM::>Out DRQ:',@m_nTxMsg);
End;

//Tranz
procedure CBTIMeter.CreateVoltReq(var nReq: CQueryPrimitive);
var i : integer;
Begin
   TempCurrP              := nReq.m_swParamID;
   LastTarif              := 0;
   m_nTxMsg.m_sbyInfo[6]  := (StrToInt(m_nP.m_sddPHAddres) + 1) div $100;
   m_nTxMsg.m_sbyInfo[7]  := (StrToInt(m_nP.m_sddPHAddres) + 1) mod $100;      //Km
   m_nTxMsg.m_sbyInfo[8]  := 0;
   m_nTxMsg.m_sbyInfo[9]  := 1; //NK
   m_nTxMsg.m_sbyInfo[12] := 0; m_nTxMsg.m_sbyInfo[13] := 0;
   m_nTxMsg.m_sbyInfo[14] := (m_nTxMsg.m_sbyInfo[14] and $00) or __SetMask[0] or __SetMask[1] or
                             __SetMask[2];
   for i := 15 to 19 do
     m_nTxMsg.m_sbyInfo[i] := 0;
   if nReq.m_swSpecc2 = 2 then
   begin
     CreateTranzMeterReq(nReq);
     exit;
   end;
   if nReq.m_swSpecc2 <> 1 then
     CreateMsg(m_nTxMsg.m_sbyInfo[0], 24, $00F1)
   else
     CreateMsg(m_nTxMsg.m_sbyInfo[0], 24, $FF1A);
   CreateMSGHead(m_nTxMsg, 24);
   FPUT(BOX_L1, @m_nTxMsg);
   TraceM(2,m_nTxMsg.m_swObjID,'(__)CBTIM::>Out DRQ:',@m_nTxMsg);
End;

//Tranz
procedure CBTIMeter.CreateCurrReq(var nReq: CQueryPrimitive);
var i : integer;
Begin
   TempCurrP              := nReq.m_swParamID;
   LastTarif              := 0;
   m_nTxMsg.m_sbyInfo[6]  := (StrToInt(m_nP.m_sddPHAddres) + 1) div $100;
   m_nTxMsg.m_sbyInfo[7]  := (StrToInt(m_nP.m_sddPHAddres) + 1) mod $100;      //Km
   m_nTxMsg.m_sbyInfo[8]  := 0;
   m_nTxMsg.m_sbyInfo[9]  := 1; //NK
   m_nTxMsg.m_sbyInfo[12] := 0; m_nTxMsg.m_sbyInfo[13] := 0;
   m_nTxMsg.m_sbyInfo[14] := (m_nTxMsg.m_sbyInfo[14] and $00) or __SetMask[3] or __SetMask[4] or
                             __SetMask[5];
   if nReq.m_swSpecc2 = 2 then
   begin
     CreateTranzMeterReq(nReq);
     exit;
   end;
   for i := 15 to 19 do
     m_nTxMsg.m_sbyInfo[i] := 0;
   if nReq.m_swSpecc2 <> 1 then
     CreateMsg(m_nTxMsg.m_sbyInfo[0], 24, $00F1)
   else
     CreateMsg(m_nTxMsg.m_sbyInfo[0], 24, $FF1A);
   CreateMSGHead(m_nTxMsg, 24);
   FPUT(BOX_L1, @m_nTxMsg);
   TraceM(2,m_nTxMsg.m_swObjID,'(__)CBTIM::>Out DRQ:',@m_nTxMsg);
End;

procedure CBTIMeter.CreateKoefPowerReq(var nReq: CQueryPrimitive);
var i : integer;
Begin
   TempCurrP              := nReq.m_swParamID;
   LastTarif              := 0;
   m_nTxMsg.m_sbyInfo[6]  := (StrToInt(m_nP.m_sddPHAddres) + 1) div $100;
   m_nTxMsg.m_sbyInfo[7]  := (StrToInt(m_nP.m_sddPHAddres) + 1) mod $100;      //Km
   m_nTxMsg.m_sbyInfo[8]  := 0;
   m_nTxMsg.m_sbyInfo[9]  := 1; //NK
   m_nTxMsg.m_sbyInfo[12] := 0; m_nTxMsg.m_sbyInfo[13] := 0;
   FillChar(m_nTxMsg.m_sbyInfo[12], 8, 0);
   m_nTxMsg.m_sbyInfo[17] := 2;
   if nReq.m_swSpecc2 <> 1 then
     CreateMsg(m_nTxMsg.m_sbyInfo[0], 24, $00F1)
   else
     CreateMsg(m_nTxMsg.m_sbyInfo[0], 24, $FF1A);
   CreateMSGHead(m_nTxMsg, 24);
   FPUT(BOX_L1, @m_nTxMsg);
   TraceM(2,m_nTxMsg.m_swObjID,'(__)CBTIM::>Out DRQ:',@m_nTxMsg);
end;

//tranz
procedure CBTIMeter.Create3MinPowerReq(var nReq: CQueryPrimitive);
var i : integer;
Begin
   TempCurrP              := nReq.m_swParamID;
   LastTarif              := 0;
   m_nTxMsg.m_sbyInfo[6]  := (StrToInt(m_nP.m_sddPHAddres) + 1) div $100;
   m_nTxMsg.m_sbyInfo[7]  := (StrToInt(m_nP.m_sddPHAddres) + 1) mod $100;      //Km
   m_nTxMsg.m_sbyInfo[8]  := 0;
   m_nTxMsg.m_sbyInfo[9]  := 1; //NK
   m_nTxMsg.m_sbyInfo[12] := 0; m_nTxMsg.m_sbyInfo[13] := 0;
   FillChar(m_nTxMsg.m_sbyInfo[12], 8, 0);
   m_nTxMsg.m_sbyInfo[17] := 4;
   if nReq.m_swSpecc2 = 2 then
   begin
     CreateTranzMeterReq(nReq);
     exit;
   end;
   if nReq.m_swSpecc2 <> 1 then
     CreateMsg(m_nTxMsg.m_sbyInfo[0], 24, $00F1)
   else
     CreateMsg(m_nTxMsg.m_sbyInfo[0], 24, $FF1A);
   CreateMSGHead(m_nTxMsg, 24);
   FPUT(BOX_L1, @m_nTxMsg);
   TraceM(2,m_nTxMsg.m_swObjID,'(__)CBTIM::>Out DRQ:',@m_nTxMsg);
end;

procedure CBTIMeter.CreateFreqReq(var nReq: CQueryPrimitive);
var i : integer;
Begin
   TempCurrP              := nReq.m_swParamID;
   LastTarif              := 0;
   m_nTxMsg.m_sbyInfo[6]  := (StrToInt(m_nP.m_sddPHAddres) + 1) div $100;
   m_nTxMsg.m_sbyInfo[7]  := (StrToInt(m_nP.m_sddPHAddres) + 1) mod $100;      //Km
   m_nTxMsg.m_sbyInfo[8]  := 0;
   m_nTxMsg.m_sbyInfo[9]  := 1; //NK
   m_nTxMsg.m_sbyInfo[12] := 0; m_nTxMsg.m_sbyInfo[13] := 0;
   m_nTxMsg.m_sbyInfo[14] := (m_nTxMsg.m_sbyInfo[14] and $00) or __SetMask[6];
   for i := 15 to 19 do
     m_nTxMsg.m_sbyInfo[i] := 0;
   if nReq.m_swSpecc2 <> 1 then
     CreateMsg(m_nTxMsg.m_sbyInfo[0], 24, $00F1)
   else
     CreateMsg(m_nTxMsg.m_sbyInfo[0], 24, $FF1A);
   CreateMSGHead(m_nTxMsg, 24);
   FPUT(BOX_L1, @m_nTxMsg);
   TraceM(2,m_nTxMsg.m_swObjID,'(__)CBTIM::>Out DRQ:',@m_nTxMsg);
End;

procedure CBTIMeter.CreateVzljotReq(var nReq: CQueryPrimitive);
var i : integer;
Begin
   TempCurrP              := nReq.m_swParamID;
   LastTarif              := 0;
   m_nTxMsg.m_sbyInfo[6]  := (StrToInt(m_nP.m_sddPHAddres) + 1) div $100;
   m_nTxMsg.m_sbyInfo[7]  := (StrToInt(m_nP.m_sddPHAddres) + 1) mod $100;      //Km
   m_nTxMsg.m_sbyInfo[8]  := 0;
   m_nTxMsg.m_sbyInfo[9]  := 1; //NK
   m_nTxMsg.m_sbyInfo[10] := nReq.m_swSpecc0 div $100;
   m_nTxMsg.m_sbyInfo[11] := nReq.m_swSpecc0 mod $100;
   FillChar(m_nTxMsg.m_sbyInfo[12], 8, 0);
   m_nTxMsg.m_sbyInfo[17] := 1;
   CreateMsg(m_nTxMsg.m_sbyInfo[0], 24, $00F1);
   CreateMSGHead(m_nTxMsg, 24);
   FPUT(BOX_L1, @m_nTxMsg);
   TraceM(2,m_nTxMsg.m_swObjID,'(__)CBTIM::>Out DRQ:',@m_nTxMsg);
End;

procedure CBTIMeter.CreateNakEnReq(var nReq:CQueryPrimitive);
var i : integer;
Begin
   TempCurrP              := nReq.m_swParamID;
   LastTarif              := nReq.m_swSpecc1;;
   m_nTxMsg.m_sbyInfo[6]  := (StrToInt(m_nP.m_sddPHAddres) + 1) div $100;
   m_nTxMsg.m_sbyInfo[7]  := (StrToInt(m_nP.m_sddPHAddres) + 1) mod $100;      //Km
   m_nTxMsg.m_sbyInfo[8]  := 0;
   m_nTxMsg.m_sbyInfo[9]  := 1; //NK
   m_nTxMsg.m_sbyInfo[12] := 0; m_nTxMsg.m_sbyInfo[13] := 0; m_nTxMsg.m_sbyInfo[14] := 0;
   m_nTxMsg.m_sbyInfo[15] := nReq.m_swSpecc1;
   for i := 16 to 19 do
     m_nTxMsg.m_sbyInfo[i] := 0;
   CreateMsg(m_nTxMsg.m_sbyInfo[0], 24, $00F1);
   CreateMSGHead(m_nTxMsg, 24);
   FPUT(BOX_L1, @m_nTxMsg);
   TraceM(2,m_nTxMsg.m_swObjID,'(__)CBTIM::>Out DRQ:',@m_nTxMsg);
end;

procedure CBTIMeter.CreateDateTimeReq(var nReq: CQueryPrimitive);
Begin
   TempCurrP              := nReq.m_swParamID;
   CreateMSG(m_nTxMsg.m_sbyInfo[0], 10, $0001);
   CreateMSGHead(m_nTxMsg, 10);
   FPUT(BOX_L1, @m_nTxMsg);
   TraceM(2,m_nTxMsg.m_swObjID,'(__)CBTIM::>Out DRQ:',@m_nTxMsg);
End;

procedure CBTIMeter.CreateKorrTimeReq(var nReq: CQueryPrimitive);
var h, s, m, ms : word;
    y, mn, d    : word;
Begin
   TempCurrP              := nReq.m_swParamID;
   DecodeDate(Now, y, mn, d); y := y - 2000;
   DecodeTime(Now, h, m, s, ms);
   m_nTxMsg.m_sbyInfo[6]  := (s + round(StrToFloat(m_nCF.edm_sKorrDelay.Text))) mod 60;   //sec
   m_nTxMsg.m_sbyInfo[7]  := (m + s div 60) mod 60;   //min
   m_nTxMsg.m_sbyInfo[8]  := (h + m div 60) mod 60;   //hour
   m_nTxMsg.m_sbyInfo[9]  := (d + h div 24);   //days
   //m_nTxMsg.m_sbyInfo[10] := (mn + d div cDateTimeR.DayPerMonth(mn, y)) mod 12;  //month
   //m_nTxMsg.m_sbyInfo[11] := (y + mn div 12) - 2000;   //year
   m_nTxMsg.m_sbyInfo[10] := mn;
   m_nTxMsg.m_sbyInfo[11] := y;
   CreateMSG(m_nTxMsg.m_sbyInfo[0], 16, $0002);
   CreateMSGHead(m_nTxMsg, 16);
   FPUT(BOX_L1, @m_nTxMsg);
   TraceM(2,m_nTxMsg.m_swObjID,'(__)CBTIM::>Out DRQ:',@m_nTxMsg);
End;

procedure CBTIMeter.CreateMaxPowerReq(var nReq: CQueryPrimitive);
begin
   TempCurrP              := nReq.m_swParamID;
   LastTarif              := nReq.m_swSpecc1;
   m_nTxMsg.m_sbyInfo[6]  := (StrToInt(m_nP.m_sddPHAddres)*4 + 1) div $100;
   m_nTxMsg.m_sbyInfo[7]  := (StrToInt(m_nP.m_sddPHAddres)*4 + 1) mod $100;      //Km
   m_nTxMsg.m_sbyInfo[8]  := 0; m_nTxMsg.m_sbyInfo[9] := 4; //NK
   m_nTxMsg.m_sbyInfo[10] := nReq.m_swSpecc0 div $100;
   m_nTxMsg.m_sbyInfo[11] := nReq.m_swSpecc0 mod $100;      //Depth
   m_nTxMsg.m_sbyInfo[12] := 1;               //Tariff
   m_nTxMsg.m_sbyInfo[13] := 4;                             //NT
   CreateMsg(m_nTxMsg.m_sbyInfo[0], 18, $00A2);
   CreateMSGHead(m_nTxMsg, 18);
   FPUT(BOX_L1, @m_nTxMsg);
   TraceM(2,m_nTxMsg.m_swObjID,'(__)CBTIM::>Out DRQ:',@m_nTxMsg);
end;

procedure CBTIMeter.CreateJrnlReq(var nReq: CQueryPrimitive);
var Year, Month, Day : word;
begin
   m_nTxMsg.m_sbyInfo[6]  := nReq.m_swParamID - QRY_JRNL_T1 + 1+2;//Type_Jrnl in automatic+2 
   m_nTxMsg.m_sbyInfo[7] := StrToInt(m_nP.m_sddPHAddres) div $100;
   m_nTxMsg.m_sbyInfo[8] := StrToInt(m_nP.m_sddPHAddres) mod $100;
   m_nTxMsg.m_sbyInfo[9] := 0;                                 //Hour
   if (nReq.m_swSpecc0 = 0) and (nReq.m_swSpecc1 = 0) and (nReq.m_swSpecc2 = 0) then
   begin
     DecodeDate(Now, Year, Month, Day);
     nReq.m_swSpecc0 := 5;
     nReq.m_swSpecc1 := Day;
     nReq.m_swSpecc2 := Month;
   end;
   m_nTxMsg.m_sbyInfo[10] := nReq.m_swSpecc1;                   //Day
   m_nTxMsg.m_sbyInfo[11] := nReq.m_swSpecc2;                   //Month
   m_nTxMsg.m_sbyInfo[12] := 1;                                 //StartInd
   m_nTxMsg.m_sbyInfo[13] := nReq.m_swSpecc0;                   //KolZapisei
   CreateMsg(m_nTxMsg.m_sbyInfo[0], 18, $FF09);
   CreateMSGHead(m_nTxMsg, 18);
   FPUT(BOX_L1, @m_nTxMsg);
end;

procedure CBTIMeter.CreateCurrentParamsReqEx(var nReq: CQueryPrimitive);
begin
   m_nTxMsg.m_sbyInfo[6] := StrToInt(m_nP.m_sddPHAddres) div $100;
   m_nTxMsg.m_sbyInfo[7] := StrToInt(m_nP.m_sddPHAddres) mod $100;
   m_nTxMsg.m_sbyInfo[8] := nReq.m_swParamID;
   move(nReq.m_swSpecc0, m_nTxMsg.m_sbyInfo[9], 2);
   CreateMSG(m_nTxMsg.m_sbyInfo[0], 15, $FF08);
   CreateMSGHead(m_nTxMsg, 15);
   FPUT(BOX_L1, @m_nTxMsg);
end;
procedure CBTIMeter.CreateCurrentParamsRash(var nReq: CQueryPrimitive);
var i : integer;
Begin
   TempCurrP              := nReq.m_swParamID;
   LastTarif              := 0;
   m_nTxMsg.m_sbyInfo[6]  := (StrToInt(m_nP.m_sddPHAddres) + 1) div $100;
   m_nTxMsg.m_sbyInfo[7]  := (StrToInt(m_nP.m_sddPHAddres) + 1)  mod $100;      //Km
   m_nTxMsg.m_sbyInfo[8]  := 0;
   m_nTxMsg.m_sbyInfo[9]  := 1; //NK
   m_nTxMsg.m_sbyInfo[13] := 0; m_nTxMsg.m_sbyInfo[14] := 0;
   for i := 15 to 19 do
   m_nTxMsg.m_sbyInfo[i] := 0;
   CreateMsg(m_nTxMsg.m_sbyInfo[0], 24, $FF24);
   CreateMSGHead(m_nTxMsg, 24);
   FPUT(BOX_L1, @m_nTxMsg);
   TraceM(2,m_nTxMsg.m_swObjID,'(__)CBTIM::>Out DRQ:',@m_nTxMsg);
End;





procedure CBTIMeter.CreateCurrentParamsMonEx(var nReq: CQueryPrimitive);
begin
    if Assigned(m_MonData) then Begin m_MonData.Free;m_MonData := Nil; End;
    m_MonData := TMemoryStream.Create;
    TempCurrP := nReq.m_swParamID;
    Depth     := nReq.m_swSpecc0;
    m_nTxMsg.m_sbyInfo[6] := StrToInt(m_nP.m_sddPHAddres) div $100;
    m_nTxMsg.m_sbyInfo[7] := StrToInt(m_nP.m_sddPhAddres) mod $100;
    m_nTxMsg.m_sbyInfo[8] := nReq.m_swParamID;
    m_nTxMsg.m_sbyInfo[9] := nReq.m_swSpecc0;
    FillChar(m_nTxMsg.m_sbyInfo[10], 4, 0);
    m_nTxMsg.m_sbyInfo[14] := $00;
    m_nTxMsg.m_sbyInfo[15] := $04;
    CreateMsg(m_nTxMsg.m_sbyInfo[0], 20, $FF1B);
    CreateMsgHead(m_nTxMsg, 20);
    FPUT(BOX_L1, @m_nTxMsg);
end;

procedure CBTIMeter.CreateTranzMeterReq(var nReq: CQueryPrimitive);
var nID : Integer;
begin
   case nReq.m_swParamID of
      QRY_ENERGY_DAY_EP, QRY_ENERGY_DAY_EM, QRY_ENERGY_DAY_RP, QRY_ENERGY_DAY_RM : nID := 2;
      QRY_E3MIN_POW_EP, QRY_E3MIN_POW_EM, QRY_E3MIN_POW_RP, QRY_E3MIN_POW_RM : nID := 5;
      QRY_U_PARAM_S, QRY_U_PARAM_A, QRY_U_PARAM_B, QRY_U_PARAM_C : nID := 10;
      QRY_I_PARAM_S, QRY_I_PARAM_A, QRY_I_PARAM_B, QRY_I_PARAM_C : nID := 11;
      QRY_KPRTEL_KE : nID := 24;
      else FinalAction;  
   end;
   CreateCC301Answer(m_nTxMsg.m_sbyInfo[6], nID);
   m_nTxMsg.m_sbyInfo[14] := StrToInt(m_nP.m_sddPHAddres) div $100;
   m_nTxMsg.m_sbyInfo[15] := StrToInt(m_nP.m_sddPHAddres) mod $100;
   CreateMsg(m_nTxMsg.m_sbyInfo[0], 6 + 8 + 2 + 10, $FF1C);
   CreateMSGHead(m_nTxMsg, 24 + 2);
   FPUT(BOX_L1, @m_nTxMsg);
end;

procedure CBTIMeter.CreateCC301Answer(var buf : array of byte; nID : integer);
begin
   buf[0] := StrToInt(m_nP.m_schPassword);
   buf[1] := 3;
   buf[2] := nID;
   buf[3] := 0;
   buf[4] := 0;
   buf[5] := 0;
   CRC301(buf[0], 6);
end;

procedure CBTIMeter.StopComplette(var pMsg:CMessage;wFnc:Word);
Begin
    case wFnc of
         $FF18:
         Begin
          if (pMsg.m_sbyInfo[6]=23) then
          Begin
           m_nRepTimer.OffTimer;
           SendSyncEvent;
          End
         End;
         
         else
         Begin
          TraceM(2,pMsg.m_swObjID,'(__)CBTIM::>STOP L2,3 CONF:',@pMsg);
          if EventBox<>Nil then EventBox.FixEvents(ET_RELEASE,'Удаленная команда выполнена.');
         End;
    End;
End;
procedure CBTIMeter.LayerSuspend;
Begin
    {
    FillChar(m_nTxMsg.m_sbyInfo[0],80,0);
    m_nTxMsg.m_sbyInfo[6] := 3;//L2 and L3
    m_nTxMsg.m_sbyInfo[7] := 0;//Suspend;
    CreateMsg(m_nTxMsg.m_sbyInfo[0], (7+1)+4, $FF05);
    CreateMSGHead(m_nTxMsg, (7+1)+4);
    FPUT(BOX_L1, @m_nTxMsg);
    TraceM(2,m_nTxMsg.m_swObjID,'(__)CBTIM::>STOP L2,3:',@m_nTxMsg);
    }
    SendQryBoolInit($FF18,213,23,0);
    TraceM(2,m_nTxMsg.m_swObjID,'(__)CBTIM::>STOP L2,3:',@m_nTxMsg);
End;
procedure CBTIMeter.LayerResume;
Begin
    {
    FillChar(m_nTxMsg.m_sbyInfo[0],80,0);
    m_nTxMsg.m_sbyInfo[6] := 3;//L2 and L3
    m_nTxMsg.m_sbyInfo[7] := 1;//Resume;
    CreateMsg(m_nTxMsg.m_sbyInfo[0], (7+1)+4, $FF05);
    CreateMSGHead(m_nTxMsg, (7+1)+4);
    FPUT(BOX_L1, @m_nTxMsg);
    TraceM(2,m_nTxMsg.m_swObjID,'(__)CBTIM::>STRT L2,3:',@m_nTxMsg);
    }
    SendQryBoolInit($FF18,213,23,1);
    TraceM(2,m_nTxMsg.m_swObjID,'(__)CBTIM::>STRT L2,3:',@m_nTxMsg);
End;
procedure CBTIMeter.SendQryBoolInit(nFCrcRb,nFEkom,nInnerF:Integer;nParam:Integer);
Var
    m_nTxMsg : CHMessage;
    fnc,wCRC:Word;
    //FPRID    : integer;
Begin
    //if MessageDlg(
    //'INIT::> FCRC:'+IntToHex(nFCrcRb,4)+
    //' FEKO:'+IntToStr(nFEkom)+
    //' FINN:'+IntToStr(nInnerF)+
    //' PARM:'+IntToStr(nParam),mtWarning,[mbOk,mbCancel],0)=mrOk then
    //Begin
     FillChar(m_nTxMsg.m_sbyInfo[0],80,0);
     m_nTxMsg.m_sbyInfo[6] := nInnerF; //10
     m_nTxMsg.m_sbyInfo[7] := nParam;
     CreateMsg(m_nTxMsg.m_sbyInfo[0], (26+16+1)+4, nFCrcRb);
     CreateMSGHead(m_nTxMsg, (26+16+1)+4);
     {
     if m_blIsRemCrc=True then
     Begin
      CreateMsgCrcRem(m_nTxMsg.m_sbyInfo[0], (26+16+1)+4, nFCrcRb);
      CreateMSGHeadCrcRem(FPRID,m_nTxMsg, (26+16+1)+4);
     End else
     if m_blIsRemEco=True then
     Begin
      m_nTxMsg.m_sbyInfo[0] := 1;
      m_nTxMsg.m_sbyInfo[1] := nFEkom;
      wCRC := CRCEco(m_nTxMsg.m_sbyInfo[0], 26+16);
      m_nTxMsg.m_sbyInfo[26+16] := Lo(wCRC);
      m_nTxMsg.m_sbyInfo[26+16+1] := Hi(wCRC);
      CreateMSGHeadCrcRem(FPRID,m_nTxMsg, (26+16+2));
     End;
     }
     {
     if not CRCRem(m_nTxMsg.m_sbyInfo[0], m_nTxMsg.m_sbyInfo[3] - 2) then
     begin
       //TraceM(4,pMsg.m_swObjID,'(__)CL4MD::>BTI CRC ERROR!!!:',@pMsg);
       exit;
     end;
     fnc    := m_nTxMsg.m_sbyInfo[4]*$100 + m_nTxMsg.m_sbyInfo[5];
     }
     TraceM(2,m_nTxMsg.m_sbyIntID,'(__)CCRRM::>Out DRQ:',@m_nTxMsg);
     FPUT(BOX_L1, @m_nTxMsg);
    //End;
End;

function CBTIMeter.SelfHandler(var pMsg:CMessage):Boolean;
Var
    res : Boolean;
Begin
    res := False;
    //Обработчик для L2(Таймер идр)
    Result := res;
End;

function CBTIMeter.LoHandler(var pMsg0:CMessage):Boolean;
Var
    res : Boolean;
    fnc : word;
    pMsg: CMessage;
Begin
    res := true;
    //Обработчик для L1
    {SendSyncEvent;
    m_nRepTimer.OffTimer;
    exit;    }
    move(pMsg0,pMsg,sizeof(CMessage));
    try
      case pMsg.m_sbyType of
        QL_CONNCOMPL_REQ: OnConnectComplette(pMsg);
        QL_DISCCOMPL_REQ: OnDisconnectComplette(pMsg);
        PH_DATA_IND:
        Begin
          //Переслать в L3 только значение и остановить таймер ожидания подтверждения
          fnc := pMsg.m_sbyInfo[4]*$100 + pMsg.m_sbyInfo[5];
          TraceM(2,pMsg.m_swObjID,'(__)CBTIM::>Inp DRQ:',@pMsg);
          if not CheckControlFields(pMsg) then
          begin
             TraceM(2,pMsg.m_swObjID,'(__)BTIM::>Error ControlField:',@pMsg);
             if EventBox<>Nil then EventBox.FixEvents(ET_CRITICAL,'Ответ неполный, отсутствуют некоторые данные!!!');
             res := false;
             exit;
          end;
          case fnc of
            $0040 : ReadEnergyDay(pMsg);
            $0042 : ReadEnergyMon(pMsg);
            $0052 : ReadSresEnr(pMsg);
            $0054 : ReadSresEnrDay(pMsg);
            $0001 : ReadDateTime(pMsg);
            $0002 : ReadKorrTime(pMsg);
            $0080 : ReadNakEnMonth(pMsg);
            $0081 : ReadNakEnDay(pMsg);
            $00C0 : ReadJrnl(pMsg);
            $00A2 : ReadMaxPower(pMsg);
            $00F1 : ReadCurrentParam(pMsg);
            $FF00,$FF01,
            $FF02,$FF03,
            $FF04,$FF05,
            $FF06,$FF07,
            $FF12,$FF13,
            $FF14,$FF15,$FF16,$FF17,$FF18,
            $FF19 : StopComplette(pMsg,fnc);
            $FF08 : ReadCurrentParams(pMsg);
            $FF09 : ReadJrnlEx(pMsg);
            $FF0C : ReadPrirDayDbl(pMsg);
            $FF0D : ReadPrirEnMonthDbl(pMsg);
            $FF0E : Read30SrezEnergDbl(pMsg);
            $FF0F : Read30SrezEnergDayDbl(pMsg);
            $FF10 : ReadEnMonthDbl(pMsg);
            $FF11 : ReadEnDayDbl(pMsg);
            $FF1A : ReadAllCurrParams(pMsg);
            $FF1B : ReadMonitorParams(pMsg);
            $FF1C : res := ReadCC301TranzAns(pMsg);
            $FF1D : ReadBadTranz(pMsg);
            $FF20 : ReadOneSliceAnswer(pMsg);
            $FF21 : RES_RASH_HOR_V(pMsg);
            $FF22 : ReadEnDayDbl(pMsg);
            $FF23 : ReadEnMonthDbl(pMsg);
            $FF24 : ReadCurrAllPulsar(pMsg);
          end;
          //if res then
          //  FinalAction;
        End;
      End;
    finally
     Result := res;
    end;
End;

function CBTIMeter.HiHandler(var pMsg:CMessage):Boolean;
Var
    res          : Boolean;
    nReq         : CQueryPrimitive;
begin
    res := False;
    //Обработчик для L3
    case pMsg.m_sbyType of
      QL_DATARD_REQ:
      Begin
       //Сформировать запрос,переслать в L1 и запустить таймер ожидания подтверждения
       Move(pMsg.m_sbyInfo[0],nReq,sizeof(CQueryPrimitive));
       //Sleep(20);
       if nReq.m_swParamID=QM_ENT_MTR_IND then Begin OnEnterAction;exit;End;
       if nReq.m_swParamID=QM_FIN_MTR_IND then Begin OnFinalAction;exit;End;
       if m_nP.m_sPhone='TEST' then
       Begin
        m_pDB.saveToDefData(nReq.m_swParamID,m_nP.m_swMID);
        m_nRepTimer.OffTimer;
        OnFinalAction;
       End;
       if nReq.m_swSpecc2 = $FF then
         case nReq.m_swParamID of
           QRY_MGAKT_POW_S, QRY_MGAKT_POW_A,
           QRY_MGAKT_POW_B, QRY_MGAKT_POW_C,
           QRY_MGREA_POW_S, QRY_MGREA_POW_A,
           QRY_MGREA_POW_B, QRY_MGREA_POW_C,
           QRY_U_PARAM_S, QRY_U_PARAM_A,
           QRY_U_PARAM_B, QRY_U_PARAM_C,
           QRY_I_PARAM_S, QRY_I_PARAM_A,
           QRY_I_PARAM_B, QRY_I_PARAM_C,
           QRY_FREQ_NET, QRY_KOEF_POW_A,
           QRY_KOEF_POW_B, QRY_KOEF_POW_C : CreateCurrentParamsReqEx(nReq);
         end
       else if nReq.m_swSpecc2 = $FF - 1 then
         case nReq.m_swParamId of
           QRY_MGAKT_POW_S, QRY_MGAKT_POW_A,
           QRY_MGAKT_POW_B, QRY_MGAKT_POW_C,
           QRY_MGREA_POW_S, QRY_MGREA_POW_A,
           QRY_MGREA_POW_B, QRY_MGREA_POW_C,
           QRY_U_PARAM_S, QRY_U_PARAM_A,
           QRY_U_PARAM_B, QRY_U_PARAM_C,
           QRY_I_PARAM_S, QRY_I_PARAM_A,
           QRY_I_PARAM_B, QRY_I_PARAM_C,
           QRY_FREQ_NET, QRY_KOEF_POW_A,
           QRY_KOEF_POW_B, QRY_KOEF_POW_C : CreateCurrentParamsMonEx(nReq);
         end
       else
       case nReq.m_swParamID of
         QRY_SUM_RASH_V,QRY_RASH_AVE_V : CreateCurrentParamsRash(nReq);
         QRY_ENERGY_SUM_EP, QRY_ENERGY_SUM_EM, QRY_ENERGY_SUM_RP, QRY_ENERGY_SUM_RM          : CreateNakEnReq(nReq);
         QRY_ENERGY_DAY_EP, QRY_ENERGY_DAY_EM, QRY_ENERGY_DAY_RP, QRY_ENERGY_DAY_RM          : CreateEnergyDayReq(nReq);
         QRY_ENERGY_MON_EP,QRY_ENERGY_MON_EM, QRY_ENERGY_MON_RP, QRY_ENERGY_MON_RM           : CreateEnergyMonReq(nReq);

         QRY_RASH_HOR_V          : REQ_RASH_HOR_V(nReq);
         QRY_RASH_DAY_V          : REQ_RASH_DAY_V(nReq);
         QRY_RASH_MON_V          : REQ_RASH_MON_V(nReq);

         QRY_SRES_ENR_EP, QRY_SRES_ENR_EM, QRY_SRES_ENR_RP, QRY_SRES_ENR_RM                  : CreateSresEnrDayReq(nReq);//CreateSresEnrReq(nReq);

         QRY_SRES_ENR_DAY_EP, QRY_SRES_ENR_DAY_EM, QRY_SRES_ENR_DAY_RP, QRY_SRES_ENR_DAY_RM  : CreateSresEnrDayReq(nReq);

         QRY_MAX_POWER_EP, QRY_MAX_POWER_EM, QRY_MAX_POWER_RP, QRY_MAX_POWER_RM              : CreateMaxPowerReq(nReq);
         QRY_NAK_EN_DAY_EP, QRY_NAK_EN_DAY_EM, QRY_NAK_EN_DAY_RP, QRY_NAK_EN_DAY_RM          : CreateNakEnDayReq(nReq);
         QRY_NAK_EN_MONTH_EP, QRY_NAK_EN_MONTH_EM, QRY_NAK_EN_MONTH_RP, QRY_NAK_EN_MONTH_RM  : CreateNakEnMonthReq(nReq);
         QRY_MGAKT_POW_S, QRY_MGAKT_POW_A, QRY_MGAKT_POW_B, QRY_MGAKT_POW_C                  : CreateAktPowerReq(nReq);
         QRY_MGREA_POW_S, QRY_MGREA_POW_A, QRY_MGREA_POW_B, QRY_MGREA_POW_C                  : CreateReaPowerReq(nReq);
         QRY_U_PARAM_A, QRY_U_PARAM_B, QRY_U_PARAM_C                                         : CreateVoltReq(nReq);
         QRY_I_PARAM_A, QRY_I_PARAM_B, QRY_I_PARAM_C                                         : CreateCurrReq(nReq);
         QRY_KOEF_POW_A, QRY_KOEF_POW_B, QRY_KOEF_POW_C                                      : CreateKoefPowerReq(nReq);
         QRY_E3MIN_POW_EP, QRY_E3MIN_POW_EM, QRY_E3MIN_POW_RP, QRY_E3MIN_POW_RM              : Create3MinPowerReq(nReq);
         QRY_FREQ_NET                                                                        : CreateFreqReq(nReq);
         QRY_DATA_TIME                                                                       : CreateDateTimeReq(nReq);
         QRY_KPRTEL_KE                                                                       : begin SendSyncEvent; exit; end;
         QRY_JRNL_T1, QRY_JRNL_T2, QRY_JRNL_T3, QRY_JRNL_T4                                  : CreateJrnlReq(nReq);
         QRY_POD_TRYB_HEAT, QRY_POD_TRYB_RASX, QRY_POD_TRYB_TEMP, QRY_OBR_TRYB_HEAT, QRY_OBR_TRYB_RASX,
         QRY_OBR_TRYB_TEMP, QRY_TEMP_COLD_WAT_DAY, QRY_POD_TRYB_RUN_TIME, QRY_WORK_TIME_ERR  : CreateVzljotReq(nReq);
         //QRY_KORR_TIME                                                                     : CreateKorrTimeReq(nReq);
         QRY_ENTER_COM                                                                       : LayerSuspend;
         QRY_EXIT_COM                                                                        : LayerResume;
       else
         begin
            FinalAction;
            exit;
         end;
       end;
       TraceM(2,pMsg.m_swObjID,'(__)CBTIM::>Out DRQ:',@pMsg);
       if nReq.m_swSpecc2 <> 2 then
         m_nRepTimer.OnTimer(m_nP.m_swRepTime)
       else
         m_nRepTimer.OnTimer(m_nP.m_swKE);
      End;
      QL_DATA_GRAPH_REQ    : HandQryRoutine(pMsg);
      QL_DATA_FIN_GRAPH_REQ: OnFinHandQryRoutine(pMsg);
      QL_LOAD_EVENTS_REQ   : AddEventsGraphQry(pMsg);
    End;
    Result := res;
End;

procedure CBTIMeter.HandQryRoutine(var pMsg:CMessage);
Var
    Date1, Date2 : TDateTime;
    param        : word;
    szDT         : word;
    pDS          : CMessageData;
begin
    IsUpdate := 1;
    //OnEnterAction;
    m_nObserver.ClearGraphQry;
    szDT := sizeof(TDateTime);
    Move(pMsg.m_sbyInfo[0],pDS,sizeof(CMessageData));
    Move(pDS.m_sbyInfo[0],Date1,szDT);
    Move(pDS.m_sbyInfo[szDT],Date2,szDT);
    m_byQweryMon := pDS.m_sbyInfo[2*szDT]; // m_byQweryMon=1 запрос мониторинга m_byQweryMon=0 запрос архива
    param := pDS.m_swData1;
    case param of
     QRY_ENERGY_DAY_EP   : AddEnergyDayGraphQry(Date1, Date2);
     QRY_ENERGY_MON_EP   : AddEnergyMonthGrpahQry(Date1, Date2);
     QRY_RASH_HOR_V,QRY_SRES_ENR_EP,QRY_SRES_ENR_EM,
     QRY_SRES_ENR_RP,QRY_SRES_ENR_RM
                         : AddSresEnergGrpahQry(param,Date1, Date2);
     QRY_RASH_DAY_V,QRY_NAK_EN_DAY_EP   : AddNakEnDayGrpahQry(param,Date1, Date2);
     QRY_RASH_MON_V,QRY_NAK_EN_MONTH_EP : AddNakEnMonthGrpahQry(param,Date1, Date2);
     QRY_MAX_POWER_EP    : AddMaxMonthEnGrpahQry(Date1, Date2);

     QRY_POD_TRYB_HEAT, QRY_POD_TRYB_RASX,
     QRY_POD_TRYB_TEMP, QRY_OBR_TRYB_HEAT,
     QRY_OBR_TRYB_RASX, QRY_OBR_TRYB_TEMP,
     QRY_TEMP_COLD_WAT_DAY, QRY_POD_TRYB_RUN_TIME,
     QRY_WORK_TIME_ERR   : AddVzljotParamsQry(Date1, Date2);
     QRY_LOAD_ALL_PARAMS : begin
                             AddEnergyDayGraphQry(Date1, Date2);
                             AddNakEnDayGrpahQry(param,Date1, Date2);
                             AddSresEnergGrpahQry(param,Date1, Date2);
                           end;
     QRY_MGAKT_POW_S, QRY_MGAKT_POW_A,
     QRY_MGAKT_POW_B, QRY_MGAKT_POW_C,
     QRY_MGREA_POW_S, QRY_MGREA_POW_A,
     QRY_MGREA_POW_B, QRY_MGREA_POW_C,
     QRY_U_PARAM_S, QRY_U_PARAM_A,
     QRY_U_PARAM_B, QRY_U_PARAM_C,
     QRY_I_PARAM_S, QRY_I_PARAM_A,
     QRY_I_PARAM_B, QRY_I_PARAM_C,
     QRY_FREQ_NET, QRY_KOEF_POW_A,
     QRY_KOEF_POW_B, QRY_KOEF_POW_C :
                            if m_byQweryMon = 0 then
                              AddCurrParamExQry(param, Date1)
                            else
                              AddCurrParamMonQry(param, Date1);

    end;
end;
{

  }
procedure CBTIMeter.OnFinHandQryRoutine(var pMsg:CMessage);
begin
    if m_nP.m_sbyEnable=1 then
    Begin
    OnFinalAction;
    TraceM(4,pMsg.m_swObjID,'(__)CL2MD::>BTIOnFinHandQryRoutine  DRQ:',@pMsg);
    IsUpdate := 0;
    End;
end;

procedure CBTIMeter.OnEnterAction;
begin
    TraceL(4,m_nP.m_swMID,'(__)CL2MD::>CBTIM OnEnterAction');
    if (m_nP.m_sbyEnable=1)and(m_nP.m_sbyModem=1) then
    OpenPhone else
    if m_nP.m_sbyModem=0 then FinalAction;
end;

procedure CBTIMeter.OnConnectComplette(var pMsg:CMessage);
Begin
    TraceL(4,m_nP.m_swMID,'(__)CL2MD::>CBTIM OnConnectComplette');
    m_nModemState := 1;
    if not((m_blIsRemCrc=True)or(m_blIsRemEco=True)) then FinalAction;
End;

procedure CBTIMeter.OnDisconnectComplette(var pMsg:CMessage);
Begin
    TraceL(4,m_nP.m_swMID,'(__)CL2MD::>CBTIM OnDisconnectComplette');
    m_nModemState := 0;
    //SendMSG(BOX_L2,DIR_QMTOL2,DL_ERRTMR1_IND);
    //FinalAction;
End;

procedure CBTIMeter.OnFinalAction;
begin
    TraceL(4,m_nP.m_swMID,'(__)CL2MD::>CBTIM OnFinalAction');

    FinalAction;
end;

procedure CBTIMeter.RunMeter;
Begin
    //m_nRepTimer.RunTimer;
    //m_nObserver.Run;
end;

function CBTIMeter.CheckControlFields(var pMsg : CMessage):boolean;
var res : boolean;
CodeHiTest:Integer;
begin
   res := true;
   if pMsg.m_swLen>2900 then
   Begin
    TraceL(2,m_nP.m_swMID,'(__)CL2MD::>CBTIM CODE Len!!!');
    Result:=False;
    exit;
   End;
   CodeHiTest:=StrToInt(m_nP.m_sddPHAddres);
   TraceL(2,m_nP.m_swMID,'(__)CL2MD::>CodeHiTest= '+ IntToHex(CodeHiTest,2) + ' из пакета = ' + IntToHex(pMsg.m_sbyInfo[pMsg.m_swLen - 11-4],2)+
                         ' LoCodeHiTest= '+ IntToHex(OldCodeLo,2) + ' из пакета = ' + IntToHex(pMsg.m_sbyInfo[pMsg.m_swLen - 11-3],2));

   //if not (pMsg.m_sbyInfo[pMsg.m_swLen - 11-4]<>Hi(CodeHiTest)) and (pMsg.m_sbyInfo[pMsg.m_swLen - 11-3]<>Lo(CodeHiTest))then
   if (pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 4]<>CodeHiTest) then
     Begin
       res := false; ////Проверка CODE
       TraceL(2,m_nP.m_swMID,'(__)CL2MD::>CBTIM CODE Error!!!');
       exit;
     End;
   if not CRC(pMsg.m_sbyInfo[0], pMsg.m_swLen - 11 - 2) then
     Begin
       res := false; ////Проверка CRC
       TraceL(2,m_nP.m_swMID,'(__)CL2MD::>CBTIM CRC Error!!!');
       exit;
     End;
    if (pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 4] <> m_nTxMsg.m_sbyInfo[m_nTxMsg.m_sbyInfo[3] - 4])
      and (pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 3] <> m_nTxMsg.m_sbyInfo[m_nTxMsg.m_sbyInfo[3] - 3]) then
     Begin
       if (pMsg.m_sbyInfo[4] <> $FF) and (pMsg.m_sbyInfo[5] <> $1C) then
       res := false; //Проверка поле CODE
       TraceL(2,m_nP.m_swMID,'(__)CL2MD::>CBTIM Error Address.Denided!');
       exit;
     End;
//   if (pMsg.m_sbyInfo[pMsg.m_swLen - 11 - 10] <> 0) then
//     begin
//       res := False; //Проверка кода достоверности
//       TraceL(2,m_nP.m_swMID,'(__)CL2MD::>CBTIM CODE INDENT Error!!!');
//       //SendSyncEvent;
//     end;
   Result := res;
end;

function  CBTIMeter.CRC(var buf : array of byte; count : word):boolean;
var i                 : integer;
    CRCHi, CRCLo, ind : byte;
begin
  CRCHi   := $FF;
  CRCLo   := $FF;
  Result  := true;
  if count>2900 then Begin Result:=False;exit;End;
  for i := 0 to count - 1 do
  begin
    ind:= CRCHi xor buf[i];
    CRCHi:= CRCLo xor srCRCHi[ind];
    CRCLo:= srCRCLo[ind];
  end;
  if (buf[count] <> CRCHi) and (buf[count+1] <> CRCLo) then
    Result := false;
  buf[count]   := CRCHi;
  buf[count+1] := CRCLo;
end;

function CBTIMeter.CRC301(var buf : array of byte; cnt : word):boolean;
var
    CRChiEl             : byte;
    CRCloEl             : byte;
    i                   : byte;
    cmp                 : byte;
    idx                 : byte;
begin
    Result  := true;
    CRChiEl := $FF;
    CRCloEl := $FF;
    cmp     := cnt-1;
    if cnt >= 300 then
    begin
       Result := false;
       exit;
    end;
    for i:=0 to cmp do
    begin
     idx       := (CRChiEl Xor buf[i]) And $FF;
     CRChiEl   := (CRCloEl Xor CRCHI[idx]);
     CRCloEl   := CRCLO[idx];
    end;
    if (CRCloEl <> buf[cnt]) and (CRChiEl <> buf[cnt+1]) then
      Result := false;
    buf[cnt]    := CRCloEl;
    buf[cnt+1]  := CRChiEl;
end;

End.

