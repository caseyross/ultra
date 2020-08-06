<template lang="pug">
    #app
        #left
            Post(post='{$selected.post}')
        #center
            FeedControl
            Feed
        #right
            +if('$selected.post.id')
                Comments(post='{$selected.post}')
                +else
                    Sidebar
        MouseMenu
    svelte:head
        +await('$feed.METADATA')
            title {$feed.type + '/' + $feed.name}
            +then('info')
                title {info.title}
    +if('$selected.inspect_mode')
        #inspector
            +if('$selected.inspect_mode === "internals"')
                Inspector(value='{$feed}')
                +elseif('$selected.inspect_mode === "post"')
                    Inspector(value='{$selected.post}')
                +elseif('$selected.inspect_mode === "comment"')
                    Inspector(value='{$selected.comment}')
                +elseif('$selected.inspect_mode === "feed"')
                    +await('$feed.METADATA then info') 
                        Inspector(value='{info}')
</template>

<style type="text/stylus">
    #app
        height: 100%
        background: #222
        color: white
        font: 400 12px/1.2 monospace
        word-break: break-word
        display: flex
    .top
        height: 80px
        border-bottom: 1px solid gray
    .bottom
        height: calc(100% - 80px)
    #center
        flex: 0 0 20%
        padding: 0 16px
        display: flex
        flex-flow: column nowrap
    #left
    #right
        flex: 0 0 40%
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
    import { feed, selected } from './state.coffee'
    import keys from './keys.coffee'
    import FeedControl from './FeedControl.svelte'
    import Sidebar from './Sidebar.svelte'
    import Feed from './Feed.svelte'
    import Post from './Post.svelte'
    import Comments from './Comments.svelte'
    import MouseMenu from './MouseMenu.svelte'
    import Inspector from './Inspector.svelte'
    window.addEventListener('popstate', () ->
        feed.go()
    )
    document.addEventListener('keydown', (e) ->
        switch e.key
            when keys.INSPECT_INTERNALS
                if $selected.inspect_mode is 'internals'
                    $selected.inspect_mode = ''
                else
                    $selected.inspect_mode = 'internals'
            when keys.INSPECT_POST
                if $selected.inspect_mode is 'post'
                    $selected.inspect_mode = ''
                else
                    $selected.inspect_mode = 'post'
            when keys.INSPECT_COMMENT
                if $selected.inspect_mode is 'comment'
                    $selected.inspect_mode = ''
                else
                    $selected.inspect_mode = 'comment'
            when keys.INSPECT_FEED
                if $selected.inspect_mode is 'feed'
                    $selected.inspect_mode = ''
                else
                    $selected.inspect_mode = 'feed'
    )
</script>