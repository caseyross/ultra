window.state = {
	route: {} # 
	show: {} # Visibility of toggleable UI elements
	objects: {} # Remote object data (by ID)
	vintage: {} # Remote object download date (by ID) 
	loading: {} # Remote object loading status (by ID)
	sending: {} # Remote action sending status (by ID)
	error: {} # Remote object error status (by ID)
	status: {} # Current system status, e.g. connection quality, ratelimit usage
}