Class Utils.InactivityWatchDogService Extends Ens.BusinessService
{

/// Use an adapter to make sure we get invoked.
Parameter ADAPTER = "Ens.InboundAdapter";

/// Seconds since 00:00:00 after which a day starts. 
/// Must be lower than DayEnd.
/// I.e. 06:00:00 AM is 6*3600 = 21600
Property DayStart As %Integer(MAXVAL = 86400, MINVAL = 0) [ InitialExpression = 21600 ];

/// Seconds since 00:00:00 after which a day ends.
/// Must be higher than DayStart.
/// I.e. 08:00:00 PM is (12+8)*3600 = 72000
Property DayEnd As %Integer(MAXVAL = 86400, MINVAL = 0) [ InitialExpression = 72000 ];

/// Days of Week, which are considered Weekend. Comma separated.
/// For Weekend, NightTimeout applies 24 hours a day.
/// Example: 1,7
/// Check date's DayOfWeek value by running: $SYSTEM.SQL.Functions.DAYOFWEEK(date-expression)
/// By default, the returned values represent these days:
///    1 — Sunday
///    2 — Monday
///    3 — Tuesday
///    4 — Wednesday
///    5 — Thursday
///    6 — Friday
///    7 — Saturday
Property WeekendDays As %String;

/// Timeout value in seconds to raise alerts during the day.
Property DayTimeout As %Integer(MINVAL = 1) [ InitialExpression = 600 ];

/// Timeout value in seconds to raise alerts during the night
Property NightTimeout As %Integer(MINVAL = 1) [ InitialExpression = 7200 ];

/// List of Business Host names (or parts of names) paired with their custom DayTimeout value, one per line.
/// Only Business Hosts which are in scope (satisfy $find(host, scopeA) condition for at least one scope) would be tracked.
/// Leave empty to monitor all Business Hosts.
/// Example:
/// OperationA=120
/// OperationB=60
Property Scopes As %VarString;

/// Internal scopes representation:
/// ..%Scopes("OperationA")=120
/// ..%Scopes("OperationB")=60
Property %Scopes As %String [ MultiDimensional ];

Property %WeekendDays As %List;

Parameter SETTINGS = "WeekendDays:Basic,Scopes:Basic,DayStart:Basic,DayEnd:Basic,DayTimeout:Basic,NightTimeout:Basic";

Method OnInit() As %Status
{
	Set ..%WeekendDays = $lfs(..WeekendDays)
	
	Quit:..Scopes="" $$$OK
	Set tSeparator = $c(10)
	For i=1:1:$length(..Scopes, tSeparator) {
		Set tScope = $piece(..Scopes, tSeparator, i)
		If tScope'="" {
			If $length(tScope, "=") = 2 {
				Set tScopeVal = $zstrip($p(tScope, "=", 1), "<>W")
				Set tTimeout = $zstrip($p(tScope, "=", 2), "*P")
				Set ..%Scopes(tScopeVal) = tTimeout
			} Else {
				Set ..%Scopes(tScope) = ..DayTimeout
			}
		}
	}
	
	Quit $$$OK
}

Method OnProcessInput(pInput As %RegisteredObject, Output pOutput As %RegisteredObject) As %Status
{
	Set tSC=$$$OK
    #; inspect status global for all hosts
    Set tHost=""
    
    For { 
    	Set tHost=$$$OrderHostMonitor(tHost) 
    	Quit:""=tHost
    	Continue:'..InScope(tHost, .tDayTimeout)
		Set lastActivity = $$$GetHostMonitor(tHost,$$$eMonitorLastActivity)
		Set lastActivityReported = $g($$$EnsJobLocal("LastActivity", tHost))
		Set tDiff = $$$timeDiff($$$timeUTC, lastActivity)
		Set tTimeout = ..GetTimeout(tDayTimeout)
		If (tDiff > tTimeout) && ((lastActivityReported="") || ($system.SQL.DATEDIFF("s",lastActivityReported,lastActivity)>0)) {
			Set tText = $$$FormatText("InactivityTimeoutAlert: Inactivity timeout of '%1' seconds exceeded for host '%2'", +$fn(tDiff,,0), tHost)
			Do ..SendAlert(##class(Ens.AlertRequest).%New($LB(tHost, tText)))
			Set $$$EnsJobLocal("LastActivity", tHost) = lastActivity
		}
   }
   Quit tSC
}

Method GetTimeout(pDayTimeout)
{
	If $lf(..%WeekendDays, $SYSTEM.SQL.Functions.DAYOFWEEK($h)) {
		// It's a weekend
		Set tTimeout = ..NightTimeout
	} ElseIf (..DayStart<$p($h,",",2))&&($p($h,",",2)<..DayEnd) {
		// Current horolog time is between DayStart and DayEnd
		Set tTimeout = pDayTimeout
	} Else {
		Set tTimeout = ..NightTimeout
	}
	Quit tTimeout
}

Method InScope(pHost As %String, Output pDayTimeout) As %Boolean
{
	Kill pDayTimeout
	If $data(..%Scopes)<10 {
		Set pDayTimeout = ..DayTimeout
		Return $$$YES
	}
	
	Set tScope=$order(..%Scopes(""))
	While (tScope'="") {
		If $find(pHost, tScope) {
			Set pDayTimeout = ..%Scopes(tScope)
			Return $$$YES
		}
		Set tScope = $order(..%Scopes(tScope))
	}
	Quit $$$NO
}

}
