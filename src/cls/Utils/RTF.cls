/// Utility to fill RTF templates
Class Utils.RTF [ Abstract ]
{

/*
Query Test() As %SQLQuery
{
SELECT 
ID, Name
FROM Sample.Person
}
 */
/// Test Query.
/// Main method.
/// template - is a path to a RTF template file
/// variables - values local
///   subscript - namr of a field to replace
///   value - either scalar vvalue, or
///           $lb(class, method) where result of this method execution would be written
///           if it's an object it would be serialized by serializeObject method first
/// 
/// Основной метод.
/// template - шаблон
/// variables - локал значений. 
/// Ключ - название заменяемого поля, значение - либо непосредственно значение
/// либо $lb(class, method) где результат работы этого метода будет отправлен 
/// в метод serializeObject для сериализации если вернётся объект
/// 
/// Call sample:
/// Пример вызова:
/// set template = "D:\Cache\RTF\template.rtf"
/// set var("%title") = "Hello"
/// set var("%table") = $lb("Utils.RTF", "TestFunc")
/// set result = "D:\Cache\RTF\out.rtf"
/// set sc = ##class(Utils.RTF).replace(template, .var, result)
ClassMethod replace(templateFile As %String, ByRef variables, ByRef resultFile As %String = {##class(%File).TempFilename("rtf")}) As %Status
{
	$$$QuitOnError(..fileToString(templateFile, .template))
	
	set key = ""
	for {
		set key=$order(variables(key),1,value) 
		quit:key=""
		
		if ((value'="") && ($listValid(value))) {
			// value is a valid nonempty list in a form of $lb(class, method) TODO args
			// call method
			set value = $classmethod($lg(value,1), $lg(value, 2))
			set:$isObject(value) value = ..serializeObject(value)			
		}
		set template = $replace(template, key, value)
	}
	$$$QuitOnError(..createFile(resultFile,,template))
	
	quit sc
}

/// Object serialization.
/// For SQL resultset - serialization into table
/// 
/// Сериализация объекта.
/// Для SQL запроса - создание таблицы из объекта
ClassMethod serializeObject(object As %RegisteredObject)
{
	set table = ""
	if object.%IsA("%SQL.StatementResult") {
		set table = ..createTableFromSQL(object)
	} elseif (0) {
		// Глобалы
	}
	quit table
}

/// Create table from SQL query
///  
/// Создание таблицы из SQL запроса
ClassMethod createTableFromSQL(rs As %SQL.StatementResult)
{
	set table = ""
	set rowStart = " \trowd" _ $$$NL
	set cellDataEnd = "\intbl\cell"  _ $$$NL
	set rowEnd = " \row"  _ $$$NL
	
	#dim metadata As SQL.StatementMetadata
	set metadata = rs.%GetMetadata()
	set columnCount = metadata.columns.Count()
	
	set header = ..createRowHeader(columnCount) 
	
	set row = rowStart _ header
	for i=1:1:columnCount {
		#dim column As %SQL.StatementColumn
		set column = metadata.columns.GetAt(i)
		set row = row _ column.colName _ cellDataEnd	
	}
	set row = row _ rowEnd
	set table = table _ row
	
	while rs.%Next() {
		set row = rowStart _ header
		for i=1:1:columnCount {
			set row = row _ rs.%GetData(i) _ cellDataEnd	
		}
		set row = row _ rowEnd
		set table = table _ row
	}
		
	quit table
}

/// Create RTF row header
/// 
/// Создаёт заголовок строки
ClassMethod createRowHeader(columns As %Integer) As %String
{
	set result = ""
	set cellHeader = " \clbrdrt\brdrs\clbrdrl\brdrs\clbrdrb\brdrs\clbrdrr\brdrs" _ $$$NL _"\cellx" 
	set width = 9000\columns /// twips per cell - таблица на всю ширину
	for i=1:1:columns {
		set result = result _ cellHeader _  (i* width) _ $$$NL 
	}
	quit result
}

/// Read file "name" into "content" stream, optionally deletes the file
/// 
/// Прочитать файл в строку
ClassMethod fileToString(name As %String, Output content As %String, delete As %Boolean = {$$$NO}) As %Status
{
	#dim sc As %Status = $$$OK
	set stream = ##class(%Stream.FileBinary).%New()
	$$$QuitOnError(stream.LinkToFile(name))
	
	set content = stream.Read($$$MaxStringLength)
	
	if delete {
		kill stream
		set sc = ..deleteFile(name)
	}
	
	quit sc
}

/// Create file "name"
/// stream - %Stream.FileBinary wrapper over created file
/// content - string to populate file with 
/// 
/// 
/// Создать файл name. 
/// Если name не задан, то возвращается имя созданного файла (в папке Temp). 
/// Если name - расширение, то возвращается имя созданного файла (в папке Temp) с заданным расширением.
/// stream - стрим файла
/// content - строка или stream который записывается в файл
ClassMethod createFile(ByRef name As %String = "", Output stream As %Stream.FileBinary, content As %String) As %Status
{
	#dim sc As %Status = $$$OK
	
	if name="" {
		set name = ##class(%File).TempFilename()
	} elseif $length(name, ".")=1 {
		set name = ##class(%File).TempFilename(name)
	}
	
	set stream = ##class(%Stream.FileBinary).%New()
	set sc = stream.LinkToFile(name)
	
	if $data(content) {
		if $isObject(content) {
			set sc = stream.CopyFrom(content)
		} else {
			set sc = stream.Write(content)
		}
		quit:$$$ISERR(sc) sc
		set sc = stream.%Save()
		do stream.Rewind()
	}
	
	quit sc
}

}

