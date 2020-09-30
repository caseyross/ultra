window.ls = window.localStorage

###
write_state_to_url = (state) ->
	new_url = url_from_state state
	history.pushState {}, new_url, new_url
###

import { state_from_url } from '/proc/url.coffee'
import { LIST, LIST_DESCRIPTION, POST_AND_COMMENTS } from '/proc/api.coffee'

state = state_from_url()
data =
	LIST: LIST {
		id: state.list_id,
		page_size: state.list_page_size,
		predecessor_object_id: state.list_predecessor_object_id,
		rank_by: state.list_rank_by,
		time_period: state.list_time_period
	}
	LIST_DESCRIPTION: LIST_DESCRIPTION { id: state.list_id }
	OBJECT: if state.object_id then POST_AND_COMMENTS { post_id: state.object_id } else new Promise (f, r) -> {}

import App from '/app.svelte'
new App({
	target: document.body
	props: {
		state,
		data
	}
})

###
window.addEventListener 'popstate', () ->
	initialize_state()
###