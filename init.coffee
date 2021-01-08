import '/lib/Object'
import Api from '/lib/Api'
import Color from '/lib/Color'
import Statistics from '/lib/Statistics'
import Time from '/lib/Time'
window.Api = Api
window.Color = Color
window.Memory = window.localStorage
window.Statistics = Statistics
window.Time = Time

document.keyboardShortcuts = {}
document.onkeydown = (e) ->
	if e.shiftKey then document.keyboardShortcuts[e.code]?.sd?()
	else if e.metaKey then document.keyboardShortcuts[e.code]?.ad?()
	else document.keyboardShortcuts[e.code]?.d?()
document.onkeyup = (e) ->
	if e.shiftKey then document.keyboardShortcuts[e.code]?.su?()
	else if e.metaKey then document.keyboardShortcuts[e.code]?.au?()
	else document.keyboardShortcuts[e.code]?.u?()

import App from '/templates/App'
new App({
	target: document.body
})