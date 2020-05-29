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
        &::-webkit-scrollbar-thumb
            width: 1px
            background: white
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
        width: 60px
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
    import { feed } from './core-state.coffee';
    import CommentTree from './CommentTree.svelte'
    export promised_post = undefined
    selected =
        id: ''
    select_comment = (comment) ->
        selected = comment
    dom =
        comments: {}
        previous_comments_scrollheight: 0
        minimap: {}
        minimap_field: {}
        minimap_cursor: {}
    move_minimap_cursor = () ->
        dom.minimap_cursor.style.transform = "translateY(#{dom.comments.scrollTop / dom.comments.scrollHeight * dom.minimap.clientHeight}px)"
    teleport_via_minimap = (click) ->
        # If clicking on minimap, jump to that location in the comments
        if 0 < dom.comments.clientWidth - click.layerX < dom.minimap.clientWidth 
            dom.comments.scrollTop = click.layerY / dom.minimap.clientHeight * dom.comments.scrollHeight - dom.minimap.clientHeight / 2
    onMount () ->
        # Size minimap, because canvas elements can't be sized properly with pure CSS
        dom.minimap_field.width = dom.minimap.clientWidth
        dom.minimap_field.height = dom.minimap.clientHeight
    afterUpdate () ->
        # Redraw minimap when comments change
        if $feed.selected.id != $feed.previous_selected.id or dom.comments.scrollHeight != dom.previous_comments_scrollheight
            # Clear minimap symbols
            ctx = dom.minimap_field.getContext '2d'
            ctx.clearRect(0, 0, dom.minimap_field.width, dom.minimap_field.height)
            # If comments don't all fit on screen, draw the minimap 
            if dom.comments.scrollHeight > dom.comments.clientHeight
                # Resize cursor
                dom.minimap_cursor.style.height = "#{dom.comments.clientHeight * dom.comments.clientHeight / dom.comments.scrollHeight}px"
                # Draw new minimap symbols
                for comment in dom.comments.children
                    ctx.fillStyle = '#999'
                    ctx.fillRect(0, Math.floor(comment.offsetTop / dom.comments.scrollHeight * dom.minimap.clientHeight), dom.minimap.clientWidth / 3, 1)
                    if comment.children.length > 1
                        for l2_comment, i in comment.children
                            if (i > 0)
                                ctx.fillStyle = '#666'
                                ctx.fillRect(dom.minimap.clientWidth / 3 + 1, Math.floor(l2_comment.offsetTop / dom.comments.scrollHeight * dom.minimap.clientHeight), dom.minimap.clientWidth / 3, 1)
                            if l2_comment.children.length > 1
                                for l3_comment, i in l2_comment.children
                                    if (i > 0)
                                        ctx.fillStyle = '#333'
                                        ctx.fillRect(dom.minimap.clientWidth / 3 * 2 + 1, Math.floor(l3_comment.offsetTop / dom.comments.scrollHeight * dom.minimap.clientHeight), dom.minimap.clientWidth / 3, 1)
            else
                dom.minimap_cursor.style.height = 0
            dom.previous_comments_scrollheight = dom.comments.scrollHeight
</script>