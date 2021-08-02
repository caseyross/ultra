import Award from './award/Award.coffee'
import Comment from './comment/Comment.coffee'
import Message from './message/Message.coffee'
import MoreComments from './comment/MoreComments.coffee'
import Post from './post/Post.coffee'
import Subreddit from './subreddit/Subreddit.coffee'
import User from './user/User.coffee'

export default class Model

	constructor: (object) ->
		switch object?.kind
			when 'Listing'
				if object.data?.children instanceof Array
					return object.data.children.map (child) -> new Model(child)
				else
					return []
			when 't1'
				return new Comment(object.data)
			when 't2'
				return new User(object.data)
			when 't3'
				return new Post(object.data)
			when 't4'
				return new Message(object.data)
			when 't5'
				return new Subreddit(object.data)
			when 't6'
				return new Award(object.data)
			when 'more'
				return new MoreComments(object.data)