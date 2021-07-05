import './common.styl'
import './prototype_extensions.coffee'
import { get, post } from './API.coffee'
window.API =
	get: get
	post: post
import { CacheKey, CacheKeySave } from './Cache.coffee'
window.CacheKey = CacheKey
window.CacheKeySave = CacheKeySave

import State from './State.coffee'
state = new State()
state.update()

import App from './App.pug'
new App
	target: document.body
	props:
		state: state