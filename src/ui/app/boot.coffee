import './stylesheet.styl'
import AppRouter from './AppRouter.pug'
import AppCrash from './AppCrash.pug'

try
	new AppRouter
		target: document.body
catch error
	new AppCrash
		target: document.body
		props:
			error: error