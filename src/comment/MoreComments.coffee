export default class MoreComments

	constructor: (data, post_id) ->  @[k] = v for k, v of {
		ids: data.children
		post_id: post_id
		comments: new Promise((f, r) -> {})
	}

	getComments: ->
		this.comments = API.get
			endpoint: '/api/morechildren'
			options:
				link_id: 't3_' + this.post_id
				children: this.ids