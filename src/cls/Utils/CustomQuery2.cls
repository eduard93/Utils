Class Utils.CustomQuery2
{

/// Return ids from a table or a class
Query GetTable(Table) As %Query(CONTAINID = 1, ROWSPEC = "Id:%String") [ SqlProc ]
{
}

ClassMethod GetTableExecute(ByRef qHandle As %Binary, Table) As %Status
{
	#Dim Status As %Status = $$$OK

	If ##class(%Dictionary.ClassDefinition).%ExistsId(Table) {
		// Got a class, we need to calculate a table name and quote it
		#define ClassSQLTable(%c)    ($$$comClassKeyGet(%c,$$$cCLASSsqlschemaname)_"."_$$$comClassKeyGet(%c,$$$cCLASSsqltablename))
		Set Table = ##class(%CSP.UI.Portal.SQL.Home).Quoter2($$$ClassSQLTable(Table))
	}
	

	Set qHandle = ##class(%SQL.Statement).%ExecDirect(,"SELECT ID FROM " _ Table)
	If qHandle.%SQLCODE'=0 {
		Set Status = $$$ERROR($$$SQLError, qHandle.%SQLCODE, qHandle.%Message)
	}
	Quit Status
}

ClassMethod GetTableFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status
{
	If qHandle.%Next() {
		// Same as in ROWSPEC
		Set Row = $Lb(qHandle.ID)
	} Else {
		/// No more data
		Set AtEnd = 1
		Set Row = ""
	}
	Quit $$$OK
}

ClassMethod GetTableClose(ByRef qHandle As %Binary) As %Status
{
	Kill qHandle
	Quit $$$OK
}

}

