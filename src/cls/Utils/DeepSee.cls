Class Utils.DeepSee [ Abstract ]
{

/// Output DeepSee schema
/// do ##class(Utils.DeepSee).Demo()
ClassMethod Demo()
{
    Set schema=##class(%XML.Schema).%New()
    Set schema.DefaultNamespace="http://www.intersystems.com/deepsee/library"
    
	Set SQL = "SELECT ID FROM %Dictionary.ClassDefinition Where ID LIKE ?"
	Set ST = ##class(%SQL.Statement).%New()
	Set sc = ST.%Prepare(SQL)
	Quit:$$$ISERR(sc) sc
	
	#Dim RS As %SQL.StatementResult
	Set RS = ST.%Execute("%DeepSee.Dashboard.%")
	
	While RS.%Next() {
		Set sc=schema.AddSchemaType(RS.%GetData(1))
		w $System.Status.GetErrorText(sc),!
	}

    //create writer
    Set writer=##class(%XML.Writer).%New()
    Set writer.Indent=1
    
    //Set writer.
    Do writer.AddSchemaNamespace()
    Do writer.AddNamespace("http://www.intersystems.com/deepsee/library")
    Do writer.OutputToFile("deepsee2.xsd")
    Set writer.DefaultNamespace = "http://www.intersystems.com/deepsee/library"
    
    Set schemawriter=schema.GetSchema("http://www.intersystems.com/deepsee/library")
    Set status=writer.DocumentNode(schemawriter)
    If $$$ERROR(status) {Do $system.OBJ.DisplayError() }
    kill
}

}

