Class Utils.MDX2JSON [ Abstract ]
{

Parameter Username;

Parameter Password;

Parameter Https As %Boolean = {$$$YES};

Parameter SSLConfiguration = "DefaultSSL";

Parameter Server = "dcstats.intersystems.ru";

Parameter Location = "MDX2JSON/MDX";

Parameter Namespace = "COMMUNITY";

/// Do ##class(Utils.MDX2JSON).Test()
ClassMethod Test(Test As %Integer(MINVAL=0,MAXVAL=2) = 0) As %Status
{
	#Dim Status As %Status = $$$OK
	#Dim Request As %Net.HttpRequest = ##class(%Net.HttpRequest).%New()
	Set Request.Username = ..#Username
	Set Request.Password = ..#Password
	Set Request.Https = ..#Https
	Set Request.SSLConfiguration = ..#SSLConfiguration
	Set Request.Server = ..#Server
	Set Request.Location = ..#Location
	Do Request.SetParam("Namespace", ..#Namespace)
	Do Request.SetHeader("Accept", "application/json")
	
	Set Body = {}
	Set Body.MDX = "SELECT NON EMPTY {%LABEL(ISNULL([DateDimension].[H1].[DayMonthYear].&[NOW],0),""Today"",""#""),%LABEL(AVG([DateDimension].[H1].[DayMonthYear].Members),""Average"",""#.##"")} ON 0 FROM [POST] %FILTER %OR({[DateDimension].[H1].[Year].&[NOW]})"

	Do Request.EntityBody.Write(Body.%ToJSON())
	
	Set Status = Request.Post(,Test)
	
	If Request.HttpResponse.StatusCode '= 200 {
		Set Status = $$$ERROR($$$GeneralError, "Received " _ Request.HttpResponse.StatusCode _ " expected 200")	
	}
	
	Quit:$$$ISERR(Status) Status

	Set Result = ##class(%AbstractObject).%FromJSON(Request.HttpResponse.Data)
	
	// Result in json
	Write:$IsObject(Result) Result.%ToJSONFormat()
	
	Quit Status
}

}

