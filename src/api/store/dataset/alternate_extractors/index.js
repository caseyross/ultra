// Special extractor functions for API routes that need data restructuring beyond what the general extractor can provide.
import account from './account.coffee'
import account_subreddits_subscribed from './account_subreddits_subscribed.coffee'
import collection from './collection.coffee'
import comment from './comment.coffee'
import global_subreddits_popular from './global_subreddits_popular.coffee'
import post from './post.coffee'
import post_more_replies from './post_more_replies.coffee'
import subreddit_widgets from './subreddit_widgets.coffee'
import user_multireddits_owned_public from './user_multireddits_owned_public.coffee'
import users from './users.coffee'

export default {
	account,
	account_subreddits_subscribed,
	collection,
	comment,
	global_subreddits_popular,
	post,
	post_more_replies,
	subreddit_widgets,
	user_multireddits_owned_public,
	users,
}