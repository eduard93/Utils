/// do $system.OBJ.UnCompile("Utils.Generator")
/// do $system.OBJ.Compile("Utils.Generator")
Class Utils.Generator [ Abstract ]
{

ClassMethod A() [ CodeMode = objectgenerator ]
{
	Do %class.XDatas.Clear()
	Set xdata = ##class(%Dictionary.XDataDefinition).%New()
	Set xdata.Name = "xdataname"
	Do xdata.Data.Write("<time>"_$zdt($h)_"</time>")
	Do %class.XDatas.Insert(xdata)
	Do %class.%Save()
}

/// do ##class(Utils.Generator).ListDemo()
ClassMethod ListDemo(pIterations = 10000)
{
    #define START(%msg) Write %msg Set start = $zh
    #define END Write ($zh - start)," seconds",!
    
    Set list = $lb(1,2,3,4,5,6,7,8,9)
    $$$START("Getting first element in list "_pIterations_" times: ")
    For i=1:1:pIterations {
        Set a = $List(list,1)
    }
    $$$END
    
    $$$START("Getting third element in list "_pIterations_" times: ")
    For i=1:1:pIterations {
        Set a = $List(list)
    }
    $$$END
}

/// do ##class(Utils.Generator).StrToArr()
ClassMethod StrToArr(string, del = ",", Output arr)
{
	Set tString = "12,34,56"

	Set tPosition = 0
	do {
		Set tNewPosition = $Find(tString,",",tPosition)
		Set tValue = $Select(tNewPosition'=0:$Extract(tString,tPosition,tNewPosition-2),1:$Extract(tString,tPosition,*))
		//zw  w !,"________",!
		Set tPosition = tNewPosition
		w tValue,!
		
	}While tPosition '=0
}

XData xdataname
{
<time>02/14/2022 21:13:52</time>
}

}

