const svelte_preprocess = require('svelte-preprocess')

module.exports = {
	preprocess: [
		svelte_preprocess({ defaults: { script: 'coffeescript', markup: 'pug', style: 'stylus' } })
	]
}