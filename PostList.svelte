<template lang="pug">
    ol
        +each('posts as post')
            li(on:mousedown='{select_post(post)}' class:read='{$memory.read_posts.has(post.id)}' class:selected='{$chosen.post.id === post.id}')
                .meta
                    button.upvote(title='{post.score} points' class:voted!='{Math.random() < 0.2}') ▲
                    button {post.author}
                    button.downvote(title='{post.score} points' class:voted!='{Math.random() < 0.1}') ▼
                    time.time-since {describe_time_since(post.created_utc).major.value}{describe_time_since(post.created_utc).major.unit.abbr}
                .core
                    h1 {post.title}
                .meta
                    +if('post.subreddit !== $chosen.listing.name')
                        button.subreddit-label {post.subreddit}
                    span.flair {post.link_flair_text}
</template>

<style type="text/stylus">
    ol
        flex: 1 1 auto
        margin: 0
        padding: 8px
        overflow: auto
        list-style: none
    li
        padding: 4px
        border: 1px solid transparent
    .read
        opacity: 0.5
    .selected
        opacity: 1
        border-color: white
    .meta
        color: gray
    .subreddit-label
        margin-right: 16px
    .flair
        font-size: 12px
        font-weight: 400
    .time-since
        display: inline-block
        width: 30px
    .core
        display: flex
    .upvote
    .downvote
        width: 20px
        height: 20px
    .upvote.voted
        color: salmon
    .downvote.voted
        color: cornflowerblue
    h1
        margin: 4px 0
        font-size: inherit
        font-weight: inherit
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
    import { describe_time_since } from './tools.coffee';
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