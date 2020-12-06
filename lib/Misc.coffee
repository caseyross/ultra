export rating = (comment) ->
	if comment.score_hidden
		return '?'
	if comment.score > 100 and comment.estimatedInterest > 40
		return 'S+'
	if comment.score > 100 and comment.estimatedInterest > 30
		return 'S'
	if comment.score > 50 and comment.estimatedInterest > 20
		return 'A'
	if comment.score > 25 and comment.estimatedInterest > 10
		return 'B'
	if comment.score > 10
		return 'C'
	if comment.score > -10
		return 'D'
	if comment.score > -100
		return 'E'
	return 'F'

export ratingColor = (rating) -> switch rating
	when 'S+' then 'rgba(0,0,0,0.5)'
	when 'S' then 'rgba(0,0,0,0.5)'
	when 'A' then 'rgba(0,0,0,0.5)'
	when 'B' then 'rgba(0,0,0,0.5)'
	when 'C' then 'rgba(0,0,0,0.5)'
	when 'E' then 'rgba(0,0,0,0.5)'
	else 'rgba(0,0,0,0.5)'
	
normalizedLength = (htmlString) ->
	x = encodeURI(htmlString.replace(/<[^>]+>/g, ''))
	return x.length - 2 * x.split('%').length

normalizedScore = (score, creationTime, subredditSubscribers) ->
	x = score / subredditSubscribers / (Date.now() / 1000 - creationTime)
	return 3600 * 1000000 * x