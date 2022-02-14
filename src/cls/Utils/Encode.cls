Class Utils.Encode Extends %RegisteredObject
{

/// do ##class(Utils.Encode).Main()
ClassMethod Main()
{
	
	 S input=$ZCVT("3243f6a8885a308d313198a2e0370734","u")
	 S ib=..binh(input)
	 /*
	 S key="2b7e151628aed2a6abf7158809cf4f3c"
	 S kb=..binh(key)
	 S checkout=$ZCVT("3925841d02dc09fbdc118597196a0b32","U")
	 
	 
	 //S ob=$SYSTEM.Encryption.AESEncode(ib,kb)
	 //S out=..hexs2(ob)
	 
	 ///W "encode ",$CASE(out=checkout,1:"OK",:"failes"),!
	 //S cb=..binh(checkout)
	 s cb="e923d7f6276d1726c07a4a0e7def4149"
	 S ib2=$SYSTEM.Encryption.AESDecode(cb,kb)
	 S input2=..hexs2(ib2)
	 W "decode ",$CASE(input=input2,1:"OK",:"failes"),!
	 
	*/
}

ClassMethod hexb(b)
{
	 Q $E("0123456789ABCDEF",$A(b)\16+1)_$E("0123456789ABCDEF",$A(b)#16+1)
}

ClassMethod hexs2(d)
{
	 //N b,i
	 S s="" F i=1:1:$L(d) S b=$E(d,i),s=s_..hexb(b)
	 Q s
}

ClassMethod binh(d)
{
	 S i=1,bin="" F  S c1=$E(d,i),c2=$E(d,i+1) Q:c1=""!(c2="")  
	 S bin=bin_$C(..h2d(c1)*16+..h2d($E(c2))),i=i+2
	 Q bin
}

ClassMethod h2d(a)
{
	 S a=$A(a)
	 I 47<a,a<58 Q a-48
	 I 64<a,a<71 Q a-65+10 
	 I 96<a,a<103 Q a-97+10
	 Q ""
}

}

