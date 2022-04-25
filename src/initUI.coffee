import './ui/stylesheets/global.styl'
import api from './api/index.js'
import UIRoot from './ui/components/UIRoot.pug'

try
	new UIRoot
		target: document.body
		props:
			id: new api.DatasetID('t5z:combatfootage:hot:20')
catch error
	alert(error)