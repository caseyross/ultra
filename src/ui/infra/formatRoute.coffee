import api from '../../api/index.js'

export default (id, options = { next: [], prev: [] }) ->
	filters = api.parse.datasetFilters(id)
	switch api.parse.datasetType(id)
		when 'post'
			post_short_id = filters[0]
			path = "/post/#{post_short_id}"
			query = new URLSearchParams()
			if options.next.length
				query.set('next', options.next)
			if options.prev.length
				query.set('prev', options.prev)
			return path + '?' + query
		else
			path = '/'
			return path