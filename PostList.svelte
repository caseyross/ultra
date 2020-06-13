<template lang="pug">
    ol
        +each('$promises.feed as promise, i')
            +await('promise')
                +then('post')
                    li.post-brochure(tabindex=0 on:click='{select_post(post)}')
                        .left
                            .position(class:read='{read_posts.has(post.id)}' class:selected='{$feed.selected.id === post.id}') {i + 1}
                        .right
                            .core
                                +if('post.subreddit.toLowerCase() === $feed.name.toLowerCase()')
                                    +if('post.link_flair_text')
                                        a.tag(style!='background: {post.link_flair_background_color}; color: {post.link_flair_text_color === "light" ? "white" : "black"}') {post.link_flair_text}
                                    +else
                                        a.tag {post.subreddit}
                                h2.headline {post.title}
                                +if('post.domain !== "self." + post.subreddit')
                                    a.domain(href='{post.url}' target='_blank' title='{post.url}') ({post.domain})
                            .meta
                                button.upvote(on:click|stopPropagation!='{() => null}' class:voted!='{Math.random() < 0.1}') [▲] 
                                button.downvote(on:click|stopPropagation!='{() => null}' class:voted!='{Math.random() < 0.01}') [▼] 
                                span ——— 
                                a.author [ u/{post.author} ]
                +catch('error')
                    li.post-brochure
                        .left
                        .right
                            p FAILED TO LOAD POST
                            p ERROR DETAILS:
                            +if('error instanceof TypeError && error.message === "Failed to fetch"')
                                blockquote Can't connect to Reddit servers
                                +else
                                    blockquote {error}
            +else
                li.post-brochure
                    .left
                    .right
                        +if('$feed.type === "user"')
                            p THIS USER HAS NO POSTS
                            +else
                                p THIS SUBREDDIT HAS NO POSTS
</template>

<style type="text/stylus">
    ol
        margin: 0
        padding: 0
        overflow: auto
        list-style: none
        will-change: transform // https://bugs.chromium.org/p/chromium/issues/detail?id=514303
        &::-webkit-scrollbar
            display: none
    .post-brochure
        cursor: default
        user-select: none
        font-family: monospace
        color: #999
        display: flex
    .left
        flex: 0 0 32px
    .position
        width: 16px
        height: 16px
        text-align: right
        background: black
        color: white
        font-weight: bold
    .read
        opacity: 0.5
    .selected
        opacity: 1
        background: darkkhaki
        color: white
    .right
        flex: 1
    .tag
        margin-right: 8px
        padding: 1px 6px
        border: 1px solid gray
        color: black
    .headline
        display: inline
        margin-right: 4px
        font-size: 18px
        font-weight: 400
        color: black
    .domain
        font-size: 12px
        color: gray
    .meta
        white-space: pre
        font-family: monospace
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