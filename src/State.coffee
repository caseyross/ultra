import MultiredditFeed from './feed/MultiredditFeed.coffee'
import PostReference from './post/PostReference.coffee'
import Story from './Story.coffee'
import SubredditFeed from './feed/SubredditFeed.coffee'
import SubredditOverviewFeed from './feed/SubredditOverviewFeed.coffee'
import WikiPage from './wiki/WikiPage.coffee'

export default class State

	constructor: ->  @[k] = v for k, v of {
		story: new Story()
		feed: null
		account: null
	}

	update: =>
		[ _, a, b, c, d, e, f ] = location.pathname.split('/')
		p = new URLSearchParams(location.search)
		if a.length > 1
			[ a, b, c, d, e, f ] = [ 'r', a, b, c, d, e ]
		switch a
			when 'r'
				switch c
					when 'comments', 'post'
						if d
							return this.story = new PostReference
								id: d
								commentId: f
					when 'wiki'
						return this.story = new WikiPage
							path: location.pathname # can have 1 or 2 levels + hash link to a heading
				if b
					if p.get('sort')
						return this.feed = new SubredditFeed
							name: b
							sort: p.get('sort')
					else if ['new', 'rising', 'hot', 'top', 'controversial'].includes(c)
						return this.feed = new SubredditFeed
							name: b
							sort: c
					else
						return this.feed = new SubredditOverviewFeed
							name: b
			else
				this.feed = new MultiredditFeed
					user: 'r'
					name: 'popular'
					sort: 'hot'