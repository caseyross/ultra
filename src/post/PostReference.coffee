import ThingArray from '../ThingArray.coffee'
import RepliesArray from '../comment/RepliesArray.coffee'
import Story from '../Story.coffee'

export default class PostReference extends Story

	constructor: ({ id }) ->
		super()
		this.id = id
		console.log this

	get: =>
		CacheKey 't3_' + this.id,
			API.get
				endpoint: '/comments/' + this.id
			.then ([ a, b ]) =>
				CacheKeySave 't3_' + this.id + '_comments',
					new RepliesArray(b, this.id)
				post = new ThingArray(a)[0]
				console.log post
				post