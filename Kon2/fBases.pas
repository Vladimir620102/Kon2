unit fBases;

interface
uses
  Windows,forms, Classes, SysUtils, SyncObjs, StdCtrls, ComCtrls, Db, Dates,
  utltypes, utlconst, utlbox, INIfiles, IBDatabase,IBQuery;
type
    TfBase = class
    private
     m_strProvider   : String;
     m_strFileName   : String;
     m_blIsConnect   : Boolean;
    public
     LOGTransaction  : TIBTransaction;
     LOGDB           : TIBDatabase;
     LOGQuery        : TIBQuery;
     LOGBLOB         : TIBQuery;
     constructor Create(m_strProvider : string); overload;
     procedure Init(strFileName:String);
     function  Connect:Boolean;
     function  Disconnect:Boolean;
     procedure CreateConnection(var vConn:TIBDatabase;var vQry:TIBQuery);
     procedure DestroyConnection(var vConn:TIBDataBase;var vQry:TIBQuery);
     procedure DestroyConnectionQuery(vQry:TIBQuery);
  //   function  ExecQry(strSQL:String):Boolean;
     function  SetQuery(strSQL: TStringList):Boolean;
 //    function  OpenQry(strSQL:String;var nCount:Integer):Boolean;
     function  GetQuery(strSQL : string; var Query : TIBQuery):Boolean;
     procedure CloseQry;
     function SetBLOB(strSQL : TStringList) : boolean;         
    End;

 var fBase : TfBase;
     strSettingsPath : string;

implementation

const
    MAX_BLOCK_QRY = 50;

constructor TfBase.Create(m_strProvider : string);
begin
  Self.Init(m_strProvider);
  Self.Connect;
end;

procedure TfBase.Init(strFileName:String);
var Fl   : TINIFile;
Begin
//  m_strFileName := strFileName;
  m_strProvider := strFileName;
  m_blIsConnect := False;
  Fl := TINIFile.Create(strFileName);
  m_strProvider := Fl.ReadString('DBCONFIG', 'DBLogFile', '');
  FreeAndNil(Fl);
End;

function TfBase.Connect:Boolean;
Begin
  Result := True;
  m_blIsConnect := True;
  try
   CreateConnection(LOGDB,LOGQuery);
  except
  end;
End;

function TfBase.Disconnect:Boolean;
Begin
   Result := True;
  m_blIsConnect := False;
  try
   DestroyConnection(LOGDB,LOGQuery);
  except
  end;
End;

procedure TfBase.CreateConnection(var vConn:TIBDataBase;var vQry:TIBQuery);
Begin
  if vConn=Nil then
  Begin
    vConn := TIBDataBase.Create(nil);
    LOGTransaction := TIBTransaction.Create(nil);
    with vConn do begin
     SQLDialect := 3;
     DatabaseName := m_strProvider;
     Params.Add('user_name=sysdba');
     Params.Add('password=masterkey');
     Params.Add('lc_ctype=WIN1251');
     LoginPrompt := False;
     DefaultTransaction := LOGTransaction;
    end;
    vConn.Connected := True;
    if vQry=Nil then
    Begin
     vQry := TIBQuery.Create(Nil);
     vQry.Transaction:=LOGTransaction;
     vQry.Database:=vConn;
    End;
  End;
End;

procedure TfBase.DestroyConnection(var vConn:TIBDataBase;var vQry:TIBQuery);
Begin
  if vConn<>Nil then
  Begin
   FreeAndNil(vConn);
   if vQry<>Nil then
   Begin
    FreeAndNil(vQry);
   End;
   if LOGTransaction<>Nil then
   Begin
    FreeAndNil(LOGTransaction);
   End;
  End;
End;

procedure TfBase.DestroyConnectionQuery(vQry:TIBQuery);
Begin
  if vQry<>Nil then
  Begin
   FreeAndNil(vQry);
  End;
End;


function  TfBase.GetQuery(strSQL : string; var Query : TIBQuery):Boolean;
var res    : Boolean;
begin
  res := False;
  try
    LOGQuery.Close;
    LOGQuery.SQL.Clear;
    LOGQuery.SQL.Add(strSQL);
    LOGQuery.Open;
//  LOGQuery.FetchAll;
    if LOGQuery.RecordCount >= 0 then begin
      res := True;
      Query := LOGQuery;
    end;
  except
    // здесь добавить запись ошибки в лог
    res := false;
  end;
  Result := res;
end;


procedure TfBase.CloseQry;
Begin
  if m_blIsConnect=False then exit;
  if m_blIsBackUp=True then exit;
  LOGQuery.SQL.Clear;
  LOGQuery.Close;
End;

function TfBase.SetQuery(strSQL: TStringList): Boolean;
Var res : Boolean;
begin
  res := True;
  try
    LOGQuery.Close;
    LOGQuery.SQL.Clear;
    LOGQuery.SQL:=strSQL;
    LOGQuery.ExecSQL;
   except
    // здесь добавить запись ошибки в лог
    res := False;
   end;
   Result := res;
end;

function TfBase.SetBLOB(strSQL : TStringList) : boolean;
Var res : Boolean;
begin
  res := True;
  try
    LOGBLOB.Close;
    LOGBLOB.SQL.Clear;
    LOGBLOB.SQL:=strSQL;
    LOGBLOB.ExecSQL;
   except
    // здесь добавить запись ошибки в лог
    res := False;
   end;
   Result := res;
end;

initialization
  strSettingsPath := ExtractFilePath(Application.ExeName) + 'Settings\USPD_Config.ini';
  fBase := TfBase.Create(strSettingsPath);
  fBase.Connect;

finalization
  fBase.Disconnect;
  fBase.Destroy;

end.

