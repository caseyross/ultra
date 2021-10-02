export default stateFromURL = ->
	state =
		channelId: '/'
		postId: ''
	# Parse channel and post status
	[ _, a, b, c, d, e, f ] = location.pathname.split('/').map((x) -> x?.toLowerCase())
	if a.length > 1
		[ a, b, c, d, e, f ] = [ 'r', a, b, c, d, e ] # impllcit "r/"
	if c is 'comments' or c is 'post' and d
		state.postId = d
	else if a and b
		state.channelId = [a, b, c, d, e, f, p.get('t')].filter((x) -> x).join('/')
	return state