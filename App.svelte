<template lang="pug">
    #main
        Post(post='{$chosen.post}')
        nav
            header
                input(type='text' bind:value='{subreddit}' on:change='{load_posts({ count: 8 })}' placeholder='POPULAR')
            PostList(posts='{posts}')
            footer
                button(on:mousedown='{load_posts({ count: 8, after: posts[posts.length - 1].name })}') +
        Comments(post='{$chosen.post}')
    +if('show_post_internals')
        #post-internals
            ValueInspectorTree(value='{$chosen.post}')
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
        flex: 0 0 20%
        display: flex
        flex-flow: column nowrap
        user-select: none
    button
    input
        text-align: center
        background: #333
        font-size: 32px
        font-weight: 900
    button
        width: 80px
        height: 80px
        color: #ccc
        &:hover
            background: wheat
            color: white
    input
        text-transform: uppercase
        &:focus
            outline: none
            background: wheat
            color: #333
    footer
        display: flex
        justify-content: center
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
    import { onMount, afterUpdate } from 'svelte'
    import { chosen, dom, history } from './core-state.js';
    import { decode_reddit_html_entities } from './tools.js'
    import Post from './Post.svelte'
    import PostList from './PostList.svelte'
    import Comments from './Comments.svelte'
    import ValueInspectorTree from './ValueInspectorTree.svelte'
    import gfycat_adjectives from './gfycat-adjectives.json';
    export subreddit = ''
    export posts = []
    export show_post_internals = false
    # docs: https://github.com/reddit-archive/reddit/wiki/OAuth2#application-only-oauth
    # docs: https://www.reddit.com/dev/api
    token_type = '';
    access_token = '';
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
        response = await fetch("https://oauth.reddit.com#{if subreddit then '/r/'+subreddit else ''}/hot?g=GLOBAL&limit=#{count}&after=#{after}", {
            method: 'GET'
            headers:
                'Authorization': "#{token_type} #{access_token}"
        })
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
                                    video_id = post.url[(post.url.lastIndexOf('/') + 1)...]
                                    adjective_1 = ''
                                    adjective_2 = ''
                                    animal = ''
                                    for word in gfycat_adjectives
                                        if video_id.startsWith word
                                            adjective_1 = word
                                            for word in gfycat_adjectives
                                                if video_id[adjective_1.length...].startsWith word
                                                    adjective_2 = word
                                                    animal = video_id[(adjective_1.length + adjective_2.length)...]
                                    post.source =
                                        'https://giant.gfycat.com/' +
                                        adjective_1[0].toUpperCase() +
                                        adjective_1[1...] +
                                        adjective_2[0].toUpperCase() +
                                        adjective_2[1...] +
                                        animal[0].toUpperCase() +
                                        animal[1...] +
                                        '.webm'
                                when 'imgur.com'
                                    post.type = 'image'
                                    post.source = post.url[0...8] + 'i.' + post.url[8...] + '.jpg'
                                when 'v.redd.it'
                                    post.type = 'video'
                                    post.source = post.media.reddit_video.fallback_url
                                else
                                    post.type = 'link'
                                    post.source = post.url
                else
                    post.type = 'unknown'
                    post.source = ''
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
</script>