<template lang="pug">
    +if('post.id')
        +if('post.type === "reddit"')
            Comments(promised_post='{$promises.source_posts[post.id]}')
            +else
                article
                    +if('post.type === "text"')
                        +if('post.source.length')
                            #self-text {@html post.source}
                            +else
                                #error-text NO TEXT
                        +elseif('post.type === "link"')
                            iframe(src='{post.source}' sandbox='allow-scripts allow-same-origin')
                        +elseif('post.type === "embed"')
                            #embed {@html post.source}
                        +elseif('post.type === "audiovideo"')
                            MediaPlayer(audio_src='{post.source.audio}' video_src='{post.source.video}' mini_video_src='{post.source.mini_video}')
                        +elseif('post.type === "image"')
                            a(href='{post.source}' target='_blank')
                                img(src='{post.source}')
                        +else
                            #error-text CANNOT PARSE POST
</template>

<style type="text/stylus">
    article
        height: calc(100% - 40px)
        margin: 20px
        display: flex
        justify-content: flex-end
        overflow: auto
    iframe
        background: white
    #self-text
        padding-right: 20px
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
    import { promises } from './core-state.coffee'
    import { describe_time_since } from './tools.coffee'
    import Comments from './Comments.svelte'
    import MediaPlayer from './MediaPlayer.svelte'
    export post = {}
</script>