import './stylesheet.styl'
import BaseApplication from './base/BaseApplication.pug'
import BaseCrash from './base/BaseCrash.pug'

try
	new BaseApplication
		target: document.body
catch error
	new BaseCrash
		target: document.body
		props:
			error: error