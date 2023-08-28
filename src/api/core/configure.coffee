export configure = ({
	clientID,
	debug,
	preloadThreshold,
	redirectURI,
}) ->
	if clientID?
		localStorage['api.config.client_id'] = clientID
	localStorage['api.config.debug'] = debug?
	localStorage['api.config.preload_threshold'] = preloadThreshold ? 0.5
	if redirectURI?
		localStorage['api.config.redirect_uri'] = redirectURI

export hasClientID = ->
	localStorage['api.config.client_id']?