export default
	N:
		unmodified: (data) ->
			label: if data.canEdit then 'Edit' else ''
			icon: if data.canEdit then '✏️' else ''
			value: if data.canEdit then 'edit' else ''
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
	W:
		unmodified: (data) ->
			label: 'Report'
			icon: '🚩'
			value: 'report'