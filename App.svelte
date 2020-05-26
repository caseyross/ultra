<template lang="pug">
    #main
        Post(post='{$feed.selected}')
        nav
            FeedControl
            PostList
        Comments
    svelte:head
        title {($feed.type === 'user' ? 'u/' : 'r/') + $feed.name}
    +if('show_post_internals')
        #post-internals
            ValueInspector(value='{$feed.selected}')
</template>

<style type="text/stylus">
    #main
        height: 100%
        display: flex
        font: 300 12px/1.2 "Iosevka Aile"
        word-break: break-word
        background: #222
        color: white
    nav
        flex: 0 0 480px
        display: flex
        flex-flow: column nowrap
        user-select: none
    button
        height: 80px
        text-align: center
        font-size: 32px
        font-weight: 900
        background: #333
        color: #ccc
        &:hover
            background: wheat
            color: white
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
    import { feed, promises } from './core-state.coffee'
    import { keybinds } from './keybinds.coffee'
    import { load_feed, get_post_fragment } from './network.coffee'
    import FeedControl from './FeedControl.svelte'
    import PostList from './PostList.svelte'
    import Post from './Post.svelte'
    import Comments from './Comments.svelte'
    import ValueInspector from './ValueInspector.svelte'
    export show_post_internals = false
    document.addEventListener('keydown', (e) ->
        if e.key == keybinds.DEBUG_INSPECTOR
            show_post_internals = !show_post_internals
    )
    (() ->
        $promises.feed = load_feed($feed)
        for promise in $promises.feed
            promise.then((post) -> $promises.posts[post.id] = get_post_fragment post.id)
    )()
</script>