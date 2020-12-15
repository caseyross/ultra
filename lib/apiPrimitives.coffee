import RateLimitError from '/objects/RateLimitError.coffee'

# Docs: https://github.com/reddit-archive/reddit/wiki/OAuth2
RENEW_API_KEY = () ->
	fetch 'https://www.reddit.com/api/v1/access_token',
		method: 'POST'
		headers:
			'Authorization': 'Basic SjZVcUg0a1lRTkFFVWc6'
		body: new URLSearchParams
			grant_type: 'https://oauth.reddit.com/grants/installed_client'
			device_id: 'DO_NOT_TRACK_THIS_DEVICE'
	.then (response) -> response.json()
	.then (json) ->
		Memory.apiTokenType = json.token_type
		Memory.apiTokenValue = json.access_token
		Memory.apiTokenExpireTime = Date.now() + json.expires_in * 999

requestLockupExpirations = []
API_OPERATION = (httpMethod, urlPath, requestBody) ->
	# Check rate limit. Reddit allows up to 60 requests per minute.
	now = Date.now()
	requestLockupExpirations = requestLockupExpirations.filter((expiration) -> expiration > now)
	if requestLockupExpirations.length >= 30 # use half of the allowed limit, for testing
		secondsUntilRequestAllowed = (requestLockupExpirations[0] - now) // 1000
		return Promise.reject(new RateLimitError("Request would exceed Reddit API frequency limit. Wait #{secondsUntilRequestAllowed} seconds."))
	# If access token is absent or already expired, block while getting a new one.
	# If access token is expiring soon, don't block the current operation, but pre-emptively request a new token.
	if not Memory.apiTokenExpireTime or now > Memory.apiTokenExpireTime then await RENEW_API_KEY()
	else if now > Memory.apiTokenExpireTime - 600000 then RENEW_API_KEY()
	# Record time of request for rate limit checking.
	requestLockupExpirations.push(now + 60000)
	fetch 'https://oauth.reddit.com' + urlPath,
		method: httpMethod
		headers:
			'Authorization': Memory.apiTokenType + ' ' + Memory.apiTokenValue
		body: requestBody
	.then (response) -> response.json()

export API_GET = (endpoint, options = {}) ->
	# Delete options with empty values.
	for name, value of options
		if not value and value isnt 0 then delete options[name]
	options.raw_json = 1
	API_OPERATION 'GET', endpoint + '?' + (new URLSearchParams(options)).toString()

export API_POST = (endpoint, content = {}) ->
	# Delete content keys with empty values.
	for name, value of content
		if not value and value isnt 0 then delete content[name]
	API_OPERATION 'POST', endpoint, new URLSearchParams(content)