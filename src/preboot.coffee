import './env/Array.coffee'
import './env/Math.coffee'

import api from './api/index.js'
import parseRoute from './ui/infra/parseRoute.coffee'

api.configure({
	client_id: process.env.API_CLIENT_ID
	redirect_uri: process.env.API_REDIRECT_URI
})

route = parseRoute(location)
if route.preload
	for id in route.preload
		api.preload(id)