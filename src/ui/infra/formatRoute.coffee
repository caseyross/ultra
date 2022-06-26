import api from '../../api/index.js'

export default (id) ->
	filters = api.parse.datasetFilters(id)
	switch api.parse.datasetType(id)
		when 'post'
			post_short_id = filters[0]
			path = "/post/#{post_short_id}"
			return path
		else
			path = '/'
			return path