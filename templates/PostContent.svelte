<template lang='pug'>

	#postContent
		+if('content.type === "comment"')
			+await('content.POST then post')
				Comments(comments='{post.comments}')
			+elseif('content.type === "text"')
				#text
					+html('content.text')
			+elseif('content.type === "image"')
				Gallery(images='{content.images}')
			+elseif('content.type === "video"')
				MediaPlayer(audioUrl='{content.audioUrl}' videoUrl='{content.url}' videoPreviewUrl='{content.previewUrl}')
			+elseif('content.type === "link"')
				iframe(src='{content.url}' sandbox='allow-scripts allow-same-origin')
			+else
				article {content.type}

</template><style>

	#postContent
		grid-area item
		height 100%
		overflow auto
		background repeating-linear-gradient(-45deg, rgba(0,0,0,0.1) 0 1rem, transparent 1rem 2rem)
	#text
		height 100%
		overflow auto
		font-size 14px

</style><script>

	export content = {}
	
	import Comments from '/templates/Comments'
	import Gallery from '/templates/Gallery'
	import MediaPlayer from '/templates/MediaPlayer'

</script>