<template lang="pug">
    section.all
        section.left
            section.top
            section.bottom
                +if('$feed.selected.id')
                    Post(post='{$feed.selected}')
                    +else
                        FeedDetails
        section.center
            FeedControl
            PostList
        section.right
            Comments(promised_post='{$promises.posts[$feed.selected.id]}')
    svelte:head
        title {$feed.name === '' ? 'frontpage' : $feed.name}
    +if('show_post_internals')
        #post-internals
            ValueInspector(value='{$feed.selected}')
</template>

<style type="text/stylus">
    .all
        height: 100%
        display: flex
    .center
        flex: 0 0 480px
        display: flex
        flex-flow: column nowrap
    .left
    .right
        flex: 0 0 calc(50% - 240px)
        display: flex
        flex-flow: column nowrap
    .top
        height: 80px
        border-bottom: 1px solid #333
    .bottom
        height: calc(100% - 80px)
    #post-internals
        position: fixed
        top: 0
        width: 100%
        height: 100%
        display: flex
        overflow: auto
        font: 700 12px/1.2 Iosevka
        background: #fed
</style>

<script type="text/coffeescript">
    import { feed, promises } from './state.coffee'
    import keybinds from './keybinds.coffee'
    import FeedControl from './FeedControl.svelte'
    import FeedDetails from './FeedDetails.svelte'
    import PostList from './PostList.svelte'
    import Post from './Post.svelte'
    import Comments from './Comments.svelte'
    import ValueInspector from './ValueInspector.svelte'
    export show_post_internals = false
    document.addEventListener('keydown', (e) ->
        if e.key == keybinds.DEBUG_INSPECTOR
            show_post_internals = !show_post_internals
    )
</script>