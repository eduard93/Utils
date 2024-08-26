/// Recursively unwraps roles.
/// Accounts for circular dependencies and repeats.
Class Utils.Roles
{

/// roles: comma-separated string of roles
/// showResources: show resources in addition to roles.
/// do ##class(Utils.Roles).Display
ClassMethod Display(roles As %String, showResources As %Boolean = {$$$NO})
{
	new $namespace
	set $namespace = "%SYS"
	set roles = $lfs(roles)
	set i=0
	while i<$ll(roles) {
		do $i(i)
		set role = $lg(roles, i)
		continue:$d(processed(role))=1
		write "Current role: ", role,!
		
		write "Grants roles: "
		set sc = ##class(Security.Roles).Get(role, .p)
		for j=1:1:$l($g(p("GrantedRoles")),",") {
			set grantedrole = $p(p("GrantedRoles"),",", j)
			continue:grantedrole=""
			continue:$lf(roles, grantedrole)
			
			write grantedrole, ", "	
			
			set roles = roles _ $lb(grantedrole)
		}
		
		write:showResources !, "Grants resources: ", p("Resources")
		write !
	}
}

}
