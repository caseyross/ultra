import actions from './actions/store.coffee'
import datasets from './datasets/store.coffee'
import { logout, processLoginResult, requestLogin } from './infra/account.coffee'
import errors from './infra/errors.coffee'

export default {

	configure: ({ client_id, redirect_uri }) => {
		localStorage['api.config.client_id'] = client_id
		localStorage['api.config.redirect_uri'] = redirect_uri
	},

	actions,
	datasets,
	
	requestLogin,
	processLoginResult,
	logout,
	
	errors,

}