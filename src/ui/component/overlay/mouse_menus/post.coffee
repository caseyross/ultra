export default
	alt: (data) ->
		if data.canEdit
			N:
				action: ''
				icon: ''
				label: ''
			W:
				action: ''
				icon: ''
				label: ''
			E:
				action: ''
				icon: ''
				label: ''
			S:
				action: 'edit'
				icon: '✏️'
				label: 'Edit'
	ctrl: (data) ->
		if data.canMod
			N:
				if data.canEdit
					if data.distinguish is 'moderator'
						action: 'undistinguish'
						icon: '🗙'
						label: 'Undistinguish'
					else
						action: 'distinguish_as_mod'
						icon: '🟢'
						label: 'Distinguish as Mod'
			W:
				action: 'remove'
				icon: '❎'
				label: 'Remove'
			E:
				action: 'approve'
				icon: '✅'
				label: 'Approve'
			S:
				action: ''
				icon: ''
				label: ''
	ctrl_shift: (data) ->
		if data.canMod
			N:
				if data.pinned
					action: 'unpin'
					icon: '❌'
					label: 'Unpin'
				else
					action: 'pin'
					icon: '📌'
					label: 'Pin'
			W:
				action: 'remove_and_ban_user'
				icon: '💀'
				label: 'Remove & Ban User'
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
				action: ''
				icon: ''
				label: ''
			W:
				action: 'report'
				icon: '🚩'
				label: 'Report'
			E:
				if data.saved
					action: 'unsave'
					icon: '🚮'
					label: 'Unsave'
				else
					action: 'save'
					icon: '💾'
					label: 'Save'
			S:
				action: 'reply'
				icon: '💬'
				label: 'Reply'