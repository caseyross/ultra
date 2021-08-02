import { get } from '../API.coffee'

export default class MoreComments

	constructor: (data, post_id) -> @[k] = v for k, v of {
		ids: data.children
		post_id: post_id
	}

	load: =>
		get
			endpoint: '/api/morechildren'
			options:
				link_id: 't3_' + this.post_id
				children: this.ids