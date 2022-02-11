// filesystem
const path = require('path')
// compilers
const pugToSvelte = require('pug-to-svelte')
const coffeescript = require('coffeescript')
const stylus = require('stylus')
// plugins
const CopyWebpackPlugin = require('copy-webpack-plugin')
const HtmlWebpackPlugin = require('html-webpack-plugin')
const InlineChunkHtmlPlugin = require('react-dev-utils/InlineChunkHtmlPlugin')

module.exports = {
	mode: 'production',
	entry: {
		init: {
			import: './src/ui/init.coffee', // bootstrap API requests prior to mounting UI components
		},
		render: {
			import: './src/ui/render.coffee', // construct and render the UI
			dependOn: 'init',
		}
	},
	optimization: {
		runtimeChunk: 'single', // with multiple entries on one page, must have only one runtime chunk to avoid duplicate module instantiations
	},
	output: {
		filename: '[name].[contenthash].js',
		path: path.join(__dirname, 'build'),
		publicPath: '/', // location of output files relative to the web server root
		clean: true // cleanup output directory before emitting assets
	},
	plugins: [
		new HtmlWebpackPlugin({
			template: './src/ui/index.html',
			inject: false, // manual script placement in template
		}),
		new InlineChunkHtmlPlugin(HtmlWebpackPlugin, [/runtime/, /init/]), // inline to avoid network roundtrip
		new CopyWebpackPlugin({
			patterns: [
				{
					from: './src/ui/assets', // copy directly to output directory
					transform: (content, path) => stylus.render(content)
				},
			],
		}),
	],
	resolve: {
		extensions: ['.pug', '.coffee', '.js'],
		// values below recommended by svelte-loader for optimum compatibility
		alias: {
			svelte: path.join(__dirname, 'node_modules', 'svelte')
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
									},
									script: ({ content }) => {
										return {
											code: coffeescript.compile(content, { bare: true })
										}
									},
									style: ({ content }) => {
										return {
											code: stylus.render(content)
										}
									},
								},
							]
						},
					},
				],
			},
			{
				test: /\.coffee$/,
				use: [
					{
						loader: 'coffee-loader',
						options: {
							bare: true // No isolation IIFE
						}
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