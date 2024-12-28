callbacks = {}

setInterval(
	->
		for timer_id in Object.getOwnPropertySymbols(callbacks)
			callbacks[timer_id]()
	3000
)

export default {
	
	onTick: (callback) ->
		timer_id = Symbol()
		callbacks[timer_id] = callback
		return timer_id

	deregister: (timer_id) ->
		delete callbacks[timer_id]

}