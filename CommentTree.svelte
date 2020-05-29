<template lang="pug">
    +if('comment.replies.length > 0')
        +each('comment.replies as reply')
            +if('reply.body_html')
                article.comment-tree
                    .comment(class:comment-highlighted='{reply.id === highlight_id}')
                        .comment-meta
                            button.upvote(title='{reply.score} points' class:voted!='{Math.random() < 0.5}') ▲
                            button.author-label(
                                class:author-label-op!='{reply.author_fullname === op_id}'
                                class:author-label-mod!='{reply.distinguished === "moderator"}'
                                class:author-label-admin!='{reply.distinguished === "admin"}'
                                class:author-label-special!='{reply.distinguished === "special"}'
                            ) {reply.author}
                            button.downvote(title='{reply.score} points' class:voted!='{Math.random() < 0.1}') ▼
                            +if('reply.author_flair_text')
                                span.author-flair {reply.author_flair_text}
                        | {@html reply.body_html}
                    svelte:self(comment='{reply}' op_id='{op_id}' highlight_id='{highlight_id}')
</template>


<style type="text/stylus">
    .comment-tree
        padding: 12px 0 0 20px
        font-size: 12px
        word-break: break-word
        border-left: 1px solid #333
        :not(.comment-tree) > &
            border: 0
    .comment
        width: 480px
    .comment-highlighted
        color: wheat
    .comment-meta
        margin-bottom: 4px
        color: gray
    .author-label
        text-decoration: none
    .author-label-op
        color: dodgerblue
    .author-label-mod
        color: lightgreen
    .author-label-admin
        color: orangered
    .author-label-special
        color: crimson
    .upvote
    .downvote
        width: 20px
        height: 20px
        &:focus
            outline: none
    .upvote
        &:hover
        &.voted
            color: salmon
    .downvote
        &:hover
        &.voted
            color: cornflowerblue
</style>

<script type="text/coffeescript">
    export comment =
        replies: []
    export op_id = ''
    export highlight_id = ''
</script>