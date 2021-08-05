import { finishLogin, getPost } from './API.coffee'
import Channel from './channel/Channel.coffee'

export default class URLState

	constructor: (newHref) ->

		if newHref
			history.pushState({}, '', newHref)

		p = new URLSearchParams(location.search)
		if p.has('code')
			@page = 'logging-in'
			@finishLogin = finishLogin(p.get('code'), p.get('state'))
			return

		@page = 'front'
		
		[ _, a, b, c, d, e, f ] = location.pathname.split('/').map((x) -> x?.toLowerCase())
		if a.length > 1
			[ a, b, c, d, e, f ] = [ 'r', a, b, c, d, e ]

		if c is 'comments' or c is 'post' and d
			@page = 'detached-post'
			@getPost = getPost(d)
		else if a and b
			@page = 'channel'
			@channel = new Channel([a, b, c, d, e, f, p.get('t')].filter((x) -> x).join('/'))
		
		console.log @