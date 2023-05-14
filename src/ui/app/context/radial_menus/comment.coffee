export default
	N: {}
	E:
		unmodified: (data) ->
			label: if data.saved then 'Unsave' else 'Save'
			icon: if data.saved then '🗙' else '💾'
			value: if data.saved then 'unsave' else 'save'
	S:
		unmodified: (data) ->
			label: 'Reply'
			icon: '💬'
			value: 'reply'
		alt: (data) ->
			label: 'Edit'
			icon: '✏️'
			value: 'edit'
	W:
		unmodified: (data) ->
			label: 'Report'
			icon: '🚩'
			value: 'report'
		alt: (data) ->
			label: 'Delete'
			icon: '🗑️'
			value: 'delete'