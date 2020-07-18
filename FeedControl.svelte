<template lang="pug">
    nav
        #feed-select
            input(type='text' value='{$feed.name}' placeholder='frontpage')
            +await('$feed.info_pending')
                img(src='{img_reddit_logo}')
                +then('info')
                    +if('info.community_icon')
                        img(src='{info.community_icon}')
                        +elseif('info.icon_img')
                            img(src='{info.icon_img}')
                        +else
                            img(src='{img_reddit_logo}')
        #rank-by
            button#new(class:selected!='{$feed.rank_by.type === "new"}') New
            button#rising(class:selected!='{$feed.rank_by.type === "rising"}') Rising
            button#hot(class:selected!='{$feed.rank_by.type === "hot"}') Hot
            button#best(class:selected!='{$feed.rank_by.type === "best"}') Best
            button#controversial(class:selected!='{$feed.rank_by.type === "controversial"}') Ctvsl
            select
                option Top (past 60 min)
                option Top (past 24 hrs)
                option Top (past 7 days)
                option Top (past month)
                option Top (past year)
                option Top (all time)
</template>

<style type="text/stylus">
    #feed-select
        height: 88px
        display: flex
        justify-content: space-between
        align-items: center
    input[type=text]
        width: 100%
        padding: 0 8px
        font-size: 24px
        height: 36px
        background: black
        border: 2px solid gray
        &:hover
            color: red
    img
        height: 48px
        flex: 0 0 auto
        margin-left: 8px
    #rank-by
        height: 24px
        width: 100%
        margin: 0
        padding: 0
        display: flex
        align-items: center
    button
        flex: 0 0 auto
        height: 100%
        width: 32px
        border: 1px solid gray
        border-width: 1px 0 0 1px
        background: #eee
        color: black
        font-weight: 700
    #hour
    #day
    #month
    #week
    #year
    #all
        width: 24px
    .selected
        background: white
</style>

<script type="text/coffeescript">
    import { feed } from './state.coffee'
    import img_reddit_logo from './reddit_logo.svg'
</script>