<template lang="pug">
    +if('comment.replies.length > 0')
        +each('comment.replies as reply')
            +if('reply.body_html')
                article.comment-tree
                    .comment(
                        tabindex=0
                        on:click='{select_comment(reply)}'
                        class:highlighted='{reply.id === highlight_id}'
                        class:selected='{reply.id === selected_id}'
                        minimap-symbol-color='{distinguish_color(reply)}'
                    )
                        .voting
                            button.upvote(on:click|stopPropagation!='{() => null}' class:voted!='{Math.random() < 0.1}') ▲
                            button.downvote(on:click|stopPropagation!='{() => null}' class:voted!='{Math.random() < 0.01}') ▼
                        .main
                            .meta
                                time.time-since(title='posted at {(new Date(reply.created_utc * 1000)).toLocaleString()}') {describe_time_since(reply.created_utc).major.value}{describe_time_since(reply.created_utc).major.unit.abbr}
                                +if('reply.total_awards_received > 0')
                                    span.awards(title='{awards_description(reply.all_awardings)}')
                                        +each('Object.entries(award_buckets(reply.all_awardings)) as bucket')
                                            +if('bucket[1].length')
                                                span(class='{bucket[0]}') {'$'.repeat(bucket[1].reduce((sum, award) => sum + award.count, 0))}
                                a.author(style='color: {distinguish_color(reply)}') {reply.author}
                                +if('reply.author_flair_text')
                                    span.author-flair {reply.author_flair_text}
                            | {@html reply.body_html}
                    svelte:self(comment='{reply}' op_id='{op_id}' highlight_id='{highlight_id}' selected_id='{selected_id}' select_comment='{select_comment}')
</template>


<style type="text/stylus">
    a
        color: inherit
        &:hover
        &:focus
            text-decoration: underline
    .comment-tree
        padding: 4px 0 0 20px
        word-break: break-word
        & > &
            border-left: 1px solid #ccc
    .comment
        width: 480px
        padding: 4px 4px 8px 8px
        font: 14px/18px Charter
        display: flex
    .highlighted
        color: wheat
    .selected
        background: #333
        color: white
    .voting
        flex: 0 0 12px
        margin-right: 8px
        font-size: 12px
        display: flex
        flex-flow: column nowrap
    .meta
        margin-bottom: 3px
        font: 12px/1 "Iosevka Aile"
        color: gray
        cursor: default
    .time-since
        display: inline-block
        margin-right: 6px
        padding: 2px 6px 1px 6px
        border: 1px solid
    .awards
        margin-right: 8px
        font-weight: 700
    .author-flair
        margin-left: 6px
        font-style: italic
    .argentium
        background: orangered
        color: black
    .platinum
        background: white
        color: black
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
    distinguish_colors =
        op: 'deepskyblue'
        mod: 'lightgreen'
        mod: 'forestgreen'
        admin: 'orangered'
        special: 'crimson'
    distinguish_color = (reply) ->
        switch reply.distinguished
            when 'moderator'
                distinguish_colors.mod
            when 'admin'
                distinguish_colors.admin
            when 'special'
                distinguish_colors.special
            else
                if reply.author_fullname == op_id
                    distinguish_colors.op
                else
                    null
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