Class Utils.Job
{

/// do ##class(Utils.Job).PrintParralelWS()
ClassMethod PrintParralelWS(JobCount = 4, Timeout = 1)
{
	
 write "Start",!
 for i=1:1:JobCount {
 	job ..exec1(Timeout)
 }
 write "All jobs started",!
 for i=1:1:JobCount {
	 
 	set msg = $listget($system.Event.WaitMsg(), 2)
 	write msg,!
 }
 write "All jobs complete"
}

ClassMethod exec1(Timeout As %Integer = 1)
{
 hang Timeout
 do $system.Event.Signal($zparent, "Job " _ $job _ " complete")
}

}

