export default class Story

	constructor: ->  @[k] = v for k, v of {}
	
	get: =>
		Promise.resolve
			title: ''