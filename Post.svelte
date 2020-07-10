<template lang="pug">
    #post
        +if('post.type === "reddit"')
            Comments(promised_post='{$promises.source_posts[post.id]}')
            +elseif('post.type === "link"')
                iframe(src='{post.source}' sandbox='allow-scripts allow-same-origin')
            +elseif('post.type === "embed"')
                #embed {@html post.source}
            +elseif('post.type === "audiovideo"')
                #audiovideo
                    MediaPlayer(audio_src='{post.source.audio}' video_src='{post.source.video}' mini_video_src='{post.source.mini_video}')
            +elseif('post.type === "image"')
                a#image(href='{post.source}' target='_blank')
                    img(use:calculate_scale src='{post.source}')
                    data.numbering
                    data.scale {dom.image ? dom.image.naturalWidth : ''}
                    data.src-url {post.source}
            +elseif('post.type === "text"')
                article
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
        width: 100%
        display: flex
        flex-flow: column nowrap
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
    #embed
        width: 100%
        height: 100%
    #audiovideo
        width: 100%
        height: 100%
    article
        height: 100%
        padding: 32px
        overflow: auto
        background: white
        &::-webkit-scrollbar
            width: 4px
            background: transparent
        &::-webkit-scrollbar-thumb
            background: black
    #error-text
        font-size: 64px
        font-weight: 900
        color: #eee
        transform: rotate(-45deg)
</style>

<script type="text/coffeescript">
    import { promises } from './state.coffee'
    import Comments from './Comments.svelte'
    import MediaPlayer from './MediaPlayer.svelte'
    export post = {}
    dom =
        image: {}
    calculate_scale = (image) ->
        console.log(image)
</script>