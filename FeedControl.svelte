<template lang="pug">
    nav
        #feed-select
            input(type='text' value='{$feed.type}/{$feed.name}')
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
            #rank-by-top
                button#top(class:selected!='{$feed.rank_by.type === "top"}') Top
                select
                    option (60 min)
                    option (24 hrs)
                    option (7 days)
                    option (month)
                    option (year)
                    option (all time)
</template>

<style type="text/stylus">
    nav
        margin-bottom: 16px
    #feed-select
        padding-top: 20px
        margin-bottom: 8px
        display: flex
        justify-content: space-between
    input[type=text]
        width: 100%
        padding: 0 8px
        font-size: 24px
        height: 36px
        background: black
        border: 1px solid
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
        justify-content: space-between
        align-items: center
    button
        flex: 0 0 auto
        height: 100%
        &:hover
            color: red
    option
        color: black
    #hour
    #day
    #month
    #week
    #year
    #all
        width: 24px
    .selected
        color: yellow
</style>

<script type="text/coffeescript">
    import { feed } from './state.coffee'
    import img_reddit_logo from './reddit_logo.svg'
</script>