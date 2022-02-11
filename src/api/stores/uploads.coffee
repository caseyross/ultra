export default uploads = {
	...writable({})
	add: (id) ->
		upload(id).then (data) -> @set(data)