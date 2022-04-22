import api from './api/index.js'

api.configure({
	client_id: process.env.API_CLIENT_ID
	redirect_uri: process.env.API_REDIRECT_URI
})