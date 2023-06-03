export default
	N: {}
	E:
		unmodified: (data) ->
			label: if data.subscribed then 'Unsubscribe' else 'Subscribe'
			icon: if data.subscribed then '💔' else '❤️'
			value: if data.subscribed then 'unsubscribe' else 'subscribe'
	S:
		unmodified: (data) ->
			label: 'Create Post'
			icon: '🖋️'
			value: 'create_post'
	W: {}