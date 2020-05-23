<template lang="pug">
    +if('comment.replies.length > 0')
        +each('comment.replies as reply')
            +if('reply.body')
                article.comment-tree
                    .comment(class:focus-comment='{reply.id === focus_comment_id}')
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
                        .comment-text {@html reply.body_html}
                    svelte:self(comment='{reply}' op_id='{op_id}' focus_comment_id='{focus_comment_id}')
</template>


<style type="text/stylus">
    .comment-tree
        padding: 12px 0 0 20px
        font-size: 12px
        word-break: break-word
        border-left: 1px solid #333
        :not(.comment-tree) > &
            border: 0
    .comment-meta
        margin-bottom: 4px
        color: gray
    .comment-text
        width: 480px
        .focus-comment &
            background: #333
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
    .upvote.voted
        color: salmon
    .downvote.voted
        color: cornflowerblue
</style>

<script type="text/coffeescript">
    import { chosen } from './core-state.coffee'
    export comment =
        replies: []
    export op_id = ''
    export focus_comment_id = ''
</script>