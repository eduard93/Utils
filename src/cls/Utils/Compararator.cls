/// Compare objects
Class Utils.Compararator Extends %RegisteredObject
{

Property diffList As list Of CompararatorItem;

/// do ##class(Utils.Compararator).test(.d, 2)
ClassMethod test(Output diff, maxLevel As %Integer = 2)
{
	kill obj1,obj2,diff
	#dim obj1,obj2 As Sample.Employee
	set obj1 = ##class(Sample.Employee).%OpenId(101)
	set obj2 = obj1.%ConstructClone($$$YES)
	
	// dt diff
	set obj2.Name = 123
	
	// dt list diff
	do obj1.FavoriteColors.Insert("Red")
	do obj2.FavoriteColors.Insert("Red")
	do obj2.FavoriteColors.Insert("Blue")
	
	// serial diff
	set obj2.Home.City = 000
	
	// stream diff
	do obj1.Notes.Write(222) 
	
	// dt diff in child obj
	set obj1.Spouse = ##class(Sample.Person).%OpenId(2)
	set obj2.Spouse = obj1.Spouse.%ConstructClone($$$YES)
	set obj2.Spouse.Name = 456
	
	// dt list diff in child obj
	do obj1.Spouse.FavoriteColors.Insert("Red")
	do obj2.Spouse.FavoriteColors.Insert("Red")
	do obj2.Spouse.FavoriteColors.Insert("Blue")
	
	// serial diff in child obj
	set obj2.Spouse.Home.City = 000
	
	// diff relationship
	set obj1.Company = ##class(Sample.Company).%OpenId(1)
	set obj2.Company = ##class(Sample.Company).%OpenId(2)
	
	set sc = ..compareObjects(obj1, obj2, , .diff, 0, maxLevel)
	write $System.Status.GetErrorText(sc)
	do:$isobject(diff) diff.displayJSON()
}

/// Compare two objects.
/// Arguments:
///   obj1, obj2 - objects to compare
///   classname - class, by which definition compare properties. For example you can compare instances of subclass only by superclass properties 
///   diff - structure, containing diff results
///   rememberVisited - by default compared object is marked as visited and not compared against other objects anymore
///   maxLevel - number of levels to go into base objects
/// Other arguments are internal and should not be provided:
///   curLevel - current level from the base object
///   basePath - current path
///   visited - local, that stores all visited objects
ClassMethod compareObjects(obj1, obj2, classname As %Dictionary.CacheClassname = {obj1.%ClassName(1)}, diff As Utils.Compararator = {##class(Utils.Compararator).%New()}, rememberVisited As %Boolean = {$$$YES}, maxLevel As %Integer = 1, curLevel As %Integer = 0, basePath As %String = "", ByRef visited) As %Status
{
	
	#dim sc As %Status = $$$OK

	// Quick compare of two datatypes.
	if '$isObject(obj1) && '$isObject(obj2) {
		do:obj1'=obj2 diff.addDiff(basePath, obj1, obj2)
		return $$$OK
	}
	
	// Quick compare for object and datatypes. 
	if (($isObject(obj1) && '$isObject(obj2)) || ('$isObject(obj1) && $isObject(obj2))) {
		set obj1Id = $s($isObject(obj1):obj1.%Id(), 1:obj1)
		set obj2Id = $s($isObject(obj2):obj2.%Id(), 1:obj2)
		do diff.addDiff(basePath, obj1Id, obj2Id)
		return $$$OK
	}

	// If rememberVisits is $$YES then store visited objects and do not visit them again as objects
	// NOTE: visited object and datatype would still be compared above 
	if rememberVisited = $$$YES {
		return:$d(visited(obj1))||$d(visited(obj2)) $$$OK
		set visited(obj1)=""
		set visited(obj2)=""
	}

	// Open compare class we would use for comparision. By default obj1 class
	set class = ##class(%Dictionary.CompiledClass).%OpenId(classname)
	
	// Iterate over each property
	for i=1:1:class.Properties.Count() {
		#dim property As %Dictionary.CompiledProperty
		set property = class.Properties.GetAt(i)
		set propertyName = property.Name
		set propertyCollection = property.Collection
		set propertyCardinality = property.Cardinality
		set propertyType = ..getClassType(property.Type)
		
		CONTINUE:(propertyName="%%OID")||(propertyName="%Concurrency")	
		
		// propertyKey is used to iterate over elements in list/array properties
		set propertyKey = ""
		
		if ((propertyCollection = $$$cPROPCOLLECTIONLIST) || (propertyCardinality = $$$cPROPCARDINALITYMANY) || (propertyCardinality = $$$cPROPCARDINALITYCHILDREN)) {
			#define MAX(%x,%y) $s((%x) > (%y): (%x), 1:(%y))
			set propertyMaxKey = $$$MAX($method($property(obj1, propertyName),"Count"), $method($property(obj2, propertyName),"Count"))
		}
		
		// Iterate till propertyKey=""
		for {
			
			// Set obj1Property, obj2Property and next propertyKey
			if propertyCollection="" {
				//zw obj, obj2, classname
				set obj1Property = $property(obj1, propertyName)
				set obj2Property = $property(obj2, propertyName)
				if propertyKey="" {
					set propertyKey = 1
				} else {
					set propertyKey = ""
				}
			} elseif ((propertyCollection = $$$cPROPCOLLECTIONLIST) || (propertyCardinality = $$$cPROPCARDINALITYMANY) || (propertyCardinality = $$$cPROPCARDINALITYCHILDREN)) {
				if propertyKey<propertyMaxKey {
					set propertyKey = propertyKey+1
					set obj1Property = $method($property(obj1, propertyName), "GetAt", propertyKey)
					set obj2Property = $method($property(obj2, propertyName), "GetAt", propertyKey)	
				} else {
					set propertyKey = ""
				}
			} elseif propertyCollection = $$$cPROPCOLLECTIONARRAY {
				/// TODO true arrays
			}
			
			quit:propertyKey=""
			
			// Compare datatypes
			if propertyType = $$$cCLASSCLASSTYPEDATATYPE {
				if (obj1Property'=obj2Property) && (curLevel<maxLevel) {
					//if $listValid(obj1Property) && '$listSame(obj1Property,obj2Property)
					do diff.addDiff(basePath _ $s(basePath'="":".", 1:"") _ propertyName _ $s(propertyCollection'="":"(" _ propertyKey _ ")", 1:""), obj1Property, obj2Property)
				}  
			// Compare persstent and serial objects recursively
			} elseif (((propertyType = $$$cCLASSCLASSTYPEPERSISTENT) || (propertyType = $$$cCLASSCLASSTYPESERIAL)) && (curLevel<maxLevel)) {
				//zw propertyName
				set sc = ..compareObjects(obj1Property, obj2Property, property.Type, diff, rememberVisited, maxLevel, curLevel+1, basePath _ $s(basePath'="":".", 1:"") _ propertyName _ $s(propertyCollection'="":"(" _ propertyKey _ ")", 1:""), .visited)
				quit:$$$ISERR(sc)
			// Compare streams
			} elseif  propertyType = $$$cCLASSCLASSTYPESTREAM {
				set obj1PropertySer = obj1Property.Read($$$MaxLocalLength)
				set obj2PropertySer = obj2Property.Read($$$MaxLocalLength)
				
				if (obj1PropertySer'=obj2PropertySer) && (curLevel<maxLevel) {
					do diff.addDiff(basePath _ $s(basePath'="":".", 1:"") _ propertyName _ $s(propertyCollection'="":"(" _ propertyKey _ ")", 1:""), obj1PropertySer, obj2PropertySer)
				}
			}
		}
	}

	quit sc
}

Method display()
{
	write "Path	OldValue	NewValue",!
	for i=1:1:..diffList.Count() {
		write ..diffList.GetAt(i).asString(), !
	}
}

Method toLocal(Output diff)
{
	kill diff
	for i=1:1:..diffList.Count() {
		set diff(i) = ..diffList.GetAt(i).asList()
	}
	set diff = i
}

Method toGlobal(glvn)
{
	set:$e(glvn)'="^" glvn = "^" _ glvn
	do ..toLocal(.diff)
	m @glvn = diff
}

Method displayJSON()
{
	#if $$$comClassDefined("%Library.Object")
		#define toJSON $toJSONFormat
	#else
		#define toJSON %ToJSON
	#endif 

	write ..asDynObj().$$$toJSON()
}

Method asDynObj()
{
	set list = []
	for i=1:1:..diffList.Count() {
		do list.%push(..diffList.GetAt(i).asDynObj())
	}
	return list
}

Method addDiff(path As %String, oldValue As %String, newValue As %String)
{
	set obj = ##class(CompararatorItem).%New(path, oldValue, newValue)
	do ..diffList.Insert(obj)
}

ClassMethod getClassType(classname As %Dictionary.CacheClassname) As %String [ CodeMode = expression ]
{
$$$getClassType($$$NormalizeClassname(classname))
}

}

