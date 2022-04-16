// filesystem
const path = require('path')
// compilers
const coffeescript = require('coffeescript')
const pugToSvelte = require('pug-to-svelte')
const stylus = require('stylus')
// plugins
const DotEnvFileWebpackPlugin = require('dotenv-webpack')
const HtmlOutputWebpackPlugin = require('html-webpack-plugin')
const HtmlOutputInlineScriptWebpackPlugin = require('html-inline-script-webpack-plugin')

module.exports = {
	entry: {
		loadBaseLibraries: {
			import: './src/loadBaseLibraries.coffee',
		},
		initializeState: {
			dependOn: 'loadBaseLibraries',
			import: './src/initializeState.coffee',
		},
		initializeUI: {
			dependOn: 'initializeState',
			import: './src/initializeUI.coffee',
		}
	},
	mode: 'production',
	optimization: {
		runtimeChunk: 'single', // with multiple entries on one page, need single runtime chunk to avoid duplicate module instantiations
	},
	output: {
		clean: true, // cleanup output directory before emitting assets
		filename: '[name].[contenthash].js',
		path: path.join(__dirname, 'dist'),
		publicPath: '/', // location of output files relative to the web server root
	},
	plugins: [
		new DotEnvFileWebpackPlugin(),
		new HtmlOutputWebpackPlugin({
			favicon: './src/ui/assets/favicons/favicon_16.png',
			inject: false, // manual script placement in template
			template: './src/index.html',
		}),
		new HtmlOutputInlineScriptWebpackPlugin({
			scriptMatchPattern: [/^runtime/, /^loadBaseLibraries/, /^initializeState/] // avoid add'l network roundtrip on critical path
		}),
	],
	resolve: {
		extensions: ['.pug', '.coffee', '.js'],
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
						loader: 'stylus-loader',
						options: {
							webpackImporter: false // Don't resolve imports at this stage
						}
					},
				],
			},
			{
				test: /\.(woff2|ttf|otf)$/,
				type: 'asset/resource',
			},
		],
	},
}