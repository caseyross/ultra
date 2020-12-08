Important Reddit URLs
=====================

Combination Subreddits
----------------------

	[
	{best (default), hot, new, rising, controversial, top, gilded, wiki}				PERSONALIZED FRONT PAGE
	r/popular/{hot (default), new, rising, controversial, top, gilded}					POSTS FROM ANY "GENERAL AUDIENCE" SUBREDDIT
		?geoFilter={regionAbbreviation}													...POPULAR IN REGION
	r/all/{hot (default), new, rising, controversial, top, gilded} 						POSTS FROM DEFAULT SUBREDDITS
	]
		?t={hour/day/week/month/year/all}													...TIME RANGE FOR "top/controversial" SORT
	user/{userName}/m/{multiredditName}												MULTIREDDIT (CUSTOM FEED) CREATED BY USER

Subreddits
----------

	r/{subredditName}/{hot (default), new, rising, controversial, top, gilded, wiki}	SINGLE SUBREDDIT
		?t={hour/day/week/month/year/all} 													...TIME RANGE FOR "top/controversial" SORT
	r/{subredditName}/comments/{postId}/{postSlug}									SINGLE POST
		?sort={confidence (default), top, new, controversial, old, qa}						...SORT METHOD FOR COMMENTS
		?limit={number}																		...MAX NUMBER OF COMMENTS TO SHOW
	r/{subredditName}/comments/{postId}/{postSlug}/{commentId}						SINGLE COMMENT TREE
		?context={number}																	...NUMBER OF ANCESTORS TO SHOW FOR COMMENT TREE

Subreddit Lists
--------------=

	subreddits																			TRENDING SUBREDDITS
	subreddits/new																		NEW SUBREDDITS
	subreddits/mine																		SUBREDDITS I'M FOLLOWING
	subreddits/leaderboard																TOP GROWING SUBREDDITS

Users
-----

	[
	user/{userName}																	POSTS & COMMENTS BY USER; USER PROFILE INFORMATION
	user/{userName}/posts																POSTS BY USER
	user/{userName}/comments															COMMENTS BY USER
	]
		?sort={new (default), hot, top, controversial}
		?t={hour/day/week/month/year/all}													...TIME RANGE FOR "top/controversial" SORT
	user/{userName}/gilded																POSTS & COMMENTS BY USER THAT HAVE BEEN AWARDED
	user/{myUserName}/gilded/given													POSTS & COMMENTS I'VE GIVEN AWARDS TO
	user/{myUserName}/saved															POSTS & COMMENTS I'VE SAVED
	user/{myUserName}/hidden															POSTS I'VE HIDDEN
	user/{myUserName}/upvoted															POSTS & COMMENTS I'VE UPVOTED
	user/{myUserName}/downvoted														POSTS & COMMENTS I'VE DOWNVOTED

Messages
--------

	message/inbox																		ALL MESSAGES, POST/COMMENT REPLIES, & USERNAME MENTIONS
	message/messages																	MESSAGES
	message/messages/{messageId}														SINGLE MESSAGE
	message/unread																		UNREAD MESSAGES
	message/sent																		SENT MESSAGES
	message/templatesose																		WRITE A MESSAGE
	message/selfreply																	REPLIES TO YOUR POSTS
	message/comments																	REPLIES TO YOUR COMMENTS
	message/mentions																	MENTIONS OF YOUR USERNAME IN COMMENTS