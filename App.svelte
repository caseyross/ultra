<template lang="pug">
    #app
        #center
            FeedControl
            PostList
        +if('$feed.selected.id')
            #left
                .top
                .bottom
                    Post(post='{$feed.selected}')
            #right
                .top
                    #rank-by
                        button#best(class:selected!='{$feed.rank_by.type === "best"}') reddit default
                        button#top(class:selected!='{$feed.rank_by.type === "top"}') score
                        button#new(class:selected!='{$feed.rank_by.type === "new"}') recent
                        button#qa(class:selected!='{$feed.rank_by.type === "op"}') op responses
                        button#controversial(class:selected!='{$feed.rank_by.type === "controversial"}') controversial
                        button#magic(class:selected!='{$feed.rank_by.type === "magic"}') magic
                .bottom
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
    #app
        height: 100%
        background: white
        font: 400 12px/1.5 "Iosevka Aile"
        word-break: break-word
        display: flex
    .top
        flex: 0 0 73px
        border-bottom: 1px solid gray
    .bottom
        flex: 0 0 calc(100% - 73px)
        display: flex
    #center
        flex: 0 0 28%
        border-right: 1px solid gray
        display: flex
        flex-flow: column nowrap
    #left
    #right
        flex: 0 0 36%
        display: flex
        flex-flow: column nowrap
        overflow: auto
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