import Comment from './Comment'
import MoreComments from './MoreComments'
import Post from './Post'

export default class Listing
	constructor: (r) ->
		return [] unless r?.kind is 'Listing' and r?.data?.children instanceof Array
		return r.data.children.map (child) ->
			switch child.kind
				when 'Listing'
					new Listing(child.data)
				when 't1'
					new Comment(child.data)
				when 't2'
					null #TODO
				when 't3'
					new Post(child.data)
				when 't4'
					null #TODO
				when 't5'
					null #TODO
				when 't6'
					null #TODO
				when 'more'
					new MoreComments(child.data)