import '../../scripts/Array.coffee'
import '../../scripts/Date.coffee'
import '../../scripts/Location.coffee'
import '../../scripts/String.coffee'
import '../../scripts/window.coffee'
import { processLoginOrLogout } from '../../logic/net/authentication.coffee'

# Setup machineState.
window.machineState = window.localStorage 
processLoginOrLogout()

# Setup sessionState.
window.sessionState = window.location.toSessionState() # Save on window to hand off to Svelte rendering code.