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
            section.top
            section.bottom
                Comments(promised_post='{$promises.posts[$feed.selected.id]}')
    svelte:head
        +await('$promises.feed_meta')
            title {$feed.name === '' ? 'frontpage' : ($feed.type === 'user' ? 'u/' : 'r/') + $feed.name}
            +then('feed_meta')
                title {feed_meta.title}
    +if('$debug.inspector.mode === "object"')
        #inspector
            Inspector(value='{$debug.inspector.object}')
        +elseif('$debug.inspector.mode === "feed"')
            #inspector
                Inspector(value='{$debug.inspector.feed}')
</template>

<style type="text/stylus">
    .all
        height: 100%
        display: flex
    .center
        flex: 0 0 540px
        display: flex
        flex-flow: column nowrap
    .left
    .right
        flex: 0 0 calc(50% - 270px)
        display: flex
        flex-flow: column nowrap
        overflow: auto
    .top
        height: 80px
        border-bottom: 1px solid #333
    .bottom
        height: calc(100% - 80px)
    #inspector
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
    import { feed, promises, debug } from './state.coffee'
    import keybinds from './keybinds.coffee'
    import FeedControl from './FeedControl.svelte'
    import FeedDetails from './FeedDetails.svelte'
    import PostList from './PostList.svelte'
    import Post from './Post.svelte'
    import Comments from './Comments.svelte'
    import Inspector from './Inspector.svelte'
    document.addEventListener('keydown', (e) ->
        if e.key == keybinds.DEBUG_INSPECT_OBJECT
            if $debug.inspector.mode == 'object'
                $debug.inspector.mode = 'none'
            else
                $debug.inspector.mode = 'object'
        if e.key == keybinds.DEBUG_INSPECT_FEED
            if $debug.inspector.mode == 'feed'
                $debug.inspector.mode = 'none'
            else
                $debug.inspector.mode = 'feed'
    )
</script>