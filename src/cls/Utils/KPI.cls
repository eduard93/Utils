Class Utils.KPI
{

/// This XData definition defines the KPI.
XData KPI
{
<kpi
xmlns="http://www.intersystems.com/deepsee/kpi"
 name="!!!1!!!" sourceType="sql"
 sql="!!!2!!!">
}

/// do ##class(Utils.KPI).GenerateKPIClass("SELECT name, type FROM Sample.Per", "KPINAME", "try.kpi") 
ClassMethod GenerateKPIClass(SQL, Name, Class)
{
	#dim sc As %Status = $$$OK
	
	if '##class(%Dictionary.ClassDefinition).%ExistsId(Class) {
		set ClassObj = ##class(%Dictionary.ClassDefinition).%New(Class)
		set ClassObj.GeneratedBy = "KPI Gen utility"
		set ClassObj.Super = "%DeepSee.KPI"
	} else {
		set ClassObj = ##class(%Dictionary.ClassDefinition).%OpenId(Class)
		do ClassObj.XDatas.Clear()
	}
	
	set KPI = ##class(%Dictionary.XDataDefinition).%New(Class _ ":KPI")
	
	set header = ##class(%Dictionary.XDataDefinition).IDKEYOpen($classname(), "KPI").Data.Read(10000)
	do ..ReplaceRegexp(.header, "!!!1!!!", Name)
	do ..ReplaceRegexp(.header, "!!!2!!!", SQL)
	do KPI.Data.WriteLine(header) 
	
	set st = ##class(%SQL.Statement).%New()
	set sc = st.%Prepare(SQL)
	quit:$$$ISERR(sc) sc
	
	#dim result As %SQL.StatementResult
	set result = st.%Execute(args...)
	
	#dim metadata As SQL.StatementMetadata
	set metadata = result.%GetMetadata()
	set columnCount = metadata.columns.Count()
	for i=1:1:columnCount {
		#dim column As %SQL.StatementColumn
		set column = metadata.columns.GetAt(i)
		do KPI.Data.WriteLine("<property name=""" _ column.colName  _ """/>")	
	}
	do KPI.Data.Write("</kpi>")
	
	do ClassObj.XDatas.Insert(KPI)
	
	do ClassObj.%Save()
	do $System.OBJ.Compile(Class)
}

/// Replaces all occurances of Pattern with ReplacePattern.
/// w $System.Status.GetErrorText(##class(SMR.Main).ReplaceRegexp(.Text))
ClassMethod ReplaceRegexp(ByRef Text, Pattern As %String = "", ReplacePattern As %String = "") As %Status
{
	#Dim Matcher As %Regex.Matcher = ##class(%Regex.Matcher).%New(Pattern, Text)
	Set Text = Matcher.ReplaceAll(ReplacePattern)
    Quit Matcher.Status
}

}

