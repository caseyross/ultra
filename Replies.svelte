<template lang="pug">
    +if('comment.replies.length > 0')
        +each('comment.replies as reply')
            +if('reply.body')
                article(class='comment')
                    p(class='comment-text') {reply.body}
                    svelte:self(comment='{reply}')
</template>

<style type="text/stylus">
    .comment
        margin-left: 32px
    .comment-text
        width: 400px
        font-size: 12px
        line-height: 1.2
        word-break: break-word
        border: 1px solid
        padding: 12px
</style>

<script type="text/coffeescript">
    export comment =
        replies: []
</script>