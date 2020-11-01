import { parse_url } from '/proc/state.coffee'
import App from '/app.svelte'

window.cache = window.localStorage
{ page, story } = parse_url()
document.onclick = (e) =>
	for element in e.path
		if element.href
			# TODO: add replaceState logic
			history.pushState {}, '', element.href
			{ page, story } = parse_url()
			e.preventDefault()
			return

document.keyboard_shortcuts = {}
document.onkeydown = (e) ->
	if e.shiftKey then document.keyboard_shortcuts[e.code]?.sd?()
	else if e.metaKey then document.keyboard_shortcuts[e.code]?.ad?()
	else document.keyboard_shortcuts[e.code]?.d?()
document.onkeyup = (e) ->
	if e.shiftKey then document.keyboard_shortcuts[e.code]?.su?()
	else if e.metaKey then document.keyboard_shortcuts[e.code]?.au?()
	else document.keyboard_shortcuts[e.code]?.u?()

new App({
	target: document.body
	props: {
		page
		story
	}
})