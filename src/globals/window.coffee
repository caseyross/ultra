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


# quick and dirty normal distribution estimator for the given sample
window.NormalDistribution = class
	constructor: (sample) ->
		@mean = sample.fold(0, (a, b) -> a + b) / sample.length
		above_mean = sample.filter((x) => x > @mean).sort()
		below_mean = sample.filter((x) => x < @mean).sort()
		@standard_deviation = (Math.abs(above_mean[above_mean.length // 3] - @mean) + Math.abs(@mean - below_mean[below_mean.length // 3 * 2])) / 2
	deviation: (value) =>
		(value - @mean) / @standard_deviation


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

window.Server =
	get: ({ endpoint, options = {} }) ->
		# Delete keys with empty values.
		for name, value of options
			if not value and value isnt 0 then delete options[name]
		options.raw_json = 1
		call_api({
			method: 'GET',
			path: endpoint + '?' + (new URLSearchParams(options)).toString()
		})
	post: ({ endpoint, content = {} }) ->
		# Delete keys with empty values.
		for name, value of content
			if not value and value isnt 0 then delete content[name]
		call_api({
			method: 'POST',
			path: endpoint,
			body: new URLSearchParams(content)
		})