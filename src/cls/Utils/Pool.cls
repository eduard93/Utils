/// Stores unique identifiers
Class Utils.Pool Extends %Persistent
{

Property Value As %String;

Index IDKEY On Value [ IdKey, PrimaryKey, Unique ];

Method %OnNew(Value As %String = "") As %Status [ Private, ServerOnly = 1 ]
{
	Set ..Value = Value
	Quit $$$OK
}

ClassMethod Add(Value As %String = "")
{
	Quit:..%ExistsId(Value)
	Set Obj = ..%New(Value)
	Do Obj.%Save()
}

/// Do ##class(Utils.Pool).Test()
ClassMethod Test()
{
	Do ..%KillExtent()
	Do ..Add(1)
	Write "Is 1 in pool: ", ..%ExistsId(1),!
	Write "Is 2 in pool: ", ..%ExistsId(2),!
	Do ..Add(2)
	Write "Is 2 in pool: ", ..%ExistsId(2),!
}

Storage Default
{
<Data name="PoolDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^||Utils.PoolD</DataLocation>
<DefaultData>PoolDefaultData</DefaultData>
<IdLocation>^||Utils.PoolD</IdLocation>
<IndexLocation>^||Utils.PoolI</IndexLocation>
<StreamLocation>^||Utils.PoolS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

