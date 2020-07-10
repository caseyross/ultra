<template lang="pug">
    ol
        +each('$promises.feed as promise')
            +await('promise')
                +then('post')
                    li.brochure(tabindex=0 on:mousedown='{select_post(post)}' class:read!='{read_posts.has(post.id) && $feed.selected.id !== post.id}')
                        .basket(title='{ago_description_long(post.created_utc)} / {post.link_flair_text}')
                            .fruit(style='{fruit_style(post)}')
                            .peel(style='{peel_style(post)}')
                            +if('post.stickied || post.pinned')
                                .sticky-tag STICKY
                            +if('post.over_18')
                                .nsfw-tag NSFW
                            +if('post.spoiler')
                                .spoiler-tag SPOIL
                        h1.headline {post.title}
                        +if('post.subreddit.toLowerCase() !== $feed.name.toLowerCase()')
                            .left
                                a.tag(href='/r/{post.subreddit}') {post.subreddit}
                +catch('error')
                    li.brochure
                        .basket(style='position: relative')
                            .error-tag ERROR
                        h1.headline(style='color: red') {error instanceof TypeError && error.message === "Failed to fetch" ? "Can't connect to Reddit servers" : error}
            +else
                p THIS {$feed.type === 'user' ? 'USER' : 'SUBREDDIT'} HAS NO POSTS
</template>

<style type="text/stylus">
    ol
        margin: 0
        padding: 0
        overflow: auto
        will-change: transform // https://bugs.chromium.org/p/chromium/issues/detail?id=514303
        &::-webkit-scrollbar
            display: none
    .brochure
        margin: 8px
        user-select: none
        display: flex
    .basket
        flex: 0 0 32px
    .fruit
        width: 32px
        height: 32px
        border-radius: 50%
    .peel
        position: absolute
        top: 0
        left: 0
        width: 32px
        height: 32px
        border: 1px solid
        border-radius: 50%
        pointer-events: none
    .sticky-tag
    .nsfw-tag
    .spoiler-tag
    .error-tag
        position: absolute
        top: 0
        left: 0
        padding: 0 1px
        background: black
        color: white
        font-size: 10px
        font-weight: 700
    .sticky-tag
        background: forestgreen
    .error-tag
        background: red
    .left
        flex: 0 0 auto
        text-align: right
    .headline
        position: relative
        flex: 1 1 auto
        margin: 0
        padding: 0 8px
        font-size: 16px
        font-weight: 700
        line-height: 1
    .right
        flex: 0 0 16px
        text-align: right
    .read
        opacity: 0.2
    a
        color: inherit
        text-decoration: none
        &:hover
        &:focus
            text-decoration: underline
</style>

<script type="text/coffeescript">
    import { feed, promises, debug } from './state.coffee';
    import { contrast_color, shade_color, ago_description, ago_description_long, recency_scale } from './tools.coffee';
    export read_posts = new Set()
    post_color = (post) ->
        if post.subreddit.toLowerCase() is $feed.name.toLowerCase()
            post.link_flair_background_color or post.sr_detail.primary_color or post.sr_detail.key_color or 'black'
        else
            post.sr_detail.primary_color or post.sr_detail.key_color or 'black'
    fruit_style = (post) ->
        "background: #{post_color(post)}; transform: scale(#{recency_scale(post.created_utc)});"
    peel_style = (post) ->
        comments_per_hour_per_subscriber = post.num_comments / ((Date.now() / 1000 - post.created_utc) / 3600) / post.subreddit_subscribers
        "color: #{post_color(post)}; transform: scale(#{Math.log(1 + 14400 * comments_per_hour_per_subscriber)});"
    select_post = (post) ->
        $feed.previous_selected = $feed.selected
        $feed.selected = post
        read_posts.add post.id
        read_posts = read_posts
        $debug.inspector.object = $feed.selected
</script>