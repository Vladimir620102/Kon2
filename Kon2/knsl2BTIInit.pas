unit knsl2BTIInit;

interface
uses
Windows, Classes, SysUtils,SyncObjs,stdctrls,comctrls,utltypes,utlbox,utlconst,knsl2meter,utlmtimer
,knsl5tracer, utldatabase, AdvProgressBar, AdvOfficeStatusBar, utlTimeDate;
type
    CBTIInit = class
    private
     metersType    : array of integer;
     GrID          : array of integer;
     m_pL1Tag      : SL1TAG;
     Addr          : byte;             //Адрес УСПД
     FState        : byte;
     m_nRepTimer   : CTimer;
     OldCodeHi     : byte;
     OldCodeLo     : byte;
     sTypeUSPD     : SL2USPDTYPE;
     sUSPDDev      : SL2USPDEVLIST;
     sPointsRead   : SL2USPDREADLIST;
     RepTimerCount : byte;
     m_nTxMSG      : CMessage;
     AbonID        : integer;
     NumbOfAction  : integer;
     PercNow       : integer;
     m_sTblL1      : SL1INITITAG;
    Public
     sUSPDCharDev  : SL2USPDCHARACTDEVLIST;
     sUSPDCharKan  : SL2USPDCHARACTKANALLIST;
     sUSPDCharGr   : SL2USPDCHARACTGRLIST;
     pStatusBar    : ^TAdvOfficeStatusBar;
     pProgressVar  : ^TAdvProgressBar;
     procedure Init(var pT : SL1TAG);
     procedure SetPortID(PortID : integer);
     procedure SetPortType(PortType : integer);
     procedure SetAbonID(AID : integer);
     procedure SetStateInPerc(Perc : integer; Status : string);
     function  SetIndexVM(nIndex : Integer):Integer;
     function  GenIndexVM:Integer;
     function  GenIndexSvVM:Integer;
     procedure FreeAllIndexVM;
     procedure FreeIndexVM(nIndex : Integer);
     function  SetIndexGr(nIndex : Integer):Integer;
     function  GenIndexGr:Integer;
     function  GenIndexSvGr:Integer;
     procedure FreeAllIndexGr;
     procedure FreeIndexGr(nIndex : Integer);
     function  SetIndexMID(nIndex : Integer):Integer;
     function  GenIndexMID:Integer;
     function  GenIndexSvMID:Integer;
     procedure FreeAllIndexMID;
     procedure FreeIndexMID(nIndex : Integer);
     function  GetRealPort(nPort:Integer):Integer;
     procedure RunModule;
     function  EventHandler(var pMsg:CMessage):boolean;
     function  SelfHandler(var pMsg:CMessage):Boolean;
     function  LoHandler(var pMsg:CMessage):Boolean;
     function  HiHandler(var pMsg:CMessage):Boolean;
     function  CRC(var buf : array of byte; count : integer):boolean;
     function  FindLenStrInArray(var buf : array of byte) : integer;
     function  ReadUSPDTypeAns(var pMsg:CMessage):boolean;
     function  ReadUSPDDevAns(var pMsg:CMessage):boolean;
     function  ReadUSPDCharDevAns(var pMsg:CMessage):boolean;
     function  ReadUSPDCharDevAnsEx(var pMsg:CMessage):boolean;
     function  ReadUSPDCharKanAns(var pMsg:CMessage):boolean;
     function  ReadUSPDCharKanAnsEx(var pMsg:CMessage):boolean;
     function  ReadUSPDCharGrAnsEx(var pMsg : CMessage):boolean;
     procedure CreateUSPDTypeReq();
     procedure CreateUSPDDevReq();
     procedure CreateUSPDCharDevReq();
     procedure CreateUSPDCharKanReq();
     procedure CreateUSPDCharGrReq();
     procedure AtuoFillAbon;
     function  EcnodeStrToVM(str : string; var buf : array of word) : integer;
     procedure CreateGroupsBTI;
     procedure CreateVMetersBTI;
     procedure CreateCountersBTI();
     procedure CreateDataReq();
     procedure CreateMSGHead(var pMsg : CMessage; length : word);
     procedure CreateMSG(var buffer : array of byte; length : word; fnc : word);
     function  CheckControlFields(var pMsg : CMessage):boolean;
     function  EncodeFormatBTIInt(var buffer : array of byte; length : word): longword;
     procedure EncodeFormatBTIFloat(const buf1 : PBYTEARRAY; buf2 : PBYTEARRAY);
     procedure SetState(byState:Byte);
     procedure ResetBTI();
     procedure StopBTI();
     function  GetState() : byte;
     procedure SetStateBti(blState:Byte);
     constructor Create;
     destructor Destroy;
    End;

var
    mBtiModule : CBTIInit;
implementation

function CBTIInit.GetState(): byte;
begin
   Result := FState;
end;
procedure CBTIInit.SetStateBti(blState : Byte);
begin
   FState := blState;
end;

function CBTIInit.EncodeFormatBTIInt(var buffer : array of byte; length : word):LongWord;
var i      : word;
begin
   Result := 0;
   for i := 0 to length - 1 do
   begin
     Result := Result*$100;
     Result := Result + buffer[i];
   end;
end;

procedure CBTIInit.EncodeFormatBTIFloat(const buf1 : PBYTEARRAY; buf2 : PBYTEARRAY);
begin
   buf2[3] := buf1[0];
   buf2[2] := buf1[1];
   buf2[1] := buf1[2];
   buf2[0] := buf1[3];
end;

procedure CBTIInit.Init(var pT : SL1TAG);
begin
   pStatusBar   := nil;
   pProgressVar := nil;
   Addr   := 1;
   Move(pT,m_pL1Tag,sizeof(SL1TAG));
   m_nRepTimer := CTimer.Create;
   m_nRepTimer.SetTimer(DIR_BTITOBTI, DL_REPMSG_TMR, 0, 0, BOX_L2);
   m_pDB.GetL1Table(m_sTblL1);
   //m_nRepTimer.OnTimer(5);  //////////
   Randomize;
   //ResetBTI;
   //FState := ST_READY_BTI;////////Закоментировать если нужна авто инициализация
end;

procedure CBTIInit.SetPortID(PortID : integer);
begin
   m_pL1Tag.m_sbyPortID := PortID;
end;

procedure CBTIInit.SetPortType(PortType : integer);
begin
   m_pL1Tag.m_sbyType := PortType;
end;

procedure CBTIInit.SetAbonID(AID : integer);
begin
   AbonID := AID;
end;

procedure CBTIInit.SetStateInPerc(Perc : integer; Status : string);
begin
   if (pStatusBar <> nil) and (pProgressVar <> nil) then
   begin
     pStatusBar.Panels.Items[0].Text  := Status;
     pProgressVar.Position            := Perc;
     pStatusBar.Refresh;
     pProgressVar.Refresh;
   end;
end;

