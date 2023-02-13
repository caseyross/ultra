export default (rawData) ->
	result =
		main:
			id: null
			data: {}
		sub: []
	if rawData?.items and rawData?.layout
		result.main.data =
			id_card: rawData.items[rawData.layout.idCardWidget]
			moderators: rawData.items[rawData.layout.moderatorWidget]
			sidebar: rawData.layout.sidebar.order.map((widget_id) => rawData.items[widget_id])
			topbar: rawData.layout.topbar.order.map((widget_id) => rawData.items[widget_id])
	return result