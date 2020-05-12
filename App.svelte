<template lang="pug">
    #main
        section#story-pane
            +if('selected_story.linked_story')
                article#story-reddit(bind:this='{dom.story_reddit}')
                    CommentTree(comment='{selected_story.linked_story}' op_id='{selected_story.linked_story.author_fullname}' focus_comment_id='{selected_story.linked_story.focus_comment_id}')
                +elseif('story_type === "link"')
                    iframe#story-embed(src='{story_source}' sandbox='allow-scripts allow-same-origin')
                +elseif('story_type === "video"')
                    video#story-video(autoplay controls muted='false' src='{story_source}')
                +elseif('story_type === "image"')
                    a(href='{story_source}' target='_blank')
                        img#story-image(src='{story_source}')
                +elseif('story_type === "text"')
                    +if('story_source.length')
                        article#story-text(bind:this='{dom.story_text}') {@html story_source}
                        +else
                            article#story-notext NO TEXT
        nav
            header
                input(type='text' bind:value='{subreddit}' on:change='{load_stories({ count: 8 })}' placeholder='POPULAR')
            #stories-list
                +each('stories as story')
                    article.story-brochure(
                        on:mousedown='{select_story(story)}'
                        on:dblclick='{debug_objects.push(story)}'
                        class:story-brochure-stickied='{story.stickied}'
                        class:story-brochure-priority-1='{story.priority === 1}'
                        class:story-brochure-priority-2='{story.priority === 2}'
                        class:story-brochure-priority-3='{story.priority === 3}'
                        class:story-brochure-priority-4='{story.priority === 4}'
                        class:story-brochure-priority-5='{story.priority === 5}'
                        class:story-brochure-priority-6='{story.priority === 6}'
                        class:story-brochure-read='{read_stories.has(story.id)}'
                        class:story-brochure-selected='{selected_story.id === story.id}'
                    )
                        .story-aux
                            span.story-subreddit-label {story.subreddit}
                            +if('story.link_flair_text')
                                span.story-flair {story.link_flair_text}
                        .story-main
                            figure.story-colorbar
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
    +if('show_debugger')
        #debug-pane
            DebugView(objects='{debug_objects}')
</template>

<style type="text/stylus">
    #main
        height: 100%
        display: flex
        font: 300 13px/1 "Iosevka Aile"
        word-break: break-word
        background: #222
        color: white
    #story-pane
        flex: 0 0 40%
        padding: 0 24px 0 0
        display: flex
        flex-flow: column nowrap
        align-items: flex-end
    nav
        flex: 0 0 20%
        display: flex
        flex-flow: column nowrap
        user-select: none
    #comments-pane
        flex: 0 0 40%
        contain: strict
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
        font-size: 14px
        font-weight: 900
        color: salmon
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
        flex: 1 1 auto
        overflow: auto
    .story-brochure
        padding: 12px 0
        cursor: pointer
    .story-brochure-priority-1
        color: salmon
        & .story-subreddit-label
        & .story-colorbar
            background: salmon
    .story-brochure-priority-2
        color: lightsalmon
        & .story-subreddit-label
        & .story-colorbar
            background: lightsalmon
    .story-brochure-priority-3
        color: wheat
        & .story-subreddit-label
        & .story-colorbar
            background: wheat
    .story-brochure-priority-4
        color: white
        & .story-subreddit-label
        & .story-colorbar
            background: white
    .story-brochure-priority-5
        color: lightgray
        & .story-subreddit-label
        & .story-colorbar
            background: lightgray
    .story-brochure-priority-6
        color: gray
        & .story-subreddit-label
        & .story-colorbar
            background: gray
    .story-brochure-selected
        background: #666
    .story-brochure-stickied
        background: darkseagreen
    .story-aux
        margin-bottom: 8px
        font-size: 12px
        font-weight: 900
        color: #222
    .story-flair
        color: gray
        margin-left: 16px
    .story-main
        display: flex
    .story-colorbar
        flex: 0 0 2px
        .story-brochure-stickied &
            background: darkseagreen
        .story-brochure-read &
            visibility: hidden
    .story-headline
        margin: 0 16px 0 8px
        font-size: 16px
        .story-brochure-stickied &
            color: white
    footer
        display: flex
        justify-content: center
    #story-reddit
        width: 100%
        height: 100%
        overflow: auto
    #story-text
        max-height: 100%
        padding: 20px 12px
        overflow: auto
        line-height: 1.3
    #story-notext
        width: 100%
        height: 100%
        display: flex
        justify-content: center
        align-items: center
        font-size: 14px
        font-weight: 900
        color: salmon
    a
        max-height: 100%
    #story-embed
        width: 100%
        height: 100%
        background: white
    #debug-pane
        position: fixed
        top: 0
        width: 100%
        height: 100%
</style>

<script type="text/coffeescript">
    import { onMount, afterUpdate } from 'svelte'
    import CommentTree from './CommentTree.svelte'
    import DebugView from './DebugView.svelte'
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
    export story_type = 'unknown'
    export story_source = ''
    export selected_story =
        id: ''
        replies: []
    export read_stories = new Set()
    export held_keys = new Set()
    export show_debugger = false
    export debug_objects = []
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
            comment_affinity = if story.score then story.num_comments / story.score else 0.01
            participation_affinity = if story.subreddit_subscribers then story.num_comments / story.subreddit_subscribers else 0.00001
            story.priority = switch
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
    identify_story_type_and_source = (story) ->
        if story.is_self
            story_type = 'text'
            story_source = if story.selftext_html
                decode_reddit_html_entities(story.selftext_html.slice(43, story.selftext_html.length - 34))
            else
                ''
        else if story.url
            filetype = ''
            [i, j, k] = [story.url.indexOf('.', story.url.indexOf('/', story.url.indexOf('//') + 2) + 1), story.url.indexOf('?'), story.url.indexOf('#')]
            if j > -1
                filetype = story.url[(i + 1)...j]
            else if k > -1
                filetype = story.url[(i + 1)...k]
            else if i > -1
                filetype = story.url[(i + 1)...]
            switch filetype
                when 'jpg', 'png', 'gif'
                    story_type = 'image'
                    story_source = story.url
                when 'gifv'
                    story_type = 'video'
                    story_source = story.url[0...story.url.lastIndexOf('.')] + '.mp4'
                else
                    switch story.domain
                        when 'imgur.com'
                            story_type = 'image'
                            story_source = story.url[0...8] + 'i.' + story.url[8...] + '.jpg'
                        when 'v.redd.it'
                            story_type = 'video'
                            story_source = story.media.reddit_video.fallback_url
                        else
                            story_type = 'link'
                            story_source = story.url
        else
            story_type = 'unknown'
            story_source = ''
    select_story = (story) ->
        identify_story_type_and_source(story)
        selected_story = story
        dom.story_reddit?.scrollTop = 0
        dom.story_text?.scrollTop = 0
        dom.comments.scrollTop = 0
        read_stories.add story.id
        read_stories = read_stories
        debug_objects.length = 0
        debug_objects.push(story)
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
        # Add global event listeners
        document.addEventListener('keydown', (e) ->
            if e.key == 'Escape'
                show_debugger = !show_debugger
        )
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