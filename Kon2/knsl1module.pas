unit knsl1module;
{$DEFINE CLL1_DEBUG}
interface
uses
    Windows, Classes, SysUtils,SyncObjs,stdctrls,comctrls,utltypes,utlbox,utlconst,knsl1cport,knsl1comport,knsl1gprsrouter,
    knsl1tcp,knsl3abon,utldatabase,extctrls,knsl3querysender,utlmtimer,knsl2BTIInit,knsl3EventBox,knsl4ConfMeterModule,knsl4Unloader,knsl4ECOMcrqsrv,
    utlThread;
type
    CL1Module = class(CThread)
    private
     //m_csOut     : TCriticalSection;
     m_nLID      : Byte;
     m_sbyAmPort : Integer;
     m_nMsg      : CMessage;
     procedure OnHandler;
     function EventHandler(var pMsg : CMessage):Boolean;
    protected
     procedure Execute; override;
    public
     m_sIniTbl   : SL1INITITAG;
     m_pPort     : array[0..MAX_PORT] of CPort;
     procedure Init;
     procedure InitMpPort;
     procedure InitIndex(Index:Integer);

     procedure DelNodeLv(nIndex:Integer);
     procedure AddNodeLv(pTbl:SL1TAG);
     procedure EditNodeLv(pTbl:SL1TAG);
     procedure CreateQrySender;
     procedure StartPort;
     procedure StopPort;
     procedure StopIsGprsPort;
     procedure DoHalfTime(Sender:TObject);
     procedure DoHalfSpeedTime(Sender:TObject);
     function GetPortState(nIndex:Byte):Boolean;
     function GetConnectState(nIndex:Byte):Boolean;
     property PPortTable:SL1INITITAG read m_sIniTbl write m_sIniTbl;
     destructor Destroy; override;
    End;
var
    mL1Module : CL1Module = nil;
implementation

procedure CL1Module.OnHandler;
Begin
     EventHandler(m_nMsg);
End;

procedure CL1Module.Execute;
Begin
    FDEFINE(BOX_L1,BOX_L1_SZ,True);
    while not Terminated do
    Begin
     FGET(BOX_L1,@m_nMsg);
 //    OnHandler;
     Synchronize(OnHandler);
     //EventHandler(m_nMsg);
    End;
End;

procedure CL1Module.Init;
Var
    i,nIndex,pIndex,nADR : Integer;
