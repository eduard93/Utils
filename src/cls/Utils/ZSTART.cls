/// Samples for %ZSTART.mac, %ZLANGC00.MAC
Class Utils.ZSTART Extends %Persistent
{

/*   
 ////// %ZLANGC00.MAC
 ; custom commands for ObjectScript
 ; http://localhost:57772/csp/docbook/DocBook.UI.Page.cls?KEY=GSTU_customize
  Quit    

/// Execute Query and display the results 
/// Call like this:
/// zsql "SELECT TOP 10 Name FROM Sample.Person"
ZSQL(Query)
	#Dim ResultSet As %SQL.StatementResult
	Set ResultSet = ##class(%SQL.Statement).%ExecDirect(, Query)
	Do ResultSet.%Display()
	Quit

/// Move user to a namespace of his choice
/// Call like this:
/// zm "s"
ZM(Namespace)
	Do MoveToNamespace^%ZSTART(Namespace)
	Quit

 //////////// %ZSTART.mac
%ZSTART() {
	Quit	
}

/// This entry point is invoked on user login
/// offering user to choose a namespace
LOGIN() Public {
	Set Timeout = 3
	Write "Namespace <" _ $Namespace _ ">: "  
	Read Namespace:Timeout // Get value of a Namespace variable
	Quit:Namespace=""
	Do MoveToNamespace(Namespace)
}	

/// Does actual moving to a chosen namespace
/// This is an entry point, for cases where 
/// Namespace value is already aquired
MoveToNamespace(Namespace = "") Public {
	Set Timeout = 3
	#Dim List As %ListOfDataTypes
	Set List = $$GetNamespaceList(Namespace)
	Set Count = List.Count() 
	
	If Count = 1 {
		Set Choice = 1
	} ElseIf Count > 1 {
		Do DisplayList(List)

		// If there is less then 10 results, then we need only 1 digit
		// Otherwise we need 2 digits 
		// It is assumed that no more then 99 results would be returned 
		Read "Select number <1>: ", Choice#$Select(Count < 10:1, 1:2):Timeout

		// If the user entered nothing or not a valid number
		// we select first namespace in a list to go to
		Set:((Choice = "") || ('$IsValidNum(Choice, 0, 1, Count))) Choice = 1
	} Else {
		// No namespaces found
		Quit
	}
	
	Zn List.GetAt(Choice)
}

/// Get all availible namespaces that satisfy 
/// "Name %STARTSWITH Namespace" condition 
/// as %ListOfDataTypes 
GetNamespaceList(Namespace = "") {
	New $Namespace
	Set $Namespace = "%SYS"

	#Dim List As %ListOfDataTypes
	#Dim ResultSet As %SQL.StatementResult
	Set List = ##class(%ListOfDataTypes).%New()

	Set UserCondition = "%UPPER(Name) %STARTSWITH %UPPER(?)"  // Or [ if you wish
	Set Condition = "(" _ UserCondition _ ") AND (SectionHeader='Namespaces') AND (%UPPER(Name) != '%ALL')"
	Set SQL = "SELECT Name FROM Config.Namespaces WHERE " _ Condition

	Set ResultSet = ##class(%SQL.Statement).%ExecDirect(, SQL, Namespace)
	While ResultSet.%Next() {
		Do List.Insert(ResultSet.%Get("Name"))
	}

	Quit List
}

/// Display %ListOfDataTypes in a format:
/// 1	item
/// 2	item
/// ...
DisplayList(List) {
	#Dim List As %ListOfDataTypes
	Write !
	For i = 1:1:List.Count() {
		Write i, $C(9), List.GetAt(i), !
	}
}
 */
Storage Default
{
<Data name="ZSTARTDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^Utils.ZSTARTD</DataLocation>
<DefaultData>ZSTARTDefaultData</DefaultData>
<IdLocation>^Utils.ZSTARTD</IdLocation>
<IndexLocation>^Utils.ZSTARTI</IndexLocation>
<StreamLocation>^Utils.ZSTARTS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

