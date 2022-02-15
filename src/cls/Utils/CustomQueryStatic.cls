Class Utils.CustomQueryStatic Extends (%Persistent, %Populate)
{

Property Prop1 As %String;

Property Prop2 As %Integer;

/// Do ##class(Utils.CustomQueryStatic).Test()
ClassMethod Test()
{
	If $O(^Utils.CustomQueryStaticD(""),-1)'=10 {
		Do ..%KillExtent()
		Do ..Populate(10)
	}
	Do ..ExecuteQuery()
}

ClassMethod ExecuteQuery()
{
	Set statement=##class(%SQL.Statement).%New()
	Set status=statement.%PrepareClassQuery("Utils.CustomQueryStatic","INTOWithFETCH")
	If $$$ISERR(status) { Do $system.OBJ.DisplayError(status) }
	Set resultset=statement.%Execute()
	Do resultset.%Display()
	
	Set status=statement.%PrepareClassQuery("Utils.CustomQueryStatic","INTOWithDECLARE")
	If $$$ISERR(status) { Do $system.OBJ.DisplayError(status) }
	Set resultset=statement.%Execute()
	Do resultset.%Display() // Same thing
}

/// Do ##class(Utils.CustomQueryStatic).ExecuteQueryOld()
ClassMethod ExecuteQueryOld()
{
	Set rset = ##class(%ResultSet).%New("Utils.CustomQueryStatic:AllStatic")
	Do rset.Execute()

	While (rset.Next()) {
		Write rset.Data("Id"),!
	}
}

Query INTOWithFETCH() As %Query(CONTAINID = 1, ROWSPEC = "Id:%String,Prop1:%String,Prop2:%Integer") [ SqlProc ]
{
}

ClassMethod INTOWithFETCHExecute(ByRef qHandle As %Binary) As %Status
{
	&sql(	DECLARE C CURSOR FOR
		    SELECT Id, Prop1, Prop2
		    FROM Utils.CustomQueryStatic
 	)

 	&sql(OPEN C)
	Quit $$$OK
}

ClassMethod INTOWithFETCHFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = INTOWithFETCHExecute ]
{
	&sql(FETCH C INTO :Id, :Prop1, :Prop2)
	#; Проверяем дошли ли до конца данных 
	s ^t = ^t _ " " _ SQLCODE
	If (SQLCODE=-400) {w $g(%msg,"nono")}
	If (SQLCODE'=0) {
		Set AtEnd = 1
		Set Row = ""
		Quit $$$OK
	}
	Set Row = $Lb(Id, Prop1, Prop2)
	Quit $$$OK
}

ClassMethod INTOWithFETCHClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = INTOWithFETCHFetch ]
{
	&sql(CLOSE C)
	Quit $$$OK
}

Query INTOWithDECLARE() As %Query(CONTAINID = 1, ROWSPEC = "Id:%String,Prop1:%String,Prop2:%Integer") [ SqlProc ]
{
}

ClassMethod INTOWithDECLAREExecute(ByRef qHandle As %Binary) As %Status
{
	&sql(	DECLARE C1 CURSOR FOR
		    SELECT Id, Prop1, Prop2
		    INTO :Id, :Prop1, :Prop2
		    FROM Utils.CustomQueryStatic
 	)
 	&sql(OPEN C1)
	Quit $$$OK
}

ClassMethod INTOWithDECLAREFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = INTOWithDECLAREExecute ]
{
	&sql(FETCH C1 )
	If (SQLCODE=-400) {w $g(%msg,"nono")}
	If (SQLCODE'=0) {
		Set AtEnd = 1
		Set Row = ""
		Quit $$$OK
	}
	Set Row = $Lb(Id, Prop1, Prop2)
	Quit $$$OK
}

ClassMethod INTOWithDECLAREClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = INTOWithDECLAREFetch ]
{
	&sql(CLOSE C1)
	Quit $$$OK
}

Storage Default
{
<Data name="CustomQueryStaticDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Prop1</Value>
</Value>
<Value name="3">
<Value>Prop2</Value>
</Value>
</Data>
<DataLocation>^Utils.CustomQueryStaticD</DataLocation>
<DefaultData>CustomQueryStaticDefaultData</DefaultData>
<ExtentSize>10</ExtentSize>
<IdLocation>^Utils.CustomQueryStaticD</IdLocation>
<IndexLocation>^Utils.CustomQueryStaticI</IndexLocation>
<Property name="%%CLASSNAME">
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Prop1">
<Selectivity>10.0000%</Selectivity>
</Property>
<Property name="Prop2">
<Selectivity>10.0000%</Selectivity>
</Property>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^Utils.CustomQueryStaticS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

