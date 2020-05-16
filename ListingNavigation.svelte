<template lang="pug">
    header
        input(type='text' bind:value='{$chosen.listing.name}' placeholder='ALL')
        #rank-by
            label Top
                input(type='radio' bind:group='{$chosen.listing.rank_by.type}' value='top')
            label All
                input(type='radio' bind:group='{$chosen.listing.rank_by.filter}' value='all')
            label Yr
                input(type='radio' bind:group='{$chosen.listing.rank_by.filter}' value='year')
            label Mo
                input(type='radio' bind:group='{$chosen.listing.rank_by.filter}' value='month')
            label Wk
                input(type='radio' bind:group='{$chosen.listing.rank_by.filter}' value='week')
            label Day
                input(type='radio' bind:group='{$chosen.listing.rank_by.filter}' value='day')
            label Hot
                input(type='radio' bind:group='{$chosen.listing.rank_by.type}' value='hot')
            select(bind:value='{$chosen.listing.rank_by.filter}')
                +each('rank_by_hot_geofilters as geofilter')
                    option(value='{geofilter.id}') {geofilter.name}
            label New
                input(type='radio' bind:group='{$chosen.listing.rank_by.type}' value='new')
</template>

<style type="text/stylus">
    input
        text-align: center
        font-size: 32px
        font-weight: 900
        text-transform: uppercase
        background: #333
        &:hover
            background: wheat
            color: white
        &:focus
            outline: none
            background: wheat
            color: #333
    #rank-by
        display: flex
    label
        height: 20px
        font-size: 12px
    #rank-by-top
    #rank-by-hot
    #rank-by-new
        flex: 0 0 12%
    #rank-by-top-today
    #rank-by-top-week
    #rank-by-top-month
    #rank-by-top-year
    #rank-by-top-all
        flex: 0 0 8%
    select
        flex: 0 0 24%
        background: #222
</style>

<script type="text/coffeescript">
    import { chosen } from './core-state.coffee'
    import rank_by_hot_geofilters from './rank-by-hot-geofilters.json'
</script>