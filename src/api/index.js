import configure from './configure.coffee'
import { load, preload, reload, send, watch } from './operations.coffee'
import { logout, processLoginResult, requestLogin } from './infra/account.coffee'
import errors from './infra/errors.coffee'

export default {

	configure,
	errors,
	load,
	logout,
	requestLogin,
	preload,
	processLoginResult,
	reload,
	send,
	watch,

}