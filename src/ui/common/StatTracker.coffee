# total size of stored data should not exceed 4MB to stay within typical browser limits
MAX_POSTS_READ = 10000 # @ 20B per = 200MB

export default {

	# could be "optimized" any number of ways. however, we care mostly about read performance, and this is the fastest possible read implementation. furthermore, a more complicated algo won't give big enough gains elsewhere to justify the complexity.
	check_post_read: (id) ->
		localStorage['stats.read.posts']?.includes(id)
	mark_post_read: (id) ->
		localStorage['stats.read.posts'] =
			String(id).padStart(10, ' ') + # use constant unit size so string can be pruned without having to parse it
				if localStorage['stats.read.posts']
					if localStorage['stats.read.posts'].length > (10 * MAX_POSTS_READ)
						localStorage['stats.read.posts'][0..-10]
					else
						localStorage['stats.read.posts']
				else
					''

}