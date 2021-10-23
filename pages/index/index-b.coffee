import '../../styles/reset.styl'
import '../../styles/vars.styl'
import '../../styles/base.styl'
import '../../styles/md.styl'
import '../../styles/util.styl'
import Index from './Index.pug'

new Index
	target: document.body
	props:
		state: window.state