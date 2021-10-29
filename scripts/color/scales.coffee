import HLSA, { interpolateHLSA } from './HLSA.coffee'

# 
red = new HLSA(0, 0, 0)
grey = new HLSA(0, 87, 0)
blue = new HLSA(216, 71, 100)
export RedGrayColorScale =
	color: (frac) -> interpolateHLSA([grey, red], frac).toString()
export BlueGrayColorScale =
	color: (frac) -> interpolateHLSA([grey, blue], frac).toString()