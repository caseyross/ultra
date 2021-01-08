<script>

	import RedditComment from '/objects/RedditComment'
	import RedditMessage from '/objects/RedditMessage'
	import RedditPost from '/objects/RedditPost'
	import Comment from '/templates/Comment'
	import Message from '/templates/Message'
	import Post from '/templates/Post'
	import PostComments from '/templates/PostComments'
	import PostContent from '/templates/PostContent'

	export feed = null
	story = null
	select = (newStory) ->
		story = newStory

</script><template lang='pug'>

	#feed-view
		h1#listing-name {feed.id}
		ol#story-list
			+each('feed.fragments as fragment')
				+await('fragment() then stories')
					+each('stories as story')
						li(on:mousedown!='{() => select(story)}')
							+if('story instanceof RedditPost')
								+await('story.data then data')
									Post(post='{data}')
								+elseif('story instanceof RedditComment')
									Comment(comment='{story}')
								+elseif('story instanceof RedditMessage')
									Message(message='{story}')
								+else
									.error-tag UNKNOWN ITEM
									.error-message {item.toString()}
					+catch('error')
						.error-tag ERROR LOADING FEED FRAGMENT
						.error-message {error}
		+if('story')
			+await('story.data then data')
				article#listing-item
					#item-actions
					h3#item-title {data.title}
					#item-content
						PostContent(content='{data.content}')
						+await('data.comments then comments')
							PostComments(comments='{comments}')
				+catch('error')
					.error-tag ERROR LOADING POST
					.error-message {error}
			+else
				+await('feed.sidebar() then sidebar')
					+if('sidebar')
						img(src='{sidebar.banner_background_image || sidebar.banner_img}')
						article
							+html('sidebar.description_html')
					+catch('error')
						.error-tag ERROR LOADING SIDEBAR
						.error-message {error}

</template><style>

	#feed-view
		height 100%
		display grid
		grid-template-rows 5rem 1fr
		overflow auto
		border-right 1px solid gray
	#listing-name
		font-size 4rem
		display flex
		place-content center
	#listing-item
		height 100%
		overflow auto
		padding-left 2rem
	#item-actions
		height 4rem
	#item-title
		font-size 3rem
	#item-content
		display flex

</style>