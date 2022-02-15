Class Utils.Main Extends %RegisteredObject
{

Property A As %String [ Aliases = {lolol
olol
wowow
wwoowo} ];

/// w ##class(Utils.Main).#A
/// works with ##class(%ZEN.proxyObject).%ZENDeserialize(..A)
Parameter A = {##class(%ZEN.proxyObject).%Create(..#B).%Serialize()};

/// works with ##class(%ZEN.proxyObject).%Create(..#B)
Parameter B = {"%ZEN.proxyObject" _ $C(6,6) _ "prop" _ $C(5) _"value" _ $C(6) _ "prop2" _ $C(5) _"value"};

ClassMethod SQL()
{
	&sql(SELECT 135+146)
}

/// https://github.com/brandonhorst/cdev-server
ClassMethod GitHub()
{
	zn "%SYS" 
	
	s b=##class(SYS.Database).%OpenId($zu(12,"cachelib"))
	s bk=b.ReadOnly 
	s b.ReadOnly=0 
	d b.%Save() 
	
	s s="Github_CDEV"
	s l="/brandonhorst/cdev-server/master/"
	s jf="json/" 
	s jn="%CDEV.JSON."
	s f="base,boolean,list,null,number,object,stream" 
	s if="includes.inc"
	s sn="%CDEV.Server"
	s u="/csp/sys/dev" 
	
	d ##class(Security.SSLConfigs).Create(s) 
	d ##class(Security.Applications).Copy("/csp/sys",u,"CDev REST Application")
	d ##class(Security.Applications).Get(u,.p) 
	s p("DispatchClass")=sn 
	d ##class(Security.Applications).Modify(u,.p) 
	
	s r=##class(%Net.HttpRequest).%New()
	s r.Server="raw.github.com"
	s r.Https=1
	s r.SSLConfiguration=s 
	
	f i=1:1:$l(f,",") { 
		s t=$p(f,",",i)
		s tn=jn_$zcvt($e(t),"U")_$e(t,2,99) 
		d r.Get(l_jf_t_".cls") 
		s d=$replace(r.HttpResponse.Data.Read(),$c(10),$c(13,10)) 
		d ##class(%Compiler.UDL.TextServices).SetTextFromString(,tn,d)
		d $system.OBJ.Compile(tn,"c-d") 
	} 
	d r.Get(l_jf_if) 
	s i=##class(%Routine).%New(jn_$zcvt($e(if),"U")_$e(if,2,*-3)_$zcvt($e(if,*-2,99),"U")) 
	d i.CopyFromAndSave(r.HttpResponse.Data)
	d r.Get(l_$zcvt(sn,"O","URL")_".cls") 
	s d=$replace(r.HttpResponse.Data.Read(),$c(10),$c(13,10)) 
	d ##class(%Compiler.UDL.TextServices).SetTextFromString(,sn,d)
	d $system.OBJ.Compile(sn,"c-d") 
	s b.ReadOnly=bk 
	d b.%Save()
}

/// 	do ##class(Utils.Main).LoopLength()
ClassMethod LoopLength()
{

	For K=1:1:100000 {
		Set Start=$ZH 
		For I=1:1:100000 { } 
		//W "Loop took, sec ",$ZH-Start,!
		set length = $ZH-Start
		set ^loop(length) =  $i(^loop(length))
	}
}

/// w ##class(Utils.Main).FixedLength(123,5)
ClassMethod FixedLength(number, length) [ CodeMode = expression ]
{
$tr($j(number,length)," ","0")
}

ClassMethod ReturnList(number, length) As %ListOfDataTypes
{
	set a = ##class(%ListOfDataTypes).%New()
	do a.Insert(1)
	do a.Insert(2)
	return a
}

ClassMethod IsClassMapped(classname) As %Boolean
{
	set ns=$Namespace
	zn "%SYS"
	set packagename=$p(classname,".",1,*-1)
	do ##Class(Config.Namespaces).Get(ns,.Properties)
	set dbname=Properties("Routines")
	set sql = "SELECT ID FROM Config.MapPackages WHERE Name = ? AND Namespace = ?"
	
	set rs = ##class(%SQL.Statement).%ExecDirect(.tStatement,sql,packagename,ns)
	if rs.%Next()'=0 {
		s result=1
	} else {
		if ((ns'="SAMPLES") && (ns'="DOCBOOK")) {
			set rs = ##class(%SQL.Statement).%ExecDirect(.tStatement,sql,packagename,"%ALL")
			if rs.%Next()'=0 {
				s result=1
			} else {
				s result=0
			}
		} else {
			s result=0
		}		
	}
	zn ns
	q result
}

