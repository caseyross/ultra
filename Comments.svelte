<template lang="pug">
    section
        #comments(bind:this='{dom.comments}' on:mousedown='{teleport_via_minimap}')
            +if('promised_post')
                +await('promised_post')
                    #nocomments LOADING...
                    +then('post')
                        +if('post.num_comments > 0')
                            article(use:reset_scroll use:draw_minimap)
                                +each('post.replies as comment')
                                    CommentTree(comment='{comment}' op_id='{post.author_fullname}' highlight_id='{post.fragment_center}' selected_id='{selected.id}' select_comment='{select_comment}')
                            +elseif('post.num_comments === 0')
                                #nocomments
                                    button#add-first-comment ADD THE FIRST COMMENT
                    +catch('error')
                        #nocomments {error}
        figure(bind:this='{dom.minimap}')
            canvas(bind:this='{dom.minimap_field}')
</template>

<style type="text/stylus">
    section
        contain: strict
        width: 100%
        height: 100%
        display: flex
        flex-flow: column nowrap
    #comments
        height: 100%
        width: 100%
        padding-right: 64px
        overflow: auto
        will-change: transform //https://bugs.chromium.org/p/chromium/issues/detail?id=514303
        background: white
        &::-webkit-scrollbar
            width: 4px
            background: transparent
        &::-webkit-scrollbar-thumb
            background: black
    article
        padding: 32px
    #nocomments
        height: 100%
        display: flex
        justify-content: center
        align-items: center
        text-align: center
        font-size: 14px
        font-weight: 900
        color: salmon
    #add-first-comment
        padding: 40px
        border: 1px dotted
        &:hover
        &:focus
            border-style: solid
            text-decoration: underline
    figure
        height: 100%
        width: 64px
        position: absolute
        top: 0
        right: 0
        pointer-events: none
</style>

<script type="text/coffeescript">
    import { onMount } from 'svelte'
    import { feed, debug } from './state.coffee';
    import CommentTree from './CommentTree.svelte'
    export promised_post = undefined
    selected =
        id: ''
    select_comment = (comment) ->
        selected = comment
        $debug.inspector.object = comment
    dom =
        comments: {}
        minimap: {}
        minimap_field: {}
    teleport_via_minimap = (click) ->
        if dom.comments.clientWidth - click.layerX < 64
            dom.comments.scrollTop = click.layerY / dom.minimap.scrollHeight * dom.comments.scrollHeight - dom.minimap.scrollHeight / 2
    onMount () ->
        # <canvas> can't be sized properly in static CSS (only scaled)
        dom.minimap_field.width = dom.minimap.clientWidth
        dom.minimap_field.height = dom.minimap.clientHeight
    reset_scroll = () ->
        dom.comments.scrollTop = 0
    draw_minimap = () ->
        canvas_context = dom.minimap_field.getContext '2d'
        # Clear symbols
        canvas_context.clearRect(0, 0, dom.minimap_field.width, dom.minimap_field.height)
        # If comments don't all fit on screen, draw symbols
        if dom.comments.scrollHeight > dom.comments.clientHeight
            max_depth = 8
            for comment in dom.comments.firstChild.children
                depth = comment.dataset.depth
                if (depth <= max_depth)
                    canvas_context.fillStyle = comment.dataset.color || "rgba(0, 0, 0, #{1 - depth * 0.1})"
                    canvas_context.fillRect(dom.minimap.scrollWidth / max_depth * (depth - 1), Math.trunc(comment.offsetTop / dom.comments.scrollHeight * dom.minimap.scrollHeight), dom.minimap.scrollWidth / max_depth, comment.scrollHeight / dom.comments.scrollHeight * dom.minimap.scrollHeight)
</script>