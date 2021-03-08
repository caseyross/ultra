const PROD_CONFIG = require('./webpack.config.prod.js')

module.exports = {
	...PROD_CONFIG,
	mode: 'development',
	devServer: {
		contentBase: './public',
		historyApiFallback: true, // serve index.html for all routes without designated pages (i.e. all of them)
		https: true,
		overlay: true, // error overlay
	},
}