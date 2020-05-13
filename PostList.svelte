<template lang="pug">
    ol
        +each('posts as post')
            li(
                on:mousedown='{select_post(post)}'
                class:priority-1='{post.priority === 1}'
                class:priority-2='{post.priority === 2}'
                class:priority-3='{post.priority === 3}'
                class:priority-4='{post.priority === 4}'
                class:priority-5='{post.priority === 5}'
                class:priority-6='{post.priority === 6}'
                class:stickied='{post.stickied}'
                class:read='{$history.read_posts.has(post.id)}'
                class:selected='{$chosen.post.id === post.id}'
            )
                .aux
                    span.subreddit-label {post.subreddit}
                    span.flair {post.link_flair_text}
                .main
                    figure.colorbar
                    h1 {decode_reddit_html_entities(post.title)}
</template>

<style type="text/stylus">
    ol
        flex: 1 1 auto
        margin: 0
        padding: 0
        overflow: auto
        list-style: none
    li
        padding: 12px 0
        cursor: pointer
    .priority-1
        color: salmon
        & .subreddit-label
        & .colorbar
            background: salmon
    .priority-2
        color: lightsalmon
        & .subreddit-label
        & .colorbar
            background: lightsalmon
    .priority-3
        color: wheat
        & .subreddit-label
        & .colorbar
            background: wheat
    .priority-4
        color: white
        & .subreddit-label
        & .colorbar
            background: white
    .priority-5
        color: lightgray
        & .subreddit-label
        & .colorbar
            background: lightgray
    .priority-6
        color: gray
        & .subreddit-label
        & .colorbar
            background: gray
    .selected
        background: #666
    .stickied
        background: darkseagreen
    .aux
        margin-bottom: 8px
        font-size: 12px
        font-weight: 900
        color: #222
    .flair
        color: gray
        margin-left: 16px
    .main
        display: flex
    .colorbar
        flex: 0 0 2px
        .stickied &
            background: darkseagreen
        .read &
            visibility: hidden
    h1
        margin: 0 16px 0 8px
        font-size: 16px
        .stickied &
            color: white
</style>

<script type="text/coffeescript">
    import { chosen, dom, history } from './core-state.js';
    import { decode_reddit_html_entities } from './tools.js'
    export posts = []
    select_post = (post) ->
        $history.previous_post_id = $chosen.post.id
        $chosen.post = post
        $history.read_posts.add post.id
        $history.read_posts = $history.read_posts
        $dom.post_reddit_comments?.scrollTop = 0
        $dom.post_self_text?.scrollTop = 0
        $dom.comments.scrollTop = 0
</script>