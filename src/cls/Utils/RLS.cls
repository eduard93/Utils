Class Utils.RLS Extends %Persistent
{

Parameter ROWLEVELSECURITY = 1;

Property %READERLIST As %String [ Calculated, Private, SqlComputeCode = {s {*} = ##class(Utils.RLS).GetAccess({ID})}, SqlComputed ];

Property data As %String;

ClassMethod GetAccess(Id) As %String
{
	return:Id>3 "_SYSTEM"
	return "%All"
}

/// do ##class(Utils.RLS).Fill()
ClassMethod Fill(N = 5)
{
	do ..%KillExtent()
	for i=1:1:N {
		&sql(insert into Utils.RLS(data) values(:i))
	}
	do $SYSTEM.SQL.SetMapSelectability($classname(),"%RLI",$$$NO)
	do $system.SQL.PurgeForTable($classname())

	zw ^demo.testD,^demo.testI

	do ##class(%SQL.Statement).%ExecDirect(,"select * from "_$classname()).%Display()
}

/// do ##class(Utils.RLS).Test()
ClassMethod Test()
{
	do $SYSTEM.SQL.SetMapSelectability($classname(),"%RLI",$$$YES)
	do $system.SQL.PurgeForTable($classname())

	write "yes 1) -----",!!
	do ##class(%SQL.Statement).%ExecDirect(,"select * from %IGNOREINDEX %RLI "_$classname()).%Display() w !!
	write "yes 2) -----",!!
	do ##class(%SQL.Statement).%ExecDirect(,"select * from "_$classname()).%Display() w !!

	do $SYSTEM.SQL.SetMapSelectability($classname(),"%RLI",$$$NO)
	do $system.SQL.PurgeForTable($classname())

	write "no 1) -----",!!
	do ##class(%SQL.Statement).%ExecDirect(,"select * from %IGNOREINDEX %RLI "_$classname()).%Display() w !!
	write "no 2) -----",!!
	do ##class(%SQL.Statement).%ExecDirect(,"select * from "_$classname()).%Display() w !!
}

Storage Default
{
<Data name="RLSDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>data</Value>
</Value>
</Data>
<DataLocation>^Utils.RLSD</DataLocation>
<DefaultData>RLSDefaultData</DefaultData>
<IdLocation>^Utils.RLSD</IdLocation>
<IndexLocation>^Utils.RLSI</IndexLocation>
<StreamLocation>^Utils.RLSS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

