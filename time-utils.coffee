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
export recency_scale = (epoch_seconds) ->
    time_since = Date.now() / 1000 - epoch_seconds
    switch
        when time_since < durations.hour.seconds
            1- 0.1 * (time_since / durations.hour.seconds)
        when time_since < durations.day.seconds
            0.9 - 0.4 * ((time_since - durations.hour.seconds) / (durations.day.seconds - durations.hour.seconds))
        when time_since < durations.week.seconds
            0.5 - 0.1 * ((time_since - durations.day.seconds) / (durations.week.seconds - durations.day.seconds))
        when time_since < durations.month.seconds
            0.4 - 0.1 * ((time_since - durations.week.seconds) / (durations.month.seconds - durations.week.seconds))
        when time_since < durations.year.seconds
            0.3 - 0.1 * ((time_since - durations.month.seconds) / (durations.year.seconds - durations.month.seconds))
        else
            0.2
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
export duration_readout = (duration_seconds, max_duration_seconds) ->
    [hours, minutes, seconds] = hours_minutes_seconds duration_seconds
    [max_hours, max_minutes, max_seconds] = hours_minutes_seconds max_duration_seconds
    if max_minutes < 10
        if seconds < 10
            "#{minutes}:0#{seconds}"
        else
            "#{minutes}:#{seconds}"
    else
        [hours, minutes, seconds]
            .map (duration) ->
                if duration < 10
                    '0' + duration
                else
                    '' + duration
            .join(':')