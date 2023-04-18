import api from '../../../api/index.js'

export default {

	comment:

		default:

			0: (data) ->
				action: ->
				description: ''
				icon: ''
			1: (data) ->
				action: ->
				description: 'Report'
				icon: '🚩'
			2: (data) ->
				action: ->
				description: 'Reply'
				icon: '💬'
			3: (data) ->
				if data.saved
					{
						action: -> api.submit(api.ID('comment_save', data.id), { unsave: true })
						description: 'Unsave'
						icon: '🗑️'
					}
				else
					{
						action: -> api.submit(api.ID('comment_save', data.id), {})
						description: 'Save'
						icon: '💾'
					}
			4: (data) ->
				action: ->
				description: ''
				icon: ''

		ctrl:

			0: (data) ->
				action: ->
				description: ''
				icon: ''
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
				description: 'Remove'
				icon: '❌'
			3: (data) ->
				action: ->
				description: 'Ban User'
				icon: '💀'
			4: (data) ->
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

		ctrlShift:
			0: (data) ->
				action: ->
				description: ''
				icon: ''
			1: (data) ->
				action: ->
				description: ''
				icon: '⚙️'
			2: (data) ->
				action: ->
				description: 'Remove'
				icon: '❌'
			3: (data) ->
				action: ->
				description: 'Ban User'
				icon: '💀'
			4: (data) ->
				if data.commentReportsIgnored
					{
						action: ->
						description: 'Unignore Reports'
						icon: '👂'
					}
				else
					{
						action: ->
						description: 'Ignore Reports'
						icon: '🙉'
					}

	post:

		default:

			0: (data) ->
				action: ->
				description: ''
				icon: ''
			1: (data) ->
				action: ->
				description: 'Report'
				icon: '🚩'
			2: (data) ->
				action: ->
				description: 'Reply'
				icon: '💬'
			3: (data) ->
				if data.saved
					{
						action: -> api.submit(api.ID('post_save', data.id), { unsave: true })
						description: 'Unsave'
						icon: '🗑️'
					}
				else
					{
						action: -> api.submit(api.ID('post_save', data.id), {})
						description: 'Save'
						icon: '💾'
					}
			4: (data) ->
				action: ->
				description: ''
				icon: ''

}