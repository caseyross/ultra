<template lang="pug">
    #app
        #left
            +if('$feed.selected_post.id')
                Post(post='{$feed.selected_post}')
        #center
            FeedControl
            PostList
        #right
            +if('$feed.selected_post.id')
                Comments(pending_post='{$feed.posts_pending[$feed.selected_post.id]}')
                +else
                    Sidebar
    svelte:head
        +await('$feed.info_pending')
            title {$feed.name === '' ? 'frontpage' : ($feed.type === 'user' ? 'u/' : 'r/') + $feed.name}
            +then('info')
                title {info.title}
    +if('$inspector.mode === "object"')
        #inspector
            Inspector(value='{$inspector.object}')
        +elseif('$inspector.mode === "feed"')
            #inspector
                Inspector(value='{$inspector.feed}')
</template>

<style type="text/stylus">
    #app
        height: 100%
        background: #222
        color: white
        font: 400 12px/1.5 "Iosevka Aile"
        word-break: break-word
        display: flex
    .top
        flex: 0 0 80px
        border-bottom: 1px solid gray
    .bottom
        flex: 0 0 calc(100% - 80px)
    #center
        flex: 0 0 20%
        padding: 0 16px
        display: flex
        flex-flow: column nowrap
    #left
    #right
        flex: 0 0 40%
        padding: 24px
        display: flex
        flex-flow: column nowrap
    #rank-by
        display: flex
    button
        flex: 0 0 auto
        height: 24px
        padding: 0 12px
        background: #ddd
        border: 1px solid gray
        border-right-width: 0
    #magic
        border-right-width: 1px
    .selected
        background: white
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
    import { feed, inspector } from './state.coffee'
    import keybinds from './keybinds.coffee'
    import FeedControl from './FeedControl.svelte'
    import Sidebar from './Sidebar.svelte'
    import PostList from './PostList.svelte'
    import Post from './Post.svelte'
    import Comments from './Comments.svelte'
    import Inspector from './Inspector.svelte'
    document.addEventListener('keydown', (e) ->
        if e.key == keybinds.DEBUG_INSPECT_OBJECT
            if $inspector.mode == 'object'
                $inspector.mode = 'none'
            else
                $inspector.mode = 'object'
        if e.key == keybinds.DEBUG_INSPECT_FEED
            if $inspector.mode == 'feed'
                $inspector.mode = 'none'
            else
                $inspector.mode = 'feed'
    )
</script>