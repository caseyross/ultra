# Before anything else, check for a change in the user's login/logout status, and handle it if so.
import './globals/browser.coffee'
import { handleLogInOrLogOut } from './api/internals/authentication.coffee'
handleLogInOrLogOut()

# Import our base global variables.
import './globals/index.coffee'

# Set up the command -> state infrastructure.
import CommandQueue from './commands/CommandQueue'
import CommandProcessor from './commands/CommandProcessor'
import commandMap from './commands/commandMap.coffee'
import state from './stores.coffee'
commandQueue = new CommandQueue()
commandProcessor = new CommandProcessor(commandMap, state)
commandQueue.addEventListener 'command', (event) -> commandProcessor.process(event.data)
commandProcessor.addEventListener('commandprocess', (event) ->
	if event.stateChange != null then state = state # Tell Svelte to re-render everything that depends on "state".
)
window.command = commandQueue.add # add global for easy syntax

# Set up logging infrastructure.
import Logger from './logging/Logger.coffee'
import logMap from './logging/logMap.coffee'
window.logger = new Logger logMap
commandProcessor.addEventListener('commandprocess', (event) ->
	logger.info('Command Successfully Processed', event.data)
)
commandProcessor.addEventListener('commandprocessfail', (event) ->
	logger.error('Error While Processing Command', event.data)
)

# Load the page.
command {
	type: 'load url data'
	data: window.location
}