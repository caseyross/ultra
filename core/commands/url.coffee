import { objectsFromListingResult } from './parsing.coffee'

export default {
	'load url data': (url) ->
		segments = url.pathname.split('/')[1..]
		fragment = url.hash[1..]
		params = new URLSearchParams url.search
		# Check prefixed paths
		switch segments[0]
			when 'c'
				route: 'COMMENT'
				data:
					id: segments[1].toCommentId()
			when 'p'
				route: 'POST'
				data:
					id: segments[1].toPostId()
					sort: fragment
					stream: switch
						when params.has 'r'
							type: 'BOARD'
							name: params.get 'r'
						when params.has 'u'
							type: 'USER'
							name: params.get 'u'
						else
							null
			when 'r'
				route: 'BOARD'
				data:
					name: segments[1].toBoardName()
					sort: fragment
			when 'u'
				route: 'USER'
				data:
					name: segments[1].toUserName()
					sort: fragment
			else
				# Check non-prefixed paths
				switch segments[0]
					when ''
					else
						route: 'BOARD'
						data:
							name: segments[0].toBoardName()
							sort: fragment
		for post in page
			command {
				type: 'begin api request'
				method: 'GET'
				path: '/comments/' + post.shortId
				query:
					sort: 'top'
				key: post.longId
				parse: (result) -> results.map(objectsFromListingResult).fold({}, (a, b) -> Object.assign(a, b))
			}
		command {
			type: 'begin api request'
			method: 'GET'
			path: '/r/' + srName + '/about'
			key: 'about_' + srName
		}
		command {
			type: 'begin api request'
			method: 'GET'
			path: '/api/v1/' + srName + '/emojis/all'
			key: 'emojis_' + srName
		}
		command {
			type: 'begin api request'
			method: 'GET'
			path: '/r/' + srName + '/api/widgets'
			key: 'widgets_' + srName
		}
		{
			routing:
				route: ''
		}
}