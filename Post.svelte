<template>
	+if('post.content.type === "html"')
		#self-text {@html post.content.html}
		+elseif('post.content.type === "image"')
			Gallery(images='{post.content.images}')
		+elseif('post.content.type === "video"')
			MediaPlayer(audio_url='{post.content.audio_url}' video_url='{post.content.url}' video_preview_url='{post.content.preview_url}')
		+elseif('post.content.type === "post"')
			+await('post.content.POST then content_post')
				Comments(post='{content_post}')
		+elseif('post.content.type === "link"')
			iframe(src='{post.content.url}' sandbox='allow-scripts allow-same-origin')
		+else
			#error-text CANNOT PARSE POST
</template>

<style>
	#self-text
		max-height: 100%
		padding: 16px
		overflow: auto
		font-size: 16px
		&::-webkit-scrollbar
			width: 4px
			background: transparent
		&::-webkit-scrollbar-thumb
			background: gray
</style>

<script>
	import { feed } from './state.coffee'
	import Gallery from './Gallery.svelte'
	import MediaPlayer from './MediaPlayer.svelte'
	import Comments from './Comments.svelte'
	export post = {}
</script>