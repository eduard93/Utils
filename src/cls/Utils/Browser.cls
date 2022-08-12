Class Utils.Browser [ Abstract ]
{

/// Do ##class(Utils.Browser).RunPage()
ClassMethod RunPage(Url As %String = "http://intersystems.com")
{
	#Include %occOptions
	Set Browser = $Select($$$isWINDOWS:"start", $$$isUNIX:"x-www-browser", 1:"x-www-browser")
	Set Command = Browser _ " " _ Url
	Do $ZF(-1, Command)
}

}

