Class Utils.YAML
{

Parameter SwaggerRefBase = "#/definitions/";

Parameter StartIndent = 1;

/// Test method
/// do ##class(Utils.YAML).Test()
ClassMethod Test()
{
	set stream = ##class(%Stream.GlobalCharacter).%New()
	
	set classes = ..GetClasses()
	
	set sc = ..GenerateClasses(classes, .stream)
	
	if $$$ISERR(sc) {
		write $System.Status.GetErrorText(sc)
	} else {
		write "ok"
	}
	
	write !,"stream:",!
	do stream.OutputToDevice()
}

/// Get Sample classes list
ClassMethod GetClasses() As %List
{
	set list = ""
	set rs = ..ClassesFunc("Ens.")
	while rs.%Next() {
		set list = list _ $lb(rs.Name)
	}
	
	quit list
}

/// Get all persistent classes in a package
/// do ##class(Utils.YAML).ClassesFunc("REST.Test").%Display()
Query Classes(package) As %SQLQuery
{
SELECT Name 
FROM %Dictionary.ClassDefinition_SubclassOf('%Persistent')
WHERE Name %STARTSWITH :package
}

/// Main entry point
/// Generate Swagger definition from a list of classes
/// Result is written into stream
/// If stream does not exist it is created
ClassMethod GenerateClasses(classes As %List, ByRef definition As %Stream.Object) As %Status
{
	#dim sc As %Status = $$$OK
	set:'$d(definition) definition = ##class(%Stream.GlobalCharacter).%New()
	
	// List of classes we already generated
	set generated = ""
	
	// Iterate over all classes we need to generate
	while $ll(classes)>0 {
		// Get the first class
		set class = $lg(classes, 1)
		
		// Generate the class definition and produce a list of dependencies
		set sc = ..GenerateClass(class, .definition, .dependencies)
		quit:$$$ISERR(sc)
		
		// Move class to the generated list (from the list of classes we need to generate)
		set generated = generated _ $lb(class)
		set $li(classes,1,1)=""
		
		// Find out which class dependencies are not yet generated
		set notGenerated = ..ExceptList(dependencies, generated)
		
		// Append not generated classes to generation list (if they are not already on the generation list)
		do ..AppendToList(.classes, notGenerated)	
	}
	
	do definition.Rewind()
	
	quit sc
}

/// Add items from new list to initial list
/// Only adds items not present in initial list
ClassMethod AppendToList(ByRef initial As %List, new As %List)
{
	set ptr=0
	while $listnext(new, ptr, class) {
		set:'$lf(initial, class) initial = initial _ $lb(class)	
	}
}

/// Remove new list from initial list
/// Assume new list is longer
ClassMethod ExceptList(initial As %List, new As %List) As %List
{
	set except = ""
	set ptr=0
	while $listnext(initial, ptr, class) {
		set:'$lf(new, class) except = except _ $lb(class)
	}
	quit except
}

/// Generate Swagger definition for one class
/// class - class to generate description from.
/// definition - generated swagger definition is placed here.
/// dependencies - list of classes our class depends on.
ClassMethod GenerateClass(class As %Dictionary.CacheClassname, definition As %Stream.Object, Output dependencies As %List) As %Status
{
	#dim sc As %Status = $$$OK
	set dependencies = ""
	do ..GenerateInitial(class, definition)
	
	// Iterate over class properties
	set property=$$$comMemberNext(class, $$$cCLASSproperty, "")
	while property'="" {
		if (..OutputProperty(class, property)) {
			set sc = ..GenerateProperty(class, property, definition)
			quit:$$$ISERR(sc)
			
			// Add current property type to dependencies if needed
			do ..AddDependency(class, property, .dependencies)
		}
				
		// Get next property
		set property=$$$comMemberNext(class, $$$cCLASSproperty, property)		
	}
	quit sc
}

/// Add class property type to dependencies if it's not there already and it's required
ClassMethod AddDependency(class As %Dictionary.CacheClassname, property As %String, ByRef dependencies As %String)
{
	set type = ..GetPropertyType(class, property)
	set classType = $$$getClassType(type)
	
	if (classType = $$$cCLASSCLASSTYPEPERSISTENT) || (classType = $$$cCLASSCLASSTYPESERIAL) {	
		set:'$lf(dependencies, type) dependencies = dependencies _ $lb(type)
	}
}

/// Do we need to output this property?
ClassMethod OutputProperty(class As %Dictionary.CacheClassname, property As %String) As %Boolean
{
	set internal = $$$comMemberKeyGet(class, $$$cCLASSproperty, property, $$$cPROPinternal)
	quit (internal = $$$NO)
}

