export classify_post_content = (post) ->
	content = null
	if post.is_self
		content =
			type: 'html'
			html: if post.selftext_html then post.selftext_html[31...-20] else ''
	else if post.media?.oembed
		content =
			type: 'html'
			html: post.media.oembed.html
	else if post.is_gallery
		content =
			type: 'images'
			images: post.gallery_data.items.map (image) -> ({
				url: post.media_metadata[image.media_id].s.u
				caption: image.caption
				caption_url: image.outbound_url
			})
	else if post.url
		filetype = ''
		[i, j, k] = [post.url.indexOf('.', post.url.indexOf('/', post.url.indexOf('//') + 2) + 1), post.url.indexOf('?'), post.url.indexOf('#')]
		if j > -1
			filetype = post.url[(i + 1)...j]
		else if k > -1
			filetype = post.url[(i + 1)...k]
		else if i > -1
			filetype = post.url[(i + 1)...]
		switch filetype
			when 'gif', 'jpg',  'jpeg', 'png', 'webp'
				content =
					type: 'image'
					url: post.url
			when 'gifv'
				content =
					type: 'video'
					url: post.url[0...post.url.lastIndexOf('.')] + '.mp4'
			else
				if post.domain
					if post.domain.endsWith 'reddit.com'
						[_, _, _, _, _, _, id, _, comment_id, options] = post.url.split '/'
						url_params = new URLSearchParams(options)
						content =
							type: 'post'
							POST: FETCH_POST_AND_COMMENTS(id, comment_id, url_params.get('context'))
					else switch post.domain
						when 'gfycat.com'
							content =
								type: 'video'
								url:'https://giant.gfycat.com/' + titlecase_gfycat_video_id(post.url[(post.url.lastIndexOf('/') + 1)...]) + '.webm'
						when 'imgur.com'
							content =
								type: 'image'
								url: post.url + '.jpg'
						when 'redgifs.com'
							content =
								type: 'video'
								url: 'https://thumbs1.redgifs.com/' + titlecase_gfycat_video_id(post.url[(post.url.lastIndexOf('/') + 1)...]) + '.webm'
						when 'v.redd.it'
							content =
								type: 'video'
								url: post.secure_media.reddit_video.fallback_url.split('?')[0]
								audio_url: post.secure_media.reddit_video.fallback_url[...post.secure_media.reddit_video.fallback_url.lastIndexOf('/')] + '/audio'
								preview_url: post.secure_media.reddit_video.scrubber_media_url
						when 'youtu.be'
							video_id = (new URL(post.url)).pathname[1..]
							content =
								type: 'html'
								html: "<iframe src='https://www.youtube.com/embed/#{video_id}?feature=oembed&amp;enablejsapi=1' frameborder='0' allow='accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture' allowfullscreen=''></iframe>"
						when 'youtube.com'
							video_id = (new URL(post.url)).searchParams.get('v')
							content =
								type: 'html'
								html: "<iframe src='https://www.youtube.com/embed/#{video_id}?feature=oembed&amp;enablejsapi=1' frameborder='0' allow='accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture' allowfullscreen=''></iframe>"
						else
							content =
								type: 'link'
								url: post.url
	# Rewrite HTTP URLs to use HTTPS
	if content?.url?.startsWith 'http://'
		content.url = 'https://' + content.url[7..]
	return content

import gfycat_adjectives from './gfycat-adjectives.json'
import gfycat_animals from './gfycat-animals.json'
titlecase_gfycat_video_id = (video_id) ->
    match_words = () ->
        for adjective_1 in gfycat_adjectives
            if video_id.startsWith adjective_1
                for adjective_2 in gfycat_adjectives
                    if video_id[adjective_1.length...].startsWith adjective_2
                        for animal in gfycat_animals
                            if video_id[(adjective_1.length + adjective_2.length)...] == animal
                                return [adjective_1, adjective_2, animal]
        return ['', '', '']
    [adjective_1, adjective_2, animal] = match_words()
    if not (adjective_1 and adjective_2 and animal)
        gfycat_adjectives.reverse()
        [adjective_1, adjective_2, animal] = match_words()
        gfycat_adjectives.reverse()
    if not (adjective_1 and adjective_2 and animal)
        return ''
    adjective_1[0].toUpperCase() + adjective_1[1...] + adjective_2[0].toUpperCase() + adjective_2[1...] + animal[0].toUpperCase() + animal[1...]