<template lang="pug">
    +if('comment.replies.length > 0')
        +each('comment.replies as reply')
            +if('reply.body')
                article.comment-tree
                    .comment
                        .comment-meta
                            span.author-label(class:author-label-op='{reply.author_fullname === op_id}') {reply.author}
                        .comment-text {reply.body}
                    svelte:self(comment='{reply}' op_id='{op_id}')
</template>


<style type="text/stylus">
    .comment-tree
        margin: 8px 32px
    .comment-text
        width: 400px
    .author-label
        background: lightgray
    .author-label-op
        background: lightblue
</style>

<script type="text/coffeescript">
    export comment =
        replies: []
    export op_id = undefined
</script>