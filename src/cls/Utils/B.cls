Class Utils.B Extends %RegisteredObject
{

Property ListProp As list Of %String;

Method ListPropSet(newvalue) As %Status
{
	If '$isobject(newvalue),newvalue'="" Quit $$Error^%apiOBJ(5807,newvalue)
	zw newvalue
	If r%ListProp=newvalue Quit 1
	If newvalue="" Kill i%ListProp,r%ListProp Set i%ListProp="",r%ListProp="" Quit 1
	Set oref=r%ListProp Kill i%ListProp,r%ListProp Set i%ListProp="",r%ListProp=oref
	Set key="" For i=1:1 Set value=newvalue.GetNext(.key) Quit:key=""  Set i%ListProp(i)=value
	Quit 1
}

/*
Method ListPropGet(val)
{
	q 1
	zw val
	set a= i%ListProp
	set b= r%ListProp
	zw a,b
	q 1
}*/
Storage Default
{
<Data name="BDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>A</Value>
</Value>
<Value name="3">
<Value>B</Value>
</Value>
<Value name="4">
<Value>Свойство</Value>
</Value>
<Value name="5">
<Value>ListProp</Value>
</Value>
</Data>
<DataLocation>^Utils.BD</DataLocation>
<DefaultData>BDefaultData</DefaultData>
<IdLocation>^Utils.BD</IdLocation>
<IndexLocation>^Utils.BI</IndexLocation>
<StreamLocation>^Utils.BS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

