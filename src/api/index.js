import { getLoginStatus, getLoginURL, finishPendingLogin, logout } from './network/account.coffee'
import { getRatelimitStatus } from './network/ratelimit.coffee'
import ID from './payload/ID.coffee'
import { load, preload, reload, send, watch } from './storage/store.coffee'
import configure from './configure.coffee'
import errors from './errors.coffee'

export default {

	configure,
	
	errors,
	ID,

	load,
	preload,
	reload,
	send,
	watch,

	getRatelimitStatus,
	
	getLoginStatus,
	getLoginURL,
	finishPendingLogin,
	logout,

}