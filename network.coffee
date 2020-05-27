# docs: https://github.com/reddit-archive/reddit/wiki/OAuth2#application-only-oauth
# docs: https://www.reddit.com/dev/api

token_type = localStorage.token_type || ''
access_token = localStorage.access_token || ''
token_expire_date = localStorage.token_expire_date || 0
refresh_api_access_token = () ->
    body = new FormData()
    body.append('grant_type', 'https://oauth.reddit.com/grants/installed_client')
    body.append('device_id', 'DO_NOT_TRACK_THIS_DEVICE')
    fetch('https://www.reddit.com/api/v1/access_token', {
        method: 'POST'
        headers:
            'Authorization': 'Basic SjZVcUg0a1lRTkFFVWc6'
        body
    }).then((response) ->
        response.json()
    ).then((json_data) ->
        { token_type, access_token, expires_in } = json_data
        token_expire_date = Date.now() + expires_in * 999
        localStorage.token_type = token_type
        localStorage.access_token = access_token
        localStorage.token_expire_date = token_expire_date
    )

api_op = (http_method, resource_path) ->
    # If access token is already expired, block while getting a new one.
    # If access token is expiring soon, don't block the current operation, but pre-emptively request a new token.
    if Date.now() > token_expire_date
        await refresh_api_access_token()
    else if Date.now() > token_expire_date - 600000
        refresh_api_access_token()
    fetch(
        'https://oauth.reddit.com/' + resource_path + (if resource_path.includes('?') then '&' else '?') + 'raw_json=1' ,
        {
            method: http_method
            headers:
                'Authorization': "#{token_type} #{access_token}"
        }
    ).then((response) ->
        response.json()
    )

import { titlecase_gfycat_video_id } from './tools.coffee'
process_post = (post) ->
    if !post.link_flair_text then post.link_flair_text = ''
    if post.is_self
            post.type = 'text'
            post.source = if post.selftext_html then post.selftext_html[31...-20] else ''
        else if post.domain.endsWith 'reddit.com'
            post.type = 'reddit'
            [_, _, _, _, _, _, id, _, comment_id, options] = post.url.split '/'
            url_params = new URLSearchParams(options)
            post.source = {
                id
                comment_id
                context_level: url_params.get('context')
            }
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
                when 'jpg', 'png', 'gif'
                    post.type = 'image'
                    post.source = post.url
                when 'gifv'
                    post.type = 'video'
                    post.source = post.url[0...post.url.lastIndexOf('.')] + '.mp4'
                else
                    switch post.domain
                        when 'gfycat.com', 'redgifs.com'
                            post.type = 'video'
                            post.source = 'https://giant.gfycat.com/' + titlecase_gfycat_video_id(post.url[(post.url.lastIndexOf('/') + 1)...]) + '.webm'
                        when 'imgur.com'
                            post.type = 'image'
                            post.source = post.url + '.jpg'
                        when 'v.redd.it'
                            post.type = 'video'
                            post.source = post.media.reddit_video.fallback_url
                        when 'youtu.be', 'youtube.com'
                            post.type = 'embed'
                            post.source = post.secure_media.oembed.html
                        else
                            post.type = 'link'
                            post.source = post.url
        else
            post.type = 'unknown'
            post.source = ''
    if typeof post.source == 'string' and post.source.startsWith 'http://'
        post.source = 'https://' + post.source[7...]
    return post
get_feed_fragment = (feed_config, num_posts) ->
    load = api_op('GET',
        (if feed_config.type == 'user' then 'user/' else 'r/') +
        feed_config.name +
        (if feed_config.type == 'user' then "?sort=#{feed_config.rank_by.type}&" else "/#{feed_config.rank_by.type}?") +
        (if feed_config.rank_by.type == 'top' then "t=#{feed_config.rank_by.filter}&" else '') +
        (if feed_config.last_seen then "after=#{feed_config.last_seen}&" else '') +
        (if feed_config.seen_count then "count=#{feed_config.seen_count}" else '') +
        "limit=#{num_posts}"
    )
    [0...num_posts].map (i) ->
        load.then ({ data }) -> process_post data.children[i].data
export load_feed = (feed_config) ->
    stage_1 = get_feed_fragment(feed_config, 1)
    stage_2 = get_feed_fragment(feed_config, 3)
    stage_3 = get_feed_fragment(feed_config, 10)
    [
        Promise.race([stage_1[0], stage_2[0], stage_3[0]])
        Promise.race([stage_2[1], stage_3[1]])
        Promise.race([stage_2[2], stage_3[2]])
        stage_3[3]
        stage_3[4]
        stage_3[5]
        stage_3[6]
        stage_3[7]
        stage_3[8]
        stage_3[9]
    ]

streamline_reply_datastructs = (comment) ->
    if comment.body_html
        comment.body_html = comment.body_html[16...-6]
    if comment.replies?.data?.children
        if comment.replies.data.children.kind == 'more'
            comment.replies = []
        else
            comment.replies = comment.replies.data.children.map (child) -> child.data
            for comment in comment.replies
                streamline_reply_datastructs comment
    else
        comment.replies = []
export get_post_fragment = (post_id, comment_id, context_level) ->
    api_op('GET',
        "comments/#{post_id}" +
        (if comment_id then "?comment=#{comment_id}" else '') +
        (if context_level then "&context=#{context_level}" else '')
    ).then ( [post, comments] ) ->
        post_fragment = {
            ...post.data.children[0].data
            replies: comments
            fragment_center: comment_id
        }
        streamline_reply_datastructs post_fragment
        return post_fragment