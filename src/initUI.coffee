import './ui/stylesheets/global.styl'
import UIRoot from './ui/components/UIRoot.pug'

try
	new UIRoot
		target: document.body
		props:
			id: 't5z:combatfootage:hot:10'
			listingId: 't5z:combatfootage:new'
catch error
	alert(error)