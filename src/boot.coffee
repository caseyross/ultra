import './ui/product/stylesheet.styl'
import Crash from './ui/infra/Crash.pug'
import Router from './ui/infra/Router.pug'

try
	new Router
		target: document.body
catch error
	new Crash
		target: document.body
		props:
			error: error