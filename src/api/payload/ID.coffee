export default {

	action: (prefix, ...body) ->
		if body.length == 0 then [prefix, ...body] = prefix.split(':')
		prefix = prefix.toLowerCase()
		body = body.filter((x) -> x?).map((x) -> (String x).toLowerCase().replace(/^t[1-6]_/, ''))
		return prefix + ':' + body.join(':')

	dataset: (prefix, ...body) ->
		if body.length == 0 then [prefix, ...body] = prefix.split(':')
		prefix = prefix.toLowerCase()
		body = body.filter((x) -> x?).map((x) -> (String x).toLowerCase().replace(/^t[1-6]_/, ''))
		return prefix + ':' + body.join(':')
	
	prefix: (id) ->
		id.split(':')[0]

	body: (id) ->
		id.split(':')[1..]

}