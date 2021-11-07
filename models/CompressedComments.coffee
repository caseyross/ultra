export default class CompressedComments

	constructor: (data, postId) -> @[k] = v for k, v of {
		referenceId: data.id # 
		count: data.count
		postId: postId
	}