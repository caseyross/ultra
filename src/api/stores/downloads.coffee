export default downloads = {
	mergeable()
	add: (id) ->
		if !loading[id]
			loading[id] = true
			download(id)
				.then (data) ->
					{ main, other, fragments } = extract(data)
					data[id] = main
					fragment[id] = false
					for other of other
						status[subObject.id] = subObject.status
						data[subObject.id] = subObject.data
					for fragment of fragments
						fragment[id] = true
					@set(data)
					error[id] = false
				.catch (error) ->
					error[id] = error
				.finally ->
					loading[id] = false