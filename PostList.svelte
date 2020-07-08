<template lang="pug">
    ol
        +each('$promises.feed as promise')
            +await('promise')
                +then('post')
                    li.post-brochure(tabindex=0 on:mousedown='{select_post(post)}' style='{post_style(post)}' class:read!='{read_posts.has(post.id) && $feed.selected.id !== post.id}')
                        .right
                            .stamp {stamp_number++}
                        h1.headline {post.title}
                        .left
                            +if('post.subreddit.toLowerCase() === $feed.name.toLowerCase()')
                                +if('post.link_flair_text')
                                    a.tag {post.link_flair_text}
                                +else
                                    a.tag(href='/r/{post.subreddit}') {post.subreddit}
                +catch('error')
                    li.post-brochure
                        p FAILED TO LOAD POST:
                        +if('error instanceof TypeError && error.message === "Failed to fetch"')
                            blockquote Can't connect to Reddit servers
                            +else
                                blockquote {error}
            +else
                li.post-brochure
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
    .post-brochure
        padding-bottom: 8px
        user-select: none
        display: flex
    .left
        flex: 0 0 auto
        text-align: right
    .headline
        flex: 1 1 auto
        margin: 0
        padding: 0 8px
        font-size: 16px
        font-weight: 700
        line-height: 1
    .right
        flex: 0 0 16px
        text-align: right
    .stamp
        font-size: 12px
        background: black
        color: white
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
    import { contrast_color, shade_color, ago_description, ago_description_long, recency_category } from './tools.coffee';
    export read_posts = new Set()
    post_style = (post) ->
        if post.subreddit.toLowerCase() is $feed.name.toLowerCase()
            background = post.link_flair_background_color or 'inherit'
        else
            background = post.sr_detail.primary_color or post.sr_detail.key_color or 'inherit'
        color = contrast_color(background)
        "background: #{background}; color: #{color};"
    stamp_number = 0
    stamp = (post) ->
        if post.stickied or post.pinned
            'STICKY'
        else
            stamp_number += 1
            switch
                when post.over_18
                    'NSFW'
                when post.spoiler
                    'SPOILER'
                when post.locked
                    'LOCKED'
                when post.archived
                    'ARCHIVED'
                else
                    stamp_number
    select_post = (post) ->
        $feed.previous_selected = $feed.selected
        $feed.selected = post
        read_posts.add post.id
        read_posts = read_posts
        $debug.inspector.object = $feed.selected
</script>