import api from '../../../api/index.js'

export default {

	comment:

		0: (dataset) ->
			api.submit(api.ID('comment_vote', dataset.short_id), {
				numerical_vote: if dataset.likes is 'true' then 0 else 1
			})

		1: (dataset) ->

		2: (dataset) ->

		3: (dataset) ->
			api.submit(api.ID('comment_vote', dataset.short_id), {
				numerical_vote: if dataset.likes is 'false' then 0 else -1
			})

		4: (dataset) ->

}