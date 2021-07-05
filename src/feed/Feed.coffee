export default class Feed

	constructor: ->  @[k] = v for k, v of {
		sections: []
	}