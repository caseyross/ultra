export const REDIRECT_URI = process.env.NODE_ENV === 'production' ? 'localhost:8080' : 'localhost:8080'

export const SCOPES = [
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