import './ui/stylesheets/global.styl'
import api from './api/index.js'
import UIRoot from './ui/components/UIRoot.pug'

try
	new UIRoot
		target: document.body
		props:
			id: new api.DatasetID('subreddit_posts:combatfootage:hot:10')
catch error
	alert(error)