import { SRPAGE, SRABOUT, USERPAGE, USERABOUT } from '/proc/api.coffee'

base_state = 
	page:
		type: 'r'
		name: ''
		range: 'day'
		sort: 'best'
		follow_id: ''
		max_count: 25
		ABOUT: new Promise (f, r) -> {}
		STORIES: new Promise (f, r) -> {}
	story:
		type: ''
		id: ''
		comments:
			root:
				id: ''
				parents: NaN
			sort: 'confidence' 

export parse_url = () ->
	segments = window.location.pathname.split('/')[1..]
	query = new URLSearchParams window.location.search
	page = { ...base_state.page }
	story = { ...base_state.story }
	if query.has 't'
		page.range = query.get 't'
	if query.has 'sort'
		page.sort = query.get 'sort'
	if query.has 'after'
		page.follow_id = query.get 'after'
	if query.has 'limit'
		page.max_count = query.get 'limit'
	if query.has 'context'
		story.comments.root.parents = query.get 'context'
	switch segments[0]
		when 'new', 'rising', 'hot', 'controversial', 'top', 'best'
			page.sort = segments[0]
			story.id = segments[1]
		when 'r'
			if segments[1]
				page.name = segments[1]
				if segments[2]
					switch segments[2]
						when 'comments'
							story.id = segments[3]
							if segments[5]
								story.comments.root.id = segments[5]
						when 'new', 'rising', 'hot', 'controversial', 'top'
							page.sort = segments[2]
							if segments[3]
								story.id = segments[3]
						else
							story.id = segments[2]
		when 'u', 'user'
			page.type = 'u'
			page.name = segments[2]
			unless query.has 'sort'
				page.sort = 'new'
		#TODO: multireddits, mail, modmail, modqueues, etc.
		else
			if segments[0].length is 6
				story.id = segments[0]
			else # 404
				{}
	switch page.type
		when 'r'
			page.STORIES = SRPAGE page
			page.ABOUT = SRABOUT page
		when 'u'
			page.STORIES = USERPAGE page
			page.ABOUT = USERABOUT page
		###
		if document.state.object_id
			object.load_comments()
			cache[document.state.object_id] = Date.now() / 1000
		###
	return { page, story }