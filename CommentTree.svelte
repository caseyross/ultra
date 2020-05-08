<template lang="pug">
    +if('comment.replies.length > 0')
        +each('comment.replies as reply')
            +if('reply.body')
                article.comment-tree
                    .comment(class:focus-comment='{reply.id === focus_comment_id}')
                        .comment-meta
                            span.author-label(class:author-label-op='{reply.author_fullname === op_id}') {reply.author}
                        .comment-text {@html reply.body_html}
                    svelte:self(comment='{reply}' op_id='{op_id}' focus_comment_id='{focus_comment_id}')
</template>


<style type="text/stylus">
    .comment-tree
        margin-left: 32px
        margin-top: 8px
        font-weight: normal
        font-size: 12px
        line-height: 1.2
        word-break: break-word
    .comment-meta
        color: #333
    .comment-text
        width: 400px
        .focus-comment &
            padding: 8px
            background: #def
    .author-label
        background: lightgray
    .author-label-op
        background: lightblue
</style>

<script type="text/coffeescript">
    export comment =
        replies: []
    export op_id = ''
    export focus_comment_id = ''
</script>