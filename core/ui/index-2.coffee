import '../../styles/variables.styl'
import '../../styles/base.styl'
import '../../styles/markdown.styl'
import '../../styles/utility.styl'
import Index from './Index.pug'

try
	new Index
		target: document.body
		props:
			sessionState: window.sessionState
catch error
	alert(error)