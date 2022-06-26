import './ui/product/stylesheet.styl'
import Router from './ui/infra/Router.pug'

try
	new Router
		target: document.body
catch error
	alert(error)