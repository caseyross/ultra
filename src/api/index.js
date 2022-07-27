import configure from './configure.coffee'
import ID from './payload/ID.coffee'
import { load, preload, reload, send, watch } from './storage/store.coffee'
import { getLoginStatus, getLoginURL, finishPendingLogin, logout } from './network/account.coffee'
import { getRatelimitStatus } from './network/ratelimit.coffee'
import errors from './network/errors.coffee'

export default {

	configure,
	
	ID,

	load,
	preload,
	reload,
	send,
	watch,
	
	getLoginStatus,
	getLoginURL,
	finishPendingLogin,
	logout,

	getRatelimitStatus,
	
	errors,

}