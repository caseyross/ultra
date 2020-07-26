<template lang="pug">
    #post
        +if('post.id')
            #meta
                a#author {post.author}
            #content
                +if('post.type === "reddit"')
                    Comments(pending_post='{$feed.sources_pending[post.id]}')
                    +elseif('post.type === "link"')
                        iframe(src='{post.source}' sandbox='allow-scripts allow-same-origin')
                    +elseif('post.type === "embed"')
                        #embed {@html post.source}
                    +elseif('post.type === "audiovideo"')
                        #audiovideo
                            MediaPlayer(audio_src='{post.source.audio}' video_src='{post.source.video}' mini_video_src='{post.source.mini_video}')
                    +elseif('post.type === "image"')
                        img( src='{post.source}')
                    +elseif('post.type === "text"')
                        +if('post.source.length')
                            #self-text {@html post.source}
                            +else
                                #error-text {'NO TEXT '.repeat(64)}
                    +else
                        #error-text CANNOT PARSE POST
</template>

<style type="text/stylus">
    #post
        height: 100%
        padding: 24px
    #meta
        height: 24px
        display: flex
        justify-content: flex-end
        align-items: flex-end
    #content
        height: calc(100% - 24px)
        overflow: auto
        display: flex
        flex-flow: column nowrap
        align-items: flex-end
    #author
        background: var(--tc-m)
        color: var(--tc-s)
    #image
        position: relative
        &:hover > .src-url
            opacity: 1 
    data
        position: absolute
        background: black
        color: white
    .numbering
        top: 0
        left: 0
    .scale
        top: 0
        right: 0
    .src-url
        bottom: 0
        left: 0
        text-decoration: none
        opacity: 0
    iframe
    img
        border: 4px solid var(--tc-m)
    #self-text
        height: 100%
        padding-right: 24px
        overflow: auto
        font-size: 13px
        line-height: 1.5
        &::-webkit-scrollbar
            width: 4px
            background: transparent
        &::-webkit-scrollbar-thumb
            background: gray
    #error-text
        font-size: 64px
        font-weight: 900
        color: #eee
        transform: rotate(-45deg)
</style>

<script type="text/coffeescript">
    import { feed } from './state.coffee'
    import Comments from './Comments.svelte'
    import MediaPlayer from './MediaPlayer.svelte'
    export post = {}
    dom =
        image: {}
    scale_percent = (image) ->
        if not image.naturalWidth and image.naturalHeight then return ''
        width_fraction = image.naturalWidth / window.innerWidth * 0.4
        height_fraction = image.naturalHeight / window.innerHeight - 80
        if width_fraction > 1 and height_fraction > 1
            scale_percent = Math.trunc(Math.min(1 / width_fraction, 1 / height_fraction) * 100) + '%'
        else if width_fraction > 1
            scale_percent = Math.trunc(1 / width_fraction * 100) + '%'
        else if height_fraction > 1
            scale_percent = Math.trunc(1 / height_fraction * 100) + '%'
        else
            scale_percent = ''
</script>