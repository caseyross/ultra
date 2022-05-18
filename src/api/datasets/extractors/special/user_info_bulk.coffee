import format from '../../../infra/format.coffee'

export default (rawData) ->
	result =
		main: null
		sub: []
	for user_fullname, user_info of rawData
		result.sub.push({
			id: format.datasetId('user_info', user_info.name)
			data: user_info
			partial: true
		})
	result.main =
		id: null
		data: result.sub.map((dataset) -> dataset.id)
	return result