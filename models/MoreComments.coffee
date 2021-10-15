export default class MoreComments

	constructor: (data, postId) -> @[k] = v for k, v of {
		ids: data.children
		postId: postId
		replies: []
	}