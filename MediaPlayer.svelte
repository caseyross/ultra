<template lang="pug">
    #player(bind:this='{dom.player}')
        +if('audio_src || video_src')
            video(bind:this='{dom.video}' src='{video_src}')
            audio(bind:this='{dom.audio}' src='{audio_src}')
            nav
                #scrubber
                    .time-readout {minimal_duration_readout(meta.time)}
                    #scrubber-track
                        #scrubber-fill(bind:this='{dom.scrubber_fill}')
                    .time-readout {minimal_duration_readout(meta.duration)}
                #buttons
                    button(on:mousedown='{play_or_pause()}') PLAY / PAUSE
                    button(on:mousedown='{fullscreen()}') FULLSCREEN
            +else
                div CANNOT LOAD AUDIO/VIDEO
</template>

<style type="text/stylus">
    #player
        width: 100%
        height: 100%
        position: relative
    nav
        width: 100%
        position: absolute
        left: 0
        bottom: 0
        background: #222
    #scrubber
    #buttons
        height: 40px
        display: flex
        justify-content: space-between
        align-items: center
    #scrubber-track
        flex: 1
        position: relative
        height: 4px
        margin: 0 8px
        background: #333
    #scrubber-fill
        position: absolute
        top: 0
        left: 0
        width: 100%
        height: 100%
        background: white
        transform-origin: left
        transform: scaleX(0)
    .time-readout
        padding: 0 16px
    button
        height: 40px
        padding: 0 16px
</style>

<script type="text/coffeescript">
    import { onMount } from 'svelte'
    import { minimal_duration_readout } from './tools.coffee'
    export audio_src = ''
    export video_src = ''
    export mini_video_src = ''
    dom =
        player: {}
        video: {}
        audio: {}
        scrubber_fill: {}
    meta =
        duration: 0
        time: 0
    play_or_pause = () ->
        if dom.video.paused
            dom.video.play()
            dom.audio.play()
        else
            dom.video.pause()
            dom.audio.pause()
    fullscreen = () ->
        if document.fullscreenElement
            document.exitFullscreen()
        else
            dom.player.requestFullscreen()
    onMount () ->
        dom.video.ondurationchange = () ->
            meta.duration = dom.video.duration
        dom.video.ontimeupdate = () ->
            meta.time = dom.video.currentTime
            dom.scrubber_fill.style.transform = "scaleX(#{ meta.time / meta.duration })"
</script>