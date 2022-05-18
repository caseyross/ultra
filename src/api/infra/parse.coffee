export default {

	actionParameters: (actionId) ->
		actionId.split(':')[1..]

	actionType: (actionId) ->
		actionId.split(':')[0]

	datasetFilters: (datasetId) ->
		datasetId.split(':')[1..]
	
	datasetType: (datasetId) ->
		datasetId.split(':')[0]

}