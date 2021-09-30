export default class MoreComments

	constructor: (data, post_id) -> @[k] = v for k, v of {
		ids: data.children
		post_id: post_id
	}