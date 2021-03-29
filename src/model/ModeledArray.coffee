import { Award, Comment, Message, MoreComments, Post, Subreddit, User } from './'

export default class ModeledArray
	constructor: (r) ->
		return [] unless r?.kind is 'Listing' and r?.data?.children instanceof Array
		return r.data.children.map (child) ->
			switch child.kind
				when 'Listing'
					new ModeledArray(child.data)
				when 't1'
					new Comment(child.data)
				when 't2'
					new User(child.data) #TODO
				when 't3'
					new Post({ data: child.data })
				when 't4'
					new Message(child.data) #TODO
				when 't5'
					new Subreddit(child.data) #TODO
				when 't6'
					new Award(child.data) #TODO
				when 'more'
					new MoreComments(child.data)