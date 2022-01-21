import '../../scripts/Array.coffee'
import '../../scripts/Date.coffee'
import '../../scripts/Location.coffee'
import '../../scripts/String.coffee'
import '../../scripts/window.coffee'

# Setup browser.
window.browser = window.localStorage

import { processLoginOrLogout } from './api/API.coffee'
processLoginOrLogout()

import CommandQueue from './commands/CommandQueue'
import CommandProcessor from './commands/CommandProcessor'
import commandMap from './commands/commandMap.coffee'
import state from './stores.coffee'
commandQueue = new CommandQueue()
commandProcessor = new CommandProcessor(commandMap, state)
commandQueue.addEventListener('command', (event) ->
	commandProcessor.process(event.data)
)
commandProcessor.addEventListener('commandprocess', (event) ->
	state = state # Tell Svelte to re-render everything that depends on "state".
)

import Logger from '../logging/Logger.coffee'
import logMap from '../logging/logMap.coffee'
logger = new Logger(logMap)
commandProcessor.addEventListener('commandprocess', (event) ->
	logger.log({
		name: 'Command Successfully Processed'
		data: event.data
	})
)
commandProcessor.addEventListener('commandprocessfail', (event) ->
	logger.log({
		name: 'Error While Processing Command'
		data: event.data
	})
)

commandQueue.push({
	type: 'system'
	name: 'Load URL Internally'
	url: window.location
})