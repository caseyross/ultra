export sync_url = (new_url = '') ->
    # Enter new URL if provided
    if new_url
        history.pushState({}, new_url, new_url)
    # Read in feed configuration from URL path
    url_path = window.location.pathname.split('/')
    url_params = new URLSearchParams window.location.search[1...]
    feed = {
        name: url_path[2] || ''
        ...(switch url_path[1]
            when 'u', 'user'
                type: 'u'
                rank_by:
                    type: url_params.get('sort') || 'new'
                    filter: url_params.get('t') || ''
            else
                type: 'r'
                rank_by:
                    type: if url_path[2] then url_params.get('sort') || url_path[3] || 'hot' else 'best'
                    filter: switch url_params.get('sort') || url_path[3]
                        when 'top'
                            url_params.get('t') || 'day'
                        else
                            url_params.get('geo_filter') || 'GLOBAL'
        )
        seen_count: url_params.get('count') || 0
        after_id: url_params.get('after') || ''
        page_size: url_params.get('limit') || 25
    }
    feed.DATA = FETCH_FEED_DATA(feed)
    feed.METADATA = FETCH_FEED_METADATA(feed)
    return feed

# docs: https://github.com/reddit-archive/reddit/wiki/OAuth2#application-only-oauth
# docs: https://www.reddit.com/dev/api
token_type = localStorage.token_type || ''
access_token = localStorage.access_token || ''
token_expire_date = localStorage.token_expire_date || 0
REFRESH_API_TOKEN = () ->
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
GET_FROM_API = (endpoint) ->
    # If access token is already expired, block while getting a new one.
    # If access token is expiring soon, don't block the current operation, but pre-emptively request a new token.
    if Date.now() > token_expire_date
        await REFRESH_API_TOKEN()
    else if Date.now() > token_expire_date - 600000
        REFRESH_API_TOKEN()
    fetch(
        'https://oauth.reddit.com/' + endpoint + (if endpoint.includes('?') then '&' else '?') + 'raw_json=1' ,
        {
            method: 'GET'
            headers:
                'Authorization': "#{token_type} #{access_token}"
        }
    ).then (response) ->
        response.json()
FETCH_FEED_DATA = (feed) ->
    GET_FROM_API(
        (if feed.name is ''
            "#{feed.rank_by.type}?"
        else
            (if feed.type is 'u'
                "user/#{feed.name}?sort=#{feed.rank_by.type}&"
            else
                "r/#{feed.name}/#{feed.rank_by.type}?"
            )
        ) +
        "limit=#{feed.page_size}&" +
        (if feed.rank_by.type is 'top' then "t=#{feed.rank_by.filter}&" else '') +
        (if feed.after_id then "after=#{feed.after_id}&" else '') +
        (if feed.seen_count then "count=#{feed.seen_count}&" else '') +
        "sr_detail=true"
    ).then (posts_listing) ->
        rectified_posts(posts_listing)
FETCH_FEED_METADATA = (feed) ->
    if feed.name is '' then return new Promise (fulfill, reject) -> fulfill({})
    GET_FROM_API(
        "#{if feed.type is 'u' then 'user' else 'r'}/#{feed.name}/about"
    ).then ({ data }) -> ({
            ...data
            description_html: if data?.description_html then data.description_html[31...-20] else ''
    })
FETCH_COMMENTS = (post_id) ->
    GET_FROM_API(
        "comments/#{post_id}"
    ).then ( [_, comments_listing] ) ->
        rectified_comments(comments_listing)
FETCH_POST_AND_COMMENTS = (post_id, focal_comment_id, focal_comment_context_level) ->
    GET_FROM_API(
        "comments/#{post_id}" +
        (if focal_comment_id then "?comment=#{focal_comment_id}" else '') +
        (if focal_comment_context_level then "&context=#{focal_comment_context_level}" else '')
    ).then ( [posts_listing, comments_listing] ) -> ({
            ...rectified_posts(posts_listing)[0]
            COMMENTS: new Promise (fulfill, reject) -> fulfill(rectified_comments(comments_listing))
            comments_fetch_time: Date.now()
    })

