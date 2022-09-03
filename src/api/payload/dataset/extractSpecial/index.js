import current_user_messages from './current_user_messages.coffee'
import post from './post.coffee'
import post_more_replies from './post_more_replies.coffee'
import subreddits_popular from './subreddits_popular.coffee'
import users from './users.coffee'

// Extractor functions for API routes that need data restructuring beyond what the general extractor can provide.
// NOTE: Expect side effects - in particular, input data modification - in all special extractors.
export default {
	current_user_messages,
	post,
	post_more_replies,
	subreddits_popular,
	users,
}