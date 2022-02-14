/// Currently unimplemented
Class Utils.DocAPI [ Abstract ]
{

ClassMethod ProduceXLSX(file) As %Status
{
	set workbook = ##class(Doc.Spreadsheet).%New()
	set sheet =  ##class(Doc.Sheet).%New()
	do workbook.Sheets.Insert(sheet)
	
	set cell11 = sheet.GetCell(1, 1)
	
	set cell11.Text = 123
	set style = ##class(Doc.Style).%New("bold")
	set cell11.Style = style
	
	set cell21 = ##class(Doc.Cell).%New("456", style)
	do sheet.SetCell(2, 1, cell21)
	
	do sheet.SetCellText(3, 1, "MyText") // fast
		
	do sheet.SetStyleForRow(2, style)
	
	do workbook.%Save() // persistent == get ids
	do workbook.Write(file)
}

}

