import PostSnapshot from './PostSnapshot'
import ThingList from './ThingList'

export default class PostReference
	constructor: (id) ->
		@id = id
		@DATA = new LazyPromise ->
			API.get('comments/' + id)
			.then ([ posts, comments ]) ->
				{
					...(new ThingList(posts))[0],
					REPLIES: new LazyPromise ->
						Promise.resolve new ThingList(comments)
				}