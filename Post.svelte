<template lang="pug">
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
                img(src='{post.source}')
        +elseif('post.type === "text"')
            article
                    +if('post.source.length')
                        #self-text {@html post.source}
                        +else
                            #error-text NO TEXT
        +else
            #error-text CANNOT PARSE POST
</template>

<style type="text/stylus">
    #embed
        height: 100%
    #audiovideo
        height: 100%
    #image
        max-height: 100%
        display: flex
        justify-content: flex-end
    article
        height: 100%
        padding: 20px
        border-right: 1px solid gray
        display: flex
        justify-content: flex-end
        overflow: auto
        &::-webkit-scrollbar
            width: 4px
            background: transparent
        &::-webkit-scrollbar-thumb
            background: black
    #self-text
        width: 100%
    #error-text
        width: 100%
        height: 100%
        display: flex
        justify-content: center
        align-items: center
        font-size: 14px
        font-weight: 900
        color: salmon
</style>

<script type="text/coffeescript">
    import { promises } from './state.coffee'
    import Comments from './Comments.svelte'
    import MediaPlayer from './MediaPlayer.svelte'
    export post = {}
</script>