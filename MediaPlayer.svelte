<template lang="pug">
    #player(bind:this='{dom.player}')
        +if('audio_url || video_url')
            video(
                src='{video_url}'
                bind:duration='{v.duration}'
                bind:currentTime='{v.time}'
                bind:paused='{v.paused}'
            )
            audio(
                src='{audio_url}'
                bind:paused='{a.paused}'
            )
            nav
                button#mute MUTE
                #volume
                    #volume-needle
                #action
                button#fullscreen(on:mousedown!='{() => fullscreen()}') [ ]
                #position
                    button#play(on:mousedown!='{() => play_or_pause()}') ▶
                    #time(style!='transform: translateX({v.time / v.duration * 100}%)') {duration(v.time)}
            +else
                div CANNOT LOAD AUDIO/VIDEO
</template>

<style type="text/stylus">
    #player
        position: relative
        overflow: hidden
    nav
        position: absolute
        top: 0
        left: 0
        width: 100%
        height: 100%
    #action
        position: absolute
        top: 0
        right: 0
        width: 80%
        height: 90%
        display: flex
        justify-content: center
        align-items: center
        font-size: 48px
        color: red
    #mute
        position: absolute
        top: 0
        left: 0
        padding: 8px
        background: red
    #volume
        position: absolute
        top: 0
        left: 0
        height: 90%
        width: 48px
    #volume-needle
        position: absolute
        top: 50%
        right: 0
        height: 4px
        width: 100%
        background: red
    #fullscreen
        position: absolute
        bottom: 0
        right: 0
        padding: 8px
        background: black
    #position
        position: absolute
        bottom: 0
        left: 0
        width: 48px
        height: 100%
        display: flex
        align-items: flex-end
    #play
    #pause
    #stop
    #time
        background: black
</style>

<script type="text/coffeescript">
    import { duration } from './time-utils.coffee'
    export audio_url = ''
    export video_url = ''
    export video_preview_url = ''
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