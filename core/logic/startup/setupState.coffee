import '../../scripts/Array.coffee'
import '../../scripts/Date.coffee'
import '../../scripts/String.coffee'
import '../../scripts/window.coffee'
import { processLoginOrLogout } from '../../logic/net/authentication.coffee'
import initialState from './state/initialState.coffee'
import stateFromURL from './state/stateFromURL.coffee'

# Setup machineState.
# We never assume the presence of any given key in machineState, so we also don't initialize it with any values.
window.machineState = window.localStorage
processLoginOrLogout()

# Setup sessionState.
sessionState = new SessionState()
sessionState.initialize(initialState)
sessionState.initialize(urlState)

# Save sessionState to window for handoff to Svelte rendering code.
window.sessionState = sessionState