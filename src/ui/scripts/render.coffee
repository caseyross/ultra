import '../lib/index.coffee'

import Index from './Index.pug'

try
	new Index
		target: document.body
catch error
	alert(error)