/// do ##class(Utils.Main).SQLToJSONParams(1)
ClassMethod SQLToJSONParams(pValue = 50) [ ProcedureBlock = 0 ]
{
    s ns = $Namespace
    zn "samples"
    s tSQL = "SELECT ID, Name FROM Sample.Person WHERE Id > ?"
    s tPR = ##class(%ZEN.Auxiliary.jsonSQLProvider).%New()
    s tPR.sql = tSQL
    s tPR.%Format = "tw"
    s tPR.maxRows = 10
    //s tPR.% = "%ZEN.Auxiliary.jsonSQLProvider"
    s tPR.OnGetSQL = "%OnGetSQL"
    s tPR.pageSize = 10
    s tPR.currPage = 3

    s tParam = ##class(%ZEN.Auxiliary.parameter).%New()
    s tParam.value = pValue
    d tPR.parameters.SetAt(tParam,1)
 
    d tPR.%DrawJSON()  
    //d ##class(%ZEN.Auxiliary.jsonSQLProvider).%WriteJSONFromSQL(,,,,,tPR)  //same thing
    zn ns
}

/// do $System.Status.GetErrorText(##class(Utils.Main).TryQuit())
ClassMethod TryQuit(arg) As %Status
{
	Set tSC = $$$OK
	Try {
		If (arg="") Quit
	}
	Catch(ex) {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

/// 	do ##class(Utils.Main).json()
ClassMethod json()
{
	set obj=##class(%ZEN.proxyObject).%New()
	set obj.property = "value" 
	set obj.objproperty = ##class(%ZEN.proxyObject).%New()
	set obj.objproperty.simpleproperty="value"
	set obj.arrayofdt = ##class(%ListOfDataTypes).%New()
	do obj.arrayofdt.Insert(1)
	do obj.arrayofdt.Insert("string")
	set obj.arrayofobj = ##class(%ListOfObjects).%New()
	
	set obj2=##class(%ZEN.proxyObject).%New()
	set obj2.property = "value"
	 
	do obj.arrayofobj.Insert(obj2)
	do obj.arrayofobj.Insert(obj2)
	
	do obj.%ToJSON() //object root
	
	////////////////////////////////////////////////
	
	set arrayofdt = ##class(%ListOfDataTypes).%New()
	do arrayofdt.Insert(1)
	do arrayofdt.Insert("string")
	do ##class(%ZEN.Auxiliary.jsonProvider).%ObjectToJSON(arrayofdt) //array root, %ListOfObjects is pretty much the same
	
	////////////////////////////////////////////////
	
	set array(1) = $lb("Sam","M",20)
	set array(2) = $lb("John","M",25)
	set array(3) = $lb("Kate","F",30)
	
	do ##class(%ZEN.Auxiliary.jsonProvider).%ArrayToJSON($lb("name","sex","age"),.array)
}

/// do ##class(Utils.Main).GetErrorText()
ClassMethod GetErrorText(st As %Status = {$$$ERROR($$$GeneralError,"Message")}) As %String
{
	q $System.Status.GetOneStatusText(st)
}

/// do ##class(Utils.Main).FormatText()
ClassMethod FormatText() As %String
{
	
	q $$$FormatText("Text %1, %2","Hi","Hello")
}

}

