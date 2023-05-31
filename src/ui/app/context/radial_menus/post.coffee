export default
	N: {}
	E:
		unmodified: (data) ->
			label: if data.saved then 'Unsave' else 'Save'
			icon: if data.saved then '🗑️' else '💾'
			value: if data.saved then 'unsave' else 'save'
		ctrl: (data) ->
			label: 'Approve'
			icon: '🛡️'
			value: 'approve'
	S:
		unmodified: (data) ->
			label: 'Reply'
			icon: '💬'
			value: 'reply'
		alt: (data) ->
			label: 'Edit'
			icon: '✏️'
			value: 'edit'
		ctrl: (data) ->
			label: 'Ban User'
			icon: '💀'
			value: 'ban_user'
	W:
		unmodified: (data) ->
			label: 'Report'
			icon: '🚩'
			value: 'report'
		ctrl: (data) ->
			label: 'Remove'
			icon: '🪓'
			value: 'remove'