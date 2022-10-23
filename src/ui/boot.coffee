import './stylesheet.styl'
import Application from './Application.pug'
import Crash from './error/Crash.pug'

try
	new Application
		target: document.body
catch error
	new Crash
		target: document.body
		props:
			error: error