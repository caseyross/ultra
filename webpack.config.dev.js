const PROD_CONFIG = require('./webpack.config.prod.js')

module.exports = {
	...PROD_CONFIG,
	mode: 'development',
	devServer: { // automatically serves static files from /public by default
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
	},
}