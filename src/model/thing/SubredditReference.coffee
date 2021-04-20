import SubredditSnapshot from './SubredditSnapshot'

export default class SubredditReference
	constructor: (name) ->
		@name = name
		@INFO = new LazyPromise =>
			API.get('r/' + name + '/about')
			.then ({ data }) => new SubredditSnapshot data