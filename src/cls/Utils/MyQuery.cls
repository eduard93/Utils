Class Utils.MyQuery Extends %SQLQuery
{

/// This method would be ran before others and changes ROWSPEC to "Id123:%String"
ClassMethod %ChangeRowspec() [ CodeMode = objectgenerator, ServerOnly = 1 ]
{
	// quit if we're not compiling a query
	if %mode="method" quit $$$OK
	
	set class = %class.Name
	set query = %compiledmethod.parent.Name		
	set rowspec = "Id123:%String"
	
	// Modify query definition
	$$$defSubMemberSet(class,$$$cCLASSquery,query,$$$cQUERYparameter,"ROWSPEC",rowspec)
	
	// Modify query compiled definition
	$$$comSubMemberSet(class,$$$cCLASSquery,query,$$$cQUERYparameter,"ROWSPEC",rowspec)
	
	// Update compile-time parameter value 
	set %parameter("ROWSPEC") = rowspec
	
	// Update class definition
	do UpdClsDef^%occLibrary(class)
	
	quit $$$OK
}

/// GetText is a method that is used to get query text as a %String
ClassMethod GetText() As %String [ CodeMode = objectgenerator, ServerOnly = 1 ]
{
	if %mode="method" quit $$$OK
	//zw %parameter
	$$$comMemberKeyGetLvar(query,%classname,$$$cCLASSquery,%property,$$$cQUERYsqlquery)
	do %code.WriteLine("    quit " _ $$$quote(query))
	QUIT $$$OK
}

}

