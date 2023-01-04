ID = (...vars) ->
	# Handle case of entire ID being passed as a single string.
	if vars.length is 1 then vars = vars.split(':')
	# Remove any trailing arguments that are null or undefined.
	i = vars.length - 1
	while i > 0 and !vars[i]?
		vars.pop()
		i = i - 1
	# Lowercase and join remaining arguments.
	return vars.map((v) -> (String v).toLowerCase()).join(':')

ID.type = (id) ->
	id.split(':')[0]
ID.var = (id, index) ->
	id.split(':')[index]
ID.varArray = (id) ->
	id.split(':')

export default ID