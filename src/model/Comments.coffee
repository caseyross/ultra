import Comment from './Comment'
import CommentsLoadable from './CommentsLoadable'

export default class Comments
	constructor: (d) ->
		return [] unless d?.kind is 'Listing' and d?.data?.children instanceof Array
		return d.data.children.map (child) ->
			switch child.kind
				when 'Listing'
					new Comments(child.data)
				when 't1'
					new Comment(child.data)
				when 'more'
					new CommentsLoadable(child.data)