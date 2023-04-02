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

}
