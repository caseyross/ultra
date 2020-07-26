<template lang="pug">
    ol
        +each('$feed.page_pending as post_pending')
            li.brochure(tabindex=0)
                +await('post_pending')
                    +then('post')
                        .flair(style='background: {post_color(post)}; color: {contrast_color(post_color(post))}') {post.subreddit.toLowerCase() === $feed.name.toLowerCase() ? post.link_flair_text : post.subreddit}
                        h1.headline(
                            class:stickied!='{post.stickied || post.pinned}'
                            class:md-spoiler-text!='{post.spoiler}'
                            class:read!='{read_posts.has(post.id) && $selected.post.id !== post.id}'
                            on:click='{select_post(post)}'
                            title='{Math.trunc(1000000 * post.score / post.subreddit_subscribers)} / {Math.trunc(1000000 * post.num_comments / post.subreddit_subscribers)}'
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
        padding: 8px 0
    .meta
        color: gray
        display: flex
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
    .error-tag
        background: red
    .headline
        display: inline
        font-size: 18px
        background: var(--tc-m)
    .right
        flex: 0 0 16px
        text-align: right
    .read
        opacity: 0.2
    a
        color: inherit
        text-decoration: none
</style>

<script type="text/coffeescript">
    import { feed, selected } from './state.coffee';
    import { contrast_color, shade_color, ago_description, ago_description_long, recency_scale, heat_color } from './tools.coffee';
    export read_posts = new Set()
    post_color = (post) ->
        post.link_flair_background_color or post.sr_detail.primary_color or post.sr_detail.key_color or '#000000'
    select_post = (post) ->
        $selected.post = post
        read_posts.add post.id
        read_posts = read_posts
</script>