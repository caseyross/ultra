<template lang="pug">
    ol
        +each('$promises.feed as promise')
            +await('promise')
                +then('post')
                    li.post-brochure(tabindex=0 on:click='{select_post(post)}' class:read='{read_posts.has(post.id)}' class:selected='{$feed.selected.id === post.id}')
                        h2.title {post.title}
                        .meta
                            a.domain {post.domain}
                            +if('post.subreddit.toLowerCase() === $feed.name.toLowerCase()')
                                +if('post.link_flair_text')
                                    span.link-flair(style!='background: {post.link_flair_background_color}; color: {post.link_flair_text_color === "light" ? "white" : "black"}') {post.link_flair_text}
                                +else
                                    a.subreddit {post.subreddit}
                            span.votes
                                button.upvote(on:click|stopPropagation!='{() => null}' class:voted!='{Math.random() < 0.1}') ▲
                                button.score(title!='{post.hide_score ? "score hidden" : "score (upvotes minus downvotes)"}') {post.hide_score ? '-' : post.score}
                                button.downvote(on:click|stopPropagation!='{() => null}' class:voted!='{Math.random() < 0.01}') ▼
                            time.time-since(title='posted at {(new Date(post.created_utc * 1000)).toLocaleString()}') {describe_time_since(post.created_utc).major.value}{describe_time_since(post.created_utc).major.unit.abbr}
                            a.author u/{post.author}
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
        padding-right: 4px
        overflow: auto
        &::-webkit-scrollbar
            width: 1px
            background: transparent
        &::-webkit-scrollbar-thumb
            background: white
            background: #333
    .post-brochure
        padding: 8px 8px 4px 8px
        cursor: default
        user-select: none
    .read
        color: #999
    .selected
        background: darkkhaki
        color: white
    .title
        margin: 0
        font-size: 18px
    .meta
        margin-top: 1px
        color: gray
    a
        color: inherit
        &:hover
        &:focus
            text-decoration: underline
    .subreddit
        margin-right: 8px
        padding: 2px 4px
        background: #b5a390
        color: white
    .link-flair
        margin-right: 8px
        padding: 2px 4px
        background: lightgray
        color: black
    .domain
        margin-right: 8px
    .time-since
        display: inline-block
        margin-right: 8px
        padding: 2px 4px
        background: #e6ccb0
        color: black
    .votes
        margin-right: 8px
        background: lightgray
    .author
        margin-right: 8px
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