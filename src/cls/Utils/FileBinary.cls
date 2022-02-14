Class Utils.FileBinary
{

/// do ##class(Utils.FileBinary).Test()
ClassMethod Test(filename = "c:\myfile.txt")
{
	Do ##class(%File).%Delete(filename)
	Set BinaryData = $System.Encryption.SHAHash(512,"123qwertyasdfg")
	
	Set Stream = ##class(%Stream.FileBinary).%New()
	Set st = Stream.LinkToFile(filename)
	Do Stream.Write(BinaryData)
	Do Stream.%Save()
	Kill (BinaryData, filename)
	
	Set Stream = ##class(%Stream.FileBinary).%New()
	Set st = Stream.LinkToFile(filename)
	Set ReadData = ""
	While 'Stream.AtEnd {
		Set ReadData = ReadData _ Stream.Read()
	}
	
	Write ReadData = BinaryData
}

}

