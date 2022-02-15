Class Utils.NS
{

///  Creates namespace, database, default webapplication (csp and REST) with name, well <b>Name</b>.<br>
///  <b>Name</b> - you're strongly encouraged to use only combinations of
/// latin alphabet (a-z, A-Z) and number (0-9) characters here.
/// <b>WebApps</b> - create webapps. 0 - none, 1 - default csp, 2 - broker, -1 - all<br>
/// do ##class(Utils.NS).Create("")
ClassMethod Create(Name As %String, WebApps As %Integer = 0)
{
 zn "%SYS"
 Set LowName = $ZCVT(Name,"L")
 
 //Create directories
 Set Path = ##class(%File).ManagerDirectory() _ Name
 Set st = ##class(%File).CreateDirectory(Path)
 Return:$$$ISERR(st) st
 Set PathWEB = ##class(%File).NormalizeDirectory(##class(%File).ParentDirectoryName(##class(%File).ManagerDirectory()) _ "CSP") _ Name
 Set st = ##class(%File).CreateDirectory(PathWEB)
 Return:$$$ISERR(st) st
  
 // Create DataBase File
 Set st=##Class(SYS.Database).CreateDatabase(Path)
 Return:$$$ISERR(st) st
  
 // Mount database to Cache
 Set Properties("Directory")=Path
 Set Properties("MountRequired")=1
 Set st=##Class(Config.Databases).Create(Name,.Properties)
 Return:$$$ISERR(st) st
 Set Properties("MountRequired")=1
 Set st=##Class(Config.Databases).Modify(Name,.Properties)
  
 // Create NameSpace
 Set nsProperties("Globals") = Name
 Set nsProperties("Library") = "CACHELIB"
 Set nsProperties("Routines") = Name
 Set nsProperties("SysGlobals") = "CACHESYS"
 Set nsProperties("SysRoutines") = "CACHESYS"
 Set nsProperties("TempGlobals") = "CACHETEMP"
 Set st = ##Class(Config.Namespaces).Create(Name,.nsProperties)
 Return:$$$ISERR(st) st
  
 // Create web apps
 
 // default
 if ((WebApps = 1) || (WebApps = -1)) {
	 Set cspProperties("AutheEnabled") = 64
	 Set cspProperties("NameSpace") = Name
	 Set cspProperties("Path") = PathWEB
	 Set cspProperties("IsNameSpaceDefault") = 1
	 Set st = ##Class(Security.Applications).Create("/csp/"_LowName,.cspProperties)
	 Return:$$$ISERR(st) st
 }
 
 // broker
 if ((WebApps = 2) || (WebApps = -1)) {
	 Set cspProperties("AutheEnabled") = 64
	 Set cspProperties("NameSpace") = Name
	 Set cspProperties("DispatchClass") = "REST.Broker"
	 Set cspProperties("IsNameSpaceDefault") = 0
	 Set st = ##Class(Security.Applications).Create("/broker/"_LowName,.cspProperties)
	 Return:$$$ISERR(st) st
 }
  
 zn Name
 Return $$$OK
}

/// Do ##class(Utils.NS).GetOriginalNamespace()
ClassMethod GetOriginalNamespace(Package = "WebTerminal") As %String
{
	set a= ##class(Subpackage.Class).%New()
	Set ns=$Namespace
	Set databasepath = ##class(%SYS.Namespace).GetPackageDest($Namespace,Package)
	Set databasepath = $p(databasepath,"^",2)
	Zn "%SYS"
	Do ##Class(Config.Databases).DatabasesByDirectory("",databasepath,.databaselist)
	Set database = $lg(databaselist,1)
	Set statement = ##class(%SQL.Statement).%New()
	Set status = statement.%PrepareClassQuery("Config.Namespaces","List")
	If $$$ISERR(status) { Do $system.OBJ.DisplayError(status) }
	Set resultset = statement.%Execute()
	While resultset.%Next() {
		If resultset.%Get("Routines")=database {
			Kill resultset
			Zn ns
			Return resultset.%Get("Namespace")
		}
	}
	Zn ns
	Return ns
}

}

