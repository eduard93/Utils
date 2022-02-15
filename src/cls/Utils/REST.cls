Class Utils.REST Extends %CSP.REST
{

XData UrlMap
{
<Routes>
   <Route Url="/file" Method="GET" Call="GET"/>
 </Routes>
}

ClassMethod GET()
{
	set name = "Z:\iknowentitybrowsericons.woff"
	quit ..serve(name)
}

ClassMethod serve(name) As %Status
{
	#dim sc As %Status = $$$OK
    #dim %response As %CSP.Response
	kill %request.Data
	set %request.Data("STREAMOID",1)= ##class(%CSP.StreamServer).Encrypt(##class(%CSP.StreamServer).GetOidForFile(name))
	if ##class(%CSP.StreamServer).OnPreHTTP() {
		set %response.Headers("Content-Disposition")="attachment; filename*=UTF-8''" _ ##class(%CSP.Page).EscapeURL(name, "UTF8")
		set sc = ##class(%CSP.StreamServer).OnPage()
	}

	quit sc
}

}

