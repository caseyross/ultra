import api from './api/index.js'
import router from './router/index.js'

api.configure({
	client_id: process.env.API_CLIENT_ID
	redirect_uri: process.env.API_REDIRECT_URI
})

router.init({}, {})
page = router.routeCurrentUrl()
if page.preload
	for id in page.preload
		api.preload(id)