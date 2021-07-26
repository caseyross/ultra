import Feed from './Feed.coffee'
import { getListingSlice } from '../API.coffee'

export default class SubredditFeed extends Feed
	
	constructor: ({ name, sort }) ->
		super()
		this.sections = [
			{
				description: sort + ' Posts'
				get: () =>
					cached 'r/' + name + '/' + sort, ->
						getListingSlice
							endpoint: '/r/' + name + '/' + sort.split('-')[0]
							options:
								limit: if sort is 'hot' then 12 else 10
								t: sort.split('-')[1]
					.then (x) -> x.filter (y) -> not y.isStickied
					.then (x) -> x.slice 0, 10
			}
		]