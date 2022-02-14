Class Utils.StreamTrigger Extends %Persistent
{

Property Stream As %Stream.GlobalCharacter;

/// do ##class(Utils.StreamTrigger).Test()
ClassMethod Test()
{
	kill ^Utils.StreamTriggerDebug,^Utils.StreamTriggerS,^Utils.StreamTriggerI,^Utils.StreamTriggerD
	do ..%KillExtent()
	&sql(INSERT INTO Utils.StreamTrigger VALUES ('texttext'))
	&sql(UPDATE Utils.StreamTrigger SET Stream =('texttext2'))
	zw ^Utils.StreamTriggerDebug
}

Trigger TrigD [ Event = UPDATE, Foreach = row, Language = objectscript, Time = AFTER ]
{
	New SQLCODE,%ROWID,%ROWCOUNT
	
	Set key = $i(^Utils.StreamTriggerDebug)
	Set ^Utils.StreamTriggerDebug(key,"old") = {Stream*O}
	Set ^Utils.StreamTriggerDebug(key,"old","value") = ##class(%Stream.GlobalCharacter).%Open({Stream*O}).Read($$$MaxCacheInt)
	Set ^Utils.StreamTriggerDebug(key,"new") = {Stream*N}
}

Storage Default
{
<Data name="StreamTriggerDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Stream</Value>
</Value>
</Data>
<DataLocation>^Utils.StreamTriggerD</DataLocation>
<DefaultData>StreamTriggerDefaultData</DefaultData>
<IdLocation>^Utils.StreamTriggerD</IdLocation>
<IndexLocation>^Utils.StreamTriggerI</IndexLocation>
<StreamLocation>^Utils.StreamTriggerS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

