<template lang="pug">
    nav
        +await('$promises.feed_meta')
            input(type='text' value='{$feed.name}' placeholder='')
            +then('feed_meta')
                input(type='text' value='{$feed.name}' placeholder='' style='background-image: url({feed_meta.banner_background_image})')
        ol
            li
                button Hot
            li
                button New
            li
                button Rising
            li
                button Controversial
            li#top
                button Top
                select
                    option (last 60m)
                    option (last 24h)
                    option (last 7d)
                    option (past month)
                    option (past year)
                    option (all time)
</template>

<style type="text/stylus">
    input[type=text]
        width: 100%
        height: 60px
        font-size: 36px
        font-weight: 800
        background-position: center
        background-size: cover
    ol
        margin: 0
        padding: 0
        display: flex
        justify-content: space-between
        align-items: center
        color: #ccc
        list-style: none
    button
    select
        height: 20px
        padding: 0 16px
        background: #333
    select
        padding: 0 0 1px 2px
    #top
        display: flex
        & button
            padding-right: 0
</style>

<script type="text/coffeescript">
    import { feed, promises } from './state.coffee'
</script>