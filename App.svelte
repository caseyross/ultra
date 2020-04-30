<template lang="pug">
    #main
        section#post
            +if('selected_story.is_self && selected_story.selftext_html')
                article#story-text(bind:this='{dom.story_text}') {@html decode_reddit_html_entities(selected_story.selftext_html.slice(43, selected_story.selftext_html.length - 34))}
                +elseif('selected_story.post_hint === "image"')
                    a(href='{selected_story.url}')
                        img#story-image(src='{selected_story.url}')
                +elseif('selected_story.post_hint === "hosted:video"')
                    video#story-video(autoplay controls muted='false' src='{selected_story.media.reddit_video.fallback_url}')
                +else
                    iframe#story-embedded-page(src='{selected_story.url}' sandbox='allow-scripts allow-same-origin')
        nav
            header
                input(type='text' bind:value='{subreddit}' on:change='{load_stories({ count: 8 })}' placeholder='POPULAR')
            #stories-list
                +each('stories as story')
                    article.story-brochure(on:click='{select_story(story)}' class:story-brochure-stickied='{story.stickied}' class:story-brochure-read='{read_stories.has(story.id)}' class:story-brochure-selected='{selected_story.id === story.id}')
                        h1.story-headline {decode_reddit_html_entities(story.title)}
            footer
                button(on:mousedown='{load_stories({ count: 8, after: stories[stories.length - 1].name })}') next 8
        section#comment-area
            #comments(bind:this='{dom.comments}' on:scroll='{move_minimap_cursor()}' on:mousedown='{teleport_via_minimap}')
                CommentTree(comment='{selected_story}' op_id='{selected_story.author_fullname}')
            figure#minimap(bind:this='{dom.minimap}')
                canvas#minimap-field(bind:this='{dom.minimap_field}')
                mark#minimap-cursor(bind:this='{dom.minimap_cursor}')
</template>

<style type="text/stylus">
    #main
        height: 100%
        display: flex
        font: bold 16px/1 "Iosevka Aile"
        word-break: break-word
    #post
        width: 640px
        display: flex
        flex-flow: column nowrap
        justify-content: space-around
        align-items: flex-end
        background: #222
        color: #ccc
    nav
        width: 320px
        display: flex
        flex-flow: column nowrap
        justify-content: space-between
        background: #222
        color: white
        user-select: none
    #comment-area
        flex: 1
        contain: strict
        background: #fed
    #comments
        width: 100%
        height: 100%
        overflow: auto
    #minimap
        position: absolute
        top: 0
        right: 16px
        width: 80px
        height: 100%
        padding: 17px 0
        pointer-events: none
    #minimap-cursor
        position: absolute
        top: 17px
        width: 100%
        display: block
        background: lightgray
        pointer-events: none
    button
    input
        padding: 24px
        font-size: 32px
        transition: color 0.1s
        &:hover
        &:focus
            outline: none
            color: royalblue
        &:active
            color: cornflowerblue
    button
        text-align: right
    input
        text-transform: uppercase
    #stories-list
        padding: 24px
        overflow: auto
    .story-brochure
        padding: 8px 0
        cursor: pointer
    .story-brochure-stickied
        color: darkseagreen
    .story-brochure-read
        color: gray
    .story-brochure-selected
        color: wheat
    #story-text
        max-height: 100%
        padding: 24px
        overflow: auto
        font-weight: normal
        font-size: 14px
    a
        max-height: 100%
    #story-embedded-page
        width: 100%
        height: 100%
</style>

<script type="text/coffeescript">
    import { onMount, afterUpdate } from 'svelte'
    import CommentTree from './CommentTree.svelte'
    export dom =
        story_text: {}
        comments: {}
        minimap: {}
        minimap_field: {}
        minimap_cursor: {}
    export memories =
        previous_story_id: ''
        previous_comments_scrollheight: 0
    export subreddit = ''
    export stories = []
    export selected_story =
        id: ''
        replies: []
    export read_stories = new Set()
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
        load_stories({ count: 8 })
    )()
    load_stories = ({ count, after }) ->
        response = await fetch("https://oauth.reddit.com#{if subreddit then '/r/'+subreddit else ''}/hot?g=GLOBAL&limit=#{count}&after=#{after}", {
            method: 'GET'
            headers:
                'Authorization': "#{token_type} #{access_token}"
        })
        { data } = await response.json()
        stories = data.children.map (child) -> {
            child.data...
            replies: []
        }
        stories.map (story) ->
            response = await fetch("https://oauth.reddit.com/comments/#{story.id}", {
                method: 'GET'
                headers:
                    'Authorization': "#{token_type} #{access_token}"
            })
            [..., comments] = await response.json()
            story.replies = comments
            console.log(story)
            streamline_reply_datastructs story
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
    decode_reddit_html_entities = (text) ->
        text
        .replace(/&amp;/g, '&')
        .replace(/&quot;/g, '"')
        .replace(/&lt;/g, '<')
        .replace(/&gt;/g, '>')
    select_story = (story) -> 
        selected_story = story
        if dom.story_text
            dom.story_text.scrollTop = 0
        dom.comments.scrollTop = 0
        read_stories.add story.id
        read_stories = read_stories
    move_minimap_cursor = () ->
        dom.minimap_cursor.style.transform = "translateY(#{dom.comments.scrollTop / dom.comments.scrollHeight * (dom.minimap.clientHeight - 34)}px)"
    teleport_via_minimap = (click) ->
        # If clicking on minimap, jump to that location in the comments
        if 0 < dom.comments.clientWidth - click.layerX < dom.minimap.clientWidth 
            dom.comments.scrollTop = (click.layerY - 17) / (dom.minimap.clientHeight - 34) * dom.comments.scrollHeight - dom.minimap.clientHeight / 2
    onMount () ->
        # Size minimap, because canvas elements can't be sized properly with pure CSS
        dom.minimap_field.width = dom.minimap.clientWidth
        dom.minimap_field.height = dom.minimap.clientHeight - 34
    afterUpdate () ->
        # Redraw minimap when comments change
        if selected_story.id != memories.previous_story_id or dom.comments.scrollHeight != memories.previous_comments_scrollheight
            # Resize cursor
            dom.minimap_cursor.style.height = "#{(dom.comments.clientHeight - 34) * dom.comments.clientHeight / dom.comments.scrollHeight}px"
            # Clear minimap symbols
            ctx = dom.minimap_field.getContext '2d'
            ctx.clearRect(0, 0, dom.minimap_field.width, dom.minimap_field.height)
            # Draw new minimap symbols
            ctx.fillStyle = 'gray'
            for comment in dom.comments.children
                ctx.fillRect(0, Math.floor(comment.offsetTop / dom.comments.scrollHeight * dom.minimap.clientHeight), dom.minimap.clientWidth, 1)
            memories.previous_story_id = selected_story.id
            memories.previous_comments_scrollheight = dom.comments.scrollHeight
</script>