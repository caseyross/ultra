import './global.styl'
import LayoutRouter from './layout/LayoutRouter.pug'
import LayoutCrash from './layout/LayoutCrash.pug'

try
	new LayoutRouter
		target: document.body
catch error
	new LayoutCrash
		target: document.body
		props:
			error: error