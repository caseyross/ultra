OAUTH_SCOPES_ALL = [
	'account'
	'creddits'
	'edit'
	'flair'
	'history'
	'identity'
	'livemanage'
	'modconfig'
	'modcontributors'
	'modflair'
	'modlog'
	'modmail'
	'modothers'
	'modposts'
	'modself'
	'modwiki'
	'mysubreddits'
	'privatemessages'
	'read'
	'report'
	'save'
	'structuredstyles'
	'submit'
	'subscribe'
	'vote'
	'wikiedit'
	'wikiread'
]

export default ({
	clientID,
	defaultOAuthScopes,
	loggingEnabled,
	preloadThreshold,
	redirectURI,
}) ->
	localStorage['api.config.client_id'] = clientID
	localStorage['api.config.default_oauth_scopes'] = (defaultOAuthScopes ? OAUTH_SCOPES_ALL).join(' ')
	localStorage['api.config.logging_enabled'] = if loggingEnabled then 'TRUE' else 'FALSE'
	localStorage['api.config.preload_threshold'] = preloadThreshold ? 0.5
	localStorage['api.config.redirect_uri'] = redirectURI