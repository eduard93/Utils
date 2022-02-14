/// Digital Ocean API. 
/// Ratelimit: 5000 requests per hour.
/// How-to: https://www.digitalocean.com/community/tutorials/how-to-use-the-digitalocean-api-v2
/// Docs: https://developers.digitalocean.com/documentation/v2/
/// To start using this class:
///   - Create SSLConfiguration DefaultSSL or change SSLConfiguration parameter to a name of a valid configuration
///   - Set ^DigitalOcean global to your access key value
Class Utils.DigitalOcean
{

Parameter LOG As %Boolean = 1;

Parameter SSLConfiguration = "DefaultSSL";

Parameter Server = "api.digitalocean.com";

/// Call resize till it succeds.
/// Do ##class(Utils.DigitalOcean).ForceResize()
ClassMethod ForceResize(DropletId As %Integer, Size As %String = "s-2vcpu-4gb", Disk As %Boolean = {$$$NO})
{
	Try {
		While 1 {
			Kill ActionId
			Do ..Log("Starting resize")
			Set Status = ..Resize(DropletId, Size, Disk, .ActionId)
			Do ..Log("ActionId: " _ ActionId)
			If $$$ISERR(Status) {
				Do ..LogStatus(Status)
			} Else {
				Set Completed = $$$NO
				While Completed '= $$$YES {
					Hang 0.7
					Kill Result
					Set Status = ..GetAction(ActionId, .Result)
					
					If $$$ISERR(Status) {
						Do ..LogStatus(Status)
					} Else {
						Do ..Log("Current status: " _ $Get(Result))
						
						If ((Result = "completed")||(Result = "errored")) {
							Set Completed = $$$YES
							Return:(Result = "completed")
						}
					}
				}
			}
		}
	} Catch ex {
		#Dim ex As %Exception.General
		Do ..LogException(ex)
	}
}

/// Resize droplet. Returns action.
/// https://developers.digitalocean.com/documentation/v2/#resize-a-droplet
/// Do ##class(Utils.DigitalOcean).Resize(,1)
ClassMethod Resize(DropletId As %Integer, Size As %String = "s-2vcpu-4gb", Disk As %Boolean = {$$$NO}, Output ActionId As %Integer, Test As %Integer(MINVAL=0,MAXVAL=2) = 0) As %Status
{
	#Dim Status As %Status = $$$OK
	#Dim Request As %Net.HttpRequest = ..GetRequest()
	#Dim Body As %DynamicObject
	
	Set Request.Location = "/v2/droplets/"_DropletId_"/actions"	
	Set Body = {"type":"resize","size":(Size)}
	
	Do Body.%Set("disk", Disk, "boolean")
	
	Do Request.EntityBody.Write(Body.%ToJSON())
	Quit:$$$ISERR(Status) Status
	Set ActionId = Result.action.id	
	Quit Status
}

/// Get all actions. Pagesize = 5000 works.
/// https://developers.digitalocean.com/documentation/v2/#actions
/// Do ##class(Utils.DigitalOcean).GetActions()
ClassMethod GetActions(Page As %Integer = 1, PageSize As %Integer = 25, Output Result As %DynamicObject, Test As %Integer(MINVAL=0,MAXVAL=2) = 0) As %Status
{
	Kill Result
	#Dim Status As %Status = $$$OK
	#Dim Request As %Net.HttpRequest = ..GetRequest()
	
	Do Request.SetParam("page", Page)
	Do Request.SetParam("per_page", PageSize)
	
	Set Location = "/v2/actions/"
	
	Set Status = ..ExecuteRequest("GET", Location, .Result, Request, , Test)		
	Quit:$$$ISERR(Status) Status

	Quit Status
}

/// Get information about action.
/// https://developers.digitalocean.com/documentation/v2/#retrieve-an-existing-action
/// Do ##class(Utils.DigitalOcean).GetStatus()
ClassMethod GetAction(ActionId As %Integer, Output Progress As %String(VALUELIST="in-progress,completed,errored,"), Test As %Integer(MINVAL=0,MAXVAL=2) = 0) As %Status
{
	Kill Progress
	#Dim Status As %Status = $$$OK
	
	Set Location = "/v2/actions/" _ ActionId
	Set Status = ..ExecuteRequest("GET", Location, .Result, , , Test)	
	Quit:$$$ISERR(Status) Status
	Set Progress = Result.action.status
	Quit Status
}

/// Get information about droplet
/// https://developers.digitalocean.com/documentation/v2/#retrieve-an-existing-droplet-by-id
/// Do ##class(Utils.DigitalOcean).GetDroplet()
ClassMethod GetDroplet(DropletId As %Integer, Output Result As %DynamicObject, Test As %Integer(MINVAL=0,MAXVAL=2) = 0) As %Status
{
	Kill Result
	#Dim Status As %Status = $$$OK

	Set Location = "/v2/droplets/" _ DropletId
	Set Status = ..ExecuteRequest("GET", Location, .Result, , , Test)
	Quit Status
}

/// Get basic request.
ClassMethod GetRequest() As %Net.HttpRequest
{
	#Dim Request As %Net.HttpRequest = ##class(%Net.HttpRequest).%New()
	Set Request.Https = $$$YES
	Set Request.SSLConfiguration = ..#SSLConfiguration
	Set Request.Server = ..#Server	
	Set Request.ContentType = ##class(%CSP.REST).#CONTENTTYPEJSON
	Do Request.SetHeader("Authorization", "Bearer " _ ..GetKey())
	Quit Request
}

/// Get Access Key
/// https://www.digitalocean.com/community/tutorials/how-to-use-the-digitalocean-api-v2
ClassMethod GetKey() As %Net.HttpRequest [ CodeMode = expression ]
{
$Get(^DigitalOcean)
}

/// Ececute request against DigitalOcean API.
ClassMethod ExecuteRequest(Method As %String(VALUELIST="GET,POST,PUT,DELETE"), Location As %String, Output Result As %DynamicObject, Request As %Net.HttpRequest = {..GetRequest()}, SuccessCode As %Integer = {$Case(Method, "POST":201,:200)}, Test As %Integer(MINVAL=0,MAXVAL=2) = 0) As %Status
{
	Kill Result
	#Dim Status As %Status = $$$OK
	Set Status = Request.Send(Method, Location, Test)
	
	If (Test '= 1) {
		If (Request.HttpResponse.StatusCode '= SuccessCode) {
			Set Status = $$$ERROR($$$GeneralError, $$$FormatText("Received %1 expected %2. Responce body: %3", Request.HttpResponse.StatusCode, SuccessCode, Request.HttpResponse.Data.Read($$$MaxStringLength)))
		}
		Set Result = {}.%FromJSON(Request.HttpResponse.Data)
	}
	
	
	Quit Status
}

ClassMethod LogException(ex As %Exception.AbstractException)
{
	Do:(..#LOG) ..LogStatus(ex.AsStatus())
}

ClassMethod LogStatus(sc As %Status)
{
	Do:(..#LOG) ..Log($System.Status.GetErrorText(sc))
}

ClassMethod Log(msg As %String)
{
	Write:(..#LOG) $ZDATETIME($ZTIMESTAMP, 3, 1, 3) _ " " _ msg,!
}

}

