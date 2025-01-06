import App from '../views/App'
import Crash from '../views/Crash'

try
	new App
		target: document.body
catch error
	new Crash
		target: document.body
		props:
			error: error