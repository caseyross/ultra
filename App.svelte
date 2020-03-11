<template lang="pug">
    section(class='popular-stories-list')
        nav
            +each('popular_stories as story')
                article(on:click!='{() => {selected_story = story; read_stories.add(story.id); read_stories = read_stories}}' class:read-story-brochure='{read_stories.has(story.id)}' class:selected-story-brochure='{selected_story.id === story.id}' class='story-brochure')
                    section
                        section(class='story-headline') {story.title}
                        section(class='subreddit-label') {story.subreddit}
                    section
                        +if('story.thumbnail !== "default" && story.thumbnail !== "self"')
                            img(class='story-thumbnail' src='{story.thumbnail}')
        article(class='popular-story-reader')
            +each('selected_story.replies as comment')
                p(class='comment') {comment.body}
</template>

<style type="text/stylus">
    .popular-stories-list
        display: flex
        height: 100%
    .popular-story-reader
        width: 560px
        background: wheat
        height: 100%
        overflow: auto
    .comment
        font-size: 12px
        line-height: 1.2
        padding: 6px
        word-break: break-word
    nav
        width: 400px
        height: 100%
        overflow: auto
    .story-brochure
        padding: 6px
        display: flex
        justify-content: space-between
        cursor: pointer
    .read-story-brochure
        background: lightgray
    .selected-story-brochure
        background: wheat
        border: 1px solid black
    .story-headline
        max-height: 56px
        overflow: hidden
        font-size: 14px
        font-weight: bold
        margin-left: 4px
    .subreddit-label
        display: inline-block
        overflow: hidden
        text-overflow: ellipsis
        font-size: 12px
        background: lightgray
        margin: 4px
    .story-thumbnail
        width: 80px
</style>

<script type="text/coffeescript">
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
            streamline_reply_datastructs(story)
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
</script>