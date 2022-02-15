Class Utils.CustomQuery Extends (%Persistent, %Populate)
{

Property Prop1 As %String;

Property Prop2 As %Integer;

Query AllRecords() As %Query(CONTAINID = 1, ROWSPEC = "Id:%String,Prop1:%String,Prop2:%Integer") [ SqlName = AllRecords, SqlProc ]
{
}

ClassMethod AllRecordsExecute(ByRef qHandle As %Binary) As %Status
{
	Set qHandle = ""
	Quit $$$OK
}

ClassMethod AllRecordsFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status
{
	#; Обходим глобал ^Utils.CustomQueryD
	#; Записываем следующий id в qHandle, а значение глобала с новым id в val
	Set qHandle = $Order(^Utils.CustomQueryD(qHandle),1,val)
	#; Проверяем дошли ли до конца данных   
	If qHandle = "" {
		Set AtEnd = 1
		Set Row = ""
		Quit $$$OK
	}
	#; Если нет, формируем %List
	#; val = $Lb("", Prop1, Prop2) - см. Storage Definition
	#; Row = $Lb(Id, Prop1, Prop2) - см. ROWSPEC запроса All
	Set Row = $Lb(qHandle, $Lg(val,2), $Lg(val,3))
	Quit $$$OK
}

ClassMethod AllRecordsClose(ByRef qHandle As %Binary) As %Status
{
	Kill qHandle
	Quit $$$OK
}

Query AllStatic() As %Query(CONTAINID = 1, ROWSPEC = "Id:%String,Prop1:%String,Prop2:%Integer") [ SqlName = AllStatic, SqlProc ]
{
}

ClassMethod AllStaticExecute(ByRef qHandle As %Binary) As %Status
{
	&sql(	DECLARE C CURSOR FOR
		    SELECT Id, Prop1, Prop2
		    FROM Utils.CustomQuery)

 	&sql(OPEN C)
	Quit $$$OK
}

ClassMethod AllStaticFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = AllStaticExecute ]
{
	&sql(FETCH C INTO :Id, :Prop1, :Prop2)
	#; Проверяем дошли ли до конца данных   
	If (SQLCODE'=0) {
		Set AtEnd = 1
		Set Row = ""
		Quit $$$OK
	}
	Set Row = $Lb(Id, Prop1, Prop2)
	Quit $$$OK
}

ClassMethod AllStaticClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = AllStaticFetch ]
{
	&sql(CLOSE C)
	Quit $$$OK
}

Query AllDynamic() As %Query(CONTAINID = 1, ROWSPEC = "Id:%String,Prop1:%String,Prop2:%Integer") [ SqlName = AllDynamic, SqlProc ]
{
}

ClassMethod AllDynamicExecute(ByRef qHandle As %Binary) As %Status
{
	Set qHandle = ##class(%SQL.Statement).%ExecDirect(,"SELECT * FROM Utils.CustomQuery")
	Quit $$$OK
}

ClassMethod AllDynamicFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status
{
	If qHandle.%Next()=0 {
		Set AtEnd = 1
		Set Row = ""
		Quit $$$OK
	} 

	Set Row = $Lb(qHandle.%Get("Id"), qHandle.%Get("Prop1"), qHandle.%Get("Prop2"))
	Quit $$$OK
}

ClassMethod AllDynamicClose(ByRef qHandle As %Binary) As %Status
{
	Kill qHandle
	Quit $$$OK
}

Storage Default
{
<Data name="CustomQueryDefaultData">
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
<DataLocation>^Utils.CustomQueryD</DataLocation>
<DefaultData>CustomQueryDefaultData</DefaultData>
<ExtentSize>1000000</ExtentSize>
<IdLocation>^Utils.CustomQueryD</IdLocation>
<IndexLocation>^Utils.CustomQueryI</IndexLocation>
<Property name="%%CLASSNAME">
<OutlierSelectivity>.999767:</OutlierSelectivity>
<Selectivity>0.0023%</Selectivity>
</Property>
<Property name="Prop1">
<Selectivity>0.0004%</Selectivity>
</Property>
<Property name="Prop2">
<Selectivity>0.0001%</Selectivity>
</Property>
<SQLMap name="IDKEY">
<BlockCount>-10932</BlockCount>
</SQLMap>
<StreamLocation>^Utils.CustomQueryS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

