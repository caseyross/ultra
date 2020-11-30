import Color from '/lib/Color'
window.Color = Color
import Content from '/lib/Content'
window.Content = Content
window.Memory = window.localStorage
import State from '/lib/State'
window.State = State
import Reddit from '/lib/Reddit'
window.Reddit = Reddit
import Time from '/lib/Time'
window.Time = Time

document.keyboard_shortcuts = {}
document.onkeydown = (e) ->
	if e.shiftKey then document.keyboard_shortcuts[e.code]?.sd?()
	else if e.metaKey then document.keyboard_shortcuts[e.code]?.ad?()
	else document.keyboard_shortcuts[e.code]?.d?()
document.onkeyup = (e) ->
	if e.shiftKey then document.keyboard_shortcuts[e.code]?.su?()
	else if e.metaKey then document.keyboard_shortcuts[e.code]?.au?()
	else document.keyboard_shortcuts[e.code]?.u?()

import App from '/App'
new App({
	target: document.body
})