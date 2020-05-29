<template lang="pug">
    +if('comment.replies.length > 0')
        +each('comment.replies as reply')
            +if('reply.body_html')
                article.comment-tree
                    .comment(tabindex=0 on:click='{select_comment(reply)}' class:highlighted='{reply.id === highlight_id}' class:selected='{reply.id === selected_id}')
                        .comment-meta
                            button.upvote(title='{reply.score} points' class:voted!='{Math.random() < 0.5}') ▲
                            button.author-label(
                                class:op!='{reply.author_fullname === op_id}'
                                class:mod!='{reply.distinguished === "moderator"}'
                                class:admin!='{reply.distinguished === "admin"}'
                                class:special!='{reply.distinguished === "special"}'
                            ) {reply.author}
                            button.downvote(title='{reply.score} points' class:voted!='{Math.random() < 0.1}') ▼
                            +if('reply.author_flair_text')
                                span.author-flair {reply.author_flair_text}
                        | {@html reply.body_html}
                    svelte:self(comment='{reply}' op_id='{op_id}' highlight_id='{highlight_id}' selected_id='{selected_id}' select_comment='{select_comment}')
</template>


<style type="text/stylus">
    .comment-tree
        padding: 4px 0 0 20px
        font-size: 12px
        word-break: break-word
        border-left: 1px solid #333
        :not(.comment-tree) > &
            border: 0
    .comment
        width: 480px
        padding: 4px 4px 8px 8px
    .highlighted
        color: wheat
    .selected
        background: #333
    .comment-meta
        margin-bottom: -0.2em
        color: gray
    .author-label
        text-decoration: none
    .op
        color: dodgerblue
    .mod
        color: lightgreen
    .admin
        color: orangered
    .special
        color: crimson
</style>

<script type="text/coffeescript">
    export comment =
        replies: []
    export op_id = ''
    export highlight_id = ''
    export selected_id = ''
    export select_comment = () -> {}
</script>