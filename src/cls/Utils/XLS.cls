Include %occODBC

Class Utils.XLS
{

/// Outputs Excel-compliant table from sql into file. args are sql arguments
/// w ##class(Utils.XLS).generateFileFromSQL()
ClassMethod generateFileFromSQL(file As %String, sql As %String, args...) As %Status
{
	#dim sc As %Status = $$$OK
	#dim stream As %Stream.TmpCharacter = ##class(%Stream.TmpCharacter).%New()
	
	set sc = ..generateStreamFromSQL(.stream, sql, args...)
	quit:$$$ISERR(sc)
	
	set fileStream = ##class(%Stream.FileCharacter).%New()
	set fileStream.Filename = file 
	
	set sc = fileStream.CopyFromAndSave(.stream)
	quit sc
}

/// Outputs Excel-compliant stream from sql into file. args are sql arguments
ClassMethod generateStreamFromSQL(Output stream As %Stream.TmpCharacter, sql As %String, args...) As %Status
{
	#dim sc As %Status = $$$OK
	set st = ##class(%SQL.Statement).%New()
	set st.%SelectMode = 1 // ODBC
	set sc = st.%Prepare(sql)
	quit:$$$ISERR(sc) sc
	
	#dim result As %SQL.StatementResult
	set result = st.%Execute(args...)
	
	set stream = ##class(%Stream.TmpCharacter).%New()
	set header = ##class(%Dictionary.XDataDefinition).IDKEYOpen($classname(), "header").Data.Read(10000)
	do stream.Write(header)
	
	
	do stream.Write("<tr style=""font-weight:bold"">")
	#dim metadata As SQL.StatementMetadata
	set metadata = result.%GetMetadata()
	set columnCount = metadata.columns.Count()
	for i=1:1:columnCount {
		#dim column As %SQL.StatementColumn
		set column = metadata.columns.GetAt(i)
		do stream.Write("<td>" _ column.colName  _ "</td>")
		if column.IsNumeric() {
			set class(i) = "class=""num"""
		} elseif ..isDate(column.ODBCType) {
			set class(i) = "class=""date"""
		} else {
			set class(i) = "class=""text"""
		}	
	}
	do stream.WriteLine("</tr>")
	
	while result.%Next() {
		do stream.Write("<tr>")
		for i=1:1:columnCount {
			do stream.Write("<td " _ class(i) _ ">" _ result.%GetData(i)  _ "</td>")
		}
		do stream.WriteLine("</tr>")
	}
	
	do stream.Write("</table></body></html>")
	return sc
}

ClassMethod isDate(odbcType As %Integer) As %Boolean
{
	return:odbcType=$$$ODBCTYPEtimestamp $$$YES
	return:odbcType=$$$ODBCTYPEdate $$$YES
	return $$$NO
}

/// http://cosicimiento.blogspot.ru/2008/11/styling-excel-cells-with-mso-number.html
XData header [ MimeType = application/yaml ]
{
<html>
<head>
<style>
.num {
  mso-number-format:General;
}
.text{
  mso-number-format:"\@";/*force text*/
}
.date {
  mso-number-format:"Short Date";
}
</style>
</head>
<body>
<table border="1">
}

}

