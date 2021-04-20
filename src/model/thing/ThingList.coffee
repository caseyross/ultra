import CommentSnapshot from './CommentSnapshot'
import MoreCommentsReference from './MoreCommentsReference'
import PostSnapshot from './PostSnapshot'

export default class ThingList
	constructor: (r) ->
		return [] unless r?.kind is 'Listing' and r?.data?.children instanceof Array
		return r.data.children.map (child) ->
			switch child.kind
				when 'Listing'
					new ThingList(child.data)
				when 't1'
					new CommentSnapshot(child.data)
				when 't2'
					null #TODO
				when 't3'
					new PostSnapshot(child.data)
				when 't4'
					null #TODO
				when 't5'
					null #TODO
				when 't6'
					null #TODO
				when 'more'
					new MoreCommentsReference(child.data.children)