import Feed from './Feed.coffee'
import { getListingSlice } from '../API.coffee'

export default class SubredditOverviewFeed extends Feed

	constructor: ({ name }) ->
		super()
		this.sections = [
			{
				description: 'Stickied Posts'
				get: () =>
					getListingSlice
						endpoint: '/r/' + name + '/hot'
						options:
							limit: 2
					.then (x) -> x.filter (y) -> y.isStickied
			}
			{
				description: 'Newest Post'
				get: () =>
					getListingSlice
						endpoint: '/r/' + name + '/new'
						options:
							limit: 1
			}
			{
				description: 'Hot Posts'
				get: () =>
					getListingSlice
						endpoint: '/r/' + name + '/hot'
						options:
							limit: 9
					.then (x) -> x.filter (y) -> not y.isStickied
					.then (x) -> x.slice 0, 7
			}
		]