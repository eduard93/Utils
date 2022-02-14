Class Utils.FuncIndex Extends %Persistent
{

Property Once As %Boolean;

Property Value As %String;

Index NewIndex1 On Value [ Condition = {..Once = 1}, Unique ];

/// do ##class(Utils.FuncIndex).Test()
ClassMethod Test()
{
	Do ..%KillExtent()
	
	Set a = ..%New()
	Set a.Once = 0
	Set a.Value = 1
	w $System.Status.GetErrorText(a.%Save())
	
	Set a = ..%New()
	Set a.Once = 1
	Set a.Value = 1
	w $System.Status.GetErrorText(a.%Save())
	
	Set a = ..%New()
	Set a.Once = 1
	Set a.Value = 2
	w $System.Status.GetErrorText(a.%Save())
}

Storage Default
{
<Data name="FuncIndexDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Once</Value>
</Value>
<Value name="3">
<Value>Value</Value>
</Value>
</Data>
<DataLocation>^Utils.FuncIndexD</DataLocation>
<DefaultData>FuncIndexDefaultData</DefaultData>
<IdLocation>^Utils.FuncIndexD</IdLocation>
<IndexLocation>^Utils.FuncIndexI</IndexLocation>
<StreamLocation>^Utils.FuncIndexS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

