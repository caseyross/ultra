<template lang="pug">
    #main
        section#story-pane
            +if('selected_story.linked_story')
                article#story-reddit(bind:this='{dom.story_reddit}')
                    CommentTree(comment='{selected_story.linked_story}' op_id='{selected_story.linked_story.author_fullname}' focus_comment_id='{selected_story.linked_story.focus_comment_id}')
                +elseif('selected_story.is_self')
                    +if('selected_story.selftext_html')
                        article#story-text(bind:this='{dom.story_text}') {@html decode_reddit_html_entities(selected_story.selftext_html.slice(43, selected_story.selftext_html.length - 34))}
                        +else
                            article#story-notext NO TEXT
                +elseif('selected_story.post_hint === "image"')
                    a(href='{selected_story.url}')
                        img#story-image(src='{selected_story.url}')
                +elseif('selected_story.post_hint === "hosted:video"')
                    video#story-video(autoplay controls muted='false' src='{selected_story.media.reddit_video.fallback_url}')
                +elseif('selected_story.url')
                    iframe#story-embed(src='{selected_story.url}' sandbox='allow-scripts allow-same-origin')
        nav
            header
                input(type='text' bind:value='{subreddit}' on:change='{load_stories({ count: 8 })}' placeholder='POPULAR')
            #stories-list
                +each('stories as story')
                    article.story-brochure(on:mousedown='{select_story(story)}' class:story-brochure-stickied='{story.stickied}' class:story-brochure-read='{read_stories.has(story.id)}' class:story-brochure-selected='{selected_story.id === story.id}')
                        .story-colorbar
                        h1.story-headline {decode_reddit_html_entities(story.title)}
            footer
                button(on:mousedown='{load_stories({ count: 8, after: stories[stories.length - 1].name })}') +
        section#comments-pane
            #comments(bind:this='{dom.comments}' on:scroll='{move_minimap_cursor()}' on:mousedown='{teleport_via_minimap}')
                +if('selected_story.num_comments > 0')
                    CommentTree(comment='{selected_story}' op_id='{selected_story.author_fullname}')
                    +elseif('selected_story.num_comments === 0')
                        #nocomments NO COMMENTS
            figure#minimap(bind:this='{dom.minimap}')
                canvas#minimap-field(bind:this='{dom.minimap_field}')
                mark#minimap-cursor(bind:this='{dom.minimap_cursor}')
</template>

<style type="text/stylus">
    #main
        height: 100%
        display: flex
        font: 400 16px/1 "Iosevka Aile"
        word-break: break-word
    #story-pane
        flex: 1 0 33%
        display: flex
        flex-flow: column nowrap
        justify-content: space-around
        align-items: flex-end
        background: #675e56
        color: white
    nav
        flex: 0 0 17%
        display: flex
        flex-flow: column nowrap
        justify-content: space-between
        background: #675e56
        color: white
        user-select: none
    #comments-pane
        flex: 0 1 50%
        contain: strict
        background: #fed
    #comments
        width: 100%
        height: 100%
        padding-bottom: 16px
        overflow: auto
    #nocomments
        width: 100%
        height: 100%
        display: flex
        justify-content: center
        align-items: center
        text-align: center
        font-size: 120px
        color: wheat
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
    #stories-list
        overflow: auto
    .story-brochure
        cursor: pointer
        display: flex
    .story-brochure-selected
        background: #333
    .story-brochure-stickied
        background: darkseagreen
    .story-colorbar
        flex: 0 0 8px
        background: white
        .story-brochure-stickied &
            background: darkseagreen
        .story-brochure-read &
            background: gray
        .story-brochure-selected &
            background: wheat
    .story-headline
        padding: 8px 16px 8px 16px
        font-size: 16px
        font-weight: 300
        .story-brochure-read &
            color: gray
        .story-brochure-selected &
            color: wheat
    footer
        display: flex
        justify-content: center
    #story-reddit
        width: 100%
        height: 100%
        overflow: auto
        background: #fed
        color: black
    #story-text
        max-height: 100%
        padding: 24px
        overflow: auto
        font-weight: normal
        font-size: 14px
        line-height: 1.2
    #story-notext
        width: 100%
        text-align: center
        font-size: 240px
        color: #333
    a
        max-height: 100%
    #story-embed
        width: 100%
        height: 100%
        background: white
</style>

<script type="text/coffeescript">
    import { onMount, afterUpdate } from 'svelte'
    import CommentTree from './CommentTree.svelte'
    export dom =
        story_text: {}
        story_reddit: {}
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
        for story in stories
            load_comments story
            if story.domain.endsWith('reddit.com') and story.url.split('/')[6]
                load_linked_story story
    load_comments = (story) ->
        response = await fetch("https://oauth.reddit.com/comments/#{story.id}", {
            method: 'GET'
            headers:
                'Authorization': "#{token_type} #{access_token}"
        })
        [..., comments] = await response.json()
        story.replies = comments
        streamline_reply_datastructs story
    load_linked_story = (story) ->
        linked_story_id = story.url.split('/')[6]
        linked_comment_id = story.url.split('/')[8]
        linked_comment_context = story.url.split("context=")[1]?.split('&')[0]
        response = await fetch("https://oauth.reddit.com/comments/#{linked_story_id}?comment=#{linked_comment_id}&context=#{linked_comment_context}", {
            method: 'GET'
            headers:
                'Authorization': "#{token_type} #{access_token}"
        })
        [linked_story, linked_comments] = await response.json()
        story.linked_story = linked_story.data.children[0].data
        story.linked_story.replies = linked_comments
        story.linked_story.focus_comment_id = linked_comment_id
        streamline_reply_datastructs story.linked_story
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
        dom.story_reddit?.scrollTop = 0
        dom.story_text?.scrollTop = 0
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
            if dom.comments.scrollHeight > dom.comments.clientHeight
                dom.minimap_cursor.style.height = "#{(dom.comments.clientHeight - 34) * dom.comments.clientHeight / dom.comments.scrollHeight}px"
            else
                dom.minimap_cursor.style.height = 0
            # Clear minimap symbols
            ctx = dom.minimap_field.getContext '2d'
            ctx.clearRect(0, 0, dom.minimap_field.width, dom.minimap_field.height)
            # Draw new minimap symbols
            ctx.fillStyle = 'gray'
            if dom.comments.children.length > 1
                for comment in dom.comments.children
                    ctx.fillRect(0, Math.floor(comment.offsetTop / dom.comments.scrollHeight * dom.minimap.clientHeight), dom.minimap.clientWidth, 1)
            memories.previous_story_id = selected_story.id
            memories.previous_comments_scrollheight = dom.comments.scrollHeight
</script>