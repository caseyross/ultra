import extract from '../general/extract.coffee'

# When the user has "manage" permissions for the livethread, an array of 2 UserList objects will be returned: current contributors and pending contibutor invites. Otherwise, the return value will simply be a UserList of current contributors.
export default (rawData) ->
	result =
		main:
			id: null
		sub: []
	if Array.isArray(rawData) and rawData.length is 2
		result.main.data =
			current: extract(rawData[0]).main.data
			invited: extract(rawData[1]).main.data
	else
		result.main.data =
			current: extract(rawData).main.data
			invited: []
	return result