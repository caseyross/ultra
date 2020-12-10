import '/lib/Object'

import Color from '/lib/Color'
window.Color = Color
window.Memory = window.localStorage
import Reddit from '/lib/Reddit'
window.Reddit = Reddit
import Time from '/lib/Time'
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