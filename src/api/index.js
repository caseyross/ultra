import { configure, getClientID, hasClientID } from './base/configure.coffee'
import errors from './base/errors.coffee'
import ID from './base/ID.coffee'
import { finishPendingLogin, getLoginStatus, getLoginURL, getUser, hasPendingLogin, isLoggedIn, logout, setUser } from './net/account.coffee'
import { getRatelimitStatus } from './net/ratelimit.coffee'
import { load, loadWatch, preload, reload, submit, watch } from './ops/ops.coffee'

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