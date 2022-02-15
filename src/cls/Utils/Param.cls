Class Utils.Param Extends (%Persistent, %Populate)
{

/// Parameter abc = "def";
Parameter abc = {$zdt($Now())};

Property str As %String;

ClassMethod ghi()
{
	w 1
}

Index strIndex On str;

Storage Default
{
<Data name="ParamDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>veshhestvennoe</Value>
</Value>
<Value name="3">
<Value>str</Value>
</Value>
</Data>
<DataLocation>^Utils.ParamD</DataLocation>
<DefaultData>ParamDefaultData</DefaultData>
<ExtentSize>1000000</ExtentSize>
<IdLocation>^Utils.ParamD</IdLocation>
<IndexLocation>^Utils.ParamI</IndexLocation>
<Property name="%%CLASSNAME">
<OutlierSelectivity>.999767:</OutlierSelectivity>
<Selectivity>0.0023%</Selectivity>
</Property>
<Property name="veshhestvennoe">
<Selectivity>0.0097%</Selectivity>
</Property>
<SQLMap name="IDKEY">
<BlockCount>-6560</BlockCount>
</SQLMap>
<StreamLocation>^Utils.ParamS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

