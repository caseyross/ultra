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

###
# Reddit permits up to 60 requests per minute for OAuth2 clients.
window.setInterval
	() ->
		if cache.api_requests
		if cache.api_requests_waiting
			for promise in 
	100
UNDER_RATE_LIMIT = () ->
	if cache.api_requests_waiting and cache.api_requests_waiting.length > 0
		permission = new Promise (f, r) -> 
		cache.api_rate
	return Promise.resolve()
###

API_OP = (http_method, url_path, request_body) ->
	# If access token is absent or already expired, block while getting a new one.
	# If access token is expiring soon, don't block the current operation, but pre-emptively request a new token.
	if not cache.api_token_expire_time or Date.now() > cache.api_token_expire_time then await RENEW_API_KEY()
	else if Date.now() > cache.api_token_expire_time - 600000 then RENEW_API_KEY()
	#await UNDER_RATE_LIMIT()
	fetch 'https://oauth.reddit.com' + url_path,
		method: http_method
		headers:
			'Authorization': cache.api_token_type + ' ' + cache.api_token_value
		body: request_body
	.then (r) -> r.json()

export API_GET = (endpoint, options = {}) ->
	# Delete options with empty values.
	for name, value of options
		if not value and value isnt 0 then delete options[name]
	options.raw_json = 1
	API_OP 'GET', endpoint + '?' + (new URLSearchParams(options)).toString()

###
export API_POST = (endpoint, content = {}) ->
	# Delete content keys with empty values.
	for name, value of content
		if not value and value isnt 0 then delete content[name]
	API_OP 'POST', endpoint, new URLSearchParams(content)
###