Include %BigData.ShardingManager

/// Report how much data is stored per class
/// Accepts 2 arguments:
///   - package: where to search for persistent classes
///   - fast: report only allocated, skip used
Class Utils.ClassSize Extends %SQL.CustomQuery
{

Parameter SQLNAME As String = "ClassSize";

/// InterSystems IRIS Class
Property Class As %Dictionary.Classname;

/// Is the class sharded?
/// In the case of a sharded class, remember:
/// 1. Allocated/Used/Directory refer only to the current shard
/// 2. IRIS.Shard package class is used
Property Sharded As %Boolean;

/// What does the global stores for a class
Property Type As %String(VALUELIST = "data,stream,index");

/// In a case of Type=index - what index.
/// If Type=index and SubType is empty - common global for all indices 
Property SubType As %String;

/// GLVN
Property Global As %String(MAXLEN = 32);

/// Total size, in MB, of blocks allocated for the global.
Property Allocated As %Integer;

/// Total used data, in MB, for the global.
Property Used As %Integer;

/// Effective directory for the global
Property Directory As %String(MAXLEN = 1000);

/// Internal storage for query results
Property %Data As %List [ MultiDimensional, Private ];

/// Current row
Property %Row As %Integer [ InitialExpression = 0, Private ];

Method %OpenCursor(package As %String, fast As %Boolean = {$$$YES}) As %Status
{
	#dim sc As %Status = $$$OK

	set rs = ..StoragesFunc(package)
	while rs.%Next() {
		set class = rs.parent
		set storage = rs.name
		
		set sharded = $$$defClassKeyGet(class,$$$cCLASSsharded)

		set:sharded class = $$$SSShardLocalPackage _ "." _ class
		
		set sc = ..GetStorageGlobals(class, storage, fast)
		quit:$$$ISERR(sc)
	}
	quit sc
}

/// Main method, based on class and storage populates %Data
/// class - FQCN
/// storage - name of the storage
/// fast - return only allocated, used is not calculated.
Method GetStorageGlobals(class As %Dictionary.Classname, storage As %String, fast As %Boolean) As %Status
{
	#dim sc As %Status = $$$OK
	set sharded = ($e(class, 1, $l($$$SSShardLocalPackage)) = $$$SSShardLocalPackage) 
	set displayClass = $case(sharded, $$$YES:$replace(class, $$$SSShardLocalPackage _ ".", ""), $$$NO:class)
	
	// First we process 3 main globals
	set data = $$$defMemberKeyGet(class,$$$cCLASSstorage,storage,$$$cSDEFdatalocation)
	set indexAll = $$$defMemberKeyGet(class,$$$cCLASSstorage,storage,$$$cSDEFindexlocation)
	set stream = $$$defMemberKeyGet(class,$$$cCLASSstorage,storage,$$$cSDEFstreamlocation)
	
	for globalList = $lb(data, "data"),	$lb(indexAll, "index"), $lb(stream, "stream") {
		set global = $lg(globalList)
		set globalType = $lg(globalList, 2)
		set sc = ..GetGlobalInfo(global, fast, .directory, .allocated, .used)
		return:$$$ISERR(sc) sc
		set ..%Data($i(..%Data)) = $lb(displayClass, sharded, globalType, "", global, allocated, used, directory)
	}
	
	// Process individual globals (for indices)
	set indexName = $$$defStorageSubMemberNext(class,$$$cCLASSstorage,storage,$$$cSDEFindex,"")
	while indexName'="" {
		if indexName '= "IDKEY" {
			set index = $$$defStorageSubMemberKeyGet(class,$$$cCLASSstorage,storage,$$$cSDEFindex,indexName,$$$cSDEFIDXlocation)
			set sc = ..GetGlobalInfo(index, fast, .directory, .allocated, .used)
			return:$$$ISERR(sc) sc
			set ..%Data($i(..%Data)) = $lb(displayClass, sharded, "index", indexName, index, allocated, used, directory)
		}	
		set indexName = $$$defStorageSubMemberNext(class,$$$cCLASSstorage,storage,$$$cSDEFindex,indexName)
	}
		
	quit sc
}

/// Get all required global information
/// global - global to search for in current namespace
/// fast - return only allocated, used is not calculated.
/// directory - effective directory for the global
/// allocated - total size, in MB, of blocks allocated for the global.
/// used - total used space, in MB, for the global.
ClassMethod GetGlobalInfo(global As %String, fast As %Boolean, Output directory As %String, Output allocated As %Integer, Output used As %Integer) As %Status
{
	kill directory, allocated, used
	#dim sc As %Status = $$$OK
	set dest = ##class(%SYS.Namespace).GetGlobalDest(,global)
	// set system = $p(dest, "^", 1)
	set directory = $p(dest, "^", 2)
		
	if global="" {
		set used = -1
		set allocated = -1
	} elseif $d(@global)=0 {
		set used = $case(fast, $$$YES:"", $$$NO:0)
		set allocated = 0
	} else {
		set sc = ##Class(%GlobalEdit).GetGlobalSize(directory, global, .allocated, .used, fast)
		set used = $case(fast, $$$YES:"", $$$NO: $fnumber(used, "", 0))
		set allocated = $fnumber(allocated, "", 0)
	}
	quit sc
}

/// Get next row
Method %FetchCursor(ByRef sc As %Status = {$$$OK}) As %Integer
{
	quit:(..%Row = ..%Data) 0
	set $lb(i%Class, i%Sharded, i%Type, i%SubType, i%Global, i%Allocated, i%Used, i%Directory) = ..%Data($i(i%%Row))
	quit 1
}

/// Clean up
Method %CloseCursor() [ PlaceAfter = %Next, Private ]
{
	set ..%Row = ""
	kill ..%Data
}

Query Storages(package As %String) As %SQLQuery
{
SELECT 
parent, name
FROM %Dictionary.StorageDefinition
WHERE parent IN (SELECT Name
				 FROM %Dictionary.ClassDefinition_SubclassOf('%Persistent')
				 WHERE Name %STARTSWITH :package)
}

}

