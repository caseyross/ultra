import Comment from './Comment'
import CommentsLoadable from './CommentsLoadable'
import Message from './Message'
import Post from './Post'

export default class Anythings
	constructor: (r) ->
		return [] unless r?.kind is 'Listing' and r?.data?.children instanceof Array
		return r.data.children.map (child) ->
			switch child.kind
				when 'Listing'
					new Anythings(child.data)
				when 't1'
					new Comment(child.data)
				when 't2'
					null #TODO
				when 't3'
					new Post { data: child.data } # TODO: Consider whether we can remove knowledge here
				when 't4'
					new Message(child.data)
				when 't5'
					null #TODO
				when 't6'
					null #TODO
				when 'more'
					new CommentsLoadable(child.data)