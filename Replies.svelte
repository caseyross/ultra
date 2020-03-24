<template lang="pug">
    +if('comment.replies.length > 0')
        +each('comment.replies as reply')
            +if('reply.body && !collapsed_comments.has(reply.id)')
                article.comment
                    p.comment-text(on:click|stopPropagation='{collapse_comment(reply)}') {reply.body}
                    svelte:self(comment='{reply}' collapsed_comments='{collapsed_comments}')
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
</style>

<script type="text/coffeescript">
    export comment =
        replies: []
    export collapsed_comments = new Set()
    collapse_comment = (comment) ->
        collapsed_comments.add comment.id
        collapsed_comments = collapsed_comments
</script>