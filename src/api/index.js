import actions from './actions/store.coffee'
import datasets from './datasets/store.coffee'
import { attemptLogin, logout, processLoginResult } from './infra/account.coffee'
import errors from './infra/errors.coffee'

export default {

	actions,
	datasets,

	attemptLogin,
	processLoginResult,
	logout,
	
	errors,

}