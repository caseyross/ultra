<template lang="pug">
    ol
        +each('posts as post')
            li(on:mousedown='{select_post(post)}' class:read='{$memory.read_posts.has(post.id)}' class:selected='{$chosen.post.id === post.id}')
                figure
                    button.upvote(class:voted!='{Math.random() < 0.5}') ▲
                    button.downvote(class:voted!='{Math.random() < 0.1}') ▼
                article
                    .meta
                        span.subreddit-label {post.subreddit}
                        span.flair {post.link_flair_text}
                    h1 {post.title}
</template>

<style type="text/stylus">
    ol
        flex: 1 1 auto
        margin: 0
        padding: 8px
        overflow: auto
        list-style: none
        color: gray
    li
        padding: 4px
        display: flex
        border: 1px solid #222
        cursor: pointer
    .stickied
        color: darkseagreen
    .read
        opacity: 0.5
    .selected
        opacity: 1
        border-color: white
    figure
        flex: 0 0 30px
        margin-right: 6px
    .upvote
    .downvote
        width: 20px
        height: 20px
    .upvote.voted
        color: chartreuse
    .downvote.voted
        color: red
    article
        flex: 1
    .meta
        margin-bottom: 4px
        font-size: 13px
        font-weight: 900
    .flair
        margin-left: 16px
    h1
        margin: 0
        font-size: 12px
        font-weight: 400
        color: white
    .priority-1
        background: salmon
    .priority-2
        background: lightsalmon
    .priority-3
        background: wheat
    .priority-4
        background: white
    .priority-5
        background: lightgray
    .priority-6
        background: gray
</style>

<script type="text/coffeescript">
    import { chosen, dom, memory } from './core-state.coffee';
    export posts = []
    select_post = (post) ->
        $memory.previous_post_id = $chosen.post.id
        $chosen.post = post
        $memory.read_posts.add post.id
        $memory.read_posts = $memory.read_posts
        $dom.post_reddit_comments?.scrollTop = 0
        $dom.post_self_text?.scrollTop = 0
        $dom.comments.scrollTop = 0
</script>