<template lang="pug">
    #sidebar
        +await('$feed.info_pending')
            +then('info')
                img(src='{info.banner_background_image}')
                article {@html info.description_html}
            +catch('error')
                article {error}
</template>

<style type="text/stylus">
    #sidebar
        height: 100%
        display: flex
        flex-flow: column nowrap
    img
        flex: 0 0 auto
    article
        flex: 1
        padding: 20px
</style>

<script type="text/coffeescript">
    import { feed } from './state.coffee'
</script>