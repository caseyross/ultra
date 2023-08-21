import '../stylesheet.styl'
import App from '../App.pug'
import Crash from '../Crash.pug'

try
	new App
		target: document.body
catch error
	new Crash
		target: document.body
		props:
			error: error