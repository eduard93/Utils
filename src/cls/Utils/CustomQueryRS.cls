Class Utils.CustomQueryRS Extends %SQL.CustomResultSet
{

Property Id As %String;

Property Prop1 As %String;

Property Prop2 As %Integer;

Method %OpenCursor() As %Library.Status
{
	Set ..Id = ""
	Quit $$$OK
}

Method %Next(ByRef sc As %Library.Status) As %Library.Integer [ PlaceAfter = %Execute ]
{
	Set sc = $$$OK
	Set ..Id = $Order(^Utils.CustomQueryD(..Id),1,val)
	Quit:..Id="" 0
	Set ..Prop1 = $Lg(val,2)
	Set ..Prop2 = $Lg(val,3)
	Quit $$$OK
}

/// Do ##class(Utils.CustomQueryRS).Test()
ClassMethod Test()
{
	Set resultset= ##class(Utils.CustomQueryRS).%New()
	While resultset.%Next() {
		Write resultset.Id, $c(9), resultset.Prop1, $c(9), resultset.Prop2, !
	}
	//Do resultset.%Display()
}

}

