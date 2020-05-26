<template lang="pug">
    header
        FeedControl
    #main
        section
            Post(post='{$feed.selected}')
        nav
            PostList
        section
            Comments(promised_post='{$promises.posts[$feed.selected.id]}')
    svelte:head
        title {($feed.type === 'user' ? 'u/' : 'r/') + $feed.name}
    +if('show_post_internals')
        #post-internals
            ValueInspector(value='{$feed.selected}')
</template>

<style type="text/stylus">
    header
        flex: 0 0 62px
        border-bottom: 1px solid gray
        display: flex
        justify-content: center
    #main
        height: calc(100% - 63px)
        display: flex
    section
        flex: 0 0 calc(50% - 240px)
    nav
        flex: 0 0 480px
        display: flex
        flex-flow: column nowrap
        user-select: none
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
            promise.then (post) ->
                $promises.posts[post.id] = get_post_fragment post.id
                if post.type == 'reddit'
                    $promises.source_posts[post.id] = get_post_fragment post.source.id, post.source.comment_id, post.source.context_level
    )()
</script>