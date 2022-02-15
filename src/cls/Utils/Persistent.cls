Class Utils.Persistent Extends %Persistent
{

Property Main As %String;

/// 	do ##class(Utils.Persistent).Populate()
ClassMethod Populate(Num = 10, Main = {$Namespace})
{

	for i=1:1:Num {
		set obj = ..%New()
		set obj.Main = Main _ i
		do obj.%Save()
	}
}

/// 	do ##class(Utils.Persistent).Display()
ClassMethod Display()
{
	Set tMainStatement = ##class(%SQL.Statement).%New()
	Set tStatus = tMainStatement.%Prepare("SELECT * FROM Utils.Persistent")
	If $$$ISERR(tStatus) {
		w $System.Status.GetErrorText(tStatus)
		Quit
	}
	
	Set tRS = tMainStatement.%Execute()
	While tRS.%Next() {
		w tRS.Main,!
	}
}

/// w ##class(Utils.Persistent).GetExtentSize("Utils.Persistent")
ClassMethod GetExtentSize(Class As %String) As %Integer
{
	Set Global = ..GetDataGlobal(Class)
	Set Id = $Order(@Global@(""))
	Set Count = 0
	While Id '= "" {
		Set Id = $Order(@Global@(Id))
		Set Count = Count + 1
	}
	Return Count
}

/// w ##class(Utils.Persistent).GetGlobal("Utils.Persistent")
ClassMethod GetDataGlobal(Class As %String) As %String
{
	Return:'$$$comClassDefined(Class) ""
	Set Strategy = $$$comClassKeyGet(Class, $$$cCLASSstoragestrategy)
	Return $$$defMemberKeyGet(Class, $$$cCLASSstorage, Strategy, $$$cSDEFdatalocation)
}

ClassMethod ExtSize() As %Integer [ CodeMode = objectgenerator ]
{
	#dim Storage As %Dictionary.CompiledStorage
	set Strategy = %compiledclass.StorageStrategy
	Set StorageId = %compiledclass.Storages.FindObjectId(%compiledclass.Name_"||"_Strategy)
	Set Storage = %compiledclass.Storages.GetAt(StorageId)
	Set Global = Storage.DataLocation
    Do %code.WriteLine(" Set Id = $Order("_Global_"(""""))")
    Do %code.WriteLine(" Set Count = 0")
    Do %code.WriteLine(" While Id '= """" {")
    Do %code.WriteLine(" 	Set Id = $Order("_Global_"(Id))")
    Do %code.WriteLine(" 	Set Count = Count + 1")
    Do %code.WriteLine(" }")
    Do %code.WriteLine(" Return Count")
    Quit $$$OK
}

Index NewIndex1 On Main [ Unique ];

ClassMethod IsLastKnownRecordCheck(CitizenRef As %Integer, RelocationDate As %Date) As %Boolean [ CodeMode = objectgenerator ]
{
    set storagename="Default"
    set storageInd=%class.Storages.FindObjectId(%classname_"||"_storagename)
    set storage=%class.Storages.GetAt(storageInd)
    set indexLocation=storage.IndexLocation
    //set indexLocation=$name(@indexLocation@("CitizenRelocation"))
    do %code.WriteLine($c(9)_"quit $order("_indexLocation_"(""CitizenRelocation"",CitizenRef, RelocationDate))=""""")
    quit $$$OK
}

Storage Default
{
<Data name="PersistentDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Main</Value>
</Value>
</Data>
<DataLocation>^Utils.PersistentD</DataLocation>
<DefaultData>PersistentDefaultData</DefaultData>
<IdLocation>^Utils.PersistentD</IdLocation>
<IndexLocation>^Utils.PersistentI</IndexLocation>
<StreamLocation>^Utils.PersistentS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

