import './common.styl'
import './lib.coffee'
import { cached } from './Cache.coffee'
window.cached = cached
import { get, post } from './API.coffee'
window.API =
	get: get
	post: post

import Router from './Router.pug'
new Router
	target: document.body