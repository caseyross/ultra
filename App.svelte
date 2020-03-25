<template lang="pug">
    #main
        nav
            header
                button Popular
                button Niche
            #stories-list
                +each('popular_stories as story')
                    article.story-brochure(on:click='{select_story(story)}' class:read-story-brochure='{read_stories.has(story.id)}' class:selected-story-brochure='{selected_story.id === story.id}')
                        section
                            section.story-headline {story.title}
                            section.subreddit-label {story.subreddit}
                        section
                            +if('story.thumbnail !== "default" && story.thumbnail !== "self"')
                                img.story-thumbnail(src='{story.thumbnail}')
            footer
                button Load next 10
        article#comments
            Replies(comment='{selected_story}' op_id='{selected_story.author_fullname}' collapsed_comments='{collapsed_comments}')
        article#story
            +if('selected_story.is_self')
                p#story-text {selected_story.selftext || '[ no text ]'}
            +if('selected_story.post_hint === "image"')
                img#story-image(src='{selected_story.url}')
            +if('selected_story.post_hint === "hosted:video"')
                video#story-video(src='{selected_story.url}')
            +if('selected_story.post_hint === "link"')
                iframe#story-embedded-page(src='{selected_story.url}' sandbox='allow-scripts allow-same-origin')
</template>

<style type="text/stylus">
    #main
        display: flex
        height: 100%
        font-family: Verdana, sans-serif
        user-select: none
    nav
        display: flex
        flex-direction: column
        justify-content: space-between
    header
        display: flex
    button
        width: 100%
        font-size: 24px
        padding: 12px
        background: white
    #stories-list
        width: 360px
        overflow: auto
    .story-brochure
        padding: 12px
        display: flex
        justify-content: space-between
        border: 1px solid black
        cursor: pointer
    .read-story-brochure
        background: lightgray
    .selected-story-brochure
        background: wheat
    .story-headline
        font-size: 14px
        font-weight: bold
        margin-right: 2px
    .subreddit-label
        display: inline-block
        overflow: hidden
        text-overflow: ellipsis
        font-size: 12px
        background: lightgray
    .story-thumbnail
        width: 96px
        margin-left: 16px
    #comments
        flex: 0 0 auto
        height: 100%
        overflow: auto
    #story
        flex: 1 1 0
    #story-text
        padding: 16px
        font-size: 16px
        line-height: 1.2
        word-break: break-word
    #story-image
    #story-video
        max-width: 100%
        max-height: 100%
    #story-embedded-page
        width: 100%
        height: 100%
</style>

<script type="text/coffeescript">
    import Replies from './Replies.svelte'
    export popular_stories = []
    export niche_stories = []
    export selected_story =
        replies: []
    export read_stories = new Set()
    export collapsed_comments = new Set()
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
        response = await fetch('https://oauth.reddit.com/best?limit=10', {
            method: 'GET'
            headers:
                'Authorization': token_type + ' ' + access_token
        })
        { data } = await response.json()
        popular_stories = data.children.map (child) -> {
            child.data...
            replies: []
        }
        popular_stories.map (story) ->
            response = await fetch('https://oauth.reddit.com/comments/' + story.id, {
                method: 'GET'
                headers:
                    'Authorization': token_type + ' ' + access_token
            })
            [..., comments] = await response.json()
            story.replies = comments
            streamline_reply_datastructs story
        console.log popular_stories
    )()
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
        document.querySelector('#comments').scrollTop = 0
        read_stories.add story.id
        read_stories = read_stories
</script>