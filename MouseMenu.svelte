<template lang="pug">
    #menu(style='top: {y - 96}px; left: {x - 96}px;')
        #menu-center {choice === "center" ? '▲' : '▼'}
        #option-n Reply
        #option-e Award
        #option-s Report
        #option-w Save
</template>

<style type="text/stylus">
    #menu
        position: absolute
        width: 192px
        height: 192px
        border-radius: 50%
        background: conic-gradient(var(--tc-m) 25%, transparent 25%)
        display: flex
        justify-content: center
        align-items: center
        font-size: 24px
        cursor: crosshair
    #menu-center
        width: 48px
        height: 48px
        border-radius: 50%
        display: flex
        justify-content: center
        align-items: center
    #option-n
    #option-e
    #option-s
    #option-w
        position: absolute
        font-size: 12px
        background: var(--tc-m)
    #option-n
        top: 32px
    #option-e
        left: 136px
    #option-s
        bottom: 32px
    #option-w
        right: 136px
</style>

<script type="text/coffeescript">
    export x = 0
    export y = 0
    export choice = 'center'
</script>