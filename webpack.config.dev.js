const path = require('path')
const webpackConfig = require('./webpack.config.js')

module.exports = {
	...webpackConfig,
	devServer: {
		client: {
			overlay: {
				errors: true,
				warnings: false,
			},
			progress: true,
			reconnect: false,
		},
		liveReload: false,
		headers: {
			'Link': '<https://oauth.reddit.com>; rel="preconnect", <https://i.redd.it>; rel="preconnect", <https://v.redd.it>; rel="preconnect"',
			'X-Frame-Options': 'DENY'
		},
		historyApiFallback: true, // serve index.html for all routes without designated pages (i.e. all of them)
		hot: false,
		https: true,
		static: {
			directory: path.join(__dirname, 'dist'),
		},
		port: 8080,
	},
	mode: 'development',
}