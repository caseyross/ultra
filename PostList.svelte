<template lang="pug">
    ol
        +each('$promises.feed as promise')
            +await('promise')
                +then('post')
                    li.post-brochure(tabindex=0 on:click='{select_post(post)}' class:read='{read_posts.has(post.id)}' class:selected='{$feed.selected.id === post.id}')
                        h1.title {post.title}
                        p.meta
                            +if('post.subreddit.toLowerCase() !== $feed.name.toLowerCase()')
                                button.subreddit {post.subreddit}
                            +if('post.link_flair_text')
                                span.link-flair(style='background-color: {post.link_flair_background_color}') {post.link_flair_text}
                            button.upvote(title='{post.score} points' class:voted!='{Math.random() < 0.1}') ▲
                            button.author {post.author}
                            button.downvote(title='{post.score} points' class:voted!='{Math.random() < 0.01}') ▼
                            time.time-since {describe_time_since(post.created_utc).major.value}{describe_time_since(post.created_utc).major.unit.abbr}
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
        opacity: 0.5
    .subreddit
        margin-right: 8px
        background: #333
        &:hover
        &:focus
            text-decoration: underline
    .link-flair
        margin-right: 8px
    .author:hover
    .author:focus
        text-decoration: underline
    .time-since
        display: inline-block
        margin-right: 8px
</style>

<script type="text/coffeescript">
    import { feed, promises } from './state.coffee';
    import { describe_time_since } from './tools.coffee';
    export read_posts = new Set()
    select_post = (post) ->
        $feed.previous_selected = $feed.selected
        if post.id == $feed.selected.id
            $feed.selected =
                id: ''
        else
            $feed.selected = post
        read_posts.add post.id
        read_posts = read_posts
</script>