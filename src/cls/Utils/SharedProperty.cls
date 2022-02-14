/// do ##class(Utils.SharedProperty).Populate(10)
Class Utils.SharedProperty Extends (%Persistent, %Populate)
{

Property LastSavedId As %Integer [ Calculated, Transient ];

Method LastSavedIdGet() As %Integer
{
	q ..LastSavedIdGetStatic()
}

ClassMethod LastSavedIdGetStatic() As %Integer
{
	/// Can be better. Dunno how.
	/// $$$defMemberKeyGet("%Dictionary.PropertyDefinition", $$$cCLASSproperty, pParamName, $$$cPROPinitialexpression)
	//w $$$comClassArrayNext(##Expression($$$quote(%classname)), $$$cCLASSextents,"") 
	//#define ClassStorageStrategy ##Expression($$$quote($$$comClassKeyGet(%classname,$$$cCLASSstoragestrategy)))
	#Define storageName $$$comClassKeyGet(%classname,$$$cCLASSstoragestrategy)
	#Define idLocation ##Expression($$$comMemberKeyGet(%classname,$$$cCLASSstorage,$$$storageName,$$$cSDEFidlocation))
	w $o($$$idLocation(""),-1)
}

Storage Default
{
<Data name="SharedPropertyDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^Utils.SharedPropertyD</DataLocation>
<DefaultData>SharedPropertyDefaultData</DefaultData>
<ExtentSize>10</ExtentSize>
<IdLocation>^Utils.SharedPropertyD</IdLocation>
<IndexLocation>^Utils.SharedPropertyI</IndexLocation>
<Property name="%%CLASSNAME">
<Selectivity>100.0000%</Selectivity>
</Property>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^Utils.SharedPropertyS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

