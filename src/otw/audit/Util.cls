Class otw.audit.Util
{

ClassMethod AuditExport(pDaysToKeep = 0) As %Status
{
	Set d = "-"
	Set pBeginDateTime = ""
	Set pEndDateH = +$Horolog - pDaysToKeep  // 66572
	Set pEndDate8 = $ZDate(pEndDateH,8)  // 20230408
	Set pEndDateTime = $Extract(pEndDate8,1,4)_d_$Extract(pEndDate8,5,6)_d_$Extract(pEndDate8,7,8)
	Quit ..AuditExportByDates(pBeginDateTime,pEndDateTime)
}

ClassMethod AuditExportByDates(
	pBeginDateTime = "",
	pEndDateTime = "") As %Status
{
	Set u = "_"
	Set tSC = $$$OK
	Set tHost = $SYSTEM.INetInfo.LocalHostName() 
	Set pFileName = tHost
	If (pBeginDateTime '= "") {
		Set pFileName = pFileName_u_pBeginDateTime
	}
	If (pEndDateTime '= "") {
		Set pFileName = pFileName_u_pEndDateTime
	}
	Set pFileName = pFileName_u_"auditexport.xml"
	Set pFlags = 0
	Set tExists = ##class(%File).Exists(pFileName)
	If tExists {
		Write pFileName," already exists.",!
		Quit tSC
	}
	Set tSC = ##class(%SYS.Audit).Export(pFileName,.pNumExported,pFlags,pBeginDateTime,pEndDateTime)
	zw pNumExported
	Quit tSC
}

/// dir = target directory
/// .cnt = data records written
ClassMethod AuditExportToCSV(
	dir As %String = "",
	ByRef cnt As %Integer = 0) As %Status
{
#define quote(%val) $zutil(144,1,%val)
#define quotes(%val) $zutil(144,1,%val)
  set filename="audit.CSV"
  set file=##class(%File).%New(dir_filename)
  set file.LineTerminator=$c(10)
  do file.Open("WSN")

#; allow selectiv export  
  set col="AuditIndex,Authentication,CSPSessionID,ClientExecutableName,ClientIPAddress"_
        ",Description,Event,EventData,EventSource,EventType,GroupName,JobId,JobNumber"_
        ",Namespace,OSUsername,Pid,Roles,RoutineSpec,StartupClientIPAddress,Status"_
        ",SystemID,UTCTimeStamp,UserInfo,Username"
#; or take them all  !!! starts with ID !!!
#; set col="*"         
  set sql = "Select "_col_" from %SYS.Audit "
  set rset=##class(%ResultSet).%New()
#; use ODBC mode;  => 1  
  set rset.RuntimeMode=1 
  set tSC=rset.Prepare(sql)
  if tSC {
    set tSC=rset.Execute()
#; write header line
    if tSC {
      set colcnt=rset.GetColumnCount()
      for i=1:1:colcnt {
        set tSC=file.Write(rset.GetColumnHeader(i)_$s(i<colcnt:",",1:""))   
        quit:'tSC
        }
      do file.WriteLine("")
    }
    if tSC {
      while rset.Next() {
        for i=1:1:colcnt {
          set tSC=file.Write($$$quotes(rset.GetData(i))_$s(i<colcnt:",",1:"")) 
          quit:'tSC
          }
        do file.WriteLine("")
        }
      }
    }
  do file.Close()
  set cnt=%ROWCOUNT
  quit tSC
}

/// Source: %SYS.Audit
/// Target: otw.audit.consolidator / otw_audit.consolidator
ClassMethod AuditTransfer(
	start As %Integer = 1,
	ByRef last As %Integer = 0) As %Status
{
  set (min,max)=0
  &SQL(select MIN(AuditIndex),MAX(AuditIndex) into :min,:max from %SYS.Audit)
  if SQLCODE b  i 0
  if start<min set start=min
  if (last>max)!('last) set last=max
  #sqlcompile select=Display
  for id=start:1:max {
    kill au
    &SQL(select AuditIndex, Authentication, CSPSessionID, ClientExecutableName, 
     ClientIPAddress, Description, Event, EventData, EventSource, 
     EventType, GroupName, JobId, JobNumber, Namespace,
     OSUsername, Pid, Roles, RoutineSpec, StartupClientIPAddress, 
     Status, SystemID, UTCTimeStamp, UserInfo, Username 
        into :au() from %SYS.Audit where AuditIndex = :id)
    if SQLCODE<0 b  i 1
#; not found    
    if SQLCODE=100  continue    
    &SQL(DELETE from otw_audit.consolidator where AuditIndex = :id )
    if SQLCODE<0 b  i 2
#; modify columns
#; ClientIPAddress
    if au(6)["." set au(6)="*** skipped ****"
#; StartupClientIPAddress    
    if au(20)["." set au(20)=".."_$p(au(20),".",3,4)
    set sql="INSERT into otw_audit.consolidator ("_
      "AuditIndex, Authentication, CSPSessionID, ClientExecutableName,"_ 
      "ClientIPAddress, Description, Event, EventData, EventSource, "_
      "EventType, GroupName, JobId, JobNumber, Namespace,"_
      "OSUsername, Pid, Roles, RoutineSpec, StartupClientIPAddress,"_ 
      "Status, SystemID, UTCTimeStamp, UserInfo, Username) VALUES ("_
      "?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
    set rs=##class(%ResultSet).%New()
    set tSC=rs.Prepare(sql)
    b:'tSC  i 3
    set tSC=rs.Execute(au(2),au(3),au(4),au(5),
      au(6),au(7),au(8),au(9),au(10),
      au(11),au(12),au(13),au(14),au(15),
      au(16),au(17),au(18),au(19),au(20),
      au(21),au(22),au(23),au(24),au(25))
#; b  i 5
   write id," "
  }
 if tSC,SQLCODE<0 set tSC=##class(%Exception.SQL).CreateFromSQLCODE(SQLCODE,$g(%msg)) 
 quit tSC
}

ClassMethod CreateViewUserChange() As %Status
{
	Set tSC = $$$OK
	&sql(CREATE VIEW UserChange 
		AS SELECT AuditIndex, Description, Event, EventData, OSUsername, Roles, SystemID, UTCTimeStamp, Username
		FROM otw_audit.consolidator WHERE Event='USERCHANGE')
	IF SQLCODE=0 {WRITE "Created a view",!}
	ELSEIF SQLCODE=-201 {WRITE "View already exists",!}
	ELSE {WRITE "Serious SQL problem: ",SQLCODE," ",%msg,! }
	Quit tSC
}

}
