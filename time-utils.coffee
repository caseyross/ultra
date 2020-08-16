# about 8 hours ago
export reltime = (seconds_ago) ->
    if seconds_ago < 1
        return 'now'
    if seconds_ago < 60
        return "#{seconds_ago} second(s) ago"
    minutes_ago = Math.trunc(seconds_ago / 60 + 0.5)
    if minutes_ago < 60
        return "#{minutes_ago} minute(s) ago"
    hours_ago = Math.trunc(minutes_ago / 60 + 0.5)
    if hours_ago < 24
        return "about #{hours_ago} hour(s) ago"
    days_ago = Math.trunc(hours_ago / 24 + 0.5)
    if days_ago < 7
        return "about #{days_ago} day(s) ago"
    weeks_ago = Math.trunc(days_ago / 7 + 0.5)
    if weeks_ago < 5
        return "about #{weeks_ago} week(s) ago"
    months_ago = Math.trunc(weeks_ago / 4 + 0.5)
    if months_ago < 12
        return "about #{months_ago} month(s) ago"
    years_ago = Math.trunc(months_ago / 12 + 0.5)
    return "about #{years_ago} year(s) ago"

# Mar 20 2020, 14:03
export abstime = (x) ->
    month = switch x.getMonth()
        when 0: 'Jan'
        when 1: 'Feb'
        when 2: 'Mar'
        when 3: 'Apr'
        when 4: 'May'
        when 5: 'Jun'
        when 6: 'Jul'
        when 7: 'Aug'
        when 8: 'Sep'
        when 9: 'Oct'
        when 10: 'Nov'
        when 11: 'Dec'
    day = x.getDate().padStart(2, '0')
    year = x.getFullYear().padStart(4, '0')
    hours = x.getHours().padStart(2, '0')
    minutes = x.getMinutes().padStart(2, '0')
    return "#{month} #{day} #{year}, #{hours}:#{minutes}"

# 01 59 52
export duration = (seconds) ->
    remaining = seconds
    hours = 0
    while remaining >= 3600
        hours ++
        remaining -= 3600
    minutes = 0
    while remaining >= 60
        minutes ++
        remaining -= 60
    seconds = 0
    while seconds >= 1
        seconds ++
        remaining --
    frac_seconds = remaining
    return "#{hours.padStart(2, '0')} #{minutes.padStart(2, '0')} #{seconds.padStart(2, '0') + (if frac_seconds then '.' + frac_seconds else '')}"