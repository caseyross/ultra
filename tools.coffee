durations =
    year:
        seconds: 60 * 60 * 24 * 365
        abbr: 'yr'
        singular: 'year'
        plural: 'years'
    month:
        seconds: 60 * 60 * 24 * 30.36
        abbr: 'mo'
        singular: 'month'
        plural: 'months'
    week:
        seconds: 60 * 60 * 24 * 7
        abbr: 'w'
        singular: 'week'
        plural: 'weeks'
    day:
        seconds: 60 * 60 * 24
        abbr: 'd'
        singular: 'day'
        plural: 'days'
    hour:
        seconds: 60 * 60
        abbr: 'h'
        singular: 'hour'
        plural: 'hours'
    minute:
        seconds: 60
        abbr: 'm'
        singular: 'minute'
        plural: 'minutes'
    second:
        seconds: 1
        abbr: 's'
        singular: 'second'
        plural: 'seconds'
duration_description = (seconds) ->
    switch
        when seconds > durations.year.seconds
            years = Math.trunc(seconds / durations.year.seconds)
            months = Math.trunc(seconds % durations.year.seconds / durations.month.seconds)
            {
                major:
                    value: years
                    unit: durations.year
                minor:
                    value: months
                    unit: durations.month
            }
        when seconds > durations.week.seconds
            weeks = Math.trunc(seconds / durations.week.seconds)
            days = Math.trunc(seconds % durations.week.seconds / durations.day.seconds)
            {
                major:
                    value: weeks
                    unit: durations.week
                minor:
                    value: days
                    unit: durations.day
            }
        when seconds > durations.day.seconds
            days = Math.trunc(seconds / durations.day.seconds)
            hours = Math.trunc(seconds % durations.day.seconds / durations.hour.seconds)
            {
                major:
                    value: days
                    unit: durations.day
                minor:
                    value: hours
                    unit: durations.hour
            }
        when seconds > durations.hour.seconds
            hours = Math.trunc(seconds / durations.hour.seconds)
            minutes = Math.trunc(seconds % durations.hour.seconds / durations.minute.seconds)
            {
                major:
                    value: hours
                    unit: durations.hour
                minor:
                    value: minutes
                    unit: durations.minute
            }
        when seconds > durations.minute.seconds
            minutes = Math.trunc(seconds / durations.minute.seconds)
            seconds = Math.trunc(seconds % durations.minute.seconds / durations.second.seconds)
            {
                major:
                    value: minutes
                    unit: durations.minute
                minor:
                    value: seconds
                    unit: durations.second
            }
        else
            {
                major:
                    value: seconds
                    unit: durations.second
            }
export ago_description = (epoch_seconds) ->
    d = duration_description(Date.now() / 1000 - epoch_seconds)
    (if d.major.value < 10 then '&nbsp;' else '') + d.major.value + d.major.unit.abbr
export ago_description_long = (epoch_seconds) ->
    d = duration_description(Date.now() / 1000 - epoch_seconds)
    d.major.value + d.major.unit.abbr + (if d.minor then (' ' + d.minor.value + d.minor.unit.abbr) else '')
export recency_category = (epoch_seconds) ->
    time_since = Date.now() / 1000 - epoch_seconds
    switch
        when time_since < durations.hour.seconds
            {
                symbol: '●'
                value: 1
            }
        when time_since < 4 * durations.hour.seconds
            {
                symbol: '◕'
                value: 0.75
            }
        when time_since < 12 * durations.hour.seconds
            {
                symbol: '◑'
                value: 0.5
            }
        when time_since < 2 * durations.day.seconds
            {
                symbol: '◔'
                value: 0.25
            }
        else
            {
                symbol: '○'
                value: 0
            }

hours_minutes_seconds = (duration_seconds) ->
    hours = 0
    minutes = 0
    seconds = Math.trunc(duration_seconds)
    if seconds > 60 * 60
        hours = Math.trunc(seconds / 60 * 60)
        seconds = seconds % (60 * 60)
    if seconds > 60
        minutes = Math.trunc(seconds / 60)
        seconds = seconds % 60
    [hours, minutes, seconds]
export minimal_duration_readout = (duration_seconds) ->
    [hours, minutes, seconds] = hours_minutes_seconds duration_seconds
    readout = ''
    if hours > 0
        readout += hours + ':'
        if minutes < 10
            readout += '0'
        readout += minutes + ':'
        if seconds < 10
            readout += '0'
        readout += seconds
    else if minutes > 0
        readout += minutes + ':'
        if seconds < 10
            readout += '0'
        readout += seconds
    else
        readout += seconds
    readout
export full_duration_readout = (duration_seconds) ->
    [hours, minutes, seconds] = hours_minutes_seconds duration_seconds
    [hours, minutes, seconds]
        .map (duration) ->
            if duration < 10
                '0' + duration
            else
                '' + duration
        .join(':')

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