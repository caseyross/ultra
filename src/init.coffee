import './common.styl'
import './lib.coffee'
import { get, post } from './API.coffee'
window.API =
	get: get
	post: post
import { CacheKey, CacheKeySave } from './Cache.coffee'
window.CacheKey = CacheKey
window.CacheKeySave = CacheKeySave

import Router from './Router.pug'
new Router
	target: document.body