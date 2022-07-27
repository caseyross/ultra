import api from '../../api/index.js'

export default (id) ->
	body = api.ID.body(id)
	switch api.ID.prefix(id)
		when 'post'
			post_short_id = body[0]
			path = "/post/#{post_short_id}"
			return path
		else
			path = '/'
			return path