Begin
    i := -1;
    mL1Module := self;               //GetSystemTime
    if m_pDB.GetL1Table(m_sIniTbl)=True then
    Begin
     m_nLID      := 1;
     m_sbyAmPort := m_sIniTbl.Count;
     pIndex      := 0;
    try
    for i:=0 to m_sbyAmPort-1 do
    Begin
     nIndex := m_sIniTbl.Items[i].m_sbyPortID;
     case m_sIniTbl.Items[i].m_sbyType of
       DEV_TCP_GPRS:
       Begin
        nADR := m_sIniTbl.Items[i].m_swAddres;
        if nADR>MAX_GPRS then break;
        if m_nGPRS[nADR]=Nil then m_nGPRS[nADR] := CGprsRouter.Create;
        m_nGPRS[nADR].Init(@m_sIniTbl.Items[i]);
        if not Assigned(m_pPort[nIndex]) then m_pPort[nIndex] := TComPort.Create;
        m_pPort[nIndex].Init(m_sIniTbl.Items[i]);
       End;
       DEV_COM_LOC,DEV_COM_GSM:
       Begin
           if not Assigned(m_pPort[nIndex]) then m_pPort[nIndex] := TComPort.Create;
           m_pPort[nIndex].Init(m_sIniTbl.Items[i]);
           if m_sIniTbl.Items[i].m_sbyProtID=DEV_BTI_SRV then
           Begin
            if not Assigned(mBtiModule)      then mBtiModule     := CBTIInit.Create;
            mBtiModule.Init(m_sIniTbl.Items[i]);
           End;
           if m_sIniTbl.Items[i].m_sbyType=DEV_COM_GSM then
           Begin
            if m_sIniTbl.Items[i].m_schPhone='Контроль' then
            m_nUNL.Init(m_sIniTbl.Items[i].m_sbyPortID);
           End;
       End;
       DEV_TCP_SRV, DEV_UDP_SRV:
       Begin
           if m_sIniTbl.Items[i].m_sbyProtID<>DEV_ECOM_SRV_CRQ then
           Begin
            if not Assigned(m_pPort[nIndex]) then m_pPort[nIndex] := CTcpPort.Create;
            m_pPort[nIndex].Init(m_sIniTbl.Items[i]);
            if m_sIniTbl.Items[i].m_sbyControl=1 then
            Begin
             m_nMasterPort0   := nIndex;
             m_nCtrPort.Count := pIndex + 1;
             m_nCtrPort.Items[pIndex] := nIndex;
             m_nCtrPort.SType[pIndex] := m_sIniTbl.Items[i].m_sbyKTRout;
             Inc(pIndex);
            End;
            if m_sIniTbl.Items[i].m_sbyProtID=DEV_BTI_SRV then
            Begin
             if not Assigned(mBtiModule)      then mBtiModule     := CBTIInit.Create;
             mBtiModule.Init(m_sIniTbl.Items[i]);
            End;
            End;
           {End else
           if m_sIniTbl.Items[i].m_sbyProtID=DEV_ECOM_SRV_CRQ then
           Begin
            if not Assigned(m_nCRQ) then m_nCRQ := CEcomCrqSrv.Create;
            m_nCRQ.Init(m_sIniTbl.Items[i]);
            m_nCRQ.Run;
           End;}
       End;
       DEV_TCP_CLI, DEV_UDP_CLI:
       Begin
           if m_sIniTbl.Items[i].m_sbyProtID<>DEV_ECOM_SRV_CRQ then
           Begin
            if not Assigned(m_pPort[nIndex]) then m_pPort[nIndex] := CTcpPort.Create;
            m_pPort[nIndex].Init(m_sIniTbl.Items[i]);
            if m_sIniTbl.Items[i].m_sbyControl=1 then
            Begin
             m_nMasterPort0   := nIndex;
             m_nCtrPort.Count := pIndex + 1;
             m_nCtrPort.Items[pIndex] := nIndex;
             m_nCtrPort.SType[pIndex] := m_sIniTbl.Items[i].m_sbyKTRout;
             Inc(pIndex);
            End;
            if m_sIniTbl.Items[i].m_sbyProtID=DEV_BTI_SRV then
            Begin
             if not Assigned(mBtiModule)      then mBtiModule     := CBTIInit.Create;
             mBtiModule.Init(m_sIniTbl.Items[i]);
            End;
           //End else
           //if m_sIniTbl.Items[i].m_sbyProtID=DEV_ECOM_SRV_CRQ then
           //Begin
           // if not Assigned(m_nCRQ) then m_nCRQ := CEcomCrqSrv.Create;
           // m_nCRQ.Init(m_sIniTbl.Items[i]);
           // m_nCRQ.Run;
           //End;
           End;
       End;
     End;
    End;
    except
//     TraceL(m_nLID,i,'(__)CL1MD::>Error Create L1.');
    end;
    Priority       := tpHighest;
    Resume;
    End;
    //CreateQrySender;
End;

procedure CL1Module.InitMpPort;
Var
    i,nIndex,pIndex,nADR : Integer;
Begin
  try
   mL1Module := self;
    for i:=0 to MAX_PORT-1 do
       m_pPort[i]:=nil;
  except
//     TraceL(m_nLID,i,'(__)CL1MD::>Error Create L1.');
  end;
  Priority       := tpHighest;
  Resume;
End;

procedure CL1Module.InitIndex(Index:Integer);
Var
    i,nIndex,pIndex,nADR : Integer;
Begin
    i := -1;
