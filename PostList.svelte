<template lang="pug">
    nav
        +each('$promises.feed as promise')
            +await('promise')
                +then('post')
                    button.post-brochure(tabindex=0 on:click='{select_post(post)}' class:read='{read_posts.has(post.id)}' class:selected='{$feed.selected.id === post.id}')
                        .meta
                            button.upvote(title='{post.score} points' class:voted!='{Math.random() < 0.2}') ▲
                            button {post.author}
                            button.downvote(title='{post.score} points' class:voted!='{Math.random() < 0.1}') ▼
                            time.time-since {describe_time_since(post.created_utc).major.value}{describe_time_since(post.created_utc).major.unit.abbr}
                        .core
                            h1 {post.title}
                        .meta
                            +if('post.subreddit !== $feed.name')
                                button.subreddit-label {post.subreddit}
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
        width: 100%
        padding: 4px 8px 8px 8px
        text-align: left
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