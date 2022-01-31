export default (id) ->

	if $loading[id]
		return

	[type, shortId] = id.split('_')
	switch type
		
		when 't1'     # Comment
		when 't1x'    # More comments
		when 't2fcv'  # User contributing view
		when 't2fmv'  # User moderating view
		when 't2fv'   # User subscriptions view
		when 't2i'    # User information
		when 't2ip'   # User preferences
		when 't2iuav' # User trusted view
		when 't2iubv' # User blocked view
		when 't2iucv' # User contacted view
		when 't2iufi' # User friend notes
		when 't2iufv' # User friended view
		when 't2mi'   # User moderation history
		when 't2sv'   # User search view
		when 't2snv'  # User ranked novelty view
		when 't2spv'  # User ranked popularity view
		when 't2v'    # User view
		when 't2xi'   # User multireddits
		when 't3'     # Post
		when 't3c'    # Post collection
		when 't3dv'   # Post duplicates view
		when 't3l'    # Live post
		when 't3lc'   # Live post contributors
		when 't3ldv'  # Live post discussions view
		when 't3li'   # Live post information
		when 't3liu'  # Live post update information
		when 't3sv'   # Post search view
		when 't3w'    # Wiki page
		when 't3wdv'  # Wiki page discussions view
		when 't3wp'   # Wiki page permissions
		when 't3wrv'  # Wiki page revisions view
		when 't4'     # Message
		when 't4c'    # Chat message
		when 't4cv'   # Chat messages view
		when 't4m'    # Modmail conversation
		when 't4mv'   # Modmail conversations view
		when 't4v'    # Messages view
		when 't5e'    # Subreddit emotes
		when 't5fp'   # Subreddit post flairs
		when 't5fu'   # Subreddit user flairs
		when 't5g'    # Subreddit widgets
		when 't5i'    # Subreddit information
		when 't5ir'   # Subreddit rules
		when 't5irp'  # Subreddit post requirements
		when 't5irpt' # Subreddit post submission text
		when 't5it'   # Subreddit traffic information
		when 't5iub'  # Subreddit banned users
		when 't5iubw' # Subreddit wikibanned users
		when 't5iuc'  # Subreddit contributors
		when 't5iucw' # Subreddit wiki contributors
		when 't5ium'  # Subreddit moderators
		when 't5iuu'  # Subreddit muted users
		when 't5mev'  # Subreddit edits view
		when 't5mqv'  # Subreddit mod queue view
		when 't5mrv'  # Subreddit reports view
		when 't5msv'  # Subreddit spam view
		when 't5muv'  # Subreddit mod unactioned view
		when 't5sdv'  # Subreddit description search view
		when 't5s'    # Subreddit search
		when 't5snv'  # Subreddit ranked novelty view
		when 't5spv'  # Subreddit ranked popularity view
		when 't5v'    # Subreddit view
		when 't5w'    # Subreddit wiki pages
		when 't5we'   # Subreddit wiki page edits
		when 't5xi'   # Multireddit information
		when 't5xv'   # Multireddit view
		when 't6'     # Award