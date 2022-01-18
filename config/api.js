export const API_RATELIMIT_PERIOD_LENGTH = Date.minutes(10)
export const API_RATELIMIT_REQUESTS_PER_PERIOD = 600
export const API_OAUTH_USER_SCOPES_REQUESTED = [
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
export const API_AFTERLOGIN_REDIRECT_URL = process.env.NODE_ENV === 'production' ? 'https://localhost:8080' : 'https://localhost:8080'