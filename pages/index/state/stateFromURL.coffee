import Channel from '../../../models/Channel.coffee'

export default stateFromURL = ->
	state =
		channel: null
		itemId: ''
	# Parse channel and post status
	[ _, a, b, c, d, e, f ] = window.location.pathname.split('/').map((x) -> x?.toLowerCase())
	p = new URLSearchParams(window.location.search)
	if a.length > 1
		[ a, b, c, d, e, f ] = [ 'r', a, b, c, d, e ] # impllcit "r/"
	if c is 'comments' or c is 'post' and d
		state.itemId = d.toPostId()
	else if a and b
		channelId = [a, b, c, d, e, f, p.get('t')].filter((x) -> x).join('/')
	state.channel = new Channel(channelId or '/')
	return state