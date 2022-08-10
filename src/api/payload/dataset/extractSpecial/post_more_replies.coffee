import extract from '../extract.coffee'

export default (rawData, sourceID) ->
	result =
		main:
			id: null
			data: []
		sub: []
	if rawData?.json?.data?.things?.length
		for comment in rawData.json.data.things
			commentDataset = extract(comment, sourceID)
			result.main.data.push(commentDataset.main.id)
			result.sub.push(commentDataset.main)
			result.sub.push(...commentDataset.sub)
	return result