//    mL1Module := self;               //GetSystemTime
    if m_pDB.GetL1TableIndex(m_sIniTbl,Index)=True then
    Begin
     m_nLID      := 1;
     m_sbyAmPort := m_sIniTbl.Count;
     pIndex      := 0;
    try
    for i:=0 to m_sbyAmPort-1 do
    Begin
     nIndex := m_sIniTbl.Items[i].m_sbyPortID;
     case m_sIniTbl.Items[i].m_sbyType of
       DEV_TCP_GPRS:
       Begin
        nADR := m_sIniTbl.Items[i].m_swAddres;
        if nADR>MAX_GPRS then break;
        if m_nGPRS[nADR]=Nil then m_nGPRS[nADR] := CGprsRouter.Create;
        m_nGPRS[nADR].Init(@m_sIniTbl.Items[i]);
        if not Assigned(m_pPort[nIndex]) then m_pPort[nIndex] := TComPort.Create;
        m_pPort[nIndex].Init(m_sIniTbl.Items[i]);
       End;
       DEV_COM_LOC,DEV_COM_GSM:
       Begin
           if not Assigned(m_pPort[nIndex]) then m_pPort[nIndex] := TComPort.Create;
           m_pPort[nIndex].Init(m_sIniTbl.Items[i]);
           if m_sIniTbl.Items[i].m_sbyProtID=DEV_BTI_SRV then
           Begin
            if not Assigned(mBtiModule)      then mBtiModule     := CBTIInit.Create;
            mBtiModule.Init(m_sIniTbl.Items[i]);
           End;
           //if m_sIniTbl.Items[i].m_sbyType=DEV_COM_GSM then
           //Begin
           // if m_sIniTbl.Items[i].m_schPhone='Контроль' then
           // m_nUNL.Init(m_sIniTbl.Items[i].m_sbyPortID);
           //End;
       End;
       DEV_TCP_SRV, DEV_UDP_SRV:
       Begin
           if m_sIniTbl.Items[i].m_sbyProtID<>DEV_ECOM_SRV_CRQ then
           Begin
            if not Assigned(m_pPort[nIndex]) then m_pPort[nIndex] := CTcpPort.Create;
            m_pPort[nIndex].Init(m_sIniTbl.Items[i]);
            if m_sIniTbl.Items[i].m_sbyControl=1 then
            Begin
             m_nMasterPort0   := nIndex;
             m_nCtrPort.Count := pIndex + 1;
             m_nCtrPort.Items[pIndex] := nIndex;
             m_nCtrPort.SType[pIndex] := m_sIniTbl.Items[i].m_sbyKTRout;
             Inc(pIndex);
            End;
            if m_sIniTbl.Items[i].m_sbyProtID=DEV_BTI_SRV then
            Begin
             if not Assigned(mBtiModule)      then mBtiModule     := CBTIInit.Create;
             mBtiModule.Init(m_sIniTbl.Items[i]);
            End;
            End;
           {End else
           if m_sIniTbl.Items[i].m_sbyProtID=DEV_ECOM_SRV_CRQ then
           Begin
            if not Assigned(m_nCRQ) then m_nCRQ := CEcomCrqSrv.Create;
            m_nCRQ.Init(m_sIniTbl.Items[i]);
            m_nCRQ.Run;
           End;}
       End;
       DEV_TCP_CLI, DEV_UDP_CLI:
       Begin
           if m_sIniTbl.Items[i].m_sbyProtID<>DEV_ECOM_SRV_CRQ then
           Begin
            if not Assigned(m_pPort[nIndex]) then m_pPort[nIndex] := CTcpPort.Create;
            m_pPort[nIndex].Init(m_sIniTbl.Items[i]);
            if m_sIniTbl.Items[i].m_sbyControl=1 then
            Begin
             m_nMasterPort0   := nIndex;
             m_nCtrPort.Count := pIndex + 1;
             m_nCtrPort.Items[pIndex] := nIndex;
             m_nCtrPort.SType[pIndex] := m_sIniTbl.Items[i].m_sbyKTRout;
             Inc(pIndex);
            End;
            if m_sIniTbl.Items[i].m_sbyProtID=DEV_BTI_SRV then
            Begin
             if not Assigned(mBtiModule)      then mBtiModule     := CBTIInit.Create;
             mBtiModule.Init(m_sIniTbl.Items[i]);
            End;
           //End else
           //if m_sIniTbl.Items[i].m_sbyProtID=DEV_ECOM_SRV_CRQ then
           //Begin
           // if not Assigned(m_nCRQ) then m_nCRQ := CEcomCrqSrv.Create;
           // m_nCRQ.Init(m_sIniTbl.Items[i]);
           // m_nCRQ.Run;
           //End;
           End;
       End;
     End;
    End;
    except
//     TraceL(m_nLID,i,'(__)CL1MD::>Error Create L1.');
    end;
//    Priority       := tpHighest;
//    Resume;
    End;
    //CreateQrySender;
