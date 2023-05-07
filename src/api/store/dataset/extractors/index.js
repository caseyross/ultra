import extract from './extract.coffee'

// Special extractor functions for API routes that need data restructuring beyond what the general extractor can provide.
import account from './account.coffee'
import collection from './collection.coffee'
import global_subreddits_popular from './global_subreddits_popular.coffee'
import post from './post.coffee'
import post_more_replies from './post_more_replies.coffee'
import subreddit_widgets from './subreddit_widgets.coffee'
import users from './users.coffee'
import user_public_multireddits from './user_public_multireddits.coffee'

export default {
	GENERAL: extract,
	account,
	collection,
	global_subreddits_popular,
	post,
	post_more_replies,
	subreddit_widgets,
	users,
	user_public_multireddits,
}