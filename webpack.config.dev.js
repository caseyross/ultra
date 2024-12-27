const path = require('path')
const webpackConfig = require('./webpack.config.js')

const PORT = 1337

module.exports = {
	...webpackConfig,
	devServer: {
		client: {
			overlay: {
				errors: true,
				warnings: false,
			},
			progress: false,
			reconnect: false,
		},
		liveReload: false,
		historyApiFallback: true, // serve index.html for all routes without designated pages (i.e. all of them)
		hot: false,
		open: {
			target: ['https://[::1]:' + PORT],
		},
		server: {
			type: 'https',
		},
		static: {
			directory: path.join(__dirname, 'dist'),
		},
		port: PORT,
	},
	mode: 'development',
}