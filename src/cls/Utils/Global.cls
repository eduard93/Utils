Class Utils.Global
{

/// Do ##class(Utils.Global).Generate()
ClassMethod Generate(NS = "SAMPLES", Count = 100000000)
{
	New $namespace
	Zn NS
	Kill ^LAB
	For i=1:1:Count {
		Set ^LAB(i) = i
	}
}

/// Do ##class(Utils.Global).Test()
ClassMethod Test(NS = "SAMPLES")
{
	Set time = $p($h,",",2)
	Do ..Ref1(NS)
	Set time1 = $p($h,",",2)
	Do ..Ref2(NS)
	Set time2 = $p($h,",",2)
	Write "Full ref time ",time1-time,!,"ZN time ",time2-time1
}

ClassMethod Ref1(NS)
{
	Set PIDX=""    
	For { 
		Set PIDX=$ORDER(^[NS]LAB(PIDX))
		Quit:PIDX=""  
	}
}

ClassMethod Ref2(NS)
{
	New $namespace
	Zn NS
	Set PIDX=""    
	For { 
		Set PIDX=$ORDER(^LAB(PIDX))
		Quit:PIDX=""  
	}
}

}

