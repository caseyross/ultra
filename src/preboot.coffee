import api from 'rr-api'

import { DEMO_API_CLIENT_ID } from './config/demo_key.js'
import { parse_url } from './url/index.js'

# Set API config from environment vars / query parameters / previously stored values.
if process.env.API_CLIENT_ID
	clientID = process.env.FAPI_CLIENT_ID
else if !api.hasClientID()
	clientID = DEMO_API_CLIENT_ID
else
	# Retain previously used client ID.
api.configure({
	clientID: clientID
	debug: (new URLSearchParams(location.search)).get('debug')? or process.env.API_DEBUG?
	redirectURI: location.origin
})

# If a login attempt was started by a prior instance of the application, finish it.
if api.hasPendingLogin()
	{ error, memoString: remembered_path } = api.finishPendingLogin()
	if error
		switch error.reason
			when 'no-matching-login-attempt' then alert("Login failed. The login process should be completed in a single window, without opening other windows.")
			when 'user-refused-login' then alert("Login failed. You didn't allow access to your account.")
			else alert("Login failed. We didn't expect it to fail in this way so we don't know why. Error message: #{error.reason || error.message}")
	history.replaceState(null, null, remembered_path ? '/')

# Parse the current route so we can start making network requests for critical path data ASAP.
route = parse_url(location)
if route.preload
	for id in route.preload
		api.load(id)