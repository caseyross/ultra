<template lang="pug">
    section
        article(bind:this='{dom.comments}' on:scroll='{move_minimap_cursor()}' on:mousedown='{teleport_via_minimap}')
            +if('promised_post')
                +await('promised_post')
                    +then('post')
                        +if('post.num_comments > 0')
                            CommentTree(comment='{post}' op_id='{post.author_fullname}' highlight_id='{post.fragment_center}' selected_id='{selected.id}' select_comment='{select_comment}')
                            +elseif('post.num_comments === 0')
                                #nocomments
                                    button#add-first-comment ADD THE FIRST COMMENT
                    +catch('error')
                        #nocomments {error}
        figure(bind:this='{dom.minimap}')
            canvas(bind:this='{dom.minimap_field}')
            mark(bind:this='{dom.minimap_cursor}')
</template>

<style type="text/stylus">
    section
        width: 100%
        height: 100%
        position: relative
        padding-top: 12px
    article
        height: 100%
        padding-bottom: 40px
        display: flex
        flex-flow: column nowrap
        overflow: auto
        scrollbar-width: none
        &::-webkit-scrollbar
            display: none
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
        position: absolute
        top: 0
        right: 0
        width: 64px
        height: 100%
        pointer-events: none
    mark
        position: absolute
        top: 0
        width: 100%
        display: block
        pointer-events: none
        background: rgba(0, 0, 0, 0.5)
</style>

<script type="text/coffeescript">
    import { onMount, afterUpdate } from 'svelte'
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
        previous_comments_height: 0
        minimap: {}
        minimap_field: {}
        minimap_cursor: {}
        minimap_drawing_context: {}
    move_minimap_cursor = () ->
        dom.minimap_cursor.style.transform = "translateY(#{dom.comments.scrollTop / dom.comments.scrollHeight * dom.minimap.scrollHeight}px)"
    teleport_via_minimap = (click) ->
        # If clicking on minimap, jump to that location in the comments
        if 0 < dom.comments.clientWidth - click.layerX < dom.minimap.clientWidth
            dom.comments.scrollTop = click.layerY / dom.minimap.scrollHeight * dom.comments.scrollHeight - dom.minimap.scrollHeight / 2
    onMount () ->
        # Size minimap, because canvas elements can't be sized properly with pure CSS
        dom.minimap_field.width = dom.minimap.clientWidth
        dom.minimap_field.height = dom.minimap.clientHeight
        dom.minimap_drawing_context = dom.minimap_field.getContext '2d'
    afterUpdate () ->
        # Redraw minimap when comments change
        if $feed.selected.id != $feed.previous_selected.id or dom.comments.scrollHeight != dom.previous_comments_height
            draw_minimap()
            dom.previous_comments_height = dom.comments.scrollHeight
    draw_minimap = () ->
        # Clear minimap symbols
        dom.minimap_drawing_context.clearRect(0, 0, dom.minimap_field.width, dom.minimap_field.height)
        # If comments don't all fit on screen, draw the minimap
        if dom.comments.scrollHeight > dom.comments.clientHeight
            dom.minimap_cursor.style.height = "#{dom.minimap.scrollHeight * dom.comments.clientHeight / dom.comments.scrollHeight}px"
            for comment_tree in dom.comments.children
                draw_child_minimap_symbols(comment_tree, 1, 7)
        else
            dom.minimap_cursor.style.height = 0
    draw_child_minimap_symbols = (comment_tree, depth, max_depth) ->
        if depth > max_depth
            return
        comment = comment_tree.children[0]
        dom.minimap_drawing_context.fillStyle = comment.getAttribute('minimap-symbol-color') || 'gray'
        dom.minimap_drawing_context.fillRect(dom.minimap.scrollWidth / (max_depth + 1) * (depth - 1), Math.floor(comment.offsetTop / dom.comments.scrollHeight * dom.minimap.scrollHeight), 2 * (dom.minimap.scrollWidth / (max_depth + 1)), comment.clientHeight * (dom.minimap.scrollHeight / dom.comments.scrollHeight) - 2)
        for child in comment_tree.children
            if child.classList.contains 'comment-tree'
                draw_child_minimap_symbols(child, depth + 1, max_depth)

</script>