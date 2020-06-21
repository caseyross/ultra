<template lang="pug">
    section.all
        section.center
            FeedControl
            PostList
        section.left
            +if('$feed.selected.id')
                Post(post='{$feed.selected}')
                +else
                    Sidebar
        section.right
            +if('$feed.selected.id')
                #rank-by
                    button#new(class:selected!='{$feed.rank_by.type === "new"}') old
                    button#hot(class:selected!='{$feed.rank_by.type === "hot"}') new
                    button#rising(class:selected!='{$feed.rank_by.type === "rising"}') score
                    button#best(class:selected!='{$feed.rank_by.type === "best"}') quality
                    #spacer-2
                    button#controversial(class:selected!='{$feed.rank_by.type === "controversial"}') ctvrsl
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
        background: #eee
        font: 400 14px/18px "Iosevka Aile"
        word-break: break-word;
        display: flex
    .center
        flex: 0 0 540px
        background: white
        border-right: 1px solid gray
        display: flex
        flex-flow: column nowrap
    .left
    .right
        flex: 0 0 calc(50% - 270px)
        display: flex
        flex-flow: column nowrap
        overflow: auto
    .left
        display: flex
        flex-flow: column wrap
        align-items: flex-end
        justify-content: center
    #rank-by
        display: flex
        align-items: center
    #spacer-2
        flex: 1
    button
        flex: 0 0 auto
        height: 24px
        padding: 0 12px
        background: #ddd
        border: 1px solid gray
        border-right-width: 0
    #best
    #controversial
    #all
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