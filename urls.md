Important Reddit URLs
=====================

Combination Subreddits
----------------------

	[
	{best (default), hot, new, rising, controversial, top, gilded, wiki}				PERSONALIZED FRONT PAGE
	r/popular/{hot (default), new, rising, controversial, top, gilded}					POSTS FROM ANY "GENERAL AUDIENCE" SUBREDDIT
		?geo_filter={region_abbreviation}													...POPULAR IN REGION
	r/all/{hot (default), new, rising, controversial, top, gilded} 						POSTS FROM DEFAULT SUBREDDITS
	]
		?t={hour/day/week/month/year/all}													...TIME RANGE FOR "top/controversial" SORT
	user/{user_name}/m/{multireddit_name}												MULTIREDDIT (CUSTOM FEED) CREATED BY USER

Subreddits
----------

	r/{subreddit_name}/{hot (default), new, rising, controversial, top, gilded, wiki}	SINGLE SUBREDDIT
		?t={hour/day/week/month/year/all} 													...TIME RANGE FOR "top/controversial" SORT
	r/{subreddit_name}/comments/{post_id}/{post_slug}									SINGLE POST
		?sort={confidence (default), top, new, controversial, old, qa}						...SORT METHOD FOR COMMENTS
		?limit={number}																		...MAX NUMBER OF COMMENTS TO SHOW
	r/{subreddit_name}/comments/{post_id}/{post_slug}/{comment_id}						SINGLE COMMENT TREE
		?context={number}																	...NUMBER OF ANCESTORS TO SHOW FOR COMMENT TREE

Subreddit Meta
--------------

	r/subreddits																		TRENDING SUBREDDITS
	r/subreddits/new																	NEW SUBREDDITS
	r/subreddits/mine																	SUBREDDITS I'M FOLLOWING

Users
-----

	[
	user/{user_name}																	POSTS & COMMENTS BY USER; USER PROFILE INFORMATION
	user/{user_name}/posts																POSTS BY USER
	user/{user_name}/comments															COMMENTS BY USER
	]
		?sort={new (default), hot, top, controversial}
		?t={hour/day/week/month/year/all}													...TIME RANGE FOR "top/controversial" SORT
	user/{user_name}/gilded																POSTS & COMMENTS BY USER THAT HAVE BEEN AWARDED
	user/{my_user_name}/gilded/given													POSTS & COMMENTS I'VE GIVEN AWARDS TO
	user/{my_user_name}/saved															POSTS & COMMENTS I'VE SAVED
	user/{my_user_name}/hidden															POSTS I'VE HIDDEN
	user/{my_user_name}/upvoted															POSTS & COMMENTS I'VE UPVOTED
	user/{my_user_name}/downvoted														POSTS & COMMENTS I'VE DOWNVOTED

Messages
--------

	message/inbox																		ALL MESSAGES
	message/messages																	SAME AS "/inbox"?
	message/messages/{message_id}														SINGLE MESSAGE
	message/unread																		UNREAD MESSAGES
	message/sent																		SENT MESSAGES
	message/compose																		WRITE A MESSAGE
	message/selfreply																	REPLIES TO YOUR POSTS
	message/comments																	REPLIES TO YOUR COMMENTS
	message/mentions																	MENTIONS OF YOUR USERNAME IN COMMENTS