End;


{
  //Типы портов
  DEV_COM_L2   = 0;
  DEV_COM_USPD = 1;
  DEV_TCP_SRV  = 3;
  DEV_TCP_CLI  = 4;
  //Типы протоколов
  DEV_NUL      = 0;
  DEV_BTI_CLI  = 1;
  DEV_BTI_SRV  = 2;
}
procedure CL1Module.CreateQrySender;
Var
     i,nPID : Integer;
Begin
     for i:=0 to m_sIniTbl.Count-1 do
     Begin
      nPID := m_sIniTbl.Items[i].m_sbyPortID;
      if m_blPortIndex[nPID]=False then
      Begin
       if (m_sIniTbl.Items[i].m_sbyProtID=DEV_C12_SRV)or
       (m_sIniTbl.Items[i].m_sbyProtID=DEV_ECOM_CLI)or
       (m_sIniTbl.Items[i].m_sbyProtID=DEV_BTI_SRV)or
       (m_sIniTbl.Items[i].m_sbyProtID=DEV_MASTER)or
       (m_sIniTbl.Items[i].m_sbyProtID=DEV_K2000B_CLI)or
       (m_sIniTbl.Items[i].m_sbyProtID=DEV_TRANSIT) then
       Begin
        if m_nQrySender[nPID]<>Nil then
        Begin
         m_nQrySender[nPID].Destroy;
         m_nQrySender[nPID]:=Nil;
        End;
        m_nQrySender[nPID] := CQuerySender.Create(True);
        m_nQrySender[nPID].Init(m_sIniTbl.Items[i]);
        m_nQrySender[nPID].FreeOnTerminate := False;
        m_nQrySender[nPID].Priority := tpHigher;
        m_nQrySender[nPID].PPort := @m_pPort[nPID];
        m_nQrySender[nPID].Resume;
       End;
      End;
     End;
End;
function CL1Module.EventHandler(var pMsg : CMessage):Boolean;
Var sPT : SL1SHTAG;
    pDS : CMessageData;
    i   : Integer;
