window.LS = window.localStorage

Array::fold = (a, b) -> @reduce(b, a)
Array::last = -> @[@.length - 1]

Date::ago = ->
	s = (Date.now() - @valueOf()) / 1000
	if s < 60
		return
			count: Math.trunc(s)
			unit: 's'
	m = s / 60
	if m < 60
		return
			count: Math.trunc(m)
			unit: 'm'
	h = m / 60
	if h < 24
		return
			count: Math.trunc(h)
			unit: 'h'
	d = h / 24
	if d < 7
		return
			count: Math.trunc(d)
			unit: 'd'
	wk = d / 7
	if wk < 4
		return
			count: Math.trunc(wk)
			unit: 'wk'
	mo = d / 28
	if mo < 12
		return
			count: Math.trunc(mo)
			unit: 'mo'
	yr = mo / 12
	return
		count: Math.trunc(yr)
		unit: 'yr'

String::cColor = ->
	if not (@startsWith('#') and @length is 7)
		return '#808080'
	red = Number.parseInt(@[1..2], 16) / 255
	green = Number.parseInt(@[3..4], 16) / 255
	blue = Number.parseInt(@[5..6], 16) / 255
	if (green + red / 8 + blue / 8) > 0.9
		return '#000000'
	else
		return '#ffffff'
String::normLength = ->
	x = encodeURI(@replace(/<[^>]+>/g, ''))
	x.length - 2 * x.split('%').length
