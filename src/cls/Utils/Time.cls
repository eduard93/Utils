/// Execution time comparision utils
Class Utils.Time
{

/// do ##class(Utils.Time).Test()
ClassMethod Test()
{
	do ..Main(1)
	do ..Main(1)
	do ..Main(1)
	do ..Main(2)
	do ..Main(3)
	do ..Main(5)
	do ..Main(10)
	do ..Main(100)
	do ..Main(1000)
	do ..Main(10000)
}

/// do ##class(Utils.Time).Main(100)
ClassMethod Main(count = 100)
{
	set od=$io
	set nul="\\.\nul" // /dev/null/ - UNIX
	open nul
	use nul
	
	s startA = $NOW()
	do ..JobA(count)
	s endA = $NOW()
	s timeA = $p(endA,",",*) - $p(startA,",",*)
	
	s startB = $NOW()
	do ..JobB(count)
	s endB = $NOW()
	s timeB = $p(endB,",",*) - $p(startB,",",*)
	
	use od
	close nul
	
	w "Iterations: ",count,!
	w "Time JobA: ",timeA,!
	w "Time JobB: ",timeB,!
	w "JobA takes ",$FN(timeA/timeB*100,"",2) _ "% of JobB time",!,!
}

ClassMethod JobA(count = 100) As %Status
{
	set a = ##class(%ZEN.proxyObject).%New()
	for i=1:1:count {
		//s st = ..NoTry()
		/*set a = ##class(%ZEN.proxyObject).%New()
		set a.A = 1
		do a.%ToJSON()*/
		set $Property(a,"property") = "value"
	}
}

ClassMethod JobB(count = 100) As %Status
{
	set a = ##class(%ZEN.proxyObject).%New()
	for i=1:1:count {
		//s st = ..Try()
		/*set a = ##class(Utils.B).%New()
		set a.A = 1
		do ##class(%ZEN.Auxiliary.jsonProvider).%ObjectToJSON(a)*/
		do a.%DispatchSetProperty("property", "value")
	}
}

/*
ClassMethod NoTry() As %Status
{
	s a=1
	s b=$R(1000000)
	q 1
}

ClassMethod Try()
{
	try {
		s a=1
		s b=$R(1000000)
	} catch ex {
		return ex.AsStatus()
	}
	q 1
}*/
/// do ##class(Utils.Time).addClassesFromPackage("%SYSTEM.")
ClassMethod addClassesFromPackage(pkg As %String)
{
	#dim result as %SQL.StatementResult
	
	set sql = "SELECT id FROM %Dictionary.ClassDefinition WHERE id %STARTSWITH ?"	
	set result = ##class(%SQL.Statement).%ExecDirect(, sql,	pkg _ ".")
	
	if (result.%SQLCODE) {
		set msg = "failed to retrieve list of classes from package" _ pkg
		throw ##class(%Exception.SQL).CreateFromSQLCODE(result.%SQLCODE, msg)
	}
	
	while result.%Next() {
		set id = result.id
		write id,!
		//do ..classList.Insert(id)
	}
	
	/*
	
	#dim position as %Integer
	#dim value as %CacheString
	
	set position = ""
	
	while (1) {
		set value = result.%NextOutputValue(.position)
		if (position = "") {
			return
		}
		w value, !
		//do ..classList.Insert(value)
	}*/
}

ClassMethod uts(stamp As %TimeStamp) As %Integer [ SqlProc ]
{
	s startday=$zdh("1970-01-01 00:00:00",3)
	s endday=$zdh(stamp,3)
	s endtime=$p($zdth(stamp,3),",",2)
	s diffday=endday - startday
	s secs=((diffday * 60 * 60 * 24) + endtime)
	quit secs
}

/// Unix timestamp to ODBC
ClassMethod chr(unixstamp As %Integer) As %TimeStamp [ SqlProc ]
{
	s startday=$zdh("1970-01-01 00:00:00",3)
	s endday=(unixstamp \ (60 * 60 * 24))
	s endtime=(unixstamp # (60 * 60 * 24))
	s totalday=endday + startday
	quit $zdt(totalday_","_endtime, 3)
}

}

