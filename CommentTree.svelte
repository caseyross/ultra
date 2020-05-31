<template lang="pug">
    +if('comment.replies.length > 0')
        +each('comment.replies as reply')
            +if('reply.body_html')
                article.comment-tree
                    .comment(tabindex=0 on:click='{select_comment(reply)}' class:highlighted='{reply.id === highlight_id}' class:selected='{reply.id === selected_id}')
                        .comment-meta
                            button.upvote(on:click|stopPropagation!='{() => null}' class:voted!='{Math.random() < 0.1}') ▲
                            span.score(
                                title!='{reply.score_hidden ? "score hidden" : "score (upvotes minus downvotes)"}'
                                class:op!='{reply.author_fullname === op_id}'
                                class:mod!='{reply.distinguished === "moderator"}'
                                class:admin!='{reply.distinguished === "admin"}'
                                class:special!='{reply.distinguished === "special"}'
                            ) {reply.score_hidden ? '-' : reply.score}
                            +if('reply.total_awards_received > 0')
                                span.awards(title='{awards_description(reply.all_awardings)}')
                                    | &nbsp;
                                    +each('Object.entries(award_buckets(reply.all_awardings)) as bucket')
                                        +if('bucket[1].length')
                                            span(class='{bucket[0]}') {'$'.repeat(bucket[1].reduce((sum, award) => sum + award.count, 0))}
                            button.downvote(on:click|stopPropagation!='{() => null}' class:voted!='{Math.random() < 0.01}') ▼
                            time(title='posted at {(new Date(reply.created_utc * 1000)).toLocaleString()}') {describe_time_since(reply.created_utc).major.value}{describe_time_since(reply.created_utc).major.unit.abbr}
                            button.author(
                                class:op!='{reply.author_fullname === op_id}'
                                class:mod!='{reply.distinguished === "moderator"}'
                                class:admin!='{reply.distinguished === "admin"}'
                                class:special!='{reply.distinguished === "special"}'
                            ) u/{reply.author}
                            +if('reply.author_flair_text')
                                span.author-flair {reply.author_flair_text}
                        | {@html reply.body_html}
                    svelte:self(comment='{reply}' op_id='{op_id}' highlight_id='{highlight_id}' selected_id='{selected_id}' select_comment='{select_comment}')
</template>


<style type="text/stylus">
    .comment-tree
        padding: 4px 0 0 20px
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
        color: white
    .comment-meta
        margin-bottom: -0.2em
        color: gray
        cursor: default
    time
        margin: 0 16px
    .author:hover
    .author:focus
        text-decoration: underline
    .op
        color: dodgerblue
    .mod
        color: lightgreen
        color: forestgreen
    .admin
        color: orangered
    .special
        color: crimson
    .argentium
        color: goldenrod
        background: white
    .platinum
        color: white
    .gold
        color: goldenrod
    .silver
        color: #ccc
    .bronze
        color: rosybrown
</style>

<script type="text/coffeescript">
    import { describe_time_since } from './tools.coffee'
    export comment =
        replies: []
    export op_id = ''
    export highlight_id = ''
    export selected_id = ''
    export select_comment = () -> {}
    award_buckets = (awards) ->
        buckets =
            argentium: []
            platinum: []
            gold: []
            silver: []
            bronze: []
        for award in awards.sort((a, b) -> (b.name < a.name) - 0.5)
            switch
                when award.coin_price < 100
                    buckets.bronze.push award
                when award.coin_price < 500
                    buckets.silver.push award
                when award.coin_price < 1800
                    buckets.gold.push award
                when award.coin_price < 20000
                    buckets.platinum.push award
                else
                    buckets.argentium.push award
        buckets
    awards_description = (awards) ->
        Object.entries(award_buckets(awards)).map((bucket) ->
            if bucket[1].length
                "#{bucket[0].toUpperCase()} AWARDS\n" +
                bucket[1].map(
                    (award) -> "#{award.count}x #{award.name}"
                ).join('\n')
            else
                ''
        ).join('\n\n')
</script>