procedure CBTIInit.ResetBTI;
begin
   Randomize;
   FState := ST_NULL_BTI;
   SetState(ST_NULL_BTI);
   m_nRepTimer.OnTimer(MAX_DELAY_IN_BTI_INIT);
   m_pDB.DelUSPDData(Addr);
   sPointsRead.m_swMaxPackLen    := 0;
   sPointsRead.m_swPRUSPDDev     := 1;
   sPointsRead.m_swPRUSPDCharDev := 1;
   sPointsRead.m_swPRUSPDCharKan := 1;
   sPointsRead.m_swPRUSPDCharGr  := 0;
   NumbOfAction                  := 1 + 5 + 3;
   PercNow                       := 0;
   SetStateInPerc(0, 'Инициализация модуля автозаполнения');
  // CreateDataReq;
end;

procedure CBTIInit.StopBTI();
begin
   ResetBTI;
   m_nRepTimer.OffTimer;
end;

function CBTIInit.CheckControlFields(var pMsg : CMessage):boolean;
var res : boolean;
begin
   res := true;
   with pMsg do
   begin
     if not CRC(m_sbyInfo[0], m_swLen - 11 - 2) then
     begin
       res := false; ////Проверка CRC
       TraceL(2, 2, 'Error crc!!!!!!!!!!');
     end;
     if (m_sbyInfo[m_swLen - 11 - 4] <> OldCodeHi) and (m_sbyInfo[m_swLen - 11 - 3] <> OldCodeLo) then
     begin
       res := false; //Проверка поле CODE
       TraceL(2, 2, 'Error Field Code!!!!!!!!!!');
     end;
     if (m_sbyInfo[m_swLen - 11 - 10] <> 0) then
     begin
       res := false; //Проверка кода достоверности
       TraceL(2, 2, 'Error Ill code!!!!!!!!!!');
     end;
   end;
   Result := res;
end;

function  CBTIInit.FindLenStrInArray(var buf : array of byte) : integer;
var i : integer;
begin
   i := 0;
   while buf[i] <> 0 do
     Inc(i);
   result := i;
end;

function  CBTIInit.ReadUSPDTypeAns(var pMsg:CMessage):boolean;
var res : boolean;
begin
   Inc(NumbOfAction);
   res := CheckControlFields(pMsg);
   if not res then
      exit;

   SetLength(sTypeUSPD.m_sUSPDName, 31);
   move(pMsg.m_sbyInfo[6], sTypeUSPD.m_sUSPDName[1], 32);

   SetLength(sTypeUSPD.m_sNameAdr, 31);
   move(pMsg.m_sbyInfo[38], sTypeUSPD.m_sNameAdr[1], 32);

   sTypeUSPD.m_swUSPDID             := Addr;
   sTypeUSPD.m_sdwWorkNumb          := EncodeFormatBTIInt(pMsg.m_sbyInfo[70], 4);
   sTypeUSPD.m_swVersPO             := EncodeFormatBTIInt(pMsg.m_sbyInfo[74], 2);

   sTypeUSPD.m_swNumIK              := EncodeFormatBTIInt(pMsg.m_sbyInfo[76], 2);
   sPointsRead.m_swPRUSPDCharKanMax := sTypeUSPD.m_swNumIK;

   sTypeUSPD.m_swNumGr              := EncodeFormatBTIInt(pMsg.m_sbyInfo[78], 2);
   sPointsRead.m_swPRUSPDCharGrMax  := sTypeUSPD.m_swNumGr;
   sTypeUSPD.m_swNumTZ              := EncodeFormatBTIInt(pMsg.m_sbyInfo[80], 2);
   sTypeUSPD.m_swMaxSupMetNum       := EncodeFormatBTIInt(pMsg.m_sbyInfo[82], 2);
   sPointsRead.m_swPRUSPDDevMax     := sTypeUSPD.m_swMaxSupMetNum;

   sTypeUSPD.m_swNumConMet          := EncodeFormatBTIInt(pMsg.m_sbyInfo[84], 2);
   SetLength(metersType, sTypeUSPD.m_swNumConMet);
   sPointsRead.m_swPRUSPDCharDevMax := sTypeUSPD.m_swNumConMet;
   SetLength(metersType, sTypeUSPD.m_swNumConMet);

   sTypeUSPD.m_swMaxPackLen         := EncodeFormatBTIInt(pMsg.m_sbyInfo[86], 2);
   sPointsRead.m_swMaxPackLen       := sTypeUSPD.m_swMaxPackLen;

   if not m_pDB.AddUSPDTypeData(sTypeUSPD) then
     res := false;
   if res then
   begin
     SetState(ST_USPD_TYPE_BTI);
     SetStateInPerc(15, 'Чтение информации о типах счетчиков');
   end;
   Result := res;
end;

function  CBTIInit.ReadUSPDDevAns(var pMsg:CMessage):boolean;
var res         : boolean;
    ReadNote,i  : integer;
begin
   res := CheckControlFields(pMsg);
   if not res then
     exit;

   ReadNote       := trunc((pMsg.m_swLen - 11 - 16)/18);
   sUSPDDev.Count := ReadNote;
   SetLength(sUspdDev.Items, ReadNote);

   for i := 0 to ReadNote - 1 do
   begin
     sUSPDDev.Items[i].m_swUSPDID := Addr;
     sUSPDDev.Items[i].m_swBMID   := EncodeFormatBTIInt(pMsg.m_sbyInfo[6 + i*18], 2) - 1;
     sUSPDDev.Items[i].m_swIDev   := sUSPDDev.Items[i].m_swBMID;
     SetLength(sUSPDDev.Items[i].m_sName, 15);
     move(pMsg.m_sbyInfo[8 + i*18], sUSPDDev.Items[i].m_sName[1], 16);
   end;
   for i := 0 to sUSPDDev.Count - 1 do
     if not m_pDB.AddUSPDDev(sUSPDDev.Items[i]) then
       res := false;
   if res then
   begin
     sPointsRead.m_swPRUSPDDev := sPointsRead.m_swPRUSPDDev + ReadNote;
     if  sPointsRead.m_swPRUSPDDev - 1 >= sPointsRead.m_swPRUSPDDevMax then
     begin
       SetState(ST_USPD_DEV_BTI);
       SetStateInPerc(25, 'Чтение информации о подключенных счетчиках');
     end;
   end;
   Result := res;
end;

function  CBTIInit.ReadUSPDCharDevAns(var pMsg:CMessage):boolean;
var res         : boolean;
    ReadNote,i  : integer;
    fPar        : single;
