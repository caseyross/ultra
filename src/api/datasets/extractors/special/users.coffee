import format from '../../../infra/format.coffee'

export default (rawData) ->
	result =
		main: null
		sub: []
	for user_fullname, user of rawData
		result.sub.push({
			id: format.datasetId('user', user.name)
			data: user
			partial: true
		})
	result.main =
		id: null
		data: result.sub.map((dataset) -> dataset.id)
	return result