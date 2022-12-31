import extract from './extract.coffee'

// Special extractor functions for API routes that need data restructuring beyond what the general extractor can provide.
import collection from './collection.coffee'
import current_user from './current_user.coffee'
import current_user_messages from './current_user_messages.coffee'
import global_subreddits_popular from './global_subreddits_popular.coffee'
import post from './post.coffee'
import post_more_replies from './post_more_replies.coffee'
import users from './users.coffee'
import user_public_multireddits from './user_public_multireddits.coffee'

export default {
	GENERAL: extract,
	collection,
	current_user,
	current_user_messages,
	global_subreddits_popular,
	post,
	post_more_replies,
	users,
	user_public_multireddits,
}