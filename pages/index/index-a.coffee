import '../../scripts/Array.coffee'
import '../../scripts/Date.coffee'
import '../../scripts/String.coffee'
import '../../scripts/window.coffee'
import processLoginOrLogout from '../../scripts/api/primitives/authentication.coffee'
import initialState from './state/initialState.coffee'
import stateFromURL from './state/stateFromURL.coffee'

processLoginOrLogout()

window.state = {
	...initialState,
	...stateFromUrl()
}

(new Channel(window.state.channelId)).getItems(10) # Prefetch for critical path performance