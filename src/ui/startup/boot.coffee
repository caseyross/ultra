import '../component/global/stylesheet.styl'
import Crash from '../routing/Crash.pug'
import Router from '../routing/Router.pug'

try
	new Router
		target: document.body
catch error
	new Crash
		target: document.body
		props:
			error: error