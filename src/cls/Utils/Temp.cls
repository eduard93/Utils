Class Utils.Temp Extends %Persistent
{

Property data As %String [ SqlComputeCode = {set {*} = ##class(Utils.Temp).dataGetStatic({ID})}, SqlComputed, Transient ];

Method dataGet() As %String
{
	return ..dataGetStatic(..%Id())
}

Method dataSet(val) As %Status
{
	set i%data = val
	return $$$OK
}

ClassMethod dataGetStatic(id) As %String
{
	set:'id id = 0
	return:$d(%ts)=0 $g(^prop(id),"")
	return:$d(^prop(id,%ts),val)=1 val
	return:$o(^prop(id,%ts),%state,val) val
	if %state=1 {
		set temp = $o(^prop(id,%ts),-1,val)
		return val
	}
	return ""
}

/// This callback method is invoked by the <METHOD>%Save</METHOD> method to 
/// provide notification that the object is being saved. It is called before 
/// any data is written to disk.
/// 
/// <P><VAR>insert</VAR> will be set to 1 if this object is being saved for the first time.
/// 
/// <P>If this method returns an error then the call to <METHOD>%Save</METHOD> will fail.
Method %OnBeforeSave(insert As %Boolean) As %Status [ Private, ServerOnly = 1 ]
{
	if insert = $$$NO {
		
	}
	q $$$OK
}

/// This callback method is invoked by the <METHOD>%Save</METHOD> method to 
/// provide notification that the object is being saved. It is called after 
/// the object's data has been successfully written to disk.
/// 
/// <P><VAR>insert</VAR> will be set to 1 if this object is being saved for the first time.
/// 
/// <P>If this method returns an error then the call to <METHOD>%Save</METHOD> will fail.
Method %OnAfterSave(insert As %Boolean) As %Status [ Private, ServerOnly = 1 ]
{
	set ts = $ztimestamp
	set ep = $zdt(ts,-2) _ $p(ts,".",2) //  unixtime - ms. 
	if ((insert = $$$YES) ||  (^prop(..%Id()) '=i%data)) {
		set ^prop(..%Id()) = i%data
		set ^prop(..%Id(), ep) = i%data
	}
	Quit $$$OK
}

/// do ##class(Utils.Temp).populate()
ClassMethod populate()
{
	kill ^dbg,^prop,%ts,%state
	do ..%KillExtent()
	w $System.Status.GetErrorText(..add(1))
	w $System.Status.GetErrorText(..add(2))
	
	hang 1
	
	do ..upd(1,2)
	hang 1
	do ..upd(1,3)
	do ##class(%SQL.Statement).%ExecDirect(,"select * from "_$classname()).%Display()
}

ClassMethod add(data) As %Status
{
	set obj = ..%New(data)
	quit obj.%Save()
}

ClassMethod upd(id, data) As %Status
{
	set obj = ..%OpenId(id)
	set obj.data = data
	quit obj.%Save()
}

Method %OnNew(data) As %Status
{
	set ..data = data
	quit $$$OK
}

/// w ##class(Utils.Temp).get()
ClassMethod get()
{
	quit:$d(^a(5),val)=1 val
	quit ""
}

/// Expect 2017-01-19 00:18:14.000
/// w ##class(Utils.Temp).AtTime("2017-01-19 00:18:14.000"),!,%ts
ClassMethod AtTime(type As %String(VALUELIST=",-1,1",DISPLAYLIST=",before,after") = -1, timestamp As %TimeStamp = {$zdt($ztimestamp,3,1,3)}) As %Boolean [ SqlProc ]
{
	q:$d(%ts) $$$YES
	set %state = type
	set %ts=$zdt($zdth(timestamp,3),-2) _ $p(timestamp,".",2)
	q $$$YES
}

Storage Default
{
<Data name="TempDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>data</Value>
</Value>
</Data>
<DataLocation>^Utils.TempD</DataLocation>
<DefaultData>TempDefaultData</DefaultData>
<IdLocation>^Utils.TempD</IdLocation>
<IndexLocation>^Utils.TempI</IndexLocation>
<StreamLocation>^Utils.TempS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

