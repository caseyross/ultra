<template lang="pug">
    .comment(
        tabindex=0
        on:click='{select_comment(comment)}'
        style!='margin-left: {32 * (depth - 1)}px; border: {comment.estimated_interest > 0 ? "1px solid red" : "none"}; background: {distinguish_color(comment)}; color: {distinguish_color(comment) ? contrast_color(distinguish_color(comment)) : "inherit"}'
        class:selected='{comment.id === selected_id}'
        data-depth='{depth}'
        data-color='{distinguish_color(comment)}'
    )
        +if('comment.is_more')
            .meta + {comment.count} more
            +else
                | {@html comment.body_html}
                +if('comment.id === selected_id')
                    .meta
                        a.author {comment.author}
                        +if('comment.author_flair_text')
                            span.author-flair {comment.author_flair_text}
                        +if('comment.total_awards_received > 0')
                            span.awards(title='{awards_description(comment.all_awardings)}')
                                +each('Object.entries(award_buckets(comment.all_awardings)) as bucket')
                                    +if('bucket[1].length')
                                        span(class='{bucket[0]}') {'$'.repeat(bucket[1].reduce((sum, award) => sum + award.count, 0))}
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
        flex: 0 1 480px
        padding: 8px 4px 8px 8px
        &::before
            content: ''
            display: block
            height: 4px
            width: 4px
            background: black
            position: absolute
            top: 0
            left: 0
    .meta
        color: gray
        display: flex
    .awards
        font-weight: 700
    .author-flair
        padding: 0 8px
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
    .selected
        background: #333
        color: white
</style>

<script type="text/coffeescript">
    import { contrast_color, ago_description_long, recency_category } from './tools.coffee'
    export comment =
        replies: []
    export depth = 1
    export op_id = ''
    export highlight_id = ''
    export selected_id = ''
    export select_comment = () -> {}
    distinguish_colors =
        op: 'lightskyblue'
        mod: 'darkseagreen'
        admin: 'orangered'
        special: 'crimson',
        highlight: 'lightgoldenrodyellow'
    distinguish_color = (comment) ->
        switch comment.distinguished
            when 'moderator'
                distinguish_colors.mod
            when 'admin'
                distinguish_colors.admin
            when 'special'
                distinguish_colors.special
            else
                if comment.author_fullname == op_id
                    distinguish_colors.op
                else if comment.id == selected_id
                    distinguish_colors.highlight
                else
                    '#' + (215 + comment.depth * 8).toString(16) + (215 + comment.depth * 8).toString(16) + (215 + comment.depth * 8).toString(16)
                    ''
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