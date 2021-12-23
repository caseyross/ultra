export const OAUTH_REDIRECT_URI = process.env.NODE_ENV === 'production' ? 'https://localhost:8080' : 'https://localhost:8080'
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