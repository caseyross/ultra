import AllListing from '../listing/AllListing'
import FrontpageListing from '../listing/FrontpageListing'
import InboxListing from '../listing/InboxListing'
import MultiredditListing from '../listing/MultiredditListing'
import PopularListing from '../listing/PopularListing'
import SavedListing from '../listing/SavedListing'
import SubredditListing from '../listing/SubredditListing'
import UserListing from '../listing/UserListing'

import SubredditReference from '../thing/SubredditReference'
import UserReference from '../thing/UserReference'

export default class FeedState
	constructor: (url = location) ->
		[ _, w, x, y, z] = url.pathname.split('/')
		if w.length > 1 # then treat as SR/MR
			[w, x, y, z] =
				if w.includes('-')
					['c', w, x, y]
				else
					['r', w, x, y]
		@thing = null
		@listing = new FrontpageListing()
		switch w
			when 'c'
				@listing = new MultiredditListing(x) #TODO
			when 'm'
				@listing = new InboxListing(x) #TODO
			when 'r'
				switch x
					when 'all'
						@listing = new AllListing()
					when 'popular'
						@listing = new PopularListing()
					else
						@thing = new SubredditReference(x)
						@listing = new SubredditListing(x)
			when 's'
				@listing = new SavedListing(x) #TODO
			when 'u'
				@thing = new UserReference(x)
				@listing = new UserListing(x)
		@PAGE = @listing.PAGE
			after: (new URLSearchParams(url.search)).get 'after'
			seen: (new URLSearchParams(url.search)).get 'seen'
			limit: z
			sort: y
		@selection_id = url.hash[1..]