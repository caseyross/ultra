<template lang='pug'>

    svelte:head
        +await('content.ABOUT')
            title {state.page.type + '/' + state.page.name}
            +then('about')
                title {about.title}
    Main(state='{state}' content='{content}')
    ActionMenu
    +if('inspect')
        #inspector-overlay
            DebugInspector(key='state' value='{state}')
            DebugInspector(key='content' value='{content}')

</template><style>

    #inspector-overlay
        position fixed
        top 0
        width 100%
        height 100%
        padding 1% 0
        overflow auto
        background #fed
        color black

</style><script>

    import Main from '/Main'
    import ActionMenu from '/comp/ActionMenu'
    import DebugInspector from '/comp/DebugInspector'

    # Cold load:
    state = State.read(window.location)
    content = Content.sync({}, {}, state)
    next_state = {}
    next_content = {}

    # Hot load:
    document.addEventListener 'mousedown',
        (e) ->
            for element in e.path
                if element.href
                    next_state = State.read(new URL(element.href))
                    next_content = Content.sync(content, state, next_state)
                    break
    document.addEventListener 'click',
        (e) ->
            for element in e.path
                if element.href
                    # TODO: add replaceState logic
                    history.pushState {}, '', element.href
                    state = next_state
                    content = next_content
                    e.preventDefault()
                    break
    window.addEventListener 'popstate',
        (e) ->
            next_state = State.read(window.location)
            content = Content.sync(content, state, next_state)
            state = next_state

    inspect = off
    document.keyboard_shortcuts.Backquote =
        n: 'Toggle Inspector'
        d: () => inspect = !inspect

</script>