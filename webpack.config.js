// filesystem
const path = require('path') // node.js built-in API, not part of package.json dependencies
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
		initEnv: {
			import: './src/initEnv.coffee',
		},
		initState: {
			import: './src/initState.coffee',
			dependOn: 'initEnv',
		},
		initUI: {
			import: './src/initUI.coffee',
			dependOn: 'initState',
		}
	},
	mode: 'production',
	module: {
		rules: [
			{
				test: /\.pug$/,
				use: [{
					loader: 'svelte-loader',
					options: {
						preprocess: [{
							markup: ({ content }) => ({ code: pugToSvelte(content) }),
							script: ({ content }) => ({ code: coffeescript.compile(content, { bare: true }) }),
							style: ({ content }) => ({ code: stylus.render(content) }),
						}]
					},
				}],
			},
			{
				test: /\.coffee$/,
				use: [{
					loader: 'coffee-loader',
					options: {
						bare: true // No isolation IIFE
					}
				}],
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
	optimization: {
		runtimeChunk: 'single', // with multiple entries on one page, need single runtime chunk to avoid duplicate module instantiations
	},
	output: {
		clean: true, // cleanup output directory before emitting assets
		filename: '[name].[contenthash].js',
		path: path.join(__dirname, 'dist'), // output directory, absolute path required
		publicPath: '', // root path for generated assets
	},
	plugins: [
		new DotEnvFileWebpackPlugin(),
		new HtmlOutputWebpackPlugin({
			favicon: './src/ui/assets/favicons/favicon_16.png',
			inject: false, // manual script placement in template
			template: './src/index.html',
		}),
		new HtmlOutputInlineScriptWebpackPlugin({
			scriptMatchPattern: [/^runtime/, /^initEnv/, /^initState/] // avoid add'l network roundtrip on critical path
		}),
	],
}