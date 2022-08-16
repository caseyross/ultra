import './stylesheet.styl'
import Application from './infra/Application.pug'
import Crash from './infra/Crash.pug'

try
	new Application
		target: document.body
catch error
	new Crash
		target: document.body
		props:
			error: error