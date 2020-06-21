<template lang="pug">
    section
        +if('post.type !== "text"')
            a(href='{post.url}' target='_blank') {post.url}
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
    section
        height: 100%
        width: 100%
        display: flex
        flex-flow: column nowrap
        justify-content: center
        align-items: center
    a
        line-height: 24px
        padding: 0 12px
        border: 1px solid gray
        background: #ddd
        color: inherit
        text-decoration: none
    #embed
        height: 100%
    #audiovideo
        height: 100%
    article
        max-height: 100%
        padding: 32px
        overflow: auto
        background: white
        &::-webkit-scrollbar
            width: 4px
            background: transparent
        &::-webkit-scrollbar-thumb
            background: black
    #error-text
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