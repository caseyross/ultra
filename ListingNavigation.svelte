<template lang="pug">
    header
        input(type='text' bind:value='{$chosen.listing.name}' placeholder='ALL')
        ol
            li#new
                label
                    input(type='radio' bind:group='{$chosen.listing.rank_by.type}' value='new')
                    span New
            li#rising
                label
                    input(type='radio' bind:group='{$chosen.listing.rank_by.type}' value='rising')
                    span Rising
            li#controversial
                label
                    input(type='radio' bind:group='{$chosen.listing.rank_by.type}' value='controversial')
                    span Controversial
            li#hot
                label
                    input(type='radio' bind:group='{$chosen.listing.rank_by.type}' value='hot')
                    span Hot
            li#top
                label
                    input(type='radio' bind:group='{$chosen.listing.rank_by.type}' value='top')
                    span Top
                #top-filters
                    label(title='Last 60 minutes')
                        input(type='radio' bind:group='{$chosen.listing.rank_by.filter}' value='hour')
                        span H
                    label(title='Last 24 hours')
                        input(type='radio' bind:group='{$chosen.listing.rank_by.filter}' value='day')
                        span D
                    label(title='Last 7 days')
                        input(type='radio' bind:group='{$chosen.listing.rank_by.filter}' value='week')
                        span W
                    label(title='Past month')
                        input(type='radio' bind:group='{$chosen.listing.rank_by.filter}' value='month')
                        span M
                    label(title='Past 12 months')
                        input(type='radio' bind:group='{$chosen.listing.rank_by.filter}' value='year')
                        span Y
                    label(title='All time')
                        input(type='radio' bind:group='{$chosen.listing.rank_by.filter}' value='all')
                        span A
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
        :checked + span
            background: orangered
    #controversial
        label
            width: 120px
    #top-filters
        display: flex
        label
            width: 20px
    span
        width: 100%
        height: 100%
        display: flex
        justify-content: center
        align-items: center
        text-decoration: none
        color: inherit
    select
        width: 120px
        height: 20px
        padding: 0px 0px 1px 4px
        background: #333
</style>

<script type="text/coffeescript">
    import { chosen } from './core-state.coffee'
</script>