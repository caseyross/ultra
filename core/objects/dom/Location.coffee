Location::toSessionState = () ->
	pageFragment = @hash[1..] # The hash starts with '#'.
	pathSegments = @pathname.split('/')[1..] # The pathname starts with a slash, so the first element from split() is always ''.
	queryParams = new URLSearchParams @search
	# Check prefixed paths
	switch pathSegments[0]
		when 'c'
			route: 'COMMENT'
			data:
				id: pathSegments[1].toCommentId()
		when 'p'
			route: 'POST'
			data:
				id: pathSegments[1].toPostId()
				sort: pageFragment
				stream: switch
					when queryParams.has 'r'
						type: 'BOARD'
						name: queryParams.get 'r'
					when queryParams.has 'u'
						type: 'USER'
						name: queryParams.get 'u'
					else
						null
		when 'r'
			route: 'BOARD'
			data:
				name: pathSegments[1].toBoardName()
				sort: pageFragment
		when 'u'
			route: 'USER'
			data:
				name: pathSegments[1].toUserName()
				sort: pageFragment
		else
			# Check non-prefixed paths
			switch pathSegments[0]
				when ''
				else
					route: 'BOARD'
					data:
						name: pathSegments[0].toBoardName()
						sort: pageFragment