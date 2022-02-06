export const iframes = {

	// Gfycat/RedGifs
	'gfycat.com': link =>
		({
			src: `https://gfycat.com/ifr/${link.pathname.split('/')[1]}`
		}),
	'redgifs.com': link =>
		({
			src: `https://redgifs.com/ifr/${link.pathname.split('/')[2]}`
		}),

	// Twitch
	'clips.twitch.tv': link =>
		({
			src: `https://clips.twitch.tv/embed?clip=${link.pathname.split('/')[1]}&parent=${window.location.hostname}`
		}),
	'twitch.tv': link =>
		({
			src: `https://clips.twitch.tv/embed?clip=${link.pathname.split('/')[3]}&parent=${window.location.hostname}`
		}),

	// YouTube
	'youtube.com': link => {
		if(link.pathname.split('/')[1] === 'clip') return null // clip URLs don't contain the information necessary for embedding
		return {
			src: `https://www.youtube.com/embed/${link.searchParams.get('v')}`,
			allow: `accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture`
		}
	},
	'youtu.be': link =>
		({
			src: `https://www.youtube.com/embed/${link.pathname.split('/')[1]}`,
			allow: `accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture`
		})
	
}