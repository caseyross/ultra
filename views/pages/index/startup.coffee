import '../../../functions/Array.coffee'
import '../../../functions/Date.coffee'
import '../../../functions/String.coffee'
import '../../../functions/window.coffee'
import stateFromURL from '../../../functions/url/stateFromURL.coffee'
import defaultState from './defaultState.coffee'

if foundCredentialsVoucher
	invalidateCredentials()
	
window.state = {
	...defaultState,
	...stateFromUrl()
}
(new Channel(window.state.channelId)).getItems(10) # Prefetch for critical path performance