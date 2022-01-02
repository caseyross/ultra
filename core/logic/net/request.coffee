import { getCredentialsTimeLeft, renewCredentials } from './authentication.coffee'
import { countRatelimit, getRatelimitStatus, RatelimitError } from './ratelimit.coffee'
import { cacheFunctionAs } from '../../cache.coffee'
import RedditDataModel from '../../../models/RedditDataModel.coffee'

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
			'Authorization': machineState.ACCESS_TOKEN
		body
	}
	.then (response) ->
		response.json()
	.finally ->
		# Asynchronously renew credentials if they're going to expire within a certain time.
		if getCredentialsTimeLeft() < Date.minutes(30)
			renewCredentials()

export get = ({ endpoint, cache, automodel, ...options }) ->
	for name, value of options
		if not value and value isnt 0 then delete options[name] # Don't send keys with empty values.
	options.raw_json = 1 # Opt out of legacy Reddit response encoding
	r = ->
		request
			method: 'GET'
			path: endpoint + '?' + (new URLSearchParams(options)).toString()
	promise =
		if cache
			cacheFunctionAs cache, r
		else
			r()
	promise.then (data) ->
		console.log data
		if automodel then new RedditDataModel(data) else data

export post = ({ endpoint, ...content }) ->
	for name, value of content
		if not value and value isnt 0 then delete content[name] # Don't send keys with empty values.
	request
		method: 'POST'
		path: endpoint
		body: new URLSearchParams(content)