begin
   res := CheckControlFields(pMsg);

   ReadNote       := trunc((pMsg.m_swLen - 11 - 16)/64);
   sUSPDDev.Count := ReadNote;
   SetLength(sUSPDCharDev.Items, ReadNote);

   for i := 0 to ReadNote - 1 do
   begin
     sUSPDCharDev.Items[i].m_swUSPDID   := Addr;
     sUSPDCharDev.Items[i].m_swMID      := EncodeFormatBTIInt(pMsg.m_sbyInfo[6 + i*64], 2) - 1;
     sUSPDCharDev.Items[i].m_swBMID     := EncodeFormatBTIInt(pMsg.m_sbyInfo[8 + i*64], 2) - 1;
     sUSPDCharDev.Items[i].m_swNDev     := sUSPDCharDev.Items[i].m_swMID;
     sUSPDCharDev.Items[i].m_swIDev     := sUSPDCharDev.Items[i].m_swBMID;
     metersType[sUSPDCharDev.Items[i].m_swMID] := sUSPDCharDev.Items[i].m_swBMID;
     sUSPDCharDev.Items[i].m_sdwWorkNumb:= EncodeFormatBTIInt(pMsg.m_sbyInfo[10 + i*64], 4);
     sUSPDCharDev.Items[i].m_swANet     := EncodeFormatBTIInt(pMsg.m_sbyInfo[14 + i*64], 2);
     sUSPDCharDev.Items[i].m_swNK       := EncodeFormatBTIInt(pMsg.m_sbyInfo[16 + i*64], 2);
     sUSPDCharDev.Items[i].m_swLMax     := EncodeFormatBTIInt(pMsg.m_sbyInfo[18 + i*64], 2);
     EncodeFormatBTIFloat(@pMsg.m_sbyInfo[20 + i*64], @fPar);
     sUSPDCharDev.Items[i].m_sfKt  := fPar;
     EncodeFormatBTIFloat(@pMsg.m_sbyInfo[24 + i*64], @fPar);
     sUSPDCharDev.Items[i].m_sfKpr := fPar;
     sUSPDCharDev.Items[i].m_swKmb      := EncodeFormatBTIInt(pMsg.m_sbyInfo[28 + i*64], 2);
     sUSPDCharDev.Items[i].m_sdwMUmHi   := EncodeFormatBTIInt(pMsg.m_sbyInfo[30 + i*64], 4);
     sUSPDCharDev.Items[i].m_sdwMUmLo   := EncodeFormatBTIInt(pMsg.m_sbyInfo[34 + i*64], 4);
     SetLength(sUSPDCharDev.Items[i].m_sStrAdr, 31);
     move(pMsg.m_sbyInfo[38 + i*64], sUSPDCharDev.Items[i].m_sStrAdr[1], 32);
   end;
   for i := sPointsRead.m_swPRUSPDCharDev to sPointsRead.m_swPRUSPDCharDev + ReadNote - 1 do
     if not m_pDB.AddUSPDCharDev(sUSPDCharDev.Items[i - sPointsRead.m_swPRUSPDCharDev]) then
       res := false;
   if res then
   begin
     sPointsRead.m_swPRUSPDCharDev := sPointsRead.m_swPRUSPDCharDev + ReadNote;
     if  sPointsRead.m_swPRUSPDCharDev - 1 >= sPointsRead.m_swPRUSPDCharDevMax  then
     begin
       SetState(ST_USPD_CHARDEV_BTI);

     end;
   end;
   Result := res;
end;

function  CBTIInit.ReadUSPDCharDevAnsEx(var pMsg:CMessage):boolean;
var res         : boolean;
    ReadNote,i  : integer;
    fPar        : single;
    sm          : integer;
    StrLen      : integer;
begin
   res := CheckControlFields(pMsg);
   ReadNote       := 0;
   sm             := 0;
   while pMsg.m_swLen - 16 - 11 > sm do
   begin
     sm := sm + 32 + FindLenStrInArray(pMsg.m_sbyInfo[38 + sm]) + 1;
     Inc(ReadNote);
   end;
   sUSPDCharDev.Count := ReadNote;
   SetLength(sUSPDCharDev.Items, ReadNote);
   sm             := 0;
   ReadNote       := 0;
   while pMsg.m_swLen - 16 - 11 > sm do
   begin
     sUSPDCharDev.Items[ReadNote].m_swUSPDID   := Addr;
     sUSPDCharDev.Items[ReadNote].m_swMID      := EncodeFormatBTIInt(pMsg.m_sbyInfo[6 + sm], 2) - 1;
     sUSPDCharDev.Items[ReadNote].m_swBMID     := EncodeFormatBTIInt(pMsg.m_sbyInfo[8 + sm], 2) - 1;
     sUSPDCharDev.Items[ReadNote].m_swNDev     := sUSPDCharDev.Items[ReadNote].m_swMID;
     sUSPDCharDev.Items[ReadNote].m_swIDev     := sUSPDCharDev.Items[ReadNote].m_swBMID;
     metersType[sUSPDCharDev.Items[ReadNote].m_swMID] := sUSPDCharDev.Items[ReadNote].m_swBMID;
     sUSPDCharDev.Items[ReadNote].m_sdwWorkNumb:= EncodeFormatBTIInt(pMsg.m_sbyInfo[10 + sm], 4);
     sUSPDCharDev.Items[ReadNote].m_swANet     := EncodeFormatBTIInt(pMsg.m_sbyInfo[14 + sm], 2);
     sUSPDCharDev.Items[ReadNote].m_swNK       := EncodeFormatBTIInt(pMsg.m_sbyInfo[16 + sm], 2);
     sUSPDCharDev.Items[ReadNote].m_swLMax     := EncodeFormatBTIInt(pMsg.m_sbyInfo[18 + sm], 2);
     EncodeFormatBTIFloat(@pMsg.m_sbyInfo[20 + sm], @fPar);
     sUSPDCharDev.Items[ReadNote].m_sfKt  := fPar;
     EncodeFormatBTIFloat(@pMsg.m_sbyInfo[24 + sm], @fPar);
     sUSPDCharDev.Items[ReadNote].m_sfKpr := fPar;
     sUSPDCharDev.Items[ReadNote].m_swKmb      := EncodeFormatBTIInt(pMsg.m_sbyInfo[28 + sm], 2);
     sUSPDCharDev.Items[ReadNote].m_sdwMUmHi   := EncodeFormatBTIInt(pMsg.m_sbyInfo[30 + sm], 4);
     sUSPDCharDev.Items[ReadNote].m_sdwMUmLo   := EncodeFormatBTIInt(pMsg.m_sbyInfo[34 + sm], 4);
     StrLen                             := FindLenStrInArray(pMsg.m_sbyInfo[38 + sm]);
     SetLength(sUSPDCharDev.Items[ReadNote].m_sStrAdr, StrLen);
     move(pMsg.m_sbyInfo[38 + sm], sUSPDCharDev.Items[ReadNote].m_sStrAdr[1], StrLen);
     sm                                 := sm + 32 + StrLen + 1;
     Inc(ReadNote);
   end;
   for i := sPointsRead.m_swPRUSPDCharDev to sPointsRead.m_swPRUSPDCharDev + ReadNote - 1 do
     if not m_pDB.AddUSPDCharDev(sUSPDCharDev.Items[i - sPointsRead.m_swPRUSPDCharDev]) then
       res := false;
   if res then
   begin
     sPointsRead.m_swPRUSPDCharDev := sPointsRead.m_swPRUSPDCharDev + ReadNote;
     if  sPointsRead.m_swPRUSPDCharDev - 1 >= sPointsRead.m_swPRUSPDCharDevMax  then
     begin
       SetState(ST_USPD_CHARDEV_BTI);
       SetStateInPerc(35, 'Чтение информации о каналах');

     end;
   end;
   Result := res;
