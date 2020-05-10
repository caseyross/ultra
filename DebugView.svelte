<template lang="pug">
    #debug-objects
        +each('objects as object')
            DebugObjectTree(value='{object}')
</template>

<style type="text/stylus">
    #debug-objects
        width: 100%
        height: 100%
        display: flex
        overflow: auto
        font: 700 12px/1.2 Iosevka
        background: #fed
</style>

<script type="text/coffeescript">
    import DebugObjectTree from './DebugObjectTree.svelte'
    export objects = {}
</script>