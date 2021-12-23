import { hasUserCredentials } from '../../../logic/net/authentication.coffee'
import { fetchPopularSubreddits, fetchCurrentUserSubscriptions } from '../../../scripts/api/API.coffee'

export default {
	ratelimitUsed: 0
	channel: {}
	postIndex: 0
	directory:
		isOpen: false
		destinations: if hasUserCredentials() then fetchCurrentUserSubscriptions() else fetchPopularSubreddits()
		userFilterText: ''
}