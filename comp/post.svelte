<template lang='pug'>

	#post
		+if('post.content.type === "post"')
			+await('post.content.LINKED_OBJECT then linked_object')
				Comments(post='{linked_object}')
			+elseif('post.content.type === "html"')
				#self-text
					+html('post.content.html')
			+elseif('post.content.type === "image"')
				Gallery(images='{post.content.images}')
			+elseif('post.content.type === "video"')
				MediaPlayer(audio_url='{post.content.audio_url}' video_url='{post.content.url}' video_preview_url='{post.content.preview_url}')
			+elseif('post.content.type === "link"')
				iframe(src='{post.content.url}' sandbox='allow-scripts allow-same-origin')

</template><style>

	#post
		grid-area object
		height 100%
		overflow auto
		background repeating-linear-gradient(-45deg, rgba(0,0,0,0.1) 0 1rem, transparent 1rem 2rem)
	#self-text
		height 100%
		overflow auto
		font-size 14px

</style><script>

	export post = {}
	
	import Comments from '/comp/Comments'
	import Gallery from '/comp/Gallery'
	import MediaPlayer from '/comp/MediaPlayer'

</script>