import extract from './extract.coffee'

// Special extractor functions for API routes that need data restructuring beyond what the general extractor can provide.
import current_user_messages from './current_user_messages.coffee'
import post from './post.coffee'
import post_more_replies from './post_more_replies.coffee'
import subreddits_popular from './subreddits_popular.coffee'
import users from './users.coffee'

export default {
	GENERAL: extract,
	current_user_messages,
	post,
	post_more_replies,
	subreddits_popular,
	users,
}