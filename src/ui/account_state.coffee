# total size of localStorage data should not exceed 5MB to stay within typical browser limits
MAX_READ_POSTS = 50_000 # @ 10 chars per * 2B per char = 1MB max; 36^(9 data chars per ID) covers sequential posts IDs as far as 101 trillion

import api from '../api/index.js'

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