export default (source_url) ->
	switch (if source_url?.hostname.startsWith('www') then source_url?.hostname[4..] else source_url?.hostname)
		when 'clips.twitch.tv'
			descriptor = source_url.pathname.split('/')[1]
			if descriptor?.length
				iframe_url: "https://clips.twitch.tv/embed?clip=#{descriptor}&parent=#{location.hostname}"
		when 'm.twitch.tv'
			descriptor = source_url.pathname.split('/')[2]
			if descriptor?.length
				iframe_url: "https://clips.twitch.tv/embed?clip=#{descriptor}&parent=#{location.hostname}"
		when 'mobile.twitter.com'
			html: "<blockquote class='twitter-tweet' data-dnt='true'><a href=#{source_url}>#{source_url}</a></blockquote>"
			script: 'twitter'
		when 'open.spotify.com'
			descriptor = source_url.pathname?.slice(1)
			if descriptor?.length
				iframe_allow: 'encrypted-media'
				iframe_url: "https://open.spotify.com/embed/#{descriptor}"
		when 'redgifs.com'
			descriptor = source_url.pathname.split('/')[2]
			if descriptor?.length
				iframe_url: "https://redgifs.com/ifr/#{descriptor}"
		when 'streamable.com'
			descriptor = source_url.pathname.split('/')[1]
			if descriptor?.length
				iframe_aspect_ratio: 3 / 2
				iframe_url: "https://streamable.com/o/#{descriptor}"
		when 'twitch.tv'
			descriptor = source_url.pathname.split('/').at(-1)
			if descriptor?.length
				iframe_url: "https://clips.twitch.tv/embed?clip=#{descriptor}&parent=#{location.hostname}"
		when 'twitter.com'
			html: "<blockquote class='twitter-tweet' data-dnt='true'><a href=#{source_url}>#{source_url}</a></blockquote>"
			script: 'twitter'
		when 'x.com'
			html: "<blockquote class='twitter-tweet' data-dnt='true'><a href=#{String(source_url).replace('x.com', 'twitter.com')}>#{source_url}</a></blockquote>"
			script: 'twitter'
		when 'youtu.be'
			descriptor = source_url.pathname.split('/')[1]
			if descriptor?.length
				iframe_allow: 'accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
				iframe_url: "https://www.youtube.com/embed/#{descriptor}"
		when 'youtube.com'
			descriptor = source_url.searchParams.get('v')
			if descriptor?.length and source_url.pathname.split('/')[1] != 'clip' # clip URLs don't contain the information necessary for embedding
				iframe_allow: 'accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
				iframe_url: "https://www.youtube.com/embed/#{descriptor}"