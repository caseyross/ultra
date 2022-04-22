export default ({ client_id, redirect_uri }) ->
	localStorage['api.config.client_id'] = client_id
	localStorage['api.config.redirect_uri'] = redirect_uri