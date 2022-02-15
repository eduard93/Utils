Class Utils.Pattern Extends %Persistent
{

/// Property Name As %String [ PopulationPct= {1}];
Property Name As %String;

Property isDeleted As %Boolean;

Index NewIndex1 On Name;

Method %OnAddToSaveSet(depth As %Integer = 3, insert As %Integer = 0, callcount As %Integer = 0) As %Status [ Private, ServerOnly = 1 ]
{
	Quit:i%isDeleted=1 $$$OK
	Quit:$d(^Utils.PatternI("NewIndex1"," "_$ZCVT(..Name,"U")))=0 $$$OK
	if $d(^Utils.PatternI("NewIndex1"," "_$ZCVT(..Name,"U")))=10 {
		//check that's it is not deleted
		Quit $$$ERROR(5001,"Not Unique " _..Name)
	}
	Quit $$$OK
}

/// do ##class(Utils.Pattern).Test()
ClassMethod Test() [ ProcedureBlock = 0 ]
{
	do ..%DeleteExtent()
	
	set a = ..%New()
	set a.isDeleted = 0
	set a.Name = "Ivan"
	set st = a.%Save()
	w:$$$ISERR(st) "a",!,$System.Status.GetErrorText(st),!
	
	set b = ..%New()
	set b.isDeleted = 1
	set b.Name = "Ivan"
	set st = b.%Save()
	w:$$$ISERR(st) "b",!,$System.Status.GetErrorText(st),!
	
	set c = ..%New()
	set c.isDeleted = 0
	set c.Name = "Ivan"
	set st = c.%Save()
	// throws error
	w:$$$ISERR(st) "c",!,$System.Status.GetErrorText(st),!
}

Storage Default
{
<Data name="PatternDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>NameComputed</Value>
</Value>
<Value name="4">
<Value>isDeleted</Value>
</Value>
<Value name="5">
<Value>NameWithDelete</Value>
</Value>
</Data>
<DataLocation>^Utils.PatternD</DataLocation>
<DefaultData>PatternDefaultData</DefaultData>
<ExtentSize>40</ExtentSize>
<IdLocation>^Utils.PatternD</IdLocation>
<IndexLocation>^Utils.PatternI</IndexLocation>
<Property name="%%CLASSNAME">
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Name">
<Selectivity>3.2258%</Selectivity>
</Property>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="idxString">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^Utils.PatternS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

