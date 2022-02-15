Class Utils.CompararatorItem Extends %RegisteredObject
{

Property path As %String(MAXLEN = "");

Property oldValue As %String(MAXLEN = "");

Property newValue As %String(MAXLEN = "");

Method asString() As %String [ CodeMode = expression ]
{
..path _ $c(9) _ ..oldValue _ $c(9) _ ..newValue
}

Method asList() As %List [ CodeMode = expression ]
{
$lb(..path, ..oldValue, ..newValue)
}

Method asDynObj() [ CodeMode = expression ]
{
{
	"path":(..path),
	"oldValue":(..oldValue),
	"newValue":(..newValue)
}
}

Method %OnNew(path As %String, oldValue As %String, newValue As %String) As %Status
{
	set ..path = path
	set ..oldValue = oldValue
	set ..newValue = newValue
	quit $$$OK
}

}

