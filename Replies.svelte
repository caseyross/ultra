<template lang="pug">
    +if('comment.replies.length > 0')
        +each('comment.replies as reply')
            +if('reply.body && !collapsed_comments.has(reply.id)')
                article.comment
                    p.comment-text(on:click|stopPropagation='{collapse_comment(reply)}' class:op-comment-text='{reply.author_fullname === op_id}') {reply.body}
                    svelte:self(comment='{reply}' op_id='{op_id}' collapsed_comments='{collapsed_comments}')
</template>

<style type="text/stylus">
    .comment
        margin-left: 32px
    .comment-text
        width: 400px
        font-size: 12px
        line-height: 1.2
        word-break: break-word
        padding: 12px
        cursor: pointer
    .op-comment-text
        color: blueviolet
</style>

<script type="text/coffeescript">
    export comment =
        replies: []
    export op_id = undefined
    export collapsed_comments = new Set()
    collapse_comment = (comment) ->
        collapsed_comments.add comment.id
        collapsed_comments = collapsed_comments
</script>