end;

function  CBTIInit.ReadUSPDCharKanAns(var pMsg:CMessage):boolean;
var res         : boolean;
    ReadNote,i  : integer;
    fPar        : single;
begin
   res := CheckControlFields(pMsg);

   ReadNote       := trunc((pMsg.m_swLen - 11 - 16)/52);
   sUSPDCharKan.Count := ReadNote;
   SetLength(sUSPDCharKan.Items, ReadNote);

   for i := 0 to ReadNote - 1 do
   begin
     sUSPDCharKan.Items[i].m_swUSPDID   := Addr;
     sUSPDCharKan.Items[i].m_swNk       := EncodeFormatBTIInt(pMsg.m_sbyInfo[6 + i*52], 2) - 1;
     sUSPDCharKan.Items[i].m_swMID      := EncodeFormatBTIInt(pMsg.m_sbyInfo[8 + i*52], 2) - 1;
     sUSPDCharKan.Items[i].m_swNDev     := sUSPDCharKan.Items[i].m_swMID;
     sUSPDCharKan.Items[i].m_swIk       := EncodeFormatBTIInt(pMsg.m_sbyInfo[10 + i*52], 2) - 1;
     EncodeFormatBTIFloat(@pMsg.m_sbyInfo[12 + i*52], @fPar);
     sUSPDCharKan.Items[i].m_sfKtr := fPar;
     EncodeFormatBTIFloat(@pMsg.m_sbyInfo[16 + i*52], @fPar);
     sUSPDCharKan.Items[i].m_sfKpr := fPar;
     EncodeFormatBTIFloat(@pMsg.m_sbyInfo[20 + i*52], @fPar);
     sUSPDCharKan.Items[i].m_sfKp  := fPar;
     sUSPDCharKan.Items[i].m_sbyPm      := pMsg.m_sbyInfo[24 + i*52];
     sUSPDCharKan.Items[i].m_sbyKmb     := pMsg.m_sbyInfo[25 + i*52];
     SetLength(sUSPDCharKan.Items[i].m_sNameKanal, 31);
     move(pMsg.m_sbyInfo[26 + i*52], sUSPDCharKan.Items[i].m_sNameKanal[1], 32);
   end;
   for i := sPointsRead.m_swPRUSPDCharKan to sPointsRead.m_swPRUSPDCharKan + ReadNote - 1 do
     if not m_pDB.AddUSPDCharKan(sUSPDCharKan.Items[i - sPointsRead.m_swPRUSPDCharKan]) then
       res := false;
   if res then
   begin
     sPointsRead.m_swPRUSPDCharKan := sPointsRead.m_swPRUSPDCharKan + ReadNote;
     if  sPointsRead.m_swPRUSPDCharKan - 1 >= sPointsRead.m_swPRUSPDCharKanMax then
     begin
       SetState(ST_READY_BTI);

     end;
   end;
   Result := res;
end;

function  CBTIInit.ReadUSPDCharKanAnsEx(var pMsg:CMessage):boolean;
var res         : boolean;
    ReadNote,i  : integer;
    fPar        : single;
    sm          : integer;
    StrLen      : integer;
begin
   res                := CheckControlFields(pMsg);
   ReadNote           := 0;
   sm                 := 0;
   while pMsg.m_swLen - 16 - 11 > sm do
   begin
     sm := sm + 20 + FindLenStrInArray(pMsg.m_sbyInfo[26 + sm]) + 1;
     Inc(ReadNote);
   end;
   sUSPDCharKan.Count := ReadNote;
   SetLength(sUSPDCharKan.Items, ReadNote);
   ReadNote          := 0;
   sm                := 0;
   while pMsg.m_swLen - 16 - 11 > sm do
   begin
     sUSPDCharKan.Items[ReadNote].m_swUSPDID   := Addr;
     sUSPDCharKan.Items[ReadNote].m_swNk       := EncodeFormatBTIInt(pMsg.m_sbyInfo[6 + sm], 2) - 1;
     sUSPDCharKan.Items[ReadNote].m_swMID      := EncodeFormatBTIInt(pMsg.m_sbyInfo[8 + sm], 2) - 1;
     sUSPDCharKan.Items[ReadNote].m_swNDev     := sUSPDCharKan.Items[ReadNote].m_swMID;
     sUSPDCharKan.Items[ReadNote].m_swIk       := EncodeFormatBTIInt(pMsg.m_sbyInfo[10 + sm], 2) - 1;
     EncodeFormatBTIFloat(@pMsg.m_sbyInfo[12 + sm], @fPar);
     sUSPDCharKan.Items[ReadNote].m_sfKtr      := fPar;
     EncodeFormatBTIFloat(@pMsg.m_sbyInfo[16 + sm], @fPar);
     sUSPDCharKan.Items[ReadNote].m_sfKpr      := fPar;
     EncodeFormatBTIFloat(@pMsg.m_sbyInfo[20 + sm], @fPar);
     sUSPDCharKan.Items[ReadNote].m_sfKp       := fPar;
     sUSPDCharKan.Items[ReadNote].m_sbyPm      := pMsg.m_sbyInfo[24 + sm];
     sUSPDCharKan.Items[ReadNote].m_sbyKmb     := pMsg.m_sbyInfo[25 + sm];
     StrLen                                    := FindLenStrInArray(pMsg.m_sbyInfo[26 + sm]);
     SetLength(sUSPDCharKan.Items[ReadNote].m_sNameKanal, StrLen);
     move(pMsg.m_sbyInfo[26 + sm], sUSPDCharKan.Items[ReadNote].m_sNameKanal[1], StrLen);
     sm                                        := sm + 20 + StrLen + 1;
     Inc(ReadNote);
   end;
   for i := sPointsRead.m_swPRUSPDCharKan to sPointsRead.m_swPRUSPDCharKan + ReadNote - 1 do
     if not m_pDB.AddUSPDCharKan(sUSPDCharKan.Items[i - sPointsRead.m_swPRUSPDCharKan]) then
       res := false;
   if res then
   begin
     sPointsRead.m_swPRUSPDCharKan := sPointsRead.m_swPRUSPDCharKan + ReadNote;
     if  sPointsRead.m_swPRUSPDCharKan - 1 >= sPointsRead.m_swPRUSPDCharKanMax then
     begin
       SetState(ST_USPD_CHARKAN_BTI);
       SetStateInPerc(55, 'Чтение информации о группах');
     end;
   end;
   Result := res;
end;

function  CBTIInit.ReadUSPDCharGrAnsEx(var pMsg : CMessage):boolean;
var res               : boolean;
    ReadNote, i, j    : integer;
    sm                : integer;
    StrLen            : integer;
