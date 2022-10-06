import Time from './Time.coffee'

Format = {

	number: {

		percent: (numerator, denominator) -> Math.trunc(100 * numerator / denominator)

		plusMinus: (number) ->
			if number > 0 then '+' + number
			else number

	}

	time: {

		absolute: (unixMs) ->
			new Intl.DateTimeFormat('default', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric', hour: 'numeric', minute: 'numeric' }).format(new Date(unixMs))

		humanRelative: (unixMs) ->
			duration = Time.msToDuration(Time.unixMs() - unixMs, { trunc: true })
			switch duration.unit.name
				when 'year', 'month', 'week'
					return "#{duration.count} #{duration.unit.name}#{if duration.count is 1 then '' else 's'} ago"
				else
					daysBack = switch duration.unit.name
						when 'day'
							# We want to account for day boundaries when counting relative days - i.e. treat days as midnight--midnight rather than just a particular number of milliseconds.
							# The key thing to note is that because the naive duration is "floored" to an integer, there is a discontinuity at precisely the hours, minutes, and seconds value at which the naive duration was calculated.
							# The effect of this is that past times later in the day than the calculation time are counted as 1 less day than we would expect, based on day boundaries.
							#
							#  MIDNIGHT  * -------------------------------------------------------------- 
							#           / 
							#          /    [ PAST HH:MM:SS EARLIER THAN CURRENT (CORRECT NAIVE DAY COUNT) ] 
							#         /
							#        / < HH:MM:SS FOR NAIVE CALCULATION
							#       /
							#      /    [ PAST HH:MM:SS LATER THAN CURRENT (NAIVE DAY COUNT OFF BY -1) ]
							#     /
							#    * NEXT DAY -------------------------------------------------------------
							#
							HHMMSS = (date) ->
								[date.getHours(), date.getMinutes(), date.getSeconds()].map((s) -> String(s).padStart(2, '0')).join(':')
							calcDate = new Date() # technically not the actual calculation date, but close enough
							targetDate = new Date(unixMs)
							if HHMMSS(calcDate) > HHMMSS(targetDate) # simple string comparison
								duration.count
							else
								duration.count + 1
						when 'hour'
							# Same logic as for days, but we can simplify the calculations.
							if Time.localHour() > duration.count
								0
							else
								1
						else
							0
					switch daysBack
						when 0
							return "Today, #{new Intl.DateTimeFormat('en-US', { hour: 'numeric', minute: 'numeric' }).format(new Date(unixMs))}"
						when 1
							return 'Yesterday'
						else
							return "#{daysBack} days ago"

		mediaDuration: (input) ->
			seconds = Time.msToS(input, { trunc: true })
			minutes = 0
			while seconds >= 60
				seconds = seconds - 60
				minutes = minutes + 1
			return "#{String(minutes).padStart(2, '0')}:#{String(seconds).padStart(2, '0')}"

		relative: (unixMs) ->
			duration = Time.msToDuration(Time.unixMs() - unixMs, { trunc: true })
			if duration.unit.name is 'millisecond' then return 'now'
			return "#{duration.count}#{duration.unit.short_name}"

	}

}

Format.time.sAbsolute = (epochS) -> Format.time.absolute Time.sToMs epochS
Format.time.sHumanRelative = (epochS) -> Format.time.humanRelative Time.sToMs epochS
Format.time.sMediaDuration = (epochS) -> Format.time.mediaDuration Time.sToMs epochS
Format.time.sRelative = (epochS) -> Format.time.relative Time.sToMs epochS

export default Format