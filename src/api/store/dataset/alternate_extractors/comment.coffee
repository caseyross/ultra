import extract from '../extract.coffee'

# When pulling a single comment, the API endpoint delivers it in a listing. We simply need to unwrap it.
export default (rawData) ->
	datasets = extract(rawData)
	datasets.main = datasets.sub[0]
	datasets.sub = []
	return datasets