export decode_reddit_html_entities = (text) ->
    text
    .replace(/&amp;/g, '&')
    .replace(/&quot;/g, '"')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')

durations =
    year:
        milliseconds: 1000 * 60 * 60 * 24 * 365
        abbr: 'y'
        singular: 'year'
        plural: 'years'
    month:
        milliseconds: 1000 * 60 * 60 * 24 * 30.36
        abbr: 'm'
        singular: 'month'
        plural: 'months'
    week:
        milliseconds: 1000 * 60 * 60 * 24 * 7
        abbr: 'w'
        singular: 'week'
        plural: 'weeks'
    day:
        milliseconds: 1000 * 60 * 60 * 24
        abbr: 'd'
        singular: 'day'
        plural: 'days'
    hour:
        milliseconds: 1000 * 60 * 60
        abbr: 'h'
        singular: 'hour'
        plural: 'hours'
    minute:
        milliseconds: 1000 * 60
        abbr: 'm'
        singular: 'minute'
        plural: 'minutes'
    second:
        milliseconds: 1000
        abbr: 's'
        singular: 'second'
        plural: 'seconds'
    millisecond:
        milliseconds: 1
        abbr: 'ms'
        singular: 'millisecond'
        plural: 'milliseconds'
export describe_duration = (milliseconds) ->
    switch
        when milliseconds > durations.year.milliseconds
            years = Math.floor(milliseconds / durations.year.milliseconds)
            months = Math.floor(milliseconds % durations.year.milliseconds / durations.month.milliseconds)
            {
                major:
                    value: years
                    unit: durations.year
                minor:
                    value: months
                    unit: durations.month
            }
        when milliseconds > durations.month.milliseconds
            months = Math.floor(milliseconds / durations.month.milliseconds)
            weeks = Math.floor(milliseconds % durations.month.milliseconds / durations.week.milliseconds)
            {
                major:
                    value: months
                    unit: durations.month
                minor:
                    value: weeks
                    unit: durations.week
            }
        when milliseconds > durations.week.milliseconds
            weeks = Math.floor(milliseconds / durations.week.milliseconds)
            days = Math.floor(milliseconds % durations.week.milliseconds / durations.day.milliseconds)
            {
                major:
                    value: weeks
                    unit: durations.week
                minor:
                    value: days
                    unit: durations.day
            }
        when milliseconds > durations.day.milliseconds
            days = Math.floor(milliseconds / durations.day.milliseconds)
            hours = Math.floor(milliseconds % durations.day.milliseconds / durations.hour.milliseconds)
            {
                major:
                    value: days
                    unit: durations.day
                minor:
                    value: hours
                    unit: durations.hour
            }
        when milliseconds > durations.hour.milliseconds
            hours = Math.floor(milliseconds / durations.hour.milliseconds)
            minutes = Math.floor(milliseconds % durations.hour.milliseconds / durations.minute.milliseconds)
            {
                major:
                    value: hours
                    unit: durations.hour
                minor:
                    value: minutes
                    unit: durations.minute
            }
        when milliseconds > durations.minute.milliseconds
            minutes = Math.floor(milliseconds / durations.minute.milliseconds)
            seconds = Math.floor(milliseconds % durations.minute.milliseconds / durations.second.milliseconds)
            {
                major:
                    value: minutes
                    unit: durations.minute
                minor:
                    value: seconds
                    unit: durations.second
            }
        when milliseconds > durations.second.milliseconds
            seconds = Math.floor(milliseconds / durations.second.milliseconds)
            {
                major:
                    value: seconds
                    unit: durations.second
            }
        else
            {
                major:
                    value: milliseconds
                    unit: durations.millisecond
            }

import gfycat_adjectives from './gfycat-adjectives.json'
import gfycat_animals from './gfycat-animals.json'
export titlecase_gfycat_video_id = (video_id) ->
    match_words = () ->
        for adjective_1 in gfycat_adjectives
            if video_id.startsWith adjective_1
                for adjective_2 in gfycat_adjectives
                    if video_id[adjective_1.length...].startsWith adjective_2
                        for animal in gfycat_animals
                            if video_id[(adjective_1.length + adjective_2.length)...] == animal
                                return [adjective_1, adjective_2, animal]
        return ['', '', '']
    [adjective_1, adjective_2, animal] = match_words()
    if not (adjective_1 and adjective_2 and animal)
        gfycat_adjectives.reverse()
        [adjective_1, adjective_2, animal] = match_words()
        gfycat_adjectives.reverse()
    if not (adjective_1 and adjective_2 and animal)
        return ''
    adjective_1[0].toUpperCase() + adjective_1[1...] + adjective_2[0].toUpperCase() + adjective_2[1...] + animal[0].toUpperCase() + animal[1...]