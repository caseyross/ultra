import Post from './Post'
import Listing from './Listing'

export default class PostReference
	constructor: (id) ->
		@id = id
		@DATA = new LazyPromise ->
			API.get('comments/' + id)
			.then ([ posts, comments ]) ->
				{
					...(new Listing(posts))[0],
					REPLIES: new LazyPromise ->
						Promise.resolve new Listing(comments)
				}