<template lang="pug">
    ol
        +each('posts as post')
            li(on:mousedown='{select_post(post)}' class:read='{$memory.read_posts.has(post.id)}' class:selected='{$chosen.post.id === post.id}')
                figure
                    .colorbar(
                        class:priority-1='{post.priority === 1}'
                        class:priority-2='{post.priority === 2}'
                        class:priority-3='{post.priority === 3}'
                        class:priority-4='{post.priority === 4}'
                        class:priority-5='{post.priority === 5}'
                        class:priority-6='{post.priority === 6}'
                        class:stickied='{post.stickied}'
                    )
                article
                    .meta
                        span.subreddit-label {post.subreddit}
                        span.flair {post.link_flair_text}
                    h1 {decode_reddit_html_entities(post.title)}
</template>

<style type="text/stylus">
    ol
        flex: 1 1 auto
        margin: 0
        padding: 0
        overflow: auto
        list-style: none
    li
        margin: 8px
        display: flex
        cursor: pointer
    .priority-1
        background: salmon
    .priority-2
        background: lightsalmon
    .priority-3
        background: wheat
    .priority-4
        background: white
    .priority-5
        background: lightgray
    .priority-6
        background: gray
    .stickied
        background: darkseagreen
    .selected
        background: steelblue
    .read
        opacity: 0.5
    figure
        flex: 0 0 32px
        margin-right: 8px
    .colorbar
        width: 100%
        height: 16px
        margin-top: 16px
    article
        flex: 1 1 auto
        margin-right: 16px
    .meta
        margin-bottom: 4px
        font-size: 12px
        font-weight: 900
    .flair
        margin-left: 16px
        color: gray
    h1
        margin: 0
        font-size: 14px
        font-weight: 400
</style>

<script type="text/coffeescript">
    import { chosen, dom, memory } from './core-state.coffee';
    import { decode_reddit_html_entities } from './tools.coffee'
    export posts = []
    select_post = (post) ->
        $memory.previous_post_id = $chosen.post.id
        $chosen.post = post
        $memory.read_posts.add post.id
        $memory.read_posts = $memory.read_posts
        $dom.post_reddit_comments?.scrollTop = 0
        $dom.post_self_text?.scrollTop = 0
        $dom.comments.scrollTop = 0
</script>