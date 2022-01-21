export default {
	ids: {}
	routing: {}
	toggled: {}
	objects: {}
	loading: {} # Loading status of remote object data, by ID
	vintage: {}
	metrics: {} # Diagnostic statistics, e.g. ratelimit usage status, internet connection status
	alerts: { # Temporary errors, warnings, or notifications that we want the user to know about
		api: []
		internet: []
	}
}