/// Generate swagger spec for one property
ClassMethod GenerateProperty(class As %Dictionary.CacheClassname, property As %String, definition As %Stream.Object) As %String
{
	#dim sc As %Status = $$$OK
	/* docs https://swagger.io/docs/specification/data-models/data-types/
	   primitives: integer number string boolean
	   collection: array object
	  
	  examples:
	  
	  id:
        type: integer
      category:
        $ref: "#/definitions/Category"
      numbers:
        type: object
      tags:
        type: array
        items:
         type: string 
        */
       
	do ..Writeline(definition, 4, property _ ":")
	
	set collection = $$$comMemberKeyGet(class, $$$cCLASSproperty, property, $$$cPROPcollection) // "", "array", "list"
	set type = ..GetPropertyType(class, property)
	set swaggerType = ..TypeToSwagger(type)
	
	if swaggerType [ ..#SwaggerRefBase {
		set swaggerTypeLine = "$ref: """ _ swaggerType _ """"		
	} else {
		set swaggerTypeLine = "type: """ _ swaggerType _ """"
	}
	
	if collection = "" {
		do ..Writeline(definition, 6, swaggerTypeLine)
	} elseif collection = "array" {
		// Free-form object
		do ..Writeline(definition, 6, "type: ""object""")
	} elseif collection = "list" {
		do ..Writeline(definition, 6, "type: ""array""")
		do ..Writeline(definition, 6, "items:")
		do ..Writeline(definition, 8, swaggerTypeLine)
	} else {
		set sc = $$$ERROR($$$GeneralError, $$$FormatText("Unknown collection state: '%1' for property '%2' in class '%3'", collection, property, class))
	}
	
	
	quit sc
}

/// Generate initial Swagger spec for a class
ClassMethod GenerateInitial(class As %Dictionary.CacheClassname, definition As %Stream.Object)
{
	do ..Writeline(definition, 0, class _ ":")
	do ..Writeline(definition, 2, "type: ""object""")
	do ..Writeline(definition, 2, "properties:")
}

/// Print new line and indent arg chars
ClassMethod Writeline(definition As %Stream.Object, indent As %Integer(MINLEN=0), value As %String) [ CodeMode = expression ]
{
definition.WriteLine($j("", ..#StartIndent + indent) _ value)
}

/// Get property Type
ClassMethod GetPropertyType(class As %Dictionary.CacheClassname = "", property As %String) As %String
{
	set type = $$$comMemberKeyGet(class, $$$cCLASSproperty, property, $$$cPROPtype)
	set:type="" type = "%Library.String"
	quit type
}

/// Get swagger property type from property type
ClassMethod TypeToSwagger(type As %Dictionary.CacheClassname = "") As %String
{
	set swagger = ""
	set classType = $$$getClassType(type)
	
	if classType = $$$cCLASSCLASSTYPEDATATYPE {	
		if type = "%Library.Boolean" {
			set swagger = "boolean"
		} elseif $lf($lb("%Library.Integer", "%Library.BigInt", "%Library.SmallInt", "%Library.TinyInt"), type) {
			set swagger = "integer"
		} elseif $lf($lb("%Library.Decimal", "%Library.Double", "%Library.Float", "%Library.Currency", "%Library.Numeric"), type) {
			set swagger = "number"
		} else {
			set swagger = "string"
		}
	} elseif ((classType = $$$cCLASSCLASSTYPEPERSISTENT) || (classType = $$$cCLASSCLASSTYPESERIAL)) {
		set swagger = ..TypeToSwaggerReference(type)
	} elseif classType =$$$cCLASSCLASSTYPESTREAM {
		set swagger = "string"
	} else {
		// $$$cCLASSCLASSTYPEVIEW and $$$cCLASSCLASSTYPESYSTEM
		// we shouldn't be here	
	}
	
	quit swagger
}

/// Convert InterSystems property type into Swagger reference
ClassMethod TypeToSwaggerReference(type As %Dictionary.CacheClassname = "") [ CodeMode = expression ]
{
..#SwaggerRefBase _ type
}

/// Get property param
/// w ##class(Utils.YAML).GetPropertyParam("Form.Test.Simple", "text", "MINVAL")
ClassMethod GetPropertyParam(class As %Dictionary.CacheClassname = "", property As %String = "", param = "") As %String [ CodeMode = expression ]
{
$$$comMemberArrayGet(class, $$$cCLASSproperty, property, $$$cPROPparameter, param)
}

}

