import { get } from '../infra/requests.coffee'

# Returns a Promise that resolves with the data requested
export default (id) ->

	switch id.type

		when 't1'     # Comment tree
			return
		when 't1x'    # More comments
			return
		when 't2fcv'  # User contributing view
			return
		when 't2fmv'  # User moderating view
			return
		when 't2fv'   # User subscriptions view
			return
		when 't2i'    # User information
			return
		when 't2ip'   # User preferences
			return
		when 't2iuav' # User trusted view
			return
		when 't2iubv' # User blocked view
			return
		when 't2iucv' # User contacted view
			return
		when 't2iufi' # User friend notes
			return
		when 't2iufv' # User friended view
			return
		when 't2mi'   # User moderation history
			return
		when 't2sv'   # User search view
			return
		when 't2snv'  # User ranked novelty view
			return
		when 't2spv'  # User ranked popularity view
			return
		when 't2v'    # User view
			return
		when 't2xi'   # User multireddits
			return
		when 't3'     # Post
			GET 'comments/' + id,
				{
					
				}
				.then (data) ->
					[posts, comments] = data.map (x) -> listing
					posts[0].replies = comments.map (comment) -> comment.id
		when 't3c'    # Post collection
			return
		when 't3dv'   # Post duplicates view
			return
		when 't3lc'   # Live post contributors
			return
		when 't3ldv'  # Live post discussions view
			return
		when 't3li'   # Live post information
			return
		when 't3liu'  # Live post update information
			return
		when 't3sv'   # Post search view
			return
		when 't3w'    # Wiki page
			return
		when 't3wdv'  # Wiki page discussions view
			return
		when 't3wp'   # Wiki page permissions
			return
		when 't3wrv'  # Wiki page revisions view
			return
		when 't4'     # Message
			return
		when 't4c'    # Chat message
			return
		when 't4cv'   # Chat messages view
			return
		when 't4m'    # Modmail conversation
			return
		when 't4mv'   # Modmail conversations view
			return
		when 't4v'    # Messages view
			return
		when 't5e'    # Subreddit emotes
			return
		when 't5fp'   # Subreddit post flairs
			return
		when 't5fu'   # Subreddit user flairs
			return
		when 't5g'    # Subreddit widgets
			return
		when 't5i'    # Subreddit information
			return
		when 't5ir'   # Subreddit rules
			return
		when 't5irp'  # Subreddit post requirements
			return
		when 't5irpt' # Subreddit post submission text
			return
		when 't5it'   # Subreddit traffic information
			return
		when 't5iub'  # Subreddit banned users
			return
		when 't5iubw' # Subreddit wikibanned users
			return
		when 't5iuc'  # Subreddit contributors
			return
		when 't5iucw' # Subreddit wiki contributors
			return
		when 't5ium'  # Subreddit moderators
			return
		when 't5iuu'  # Subreddit muted users
			return
		when 't5mev'  # Subreddit edits view
			return
		when 't5mlv'  # Subreddit mod log view
			return
		when 't5mqv'  # Subreddit mod queue view
			return
		when 't5mrv'  # Subreddit reports view
			return
		when 't5msv'  # Subreddit spam view
			return
		when 't5muv'  # Subreddit mod unactioned view
			return
		when 't5sdv'  # Subreddit description search view
			return
		when 't5s'    # Subreddit search
			return
		when 't5snv'  # Subreddit ranked novelty view
			return
		when 't5spv'  # Subreddit ranked popularity view
			return
		when 't5v'    # Subreddit view
			[name, sort, limit] = shortId
			endpoint = 'r/' + name + '/' + sort
			GET endpoint, {
				sort: sort
				limit: limit
			}
				.then (data) -> listing
		when 't5w'    # Subreddit wiki page
			return
		when 't5we'   # Subreddit wiki page edits
			return
		when 't5xi'   # Multireddit information
			return
		when 't5xv'   # Multireddit view
			return
		when 't6'     # Award
			return