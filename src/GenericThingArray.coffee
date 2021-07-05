import Award from './award/Award.coffee'
import Comment from './comment/Comment.coffee'
import Message from './message/Message.coffee'
import Post from './post/Post.coffee'
import Subreddit from './subreddit/Subreddit.coffee'
import User from './user/User.coffee'

export default class GenericThingArray

	constructor: (data) ->

		return [] unless data?.kind is 'Listing' and data?.data?.children instanceof Array
		return data.data.children.map (child) =>
			switch child.kind
				when 'Listing'
					new this(child.data)
				when 't1'
					new Comment(child.data)
				when 't2'
					new User(child.data)
				when 't3'
					new Post(child.data)
				when 't4'
					new Message(child.data)
				when 't5'
					new Subreddit(child.data)
				when 't6'
					new Award(child.data)