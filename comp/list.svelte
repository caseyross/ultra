<template lang='pug'>
	ol#list
		+await('LIST')
			+then('objects')
				+each('objects as object')
					Box(
						object='{object}'
						is_read='{ls[object.id]}'
						is_chosen='{choice === object.id}'
						f_choose!='{() => f_choose(object)}'
					)
			+catch('error')
				.error-tag ERROR LOADING FEED
				.error-message {error}
</template>

<style>
	#list
		grid-area list
		margin 0
		padding 0
		overflow auto
		will-change transform // https://bugs.chromium.org/p/chromium/issues/detail?id=514303
		&::-webkit-scrollbar
			display none
</style>

<script>
	export LIST = new Promise (f, r) -> {}
	export choice = ''
	export f_choose = () -> {}

	import Box from '/comp/box.svelte'
</script>