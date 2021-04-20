import PostSnapshot from './PostSnapshot'
import ThingList from './ThingList'

export default class PostReference
	constructor: (id) ->
		@id = id
		@DATA = new LazyPromise ->
			API.get('comments/' + id)
			.then ([ post_data, comments_data ]) ->
				new PostSnapshot({
					...post_data,
					replies: new ThingList(comments_data)
				})