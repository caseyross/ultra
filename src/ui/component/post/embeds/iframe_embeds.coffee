export default (source_url) ->
	
	switch (if source_url?.hostname.startsWith('www') then source_url?.hostname[4..] else source_url?.hostname)
		when 'clips.twitch.tv'
			descriptor = source_url.pathname.split('/')[1]
			if descriptor?.length
				iframe_action_description: 'Watch (Twitch)'
				iframe_aspect_ratio: 16/9
				iframe_url: "https://clips.twitch.tv/embed?clip=#{descriptor}&parent=#{location.hostname}"
			else
				null
		when 'gfycat.com'
			descriptor = source_url.pathname.split('/')[1]
			if descriptor?.length
				iframe_action_description: 'View (Gfycat)'
				iframe_aspect_ratio: 4/3
				iframe_url: "https://gfycat.com/ifr/#{descriptor}"
			else
				null
		when 'm.twitch.tv'
			descriptor = source_url.pathname.split('/')[2]
			if descriptor?.length
				iframe_action_description: 'Watch (Twitch)'
				iframe_aspect_ratio: 16/9
				iframe_url: "https://clips.twitch.tv/embed?clip=#{descriptor}&parent=#{location.hostname}"
			else
				null
		when 'open.spotify.com'
			descriptor = source_url.pathname?.slice(1)
			if descriptor?.length
				iframe_action_description: 'Listen (Spotify)'
				iframe_aspect_ratio: 1
				iframe_allow: 'encrypted-media'
				iframe_url: "https://open.spotify.com/embed/#{descriptor}"
			else
				null
		when 'redgifs.com'
			descriptor = source_url.pathname.split('/')[2]
			if descriptor?.length
				iframe_action_description: 'View (Redgifs)'
				iframe_aspect_ratio: 4/3
				iframe_url: "https://redgifs.com/ifr/#{descriptor}"
			else
				null
		when 'streamable.com'
			descriptor = source_url.pathname.split('/')[1]
			if descriptor?.length
				iframe_action_description: 'Watch (Streamable)'
				iframe_aspect_ratio: 4/3
				iframe_url: "https://streamable.com/o/#{descriptor}"
			else
				null
		when 'twitch.tv'
			descriptor = source_url.pathname.split('/').at(-1)
			if descriptor?.length
				iframe_action_description: 'Watch (Twitch)'
				iframe_aspect_ratio: 16/9
				iframe_url: "https://clips.twitch.tv/embed?clip=#{descriptor}&parent=#{location.hostname}"
			else
				null
		when 'youtu.be'
			descriptor = source_url.pathname.split('/')[1]
			if descriptor?.length
				iframe_action_description: 'Watch (YouTube)'
				iframe_allow: 'accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
				iframe_aspect_ratio: 16/9
				iframe_url: "https://www.youtube.com/embed/#{descriptor}"
			else
				null
		when 'youtube.com'
			descriptor = source_url.searchParams.get('v')
			if descriptor?.length and source_url.pathname.split('/')[1] != 'clip' # clip URLs don't contain the information necessary for embedding
				iframe_action_description: 'Watch (YouTube)'
				iframe_allow: 'accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
				iframe_aspect_ratio: 16/9
				iframe_url: "https://www.youtube.com/embed/#{descriptor}"
			else
				null
		else
			null