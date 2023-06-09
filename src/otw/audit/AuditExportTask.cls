Class otw.audit.AuditExportTask Extends %SYS.Task.Definition
{

Parameter TaskName = "Export Audit Data";

/// Days to keep in %SYS.Audit
Property DaysToKeep As %ZEN.Datatype.string [ InitialExpression = 0 ];

ClassMethod FindMyID() As %String
{
	Set pQuery = "SELECT ID FROM %SYS.Task WHERE TaskClass = 'otw.audit.AuditExportTask'"
	Set pResult = ""
	Set rs = ##class(%ResultSet).%New()
	Set tSC = rs.Prepare(pQuery)
	If $$$ISOK(tSC) {
		Set tSC = rs.Execute()
		If $$$ISOK(tSC), rs.Next() Set pResult = rs.GetData(1)
	}
	Do rs.Close()
	Set rs = ""
	If (pResult '= "") { Quit pResult }
	Set objTask = ##class(%SYS.Task).%New()
	Set objTask.Description = "Export Audit Data"
	Set objTask.MirrorStatus = 3  // "Any"
	Set objTask.Name = ..#TaskName
	Set objTask.NameSpace = "%SYS"
	Set objTask.RunAsUser = "_SYSTEM"
	Set objTask.TaskClass = "otw.audit.AuditExportTask"
	Set objTask.TimePeriod = 0  // (DISPLAYLIST = ",Daily,Weekly,Monthly,Monthly Special,Run After,On Demand", VALUELIST = ",0,1,2,3,4,5")
	//Set objTask.TimePeriodEvery=1
	Set objTask.TimePeriodDay = ""
	Set objTask.DailyFrequency = 0  // (DISPLAYLIST = ",Once,Several", VALUELIST = ",0,1")
	//Set objTask.DailyFrequencyTime=0  // (DISPLAYLIST = ",Minutes,Hourly", VALUELIST = ",0,1")
	Set objTask.DailyIncrement = 1  // Run every # 
	Set objTask.DailyStartTime = 120
	Set tSC = objTask.%Save()
	Set pResult = objTask.%Id()
	Quit pResult
}

Method OnTask() As %Status
{
	Quit ##class(otw.audit.Util).AuditExport(..DaysToKeep)
}

ClassMethod RunNow() As %Status
{
	Set tID = ..FindMyID()
	Set tSC = ##class(%SYS.Task).RunNow(tID)
	Quit tSC
}

}
