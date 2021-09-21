import './base.styl'
import './md.styl'
import './util.styl'
import Website from './Website.pug'

new Website
	target: document.body
	props:
		urlState: window.urlState