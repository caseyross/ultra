import UserSnapshot from './UserSnapshot'

export default class UserReference
	constructor: (name) ->
		@name = name
		@INFO = new LazyPromise =>
			API.get('user/' + name + '/about')
			.then ({ data }) => new UserSnapshot data