begin
   res                := CheckControlFields(pMsg);
   ReadNote           := 0;
   sm                 := 0;
   while pMsg.m_swLen - 16 - 11 > sm do
   begin
     sm := sm + 129 + FindLenStrInArray(pMsg.m_sbyInfo[135 + sm]) + 1;
     Inc(ReadNote);
   end;
   sUSPDCharGr.Count := ReadNote;
   SetLength(sUSPDCharGr.Items, ReadNote);
   ReadNote          := 0;
   sm                := 0;
   while pMsg.m_swLen - 16 - 11 > sm do
   begin
     sUSPDCharGr.Items[ReadNote].m_swGrID   := pMsg.m_sbyInfo[6 + sm];
     sUSPDCharGr.Items[ReadNote].m_sVMeters := '';
     for i := 0 to 127 do
       for j := 0 to 7 do
         if (pMsg.m_sbyInfo[7 + i + sm] and __SetMask[j]) <> 0 then
           sUSPDCharGr.Items[ReadNote].m_sVMeters  := sUSPDCharGr.Items[ReadNote].m_sVMeters + IntToStr(i*8 + j) + ',';
     StrLen := FindLenStrInArray(pMsg.m_sbyInfo[135 + sm]);
     SetLength(sUSPDCharGr.Items[ReadNote].m_sGroupName, StrLen);
     move(pMsg.m_sbyInfo[135 + sm], sUSPDCharGr.Items[ReadNote].m_sGroupName[1], StrLen);
     sm := sm + 129 + StrLen + 1;
     Inc(ReadNote);
   end;
   for i := sPointsRead.m_swPRUSPDCharGr to sPointsRead.m_swPRUSPDCharGr + ReadNote - 1 do
     if not m_pDB.AddUSPDCharGr(sUSPDCharGr.Items[i - sPointsRead.m_swPRUSPDCharGr]) then
       res := false;
   if res then
   begin
     sPointsRead.m_swPRUSPDCharGr := sPointsRead.m_swPRUSPDCharGr + ReadNote;
     if  sPointsRead.m_swPRUSPDCharGr >= sPointsRead.m_swPRUSPDCharGrMax then
     begin
       SetState(ST_READY_BTI);
       SetStateInPerc(65, 'Запись информации о физических счетчиках');
     end;
   end;
   Result := res;
end;

procedure CBTIInit.CreateMSGHead(var pMsg : CMessage; length : word);
begin
   pMsg.m_swLen         := length + 11;
   pMsg.m_swObjID       := GetRealPort(m_pL1Tag.m_sbyPortID);
   pMsg.m_sbyFrom       := DIR_BTITOL1;
   pMsg.m_sbyFor        := DIR_BTITOL1;
   pMsg.m_sbyType       := PH_DATARD_REQ;
   pMsg.m_sbyTypeIntID  := DEV_COM_LOC;
   pMsg.m_sbyIntID      := GetRealPort(m_pL1Tag.m_sbyPortID);
   pMsg.m_sbyServerID   := HIP_BTI;
end;

procedure CBTIInit.CreateMSG(var buffer : array of byte; length : word; fnc : word);
begin
   buffer[0]          := $55;
   buffer[1]          := Addr or $80;                //Adr YSPD
   buffer[2]          := length div $100;
   buffer[3]          := length mod $100;
   buffer[4]          := fnc div $100;
   buffer[5]          := fnc mod $100;
   buffer[length - 4] := random(255);
   OldCodeHi          := buffer[length - 4];
   buffer[length - 3] := 12;
   OldCodeLo          := buffer[length - 3];
   CRC(buffer, length - 2);
end;

procedure CBTIInit.CreateUSPDTypeReq();
begin
   CreateMSG(m_nTxMsg.m_sbyInfo[0], 10, $00D0);
   CreateMSGHead(m_nTxMsg, 10);
   FPUT(BOX_L1, @m_nTxMsg);
   SetState(ST_WAIT_ASK_USPD_TYPE_BTI);
end;

procedure CBTIInit.CreateUSPDDevReq();
var ReadPakLen : word;
    PointEnd   : word;
    LengthMSG  : byte;
begin
    ReadPakLen := trunc((sPointsRead.m_swMaxPackLen - 16)/(16));              //Подсчет количества читаемых полей
    PointEnd   := sPointsRead.m_swPRUSPDDev + ReadPakLen - 1;
    //sPointsRead.m_swPRUSPDDevMax :=5;
    if PointEnd > sPointsRead.m_swPRUSPDDevMax then
      ReadPakLen := ReadPakLen - (PointEnd - sPointsRead.m_swPRUSPDDevMax);

    m_nTxMsg.m_sbyInfo[6] := sPointsRead.m_swPRUSPDDev div $100;
    m_nTxMsg.m_sbyInfo[7] := sPointsRead.m_swPRUSPDDev mod $100;
    m_nTxMsg.m_sbyInfo[8] := ReadPakLen div $100;
    m_nTxMsg.m_sbyInfo[9] := ReadPakLen mod $100;

    CreateMSG(m_nTxMsg.m_sbyInfo[0], 14, $00D1);
    CreateMSGHead(m_nTxMsg, 14);
    FPUT(BOX_L1, @m_nTxMsg);
    SetState(ST_WAIT_ASK_USPD_DEV_BTI);
end;

procedure CBTIInit.CreateUSPDCharDevReq();
var ReadPakLen : word;
    PointEnd   : word;
    LengthMSG  : byte;
begin
    ReadPakLen := trunc((sPointsRead.m_swMaxPackLen - 16)/(140));              //Подсчет количества читаемых полей
    PointEnd   := sPointsRead.m_swPRUSPDCharDev + ReadPakLen - 1;
    if PointEnd > sPointsRead.m_swPRUSPDCharDevMax then
      ReadPakLen := ReadPakLen - (PointEnd - sPointsRead.m_swPRUSPDCharDevMax);
    {if ReadPakLen >= sPointsRead.m_swPRUSPDCharDevMax - sPointsRead.m_swPRUSPDCharDev then
      ReadPakLen := sPointsRead.m_swPRUSPDCharDevMax - sPointsRead.m_swPRUSPDCharDev;   }
    m_nTxMsg.m_sbyInfo[6]  := sPointsRead.m_swPRUSPDCharDev div $100;
    m_nTxMsg.m_sbyInfo[7]  := sPointsRead.m_swPRUSPDCharDev mod $100;
    m_nTxMsg.m_sbyInfo[8]  := ReadPakLen div $100;
    m_nTxMsg.m_sbyInfo[9]  := ReadPakLen mod $100;

    CreateMSG(m_nTxMsg.m_sbyInfo[0], 14, $00D2);
    CreateMSGHead(m_nTxMsg, 14);
    FPUT(BOX_L1, @m_nTxMsg);

    SetState(ST_WAIT_ASK_USPD_CHARDEV_BTI);
end;

procedure CBTIInit.CreateUSPDCharKanReq();
var ReadPakLen : word;
    PointEnd   : word;
    LengthMSG  : byte;
