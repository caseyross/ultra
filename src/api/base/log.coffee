export default ({ details, error, id, message }) ->
	if localStorage['api.config.debug'] != 'TRUE' then return
	style = switch
		when error then 'background: orangered; color: white'
		else 'background: mediumspringgreen; color: darkolivegreen'
	console.groupCollapsed("%c #{id} ", style, '>', message)
	if details then console.info(details)
	if error then console.info(error)
	console.groupEnd()