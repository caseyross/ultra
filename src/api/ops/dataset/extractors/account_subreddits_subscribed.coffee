import extract from '../extract.coffee'

export default (rawData) ->
	datasets = extract(rawData)
	# Sort alphabetically.
	datasets.main.data.sort()
	# Move user subreddits to end of list.
	datasets.main.data.sort((a, b) ->
		switch 
			when a.startsWith('u_') and b.startsWith('u_') then 0
			when a.startsWith('u_') then 1
			when b.startsWith('u_') then -1
			else 0
	)
	return datasets