import Award from './Award'
import Comment from './Comment'
import Feed from './Feed'
import Message from './Message'
import MoreComments from './MoreComments'
import Post from './Post'
import User from './User'

export default class List
	constructor: (r) ->
		return [] unless r?.kind is 'Listing' and r?.data?.children instanceof Array
		return r.data.children.map (child) ->
			switch child.kind
				when 'Listing'
					new List(child.data)
				when 't1'
					new Comment(child.data)
				when 't2'
					new User(child.data) #TODO
				when 't3'
					new Post(child.data)
				when 't4'
					new Message(child.data) #TODO
				when 't5'
					new Feed(child.data) #TODO
				when 't6'
					new Award(child.data) #TODO
				when 'more'
					new MoreComments(child.data)