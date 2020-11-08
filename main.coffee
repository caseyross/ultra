import System from '/system.svelte'

window.cache = window.localStorage

document.keyboard_shortcuts = {}
document.onkeydown = (e) ->
	if e.shiftKey then document.keyboard_shortcuts[e.code]?.sd?()
	else if e.metaKey then document.keyboard_shortcuts[e.code]?.ad?()
	else document.keyboard_shortcuts[e.code]?.d?()
document.onkeyup = (e) ->
	if e.shiftKey then document.keyboard_shortcuts[e.code]?.su?()
	else if e.metaKey then document.keyboard_shortcuts[e.code]?.au?()
	else document.keyboard_shortcuts[e.code]?.u?()

new System({
	target: document.body
})