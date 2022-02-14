Class Utils.OID Extends %Persistent
{

Property A;

Property B;

/// do ##class(Utils.OID).%New()
Method OID()
{
	// I want casting
	#define idCurrent					$listget(i%"%%OID")
	w $$$idCurrent,!
	s $li(i%"%%OID",2)="Utils.B"
	//s a= i%"%%OID"
	//zw a
	//w i%"class name"
	//w $listget(%oid)
	w $$$MaxCacheInt
}

Storage Default
{
<Data name="OIDDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>A</Value>
</Value>
<Value name="3">
<Value>B</Value>
</Value>
</Data>
<DataLocation>^Utils.OIDD</DataLocation>
<DefaultData>OIDDefaultData</DefaultData>
<IdLocation>^Utils.OIDD</IdLocation>
<IndexLocation>^Utils.OIDI</IndexLocation>
<StreamLocation>^Utils.OIDS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

