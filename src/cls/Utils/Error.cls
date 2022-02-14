Class Utils.Error
{

ClassMethod GetStatusAll()
{
	Set tInitNS = $namespace
	Set ns = ""
	For {
		Set ns = $order(^%SYS("Ensemble","InstalledNamespace",ns))
		Quit:(ns = "")
		Set tDestDir = ##class(%SYS.Namespace).GetGlobalDest(ns,"^Ens.Configuration","""csp"",""LastProduction""")
		If $piece(tDestDir,"^",1) '= "" { // Don't fetch data for remote databases
			Continue
		}
		try {
			Set tProd = $get(^|ns|Ens.Configuration("csp","LastProduction"))
			w "No errors on namespace ",ns,!
		} catch ex {
			w "Caught error on namespace ",ns,!
			w $System.Status.GetErrorText(ex.AsStatus())
		}
	}
}

}

