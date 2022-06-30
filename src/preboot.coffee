import './env/Array.coffee'
import './env/Math.coffee'

import Time from './lib/Time.coffee'

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

THEMES =
	DARK: 'theme-dark'
	LIGHT: 'theme-light'

setTheme = ->
	localHour = Time.localHour()
	newTheme = switch
		when 6 <= localHour <= 18 then THEMES.LIGHT
		else THEMES.DARK
	document.body.classList.add(newTheme)
	document.body.classList.remove(...Object.values(THEMES).filter((x) -> x != newTheme))

window.addEventListener('DOMContentLoaded', (e) ->
	setTheme()
	setInterval(setTheme, Time.mToMs(1))
)