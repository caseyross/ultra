export default {
	'gfycat.com': url =>
		({
			src: `https://gfycat.com/ifr/${url.pathname.split('/')[1]}`
		}),
	'redgifs.com': url =>
		({
			src: `https://redgifs.com/ifr/${url.pathname.split('/')[2]}`
		}),
	'clips.twitch.tv': url =>
		({
			src: `https://clips.twitch.tv/embed?clip=${url.pathname.split('/')[1]}&parent=${window.location.host}`
		}),
	'twitch.tv': url =>
		({
			src: `https://clips.twitch.tv/embed?clip=${url.pathname.split('/')[3]}&parent=${window.location.host}`
		}),
	'youtube.com': url =>
		({
			src: `https://www.youtube.com/embed/${url.searchParams.get('v')}`,
			allow: `accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture`
		}),
	'youtu.be': url =>
		({
			src: `https://www.youtube.com/embed/${url.pathname.split('/')[1]}`,
			allow: `accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture`
		})
}