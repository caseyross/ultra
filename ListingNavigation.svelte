<template lang="pug">
    header
        input(type='text' bind:value='{$chosen.listing.name}' placeholder='ALL')
        ol
            li#hot
                label
                    input(type='radio' bind:group='{$chosen.listing.rank_by.type}' value='hot')
                    div Hot
                +if('$chosen.listing.name === "popular" && $chosen.listing.type === "subreddit"')
                    select(bind:value='{$chosen.listing.rank_by.filter}')
                        +each('rank_by_hot_geofilters as geofilter')
                            option(value='{geofilter.id}') {geofilter.name}
            +if('$chosen.listing.name !== "popular" || $chosen.listing.type !== "subreddit"')
                li#controversial
                    label
                        input(type='radio' bind:group='{$chosen.listing.rank_by.type}' value='controversial')
                        div Controversial
            li#top
                label
                    input(type='radio' bind:group='{$chosen.listing.rank_by.type}' value='top')
                    div Top
                #top-filters
                    label(title='This hour')
                        input(type='radio' bind:group='{$chosen.listing.rank_by.filter}' value='hour')
                        div H
                    label(title='Last 24 hours')
                        input(type='radio' bind:group='{$chosen.listing.rank_by.filter}' value='day')
                        div D
                    label(title='This week')
                        input(type='radio' bind:group='{$chosen.listing.rank_by.filter}' value='week')
                        div W
                    label(title='This month')
                        input(type='radio' bind:group='{$chosen.listing.rank_by.filter}' value='month')
                        div M
                    label(title='This year')
                        input(type='radio' bind:group='{$chosen.listing.rank_by.filter}' value='year')
                        div Y
                    label(title='All time')
                        input(type='radio' bind:group='{$chosen.listing.rank_by.filter}' value='all')
                        div A
            li#new
                label
                    input(type='radio' bind:group='{$chosen.listing.rank_by.type}' value='new')
                    div New
</template>

<style type="text/stylus">
    header
        font-size: 12px
        font-weight: 900
    input[type=text]
        width: 100%
        height: 38px
        text-align: center
        font-size: 32px
        text-transform: uppercase
        &:focus
            color: orangered
    input[type=radio]
        display: none
    ol
        margin: 4px 0 0 0
        padding: 0
        display: flex
        justify-content: space-between
        color: #ccc
        list-style: none
    li
        display: flex
        background: #333
    label
        width: 60px
        height: 20px
        cursor: pointer
        :checked + div
            background: orangered
    #controversial
        label
            width: 111px
    #top-filters
        label
            width: 20px
        :checked + div
            background: initial
            color: orangered
    div
        height: 100%
        display: flex
        justify-content: center
        align-items: center
    select
        width: 120px
        height: 20px
        padding: 0px 0px 1px 4px
        background: #333
</style>

<script type="text/coffeescript">
    import { chosen } from './core-state.coffee'
    import rank_by_hot_geofilters from './rank-by-hot-geofilters.json'
</script>