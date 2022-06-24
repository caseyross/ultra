import './ui/stylesheets/global.styl'
import Router from './ui/Router.pug'

try
	new Router
		target: document.body
catch error
	alert(error)