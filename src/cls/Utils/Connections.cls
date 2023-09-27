Class Utils.Connections
{

/// List all connections for all Production Items.
/// 
/// SELECT * FROM Utils.Connections_ListConnections()
/// do ##class(Utils.Connections).ListConnectionsFunc().%Display()
Query ListConnections() As %SQLQuery [ SqlProc ]
{
SELECT Name, Utils.Connections_GetConnections(Id) Connections
FROM Ens_Config.Item
WHERE Utils.Connections_GetConnections(Id) IS NOT NULL
}

/// Get all connections for one Production Item.
/// Accepts Item ID or Item Name.
/// 
/// SELECT Utils.Connections_GetConnections(ID)
/// w ##class(Utils.Connections).GetConnections()
ClassMethod GetConnections(id) As %VarString [ SqlProc ]
{
	set formatter = ##class(%JSON.Formatter).%New()
	do formatter.FormatToString(..GetConnectionsJSON(id), .json)
	quit json
}

/// zw ##class(Utils.Connections).GetConnectionsJSON()
ClassMethod GetConnectionsJSON(id) As %DynamicArray
{
	set item = ##class(Ens.Config.Item).%OpenId(id)
	if '$isObject(item) {
		do ##class(Ens.Config.Item).NameExists(##class(Ens.Director).GetActiveProductionName(), id, .hostId)
		set item = ##class(Ens.Config.Item).%OpenId(hostId)	
	}
	
	do $classmethod(item.ClassName, "OnGetConnections", .connections, item)
	if $d(connections) {
		set result = []
		set connection=$ORDER(connections(""))
		while (connection'="") {
			if ##class(Ens.Config.Item).NameExists(item.Production.Name, connection, .connectionId)	{
				do result.%Push(..GetConnectionsJSON(connectionId))
			}
			set connection = $ORDER(connections(connection))
		}
	} else {
		quit item.Name		
	}
	quit {}.%Set(item.Name, result)
}

}
