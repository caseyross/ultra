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
		boot: {
			import: './src/boot.coffee', // bootstrap API requests prior to constructing the UI
		},
		render: {
			import: './src/ui/pages/render.coffee', // render the page
			dependOn: 'boot',
		}
	},
	optimization: {
		runtimeChunk: 'single', // with multiple entries on one page, must have only one runtime chunk to avoid duplicate module instantiations
	},
	output: {
		filename: '[name].[contenthash].js',
		path: path.join(__dirname, 'dist'),
		publicPath: '/', // location of output files relative to the web server root
		clean: true // cleanup output directory before emitting assets
	},
	plugins: [
		new HtmlWebpackPlugin({
			template: './src/index.html',
			inject: false, // manual script placement in template
		}),
		new InlineChunkHtmlPlugin(HtmlWebpackPlugin, [/runtime/, /boot/]), // inline to avoid network roundtrip latency
		/* TODO: fix copying
		new CopyWebpackPlugin({
			patterns: [
				{
					from: './src/ui/stylesheets', // copy directly to output directory
					transform: (content, path) => stylus.render(content)
				},
			],
		}),
		*/
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