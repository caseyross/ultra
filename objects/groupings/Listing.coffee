import Award from './Award.coffee'
import Comment from './Comment.coffee'
import Message from './Message.coffee'
import MoreComments from './MoreComments.coffee'
import Post from './Post.coffee'
import Subreddit from './Subreddit.coffee'
import User from './User.coffee'

export default class Listing

	constructor: (object) ->
		switch object?.kind
			when 'Listing'
				if object.data?.children instanceof Array
					return object.data.children.map (child) -> new Listing(child)
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