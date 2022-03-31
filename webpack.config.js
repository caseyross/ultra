// filesystem
const path = require('path')
// compilers
const coffeescript = require('coffeescript')
const pugToSvelte = require('pug-to-svelte')
const stylus = require('stylus')
// plugins
const EnvPlugin = require('dotenv-webpack')
const FaviconsPlugin = require('favicons-webpack-plugin')
const HtmlWebpackPlugin = require('html-webpack-plugin')
const InlineChunkHtmlPlugin = require('react-dev-utils/InlineChunkHtmlPlugin')

module.exports = {
	mode: 'production',
	entry: {
		loadBaseLibraries: {
			import: './src/loadBaseLibraries.coffee',
		},
		initializeState: {
			import: './src/initializeState.coffee',
			dependOn: 'loadBaseLibraries',
		},
		initializeUI: {
			import: './src/initializeUI.coffee',
			dependOn: 'initializeState',
		}
	},
	optimization: {
		runtimeChunk: 'single', // with multiple entries on one page, need single runtime chunk to avoid duplicate module instantiations
	},
	output: {
		filename: '[name].[contenthash].js',
		path: path.join(__dirname, 'dist'),
		publicPath: '/', // location of output files relative to the web server root
		clean: true // cleanup output directory before emitting assets
	},
	plugins: [
		new EnvPlugin(),
		new FaviconsPlugin('./src/ui/assets/favicons/16x16.png'),
		new HtmlWebpackPlugin({
			template: './src/index.html',
			inject: false, // manual script placement in template
		}),
		new InlineChunkHtmlPlugin(HtmlWebpackPlugin, [/runtime/, /loadBaseLibraries/, /initializeState/]), // avoids network roundtrip
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