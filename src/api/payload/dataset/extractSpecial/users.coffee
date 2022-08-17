import ID from '../../ID.coffee'

export default (rawData) ->
	result =
		main: null
		sub: []
	for user_fullname, user of rawData
		result.sub.push({
			id: ID.dataset('user', user.name)
			data: user
			partial: true
		})
	result.main =
		id: null
		data: result.sub.map((dataset) -> ID.bodyString(dataset.id))
	return result