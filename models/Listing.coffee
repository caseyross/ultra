import Award from './Award.coffee'
import Comment from './Comment.coffee'
import CompressedComments from './CompressedComments.coffee'
import DeeperComments from './DeeperComments.coffee'
import Message from './Message.coffee'
import Post from './Post.coffee'
import Subreddit from './Subreddit.coffee'
import User from './User.coffee'

export default class Listing

	constructor: (object) ->
		switch object?.kind
			when 'Listing'
				if object.data?.children instanceof Array
					return object.data.children.map (child) -> new Listing(child)
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
				if object.data.depth == 10 # "more" things at depth 10 aren't directly expandable; comments beneath them can only be seen by specifically requesting a comment tree that starts deeper than the parent post.
					return new DeeperComments(object.data)
				return new CompressedComments(object.data)