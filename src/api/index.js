import configure from './core/configure.coffee'
import errors from './core/errors.coffee'
import ID from './core/ID.coffee'
import { finishPendingLogin, getLoginStatus, getLoginURL, getUser, hasPendingLogin, isLoggedIn, logout, setUser } from './net/account.coffee'
import { getRatelimitStatus } from './net/ratelimit.coffee'
import { load, loadWatch, preload, read, submit, watch } from './store/store.coffee'

export default {

	configure,
	errors,
	ID,
	
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
	read,
	submit,
	watch,

}