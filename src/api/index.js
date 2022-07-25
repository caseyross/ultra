import configure from './configure.coffee'
import { getLoginStatus, getLoginURL, handlePendingLogin, logout } from './account.coffee'
import { load, preload, reload, send, watch } from './operations.coffee'
import errors from './infra/errors.coffee'
import format from './infra/format.coffee'
import parse from './infra/parse.coffee'
import { getRatelimitStatus } from './infra/ratelimit.coffee'

export default {

	configure,
	errors,
	format,
	getLoginStatus,
	getLoginURL,
	getRatelimitStatus,
	handlePendingLogin,
	load,
	logout,
	parse,
	preload,
	reload,
	send,
	watch,

}