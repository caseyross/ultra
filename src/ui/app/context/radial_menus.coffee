import api from '../../../api/index.js'

export default {

	comment:

		default:
			1: (data) ->
				action: ->
				description: 'Share'
				icon: ''
			2: (data) ->
				if data.saved
					{
						action: -> api.submit(api.ID('comment_save', data.id), { unsave: true })
						description: 'Unsave'
						icon: '🗙'
					}
				else
					{
						action: -> api.submit(api.ID('comment_save', data.id), {})
						description: 'Save'
						icon: '💾'
					}
			3: (data) ->
				action: ->
				description: 'Reply'
				icon: '💬'
			4: (data) ->
				action: -> console.log data.id
				description: 'Report'
				icon: '🚩'

		alt:
			1: (data) ->
				action: ->
				description: ''
				icon: ''
			2: (data) ->
				action: ->
				description: ''
				icon: ''
			3: (data) ->
				action: ->
				description: 'Edit'
				icon: ''
			4: (data) ->
				action: ->
				description: 'Delete'
				icon: ''

		shift: 
			1: (data) ->
				action: ->
				description: ''
				icon: ''
			2: (data) ->
				action: ->
				description: ''
				icon: ''
			3: (data) ->
				action: ->
				description: ''
				icon: ''
			4: (data) ->
				action: ->
				description: ''
				icon: ''

		ctrl:
			1: (data) ->
				if data.locked
					{
						action: ->
						description: 'Unlock'
						icon: '🔑'
					}
				else
					{
						action: ->
						description: 'Lock'
						icon: '🔒'
					}
			2: (data) ->
				action: ->
				description: 'Approve'
				icon: '✅'
			3: (data) ->
				action: ->
				description: 'Ban User'
				icon: '💀'
			4: (data) ->
				action: ->
				description: 'Remove'
				icon: '❌'

		ctrlAlt:
			1: (data) ->
				action: ->
				description: ''
				icon: ''
			2: (data) ->
				action: ->
				description: ''
				icon: ''
			3: (data) ->
				action: ->
				description: ''
				icon: '⚙️'
			4: (data) ->
				action: ->
				description: 'Remove as Spam'
				icon: '💩'

		ctrlShift:
			1: (data) ->
				action: ->
				description: 'Ban User'
				icon: '💀'
			2: (data) ->
				if data.reportsIgnored
					{
						action: ->
						description: 'Receive Reports'
						icon: '👂'
					}
				else
					{
						action: ->
						description: 'Ignore Reports'
						icon: '🙉'
					}
			3: (data) ->
				action: ->
				description: ''
				icon: ''
			4: (data) ->
				action: ->
				description: ''
				icon: ''
		
		ctrlShiftAlt:
			1: (data) ->
				action: ->
				description: ''
				icon: '⚙️'
			2: (data) ->
				action: ->
				description: ''
				icon: ''
			3: (data) ->
				action: ->
				description: ''
				icon: ''
			4: (data) ->
				action: ->
				description: 'Remove Chain'
				icon: '💣'

	post:

		default:
			1: (data) ->
				action: ->
				description: 'Share'
				icon: ''
			2: (data) ->
				if data.saved
					{
						action: -> api.submit(api.ID('post_save', data.id), { unsave: true })
						description: 'Unsave'
						icon: '🗙'
					}
				else
					{
						action: -> api.submit(api.ID('post_save', data.id), {})
						description: 'Save'
						icon: '💾'
					}
			3: (data) ->
				action: ->
				description: 'Reply'
				icon: '💬'
			4: (data) ->
				action: -> console.log data.id
				description: 'Report'
				icon: '🚩'

		alt:
			1: (data) ->
				action: ->
				description: ''
				icon: ''
			2: (data) ->
				action: ->
				description: 'Add to Collection'
				icon: ''
			3: (data) ->
				action: ->
				description: 'Edit'
				icon: ''
			4: (data) ->
				action: ->
				description: 'Delete'
				icon: '💣'
		
		ctrlAlt:
			1: (data) ->
				if data.stickied
					{
						action: ->
						description: 'Unset as Sticky'
						icon: '🗙'
					}
				else
					{
						action: ->
						description: 'Set as Sticky'
						icon: '📗'
					}
			2: (data) ->
				action: ->
				description: ''
				icon: ''
			3: (data) ->
				action: ->
				description: 'Set Crowd Control Level'
				icon: ''
			4: (data) ->
				action: ->
				description: ''
				icon: ''
		
		ctrlAltShift:
			1: (data) ->
				action: ->
				description: ''
				icon: ''
			2: (data) ->
				if data.contestMode
					{
						action: ->
						description: 'Unset Contest Mode'
						icon: '🗙'
					}
				else
					{
						action: ->
						description: 'Set Contest Mode'
						icon: '🏆'
					}
			3: (data) ->
				action: ->
				description: 'Set Suggested Sort'
				icon: ''
			4: (data) ->
				action: ->
				description: ''
				icon: ''

}