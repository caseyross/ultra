<script>

	export subscriptions = {}

	import Avatar from '/templates/Avatar.svelte'
	import Subreddit from '/templates/Subreddit.svelte'

</script><template lang='pug'>

	nav#global-nav
		#account-links
			Avatar(user='')
			button#account-switcher Switch account...
		#subscriptions
			ol#user-subscriptions
				+each('subscriptions.users as user')
					li
						Avatar(user='{user}')
			ol#subreddit-subscriptions
				+each('subscriptions.subreddits as name')
					li
						Subreddit(name='{name}')
		ol#quick-settings
			li SFW
			li Frugal

</template><style>

	#global-nav
		height 100%
		display grid
		grid-template-rows 5rem 1fr 5rem
		overflow auto
		border-right 1px solid gray
	#user-subscriptions
		display flex
		flex-flow row wrap
	li
		list-style none
		margin 1ch 0
	#quick-settings
		display flex
		border-top 1px solid gray

</style>