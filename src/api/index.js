import configure from './configure.coffee'
import { load, preload, reload, send, watch } from './operations.coffee'
import { logout, processLoginResult, requestLogin } from './infra/account.coffee'
import errors from './infra/errors.coffee'
import { DatasetID } from './infra/ids.coffee'

export default {

	configure,
	DatasetID,
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