import '../../styles/variables.styl'
import '../../styles/base.styl'
import '../../styles/markdown.styl'
import '../../styles/utility.styl'
import Index from './Index.pug'

try
	new Index
		target: document.body
		props:
			state: window.state
catch error
	alert(error)