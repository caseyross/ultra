import Comment from './Comment.coffee'
import MoreComments from './MoreComments.coffee'

export default class RepliesArray

	constructor: (data, post_id) ->

		return [] unless data?.kind is 'Listing' and data?.data?.children instanceof Array
		return data.data.children.map (child) ->
			switch child.kind
				when 'Listing'
					new this(child.data, post_id)
				when 't1'
					new Comment(child.data)
				when 'more'
					new MoreComments(child.data, post_id)