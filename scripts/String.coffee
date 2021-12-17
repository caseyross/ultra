String::toCommentId = ->
	if @startsWith('t1_')
		return @
	return 't1_' + @
String::toUserId = ->
	if @startsWith('t2_')
		return @
	return 't2_' + @
String::toPostId = ->
	if @startsWith('t3_')
		return @
	return 't3_' + @
String::toMessageId = ->
	if @startsWith('t4_')
		return @
	return 't4_' + @
String::toSubredditId = ->
	if @startsWith('t5_')
		return @
	return 't5_' + @
String::toAwardId = ->
	if @startsWith('t6_')
		return @
	return 't6_' + @

String::toShortId = ->
	if @[2] == '_'
		return @[3..]
	return @


String::normalizedLength = ->
	x = encodeURI(@replace(/<[^>]+>/g, ''))
	x.length - 2 * x.split('%').length

String::cColor = ->
	if not (@startsWith('#') and @length is 7)
		return '#000000'
	red = Number.parseInt(@[1..2], 16) / 255
	green = Number.parseInt(@[3..4], 16) / 255
	blue = Number.parseInt(@[5..6], 16) / 255
	if (green + red / 8 + blue / 8) > 0.9
		return '#000000'
	else
		return '#ffffff'