begin
    ReadPakLen := trunc((sPointsRead.m_swMaxPackLen - 16)/(140));              //Подсчет количества читаемых полей
    PointEnd   := sPointsRead.m_swPRUSPDCharKan + ReadPakLen - 1;
    if PointEnd > sPointsRead.m_swPRUSPDCharKanMax then
      ReadPakLen := ReadPakLen - (PointEnd - sPointsRead.m_swPRUSPDCharKanMax);
   { if ReadPakLen >= sPointsRead.m_swPRUSPDCharKanMax - sPointsRead.m_swPRUSPDCharKan then
      ReadPakLen := sPointsRead.m_swPRUSPDCharKanMax - sPointsRead.m_swPRUSPDCharKan;    }

    m_nTxMsg.m_sbyInfo[6]  := sPointsRead.m_swPRUSPDCharKan div $100;
    m_nTxMsg.m_sbyInfo[7]  := sPointsRead.m_swPRUSPDCharKan mod $100;
    m_nTxMsg.m_sbyInfo[8]  := ReadPakLen div $100;
    m_nTxMsg.m_sbyInfo[9]  := ReadPakLen mod $100;

    CreateMSG(m_nTxMsg.m_sbyInfo[0], 14, $00D3);
    CreateMSGHead(m_nTxMsg, 14);
    FPUT(BOX_L1, @m_nTxMsg);

    SetState(ST_WAIT_ASK_USPD_CHARKAN_BTI);
end;

procedure CBTIInit.CreateUSPDCharGrReq;
var ReadPakLen : word;
    PointEnd   : word;
    LengthMSG  : byte;
begin
    ReadPakLen := trunc((sPointsRead.m_swMaxPackLen - 16)/(200));              //Подсчет количества читаемых полей
    if ReadPakLen >= sPointsRead.m_swPRUSPDCharGrMax - sPointsRead.m_swPRUSPDCharGr then
      ReadPakLen := sPointsRead.m_swPRUSPDCharGrMax - sPointsRead.m_swPRUSPDCharGr;

    m_nTxMsg.m_sbyInfo[6]  := sPointsRead.m_swPRUSPDCharGr div $100;
    m_nTxMsg.m_sbyInfo[7]  := sPointsRead.m_swPRUSPDCharGr mod $100;
    m_nTxMsg.m_sbyInfo[8]  := ReadPakLen div $100;
    m_nTxMsg.m_sbyInfo[9]  := ReadPakLen mod $100;

    CreateMSG(m_nTxMsg.m_sbyInfo[0], 14, $00D4);
    CreateMSGHead(m_nTxMsg, 14);
    FPUT(BOX_L1, @m_nTxMsg);

    SetState(ST_WAIT_ASK_USPD_CHARGR_BTI);
end;

function CBTIInit.EcnodeStrToVM(str : string; var buf : array of word) : integer;
var Pos1, Pos2, cnt, i : integer;
    TempStr            : string;
begin
   Pos1 := 1;
   Pos2 := 1;
   cnt  := 0;
   for i := 1 to Length(str) do
     if (str[i] = ',') then
     begin
       Pos2 := i;
       SetLength(TempStr, (Pos2 - Pos1));
       move(str[Pos1], TempStr[1], Pos2- Pos1);
       buf[cnt] := StrToInt(TempStr);
       Inc(cnt);
       Pos1 := Pos2 + 1;
     end;
   Result := cnt;
end;

procedure CBTIInit.AtuoFillAbon;
begin
   CreateCountersBTI;
   SetStateInPerc(80, 'Запись информации о группах');
   CreateGroupsBTI;
   SetStateInPerc(85, 'Запись информации о точках учета');
   CreateVMetersBTI;
   SetStateInPerc(100, 'Данные успешно считаны');
   FState        := ST_READY_BTI;
   pStatusBar    := nil;
   pProgressVar  := nil;
   if m_pL1Tag.m_sbyType = DEV_COM_GSM then
     SendPMSG(BOX_L1,GetRealPort(m_pL1Tag.m_sbyPortID),DIR_L2TOL1,PH_DISC_IND);

end;

procedure CBTIInit.CreateGroupsBTI();
var pTableGr       : SL3INITTAG;
    pTableGrToSave : SL3GROUPTAG;
    i              : integer;
begin
   m_pDB.DelGroupTable(AbonID, -1);
   FreeAllIndexGr;
   if m_pDB.GetGroupsTable(pTableGr)=True then
     for i:=0 to pTableGr.Count-1 do
       SetIndexGr(pTableGr.Items[i].m_sbyGroupID);
   m_pDB.ReadUSPDCharGr(sUSPDCharGr);
   SetLength(GrID, sUSPDCharGr.Count);
   for i := 0 to sUSPDCharGr.Count - 1 do
   begin
     pTableGrToSave.m_swABOID       := AbonID;
     pTableGrToSave.m_sbyGroupID    := GenIndexGr;
     SetIndexGr(pTableGrToSave.m_sbyGroupID);
     GrID[i]                        := pTableGrToSave.m_sbyGroupID;
     pTableGrToSave.m_swPLID        := 0;
     pTableGrToSave.m_sGroupName    := sUSPDCharGr.Items[i].m_sGroupName;
     pTableGrToSave.m_sGroupExpress := '[x]';
     pTableGrToSave.m_swPosition    := i;
     pTableGrToSave.m_sbyEnable     := 1;
     pTableGrToSave.m_swAmVMeter    := 0;
     pTableGrToSave.M_NGROUPLV      := 0;
     m_pDB.AddGroupTable(pTableGrToSave);
   end;
end;

procedure CBTIInit.CreateVMetersBTI();
var  m_sTbl        : SL3GROUPTAG;
     sUSPDCharDev  : SL2USPDCHARACTDEVLIST;
     sUSPDCharGr   : SL2USPDCHARACTGRLIST;
     sNewVMeter    : SL3VMETERTAG;
     pTbl          : SL2INITITAG;
     i, j, cnt     : integer;
     mas           : array [0..MAX_VMETER] of word;
     MID, CharDev  : integer;
     IsGroupLVUpd  : boolean;
