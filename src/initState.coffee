import api from './api/index.js'
import router from './router/index.js'

api.configure({
	client_id: process.env.API_CLIENT_ID
	redirect_uri: process.env.API_REDIRECT_URI
})
api.preload('subreddit_posts:combatfootage:hot:10')

router.routeCurrentUrl()
router.listen()