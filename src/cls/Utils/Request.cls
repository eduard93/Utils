Class Utils.Request [ Abstract ]
{

/// do ##class(Utils.Request).SendFax()
ClassMethod SendFax(phone As %String = 985, docpath As %String = "C:\1.bat") As %String
{
    Set req = ##class(%Net.HttpRequest).%New()
    //test server
    Set req.Server = "httpbin.org"
    Set req.SSLConfiguration = "CardChoice"
    
    Do req.InsertFormData("Username",1)
    Do req.InsertFormData("Password",2)
    Do req.InsertFormData("ProductId",3)
    Do req.InsertFormData("cookies","false")
    Do req.InsertFormData("header","header")
    //Set req.ContentType = "multipart/form-data;"
      
    //Create job name for fax
    Set sendDate = +$H
    Set sendTime = $P($ZTIMESTAMP,",",2)+(15*60)
    Set schedDate = $ZDATETIME(sendDate_","_sendTime,1,4)
    Set schedDate = $E(schedDate,1,16)_" "_$E(schedDate,17,18)
    Set docList = $LFS(docpath,"\")
    Set docName = $LISTGET(docList,$LL(docList))
    Do req.InsertFormData("JobName",schedDate_docName)
    
    //format phone number and set billing code
    Set num = $REPLACE(phone,"-","")
    Do req.InsertFormData("BillingCode",num)
    Do req.InsertFormData("Numbers1",num)
   
    
    //get notification email
    Set email = "ed@is.ru"
    If (email '= "") Do req.InsertFormData("FeedbackEmail",email)
    
     // Create a new MIME message into which we'll insert
    // one or more MIME parts
    Set mimeMsg = ##class(%Net.MIMEPart).%New()

    // Create the MIME part
    Set mimePart = ##class(%Net.MIMEPart).%New()

    // The body of the part is the file stream
    Set docStream=##class(%FileBinaryStream).%New()
    &js<alert("#(docpath)#")>
    Set docStream.Filename = docpath
    Do docStream.LinkToFile(docpath)
    //Set base64 = ##class(%SYSTEM.Encryption).Base64Encode(docStream)
    
    Do mimePart.BodySet(docStream)
    //Set mimePart.Body = base64
    
    // Note: ContentTransferEncoding must be explicitly set to something or
    // an error is generated. Can set it to an empty string.
    //Set mimePart.ContentTransferEncoding = "quoted-printable"
    //Set mimePart.ContentTransferEncoding = "base64"

    //Set the Content Type
    Set mimePart.ContentType = "application/x-object"

    // Add any custom headers
    //Do mimePart.SetHeader("Content-Disposition","attachment; name=""Files1""; filename="""_docName_"""")
	Do mimePart.SetHeader("Content-Disposition", "form-data; name=""uploadedfile""; filename=""hello.o""")
    // Insert the part into the MIME message
    Set sc = mimeMsg.Parts.Insert(mimePart)
    Quit:$System.Status.IsError(sc)
    Set mimeMsg.ContentType = "multipart/form-data"
    //Do mimeMsg.SetHeader("Content-Disposition","attachment; name=""Files1""; filename="""_docName_"""")
    //Set mimeMsg.ContentTransferEncoding = "base64"

    // Create a MIME writer to output the MIME message
    Set mimeWriter = ##class(%Net.MIMEWriter).%New()
    Set sc = mimeWriter.OutputToStream(req.EntityBody)
    Quit:$System.Status.IsError(sc)

    Set sc = mimeWriter.WriteMIMEBody(mimeMsg)
    Quit:$System.Status.IsError(sc)

    // Store the output from the MIME writer in the EntityBody of the request
    //Set req.EntityBody = stream

    // Force the content type of the message to be multipart form data
    // NOTE: By default the ContentType comes from the EntityBody
    // so to explicitly set this, it must happen AFTER setting the EntityBody
    Set req.ContentType = "multipart/form-data;boundary=" _mimeMsg.Boundary


    // Post the request
    Set err = ""
     Do req.Post("post")
    
    If '$IsObject(req.HttpResponse) {
        s err = "Response Error"
        Quit ""
    }
    
    If '$IsObject(req.HttpResponse.Data) {
        s err = "Data Error"
        Quit ""
    }
    
    Set response = req.HttpResponse.Data.Read()
    Set ^response = response
    &js<alert("#(response)#")>
    
    Quit response
}

}

