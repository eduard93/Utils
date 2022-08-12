Class Utils.Projection Extends %Projection.AbstractProjection
{

/// For class in which you want to call CreateProjection
Projection Reference As Utils.Projection;

/// This method is invoked when a class is compiled
ClassMethod CreateProjection(cls As %String, ByRef params) As %Status
{
	//Do ##class(Utils.Browser).RunPage()
	//Read !,"Input x: ", x:2
    //Set ^test = $Get(x)
    //Set ^test("user") = $System.Process.UserName()
    Quit $$$OK
}

/// This method is invoked when a class is 'uncompiled'
ClassMethod RemoveProjection(cls As %String, ByRef params, recompile As %Boolean) As %Status
{
	//Do ##class(Utils.Browser).RunPage()
    // code here...
    Quit $$$OK
}

}

