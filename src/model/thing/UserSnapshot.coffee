export default class UserSnapshot # TODO: better alignment with api response
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