<template lang="pug">
    +if('typeof value === "object"')
        +if('value === null')
            +elseif('Object.entries(value).length === 0')
            +else
                .object
                    .object-key {key}
                    .object-value
                        ol
                            +each('sort(Object.entries(value)) as [nestedKey, nestedValue]')
                                svelte:self(key='{nestedKey}' value='{nestedValue}')
        +else
            li(title='{value}' style='color: {color(value)}') {format(key, value)}
</template>

<style type="text/stylus">
    .object
        display: flex
    .object-key
        flex: 0 0 144px
        height: 12px
        color: gray
        background: #ddd
        border-top-right-radius: 12px
        border-bottom-right-radius: 12px
    .object-value
        flex: 0 0 288px
    ol
        white-space: pre
        list-style: none
</style>

<script type="text/coffeescript">
    export key = 'ROOT'
    export value = undefined
    sort = (entries) ->
        entries.sort (a, b) ->
            (order.indexOf(typeof a[1]) - order.indexOf(typeof b[1])) + ((a[0] > b[0]) - 0.5)
    order = [
        'string'
        'bigint'
        'number'
        'boolean'
        'symbol'
        'function'
        'undefined'
        'object'
    ]
    color = (value) ->
        switch typeof value
            when 'boolean'
                'darkkhaki'
            when 'number'
                'steelblue'
            when 'string'
                'salmon'
            else
                'forestgreen'
    format = (key, value) ->
        if value.toString().length > 24
            key.padEnd(23) + ' ' + value.toString()[...21] + '<<<'
        else
            key.padEnd(23) + ' ' + value.toString()
</script>