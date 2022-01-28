window.state = {
	route: {} # 
	show: {} # Visibility of toggleable UI elements
	objects: {} # Remote object data (by ID)
	vintage: {} # Remote object download date (by ID) 
	loading: {} # Remote object loading states (by ID)
	error: {} # Remote object errors (by ID)
	translate: {} # Translation table relating IDs and human-readable names
	status: {} # Current system status, e.g. connection quality, ratelimit usage
}

window.routing = derived(window.state.routing)

derived(
	parentStore,

import { writable } from 'svelte/store'

actions = writable({})
actions.set(

window.state = readable(