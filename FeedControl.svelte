<template lang="pug">
    nav
        #feed-select
            +await('$promises.feed_meta')
                img
                +then('feed_meta')
                    +if('feed_meta.community_icon')
                        img(src='{feed_meta.community_icon}')
                        +elseif('feed_meta.icon_img')
                            img(src='{feed_meta.icon_img}')
                        +else
                            img
            input(type='text' value='{$feed.name}' placeholder='frontpage')
        #rank-by
            button#new(class:selected!='{$feed.rank_by.type === "new"}') new
            button#rising(class:selected!='{$feed.rank_by.type === "rising"}') rising
            button#hot(class:selected!='{$feed.rank_by.type === "hot"}') hot
            button#best(class:selected!='{$feed.rank_by.type === "best"}') best
            .spacer
            button#controversial(class:selected!='{$feed.rank_by.type === "controversial"}') ctvrsl
            .spacer
            span#top top:
            button#hour(class:selected!='{$feed.rank_by.filter === "hour"}') h
            button#day(class:selected!='{$feed.rank_by.filter === "day"}') d
            button#week(class:selected!='{$feed.rank_by.filter === "week"}') w
            button#month(class:selected!='{$feed.rank_by.filter === "month"}') m
            button#year(class:selected!='{$feed.rank_by.filter === "year"}') y
            button#all(class:selected!='{$feed.rank_by.filter === "all"}') a
</template>

<style type="text/stylus">
    nav
        border-bottom: 1px solid gray
    #feed-select
        display: flex
        justify-content: space-between
        align-items: center
    input[type=text]
        width: 100%
        height: 48px
        font-size: 32px
        font-weight: 600
    img
        height: 32px
        flex: 0 0 32px
        margin: 0 8px
        clip-path: circle()
    ol
        margin: 0
        padding: 0
        display: flex
        justify-content: space-between
        align-items: center
        color: #ccc
        list-style: none
    #rank-by
        padding-left: 48px
        display: flex
        align-items: center
    .spacer
        flex: 1
    button
        flex: 0 0 auto
        height: 24px
        padding: 0 12px
        background: #ddd
        border: 1px solid gray
        border-width: 1px 0px 0px 1px
    #best
    #controversial
        border-right-width: 1px
    #top
        padding-right: 2px
    #hour
    #day
    #month
    #week
    #year
    #all
        padding: 0 8px
    .selected
        background: white
</style>

<script type="text/coffeescript">
    import { feed, promises } from './state.coffee'
</script>