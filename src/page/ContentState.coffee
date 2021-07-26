import MultiredditFeed from '../feed/MultiredditFeed.coffee'
import SubredditFeed from '../feed/SubredditFeed.coffee'
import SubredditOverviewFeed from '../feed/SubredditOverviewFeed.coffee'
import ThingArray from '../ThingArray.coffee'

export default class ContentState

	constructor: ->  @[k] = v for k, v of {
		subreddit: Promise.resolve {}
		feed: {}
		story: Promise.resolve {}
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
							this.story =
								cached 't3_' + d, ->
									API.get
										endpoint: '/comments/' + d
								.then ([x, y]) ->
									new ThingArray(x)[0]
				if b
					this.subreddit = cached 'r/' + b + '/about', ->
						API.get
							endpoint: '/r/' + b + '/about'
						.then (x) ->
							new ThingArray(x)[0]
					if p.get('sort')
						this.feed = new SubredditFeed
							name: b
							sort: p.get('sort')
					else if ['new', 'rising', 'hot', 'top', 'controversial'].includes(c)
						this.feed = new SubredditFeed
							name: b
							sort: c
					else
						this.feed = new SubredditOverviewFeed
							name: b
			else
				this.feed = new MultiredditFeed
					user: 'r'
					name: 'popular'
					sort: 'hot'