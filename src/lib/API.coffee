# Docs: https://github.com/reddit-archive/reddit/wiki/OAuth2

RATELIMIT_WINDOW = 600000 # milliseconds
RATELIMIT_QUOTA = 600 # requests

class RateLimitError extends Error
	constructor: (message) ->
		super(message)
		@name = 'RateLimitError'

mark_ratelimit = () ->
	existing_activity = localStorage.api_ratelimit_activity
	updated_activity =
		if existing_activity
			existing_activity + '-' + Date.now()
		else
			Date.now()
	localStorage.api_ratelimit_activity = updated_activity
		
check_ratelimit_wait = () ->
	existing_activity = localStorage.api_ratelimit_activity
	existing_actives =
		if existing_activity
			existing_activity.split('-')
		else
			[]
	current_time = Date.now()
	updated_actives = existing_actives.filter((x) -> (Number(x) + RATELIMIT_WINDOW) > current_time)
	if updated_actives.length != existing_actives.length
		localStorage.api_ratelimit_activity = updated_actives.join('-')
	if updated_actives.length > RATELIMIT_QUOTA
		(Number(updated_actives[0]) + RATELIMIT_WINDOW) - Date.now()
	else
		0

renew_api_key = () ->
	fetch 'https://www.reddit.com/api/v1/access_token',
		method: 'POST'
		headers:
			'Authorization': 'Basic SjZVcUg0a1lRTkFFVWc6'
		body: new URLSearchParams
			grant_type: 'https://oauth.reddit.com/grants/installed_client'
			device_id: 'DO_NOT_TRACK_THIS_DEVICE'
	.then (response) -> response.json()
	.then (json) ->
		localStorage.api_key_type = json.token_type
		localStorage.api_key_value = json.access_token
		localStorage.api_key_expiration = Date.now() + json.expires_in * 1000

call_api = ({ method, path, body }) ->
	ratelimit_wait = check_ratelimit_wait()
	if ratelimit_wait < 1
		# If API key is absent or expired, renew it.
		if (not localStorage.api_key_expiration) or (Date.now() > localStorage.api_key_expiration)
			await renew_api_key()
		mark_ratelimit()
		fetch 'https://oauth.reddit.com' + path,
			method: method
			headers:
				'Authorization': localStorage.api_key_type + ' ' + localStorage.api_key_value
			body: body
		.then (response) ->
			response.json()
		.finally () ->
			# If API key is expiring soon, asynchronously renew it.
			if Date.now() > (localStorage.api_key_expiration - 600000)
				renew_api_key()
	else
		Promise.reject(new RateLimitError("Request would exceed Reddit API frequency limit. Wait #{ratelimit_wait // 1000} seconds."))

window.API =
	get: (url, options = {}) ->
		# Delete keys with empty values.
		for name, value of options
			if not value and value isnt 0 then delete options[name]
		options.raw_json = 1
		call_api({
			method: 'GET',
			path: url + '?' + (new URLSearchParams(options)).toString()
		})
	post: (url, content = {}) ->
		# Delete keys with empty values.
		for name, value of content
			if not value and value isnt 0 then delete content[name]
		call_api({
			method: 'POST',
			path: url,
			body: new URLSearchParams(content)
		})