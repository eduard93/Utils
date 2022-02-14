/// Run Business Service on schedule
Class Utils.ServiceTask Extends %SYS.Task.Definition
{

Parameter TaskName = "Run Service";

Property BusinessService As %String(MAXLEN = 128) [ Required ];

/// Check that Production has this Business Host
Method %OnValidateObject() As %Status
{
	#dim sc As %Status = $$$OK
	do ##class(Ens.Director).IsItemEnabled(..BusinessService, .sc)
	quit sc
}

/// What's going on
/// 1. Check that Service is OFF
/// 2. Check that Service's PoolSize is 0 is that Interoperability won't start the job
/// 3. Enable Service
/// 4. Create Service object
/// 5. Run Service once
/// 6. Disable Service
Method OnTask() As %Status
{
	#dim sc As %Status = $$$OK
	try {
		#dim enabled As %Boolean = ##class(Ens.Director).IsItemEnabled(..BusinessService, .sc)
		quit:$$$ISERR(sc)
		if enabled {
			set sc = $$$ERROR($$$FormatText("Service %1 is enabled externally", ..BusinessService))
			quit
		}

		set poolSize = ..getPoolSize(..BusinessService)
		if (poolSize'=0) {
			set sc = $$$ERROR($$$FormatText("Service %1 has PoolSize: '%2', to start set PoolSize equal to 0", ..BusinessService, poolSize))
			quit
		}

		set sc = ##class(Ens.Director).EnableConfigItem(..BusinessService)
		quit:$$$ISERR(sc)

		set sc = ##class(Ens.Director).CreateBusinessService(..BusinessService, .service)
	 	quit:$$$ISERR(sc)
	 	
	 	// TODO for Services without poll adaptor it is enough to call 
	 	// set sc = service.ProcessInput() 
	 	
	 	/*
	 	 If a polling service need to set callinterval to 1 (minimum allowed)
	     since it always waits call interval at the end of the poll
	     This means it will always wait 1 second at the end before exiting
	    */
	    set service.Adapter.CallInterval = 1
	 	set sc = service.OnTask() ; this will process first row it finds.
	 	quit:$$$ISERR(sc)
	 	/*
	     If more rows to process and the production is not stopping then the following
	     will cause it to loop over the other rows.
	     If want to be able to throttle create a property for maximum number of 
	     iterations.
	 	*/       
		while (('service.%WaitForNextCallInterval) && ('service.%QuitTask)) {
		 	set sc = service.OnTask()
		 	return:$$$ISERR(sc) sc
		}
		set service="" ;This is so that adapter disconnects if it connects.

		set sc = ##class(Ens.Director).EnableConfigItem(..BusinessService, $$$NO)
	} catch ex {
		set sc = ex.AsStatus()
		
		#dim sc1 As %Status = $$$OK
		// Disable service in any case
		try {
			kill enabled
			set enabled = ##class(Ens.Director).IsItemEnabled(..BusinessService, .sc1)
			set:enabled sc1 = ##class(Ens.Director).EnableConfigItem(..BusinessService, $$$NO)
		} catch {
			set sc1 = ex.AsStatus()
		}
		
		set sc = $$$ADDSC(sc, sc1)
	}
	
	quit sc
}

Query poolSize(production As %String = {##class(Ens.Director).GetActiveProductionName()}, host As %String) As %SQLQuery
{
SELECT PoolSize
FROM Ens_Config.Item 
WHERE Production=:production AND Name=:host
}

/// Get Business Host PoolSize
/// w ##class(Utils.ServiceTask).getPoolSize()
ClassMethod getPoolSize(host As %String) As %Integer
{
	#dim rs As %SQL.ISelectResult
	set rs = ..poolSizeFunc(,host)
	do rs.%Next() 
	set poolSize = rs.PoolSize
	
	quit poolSize
}

}

