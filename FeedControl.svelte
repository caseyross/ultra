<template lang="pug">
    nav
        input(type='text' bind:value='{$feed.name}' placeholder='ALL')
        ol
            li#hot
                label
                    input(type='radio' bind:group='{$feed.rank_by.type}' value='hot')
                    span Hot
            li#new
                label
                    input(type='radio' bind:group='{$feed.rank_by.type}' value='new')
                    span New
            li#rising
                label
                    input(type='radio' bind:group='{$feed.rank_by.type}' value='rising')
                    span Rising
            li#controversial
                label
                    input(type='radio' bind:group='{$feed.rank_by.type}' value='controversial')
                    span Controversial
            li#top
                label
                    input(type='radio' bind:group='{$feed.rank_by.type}' value='top')
                    span Top
                #top-filters
                    label(title='Last 60 minutes')
                        input(type='radio' bind:group='{$feed.rank_by.filter}' value='hour')
                        span H
                    label(title='Last 24 hours')
                        input(type='radio' bind:group='{$feed.rank_by.filter}' value='day')
                        span D
                    label(title='Last 7 days')
                        input(type='radio' bind:group='{$feed.rank_by.filter}' value='week')
                        span W
                    label(title='Past month')
                        input(type='radio' bind:group='{$feed.rank_by.filter}' value='month')
                        span M
                    label(title='Past 12 months')
                        input(type='radio' bind:group='{$feed.rank_by.filter}' value='year')
                        span Y
                    label(title='All time')
                        input(type='radio' bind:group='{$feed.rank_by.filter}' value='all')
                        span A
</template>

<style type="text/stylus">
    input[type=text]
        width: 100%
        height: 38px
        text-align: center
        font-size: 32px
        font-weight: 800
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
    label
        display: inline-block
        height: 20px
        padding: 0 16px
        cursor: pointer
        :checked + span
            color: white
            font-weight: 800
    #top
        display: flex
    #top-filters
        label
            padding: 0 8px
            color: gray
    span
        width: 100%
        height: 100%
        display: flex
        justify-content: center
        align-items: center
</style>

<script type="text/coffeescript">
    import { feed } from './core-state.coffee'
</script>