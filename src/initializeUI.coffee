import './ui/assets/global.styl'
import Listing from './ui/components/listing/Listing.pug'

try
	new Listing
		target: document.body
		props:
			id: 't5z:combatfootage:hot:5'
catch error
	alert(error)