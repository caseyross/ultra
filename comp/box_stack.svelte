<template>
	ol
		+each('items as item')
			Box(
				item='{item}'
				is_selected!='{selected_item.id === item.id}'
				is_read!='{read_items.has(item.id)}'
				do_select!='{() => do_select_item(item)}'
			)
</template>

<style>
	ol
		user-select none
</style>

<script>
	export items = []
	export selected_item = {}
	export read_items = new Set()
	export do_select_item = () -> {}
	
	import Box from '/comp/box.svelte'
</script>