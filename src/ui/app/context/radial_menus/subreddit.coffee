export default
	unmodified: (data) ->
		if data.canInteract
			N:
				if data.subscribed
					action: 'unsubscribe'
					icon: '💔'
					label: 'Unsubscribe'
				else
					action: 'subscribe'
					icon: '❤️'
					label: 'Subscribe'
			W:
				action: ''
				icon: ''
				label: ''
			E:
				action: 'create_post'
				icon: '🖋️'
				label: 'Create Post'
			S:
				action: ''
				icon: ''
				label: ''