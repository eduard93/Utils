Class Utils.Stack Extends %RegisteredObject
{

/// do ##class(Utils.Stack).Test()
ClassMethod Test() [ ProcedureBlock = 0 ]
{
	
	s a=1
	s b=2
	FOR loop=0:1:$STACK(-1) { 
		WRITE !,"Context level:",loop,?25,"Context type: ",$STACK(loop)
		WRITE !,?5,"Current place: ",$STACK(loop,"PLACE")
		WRITE !,?5,"Current source: ",$STACK(loop,"MCODE")
		WRITE ! 
    }
}

/// do ##class(Utils.Stack).ParentMethod()
ClassMethod ParentMethod()
{
 //new a,b,c
 set a="is public var"
 do ..ChildMethod()
}

ClassMethod ChildMethod() [ PublicList = (a, b, c) ]
{
 w
 w !,a
}

/// Do ##class(Utils.Stack).GetStackAsArray()
ClassMethod GetStackAsArray()
{
	//Do ..StackAsArray()
	w !
	//Do ##class(Src.Utils.Test).Test2()
	FOR level=1:1:$STACK(-1) { 
	WRITE !,"Context level:",level,?25,"Context type: ",$STACK(level)
	WRITE !,?5,"Current place: ",$STACK(level,"PLACE")
	WRITE !,?5,"Current source: ",$STACK(level,"MCODE")
	set key = $zu(42,level,"")
	while (key'=""){
		if ($zu(41,level,key)=level){
			w key_"="_$zu(43,level,key),!
		}
		set key = $zu(42,level,key)
	}
		WRITE ! 
	}
}

ClassMethod StackAsArray()
{
	Set ex = ##class(%Exception.SystemException).%New()
	Do ex.StackAsArray(.arr)
	zw arr
}

}

