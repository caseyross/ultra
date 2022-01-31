export default class DeeperComments

	constructor: (data, postId) -> @[k] = v for k, v of {
		referenceId: data.parent_id
		postId: postId
	}