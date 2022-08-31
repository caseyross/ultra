import './stylesheet.styl'
import Application from './routing/Application.pug'
import Crash from './errors/Crash.pug'

try
	new Application
		target: document.body
catch error
	new Crash
		target: document.body
		props:
			error: error