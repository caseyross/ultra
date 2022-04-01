import './ui/assets/global.styl'
import Listing from './ui/components/listing/Listing.pug'

try
	new Listing
		target: document.body
		props:
			id: 't5z:ukrainianconflict:hot:1'
catch error
	alert(error)