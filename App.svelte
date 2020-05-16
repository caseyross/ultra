<template lang="pug">
    #main
        Post(post='{$chosen.post}')
        nav
            ListingNavigation
            PostList(posts='{posts}')
            footer
                button#back {'←'}
                button#forward(on:mousedown='{load_posts({ count: 8, after: posts[posts.length - 1].name })}') {$load.posts ? 'LOAD' : '― 2 →'}
        Comments(post='{$chosen.post}')
    +if('show_post_internals')
        #post-internals
            ValueInspector(value='{$chosen.post}')
</template>

<style type="text/stylus">
    #main
        height: 100%
        display: flex
        font: 300 13px/1 "Iosevka Aile"
        word-break: break-word
        background: #222
        color: white
    nav
        flex: 0 0 400px
        display: flex
        flex-flow: column nowrap
        user-select: none
    button
        height: 80px
        text-align: center
        font-size: 32px
        font-weight: 900
        background: #333
        color: #ccc
        &:hover
            background: wheat
            color: white
    footer
        display: flex
        justify-content: center
    #back
        flex: 0 0 33%
        opacity: 0.5
    #forward
        flex: 0 0 67%
    #post-internals
        position: fixed
        top: 0
        width: 100%
        height: 100%
        display: flex
        overflow: auto
        font: 700 12px/1.2 Iosevka
        background: #fed
</style>

<script type="text/coffeescript">
    import { onMount } from 'svelte'
    import { chosen, dom, load } from './core-state.coffee'
    import { decode_reddit_html_entities, titlecase_gfycat_video_id } from './tools.coffee'
    import ListingNavigation from './ListingNavigation.svelte'
    import PostList from './PostList.svelte'
    import Post from './Post.svelte'
    import Comments from './Comments.svelte'
    import ValueInspector from './ValueInspector.svelte'
    export posts = []
    export show_post_internals = false
    # docs: https://github.com/reddit-archive/reddit/wiki/OAuth2#application-only-oauth
    # docs: https://www.reddit.com/dev/api
    token_type = ''
    access_token = ''
    (() ->
        body = new FormData()
        body.append('grant_type', 'https://oauth.reddit.com/grants/installed_client')
        body.append('device_id', 'DO_NOT_TRACK_THIS_DEVICE')
        response = await fetch('https://www.reddit.com/api/v1/access_token', {
            method: 'POST'
            headers:
                'Authorization': 'Basic SjZVcUg0a1lRTkFFVWc6'
            body
        })
        { token_type, access_token } = await response.json()
        load_posts({ count: 8 })
    )()
    load_posts = ({ count, after }) ->
        $load.posts = true
        response = await fetch(
            'https://oauth.reddit.com' +
            (
                if $chosen.listing.type == 'user' then '/user/' else '/r/'
            ) +
            $chosen.listing.name +
            (
                if $chosen.listing.type == 'user'
                    switch $chosen.listing.rank_by.type
                        when 'top'
                            '?sort=top&t=' + $chosen.listing.rank_by.filter + '&'
                        when 'hot'
                            '?sort=hot&'
                        else
                            '?sort=new&'
                else
                    switch $chosen.listing.rank_by.type
                        when 'top'
                            '/top?t=' + $chosen.listing.rank_by.filter + '&'
                        when 'new'
                            '/new?'
                        else 
                            '/hot?' + if $chosen.listing.name == 'popular' then 'g=' + $chosen.listing.rank_by.filter + '&' else ''
            ) +
            'limit=' + $chosen.listing.page_size + '&' +
            'count=' + $chosen.listing.seen + '&' +
            if $chosen.listing.last_seen_post_id then 'after=' + $chosen.listing.last_seen_post_id else '',
            {
                method: 'GET'
                headers:
                    'Authorization': "#{token_type} #{access_token}"
            }
        )
        { data } = await response.json()
        posts = data.children.map (child) -> {
            child.data...
            replies: []
        }
        for post in posts
            if post.is_self
                    post.type = 'text'
                    post.source = if post.selftext_html
                        decode_reddit_html_entities(post.selftext_html.slice(43, post.selftext_html.length - 34))
                    else
                        ''
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
                                    post.source = post.url[0...8] + 'i.' + post.url[8...] + '.jpg'
                                when 'v.redd.it'
                                    post.type = 'video'
                                    post.source = post.media.reddit_video.fallback_url
                                when 'youtu.be', 'youtube.com'
                                    post.type = 'embed'
                                    post.source = decode_reddit_html_entities post.secure_media.oembed.html
                                else
                                    post.type = 'link'
                                    post.source = post.url
                else
                    post.type = 'unknown'
                    post.source = ''
            post.title = decode_reddit_html_entities post.title
            if !post.link_flair_text
                post.link_flair_text = ''
            comment_affinity = if post.score then post.num_comments / post.score else 0.01
            participation_affinity = if post.subreddit_subscribers then post.num_comments / post.subreddit_subscribers else 0.00001
            post.priority = switch
                when comment_affinity > 0.33
                    1
                when comment_affinity > 0.24
                    2
                when comment_affinity > 0.15
                    3
                when comment_affinity > 0.03
                    4
                when comment_affinity > 0.01
                    5
                else
                    6
            load_comments post
            if post.domain.endsWith('reddit.com') and post.url.split('/')[6]
                load_linked_post post
            $load.posts = false
    load_comments = (post) ->
        response = await fetch("https://oauth.reddit.com/comments/#{post.id}", {
            method: 'GET'
            headers:
                'Authorization': "#{token_type} #{access_token}"
        })
        [..., comments] = await response.json()
        post.replies = comments
        streamline_reply_datastructs post
    load_linked_post = (post) ->
        linked_post_id = post.url.split('/')[6]
        linked_comment_id = post.url.split('/')[8]
        linked_comment_context = post.url.split("context=")[1]?.split('&')[0]
        response = await fetch("https://oauth.reddit.com/comments/#{linked_post_id}?comment=#{linked_comment_id}&context=#{linked_comment_context}", {
            method: 'GET'
            headers:
                'Authorization': "#{token_type} #{access_token}"
        })
        [linked_post, linked_comments] = await response.json()
        post.linked_post = linked_post.data.children[0].data
        post.linked_post.replies = linked_comments
        post.linked_post.focus_comment_id = linked_comment_id
        streamline_reply_datastructs post.linked_post
    streamline_reply_datastructs = (comment) ->
        if comment.body_html
            comment.body_html = decode_reddit_html_entities comment.body_html.slice(22, comment.body_html.length - 13)
        if comment.replies?.data?.children
            if comment.replies.data.children.kind == 'more'
                comment.replies = []
            else
                comment.replies = comment.replies.data.children.map (child) -> child.data
                for comment in comment.replies
                    streamline_reply_datastructs comment
        else
            comment.replies = []
    onMount () ->
        # Add global event listeners
        document.addEventListener('keydown', (e) ->
            if e.key == 'Escape'
                show_post_internals = !show_post_internals
        )
    $: console.log $chosen.listing.rank_by.type
</script>