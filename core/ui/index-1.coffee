import '../../scripts/Array.coffee'
import '../../scripts/Date.coffee'
import '../../scripts/Location.coffee'
import '../../scripts/String.coffee'
import '../../scripts/window.coffee'
import { processLoginOrLogout } from './API.coffee'

# Setup browser.
window.browser = window.localStorage
processLoginOrLogout()

