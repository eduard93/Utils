Class Utils.Length
{

/// w ##class(Utils.Length).CountClassLength("Utils.Projection")
ClassMethod CountClassLength(classname) As %Integer
{
	
	set length = 0
	set key = $o(^oddDEF(classname,""))
	while key '= ""
	{
		//w key
		set length = length + $l($g(^oddDEF(classname,key)),$c(10))
		w $g(^oddDEF(classname,key)),!
		set key = $o(^oddDEF(classname,key))
		
	}
	return length
}

ClassMethod %IsA(isclass As %String) As %Integer
{
	$$$SystemMethod(Is:1)
}

}

