export default (url) -> switch (if url.hostname.startsWith('www') then url.hostname[4..] else url.hostname)
	when 'clips.twitch.tv'
		descriptor = url.pathname.split('/')[1]
		if descriptor?.length
			iframe_src: "https://clips.twitch.tv/embed?clip=#{descriptor}&parent=#{location.hostname}"
		else
			null
	when 'gfycat.com'
		descriptor = url.pathname.split('/')[1]
		if descriptor?.length
			iframe_src: "https://gfycat.com/ifr/#{descriptor}"
		else
			null
	when 'm.twitch.tv'
		descriptor = url.pathname.split('/')[2]
		if descriptor?.length
			iframe_src: "https://clips.twitch.tv/embed?clip=#{descriptor}&parent=#{location.hostname}"
		else
			null
	when 'redgifs.com'
		descriptor = url.pathname.split('/')[2]
		if descriptor?.length
			iframe_src: "https://redgifs.com/ifr/#{descriptor}"
		else
			null
	when 'twitch.tv'
		descriptor = url.pathname.split('/')[3]
		if descriptor?.length
			iframe_src: "https://clips.twitch.tv/embed?clip=#{descriptor}&parent=#{location.hostname}"
		else
			null
	when 'youtu.be'
		descriptor = url.pathname.split('/')[1]
		if descriptor?.length
			iframe_src: "https://www.youtube.com/embed/#{descriptor}"
			iframe_allow: 'accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
		else
			null
	when 'youtube.com'
		descriptor = url.searchParams.get('v')
		if descriptor?.length and url.pathname.split('/')[1] != 'clip' # clip URLs don't contain the information necessary for embedding
			iframe_src: "https://www.youtube.com/embed/#{descriptor}",
			iframe_allow: 'accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
		else
			null
	else
		null