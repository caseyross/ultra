<script>

	export content = {}
	
	import PostComments from '/templates/PostComments'
	import Gallery from '/templates/Gallery'
	import MediaPlayer from '/templates/MediaPlayer'

</script><template lang='pug'>

	#postContent
		+if('content.type === "comment"')
			+await('content.post.data then data')
				PostComments(comments='{data.comments}')
				+catch('error')
					.error-tag ERROR LOADING POST
					.error-message {error}
			+elseif('content.type === "text"')
				+if('content.text.length')
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
		flex 0 0 auto
		height 100%
		overflow auto
		background repeating-linear-gradient(-45deg, rgba(0,0,0,0.1) 0 1rem, transparent 1rem 2rem)
		padding 1ch 0
	#text
		height 100%
		overflow auto
		padding 1ch
		width 50%
		background white
		color black

</style>