import extract from '../extract.coffee'

export default (rawData) ->
	# If the target user is the currently logged-in user, their private multis are returned in addition to public ones.
	# We fix that inconsistency here.
	publicRawData = rawData.filter((x) -> x.data.visibility is 'public')
	return extract(publicRawData)