Class Utils.SQL [ Abstract ]
{

/// set sql=##class(Utils.SQL).getSQL("Comments",0,.desc) write !,sql,!!,desc
ClassMethod getSQL(name As %String, removeNL = {$$$NO}, ByRef Description) As %String
{
	#dim sc As %Status = $$$OK
	
	set class = $case($l(name, ":"), 2:$p(name, ":"), :$classname())
	set queryName = $p(name, ":", *)
	set Description=""
		
	if ##class(%Dictionary.QueryDefinition).IDKEYExists(class, queryName) {
		set query = ##class(%Dictionary.QueryDefinition).IDKEYOpen(class, queryName,,.sc)
		throw:$$$ISERR(sc) ##class(%Exception.StatusException).CreateFromStatus(sc)
		set sql = query.SqlQuery
		set Description=query.Description
	} elseif ##class(%Dictionary.XDataDefinition).IDKEYExists(class, queryName) {
		set stream = ##class(%Stream.TmpCharacter).%New()
		for i=1:1:$$$comMemberKeyGet(class,$$$cCLASSxdata,queryName,$$$cXDATAdata) {
			do stream.WriteLine($$$comMemberArrayGet(class,$$$cCLASSxdata,queryName,$$$cXDATAdata,i))
		}
		set sql = stream.Read($$$MaxLocalLength)
		set Description=$$$comMemberKeyGet(class,$$$cCLASSxdata,queryName,$$$cXDATAdescription)
		
	} else {
		throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, $$$FormatText("Class %1 does not have a Query or XData element named %2"), class, queryName))
	}
	
	set:(removeNL = $$$YES) sql = $replace(sql, $$$NL, " ")
	return sql
}

/// BS, BP, BO settings
Query ProductionClassesSettings(production) As %Query
{
SELECT
  prop.parent Class,
  prop.name Setting,
  --TRIM('"' FROM prop.InitialExpression) Default,
  prop.Description Description
FROM "%Dictionary".PropertyDefinition prop
  JOIN "%Dictionary".CompiledParameter par ON par.parent = prop.parent AND par.Name = 'SETTINGS'
  JOIN "%Dictionary".CompiledClass cls ON prop.parent = cls.Name
WHERE cls.Name LIKE ? and
      par."_Default" LIKE '%' || prop.Name || '%'
ORDER BY Class, Setting
}

/// test query
/// stored in xdata
XData Comments [ MimeType = application/yaml ]
{
SELECT
  c.cid                    AS Id,
  c.nid                    AS Nid,
  FROM_UNIXTIME(c.created) AS Created,
  c.uid                    AS Uid,
  IFNULL(vv.average, 0)        AS AvgVote,
  IFNULL(vv.amount, 0)     AS VotesAmount,
  body.comment_body_value  AS Text,
  'comment'                AS Type
FROM comment AS c
  LEFT OUTER JOIN node ON node.nid = c.nid
  INNER JOIN field_data_field_forum_ref AS ref ON ref.entity_id = node.nid
  LEFT OUTER JOIN field_data_comment_body AS body ON c.cid = body.entity_id
  LEFT OUTER JOIN (SELECT
                     entity_id,
                     SUM(value) AS average, 
                     COUNT (1) AS amount
                   FROM votingapi_vote
                   WHERE entity_type = 'comment'
                   GROUP BY entity_id) AS vv ON vv.entity_id = c.cid
WHERE
  node.status = 1
  AND node.type IN ('code_package', 'documentation', 'learning_track', 'video', 'post')
GROUP BY c.cid
}

}

