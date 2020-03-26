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
            #stories-list
                +each('popular_stories as story')
                    article.story-brochure(on:click='{select_story(story)}' class:read-story-brochure='{read_stories.has(story.id)}' class:selected-story-brochure='{selected_story.id === story.id}')
                        section.subreddit-label {story.subreddit}
                        section.story-headline
                            +if('story.thumbnail !== "default" && story.thumbnail !== "self"')
                                img.story-thumbnail(src='{story.thumbnail}')
                            h1 {story.title}
            footer
                button Load next 10
        section#comments
            Replies(comment='{selected_story}' op_id='{selected_story.author_fullname}')
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
        width: 480px
        margin-right: 40px
        display: flex
        flex-flow: column nowrap
        justify-content: space-around
        align-items: center
    nav
        width: 320px
        display: flex
        flex-flow: column nowrap
        justify-content: space-between
    #comments
        flex: 1
        overflow: auto
        white-space: pre-wrap
    header
        display: flex
    button
        width: 100%
        padding: 8px
        font: inherit
        background: black
        color: white
        cursor: pointer
    #stories-list
        overflow: auto
    .story-brochure
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
    .story-thumbnail
        float: right
        width: 64px
    .subreddit-label
        position: relative
        display: inline-block
        background: lightgray
    #story-text
        max-height: 100%
        overflow: auto
        margin: 40px
        white-space: pre-wrap
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
    import Replies from './Replies.svelte'
    export popular_stories = []
    export niche_stories = []
    export selected_story =
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