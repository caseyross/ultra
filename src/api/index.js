import configure from './core/configure.coffee'
import errors from './core/errors.coffee'
import ID from './core/ID.coffee'
import { getLoginStatus, getLoginURL, finishPendingLogin, logout } from './net/account.coffee'
import { getRatelimitStatus } from './net/ratelimit.coffee'
import { load, loadWatch, preload, submit, watch } from './store/store.coffee'

export default {

	configure,
	errors,
	ID,
	
	getLoginStatus,
	getLoginURL,
	finishPendingLogin,
	logout,
	
	getRatelimitStatus,

	load,
	loadWatch,
	preload,
	submit,
	watch,

}