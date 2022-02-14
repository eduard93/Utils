Class Utils.GetStored Extends (%Persistent, %Populate)
{

Parameter POPSIZE = 1000;

Property text As %String;

/// Do ##class(Utils.GetStored).Test()
ClassMethod Test()
{
	Do ..%KillExtent()
	Do ..Populate(..#POPSIZE, $$$NO, , , $$$NO)
	;Do ..Main(100)
	;Do ..Main(1000)
	;Do ..Main(10000)
}

/*
/// Do ##class(Utils.GetStored).Main(100)
ClassMethod Main(Count = 100)
{
	Set StartA = $Piece($Now(),",",2)
	Do ..Object(Count)
	Set EndA = $Piece($Now(),",",2)
	Set TimeA = EndA - StartA
	
	Set StartB = $Piece($Now(),",",2)
	Do ..GetStored(Count)
	Set EndB = $Piece($Now(),",",2)
	Set TimeB = EndB - StartB
	
	Set StartC = $Piece($Now(),",",2)
	Do ..SQL(Count)
	Set EndC = $Piece($Now(),",",2)
	Set TimeC = EndC - StartC
	
	Set StartD = $Piece($Now(),",",2)
	Do ..Global(Count)
	Set EndD = $Piece($Now(),",",2)
	Set TimeD = EndD - StartD
	
	Write "Iterations: ",Count,!
	Write "Object access: ",TimeA,!
	Write "GetStored access: ",TimeB,!
	Write "SQL access: ",TimeC,!
	Write "Global access: ",TimeD,!
	Write "Object access takes ",$FN(TimeA/TimeB*100,"",2) _ "% of GetStored time",!
	Write "Object access takes ",$FN(TimeA/TimeC*100,"",2) _ "% of SQL time",!
	Write "Object access takes ",$FN(TimeA/TimeD*100,"",2) _ "% of Global time",!
	Write "GetStored access takes ",$FN(TimeB/TimeC*100,"",2) _ "% of SQL time",!
	Write "GetStored access takes ",$FN(TimeB/TimeD*100,"",2) _ "% of Global time",!
	Write "SQL access takes ",$FN(TimeC/TimeD*100,"",2) _ "% of Global time",!,!
}

ClassMethod Object(Count = 100) As %Status
{
	For i=1:1:Count {
		Set Obj = ..%OpenId($Random(..#POPSIZE-1)+1)
		Set Val = Obj.text
	}
}

ClassMethod GetStored(Count = 100) As %Status
{
	For i=1:1:Count {
		Set Val = ..textGetStored($Random(..#POPSIZE-1)+1)
	}
}

ClassMethod SQL(Count = 100) As %Status
{
	For i=1:1:Count {
		Set Id = $Random(..#POPSIZE-1)+1 
		&sql(SELECT text INTO :Val FROM Utils.GetStored WHERE %ID = :Id) 
	}
}

ClassMethod Global(Count = 100) As %Status
{
	// This macro compiles into a direct global reference to property %prop of class %cls with id %idvar
	#Define GetStoredProp(%cls,%prop,%idvar) ##Expression(##class(Utils.GetStored).GetPropGLVN(%cls,%prop, $name(%idvar)))
	For i=1:1:Count {
		Set Id = $Random(..#POPSIZE-1)+1 
		Set Val = $$$GetStoredProp("Utils.GetStored","text", Id) 
	}
}

/// Write ##class(Utils.GetStored).GetPropGLVN("Utils.GetStored", "text")
ClassMethod GetPropGLVN(Class, Property, IdVar = "id") As %String
{
	Set StoredCode = $Get($$$EXTPROPondisk($$$pEXT,Class,Property))
	Set StoredCode = $Replace(StoredCode, "(id)", "(" _ IdVar _ ")") 
	Return StoredCode
}
 */
Storage Default
{
<Data name="GetStoredDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>text</Value>
</Value>
</Data>
<DataLocation>^Utils.GetStoredD</DataLocation>
<DefaultData>GetStoredDefaultData</DefaultData>
<IdLocation>^Utils.GetStoredD</IdLocation>
<IndexLocation>^Utils.GetStoredI</IndexLocation>
<StreamLocation>^Utils.GetStoredS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

