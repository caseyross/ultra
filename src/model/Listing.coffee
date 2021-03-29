import ModeledArray from './ModeledArray'

export default class Listing
	constructor: ->
		@id = ''
		@href = ''
		@display_name = ''
		@page_config = () ->
			url: ''
			options: {}
		@first_page = ({ sort, count }) =>
			new ListingPage
				listing: @,
				sort: sort,
				seen: 0,
				after: null,
				count: count
		@profile_config = () ->
			url: ''
		@PROFILE = new LazyPromise =>
			if @profile_config().url
				API.get @profile_config().url
				.then ({ data }) => new ListingProfile data
			else
				Promise.resolve null

class ListingPage
	constructor: ({ listing, sort, seen, after, count }) ->
		return new LazyPromise =>
			API.get listing.page_config(sort).url,
				{
					count: seen,
					after: after,
					limit: count,
					...listing.page_config(sort).options
				}
			.then (page_data) =>
				submissions = new ModeledArray(page_data)
				{
					listing,
					sort,
					submissions,
					NEXT_PAGE:
						if page_data.data.after
							new ListingPage {
								listing,
								sort,
								seen: seen + submissions.length,
								after: page_data.data.after,
								count
							}
						else
							Promise.resolve null
				}

class ListingProfile
	constructor: (r) ->
		@text =
			tagline: r.public_description_html
			sidebar: r.description_html
		@images =
			banner: r.banner_background_image or r.mobile_banner_image or r.banner_img or ''
			icon: r.community_icon or r.icon_img or ''
			header: r.header_img or ''
		@color = r.primary_color or r.key_color or 'transparent'
		@meta =
			create_date: new Date(r.created_utc * 1000)
			nsfw: r.over18
			online_user_count: r.active_user_count or r.accounts_active
			subscriber_count: r.subscribers