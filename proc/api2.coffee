# Docs: https://github.com/reddit-archive/reddit/wiki/OAuth2

RENEW_API_KEY = () ->
	fetch 'https://www.reddit.com/api/v1/access_token',
		method: 'POST'
		headers:
			'Authorization': 'Basic SjZVcUg0a1lRTkFFVWc6'
		body: new URLSearchParams
			grant_type: 'https://oauth.reddit.com/grants/installed_client'
			device_id: 'DO_NOT_TRACK_THIS_DEVICE'
	.then (r) -> r.json()
	.then (json) ->
		cache.api_token_type = json.token_type
		cache.api_token_value = json.access_token
		cache.api_token_expire_time = Date.now() + json.expires_in * 999

API_OP = (http_method, url_path) ->
	# If access token is absent or already expired, block while getting a new one.
	# If access token is expiring soon, don't block the current operation, but pre-emptively request a new token.
	if not cache.api_token_expire_time or Date.now() > cache.api_token_expire_time then await RENEW_API_KEY()
	else if Date.now() > cache.api_token_expire_time - 600000 then RENEW_API_KEY()
	fetch 'https://oauth.reddit.com' + url_path,
		method: http_method
		headers:
			'Authorization': cache.api_token_type + ' ' + cache.api_token_value
	.then (r) -> r.json()

export API_GET = (endpoint, options = {}) ->
	# Delete options with empty values.
	for name, value of options
		if not value and value is not 0 then delete options[name]
	options.raw_json = 1
	API_OP 'GET', endpoint + '?' + (new URLSearchParams(options)).toString()