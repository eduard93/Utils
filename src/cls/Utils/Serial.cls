Class Utils.Serial Extends %SerialObject
{

Property Payload As %String;

/// zw ##class(Utils.Serial).Test()
ClassMethod Test(input As %String = {$lb(1,2,3,",",5)}) As %String
{
	
	set obj = ##class(Utils.Serial).%New()
	set obj.Payload = input
	do obj.%SerializeObject(.str)
	kill (str)
	
	set obj = ##class(Utils.Serial).%Open(str)
	return obj.Payload
}

Storage Default
{
<Data name="SerialState">
<Value name="1">
<Value>Payload</Value>
</Value>
</Data>
<State>SerialState</State>
<StreamLocation>^Utils.SerialS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}

