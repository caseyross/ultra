export default class HLSA
	constructor: (H, L, S, A = 100) ->
		@H = H # 0--360
		@L = L # 0--100
		@S = S # 0--100
		@A = A # 0--100
	toString: -> "hsla(#{@H}deg, #{@S}%, #{@L}%, #{@A / 100})"

export interpolateHLSA = ([zeroC, oneC], frac) ->
	new HLSA(
		...(
			['H', 'L', 'S', 'A'].map((component) ->
				zeroC[component] + Math.round((oneC[component] - zeroC[component]) * frac)
			)
		)
	)