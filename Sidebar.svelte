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
        height: 100%
        padding: 20px
        overflow: auto
        background: #eee
        &::-webkit-scrollbar
            width: 4px
            background: white
        &::-webkit-scrollbar-thumb
            background: black
</style>

<script type="text/coffeescript">
    import { promises, debug } from './state.coffee'
    $promises.feed_meta.then (feed_meta) ->
        $debug.inspector.feed = feed_meta
</script>