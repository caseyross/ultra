<template lang="pug">
    +if('comment.replies.length > 0')
        +each('comment.replies as reply')
            +if('reply.body')
                article.comment-tree
                    .comment(class:focus-comment='{reply.id === focus_comment_id}')
                        .comment-meta
                            span.author-label(class:author-label-op='{reply.author_fullname === op_id}') {reply.author}
                            +if('reply.author_flair_text')
                                span.author-flair {reply.author_flair_text}
                        .comment-text {@html reply.body_html}
                    svelte:self(comment='{reply}' op_id='{op_id}' focus_comment_id='{focus_comment_id}')
</template>


<style type="text/stylus">
    .comment-tree
        margin-left: 32px
        margin-top: 20px
        font-size: 12px
        line-height: 1.2
        word-break: break-word
    .comment-meta
        margin-bottom: 4px
        color: #222
    .comment-text
        width: 400px
        padding: 4px 0 0 4px
        .focus-comment &
            background: #333
    .author-label
        background: lightgray
    .author-label-op
        background: lightblue
    .author-flair
        margin-left: 8px
        color: gray
</style>

<script type="text/coffeescript">
    export comment =
        replies: []
    export op_id = ''
    export focus_comment_id = ''
</script>