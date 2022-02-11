export default (id) ->

	idem = true

	switch type

		when 'accept'
			return
		when 'approve'
			return
		when 'block'
			return
		when 'configure'
			return
		when 'create'
			return
		when 'delete'
			return
		when 'downvote'
			POST 'api/vote',
				id: id
				dir: -1
		when 'edit'
			return
		when 'expel'
			return
		when 'follow'
			return
		when 'hide'
			return
		when 'ignore'
			return
		when 'invite'
			return
		when 'notify'
			return
		when 'report'
			return
		when 'resign'
			return
		when 'revert'
			return
		when 'save'
			return
		when 'show'
			return
		when 'unvote'
			POST 'api/vote',
				id: id
				dir: 0
		when 'upvote'
			POST 'api/vote',
				id: id
				dir: 1

	if idem == true and $sending[id]
		return
	$sending[id] = true