Begin
  try
    Result := False;
    try
    //TraceM(1,0,'(__)CL1MD::>MSG:',@pMsg);

      case pMsg.m_sbyFor of
        DIR_L1TOGPRS :
          Begin
            case pMsg.m_sbyType of
              DL_START_ROUT_REQ,
              DL_STOP_ROUT_REQ,
              DL_INIT_ROUT_REQ:
                Begin
                  for i:=0 to MAX_GPRS-1 do
                  if Assigned(m_nGPRS[i]) then
                  m_nGPRS[i].EventHandler(pMsg);
                End;
            else
              Begin
                if pMsg.m_swObjID<MAX_GPRS then
                  if Assigned(m_nGPRS[pMsg.m_swObjID]) then
                    m_nGPRS[pMsg.m_swObjID].EventHandler(pMsg);
              End;
            End;
          End;
        DIR_QSTOL1:
          Begin
            case pMsg.m_sbyType of
              DL_QSDISC_TMR:
              Begin
                if Assigned(m_nQrySender[pMsg.m_swObjID]) then
                  m_nQrySender[pMsg.m_swObjID].EventHandler(pMsg);
               End;
            End;
          End;
        DIR_LMETOL1,DIR_L5TOL1,DIR_BTITOL1,DIR_EKOMTOL1,DIR_C12TOL1,DIR_TRANSITTOL1 :
          case pMsg.m_sbyType of
            PH_DATARD_REQ:
              if m_pPort[pMsg.m_sbyIntID]<>Nil then
              Begin
               Inc(m_dwOUT);
               if (m_pPort[pMsg.m_sbyIntID]<>Nil)and(pMsg.m_sbyIntID>MAX_PORT) then exit;
               m_pPort[pMsg.m_sbyIntID].Send(@pMsg,pMsg.m_swLen);
              end;
          End;
        DIR_L2TOL1:
          Begin
            case pMsg.m_sbyType of
               PH_DATARD_REQ:
                 if m_pPort[pMsg.m_sbyIntID]<>Nil then
                 begin
                   Inc(m_dwOUT);
                   if m_pPort[pMsg.m_sbyIntID]=Nil then exit;
                   {$IFNDEF CLL1_DEBUG}
                    m_pPort[pMsg.m_sbyIntID].Send(@pMsg,pMsg.m_swLen);
                   {$ELSE}
                    pMsg.m_sbyFor  := DIR_L1TOL2;
                    pMsg.m_sbyType := PH_DATA_IND;
                    FPUT(BOX_L2,@pMsg);
                   {$ENDIF}
                 end;
               PH_SETPORT_IND:
                 Begin
                   Move(pMsg.m_sbyInfo[0],pDS,sizeof(CMessageData));
                   Move(pDS.m_sbyInfo[0],sPT,sizeof(SL1SHTAG));
                   m_pPort[pMsg.m_sbyIntID].SetDynamic(sPT);
                 End;
               PH_SETDEFSET_IND:
                 Begin
                   if m_pPort[pMsg.m_sbyIntID]=Nil then exit;
                   m_pPort[pMsg.m_sbyIntID].SetDefaultSett;
                 End;
               PH_CONN_IND:
                 Begin
                   if m_pPort[pMsg.m_sbyIntID]=Nil then exit;
                   m_pPort[pMsg.m_sbyIntID].Connect(pMsg);
                 End;
               PH_RECONN_IND:
                 Begin
                   if m_pPort[pMsg.m_sbyIntID]=Nil then exit;
                   m_pPort[pMsg.m_sbyIntID].ReConnect(pMsg);
                 End;
               PH_DISC_IND:
                 Begin
                   if m_pPort[pMsg.m_sbyIntID]=Nil then exit;
                   m_pPort[pMsg.m_sbyIntID].Disconnect(pMsg);
                 End;
               PH_FREE_PORT_IND:
                 Begin
                   if m_pPort[pMsg.m_sbyIntID]=Nil then exit;
                   m_pPort[pMsg.m_sbyIntID].FreePort(pMsg);
                 End;
               PH_SETT_PORT_IND:
                 Begin
                   if m_pPort[pMsg.m_sbyIntID]=Nil then exit;
                   m_pPort[pMsg.m_sbyIntID].SettPort(pMsg);
                 End;
               PH_COMM_IND:
                 Begin
                   if m_pPort[pMsg.m_sbyIntID]=Nil then exit;
                   m_pPort[pMsg.m_sbyIntID].SendCommandEx(pMsg);
                 End;
               PH_OPEN_PORT_IND:
                 Begin
                   Move(pMsg.m_sbyInfo[0],pDS,sizeof(CMessageData));
                   Move(pDS.m_sbyInfo[0],sPT,sizeof(SL1SHTAG));
                   if m_pPort[pMsg.m_sbyIntID]=Nil then exit;
                   m_pPort[pMsg.m_sbyIntID].OpenPortEx(sPT);
                 End;
               PH_RESET_PORT_IND:
                 Begin
                   if m_pPort[pMsg.m_sbyIntID]=Nil then exit;
                   m_pPort[pMsg.m_sbyIntID].ResetPort(pMsg);
                 End;
               PH_RECONN_L1_IND:
                 Begin
                   if m_pPort[pMsg.m_sbyIntID]=Nil then exit;
                   m_pPort[pMsg.m_sbyIntID].ReconnectL1(pMsg);
                 End;
               PH_STOP_IS_GPRS_IND: StopIsGprsPort;
            end;
          end;
        DIR_L1TOL1:
          case pMsg.m_sbyType of
            PH_CONNTMR_IND: m_pPort[pMsg.m_swObjID].QueryConnect(pMsg);
            PH_MCREG_IND  : begin end;
            PH_MCONN_IND  :
              begin
                SendMsg(BOX_L3_LME,0,DIR_LLTOLM3,PH_CONN_IND);
                pMsg.m_sbyFor  := DIR_L1TOL2;
                pMsg.m_sbyType := QL_CONNCOMPL_REQ;
                if ConfMeterAuto<>Nil then ConfMeterAuto.LoHandler(pMsg);
                case pMsg.m_sbyTypeIntID of
                  DEV_MASTER,DEV_K2000B_CLI : FPUT(BOX_L2,@pMsg);
                  DEV_BTI_CLI:
                    Begin
                      pMsg.m_sbyFor := DIR_ARTOL4;
                      FPUT(BOX_L4,@pMsg);
                    End;
                  DEV_BTI_SRV:
                    Begin
                      pMsg.m_sbyFor := DIR_L1TOBTI;
                      FPUT(BOX_L2,@pMsg);
                    End;
                  DEV_C12_SRV:
                    Begin
                      pMsg.m_sbyFor := DIR_L1TOL2;
                      FPUT(BOX_L4,@pMsg);
                    End;
                  DEV_TRANSIT:
                    Begin
                      pMsg.m_sbyFor := DIR_L1TOL2;
                      FPUT(BOX_L4,@pMsg);
                    End;
                End;

              end;
           PH_MDISC_IND  :
              Begin
                SendPMSG(BOX_UN_LOAD,pMsg.m_sbyDirID,DIR_ULTOUL,UNL_DIAL_DISC);
                SendMsg(BOX_L3_LME,0,DIR_LLTOLM3,PH_DISC_IND);
                pMsg.m_sbyFor  := DIR_L1TOL2;
                pMsg.m_sbyType := QL_DISCCOMPL_REQ;
                case pMsg.m_sbyTypeIntID of
                  DEV_MASTER,DEV_K2000B_CLI : FPUT(BOX_L2,@pMsg);
                  DEV_BTI_CLI:
                    Begin
                      pMsg.m_sbyFor := DIR_ARTOL4;
                      FPUT(BOX_L4,@pMsg);
                    End;
                  DEV_BTI_SRV:
                    Begin
                      pMsg.m_sbyFor := DIR_L1TOBTI;
                      FPUT(BOX_L2,@pMsg);
                    End;
                  DEV_C12_SRV:
                    Begin
                      pMsg.m_sbyFor := DIR_L1TOC12;
                      FPUT(BOX_L4,@pMsg);
                    End;
                  DEV_TRANSIT:
                    Begin
                      pMsg.m_sbyFor := DIR_ARTOL4;
                      FPUT(BOX_L4,@pMsg);
                    End;
                End;
              End;
            PH_DIAL_ERR_IND:
              Begin
                if EventBox<>Nil then EventBox.FixEvents(ET_CRITICAL,'Ошибка установления связи по GSM каналу!!!');
                if m_nQrySender[pMsg.m_sbyDirID]<>Nil then
                   m_nQrySender[pMsg.m_sbyDirID].OnDialError;
                Sleep(500);
              End;
            PH_MDISCSCMPL_IND:
              Begin
                 if EventBox<>Nil then EventBox.FixEvents(ET_RELEASE,'Соединение разорвано успешно.');
                 if m_pPort[pMsg.m_sbyIntID]=Nil then exit;
                 Sleep(200);
              End;
            PH_MRING_IND  :
              Begin

              End;
            PH_MNOCA_IND  :
              Begin
                if EventBox<>Nil then EventBox.FixEvents(ET_CRITICAL,'Внимание! Соединение разорвано по неизвестной причине.');
              End;
            PH_MBUSY_IND  :
              Begin
                if EventBox<>Nil then EventBox.FixEvents(ET_CRITICAL,'Внимание! Абонент уже занят.');
              End;
            PH_MNDLT_IND  :
              Begin
                if EventBox<>Nil then EventBox.FixEvents(ET_CRITICAL,'Внимание! Абонент отключен.');
              End;
            PH_MNANS_IND  :
              Begin
                if EventBox<>Nil then EventBox.FixEvents(ET_CRITICAL,'Внимание! Соединение разорвано по неизвестной причине.');
              End;
            PH_STATIONON_REQ :
              Begin
                SendMsg(BOX_L3_LME,0,DIR_LLTOLM3,PH_STATIONON_REQ);
                if m_nQrySender[pMsg.m_sbyDirID]<>Nil then m_nQrySender[pMsg.m_sbyDirID].SetModemState(PH_STATIONON_REQ);
              End;
            PH_STATIONOF_REQ :
              Begin
                SendMsg(BOX_L3_LME,0,DIR_LLTOLM3,PH_STATIONOF_REQ);
                if m_nQrySender[pMsg.m_sbyDirID]<>Nil then m_nQrySender[pMsg.m_sbyDirID].SetModemState(PH_STATIONOF_REQ);
              End;
          else
            if m_pPort[pMsg.m_swObjID]<>Nil then
            m_pPort[pMsg.m_swObjID].EventHandler(pMsg);
          End;
      end;
    except
     //TraceL(m_nLID,pMsg.m_swObjID,'(__)CL1MD::>Error Send.')
    End;
  Except
   if EventBox<>Nil then EventBox.FixEvents(ET_RELEASE,'(Error_Knsl1Module1 :: EventHandler!!!');
  end;
