import { FETCH_FEED_DATA, FETCH_FEED_METADATA } from '/proc/network.coffee'
load_feed = (new_url = '') ->
	# Write new URL (if provided) to browser
	if new_url
		history.pushState({}, new_url, new_url)
	# Read feed configuration from URL
	path = window.location.pathname.split('/')
	params = new URLSearchParams window.location.search[1...]
	# Construct tabula rasa state
	state =
		feed: {
			...(switch path[1]
				when 'u', 'user'
					type: 'u'
					sort: params.get('sort') || 'new'
					filter: params.get('t') || ''
				else
					type: 'r'
					sort: if path[2] then params.get('sort') || path[3] || 'hot' else 'best'
					filter: switch params.get('sort') || path[3]
						when 'top'
							params.get('t') || 'day'
						else
							params.get('geo_filter') || 'GLOBAL'
			)
			name: path[2] || ''
			pagesize: params.get('limit') || 25
			after: params.get('after') || ''
			seen: params.get('count') || 0
			read: new Set()
		},
		item:
			id: ''
			content:
				type: 'empty'
		comment:
			id: ''
		inspect: false
	# Request Reddit content
	state.feed.DATA = FETCH_FEED_DATA(state.feed)
	state.feed.METADATA = FETCH_FEED_METADATA(state.feed)
	# 
	return state

import App from '/app.svelte'
new App({
	target: document.body
	props: {
		state: load_feed(),
		load_feed
	}
})