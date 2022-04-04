import './ui/assets/global.styl'
import Listing from './ui/components/listing/Listing.pug'

try
	new Listing
		target: document.body
		props:
			id: 't5z:hololive:hot:10'
catch error
	alert(error)