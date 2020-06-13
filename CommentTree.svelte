<template lang="pug">
    .comment(minimap-symbol-color!='{distinguish_color(comment) || "black"}')
        .spacer(style='flex: 0 0 {20 * depth}px')
        .voting
            +if('!comment.is_more')
                button.upvote(on:click|stopPropagation!='{() => null}' class:voted!='{Math.random() < 0.1}') ▲
                button.downvote(on:click|stopPropagation!='{() => null}' class:voted!='{Math.random() < 0.01}') ▼
        .body(
            tabindex=0
            on:click='{select_comment(comment)}'
            class:highlighted='{comment.id === highlight_id}'
            class:selected='{comment.id === selected_id}'
        )
            +if('comment.is_more')
                .meta + {comment.count} more
                +else
                    .meta
                        time(title!='{ago_description_long(comment.created_utc) + " ago - " + (new Date(comment.created_utc * 1000)).toLocaleString()}') {comment.estimated_interest}
                        +if('comment.total_awards_received > 0')
                            span.awards(title='{awards_description(comment.all_awardings)}')
                                +each('Object.entries(award_buckets(comment.all_awardings)) as bucket')
                                    +if('bucket[1].length')
                                        span(class='{bucket[0]}') {'$'.repeat(bucket[1].reduce((sum, award) => sum + award.count, 0))}
                        a.author(style='color: {distinguish_color(comment)}') {comment.author}
                        +if('comment.author_flair_text')
                            span.author-flair {comment.author_flair_text}
                    | {@html comment.body_html}
    +each('comment.replies as comment')
        svelte:self(comment='{comment}' depth='{depth + 1}' op_id='{op_id}' highlight_id='{highlight_id}' selected_id='{selected_id}' select_comment='{select_comment}')
</template>


<style type="text/stylus">
    a
        color: inherit
        &:hover
        &:focus
            text-decoration: underline
    .comment
        display: flex
    .voting
        flex: 0 0 14px
        margin-top: 8px
        display: flex
        flex-flow: column nowrap
    .body
        flex: 0 1 480px
        padding: 8px 4px 8px 8px
    .meta
        font-size: 12px
        color: gray
        cursor: default
        display: flex
    time
        margin-right: 6px
        width: 27px
        height: 16px
        text-align: center
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
    .highlighted
        color: wheat
    .selected
        background: #333
        color: white
</style>

<script type="text/coffeescript">
    import { ago_description_long, recency_category } from './tools.coffee'
    export comment =
        replies: []
    export depth = 0
    export op_id = ''
    export highlight_id = ''
    export selected_id = ''
    export select_comment = () -> {}
    distinguish_colors =
        op: 'royalblue'
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