import Feed from './Feed.coffee'
import { getListingSlice } from '../API.coffee'

export default class MultiredditFeed extends Feed
	
	constructor: ({ user, name, sort }) ->
		super()
		this.sections =
			if user is 'r' and name is 'popular' or name is 'all'
				[
					{
						description: sort + ' Posts'
						get: ->
							cached user + '/' + name + '/' + sort, ->
								getListingSlice
									endpoint: '/r/' + name + '/' + sort.split('-')[0]
									options:
										limit: 10
										t: sort.split('-')[1]
					}
				]
			else
				[]