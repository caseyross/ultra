<template lang="pug">
    ol
        +each('$promises.feed as promise')
            +await('promise')
                +then('post')
                    li.post-brochure(tabindex=0 on:click='{select_post(post)}' class:read='{read_posts.has(post.id)}' class:selected='{$feed.selected.id === post.id}')
                        time(title='{(new Date(post.created_utc * 1000)).toLocaleString()}')
                            span.time-value {describe_time_since(post.created_utc).major.value}
                            span.time-unit {describe_time_since(post.created_utc).major.unit.abbr}
                        .voting
                            button.upvote(on:click|stopPropagation!='{() => null}' class:voted!='{Math.random() < 0.1}') ▲
                            button.downvote(on:click|stopPropagation!='{() => null}' class:voted!='{Math.random() < 0.01}') ▼
                        .main
                            .core
                                h2.headline {post.title}
                                +if('post.domain !== "self." + post.subreddit')
                                    a.domain(href='{post.url}' target='_blank' title='{post.url}') ({post.domain})
                            .meta
                                +if('post.subreddit.toLowerCase() === $feed.name.toLowerCase()')
                                    +if('post.link_flair_text')
                                        a.tag(style!='background: {post.link_flair_background_color}; color: {post.link_flair_text_color === "light" ? "white" : "black"}') {post.link_flair_text}
                                    +else
                                        a.tag {post.subreddit}
                                a.author {post.author}
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
        padding: 0
        overflow: auto
        list-style: none
        &::-webkit-scrollbar
            display: none
    .post-brochure
        padding: 8px 0
        cursor: default
        user-select: none
        display: flex
    .voting
        flex: 0 0 14px
        height: 28px
        position: relative
        left: 8px
        background: #fed
        display: flex
        flex-flow: column nowrap
    time
        flex: 0 0 30px
        padding-top: 5px
        text-align: right
        color: gray
    .time-unit
        margin-left: 1px
    .main
        flex: 1
        padding-left: 14px
        border-left: 2px solid lightgray
    .headline
        display: inline
        margin: 0 4px 0 0
        font: 400 18px/1.2 Charter
    .meta
        margin-top: 8px
        color: gray
    a
        color: inherit
        &:hover
        &:focus
            text-decoration: underline
    .domain
        font: 12px "Iosevka Aile"
        color: gray
        text-decoration: none
    .tag
        margin-right: 8px
        padding: 1px 6px
        border: 1px solid gray
        color: black
    .read
        opacity: 0.5
    .selected
        opacity: 1
        background: darkkhaki
        color: white
</style>

<script type="text/coffeescript">
    import { feed, promises, debug } from './state.coffee';
    import { describe_time_since } from './tools.coffee';
    export read_posts = new Set()
    select_post = (post) ->
        $feed.previous_selected = $feed.selected
        $feed.selected = post
        read_posts.add post.id
        read_posts = read_posts
        $debug.inspector.object = $feed.selected
</script>