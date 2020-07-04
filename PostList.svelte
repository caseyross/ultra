<template lang="pug">
    ol
        +each('$promises.feed as promise')
            +await('promise')
                +then('post')
                    li.post-brochure(tabindex=0 on:mousedown='{select_post(post)}' class:read!='{read_posts.has(post.id) && $feed.selected.id !== post.id}' class:selected='{$feed.selected.id === post.id}')
                        h2.headline(class:stickied!='{post.stickied || post.pinned}') {post.title}
                        .meta
                            +if('post.domain !== "self." + post.subreddit')
                                a.domain(href='{post.url}' target='_blank' title='{post.url}') {post.domain}
                            +if('post.subreddit.toLowerCase() === $feed.name.toLowerCase()')
                                +if('post.link_flair_text')
                                    a.tag(style!='background: {post.link_flair_background_color || "black"}; color: {post.link_flair_background_color && post.link_flair_text_color === "dark" ? "black" : "white"}') {post.link_flair_text}
                                +else
                                    a.tag(href='/r/{post.subreddit}' style!='background: {post.link_flair_background_color || "black"}; color: {post.link_flair_background_color && post.link_flair_text_color === "dark" ? "black" : "white"}') {post.subreddit}
                            .voting
                                button.upvote(on:click|stopPropagation!='{() => null}' class:voted!='{Math.random() < 0.1}') ▲
                                span.score {post.score}
                                button.downvote(on:click|stopPropagation!='{() => null}' class:voted!='{Math.random() < 0.01}') ▼
                +catch('error')
                    li.post-brochure
                        p FAILED TO LOAD POST
                        p ERROR DETAILS:
                        +if('error instanceof TypeError && error.message === "Failed to fetch"')
                            blockquote Can't connect to Reddit servers
                            +else
                                blockquote {error}
            +else
                li.post-brochure
                    +if('$feed.type === "user"')
                        p THIS USER HAS NO POSTS
                        +else
                            p THIS SUBREDDIT HAS NO POSTS
</template>

<style type="text/stylus">
    ol
        margin: 0
        overflow: auto
        will-change: transform // https://bugs.chromium.org/p/chromium/issues/detail?id=514303
        &::-webkit-scrollbar
            display: none
    .post-brochure
        padding: 8px 8px
        user-select: none
    .headline
        margin: 0
        font-size: 18px
    .meta
        display: flex
    .stickied
        color: darkseagreen
    .read
        opacity: 0.5
    .selected
        background: black
        color: white
    a
        color: inherit
        text-decoration: none
        &:hover
        &:focus
            text-decoration: underline
</style>

<script type="text/coffeescript">
    import { feed, promises, debug } from './state.coffee';
    import { ago_description, ago_description_long, recency_category } from './tools.coffee';
    export read_posts = new Set()
    select_post = (post) ->
        $feed.previous_selected = $feed.selected
        $feed.selected = post
        read_posts.add post.id
        read_posts = read_posts
        $debug.inspector.object = $feed.selected
</script>