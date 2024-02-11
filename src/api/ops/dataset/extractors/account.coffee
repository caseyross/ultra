import ID from '../../../base/ID.coffee'
import extract from '../extract.coffee'

export default (rawData) ->
	return extract({
		kind: 't2'
		data: rawData
	})