window.LazyPromise = class
	constructor: (f) ->
		@ran = false
		@result = undefined
		@run = () ->
			if not @ran
				@ran = true
				@result = f()
			@result


window.KeyMap = {}
document.onkeydown = (e) ->
	if e.shiftKey then KeyMap[e.code]?.sd?()
	else if e.metaKey then KeyMap[e.code]?.ad?()
	else KeyMap[e.code]?.d?()
document.onkeyup = (e) ->
	if e.shiftKey then KeyMap[e.code]?.su?()
	else if e.metaKey then KeyMap[e.code]?.au?()
	else KeyMap[e.code]?.u?()


# Docs: https://github.com/reddit-archive/reddit/wiki/OAuth2
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
		Storage.apiTokenType = json.token_type
		Storage.apiTokenValue = json.access_token
		Storage.apiTokenExpireTime = Date.now() + json.expires_in * 999
class RateLimitError extends Error
	constructor: (message) ->
		super(message)
		@name = 'RateLimitError'
requestLockupExpirations = []
contact_api = ({ method, path, body }) ->
	# Check rate limit. Reddit allows up to 60 requests per minute.
	now = Date.now()
	requestLockupExpirations = requestLockupExpirations.filter((expiration) -> expiration > now)
	if requestLockupExpirations.length >= 30 # use half of the allowed limit, for testing
		secondsUntilRequestAllowed = (requestLockupExpirations[0] - now) // 1000
		return Promise.reject(new RateLimitError("Request would exceed Reddit API frequency limit. Wait #{secondsUntilRequestAllowed} seconds."))
	# If access token is absent or already expired, block while getting a new one.
	# If access token is expiring soon, don't block the current operation, but pre-emptively request a new token.
	if not Storage.apiTokenExpireTime or now > Storage.apiTokenExpireTime
		await renew_api_key()
	else if now > Storage.apiTokenExpireTime - 600000
		renew_api_key()
	# Record time of request for rate limit checking.
	requestLockupExpirations.push(now + 60000)
	fetch(
		'https://oauth.reddit.com' + path,
		{
			method,
			headers: {
				'Authorization': Storage.apiTokenType + ' ' + Storage.apiTokenValue
			},
			body
		}
	).then (response) -> response.json()
window.Server =
	get: ({ endpoint, options = {} }) ->
		# Delete keys with empty values.
		for name, value of options
			if not value and value isnt 0 then delete options[name]
		options.raw_json = 1
		contact_api({
			method: 'GET',
			path: endpoint + '?' + (new URLSearchParams(options)).toString()
		})
	post: ({ endpoint, content = {} }) ->
		# Delete keys with empty values.
		for name, value of content
			if not value and value isnt 0 then delete content[name]
		contact_api({
			method: 'POST',
			path: endpoint,
			body: new URLSearchParams(content)
		})


window.Storage = window.localStorage