import { titlecase_gfycat_video_id } from './tools.coffee'
rectified_posts = (posts_listing) ->
    posts_listing.data.children.map (child) ->
        post = child.data
        post.COMMENTS = new Promise (fulfill, reject) -> {}
        post.comments_fetch_time = null
        post.fetch_comments = () ->
            if not post.comments_fetch_time
                post.COMMENTS = FETCH_COMMENTS(post.id)
                post.comments_fetch_time = Date.now()
        post.link_flair_text = post.link_flair_text || ''
        if post.is_self
                post.type = 'text'
                post.source = if post.selftext_html then post.selftext_html[31...-20] else ''
            else if post.domain.endsWith 'reddit.com'
                if post.is_gallery
                    post.type = 'gallery'
                else
                    post.type = 'reddit'
                    [_, _, _, _, _, _, id, _, comment_id, options] = post.url.split '/'
                    url_params = new URLSearchParams(options)
                    post.source = {
                        id
                        comment_id
                        context_level: url_params.get('context')
                    }
                    post.SOURCE = FETCH_POST_AND_COMMENTS(post.source.id, post.source.comment_id, post.source.context_level)
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
                        post.type = 'image'
                        post.source = post.url
                    when 'gifv'
                        post.type = 'audiovideo'
                        post.source = {
                            video: post.url[0...post.url.lastIndexOf('.')] + '.mp4'
                        }
                    else
                        switch post.domain
                            when 'gfycat.com'
                                post.type = 'audiovideo'
                                post.source = {
                                    video: 'https://giant.gfycat.com/' + titlecase_gfycat_video_id(post.url[(post.url.lastIndexOf('/') + 1)...]) + '.webm'
                                }
                            when 'imgur.com'
                                post.type = 'image'
                                post.source = post.url + '.jpg'
                            when 'redgifs.com'
                                post.type = 'audiovideo'
                                post.source = {
                                    video: 'https://thumbs1.redgifs.com/' + titlecase_gfycat_video_id(post.url[(post.url.lastIndexOf('/') + 1)...]) + '.webm'
                                }
                            when 'v.redd.it'
                                post.type = 'audiovideo'
                                post.source = {
                                    audio: post.secure_media.reddit_video.fallback_url[...post.secure_media.reddit_video.fallback_url.lastIndexOf('/')] + '/audio'
                                    video: post.secure_media.reddit_video.fallback_url.split('?')[0]
                                    mini_video: post.secure_media.reddit_video.scrubber_media_url
                                }
                            when 'youtube.com', 'youtu.be' 
                                post.type = 'embed'
                                post.source = post.secure_media.oembed.html
                            else
                                post.type = 'link'
                                post.source = post.url
            else
                post.type = 'unknown'
                post.source = ''
        if typeof post.source is 'string' and post.source.startsWith 'http://'
            post.source = 'https://' + post.source[7...]
        return post
rectified_comments = (comments_listing) ->
    restructured_comments = (comments_listing) ->
        # No replies
        if not comments_listing?.data?.children
            []
        # Ill-formed response structures
        else if not comments_listing.data.children.length # Very rare: empty array
            []
        else if comments_listing.data.children[0].data.count is 0 # Rare: "more" with 0 replies in it
            []
        # Replies, or "more"
        else comments_listing.data.children.map (child) ->
            if child.kind is 'more'
                {
                    ...child.data
                    is_more: true
                    replies: []
                    body: ''
                    score_per_hour: 0
                }
            else
                {
                    ...child.data
                    is_more: false
                    replies: restructured_comments(child.data.replies)
                    body_html: child.data.body_html[16...-6]
                    score: child.data.score - 1 # Don't count the built-in upvote from the commenter
                    score_per_hour: (child.data.score - 1) * 3600 / (Date.now() / 1000 - child.data.created_utc)
                }
    post_skeleton = {
        score_per_hour: 0
        body: ''
        replies: restructured_comments(comments_listing)
    }
    comment_tree_score_per_hour = (comment) ->
        Math.abs(comment.score_per_hour) + comment.replies.reduce(((sum, reply) -> sum + comment_tree_score_per_hour(reply)), 0)
    total_score_per_hour = comment_tree_score_per_hour(post_skeleton)
    comment_tree_character_count = (comment) ->
        comment.body.length + comment.replies.reduce(((sum, reply) -> sum + comment_tree_character_count(reply)), 0)
    total_character_count = comment_tree_character_count(post_skeleton)
    estimate_interest = (comment) ->
        comment.score_per_hour_percentage = Math.trunc(comment.score_per_hour / total_score_per_hour * 100)
        comment.character_count_percentage = Math.trunc(comment.body.length / total_character_count * 100)
        comment.estimated_interest = if comment.score_hidden then 2 else comment.score_per_hour_percentage + comment.character_count_percentage
        for reply in comment.replies
            estimate_interest(reply)
    estimate_interest(post_skeleton)
    return post_skeleton.replies