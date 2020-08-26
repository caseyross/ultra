<template>
#sidebar
	+await('$feed.METADATA')
		+then('info')
			article {@html info.description_html}
		+catch('error')
			article {error}
</template>

<style>
	#sidebar
		height: 100%
		overflow: auto
		display: flex
		flex-flow: column nowrap
		&::-webkit-scrollbar
			width: 4px
			background: transparent
		&::-webkit-scrollbar-thumb
			background: gray
</style>

<script>
	import { feed } from './state.coffee'
</script>