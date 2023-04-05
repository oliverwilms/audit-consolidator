Class otw.audit.Util
{

ClassMethod AuditExport(pDaysToKeep = 0) As %Status
{
	Set tSC = $$$OK
	Set tHost = $SYSTEM.INetInfo.LocalHostName() 
	Set pBeginDateTime = ""
	Set pEndDateTime = ""
	Set pFileName = tHost_"_auditexport.xml"
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
  set filename="audit.CSV"
  set file=##class(%File).%New(dir_filename)
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
          set val=rset.GetData(i)
#; replace <CR><LF> by §§ 
          if '$isvalidnum(val) set val=""""_$tr(val,$c(13,10),"§§")_""""
          set tSC=file.Write(val_$s(i<colcnt:",",1:""))   
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

}
