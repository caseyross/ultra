<template lang="pug">
    article
        +await('$promises.feed_meta')
            +then('feed_meta')
                | {@html feed_meta.description_html}
            +catch('error')
                | {error}
</template>

<style type="text/stylus">
    article
        height: calc(100% - 40px)
        margin: 20px
        padding-right: 20px
        overflow: auto
        &::-webkit-scrollbar
            width: 1px
            background: transparent
        &::-webkit-scrollbar-thumb
            background: white
</style>

<script type="text/coffeescript">
    import { promises, debug } from './state.coffee'
    $promises.feed_meta.then (feed_meta) ->
        $debug.inspector.feed = feed_meta
</script>