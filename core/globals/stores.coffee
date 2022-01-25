window.state = {
	ids: {}
	route: {}
	shown: {}
	objects: {} # Remote object data, by object key
	loading: {} # Loading status for remote object data, by object key
	vintage: {} # Download date for remote data, by object key
	metrics: {} # Diagnostic statistics, e.g. ratelimit usage status, internet connection status
	alerts: { # Temporary errors, warnings, or notifications that we want the user to know about
		api: []
		internet: []
	}
}

window.routing = derived(window.state.routing)