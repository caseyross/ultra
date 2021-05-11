import Comment from './Comment'
import CommentsLoadable from './CommentsLoadable'

export default class Comments
	constructor: (r) ->
		return [] unless r?.kind is 'Listing' and r?.data?.children instanceof Array
		return r.data.children.map (child) ->
			switch child.kind
				when 'Listing'
					new Comments(child.data)
				when 't1'
					new Comment(child.data)
				when 'more'
					new CommentsLoadable(child.data)