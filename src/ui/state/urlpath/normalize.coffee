export default (url) ->
			if e.target.href[0] == '/'
				e.target.origin + e.target.href
			else
				e.target.href