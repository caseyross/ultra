import extract from '../extract.coffee'

export default (rawData) ->
	result =
		main:
			id: null
			data: []
		sub: []
	if rawData?.json?.data?.things?.length
		for comment in rawData.json.data.things
			commentDataset = extract(comment)
			result.main.data.push(commentDataset.main.id)
			result.sub.push(commentDataset.main)
			result.sub.push(...commentDataset.sub)
	return result