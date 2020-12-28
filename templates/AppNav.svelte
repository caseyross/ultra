<template lang='pug'>

	nav
		#user-management
			Avatar(username='caseyross')
		#listing-title
			input(type='text' bind:value='{state.listingId}')
		Feed(state='{state}')

</template><style>

	nav
		width 100%
		height 100%
	#user-management
		height 5rem
	#listing-title
		height 5rem

</style><script>

	export state = {}

	import Avatar from '/templates/Avatar.svelte'
	import Feed from '/templates/Feed.svelte'

</script>