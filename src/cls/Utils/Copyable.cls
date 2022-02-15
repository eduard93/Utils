/// / Generated methods for copying and comparing property values between objects of different classes with a common ancestor.
Class Utils.Copyable
{

/// "Shallow" copy of property values from objToCopy object except Internal, Calculated, ReadOnly, Private, MultiDimensional and Identity properties.
/// If originClassName is not specified, the objToCopy object class must be inherited from or equal to the current class. The values of all properties of the current class are copied.
/// If originClassName is specified, the current class and objToCopy object class must be inherited from or equal to originClassName.
/// If originClassName is specified, the values of the properties of the current class available in the originClassName class are copied.
Method copyFrom(objToCopy, originClassName As %String = "") As %Status [ CodeMode = objectgenerator ]
{
	do %code.WriteLine(" if (originClassName '= """") && '$classmethod(""" _ %compiledclass.Name _  """, ""%Extends"", originClassName) quit $$$ERROR($$$InvalidArgument)")
	do %code.WriteLine(" if '$isObject(objToCopy) quit $$$ERROR($$$InvalidArgument)")
	do %code.WriteLine(" if 'objToCopy.%Extends($case(originClassName, """":""" _ %compiledclass.Name _  """, :originClassName)) quit $$$ERROR($$$InvalidArgument)")
	
	kill list
	for i = 1:1:%compiledclass.Properties.Count()
	{
		#dim prop As %Dictionary.CompiledProperty = %compiledclass.Properties.GetAt(i)
		if prop.Internal || prop.Calculated || prop.ReadOnly || prop.Private || prop.Identity || prop.MultiDimensional continue
		set list(prop.Origin, prop.Name) = ""
	}
		
	#dim origin As %String = $order(list(""))
	while (origin '= "")
	{
		do %code.WriteLine(" if (originClassName = """") || ($classmethod(originClassName, ""%Extends"", """ _ origin _ """)) {")
		
		#dim name As %String = $order(list(origin, ""))
		while (name '= "")
		{
			do %code.WriteLine("  set .." _ name _ " = objToCopy." _ name)
			set name = $order(list(origin, name))
		}

		do %code.WriteLine(" }")
		
		set origin = $order(list(origin))
	}
	
	do %code.WriteLine(" quit $$$OK")
	quit $$$OK
}

/// Comparison of the properties of the current object with those of obj except Internal, Calculated, ReadOnly, Private, MultiDimensional and Identity properties.
/// The list of different properties is entered in the diffList.
/// If originClassName is not specified, the obj object class must be inherited from or equal to the current class. All the properties of the current class participate in the comparison.
/// If originClassName is specified, the current class and class of obj object must be inherited from or equal to originClassName.
/// If originClassName is specified, then only those properties of the current class that are present in the originClassName class are involved in the comparison.
/// IMPORTANT: Only the first 3 641 144 bytes are compared for streams
/// IMPORTANT: When comparing stream collections and stream properties inside Serial objects are ignored.
/// To compare the contents of streams inside Serial objects, you should create and fill additional properties containing stream hashes.
Method compareTo(obj, originClassName As %String = "", Output diffList As %List) As %Status [ CodeMode = objectgenerator ]
{
	do %code.WriteLine(" if (originClassName '= """") && '$classmethod(""" _ %compiledclass.Name _  """, ""%Extends"", originClassName) quit $$$ERROR($$$InvalidArgument)")
	do %code.WriteLine(" if '$isObject(obj) quit $$$ERROR($$$InvalidArgument)")
	do %code.WriteLine(" if 'obj.%Extends($case(originClassName, """":""" _ %compiledclass.Name _  """, :originClassName)) quit $$$ERROR($$$InvalidArgument)")
	
	kill list
	for i = 1:1:%compiledclass.Properties.Count()
	{
		#dim prop As %Dictionary.CompiledProperty = %compiledclass.Properties.GetAt(i)
		if prop.Internal || prop.Calculated || prop.ReadOnly || prop.Private || prop.Identity || prop.MultiDimensional continue
		set list(prop.Origin, prop.Name) = $lb(prop.RuntimeType, prop.Collection)
	}
	
	do %code.WriteLine(" set diffList = """"")
	#dim origin As %String = $order(list(""))
	while (origin '= "")
	{
		do %code.WriteLine(" if (originClassName = """") || ($classmethod(originClassName, ""%Extends"", """ _ origin _ """))")
		do %code.WriteLine(" {")
		
		#dim name As %String = $order(list(origin, ""))
		while (name '= "")
		{
			do %code.WriteLine("  // " _ name)
			#dim runtimeType As %String = $listget(list(origin, name), 1)
			#dim collection As %String = $listget(list(origin, name), 2)
			
			if (collection '= "")
			{
				// Collections
				do %code.WriteLine("  set sc = ..compareCollection(""" _ name _ """, """ _ runtimeType _ """, $this, obj, .diffList)")
				do %code.WriteLine("  if $$$ISERR(sc) return sc")
			}
			elseif (runtimeType [ "%Library.") || (runtimeType [ "%xsd.") || (runtimeType [ "%Stream.")
			{
				// Simple datatypes
				if '$classmethod(runtimeType, "%Extends", "%Stream.Object")
				{
					do %code.WriteLine("  if (.." _ name _ " '= obj." _ name _ ") set diffList = diffList _ $lb(""" _ name _ """)")
				}
				else
				{
					do %code.WriteLine("  if (.." _ name _ ".Read($$$MaxLocalLength) '= obj." _ name _ ".Read($$$MaxLocalLength)) set diffList = diffList _ $lb(""" _ name _ """)")
				}
			}
			else
			{
				do %code.WriteLine("  set sc = ..compare(""" _ name _ """, """ _ runtimeType _ """, $this, obj, .diffList)")
				do %code.WriteLine("  if $$$ISERR(sc) return sc")
			}
			set name = $order(list(origin, name))
		}

		do %code.WriteLine(" }")
		
		set origin = $order(list(origin))
	}
	
	do %code.WriteLine(" quit $$$OK")
	quit $$$OK
}

/// Delete stream references from serialized properties
ClassMethod removeStreamRef(ByRef str As %String) As %Status [ Private ]
{
	#dim pattern As %String = "\$lb\(\$c\([[0-9],]*\)\_\""\^?[\.\$\%[a-z][A-Z][0-9]]*\""\_\$c\([[0-9],]*\),\""([\.\$\%[a-z][A-Z][0-9]]*)\""\)"
	#dim matcher As %Regex.Matcher = ##class(%Regex.Matcher).%New(pattern)
    set matcher.Text = str
    
    while matcher.Locate()
    {
	    if (matcher.GroupCount '= 1) || '$classmethod(matcher.Group(1), "%Extends", "%Stream.Object") continue
	    set matcher.Text = matcher.ReplaceFirst("")
	    if $$$ISERR(matcher.Status) return matcher.Status
    }
    
    set str = matcher.Text
    
    quit $$$OK
}

/// Recursively replace empty serial objects with empty string
/// "$lb(1,$lb($lb("""",""""),""""),2,$lb($lb("""",""""),""""),$lb(""""),3)" -> "$lb(1,"""",2,"""","""",3)"
ClassMethod removeEmptySerialRef(ByRef str As %String) As %Status
{
	#dim pattern As %String = "\$lb\(((\""\"")?\,?)+\)"
	#dim matcher As %Regex.Matcher = ##class(%Regex.Matcher).%New(pattern)
    set matcher.Text = str
    
    while matcher.Locate()
    {
	    set matcher.Text = matcher.ReplaceAll("""""")
	    if $$$ISERR(matcher.Status) return matcher.Status
    }
    
    set str = matcher.Text
    
    if (str = """""") set str = ""
    
    quit $$$OK
}

/// Compare collection properties
ClassMethod compareCollection(name As %String, runtimeType As %String, obj1 As %Persistent, obj2 As %Persistent, ByRef diffList As %List) As %Status [ Private ]
{
	// Ignore streams
	if $classmethod(runtimeType, "%Extends", "%Collection.ListOfStream") quit $$$OK
	
	#dim sc As %Status
	#dim s1, s2 As %String
	
	set sc = ..serializeCollection(name, obj1, .s1)
	if $$$ISERR(sc) quit sc
	
	set sc = ..serializeCollection(name, obj2, .s2)
	if $$$ISERR(sc) quit sc
	
	if (s1 '= s2) set diffList = diffList _ $lb(name)
	
	//w name _ ": compareCollection: " _ s1 _ " -- " _ s2,!
    
    quit $$$OK
}

/// Serialize collections without streams
ClassMethod serializeCollection(name As %String, obj As %Persistent, Output serialized As %String) As %Status [ Private ]
{
	set serialized = $method($property(obj, name), "Serialize")
	set serialized = ##class(%Library.Global).Quote(serialized)
	quit ..removeStreamRef(.serialized)
}

/// Compare properties
/// We check classes in runtime instead of at the moment of generation to avoid errors because of the unknown order of compilation of property classes.
ClassMethod compare(name As %String, runtimeType As %String, obj1, obj2, ByRef diffList As %List) As %Status [ Private ]
{
	#dim sc As %Status
	#dim s1, s2 As %String

	if $classmethod(runtimeType, "%Extends", "%Library.SerialObject")
	{
		set sc = ..serializeSerial(name, obj1, .s1)
		if $$$ISERR(sc) quit sc
		
		set sc = ..serializeSerial(name, obj2, .s2)
		if $$$ISERR(sc) quit sc
	}
	elseif $classmethod(runtimeType, "%Extends", "%Stream.Object")
	{
		set sc = ..serializeStream(name, obj1, .s1)
		if $$$ISERR(sc) quit sc
		
		set sc = ..serializeStream(name, obj2, .s2)
		if $$$ISERR(sc) quit sc
	}
	elseif $classmethod(runtimeType, "%Extends", "%Library.Persistent")
	{
		set s1 = $property(obj1, name)
		set s2 = $property(obj2, name)
		if (s1 '= s2)
		{
			set s1 = $case(s1, "":"", :$method(s1, "%Id"))
			set s2 = $case(s2, "":"", :$method(s2, "%Id"))
		}
	}
	else
	{
		set s1 = $property(obj1, name)
		set s2 = $property(obj2, name)
	}
	
	if (s1 '= s2) set diffList = diffList _ $lb(name)
	
	//w name _ ": compare: " _ s1 _ " -- " _ s2,!
    
    quit $$$OK
}

/// Serialize serial properties without streams
ClassMethod serializeSerial(name As %String, obj As %Persistent, Output serialized As %String) As %Status [ Private ]
{
	#dim sc As %Status
	#dim oid As %String
	do $method($property(obj, name), "%GetSwizzleObject", , .oid)
	set serialized = $case($get(oid), "":"", :##class(%Library.Global).Quote($listget(oid, 1)))
	set sc = ..removeEmptySerialRef(.serialized)
	quit:$$$ISERR(sc) sc
	quit ..removeStreamRef(.serialized)
}

/// Serialize stream for comparision, only first 3 641 144 bytes are taken
ClassMethod serializeStream(name As %String, obj As %Persistent, Output serialized As %String) As %Status [ Private ]
{
	#dim sc As %Status
	set serialized = $method($property(obj, name), "Read", $$$MaxLocalLength, .sc)
	quit sc
}

/// MD4 Base64 hash, argcount must be less than 255 and their total length less than 3 641 144 bytes
ClassMethod hash(in...) As %Binary
{
    set delimiter = $c(255)
    set str = delimiter
    for i=1:1:in {
        set str = str _ in(i) _ delimiter
    }
    return $system.Encryption.Base64Encode($system.Encryption.MD5Hash(str))
}

}

