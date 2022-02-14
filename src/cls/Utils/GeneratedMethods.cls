Class Utils.GeneratedMethods Extends (%Persistent, %Populate)
{

Parameter POPSIZE = 10;

Property Text As %String;

Property Date As %Date;

Property Relative As GeneratedMethods;

Index TextIndex On Text [ Unique ];

/// Do ##class(Utils.GeneratedMethods).Test()
ClassMethod Test()
{
	Do ..%KillExtent()
	Do ..Populate(..#POPSIZE, $$$NO, , , $$$NO)
	
	Set ResultSet = ..TextQueryFunc(3)
	While ResultSet.%Next() { 
		Write ResultSet.Text,! 
	}
	
	Write "___________",!
	
	For i = 1:1:..#POPSIZE {
		Write ..TextGetStored(i),!
	}
	
	Write "___________",!
	
	Set Id = 5
	Set Text = ..TextGetStored(Id)
	Set ObjExists = ..TextIndexExists(Text, .ObjId)
	Set Obj = ..TextIndexOpen(Text)
	Set ObjById = ..%OpenId(ObjId)
	Zw ObjExists,ObjId,Id,Obj,ObjById
	
	Write "___________",!
	
	Do ..TextIndexDelete(Text)
	Set ObjExists = ..TextIndexExists(Text)
	Zw ObjExists
	Kill
	
	Write "___________",!
	
	Set Id = 1
	Set Obj = ..%OpenId(Id)
	
	Write "Text: ",Obj.Text, !
	Write "Text: ",Obj.TextGet(), !
	
	Write "Date: ",Obj.Date, !
	Write "Date: ",Obj.DateLogicalToDisplay(Obj.Date), !
	Write "Date: ",Obj.DateLogicalToOdbc(Obj.Date), !
	Write "Date: ",Obj.DateOdbcToLogical("2020-01-02"), !
	Write "Date: ",Obj.DateIsValid(Obj.DateNormalize($h)), !
	
	
	Set Relative = 2
	Do Obj.RelativeSetObjectId(Relative)
	Write "Relative: ", Obj.RelativeGetObjectId(),!
	Set RelObj = Obj.Relative
	Do Obj.Relative.RelativeSetObject(Obj.RelativeGetObject())
	Set RelRelObj = Obj.Relative.Relative
	
	zw RelObj,RelRelObj
}

Query TextQuery(SubStr As %String = {A}) As %SQLQuery
{
SELECT Text FROM GeneratedMethods
 WHERE (Text [ :SubStr)
}

Storage Default
{
<Data name="GeneratedMethodsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Text</Value>
</Value>
<Value name="3">
<Value>Date</Value>
</Value>
<Value name="4">
<Value>Relative</Value>
</Value>
</Data>
<DataLocation>^Utils.GeneratedMethodsD</DataLocation>
<DefaultData>GeneratedMethodsDefaultData</DefaultData>
<IdLocation>^Utils.GeneratedMethodsD</IdLocation>
<IndexLocation>^Utils.GeneratedMethodsI</IndexLocation>
<StreamLocation>^Utils.GeneratedMethodsS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

