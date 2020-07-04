<template lang="pug">
    #player(bind:this='{dom.player}')
        +if('audio_src || video_src')
            video(
                src='{video_src}'
                bind:duration='{v.duration}'
                bind:currentTime='{v.time}'
                bind:paused='{v.paused}'
            )
            audio(
                src='{audio_src}'
                bind:paused='{a.paused}'
            )
            nav
                #scrubber
                    .time-readout {minimal_duration_readout(v.time)}
                    #scrubber-track
                        #scrubber-fill(style!='transform: scaleX({ v.time / v.duration })')
                    .time-readout {minimal_duration_readout(v.duration)}
                #buttons
                    button(on:mousedown='{play_or_pause()}') PLAY / PAUSE
                    button(on:mousedown='{fullscreen()}') FULLSCREEN
            +else
                div CANNOT LOAD AUDIO/VIDEO
</template>

<style type="text/stylus">
    #player
        position: relative
    nav
        position: absolute
        left: 0
        bottom: 0
        width: 100%
        background: white
        border: 1px solid
    #scrubber
    #buttons
        height: 24px
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
    import { minimal_duration_readout } from './tools.coffee'
    export audio_src = ''
    export video_src = ''
    export mini_video_src = ''
    dom =
        player: {}
    a =
        paused: true
    v =
        duration: 0
        time: 0
        paused: true
    play_or_pause = () ->
        v.paused = not v.paused
        a.paused = not a.paused
    fullscreen = () ->
        if document.fullscreenElement
            document.exitFullscreen()
        else
            dom.player.requestFullscreen()
</script>