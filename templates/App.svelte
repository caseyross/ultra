<script>

	import RedditFeed from '/objects/RedditFeed'
	import RedditUser from '/objects/RedditUser'
	import FeedList from '/templates/FeedList'
	import FeedView from '/templates/FeedView'
	import MouseMenu from '/templates/MouseMenu'
	import InternalsView from '/templates/InternalsView'

	# Initialize.
	currentFeed = new RedditFeed(window.location.pathname)
	# Hot load internal links.
	document.addEventListener 'click',
		(e) ->
			for element in e.path
				if element.href
					url = new URL(element.href)
					if url.origin is window.location.origin
						currentFeed = new RedditFeed(url.pathname)
						history.pushState({}, '', element.href)
						e.preventDefault()
					break
	# Also hot load when the user goes "Back".
	window.addEventListener 'popstate',
		(e) ->
			currentFeed = new RedditFeed(window.location.pathname)
	
	account =
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

	inspect = off
	document.keyboardShortcuts.Backquote =
		n: 'Toggle Inspector'
		d: () => inspect = !inspect

</script><template lang='pug'>

	svelte:head
		title {currentFeed.id}
	FeedList(subscriptions='{account.subscriptions}')
	FeedView(feed='{currentFeed}')
	MouseMenu
	+if('inspect')
		#inspector-overlay
			InternalsView(key='currentFeed' value='{currentFeed}')

</template><style>

	#inspector-overlay
		position fixed
		top 0
		width 100vw
		height 100vh
		padding 1% 0
		overflow auto
		background #fed
		color black

</style>