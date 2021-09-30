export default stateFromURL = ->
	state =
		loginCode: ''
		loginError: false
		channelId: '/'
		postId: ''
	# Check for completed or errored login
	p = new URLSearchParams(location.search)
	if p.has('error')
		switch p.get('error')
			state.loginError = true
	else if p.has('code')
		state.loginCode = p.get('code')
	# Parse channel and post status
	[ _, a, b, c, d, e, f ] = location.pathname.split('/').map((x) -> x?.toLowerCase())
	if a.length > 1
		[ a, b, c, d, e, f ] = [ 'r', a, b, c, d, e ] # impllcit "r/"
	if c is 'comments' or c is 'post' and d
		state.postId = d
	else if a and b
		state.channelId = [a, b, c, d, e, f, p.get('t')].filter((x) -> x).join('/')
	return state