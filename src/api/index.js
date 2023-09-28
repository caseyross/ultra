import { configure, getClientID, hasClientID } from './core/configure.coffee'
import errors from './core/errors.coffee'
import ID from './core/ID.coffee'
import { finishPendingLogin, getLoginStatus, getLoginURL, getUser, hasPendingLogin, isLoggedIn, logout, setUser } from './net/account.coffee'
import { getRatelimitStatus } from './net/ratelimit.coffee'
import { load, loadWatch, preload, reload, submit, watch } from './store/store.coffee'

export default {
	
	errors,
	ID,

	configure,
	getClientID,
	hasClientID,
	
	finishPendingLogin,
	getLoginStatus,
	getLoginURL,
	getUser,
	hasPendingLogin,
	isLoggedIn,
	logout,
	setUser,
	
	getRatelimitStatus,

	load,
	loadWatch,
	preload,
	reload,
	submit,
	watch,

}