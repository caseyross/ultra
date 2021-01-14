import '/src/utilities/Object'
import Api from '/src/utilities/Api'
import Color from '/src/utilities/Color'
import KeyMap from '/src/utilities/KeyMap'
import Statistics from '/src/utilities/Statistics'
import Time from '/src/utilities/Time'
window.Api = Api
window.Color = Color
window.KeyMap = KeyMap
window.Memory = window.localStorage
window.Statistics = Statistics
window.Time = Time

import MAIN from '/src/components/MAIN'
new MAIN({
	target: document.getElementById('svelte-root')
})