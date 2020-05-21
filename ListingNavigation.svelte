<template lang="pug">
    header
        input(type='text' bind:value='{$chosen.listing.name}' on:change!='{e => window.location.pathname = "/r/" + e.target.value}' placeholder='ALL')
        ol
            li#new
                label
                    input(type='radio' bind:group='{$chosen.listing.rank_by.type}' value='new')
                    a(href='{window.location.pathname}?sort=new') New
            li#rising
                label
                    input(type='radio' bind:group='{$chosen.listing.rank_by.type}' value='rising')
                    a(href='{window.location.pathname}?sort=rising') Rising
            li#controversial
                label
                    input(type='radio' bind:group='{$chosen.listing.rank_by.type}' value='controversial')
                    a(href='{window.location.pathname}?sort=controversial') Controversial
            li#hot
                label
                    input(type='radio' bind:group='{$chosen.listing.rank_by.type}' value='hot')
                    a(href='{window.location.pathname}?sort=hot') Hot
            li#top
                label
                    input(type='radio' bind:group='{$chosen.listing.rank_by.type}' value='top')
                    a(href='{window.location.pathname}?sort=top') Top
                #top-filters
                    label(title='Last 60 minutes')
                        input(type='radio' bind:group='{$chosen.listing.rank_by.filter}' value='hour')
                        a(href='{window.location.pathname}?sort=top&t=hour') H
                    label(title='Last 24 hours')
                        input(type='radio' bind:group='{$chosen.listing.rank_by.filter}' value='day')
                        a(href='{window.location.pathname}?sort=top&t=day') D
                    label(title='Last 7 days')
                        input(type='radio' bind:group='{$chosen.listing.rank_by.filter}' value='week')
                        a(href='{window.location.pathname}?sort=top&t=week') W
                    label(title='Past month')
                        input(type='radio' bind:group='{$chosen.listing.rank_by.filter}' value='month')
                        a(href='{window.location.pathname}?sort=top&t=month') M
                    label(title='Past 12 months')
                        input(type='radio' bind:group='{$chosen.listing.rank_by.filter}' value='year')
                        a(href='{window.location.pathname}?sort=top&t=year') Y
                    label(title='All time')
                        input(type='radio' bind:group='{$chosen.listing.rank_by.filter}' value='all')
                        a(href='{window.location.pathname}?sort=top&t=all') A
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
        :checked + a
            background: orangered
    #controversial
        label
            width: 120px
    #top-filters
        display: flex
        label
            width: 20px
    a
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