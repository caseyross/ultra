<template lang="pug">
    section
        article(bind:this='{$dom.comments}' on:scroll='{move_minimap_cursor()}' on:mousedown='{teleport_via_minimap}')
            +if('post.num_comments > 0')
                CommentTree(comment='{post}' op_id='{post.author_fullname}')
                +elseif('post.num_comments === 0')
                    #nocomments NO COMMENTS
        figure(bind:this='{$dom.minimap}')
            canvas(bind:this='{$dom.minimap_field}')
            mark(bind:this='{$dom.minimap_cursor}')
</template>


<style type="text/stylus">
    section
        flex: 0 0 40%
        contain: strict
    article
        width: 100%
        height: 100%
        padding-bottom: 16px
        overflow: auto
    #nocomments
        width: 100%
        height: 100%
        display: flex
        justify-content: center
        align-items: center
        text-align: center
        font-size: 14px
        font-weight: 900
        color: salmon
    figure
        position: absolute
        top: 0
        right: 16px
        width: 80px
        height: 100%
        padding: 17px 0
        pointer-events: none
    mark
        position: absolute
        top: 17px
        width: 100%
        display: block
        background: lightgray
        pointer-events: none
</style>

<script type="text/coffeescript">
    import { chosen, dom, history } from './core-state.js';
    import CommentTree from './CommentTree.svelte'
    export post = {}
    move_minimap_cursor = () ->
        $dom.minimap_cursor.style.transform = "translateY(#{$dom.comments.scrollTop / $dom.comments.scrollHeight * ($dom.minimap.clientHeight - 34)}px)"
    teleport_via_minimap = (click) ->
        # If clicking on minimap, jump to that location in the comments
        if 0 < $dom.comments.clientWidth - click.layerX < $dom.minimap.clientWidth 
            $dom.comments.scrollTop = (click.layerY - 17) / ($dom.minimap.clientHeight - 34) * $dom.comments.scrollHeight - $dom.minimap.clientHeight / 2
    onMount () ->
        # Size minimap, because canvas elements can't be sized properly with pure CSS
        $dom.minimap_field.width = $dom.minimap.clientWidth
        $dom.minimap_field.height = $dom.minimap.clientHeight - 34
    afterUpdate () ->
        # Redraw minimap when comments change
        if $chosen.post.id != $history.previous_post_id or $dom.comments.scrollHeight != $history.previous_comments_scrollheight
            # Clear minimap symbols
            ctx = $dom.minimap_field.getContext '2d'
            ctx.clearRect(0, 0, $dom.minimap_field.width, $dom.minimap_field.height)
            # If comments don't all fit on screen, draw the minimap 
            if $dom.comments.scrollHeight > $dom.comments.clientHeight
                # Resize cursor
                $dom.minimap_cursor.style.height = "#{($dom.comments.clientHeight - 34) * $dom.comments.clientHeight / $dom.comments.scrollHeight}px"
                # Draw new minimap symbols
                ctx.fillStyle = 'gray'
                for comment in $dom.comments.children
                    ctx.fillRect(0, Math.floor(comment.offsetTop / $dom.comments.scrollHeight * $dom.minimap.clientHeight), $dom.minimap.clientWidth, 1)
            else
                $dom.minimap_cursor.style.height = 0
</script>