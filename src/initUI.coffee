import './ui/stylesheets/global.styl'
import UIRoot from './ui/components/UIRoot.pug'

try
	new UIRoot
		target: document.body
		props:
			id: 'subreddit_posts:combatfootage:hot:10'
	alert(error)