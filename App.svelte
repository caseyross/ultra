<template lang="pug">
    #main
        section#post
            +if('selected_story.is_self && selected_story.selftext')
                article#story-text {selected_story.selftext}
            +if('selected_story.post_hint === "image"')
                a(href='{selected_story.url}')
                    img#story-image(src='{selected_story.url}')
            +if('selected_story.post_hint === "hosted:video"')
                a(href='{selected_story.url}')
                    video#story-video(src='{selected_story.url}')
            +if('selected_story.post_hint === "link"')
                iframe#story-embedded-page(src='{selected_story.url}' sandbox='allow-scripts allow-same-origin')
        nav
            header
                button Popular
                button Niche
                input(type='text' bind:value='{subreddit}' on:change='{load_stories({ count: 10 })}')
            #stories-list
                +each('stories as story')
                    article.story-brochure(on:click='{select_story(story)}' class:read-story-brochure='{read_stories.has(story.id)}' class:selected-story-brochure='{selected_story.id === story.id}')
                        section.subreddit-label {story.subreddit}
                        section
                            +if('story.thumbnail !== "default" && story.thumbnail !== "self"')
                                img.story-thumbnail(src='{story.thumbnail}')
                            h1.story-headline {story.title}
            footer
                button(on:mousedown='{load_stories({ count: 10, after: stories[stories.length - 1].name })}') Load next 10
        section#comments(bind:this='{dom.comments}' on:scroll='{move_minimap_cursor()}' on:mousedown='{teleport_via_minimap}')
            CommentTree(comment='{selected_story}' op_id='{selected_story.author_fullname}')
        figure#minimap(bind:this='{dom.minimap}')
            canvas#minimap-field(bind:this='{dom.minimap_field}')
            mark#minimap-cursor(bind:this='{dom.minimap_cursor}')
</template>

<style type="text/stylus">
    @font-face
        font-family: IosevkaAile
        font-style: normal
        font-weight: 400
        src:
            url(iosevka-aile-regular.ttc)
    #main
        display: flex
        height: 100%
        font: 12px/1.2 IosevkaAile
        user-select: none
    #post
        width: 600px
        margin-right: 40px
        display: flex
        flex-flow: column nowrap
        justify-content: space-around
        align-items: flex-end
    nav
        width: 320px
        display: flex
        flex-flow: column nowrap
        justify-content: space-between
    #comments
        flex: 1
        overflow: auto
        white-space: pre-wrap
    #minimap
        position: fixed
        right: 15px
        width: 105px
        height: 100%
        margin: 17px 0
        pointer-events: none
    #minimap-cursor
        position: absolute
        top: 0
        display: block
        width: 100%
        pointer-events: none
        background: transparent
        border-left: 1px solid orangered
    header
        display: flex
    button
    input
        width: 100%
        padding: 8px
        font: inherit
        background: black
        color: white
    button
        cursor: pointer
    #stories-list
        overflow: auto
    .story-brochure
        border: 1px solid black
        cursor: pointer
    .read-story-brochure
        background: lightgray
    .selected-story-brochure
        background: wheat
    .story-headline
        font-size: 14px
    .story-thumbnail
        float: right
        width: 64px
    .subreddit-label
        display: inline-block
        background: lightgray
    #story-text
        max-height: 100%
        overflow: auto
        margin: 40px
        white-space: pre-wrap
        word-break: break-word
    a
        max-height: 100%
        text-align: right
    #story-image
    #story-video
        max-width: 100%
        max-height: 100%
    #story-embedded-page
        width: 100%
        height: 100%
</style>

<script type="text/coffeescript">
    import { onMount, afterUpdate } from 'svelte'
    import CommentTree from './CommentTree.svelte'
    export dom =
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
        load_stories({ count: 10 })
    )()
    load_stories = ({ count, after }) ->
        response = await fetch("https://oauth.reddit.com/#{if subreddit then 'r/'+subreddit else ''}/hot?g=GLOBAL&limit=#{count}&after=#{after}", {
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
            streamline_reply_datastructs story
    streamline_reply_datastructs = (comment) ->
        if comment.replies?.data?.children
            if comment.replies.data.children.kind == 'more'
                comment.replies = []
            else
                comment.replies = comment.replies.data.children.map (child) -> child.data
                for comment in comment.replies
                    streamline_reply_datastructs comment
        else
            comment.replies = []
    select_story = (story) -> 
        selected_story = story
        dom.comments.scrollTop = 0
        read_stories.add story.id
        read_stories = read_stories
    move_minimap_cursor = () ->
        dom.minimap_cursor.style.transform = "translateY(#{dom.comments.scrollTop / dom.comments.scrollHeight * (dom.minimap.clientHeight - 34)}px)"
    teleport_via_minimap = (click) ->
        # If clicking on minimap, jump to that location in the comments
        if dom.comments.clientWidth - click.layerX < dom.minimap.clientWidth 
            dom.comments.scrollTop = (click.y - 17) / (dom.minimap.clientHeight - 34) * dom.comments.scrollHeight
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
            for comment in dom.comments.children
                ctx.fillRect(0, Math.floor(comment.offsetTop / dom.comments.scrollHeight * dom.minimap.clientHeight), dom.minimap.clientWidth - 5, 1)
            memories.previous_story_id = selected_story.id
            memories.previous_comments_scrollheight = dom.comments.scrollHeight
</script>