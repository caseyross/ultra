<template lang="pug">
    #sidebar
        +await('$feed.METADATA')
            +then('info')
                img(src='{info.banner_background_image}')
                article {@html info.description_html}
            +catch('error')
                article {error}
</template>

<style type="text/stylus">
    #sidebar
        height: 100%
        overflow: auto
        display: flex
        flex-flow: column nowrap
        &::-webkit-scrollbar
            width: 4px
            background: transparent
        &::-webkit-scrollbar-thumb
            background: gray
    article
        padding: 20px
</style>

<script type="text/coffeescript">
    import { feed } from './state.coffee'
</script>