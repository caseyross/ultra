export default KeyMap = {}

document.onkeydown = (e) ->
	if e.shiftKey then KeyMap[e.code]?.sd?()
	else if e.metaKey then KeyMap[e.code]?.ad?()
	else KeyMap[e.code]?.d?()
document.onkeyup = (e) ->
	if e.shiftKey then KeyMap[e.code]?.su?()
	else if e.metaKey then KeyMap[e.code]?.au?()
	else KeyMap[e.code]?.u?()