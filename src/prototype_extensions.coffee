Array::fold = (a, b) -> @reduce(b, a)
Array::last = -> @[@.length - 1]

Date::asNaturalLanguageAgo = ->
	s = (Date.now() - @valueOf()) / 1000
	if s < 7
		return 'a few seconds ago'
	if s < 10
		return 'several seconds ago'
	if s < 60
		return 'less than a minute ago'
	m = s / 60
	if m < 2
		return 'a minute ago'
	if m < 3
		return 'a couple minutes ago'
	if m < 7
		return 'a few minutes ago'
	if m < 10
		return 'several minutes ago'
	if m < 60
		return m + ' minutes ago'
	h = m / 60
	if h < 1.3
		return 'an hour ago'
	if h < 1.7
		return 'one and a half hours ago'
	if h < 3
		return 'a couple hours ago'
	if h < 7
		return 'a few hours ago'
	if h < 10
		return 'several hours ago'
	# Take midnight into account when counting days.
	d = h / 24
	b = ((new Date()).getDay() - @getDay() + 7) % 7
	if d < 7
		if b < 1
			return 'earlier today'
		if b < 2
			return 'yesterday'
		if b < 3
			return 'two days ago'
		if b < 4
			return 'three days ago'
		if b < 6
			return 'a few days ago'
		return 'almost a week ago'
	if d < 14
		if b < 1
			return 'a week ago'
		if b < 3
			return 'a little over a week ago'
		if b < 5
			return 'a week and a half ago'
		if b < 7
			return 'almost two weeks ago'
		return 'two weeks ago'
	if d < 21
		if b < 1
			return 'two weeks ago'
		if b < 3
			return 'a little over two weeks ago'
		if b < 5
			return 'two and a half weeks ago'
		if b < 7
			return 'almost three weeks ago'
		return 'three weeks ago'
	if d < 28
		if b < 1
			return 'three weeks ago'
		if b < 3
			return 'a little over three weeks ago'
		if b < 5
			return 'three and a half weeks ago'
		if b < 7
			return 'almost four weeks ago'
		return 'four weeks ago'
	m = d / 30
	if m < 1.2
		return 'a month ago'
	if m < 1.7
		return 'a month and a half ago'
	if m < 2
		return 'almost two months ago'
	if m < 2.2
		return 'two months ago'
	if m < 2.7
		return 'two and a half months ago'
	if m < 3
		return 'almost three months ago'
	if m < 3.2
		return 'three months ago'
	if m < 3.7
		return 'three and a half months ago'
	if m < 4
		return 'almost four months ago'
	if m < 7
		return 'a few months ago'
	if m < 10
		return 'several months ago'
	if m < 12
		return 'almost a year ago'
	if m < 13
		return 'a year ago'
	if m < 14
		return 'a little over a year ago'
	if m < 15
		return 'fourteen months ago'
	if m < 16
		return 'fifteen months ago'
	if m < 17
		return 'sixteen months ago'
	if m < 18
		return 'seventeen months ago'
	if m < 19
		return 'a year and a half ago'
	if m < 20
		return 'a little over a year and a half ago'
	if m < 22
		return 'one and three-quarters years ago'
	if m < 24
		return 'almost two years ago'
	y = m / 12
	if y < 3
		return 'a couple years ago'
	if y < 7
		return 'a few years ago'
	if y < 10
		return 'several years ago'
	if y < 11
		return 'a decade ago'
	if y < 20
		return 'more than a decade ago'
	if y < 21
		return 'two decades ago'
	return 'more than two decades ago'

String::contrast_color = ->
	if not (@startsWith('#') and @length is 7) then 'inherit'
	red = Number.parseInt(@[1..2], 16) / 255
	green = Number.parseInt(@[3..4], 16) / 255
	blue = Number.parseInt(@[5..6], 16) / 255
	if (green + red / 8 + blue / 8) > 0.9 then 'black' else 'white'
String::normalized_length = ->
	x = encodeURI(@replace(/<[^>]+>/g, ''))
	x.length - 2 * x.split('%').length
String::pluralize = (count) -> @ + (if count is 1 then '' else 's')
