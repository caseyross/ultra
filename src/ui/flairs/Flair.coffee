export default class Flair
	
	constructor: ({ text, color }) ->  @[k] = v for k, v of {
		
		text: text or ''
		color: color or ''

	}