import { getSubredditPosts } from '../subreddit/Subreddit.coffee'
import API from '../api/API.coffee'

export getFrontpagePosts = ({ sort = 'best', quantity }) -> API.get
	endpoint: '/' + sort.split('/')[0]
	limit: quantity
	t: sort.split('/')[1]
	sr_detail: true
	cache: ['r/frontpage', sort, quantity].join('/')
	automodel: true # Array[Post]

export getMultiredditPosts = (multiredditNamespace, multiredditName, { sort = 'hot', quantity }) ->
	if multiredditNamespace is 'r'
		getSubredditPosts(multiredditName, { sort, quantity })
	else
		API.get
			endpoint: '/api/multi/u' + multiredditNamespace + '/m/' + multiredditName + '/' + sort.split('/')[0]
			limit: quantity
			t: sort.split('/')[1]
			sr_detail: true
			cache: ['m', multiredditNamespace, multiredditName, sort, quantity].join('/')
			automodel: true # Array[Post]
		.then (x) -> console.log x