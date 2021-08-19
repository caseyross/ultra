const path = require('path')
const pugToSvelte = require('pug-to-svelte')
const autoToSvelte = require('svelte-preprocess')
const HtmlWebpackPlugin = require('html-webpack-plugin')
const { CleanWebpackPlugin } = require('clean-webpack-plugin')
const CopyPlugin = require('copy-webpack-plugin')

module.exports = {
	mode: 'production',
	entry: './src/init.coffee',
	output: {
		filename: 'index.js',
		path: path.resolve(__dirname, 'public'),
		publicPath: '/', // location of output files relative to the web server root
	},
	resolve: {
		extensions: ['.pug', '.coffee', '.js'],
		// values below recommended by svelte-loader for optimum compatibility
		alias: {
			svelte: path.resolve('node_modules', 'svelte')
		},
		mainFields: ['svelte', 'browser', 'module', 'main']
		// end
	},
	module: {
		rules: [
			{
				test: /\.pug$/,
				use: [
					{
						loader: 'svelte-loader',
						options: {
							preprocess: [
								{
									markup: ({ content }) => {
										return {
											code: pugToSvelte(content)
										}
									} 
								},
								autoToSvelte({
									defaults: {
										script: 'coffeescript',
										style: 'stylus',
									}
								})
							]
						},
					},
				],
			},
			{
				test: /\.coffee$/,
				use: [
					{
						loader: 'coffee-loader'
					},
				],
			},
			{
				test: /\.styl$/,
				use: [
					{
						loader: 'style-loader'
					},
					{
						loader: 'css-loader'
					},
					{
						loader: 'stylus-loader'
					},
				],
			},
		],
	},
	plugins: [
		new CleanWebpackPlugin(),
		new HtmlWebpackPlugin({
			template: './src/index.html',
		}),
		new CopyPlugin({
			patterns: [
				{ from: './static' }, // copy to output directory
			],
		}),
	],
}