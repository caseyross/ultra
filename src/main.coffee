import './common.styl'
import Website from './Website.pug'

new Website
	target: document.body
	props:
		urlState: window.urlState