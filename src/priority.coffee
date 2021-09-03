import './util/Array.coffee'
import './util/Date.coffee'
import './util/String.coffee'
import './util/window.coffee'

import URLState from './url/URLState.coffee'
window.urlState = new URLState()
if window.urlState.channel
	window.urlState.channel.getItems(10) # Prefetch for critical path performance