export default {

	actionId: (type, ...filters) ->
		if filters.length == 0 then [type, ...filters] = type.split(':')
		type = type.toLowerCase()
		filters = filters.map((c) -> (String c).toLowerCase().replace(/^t[1-6]_/, ''))
		return [type, ...filters].join(':')

	datasetId: (type, ...filters) ->
		if filters.length == 0 then [type, ...filters] = type.split(':')
		type = type.toLowerCase()
		filters = filters.map((c) -> (String c).toLowerCase().replace(/^t[1-6]_/, ''))
		return [type, ...filters].join(':')

}