<template>
	#self-text
		+html('text_html')
</template>

<style>
	#self-text
		height 100%
		overflow auto
		font-size 14px
		&::-webkit-scrollbar
			width 4px
			background transparent
		&::-webkit-scrollbar-thumb
			background gray
</style>

<script>
	export text_html = ''
</script>