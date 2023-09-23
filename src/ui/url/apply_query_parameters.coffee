export default (query) ->
	url = new URL(location)
	params = new URLSearchParams(url.search)
	for key, value of query
		params.set(key, value)
	url.search = params
	return url