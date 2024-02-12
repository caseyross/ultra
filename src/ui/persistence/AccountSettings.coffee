# total size of localStorage data should not exceed 5MB to stay within typical browser limits
MAX_READ_POSTS = 50_000 # @ 10 chars per * 2B per char = 1MB max; 36^(9 data chars per ID) covers sequential posts IDs as far as 101 trillion

import api from '../../api/index.js'

account_name = api.getUser() or 'none'
format_key = (key_name) -> "ui.account<#{account_name}>.#{key_name}"

export default {

	# could be "optimized" any number of ways. however, we care mostly about read performance, and this is the fastest possible read implementation. furthermore, a more complicated algo won't give big enough gains elsewhere to justify the complexity.
	check_post_read: (id) ->
		localStorage[format_key('read_posts')]?.includes(id)
	mark_post_read: (id) ->
		key = format_key('read_posts')
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
		Number(localStorage[format_key('media_volume')]) or 0
	set_media_volume: (volume) ->
		localStorage[format_key('media_volume')] = volume

	get_media_premute_volume: ->
		Number(localStorage[format_key('media_premute_volume')]) or 0
	set_media_premute_volume: (volume) ->
		localStorage[format_key('media_premute_volume')] = volume

}