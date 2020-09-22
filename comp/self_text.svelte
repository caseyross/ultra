<template>
	#self-text
		+html('text_html')
</template>

<style>
	#self-text
		height 100%
		padding 16px
		overflow auto
		font-size 14px
		line-height 1.5
		&::-webkit-scrollbar
			width 4px
			background transparent
		&::-webkit-scrollbar-thumb
			background gray
</style>

<script>
	export text_html = ''
</script>