<template lang='pug'>
	#post
		+if('post.content.type === "post"')
			+await('post.content.LINKED_OBJECT then linked_object')
				Comments(post='{linked_object}')
			+elseif('post.content.type === "html"')
				SelfText(text_html='{post.content.html}')
			+elseif('post.content.type === "image"')
				Gallery(images='{post.content.images}')
			+elseif('post.content.type === "video"')
				MediaPlayer(audio_url='{post.content.audio_url}' video_url='{post.content.url}' video_preview_url='{post.content.preview_url}')
			+elseif('post.content.type === "link"')
				iframe(src='{post.content.url}' sandbox='allow-scripts allow-same-origin')
</template>

<style>
	#post
		grid-area object
		height 100%
		overflow auto
</style>

<script>
	export post = {}
	
	import Comments from '/comp/comments.svelte'
	import Gallery from '/comp/gallery.svelte'
	import MediaPlayer from '/comp/media_player.svelte'
	import SelfText from '/comp/self_text.svelte'
</script>