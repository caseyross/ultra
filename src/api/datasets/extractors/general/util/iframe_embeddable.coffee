export default (url) -> switch (if url.hostname.startsWith('www') then url.hostname[4..] else url.hostname)
	when 'clips.twitch.tv'
		descriptor = url.pathname.split('/')[1]
		if descriptor?.length
			iframe_height: 360
			iframe_url: "https://clips.twitch.tv/embed?clip=#{descriptor}&parent=#{location.hostname}"
			iframe_width: 640
		else
			null
	when 'gfycat.com'
		descriptor = url.pathname.split('/')[1]
		if descriptor?.length
			iframe_height: 360
			iframe_url: "https://gfycat.com/ifr/#{descriptor}"
			iframe_width: 640
		else
			null
	when 'm.twitch.tv'
		descriptor = url.pathname.split('/')[2]
		if descriptor?.length
			iframe_height: 360
			iframe_url: "https://clips.twitch.tv/embed?clip=#{descriptor}&parent=#{location.hostname}"
			iframe_width: 640
		else
			null
	when 'redgifs.com'
		descriptor = url.pathname.split('/')[2]
		if descriptor?.length
			iframe_height: 360
			iframe_url: "https://redgifs.com/ifr/#{descriptor}"
			iframe_width: 640
		else
			null
	when 'streamable.com'
		descriptor = url.pathname.split('/')[1]
		if descriptor?.length
			iframe_height: 360
			iframe_url: "https://streamable.com/o/#{descriptor}"
			iframe_width: 640
		else
			null
	when 'twitch.tv'
		descriptor = url.pathname.split('/')[3]
		if descriptor?.length
			iframe_height: 360
			iframe_url: "https://clips.twitch.tv/embed?clip=#{descriptor}&parent=#{location.hostname}"
			iframe_width: 640
		else
			null
	when 'youtu.be'
		descriptor = url.pathname.split('/')[1]
		if descriptor?.length
			iframe_allow: 'accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
			iframe_height: 360
			iframe_url: "https://www.youtube.com/embed/#{descriptor}"
			iframe_width: 640
		else
			null
	when 'youtube.com'
		descriptor = url.searchParams.get('v')
		if descriptor?.length and url.pathname.split('/')[1] != 'clip' # clip URLs don't contain the information necessary for embedding
			iframe_allow: 'accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
			iframe_height: 360
			iframe_url: "https://www.youtube.com/embed/#{descriptor}"
			iframe_width: 640
		else
			null
	else
		null