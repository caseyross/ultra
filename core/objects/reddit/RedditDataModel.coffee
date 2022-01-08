import Award from './Award.coffee'
import Comment from './Comment.coffee'
import CompressedComments from './CompressedComments.coffee'
import DeeperComments from './DeeperComments.coffee'
import PrivateMessage from './PrivateMessage.coffee'
import Post from './Post.coffee'
import Subreddit from './Subreddit.coffee'
import User from './User.coffee'

export default class RedditDataModel
	constructor: (object) ->
		switch object?.kind
			when 'Listing'
				if object.data?.children instanceof Array
					return object.data.children.map (child) -> new RedditDataModel(child)
				return []
			when 't1'
				return new Comment(object.data)
			when 'more'
				if object.data.depth == 10
					 # Objects of type "more" at depth 10 aren't directly expandable.
					 # To see those comments, we need to load comment trees where they appear before depth 10.
					 # On the official site, these objects are displayed as "Continue this thread" links.
					return new DeeperComments(object.data)
				return new CompressedComments(object.data)
			when 't2'
				return new User(object.data)
			when 't3'
				return new Post(object.data)
			when 't4'
				return new PrivateMessage(object.data)
			when 't5'
				return new Subreddit(object.data)
			when 't6'
				return new Award(object.data)