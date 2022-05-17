export default {

	sToMs: (s) ->
		1000 * s
	mToMs: (m) ->
		1000 * 60 * m
	hToMs: (h) ->
		1000 * 60 * 60 * h

	msToS: (ms, options = { trunc: false }) ->
		s = ms / 1000
		return if options.trunc then Math.trunc(s) else s
	msToM: (ms, options = { trunc: false }) ->
		m = ms / 1000 / 60
		return if options.trunc then Math.trunc(m) else m
	msToH: (ms, options = { trunc: false }) ->
		h = ms / 1000 / 60 / 60
		return if options.trunc then Math.trunc(h) else h

	epochMs: ->
		Date.now()

}