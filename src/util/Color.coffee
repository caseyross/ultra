class HLSA
	constructor: (H, L, S, A = 100) ->
		@H = H # 0--360
		@L = L # 0--100
		@S = S # 0--100
		@A = A # 0--100
	toString: -> "hsla(#{@H}deg, #{@S}%, #{@L}%, #{@A / 100})"

interpolateHLSA = ([zeroC, oneC], frac) ->
	new HLSA(
		...(
			['H', 'L', 'S', 'A'].map((component) ->
				zeroC[component] + Math.round((oneC[component] - zeroC[component]) * frac)
			)
		)
	)

# 
red = new HLSA(8, 59, 100)
grey = new HLSA(0, 87, 0)
blue = new HLSA(216, 71, 100)
export RedBlueColorScale =
	get: (frac) ->
		if frac > 0
			interpolateHLSA([grey, red], frac).toString()
		else
			interpolateHLSA([grey, blue], frac).toString()