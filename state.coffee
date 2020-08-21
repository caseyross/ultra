import { writable } from 'svelte/store'
import { sync_url } from './network.coffee'

default_selected = {
	post: {}
	comment: {}
	inspect_mode: ''
}
export selected = writable default_selected
_feed = writable window.feed
export feed =
	subscribe: _feed.subscribe
	go: (new_url) ->
		selected.set default_selected
		_feed.set sync_url(new_url)