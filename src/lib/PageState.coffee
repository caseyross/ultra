import { All, Home, Inbox, Multireddit, Popular, Saved, Subreddit, User } from '/src/model'

window.PageState =
	from_url: (url) ->
		[ _, w, x, y, z] = url.pathname.split('/')
		if w.length < 1
			[w, x, y, z] = ['r', 'h']
		else if w.length > 1
			if w.includes('-')
				[w, x, y, z] = ['c', w, x, y]
			else
				[w, x, y, z] = ['r', w, x, y]
		listing = switch w
			when 'c' then new Multireddit(x)
			when 'm' then new Inbox(x)
			when 'r' then switch x
				when 'h' then new Home()
				when 'all' then new All()
				when 'popular' then new Popular()
				else new Subreddit(x)
			when 's' then new Saved(x)
			when 'u' then new User(x)
			else null
		sort = y
		count = z
		id = if url.hash.length > 3 then url.hash[1..] else ''
		{ listing, sort, count, id }