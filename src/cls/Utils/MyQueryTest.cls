Class Utils.MyQueryTest
{

Query ABC() As Utils.MyQuery(ROWSPEC = "Id123:%String")
{
SELECT 1
}

/// do ##class(Utils.MyQueryTest).Test()
ClassMethod Test()
{
	$$$comMemberArrayGetLvar(rowspec,$classname(),$$$cCLASSquery,"ABC", $$$cQUERYparameter, "ROWSPEC")
	w "ROWSPEC: ", rowspec,!
	write "Query text: ", ..ABCGetText(),!
	do ..ABCFunc().%Display()
}

}

