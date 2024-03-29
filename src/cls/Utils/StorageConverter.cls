/// Convert: list Of <serial> into list Of <serial>(STORAGEDEFAULT = "array")
/// Entry point: convert classmethod
/// Assumptions:
/// 1. Storage is called Default
/// 2. Main Data is called <ShortClassName>DefaultData
/// 3. For the <Property> old storage node (before STORAGEDEFAULT was added) is named <Property>Old - it should be done manually
Class Utils.StorageConverter
{

/// Move class data.
/// If deleteOldData = 1,then data in old storage location would be deleted
/// do ##class(isc.util.StorageConverter).convert("class")
ClassMethod convert(class As %Dictionary.CacheClassname, deleteOldData As %Boolean = {$$$NO})
{
	quit:'##class(%Dictionary.ClassDefinition).%ExistsId(class) $$$ERROR($$$GeneralError, "Class " _ class _ " doesn't exist")
	set global = ..getDataGlobal(class)
	quit:global="" $$$ERROR($$$GeneralError, "Storage global not found for class: " _ class)
	
	// Iterate over class properties
	set rs = ..getPropertiesFunc(class)
	while rs.%Next() {
		set position = rs.position
		set property = rs.property
		write "Converting: ", property, !
		
		// Iterate over data global
		set key=""
		for {
			set key=$order(@global@(key), 1, data) 
			quit:key=""			
			
			// Get field value
			set value = $lg(data, position)
			
			// Move data if it's not empty
			set length = $ll(value)
			if length>0 {
				set @global@(key, property) = length
				for i = 1:1:length {
					set @global@(key, property, i) = $lg($lg(value, i))
				}
				
				// Replace value with empty string
				set:deleteOldData $li(@global@(key), position) = ""
			}
		}
	}
}

/// Get data global
/// w ##class(isc.util.StorageConverter).getDataGlobal("class")
ClassMethod getDataGlobal(class As %Dictionary.CacheClassname) As %String
{
	return:'$$$comClassDefined(class) ""
	set strategy = $$$comClassKeyGet(class, $$$cCLASSstoragestrategy)
	return $$$defMemberKeyGet(class, $$$cCLASSstorage, strategy, $$$cSDEFdatalocation)
}

/// Get list of Data <Property> for which <Data> node <ShortClassName>DefaultData has Value with name <Property>Old
Query getProperties(class As %Dictionary.CacheClassname) As %SQLQuery(ROWSPEC = "position:%Integer,property:%String")
{
SELECT 
     sdv.Name As position, 
     sdd.Attribute As property
     -- sdd.parent, sdd.ID, sdd.Attribute, sdd.Name, sdd.Structure, sdd.Subscript, sdv.Name, sdv.Value
FROM %Dictionary.StorageDataDefinition sdd
JOIN %Dictionary.StorageDataValueDefinition sdv 
     ON sdv.parent =  :class || '||Default||' || $PIECE(:class,'.', $LENGTH(:class,'.'), $LENGTH(:class,'.')) || 'DefaultData'
     AND sdd.Name || 'Old' = sdv.Value
WHERE sdd.parent =  :class || '||Default' 
     AND sdd.Structure = 'subnode'
}

}

