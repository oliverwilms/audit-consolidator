Class otw.audit.consolidator Extends (%Persistent, %XML.Adaptor)
{

Index NewIndex1 On (UTCTimeStamp, SystemID, AuditIndex) [ IdKey, PrimaryKey, Unique ];

Property AuditIndex As %BigInt [ Required ];

/// Property Authentication As Security.Datatype.Authentication;
Property Authentication As %String(MAXLEN = 128);

Property CSPSessionID As %String(MAXLEN = 16);

Property ClientExecutableName As %String(MAXLEN = 128);

Property ClientIPAddress As %String(MAXLEN = 128);

Property Description As %SYS.AuditString(MAXLEN = 128);

Property Event As %String(MAXLEN = 64);

Property EventData As %SYS.AuditString(MAXLEN = 16384);

Property EventSource As %String(MAXLEN = 64);

Property EventType As %String(MAXLEN = 64);

Property GroupName As %String(MAXLEN = 64);

Property JobId As %String(MAXLEN = 16);

Property JobNumber As %Integer;

Property Namespace As %String(MAXLEN = 128);

Property OSUsername As %String(MAXLEN = 16);

Property Pid As %String(MAXLEN = 16);

Property Roles As %String(MAXLEN = 2048);

Property RoutineSpec As %String(MAXLEN = 512);

Property StartupClientIPAddress As %String(MAXLEN = 128);

/// Property Status As %Status [ InitialExpression = 1 ];
Property Status As %String(MAXLEN = 2048);

Property SystemID As %String(MAXLEN = 128) [ Required ];

Property UTCTimeStamp As %String(MAXLEN = 64) [ Required ];

Property UserInfo As %String(MAXLEN = 64);

Property Username As %SYS.AuditString(MAXLEN = 160);

ClassMethod Exists(
	UTCTimeStamp As %String = "",
	SystemID As %String = "",
	AuditIndex As %Integer = 0,
	ByRef Audit As %ObjectHandle,
	ByRef Status As %Status) As %Boolean
{
	Set Audit = $$$NULLOREF
	Set Status = $$$OK
	Set tData = 0
	If (UTCTimeStamp '= "") Set tData = tData + 1
	If (SystemID '= "") Set tData = tData + 2
	If (AuditIndex '= 0) Set tData = tData + 4
	If (tData < 7) {
		Set tMessage = "UTCTimeStamp, SystemID, and AuditIndex are required."
		Set Status = $$$ERROR($$$GeneralError,tMessage)
		Quit 0
	}
	Set tID = UTCTimeStamp_"||"_SystemID_"||"_AuditIndex
	Set Audit = ..%OpenId(tID)
	Quit 1
}

/// Flags - Bit 0 - Do not import records, just return count
/// Note: On failure, no records will be imported
ClassMethod Import(
	FileName As %String = "",
	ByRef NumImported As %Integer,
	Flags As %Integer = 0) As %Status
{
	Set pDebug = 1
	Set pMaxLines = -1
	If ($Get(FileName) = "") {
		Set tMessage = "Filename is required."
		Set tSC = $$$ERROR($$$GeneralError,tMessage)
		Quit tSC
	}
	Set tSC = $$$OK
	If ##class(%File).Exists(FileName) {
		Set tReader = ##class(%XML.Reader).%New()
		Set tSC = tReader.OpenFile(FileName)
		If $$$ISERR(tSC) Quit tSC
		Do tReader.Correlate("Audit","otw.audit.consolidator")
		#dim Audit As otw.audit.consolidator
		#dim tExistingAudit As otw.audit.consolidator
		While tReader.Next(.Audit,.tSC) {
			If $$$ISERR(tSC) { Quit }
			Set tID = Audit.%Id()
			Set tExistingAudit = ##class(otw.audit.consolidator).%OpenId(tID)
			If $IsObject(tExistingAudit) {
				Set tSC = tExistingAudit.%Delete()
				If $$$ISERR(tSC) { Quit }
			}
			Set tSC = Audit.%Save()
			If $$$ISERR(tSC) { Quit }
		}
		If $$$ISERR(tSC) Quit tSC
	}
	Quit $$$OK

	##sql(START TRANSACTION)
	Set $ZT="ERROR" 
	Write 1,!
	SET ^otwaudit(1,2,3)=100
	Write 2,!
	//SET ^otwaudit(2,3,4)=error
	Write 3,!
	SET ^otwaudit(1,1)=200
	##sql(COMMIT WORK)
	Write !,"Transaction Committed"
	Quit tSC
ERROR
	##sql(ROLLBACK WORK)
	Write !,"Transaction failed."
	Set tSC = $$$ERROR($$$GeneralError,"Transaction failed.")
	Quit tSC
}

ClassMethod ImportAll() As %Status
{
	Set tSC = $$$OK
	Set tDir = $ZU(12)
	Set tIncludeAllDirs = 0
	Set tSortBy = ""
	Set tSC = ##class(%File).FileSetExecute(.tHandle,tDir,"*.xml",tSortBy,tIncludeAllDirs)
	If $$$ISERR(tSC) { Quit }
	Set tAtEnd = 0
	For {
		Set tSC = ##class(%File).FileSetFetch(.tHandle, .tRow, .tAtEnd)
		If '$$$ISOK(tSC)!($ListLength(tRow)<6) Quit
		Set tFile = $List(tRow, 6)
		Set tType = $List(tRow, 2)
		Set tPath = $list(tRow, 1)
		Set tFileName = ##class(%File).GetFilename(tPath)
		Set tSC = ..Import(tFileName,.tNum)
		If $$$ISERR(tSC) Quit
		If tAtEnd Quit
	}
	Set x = ##class(%File).FileSetClose(.tHandle)
	Quit tSC
}

Storage NewStorage1
{
<SQLMap name="Map1">
<Data name="AuditIndex">
<Delimiter>
<![CDATA[">"]]></Delimiter>
<Piece>1</Piece>
</Data>
<Data name="Authentication">
<Delimiter>
<![CDATA[">"]]></Delimiter>
<Piece>2</Piece>
</Data>
<Data name="CSPSessionID">
<Delimiter>
<![CDATA[">"]]></Delimiter>
<Piece>5</Piece>
</Data>
<Data name="ClientExecutableName">
<Delimiter>
<![CDATA[">"]]></Delimiter>
<Piece>3</Piece>
</Data>
<Data name="ClientIPAddress">
<Delimiter>
<![CDATA[">"]]></Delimiter>
<Piece>4</Piece>
</Data>
<Data name="Description">
<Delimiter>
<![CDATA[">"]]></Delimiter>
<Piece>6</Piece>
</Data>
<Data name="Event">
<Delimiter>
<![CDATA[">"]]></Delimiter>
<Piece>7</Piece>
</Data>
<Data name="EventData">
<Delimiter>
<![CDATA[">"]]></Delimiter>
<Piece>8</Piece>
</Data>
<Data name="EventSource">
<Delimiter>
<![CDATA[">"]]></Delimiter>
<Piece>9</Piece>
</Data>
<Data name="EventType">
<Delimiter>
<![CDATA[">"]]></Delimiter>
<Piece>10</Piece>
</Data>
<Data name="GroupName">
<Delimiter>
<![CDATA[">"]]></Delimiter>
<Piece>11</Piece>
</Data>
<Data name="JobId">
<Delimiter>
<![CDATA[">"]]></Delimiter>
<Piece>12</Piece>
</Data>
<Data name="JobNumber">
<Delimiter>
<![CDATA[">"]]></Delimiter>
<Piece>13</Piece>
</Data>
<Data name="Namespace">
<Delimiter>
<![CDATA[">"]]></Delimiter>
<Piece>14</Piece>
</Data>
<Data name="OSUsername">
<Delimiter>
<![CDATA[">"]]></Delimiter>
<Piece>15</Piece>
</Data>
<Data name="Pid">
<Delimiter>
<![CDATA[">"]]></Delimiter>
<Piece>16</Piece>
</Data>
<Data name="Roles">
<Delimiter>
<![CDATA[">"]]></Delimiter>
<Piece>17</Piece>
</Data>
<Data name="RoutineSpec">
<Delimiter>
<![CDATA[">"]]></Delimiter>
<Piece>18</Piece>
</Data>
<Data name="StartupClientIPAddress">
<Delimiter>
<![CDATA[">"]]></Delimiter>
<Piece>19</Piece>
</Data>
<Data name="Status">
<Delimiter>
<![CDATA[">"]]></Delimiter>
<Piece>20</Piece>
</Data>
<Data name="SystemID">
<Delimiter>
<![CDATA[">"]]></Delimiter>
<Piece>21</Piece>
</Data>
<Data name="UTCTimeStamp">
<Delimiter>
<![CDATA[">"]]></Delimiter>
<Piece>24</Piece>
</Data>
<Data name="UserInfo">
<Delimiter>
<![CDATA[">"]]></Delimiter>
<Piece>22</Piece>
</Data>
<Data name="Username">
<Delimiter>
<![CDATA[">"]]></Delimiter>
<Piece>23</Piece>
</Data>
<Global>otwaudit</Global>
<Subscript name="1">
<Expression>{UTCTimeStamp}</Expression>
</Subscript>
<Subscript name="2">
<Expression>{SystemID}</Expression>
</Subscript>
<Subscript name="3">
<Expression>{AuditIndex}</Expression>
</Subscript>
<Type>data</Type>
</SQLMap>
<StreamLocation>^otw.audit.consolidatorS</StreamLocation>
<Type>%Storage.SQL</Type>
}

Storage Default
{
<Data name="consolidatorDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Authentication</Value>
</Value>
<Value name="3">
<Value>CSPSessionID</Value>
</Value>
<Value name="4">
<Value>ClientExecutableName</Value>
</Value>
<Value name="5">
<Value>ClientIPAddress</Value>
</Value>
<Value name="6">
<Value>Description</Value>
</Value>
<Value name="7">
<Value>Event</Value>
</Value>
<Value name="8">
<Value>EventData</Value>
</Value>
<Value name="9">
<Value>EventSource</Value>
</Value>
<Value name="10">
<Value>EventType</Value>
</Value>
<Value name="11">
<Value>GroupName</Value>
</Value>
<Value name="12">
<Value>JobId</Value>
</Value>
<Value name="13">
<Value>JobNumber</Value>
</Value>
<Value name="14">
<Value>Namespace</Value>
</Value>
<Value name="15">
<Value>OSUsername</Value>
</Value>
<Value name="16">
<Value>Pid</Value>
</Value>
<Value name="17">
<Value>Roles</Value>
</Value>
<Value name="18">
<Value>RoutineSpec</Value>
</Value>
<Value name="19">
<Value>StartupClientIPAddress</Value>
</Value>
<Value name="20">
<Value>Status</Value>
</Value>
<Value name="21">
<Value>UserInfo</Value>
</Value>
<Value name="22">
<Value>Username</Value>
</Value>
</Data>
<DataLocation>^otw.audit.consolidatorD</DataLocation>
<DefaultData>consolidatorDefaultData</DefaultData>
<IdLocation>^otw.audit.consolidatorD</IdLocation>
<IndexLocation>^otw.audit.consolidatorI</IndexLocation>
<StreamLocation>^otw.audit.consolidatorS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
