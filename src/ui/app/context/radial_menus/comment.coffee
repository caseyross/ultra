export default
	alt: (data) ->
		if data.canEdit
			N:
				if data.canMod
					if data.distinguish is 'moderator'
						action: 'undistinguish'
						icon: '🗙'
						label: 'Undistinguish'
					else
						action: 'distinguish_as_mod'
						icon: '🟢'
						label: 'Distinguish as Mod'
			W:
				action: 'edit'
				icon: '✏️'
				label: 'Edit'
			E:
				action: ''
				icon: ''
				label: ''
			S:
				action: ''
				icon: ''
				label: ''
	ctrl: (data) ->
		if data.canMod
			N:
				action: 'approve'
				icon: '✅'
				label: 'Approve'
			W:
				action: 'ban_user'
				icon: '💀'
				label: 'Ban User'
			E:
				if data.pinned
					action: 'unpin'
					icon: '❌'
					label: 'Unpin'
				else
					action: 'pin'
					icon: '📌'
					label: 'Pin'
			S:
				action: 'remove'
				icon: '❎'
				label: 'Remove'
	shift: (data) ->
		if data.canInteract
			N:
				if data.saved
					action: 'unsave'
					icon: '💔'
					label: 'Unsave'
				else
					action: 'save'
					icon: '❤️'
					label: 'Save'
			W:
				action: ''
				icon: ''
				label: ''
			E:
				action: ''
				icon: ''
				label: ''
			S:
				action: ''
				icon: ''
				label: ''
	unmodified: (data) ->
		if data.canInteract
			N:
				action: 'upvote'
				icon: '👍'
				label: 'Upvote'
			W:
				action: 'report'
				icon: '🚩'
				label: 'Report'
			E:
				action: 'reply'
				icon: '🗨️'
				label: 'Reply'
			S:
				action: 'downvote'
				icon: '👎'
				label: 'Downvote'