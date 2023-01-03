ID = (...vars) ->
	if vars.length is 1 then vars = vars.split(':')
	return vars.map((v) -> (String v).toLowerCase()).join(':')
ID.type = (id) ->
	id.split(':')[0]
ID.var = (id, index) ->
	id.split(':')[index]
ID.varArray = (id) ->
	id.split(':')

export default ID