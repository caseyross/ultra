import ID from '../../../base/ID.coffee'
import extract from '../extract.coffee'

export default (rawData) ->
	result =
		main: null
		sub: []
	collection = rawData
	postDatasets = extract(collection.sorted_links)
	delete collection.sorted_links
	delete collection.link_ids
	collection.posts = postDatasets.main.data
	result.main =
		id: ID('collection', collection.collection_id)
		data: collection
	result.sub = postDatasets.sub
	return result