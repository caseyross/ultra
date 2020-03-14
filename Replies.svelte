<template lang="pug">
    +if('comment.replies.length > 0')
        +each('comment.replies as reply')
            +if('reply.body')
                p(class='comment') {reply.body}
                    svelte:self(comment='{reply}')
</template>

<style type="text/stylus">
    .comment
        font-size: 12px
        line-height: 1.2
        margin: 12px 24px
        word-break: break-word
</style>

<script type="text/coffeescript">
    export comment =
        replies: []
</script>