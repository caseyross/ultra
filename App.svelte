<template lang="pug">
    section.all
        section.left
            +if('$feed.selected.id')
                Post(post='{$feed.selected}')
        section.center
            FeedControl
            PostList
        section.right
            +if('$feed.selected.id')
                Comments(promised_post='{$promises.posts[$feed.selected.id]}')
                +else
                    Sidebar
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
        padding: 0 32px
        display: flex
        flex-flow: column nowrap
    .left
    .right
        flex: 0 0 calc(50% - 270px)
        display: flex
        flex-flow: column nowrap
        overflow: auto
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
    import Sidebar from './Sidebar.svelte'
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