End;

procedure CL1Module.DoHalfSpeedTime(Sender:TObject);
Var
    i,nPID : Integer;
Begin
    try
     for i:=0 to m_sIniTbl.Count-1 do
     Begin
      nPID := m_sIniTbl.Items[i].m_sbyPortID;
      if Assigned(m_pPort[nPID]) then
      m_pPort[nPID].RunSpeedTmr;
     End;
    except
//      TraceL(1,0,'(__)CL1MD::>Error SpeedTimer Routing.');
    End
End;
procedure CL1Module.DoHalfTime(Sender:TObject);
Var
    i,nPID : Integer;
Begin
    try
     //if mBtiModule<>Nil then   mBtiModule.RunModule;
    // for i:=0 to MAX_GPRS-1 do
   //  if Assigned(m_nGPRS[i]) then m_nGPRS[i].Run;
     for i:=0 to m_sIniTbl.Count-1 do
     Begin
      nPID := m_sIniTbl.Items[i].m_sbyPortID;
      if Assigned(m_pPort[nPID]) then
      m_pPort[nPID].RunTmr;

      if m_blPortIndex[nPID]=False then
      if m_nQrySender[nPID]<>Nil then m_nQrySender[nPID].Run;
     End;
    except
//     TraceL(1,0,'(__)CL1MD::>Error Timer Routing.');
    End;
    //m_csOut.Leave;
