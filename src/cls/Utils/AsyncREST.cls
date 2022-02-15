/// Basic async REST example.
Class Utils.AsyncREST Extends %CSP.REST
{

Parameter CONTENTTYPE = "application/json";

Parameter CHARSET = "UTF-8";

Parameter UseSession As BOOLEAN = 1;

Parameter HandleCorsRequest = 1;

Parameter GLVN = "^AsyncREST";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/StartTask" Method="GET" Call="StartTask"/>
<Route Url="/GetTask/:TaskId" Method="GET" Call="GetTask"/>
</Routes>
}

/// Get info about task
ClassMethod GetTask(TaskId As %Integer) As %Status
{
	Set PercentDone = ..TaskStatus(TaskId)
	
	If PercentDone = 100 {
		Set Result = ..GetCompletedTask(TaskId) 
	} Else {
		Set Result = {"TaskId" : (+TaskId), "PercentDone":(PercentDone), "Alive":($Data(^$JOB(TaskId)))}
	}
	
	Write Result.%ToJSON()
	Quit $$$OK
}

/// Start new task and return result immediately
ClassMethod StartTask() As %Status
{
	Job ..Task()
	Write {"TaskId" : ($zchild)}.%ToJSON()
	Quit $$$OK
}

/// Actually do task
ClassMethod Task()
{
	Set Wait = 0 
	Set Increase = 1
	While Wait<=10 {
		Hang Increase
		Do ..LogTaskStatus( Wait * 10)
		Set Wait = Wait + Increase
			
	}
	
	Do ..LogTaskData("Some result")
}

/// Set current task progression
ClassMethod LogTaskStatus(PercentDone As %Integer(MINVAL=0,MAXVAL=100))
{
	Set:PercentDone>100 PercentDone = 100
	Set:PercentDone<0 PercentDone = 0
	
	Set @..#GLVN@($job) = PercentDone
	If PercentDone = 0 {
		Set @..#GLVN@($job, "Start") = $zdt($h, 3, 1, 3)
	} ElseIf PercentDone = 100 {
		Set @..#GLVN@($job, "End") = $zdt($h, 3, 1, 3)
	}
}

/// Specify data = task output
ClassMethod LogTaskData(Data)
{
	Set @..#GLVN@($job, "Data") = Data
}

/// Get current task progression
ClassMethod TaskStatus(TaskId As %Integer) [ CodeMode = expression ]
{
@..#GLVN@(TaskId)
}

/// Get info about completed task
ClassMethod GetCompletedTask(TaskId As %Integer) As %DynamicObject [ CodeMode = expression ]
{
{
	"TaskId": (+TaskId), 
	"PercentDone": 100,
	"Start": (@..#GLVN@(TaskId, "Start")),
	"End": (@..#GLVN@(TaskId, "End")),
	"Data": (@..#GLVN@(TaskId, "Data")),
	"IsJobAlive": ($Data(^$JOB(TaskId)))
}
}

/// Remove complete task
ClassMethod ClearTask(TaskId As %Integer)
{
	Kill @..#GLVN@(TaskId)
}

}