begin
   FreeAllIndexVM;
   if m_pDB.GetVMetersTable(-1,m_sTbl)=True then
     for i := 0 to m_sTbl.m_swAmVMeter-1 do
       SetIndexVM(m_sTbl.Item.Items[i].m_swVMID);
   if not m_pDB.ReadUSPDCharDev(Addr, sUSPDCharDev) then
     exit;
   if not m_pDB.ReadUSPDCharGr(sUSPDCharGr) then
     exit;
   if not m_pDB.GetMetersTable(m_pL1Tag.m_sbyPortID,pTbl) then
     exit;
   for i := 0 to sUSPDCharGr.Count - 1 do
   begin
     cnt := EcnodeStrToVM(sUSPDCharGr.Items[i].m_sVMeters, mas);
     IsGroupLVUpd := false;
     for j := 0 to cnt - 1 do
     begin
       for CharDev := 0 to sUSPDCharDev.Count - 1 do
         if sUSPDCharDev.Items[CharDev].m_swNDev = mas[j] then break;
       for MID := 0 to pTbl.m_swAmMeter - 1 do
         if StrToInt(pTbl.m_sMeter[MID].m_sddPHAddres) = sUSPDCharDev.Items[CharDev].m_swNDev then break;
       sNewVMeter.m_swMID       := pTbl.m_sMeter[MID].m_swMID;
       if (sUSPDCharDev.Items[CharDev].m_swBMID <> MET_GSUMM) and (sUSPDCharDev.Items[CharDev].m_swBMID <> MET_SUMM) then
         sNewVMeter.m_sbyType   := sUSPDCharDev.Items[CharDev].m_swBMID
       else
         sNewVMeter.m_sbyType   := MET_SS301F3;
       sNewVMeter.m_sbyPortID   := m_pL1Tag.m_sbyPortID;
       sNewVMeter.m_sbyGroupID  := GrID[sUSPDCharGr.Items[i].m_swGrID];
       sNewVMeter.m_swVMID      := GenIndexVM;
       SetIndexVM(sNewVMeter.m_swVMID);
       sNewVMeter.m_sddPHAddres := IntToStr(sUSPDCharDev.Items[CharDev].m_swANet);
       sNewVMeter.m_sMeterCode  := 'Code';
       sNewVMeter.m_sMeterName  := sUSPDCharDev.Items[CharDev].m_sStrAdr;
       sNewVMeter.m_sVMeterName := sUSPDCharDev.Items[CharDev].m_sStrAdr;
       sNewVMeter.m_sbyExport   := 0;
       sNewVMeter.m_sbyEnable   := 1;
       sNewVMeter.m_swPLID      := 0;
       if not IsGroupLVUpd then
       begin
         IsGroupLVUpd := true;
         if (sUSPDCharDev.Items[CharDev].m_swBMID <> MET_GSUMM) and (sUSPDCharDev.Items[CharDev].m_swBMID <> MET_SUMM) then
           m_pDB.UpdateGROUPLV(sNewVMeter.m_sbyGroupID, 0)
         else
           m_pDB.UpdateGROUPLV(sNewVMeter.m_sbyGroupID, 1);
       end;
       m_pDB.AddVMeterTable(sNewVMeter);
       m_pDB.InsertVParams(sUSPDCharDev.Items[CharDev].m_swBMID, sNewVMeter.m_swVMID);
     end;
   end;
end;

procedure CBTIInit.CreateCountersBTI();
var i        : word;
    NewMeter : SL2TAG;
    pTbl     : SL2INITITAG;
begin
   m_pDB.DeleteBTIMeters(m_pL1Tag.m_sbyPortID);
   if not m_pDB.ReadUSPDCharDev(Addr, sUSPDCharDev) then
     exit;

   FreeAllIndexMID;
   if m_pDB.GetMetersAll(pTbl)=True then
   for i:=0 to pTbl.m_swAmMeter-1 do
     SetIndexMID(pTbl.m_sMeter[i].m_swMID);
   m_pDB.GetPortTable(m_pL1Tag);
   for i := 0 to sUSPDCharDev.Count - 1 do
   begin
     NewMeter.m_sbyGroupID  := 0;
     NewMeter.m_swVMID      := 0;
     NewMeter.m_sbyPortID   := m_pL1Tag.m_sbyPortID;
     NewMeter.m_swMID       := GenIndexMID;//sUSPDCharDev.Items[i].m_swNDev;
     if (metersType[i] <> MET_SUMM) and (metersType[i] <> MET_GSUMM) then
       NewMeter.m_sbyType := metersType[i]
     else
       NewMeter.m_sbyType := MET_SS301F3;
     NewMeter.m_sddPHAddres := IntToStr(sUSPDCharDev.Items[i].m_swNDev);
     NewMeter.m_schPassword := '0';
     NewMeter.m_schName     := sUSPDCharDev.Items[i].m_sStrAdr;
     if m_pL1Tag.m_sbyType = DEV_COM_GSM then
     begin
       NewMeter.m_sbyRepMsg   := 10;
       NewMeter.m_swRepTime   := 10;
     end else
     begin
     NewMeter.m_sbyRepMsg   := 10;
     NewMeter.m_swRepTime   := 15;
     end;
     NewMeter.m_swCurrQryTm := 40;
     //NewMeter.m_swGraphQryTm:= 10;
     NewMeter.m_sfKI        := 1.0;
     NewMeter.m_sfKU        := 1.0;
     NewMeter.m_sfMeterKoeff:= 1.0;
     NewMeter.m_sbyTSlice   := 1;
     //NewMeter.m_sbyHandScenr:= 1;
     NewMeter.m_sbyPrecision:= 3; 
     NewMeter.m_sbyEnable   := 1;
     NewMeter.m_sbyLocation := 0;
     if m_pL1Tag.m_sbyType = DEV_COM_GSM then
       NewMeter.m_sbyModem  := 1
     else
       NewMeter.m_sbyModem  := 0;
     NewMeter.m_sPhone      := m_pL1Tag.m_schPhone;
     NewMeter.m_sddFabNum   := IntToStr(sUSPDCharDev.Items[i].m_sdwWorkNumb);
     if not m_pDB.ReadUSPDCharKan(Addr, sUSPDCharDev.Items[i].m_swNDev, sUSPDCharKan) then
       continue;
     NewMeter.m_swMinNKan   := sUSPDCharKan.Items[0].m_swNK;
     NewMeter.m_swMaxNKan   := sUSPDCharKan.Items[sUSPDCharKan.Count - 1].m_swNK;
     NewMeter.m_sfKU        := sUSPDCharKan.Items[0].m_sfKtr;
     NewMeter.m_sdtSumKor   := cDateTimeR.SecToDateTime(0);
     NewMeter.m_sdtLimKor   := cDateTimeR.SecToDateTime(1800);
     NewMeter.m_sdtPhLimKor := cDateTimeR.SecToDateTime(1800);
     NewMeter.m_sbyTSlice   := 0;
     NewMeter.m_sAdvDiscL2Tag := '';
     NewMeter.m_sbyStBlock  := 0;
     //NewMeter.m_sbyType     := 2;
     if m_pDB.AddMeterUSPD(NewMeter) then
     begin
       SetIndexMID(NewMeter.m_swMID);
       m_pDB.InsertCommand(NewMeter.m_swMID,metersType[i]);
     end;
   end;
   m_nRepTimer.OffTimer;
end;

function  CBTIInit.EventHandler(var pMsg:CMessage):boolean;
var res : boolean;
begin
   res    := false;
   case pMsg.m_sbyFor of
     DIR_L1TOBTI:  LoHandler(pMsg);
     DIR_BTITOBTI: begin SelfHandler(pMsg);HiHandler(pMsg); end;
     DIR_L3TOBTI:  HiHandler(pMsg);
   end;
   Result := res;
end;

procedure CBTIInit.SetState(byState:Byte);
Begin
    TraceL(2,0,'(__)CBTII::>ST:'+chBTISate[FState]+'->ST:'+chBTISate[byState]);
    FState := byState;
End;

constructor CBTIInit.Create;
Begin

End;

destructor CBTIInit.Destroy;
Begin
    inherited;
End;

function  CBTIInit.SelfHandler(var pMsg:CMessage):Boolean;
var res : boolean;
begin
   if (FState = ST_READY_BTI) then
     exit;
   ResetBTI;
   res := false;
   Dec(RepTimerCount);
   if RepTimerCount<>0 then
   begin
     m_nRepTimer.OnTimer(MAX_DELAY_IN_BTI_INIT)
   end
   else
   begin
     TraceL(2,0,'(__)CBTII::>ST:REQ Timer BTIInit ERROR!!!!');
     ResetBTI;
   end;
   TraceL(2,0,'(__)CBTII::>ST:REQ Timer BTIInit'+IntToStr(RepTimerCount));

   Result := res;
