import RedditFeed from '/src/objects/RedditFeed'
import RedditUser from '/src/objects/RedditUser'

sorts = [
	'new', 'rising', 'hot', 'top-hour', 'top-day', 'top-week', 'top-month', 'top-year', 'top-all', 'controversial-hour', 'controversial-day', 'controversial-week', 'controversial-month', 'controversial-year', 'controversial-all'
]

export default class State
	constructor: (url) ->
		#@selected =
		#	id: url.hash.match(/p[A-Z0-9]+/)
		#	commentFocusId = url.hash.match(/c[A-Z0-9]+/)
		#	commentFocusDepth = url.hash.match(/d[A-Z0-9]+/)
		@account =
			subscriptions:
				subreddits: [
					'fireemblem'
					'onebag'
					'gonewild'
					'tulsa'
					'genshin_impact'
					'buildapcsales'
					'namenerds'
					'singapore'
					'postprocessing'
					'manybaggers'
				]
				users: [
					'spez'
					'kn0thing'
					'gallowboob'
				].map((name) -> new RedditUser(name))
		@viewing =
			feed: new RedditFeed(url.pathname)
			story: null