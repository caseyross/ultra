export configure = ({
	clientID,
	debug,
	preloadThreshold,
	redirectURI,
}) ->
	if clientID?
		localStorage['api.config.client_id'] = clientID
	localStorage['api.config.debug'] = if debug? then 'TRUE' else 'FALSE'
	localStorage['api.config.preload_threshold'] = preloadThreshold ? 0.5
	if redirectURI?
		localStorage['api.config.redirect_uri'] = redirectURI

export getClientID = ->
	localStorage['api.config.client_id']

export hasClientID = ->
	localStorage['api.config.client_id']