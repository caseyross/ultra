const sveltePreprocess = require('svelte-preprocess')

module.exports = {
	preprocess: sveltePreprocess({ defaults: { markup: 'pug', style: 'stylus', script: 'coffeescript' } })
}