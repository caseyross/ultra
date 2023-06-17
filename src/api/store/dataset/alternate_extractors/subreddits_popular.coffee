import extract from '../extract.coffee'

export default (rawData) ->
	datasets = extract(rawData)
	datasets.main.data = datasets.main.data[1..] # first result is always r/home
	return datasets