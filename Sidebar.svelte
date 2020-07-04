<template lang="pug">
    #sidebar
        +await('$promises.feed_meta')
            +then('feed_meta')
                img(src='{feed_meta.banner_background_image}')
                article {@html feed_meta.description_html}
            +catch('error')
                article {error}
</template>

<style type="text/stylus">
    #sidebar
        height: 100%
        display: flex
        flex-flow: column nowrap
        align-items: flex-start
        overflow: auto
        background: #eee
        &::-webkit-scrollbar
            width: 4px
            background: white
        &::-webkit-scrollbar-thumb
            background: black
    img
        flex: 0 0 auto
    article
        flex: 1
        padding: 20px
</style>

<script type="text/coffeescript">
    import { promises, debug } from './state.coffee'
    $promises.feed_meta.then (feed_meta) ->
        $debug.inspector.feed = feed_meta
</script>