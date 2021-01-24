import '/src/functions/Object'
import '/src/functions/String'
import Api from '/src/functions/Api'
import Color from '/src/functions/Color'
import KeyMap from '/src/functions/KeyMap'
import Statistics from '/src/functions/Statistics'
import Time from '/src/functions/Time'
window.Api = Api
window.Color = Color
window.KeyMap = KeyMap
window.Memory = window.localStorage
window.Statistics = Statistics
window.Time = Time

import V_Root from '/src/views/V_Root'
new V_Root({
	target: document.getElementById('svelte-root')
})