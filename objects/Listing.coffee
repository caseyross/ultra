import Award from '/objects/Award'
import Comment from '/objects/Comment'
import Message from '/objects/Message'
import MoreComments from '/objects/MoreComments'
import Post from '/objects/Post'
import User from '/objects/User'
import Subreddit from '/objects/Subreddit'

export default class Listing
	constructor: (raw) ->
		return [] unless raw?.kind is 'Listing' and raw?.data?.children instanceof Array
		return raw.data.children.map (child) ->
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
				when 'more'
					new MoreComments(child.data)