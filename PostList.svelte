<template lang="pug">
    nav
        +each('$promises.feed as promise')
            +await('promise')
                +then('post')
                    button.post-brochure(on:mousedown='{select_post(post)}' class:read='{read_posts.has(post.id)}' class:selected='{$feed.selected.id === post.id}')
                        .meta
                            button.upvote(title='{post.score} points' class:voted!='{Math.random() < 0.2}' tabindex=-1) ▲
                            button(tabindex=-1) {post.author}
                            button.downvote(title='{post.score} points' class:voted!='{Math.random() < 0.1}' tabindex=-1) ▼
                            time.time-since {describe_time_since(post.created_utc).major.value}{describe_time_since(post.created_utc).major.unit.abbr}
                        .core
                            h1 {post.title}
                        .meta
                            +if('post.subreddit !== $feed.name')
                                button.subreddit-label(tabindex=-1) {post.subreddit}
                            span.flair {post.link_flair_text}
                +catch('error')
                    li {error}
            +else
                li Couldn't load posts
</template>

<style type="text/stylus">
    nav
        height: 100%
        padding: 8px
        overflow: auto
    .post-brochure
        position: relative
        width: 100%
        padding: 4px 8px 8px 8px
        text-align: left
        &:focus
            outline: none
        &::after
            opacity: 0
            content: ''
            position: absolute
            left: 0
            top: 0
            width: 100%
            height: 100%
            length = 20px
            background-image:
                linear-gradient(to right, darkkhaki length, transparent length),
                linear-gradient(to right, darkkhaki length, transparent length),
                linear-gradient(to bottom, darkkhaki length, transparent length),
                linear-gradient(to bottom, darkkhaki length, transparent length)
            background-size:
                100% 1px,
                100% 1px,
                1px 100%,
                1px 100%
            background-position:
                -(length / 2) 0%,
                -(length / 2) 100%,
                0% (-(length / 2)),
                100% (-(length / 2))
            background-repeat:
                repeat-x,
                repeat-x,
                repeat-y,
                repeat-y
        &:hover::after
        &:focus::after
            opacity: 1
    .read
        opacity: 0.5
    .selected
        opacity: 1
        background: #333
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
        &:focus
            outline: none
    .upvote
        &:hover
        &.voted
            color: salmon
    .downvote
        &:hover
        &.voted
            color: cornflowerblue
    h1
        margin: 4px 0
        font-size: inherit
        font-weight: inherit
</style>

<script type="text/coffeescript">
    import { feed, promises } from './core-state.coffee';
    import { describe_time_since } from './tools.coffee';
    export read_posts = new Set()
    select_post = (post) ->
        $feed.previous_selected = $feed.selected
        $feed.selected = post
        read_posts.add post.id
        read_posts = read_posts
</script>