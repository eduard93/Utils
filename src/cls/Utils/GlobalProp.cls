Class Utils.GlobalProp Extends %Persistent
{

Parameter InvalidGLVN = "^Utils.GlobalPropP";

Property Invalid As %String [ SqlComputeCode = {set {*} = ##class(Utils.GlobalProp).InvalidStatic()}, SqlComputed, Transient ];

Method InvalidGet() As %String
{
	Return ..InvalidStatic()
}

ClassMethod InvalidStatic() As %String
{
	Return $Get(@..#InvalidGLVN)
}

Method InvalidSet(val As %String) As %Status
{
	Set @..#InvalidGLVN = val
	Return $$$OK
}

/// Do ##class(Utils.GlobalProp).Test()
ClassMethod Test()
{
	Do ..%KillExtent()
	Set obj = ..%New()
	Write "Invalid old: " _ obj.Invalid,!
	Set obj.Invalid = $Random(100)
	Write "Invalid new: " _ obj.Invalid,!
	Do obj.%Save()
	Kill obj
	&sql(SELECT Invalid INTO :invalid FROM Utils.GlobalProp WHERE Id = 1)
	Write "SQLCODE: " _ SQLCODE,!
	Write "Invalid sql: " _ invalid,!
}

Storage Default
{
<Data name="GlobalPropDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Invalid</Value>
</Value>
</Data>
<DataLocation>^Utils.GlobalPropD</DataLocation>
<DefaultData>GlobalPropDefaultData</DefaultData>
<IdLocation>^Utils.GlobalPropD</IdLocation>
<IndexLocation>^Utils.GlobalPropI</IndexLocation>
<StreamLocation>^Utils.GlobalPropS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

