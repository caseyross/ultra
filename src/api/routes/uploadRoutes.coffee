import { post } from '../infra/requests.coffee'

export default {

	delete:      (targetId) ->
		post "/api/del", { id: targetId }
	edit:        (targetId, newText) ->
		post "/api/editusertext", { api_type: 'json', thing_id: targetId, text: newText }
	reply:       (targetId, text) ->
		post "/api/comment", { api_type: 'json', thing_id: targetId, text }
	save:        (targetId, categoryName) ->
		post "/api/save", { id: submissionId, category: categoryName }
	subscribe:   (...subredditNames) ->
		post "/api/subscribe", { action: 'sub', sr_name: subredditNames.join(',') }
	unsave:      (targetId) ->
		post "/api/unsave", { id: submissionId }
	unsubscribe: (...subredditNames) ->
		post "/api/subscribe", { action: 'unsub', sr_name: subredditNames.join(',') }
	vote:        (targetId, dir) ->
		post "/api/vote", { id: submissionId, dir }

}