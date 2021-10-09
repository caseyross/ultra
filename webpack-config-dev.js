const path = require('path')
const webpackConfig = require('./webpack-config.js')

module.exports = {
	...webpackConfig,
	mode: 'development',
	devServer: {
		client: {
			overlay: {
				errors: true,
				warnings: false,
			},
		},
		headers: {
			'Link': '<https://oauth.reddit.com>; rel="preconnect", <https://i.redd.it>; rel="preconnect", <https://v.redd.it>; rel="preconnect"'
		},
		historyApiFallback: true, // serve index.html for all routes without designated pages (i.e. all of them)
		https: true,
		static: {
			directory: path.join(__dirname, 'build'),
		},
	},
}