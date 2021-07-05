import GenericThingArray from './GenericThingArray.coffee'

# Docs: https://github.com/reddit-archive/reddit/wiki/OAuth2

searchParams = new URLSearchParams location.search
if searchParams.get('code')
	localStorage.api_key_exchange_token = searchParams.get('code')
	localStorage.api_key_expiration = 0
else if searchParams.get('logout')
	delete localStorage.api_key_refresh_token
	localStorage.api_key_expiration = 0

CLIENT_ID = '3-XWy138GarDUw'
REDIRECT_URI = 'https://localhost:8080'
RENEWAL_HEADSTART = 600000 # milliseconds
RATELIMIT_WINDOW = 600000 # milliseconds
RATELIMIT_QUOTA = 600 # requests
export LOGIN_AUTH_URL = "https://www.reddit.com/api/v1/authorize?response_type=code&duration=permanent&scope=account,creddits,edit,flair,history,identity,livemanage,modconfig,modcontributors,modflair,modlog,modmail,modothers,modposts,modself,modwiki,mysubreddits,privatemessages,read,report,save,structuredstyles,submit,subscribe,vote,wikiedit,wikiread&client_id=#{CLIENT_ID}&redirect_uri=#{REDIRECT_URI}&state=x"

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
	exchange_token = localStorage.api_key_exchange_token
	last_used_exchange_token = localStorage.api_key_last_used_exchange_token
	refresh_token = localStorage.api_key_refresh_token
	if exchange_token and not (exchange_token is last_used_exchange_token)
		console.log exchange_token
		body = new URLSearchParams
			grant_type: 'authorization_code'
			code: exchange_token
			redirect_uri: REDIRECT_URI
		localStorage.api_key_last_used_exchange_token = exchange_token
		delete localStorage.api_key_exchange_token
	else if refresh_token
		body = new URLSearchParams
			grant_type: 'refresh_token'
			refresh_token: refresh_token
	else
		body = new URLSearchParams
			grant_type: 'https://oauth.reddit.com/grants/installed_client'
			device_id: 'DO_NOT_TRACK_THIS_DEVICE'
	fetch 'https://www.reddit.com/api/v1/access_token',
		method: 'POST'
		headers:
			'Authorization': 'Basic ' + btoa(CLIENT_ID + ':')
		body: body
	.then (response) -> response.json()
	.then (json) ->
		localStorage.api_key_type = json.token_type or ''
		localStorage.api_key_value = json.access_token or ''
		localStorage.api_key_expiration = if json.expires_in then Date.now() + json.expires_in * 1000 else 0
		localStorage.api_key_refresh_token = json.refresh_token or ''

call_api = ({ method, path, body }) ->
	ratelimit_wait = check_ratelimit_wait()
	if ratelimit_wait < 1
		# If API key is absent or expired, renew it.
		expiration = Number localStorage.api_key_expiration
		if (not expiration) or Date.now() > expiration
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
			expiration = Number localStorage.api_key_expiration
			if Date.now() > (expiration - RENEWAL_HEADSTART)
				renew_api_key()
	else
		Promise.reject(new RateLimitError("Request would exceed Reddit API frequency limit. Wait #{ratelimit_wait // 1000} seconds."))

export get = ({ endpoint, options = {} }) ->
	# Delete keys with empty values.
	for name, value of options
		if not value and value isnt 0 then delete options[name]
	options.raw_json = 1
	call_api
		method: 'GET'
		path: endpoint + '?' + (new URLSearchParams(options)).toString()

export post = ({ endpoint, content = {} }) ->
	# Delete keys with empty values.
	for name, value of content
		if not value and value isnt 0 then delete content[name]
	call_api
		method: 'POST'
		path: endpoint
		body: new URLSearchParams(content)

export getListingSlice = ({ endpoint, options }) =>
	get
		endpoint: endpoint
		options: options
	.then (x) ->
		new GenericThingArray(x)