End;
function CL1Module.GetPortState(nIndex:Byte):Boolean;
Begin
    Result := False;
    if Assigned(m_pPort[nIndex]) then
    Result := m_pPort[nIndex].GetPortState;
End;
function CL1Module.GetConnectState(nIndex:Byte):Boolean;
Begin
    Result := False;
    if Assigned(m_pPort[nIndex]) then
    Result := m_pPort[nIndex].GetConnectState;
End;
procedure CL1Module.StartPort;
Var
    i,nPID : Integer;
Begin
    for i:=0 to m_sbyAmPort-1 do
    Begin
     nPID := m_sIniTbl.Items[i].m_sbyPortID;
     if Assigned(m_pPort[nPID]) then
     m_pPort[i].StartPort;
    End;
End;
procedure CL1Module.StopPort;
Var
    i,nPID : Integer;
Begin
    for i:=0 to m_sbyAmPort-1 do
    Begin
     nPID := m_sIniTbl.Items[i].m_sbyPortID;
     if Assigned(m_pPort[nPID]) then
     m_pPort[nPID].StopPort;
    End;
End;
procedure CL1Module.StopIsGprsPort;
Var
    i,nPID : Integer;
Begin
    for i:=0 to m_sbyAmPort-1 do
    Begin
     nPID := m_sIniTbl.Items[i].m_sbyPortID;
     if Assigned(m_pPort[nPID]) then
     m_pPort[nPID].StopIsGPRS;
    End;
End;
procedure CL1Module.DelNodeLv(nIndex:Integer);
Begin
//    TraceL(1,0,'(__)CL1MD::>DelNodeLv.');
    if Assigned(m_pPort[nIndex]) then
    Begin
     m_pPort[nIndex].Close;
     m_pPort[nIndex].Destroy;
     m_pPort[nIndex] := Nil;
    End;
End;
procedure CL1Module.AddNodeLv(pTbl:SL1TAG);
Begin
//    TraceL(1,0,'(__)CL1MD::>AddNodeLv.');
End;
procedure CL1Module.EditNodeLv(pTbl:SL1TAG);
Begin
//    TraceL(1,0,'(__)CL1MD::>EditNodeLv.');
End;
destructor CL1Module.Destroy;
var
  I: Integer;
  P: CPort;
begin
  if mBtiModule <> nil then FreeAndNil(mBtiModule);

  for I := Low(m_pPort) to High(m_pPort) do begin
    P := m_pPort[I];
    if P <> nil then begin
      if P is CPort then
        FreeAndNil(m_pPort[I]);
    end;
  end;

  inherited;
end;

end.