end;

procedure CBTIInit.CreateDataReq();
begin
   case FState of
     ST_NULL_BTI                                       : CreateUSPDTypeReq();
     ST_USPD_TYPE_BTI, ST_WAIT_ASK_USPD_DEV_BTI        : CreateUSPDDevReq();
     ST_USPD_DEV_BTI, ST_WAIT_ASK_USPD_CHARDEV_BTI     : CreateUSPDCharDevReq();
     ST_USPD_CHARDEV_BTI, ST_WAIT_ASK_USPD_CHARKAN_BTI : CreateUSPDCharKanReq();
     ST_WAIT_ASK_USPD_CHARGR_BTI, ST_USPD_CHARKAN_BTI  : CreateUSPDCharGrReq();
     ST_READY_BTI, ST_USPD_CHARGR_BTI                  : AtuoFillAbon();
   end;
   Sleep(50);
   if FState <> ST_READY_BTI then
   begin
     m_nRepTimer.OnTimer(MAX_DELAY_IN_BTI_INIT);
     RepTimerCount := 3;
   end;
end;

function  CBTIInit.LoHandler(var pMsg:CMessage):Boolean;
var res : boolean;
begin
   res := false;
   case FState of
     ST_WAIT_ASK_USPD_TYPE_BTI    : res := ReadUSPDTypeAns(pMsg);              {00D0}
     ST_WAIT_ASK_USPD_DEV_BTI     : res := ReadUSPDDevAns(pMsg);               {00D1}
     ST_WAIT_ASK_USPD_CHARDEV_BTI : res := ReadUSPDCharDevAnsEx(pMsg);         {00D2}
     ST_WAIT_ASK_USPD_CHARKAN_BTI : res := ReadUSPDCharKanAnsEx(pMsg);         {00D3}
     ST_WAIT_ASK_USPD_CHARGR_BTI  : res := ReadUSPDCharGrAnsEx(pMsg);          {00D4}
   End;
   if res then
   begin
     m_nRepTimer.OffTimer;
     CreateDataReq();
   end;
   Result := res;
end;

function  CBTIInit.HiHandler(var pMsg:CMessage):Boolean;
var res : boolean;
begin
   res := false;
   SetStateInPerc(5, 'Начало опроса конфигурации');
   case FState of
     ST_NULL_BTI                  : CreateUSPDTypeReq();
     ST_USPD_TYPE_BTI             : CreateUSPDDevReq();
     ST_USPD_DEV_BTI              : CreateUSPDCharDevReq();
     ST_USPD_CHARDEV_BTI          : CreateUSPDCharKanReq();
     ST_USPD_CHARKAN_BTI          : CreateUSPDCharGrReq();
     ST_USPD_CHARGR_BTI           : AtuoFillAbon();
   end;
   m_nRepTimer.OnTimer(MAX_DELAY_IN_BTI_INIT);
   RepTimerCount := 3;
   Result := res;
end;

function  CBTIInit.CRC(var buf : array of byte; count : integer):boolean;

var i                 : integer;
    CRCHi, CRCLo, ind : byte;
begin
  CRCHi   := $FF;
  CRCLo   := $FF;
  Result  := true;
  for i := 0 to count - 1 do
  begin
    ind:= CRCHi xor buf[i];
    CRCHi:= CRCLo xor srCRCHi[ind];
    CRCLo:= srCRCLo[ind];
  end;
  if (buf[count] <> CRCHi) or (buf[count + 1] <> CRCLo) then
    Result := false;
  buf[count]   := CRCHi;
  buf[count+1] := CRCLo;
end;

function  CBTIInit.SetIndexVM(nIndex : Integer):Integer;
begin
   m_blVMeterIndex[nIndex] := False;
   Result := nIndex;
end;

function  CBTIInit.GenIndexVM:Integer;
Var
   i : Integer;
Begin
   for i:=0 to MAX_VMETER do
     if m_blVMeterIndex[i]=True then
     Begin
       Result := i;
       exit;
     End;
   Result := -1;
end;

function  CBTIInit.GenIndexSvVM:Integer;
begin
   Result := SetIndexVM(GenIndexVM);
end;

procedure CBTIInit.FreeAllIndexVM;
Var
   i : Integer;
Begin
   for i:=0 to MAX_VMETER do
     m_blVMeterIndex[i] := True;
end;

procedure CBTIInit.FreeIndexVM(nIndex : Integer);
begin
   m_blVMeterIndex[nIndex] := True;
end;

function  CBTIInit.SetIndexGr(nIndex : Integer):Integer;
begin
   m_blGroupIndex[nIndex] := False;
   Result := nIndex;
end;

function  CBTIInit.GenIndexGr:Integer;
Var
   i : Integer;
Begin
   for i:=0 to MAX_GROUP do
     if m_blGroupIndex[i]=True then
     Begin
      Result := i;
      exit;
     End;
   Result := -1;
end;

function  CBTIInit.GenIndexSvGr:Integer;
begin
   Result := SetIndexGr(GenIndexGr);
end;

procedure CBTIInit.FreeAllIndexGr;
Var
   i : Integer;
Begin
   for i:=0 to MAX_GROUP do
      m_blGroupIndex[i] := True;
end;

procedure CBTIInit.FreeIndexGr(nIndex : Integer);
begin
   m_blGroupIndex[nIndex] := True;
end;

function  CBTIInit.SetIndexMID(nIndex : Integer):Integer;
begin
   m_blMeterIndex[nIndex] := False;
   Result := nIndex;
end;

function  CBTIInit.GenIndexMID:Integer;
Var
   i : Integer;
Begin
   for i:=0 to MAX_METER do
     if m_blMeterIndex[i]=True then
     Begin
       Result := i;
       exit;
     End;
   Result := -1;
end;

function  CBTIInit.GenIndexSvMID:Integer;
begin
   Result := SetIndexMID(GenIndexMID);
end;

procedure CBTIInit.FreeAllIndexMID;
Var
   i : Integer;
Begin
   for i:=0 to MAX_METER do
     m_blMeterIndex[i] := True;
end;

procedure CBTIInit.FreeIndexMID(nIndex : Integer);
begin
   m_blMeterIndex[nIndex] := True;
end;

procedure CBTIInit.RunModule;
Begin
    m_nRepTimer.RunTimer;
End;

function CBTIInit.GetRealPort(nPort:Integer):Integer;
Var
    i : Integer;
Begin
    Result := nPort;
    for i:=0 to m_sTblL1.Count-1 do
    Begin
     with m_sTblL1.Items[i] do
     Begin
      if m_sbyPortID=nPort then
      Begin
       Result := m_sbyPortID;
       if m_sblReaddres=1 then Result := m_swAddres;
       exit;
      End;
     End;
    End;
end;

end.


