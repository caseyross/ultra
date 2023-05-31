export default
	N:
		alt: (data) ->
			label: if data.distinguish is 'moderator' then 'Undistinguish' else 'Distinguish as Mod'
			icon: if data.distinguish is 'moderator' then '🀄' else '🀅'
			value: if data.distinguish is 'moderator' then 'undistinguish' else 'distinguish_as_mod'
	E:
		unmodified: (data) ->
			label: if data.saved then 'Unsave' else 'Save'
			icon: if data.saved then '🗑️' else '💾'
			value: if data.saved then 'unsave' else 'save'
		alt: (data) ->
			label: if data.pinned then 'Unpin' else 'Pin'
			icon: '📌'
			value: if data.pinned then 'unpin' else 'pin'
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