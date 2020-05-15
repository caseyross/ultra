<template lang="pug">
    section
        .meta
            span posted-by: {post.author}
            span score: {post.score}
            span when:
                span {time_since(post.created_utc).major.value} {time_since(post.created_utc).major.unit.abbr} 
                +if('time_since(post.created_utc).minor')
                    span {time_since(post.created_utc).minor.value} {time_since(post.created_utc).minor.unit.abbr}
        +if('!post.id')
            +elseif('post.linked_post')
                article#reddit-comments(bind:this='{$dom.post_reddit_comments}')
                    CommentTree(comment='{post.linked_post}' op_id='{post.linked_post.author_fullname}' focus_comment_id='{post.linked_post.focus_comment_id}')
            +elseif('post.type === "embed"')
                article#embed {@html post.source}
            +elseif('post.type === "image"')
                a(href='{post.source}' target='_blank')
                    img(src='{post.source}')
            +elseif('post.type === "link"')
                iframe(src='{post.source}' sandbox='allow-scripts allow-same-origin')
            +elseif('post.type === "text"')
                +if('post.source.length')
                    article#self-text(bind:this='{$dom.post_self_text}') {@html post.source}
                    +else
                        article#error-text NO TEXT
            +elseif('post.type === "video"')
                video(autoplay controls muted src='{post.source}')
            +else
                article#error-text CANNOT PARSE POST
</template>

<style type="text/stylus">
    section
        flex: 1
        padding: 0 24px 0 0
        display: flex
        flex-flow: column nowrap
    .meta
        flex: 0 0 40px
        font-weight: 900
        display: flex
    span
        margin: 8px
    a
        max-height: 100%
    iframe
        width: 100%
        height: 100%
        background: white
    #embed
        width: 100%
        height: 100%
    #reddit-comments
        width: 100%
        height: 100%
        overflow: auto
    #self-text
        width: 100%
        max-height: 100%
        padding: 20px 12px
        overflow: auto
        line-height: 1.3
    #error-text
        width: 100%
        height: 100%
        display: flex
        justify-content: center
        align-items: center
        font-size: 14px
        font-weight: 900
        color: salmon
</style>

<script type="text/coffeescript">
    import { dom } from './core-state.coffee';
    import { describe_duration } from './tools.coffee'
    export post = {}
    time_since = (seconds) -> describe_duration(Date.now() - seconds * 1000)
</script>