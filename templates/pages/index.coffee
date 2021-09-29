import './libraries/environment/Array.coffee'
import './libraries/environment/Date.coffee'
import './libraries/environment/String.coffee'
import './libraries/environment/window.coffee'
import URLState from './models/URLState.coffee'

window.state = stateFromUrl()
(new Channel(window.state.channelId)).getItems(10) # Prefetch for critical path performance