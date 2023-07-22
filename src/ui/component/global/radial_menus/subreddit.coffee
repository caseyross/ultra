export default
	unmodified: (data) ->
		if data.canInteract
			N:
				action: ''
				icon: ''
				label: ''
			W:
				action: ''
				icon: ''
				label: ''
			E:
				if data.subscribed
					action: 'unsubscribe'
					icon: '💔'
					label: 'Unsubscribe'
				else
					action: 'subscribe'
					icon: '❤️'
					label: 'Subscribe'
			S:
				action: 'create_post'
				icon: '🖋️'
				label: 'Create Post'