export const OAUTH_REDIRECT_URI = process.env.NODE_ENV === 'production' ? 'localhost:8080' : 'localhost:8080'
export const OAUTH_TARGET_SCOPES = [
	'edit',
	'flair',
	'history',
	'identity',
	'mysubreddits',
	'privatemessages',
	'read',
	'report',
	'save',
	'structuredstyles',
	'submit',
	'subscribe',
	'vote',
	'wikiread'
]
export const RATELIMIT_PERIOD = 600000 // 10 minutes
export const RATELIMIT_QUOTA = 600