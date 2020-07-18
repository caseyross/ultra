<template lang="pug">
    ol
        +each('$feed.page_pending as post_pending')
            li.brochure(tabindex=0)
                +await('post_pending')
                    +then('post')
                        .gutter
                            .upvote ▲
                            .downvote ▼
                            .flair-block(style='background: {post_color(post)}')
                            +if('post.over_18')
                                .nsfw-tag NSFW
                        h1.headline(on:mousedown='{select_post(post)}' title='{Math.trunc(1000000 * post.score / post.subreddit_subscribers)} / {Math.trunc(1000000 * post.num_comments / post.subreddit_subscribers)}')
                            mark(
                                class:stickied!='{post.stickied || post.pinned}'
                                class:spoiler!='{post.spoiler}'
                                class:read!='{read_posts.has(post.id) && $feed.selected_post.id !== post.id}'
                            ) {post.title}
                    +catch('error')
                        .gutter(style='position: relative')
                            .error-tag ERROR
                        h1.headline
                            mark(style='background: red') {error instanceof TypeError && error.message === "Failed to fetch" ? "Can't connect to Reddit servers" : error}
</template>

<style type="text/stylus">
    ol
        margin: 0
        padding: 0
        height: 100%
        overflow: auto
        list-style: none
        display: flex
        flex-flow: column nowrap
        user-select: none
        cursor: pointer
        will-change: transform // https://bugs.chromium.org/p/chromium/issues/detail?id=514303
        &::-webkit-scrollbar
            display: none
    .brochure
        display: flex
    .gutter
        flex: 0 0 auto
        padding: 6px 0
        display: flex
        flex-flow: column nowrap
        align-items: flex-end
        display: none
    .flair-block
        width: 9px
        height: 9px
    .upvote
    .downvote
        width: 24px
        height: 16px
        padding-right: 6px
        text-align: center
        background: yellow
        color: black
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
    .stickied
        background: darkseagreen
    .spoiler
        color: transparent
        &:hover
            color: initial
    .error-tag
        background: red
    .left
        flex: 0 0 auto
        text-align: right
    .headline
        position: relative
        flex: 1 1 auto
        margin: 0
        padding: 7px 0
        font-size: 14px
        font-weight: 600
        line-height: 20px
    mark
        padding: 1px 4px
        &:hover
            background: red
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
    import { feed, inspector } from './state.coffee';
    import { contrast_color, shade_color, ago_description, ago_description_long, recency_scale, heat_color } from './tools.coffee';
    export read_posts = new Set()
    post_color = (post) ->
        if post.subreddit.toLowerCase() is $feed.name.toLowerCase()
            return post.link_flair_background_color or post.sr_detail.primary_color or post.sr_detail.key_color or '#000000'
            post.link_flair_background_color or 'transparent'
        else
            post.sr_detail.primary_color or post.sr_detail.key_color or '#000000'
    select_post = (post) ->
        $feed.selected_post = post
        read_posts.add post.id
        read_posts = read_posts
        $inspector.object = $feed.selected_post
</script>