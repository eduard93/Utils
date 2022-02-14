/// Another singleton
Class Utils.Singleton2 Extends %SystemBase
{

Property Content As %String;

/// Set a = ##class(Utils.Singleton2).Get()
ClassMethod Get() As Utils.Singleton2
{
	#Define Var %Var
	If '$Data($$$Var) || '$IsObject($$$Var) {
		Set Obj = ..%New()
		Set $$$Var = Obj
	} Else {
		Set Obj = $$$Var
	}
	Return Obj
}

/// Do ##class(Utils.Singleton2).Test()
ClassMethod Test()
{
	Set a = ##class(Utils.Singleton2).Get()
	Set a.Content = $Random(100)
	
	Set b = ##class(Utils.Singleton2).Get()
	Write b.Content
}

}

