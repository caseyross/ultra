export default ({
	clientID,
	debug,
	preloadThreshold,
	redirectURI,
}) ->
	localStorage['api.config.client_id'] = clientID
	localStorage['api.config.debug'] = if debug then 'TRUE' else 'FALSE'
	localStorage['api.config.preload_threshold'] = preloadThreshold ? 0.5
	localStorage['api.config.redirect_uri'] = redirectURI