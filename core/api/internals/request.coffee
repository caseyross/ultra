import { getCredentialsTimeLeft, renewCredentials } from './authentication.coffee'
import { countRatelimit, getRatelimitStatus, RatelimitError } from './ratelimit.coffee'

request = ({ method, path, body }) ->
	# Check credentials validity. Force renewal if necessary.
	if getCredentialsTimeLeft() <= 0
		await renewCredentials()
	# Check ratelimit status and fail if quota has been hit.
	{ quota, used } = getRatelimitStatus()
	if used >= quota
		return Promise.reject(new RatelimitError())
	# OK to send.
	countRatelimit(1)
	return fetch 'https://oauth.reddit.com' + path, {
		method
		headers:
			'Authorization': browser.OAUTH_ACCESS_TOKEN
		body
	}
	.then (response) ->
		response.json()
	.finally ->
		# Asynchronously renew credentials if they're going to expire within a certain time.
		if getCredentialsTimeLeft() < Date.minutes(30)
			renewCredentials()

export get = ({ endpoint, ...options }) ->
	for name, value of options
		if value == undefined or value == null
			delete options[name]
	options.raw_json = 1 # Opt out of legacy Reddit response encoding
	request
		method: 'GET'
		path: endpoint + '?' + (new URLSearchParams(options)).toString()

export post = ({ endpoint, ...content }) ->
	for name, value of options
		if value == undefined or value == null
			delete options[name]
	request
		method: 'POST'
		path: endpoint
		body: new URLSearchParams(content)