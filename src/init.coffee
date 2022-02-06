# Import our base global variables.
import './globals/index.coffee'
import './globals/browser.coffee'

# Before anything else, check for a change in the user's login/logout status, and handle it if so.
import { handleLoginOrLogout } from './api/account.coffee'
handleLoginOrLogout()

# Set up the command -> state infrastructure.
import CommandQueue from './commands/CommandQueue'
import CommandProcessor from './commands/CommandProcessor'
import commandMap from './commands/index.coffee'
import state from './stores.coffee'
commandQueue = new CommandQueue()
commandProcessor = new CommandProcessor(commandMap, state)
commandQueue.addEventListener 'command', (event) -> commandProcessor.process(event.data)
commandProcessor.addEventListener('statechange', (event) -> state = state) # let Svelte know when the state changes

# Set up logging infrastructure.
import Logger from './logging/Logger.coffee'
import logMap from './logging/logMap.coffee'
window.logger = new Logger(logMap)
commandProcessor.addEventListener('commandprocess', (event) -> logger.info('Command Successfully Processed', event.data))
commandProcessor.addEventListener('commanderror', (event) -> logger.error('Error While Processing Command', event.data))

# Load the page.
actions.LOAD_URL_DATA({ url: window.location })