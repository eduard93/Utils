Class Utils.CallArgs Extends %RegisteredObject
{

/// do ##class(Utils.CallArgs).Main()
ClassMethod Main()
{
	set (arg(1),arg(2),arg(3)) = 1
	set arg=3
	set StandartCallCount = ..GetCount(arg(1),arg(2),arg(3))
	w "StandartCallCount: ",StandartCallCount,!
	
	set NewCallCount = ..GetCount(arg...)
	w "NewCallCount: ",NewCallCount,!
	
	set RefCallCount = ..GetCount(.arg)
	w "RefCallCount: ",NewCallCount
}

/// Get the number of pNode args
ClassMethod GetCount(pNode...) As %String
{
	zw pNode
	// count nodes
	Set tCount = 0
	Set n = $O(pNode(""))
	While (n'="") {
		Set tCount = tCount + 1
		Set n = $O(pNode(n))
	}
	Quit tCount
}

/// do ##class(Utils.CallArgs).TestIn()
ClassMethod TestIn() As %String
{
	
	s a = ##class(%ZEN.proxyObject).%New()
	s a.Test=1
	do a.%ToJSON()
	do ..TestRef(a)
	do a.%ToJSON()
}

ClassMethod TestRef(a) As %String
{
	s a.Test=2
}

}

