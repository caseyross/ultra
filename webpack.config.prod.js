const path = require('path')
const pugToSvelte = require('pug-to-svelte')
const autoToSvelte = require('svelte-preprocess')
const CopyWebpackPlugin = require('copy-webpack-plugin')
const HtmlWebpackPlugin = require('html-webpack-plugin')
const InlineChunkHtmlPlugin = require('react-dev-utils/InlineChunkHtmlPlugin')

module.exports = {
	mode: 'production',
	entry: {
		priority: {
			import: './src/priority.coffee', // scripts that should run ASAP to start API requests
		},
		main: {
			import: './src/main.coffee', // all other scripts
			dependOn: 'priority',
		}
	},
	optimization: {
		runtimeChunk: 'single', // with multiple entries on one page, must have only one runtime chunk to avoid duplicate module instantiations
	},
	output: {
		filename: '[name].[contenthash].js',
		path: path.resolve(__dirname, 'public'),
		publicPath: '/', // location of output files relative to the web server root
		clean: true // cleanup output directory before emitting assets
	},
	plugins: [
		new HtmlWebpackPlugin({
			template: './src/index.html',
			inject: false, // manual script placement in template
		}),
		new InlineChunkHtmlPlugin(HtmlWebpackPlugin, [/runtime/, /priority/]), // inline priority chunks for speed
		new CopyWebpackPlugin({
			patterns: [
				{ from: './static' }, // copy directly to output directory
			],
		}),
	],
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
}