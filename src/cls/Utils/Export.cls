/// Exports object globals to file
Class Utils.Export [ Abstract ]
{

/// Entry point. Exports object globals to file
/// className - name of class, id - object id, file - file name and path
/// w ##class(Utils.Export).objectDataToXML("Sample.Person", 1, "C:\Users\eduard\gbl.xml")
ClassMethod objectDataToXML(className As %String, id As %Integer, file As %String) As %Status
{
	do ..getObjectGlobals(className, id, .items)
	return $system.OBJ.Export(.items, file)
}

/// Get list of globals which contain current object
/// className - name of class, id - object id, items - array of global names, eg: items("^PersonD(id).gbl")
/// do ##class(Utils.Export).getObjectGlobals("Sample.Person", 1,.items)
ClassMethod getObjectGlobals(className As %String, id As %Integer, ByRef items As %String)
{
	#dim sc As %Status = $$$OK
	
	set dataGlobal = ..getDataGlobal(className)
	set ref = dataGlobal _ "(" _ $replace(id, "||", ",") _ ").gbl" 

	if ($data(items(ref)) = $$$NO) {
		set items(ref) = ""
	} else {
		return sc
	}
	
	set class = ##class(%Dictionary.CompiledClass).%OpenId(className)
	for i=1:1:class.Properties.Count() {
		#dim property As %Dictionary.CompiledProperty
		set property = class.Properties.GetAt(i)
		CONTINUE:(property.Internal || property.Calculated || property.Identity || property.MultiDimensional)
		
		set propertyClass = property.Type
		CONTINUE:'$$$classIsPersistent(propertyClass) // TODO Streams?
		
		// List of ids for this persistent property
		#dim propertyIdList As %List = ""
		
		if ((property.Relationship=$$$YES) && ((property.Cardinality = $$$cPROPCARDINALITYMANY) || (property.Cardinality = $$$cPROPCARDINALITYCHILDREN))) {
			set propertyIdList = ..getManyForOne(propertyClass, property.Inverse, id)
		} else {
			set propertyIds = $classmethod(className, property.Name _ "GetStored", id)
			CONTINUE:propertyIds=""

			set collection = property.Collection
			if collection = $$$cPROPCOLLECTIONLIST {
				for j=1:1:$listlength(propertyIds) {
					set propertyIdList = propertyIdList _ $lb($lg($lg(propertyIds, j)))
				}
			} elseif collection = $$$cPROPCOLLECTIONARRAY {
				for j=1:1:$listlength(propertyIds) {
					set propertyIdList = propertyIdList _ $lb($lg($lg($lg(propertyIds, j), 2)))
				}			
			} else {
				set propertyIdList = $lb(propertyIds)
				
			}
		} 
				
		for j=1:1:$listlength(propertyIdList) {
			do ..getObjectGlobals(propertyClass, $lg(propertyIdList, j), .items)
		}
	}
}

/// Get data global by className
/// write ##class(Utils.Export).getDataGlobal("Sample.Person")
ClassMethod getDataGlobal(className As %String) As %String
{
	return:'$$$comClassDefined(className) ""
	set strategy = $$$comClassKeyGet(className, $$$cCLASSstoragestrategy)
	return $$$defMemberKeyGet(className, $$$cCLASSstorage, strategy, $$$cSDEFdatalocation)
}

/// Get id list of child/many objects for parentId. Copied from %Library.RelationshipObject:Load.
/// className - property type, propertyName - INVERSE property name, parentId - id, for which we constrict list of id
/// zw ##class(Utils.Export).getChildrenForParent("User.P2", "parent",1)
ClassMethod getManyForOne(className As %String, propertyName As %String, parentId As %Integer) As %List
{
	set sc=$classmethod(className, propertyName _ "RExec", .handle, parentId)
	set children = ""
	for {
		set sc=$classmethod(className, propertyName _ "RFetch", .handle, , .ids, .returnCount, .atEnd)
		quit:(returnCount=0)
		set children = children _ ids
		quit:atEnd
	}
	return children
}

}

