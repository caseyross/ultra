import '../stylesheet.styl'

import AppRouter from '../routing/AppRouter.pug'
import AppCrash from '../routing/AppCrash.pug'

try
	new AppRouter
		target: document.body
catch error
	new AppCrash
		target: document.body
		props:
			error: error