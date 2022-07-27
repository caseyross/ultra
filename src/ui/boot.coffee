import './stylesheet.styl'
import Crash from './infra/Crash.pug'
import Router from './infra/Router.pug'

try
	new Router
		target: document.body
catch error
	new Crash
		target: document.body
		props:
			error: error