# total size of localStorage data should not exceed 5MB to stay within typical browser limits
MAX_READ_POSTS = 50_000 # @ 10 chars per * 2B per char = 1MB max; 36^(9 data chars per ID) covers sequential posts IDs as far as 101 trillion

import api from '../../api/index.js'

account_name = api.getUser() or 'none'
key_prefix = "ui.account<#{account_name}>."

export default {

	# could be "optimized" any number of ways. however, we care mostly about read performance, and this is the fastest possible read implementation. furthermore, a more complicated algo won't give big enough gains elsewhere to justify the complexity.
	check_post_read: (id) ->
		key = key_prefix + 'read_posts'
		localStorage[key]?.includes(id)
	mark_post_read: (id) ->
		key = key_prefix + 'read_posts'
		localStorage[key] =
			String(id).padStart(10, ' ') + # use constant unit size so string can be pruned without having to parse it
				if localStorage[key]
					if localStorage[key].length >= (10 * MAX_READ_POSTS)
						localStorage[key][0...-10] # drop oldest
					else
						localStorage[key]
				else
					''

	# reason for keeping track of this is to be able to sort the user's subscriptions in order of likely preference
	get_subreddit_viewcount: (name) ->
		key = key_prefix + 'subreddit_viewcount'
		index = localStorage[key]?.indexOf(name + ':')
		if index == undefined or index < 0
			return 0
		else
			endIndex = localStorage[key].indexOf(' ', index + 3)
			return Number(localStorage[key].slice(index + name.length + 1, endIndex))
	get_subreddit_viewcounts: ->
		key = key_prefix + 'subreddit_viewcount'
		if !localStorage[key]?
			return []
		else
			viewcounts = localStorage[key].split(' ').map((x) ->
				[name, count] = x.split(':')
				return {
					name,
					count,
				}
			)
			viewcounts.sort((a, b) -> b.count - a.count)
			return viewcounts
	increment_subreddit_viewcount: (name) ->
		key = key_prefix + 'subreddit_viewcount'
		index = localStorage[key]?.indexOf(name + ':')
		if index == undefined
			localStorage[key] = name + ':1'
		else if index < 0
			localStorage[key] = localStorage[key] + ' ' + name + ':1'
		else
			endIndex = localStorage[key].indexOf(' ', index + 3)
			if endIndex < 0
				endIndex = Infinity
			count = Number(localStorage[key].slice(index + name.length + 1, endIndex))
			localStorage[key] =
				localStorage[key].slice(0, index + name.length + 1) +
				(count + 1) +
				localStorage[key].slice(endIndex)

	get_media_volume: ->
		key = key_prefix + 'media_volume'
		Number(localStorage[key]) or 0
	set_media_volume: (volume) ->
		key = key_prefix + 'media_volume'
		localStorage[key] = volume

	get_media_premute_volume: ->
		key = key_prefix + 'media_premute_volume'
		Number(localStorage[key]) or 0
	set_media_premute_volume: (volume) ->
		key = key_prefix + 'media_premute_volume'
		localStorage[key] = volume

}