import { get } from '../infra/requests.coffee'
NOT_IMPLEMENTED = ->
	Promise.reject('Route for specified ID is not implemented yet!')

export default {
	
	t1:     NOT_IMPLEMENTED
	t1x:    (parentPostId, sort, ...desiredCommentIds) -> # NOTE: Max concurrency for this call is 1 per Reddit API rules.
		get "/api/morechildren", { link_id: parentPostId, children: desiredCommentIds, sort }
	t2fcz:  (limit, after) ->
		get "/subreddits/mine/contributor", { limit, after }
	t2fmz:  (limit, after) ->
		get "/subreddits/mine/moderator", { limit, after }
	t2fz:   (limit, after) ->
		get "/subreddits/mine/subscriber", { limit, after }
	t2i:    (userName) ->
		get "/user/#{userName}/about"
	t2ii:   ->
		get "/api/v1/me"
	t2iix:  ->
		get "/api/multi/mine"
	t2ip:   (...fields) -> # RESEARCH: Check if you get all prefs when no fields specified
		get "/api/v1/me/prefs", { fields: fields.join(',') }
	t2ix:   (userName) ->
		get "/api/multi/user/#{userName}"
	t2iuaz: NOT_IMPLEMENTED
	t2iubz: NOT_IMPLEMENTED
	t2iucz: NOT_IMPLEMENTED
	t2iufi: NOT_IMPLEMENTED
	t2iufz: NOT_IMPLEMENTED
	t2snz:  (limit, after) ->
		get "/users/new", { limit, after }
	t2spz:  (limit, after) ->
		get "/users/popular", { limit, after }
	t2sz:   (searchText, limit, after) ->
		get "/users/search", { q: searchText, sort: 'relevance', limit, after }
	t2z:    (userName, filter, sort, limit, after) ->
		get "/user/#{userName}/#{filter}", { sort: sort.preHyphen, t: sort.postHyphen, limit, after }
	t3:     (postShortId, commentsSort, commentShortId, context) ->
		get "/comments/#{postShortId}", { sort: commentsSort, comment: commentShortId, context }
	t3c:    (collection_id) ->
		get "/api/v1/collections/collection", { collection_id, include_links: true }
	t3dz:   (postShortId, limit, after) ->
		get "/duplicates/#{postShortId}", { limit, after }
	t3ldz:  (threadId, limit, after) ->
		get "/live/#{threadId}/discussions", { limit, after }
	t3li:   (threadId) ->
		get "/live/#{threadId}/about"
	t3lic:  (threadId) ->
		get "/live/#{threadId}/contributors"
	t3lu:   (threadId, updateId) ->
		get "/live/#{threadId}/updates/#{updateId}"
	t3luz:  (threadId, limit, after) ->
		get "/live/#{threadId}", { limit, after }
	t3sz:   (searchText, subredditName, sort, limit, after) ->
		endpoint = if subredditName? then "/r/#{subredditName}/search" else "/search"
		get endpoint, { sort: sort.preHyphen, t: sort.postHyphen, limit, after, restrict_sr: true }
	t3w:    (pageName, subredditName, versionId, diffFromVersionId) ->
		get "/r/#{subredditName}/wiki/#{pageName}", { v: version, v2: diffFromVersionId }
	t3wdz:  (pageName, subredditName, limit, after) ->
		get "/r/#{subredditName}/wiki/discussions/#{pageName}", { limit, after }
	t3wp:   (pageName, subredditName) ->
		get "/r/#{subredditName}/wiki/settings/#{pageName}"
	t3wvz:  (pageName, subredditName, limit, after) ->
		get "/r/#{subredditName}/wiki/revisions/#{pageName}", { limit, after }
	t4:     NOT_IMPLEMENTED
	t4c:    NOT_IMPLEMENTED
	t4cz:   NOT_IMPLEMENTED
	t4m:    NOT_IMPLEMENTED
	t4miu:  NOT_IMPLEMENTED
	t4mz:   NOT_IMPLEMENTED
	t4z:    NOT_IMPLEMENTED
	t5e:    (subredditName) ->
		get "/api/v1/#{subredditName}/emojis/all"
	t5fp:   (subredditName) ->
		get "/r/#{subredditName}/api/link_flair_v2"
	t5fu:   (subredditName) ->
		get "/r/#{subredditName}/api/user_flair_v2"
	t5g:    (subredditName) ->
		get "/r/#{subredditName}/api/widgets"
	t5i:    (subredditName) ->
		get "/r/#{subredditName}/about"
	t5ir:   (subredditName) ->
		get "/r/#{subredditName}/about/rules"
	t5irp:  (subredditName) ->
		get "/api/v1/#{subredditName}/post_requirements"
	t5irpt: (subredditName) ->
		get "/r/#{subredditName}/api/submit_text"
	t5it:   (subredditName) ->
		get "/r/#{subredditName}/about/traffic"
	t5iub:  NOT_IMPLEMENTED
	t5iubw: NOT_IMPLEMENTED
	t5iuc:  NOT_IMPLEMENTED
	t5iucw: NOT_IMPLEMENTED
	t5ium:  NOT_IMPLEMENTED
	t5iuu:  NOT_IMPLEMENTED
	t5mez:  NOT_IMPLEMENTED
	t5mlz:  NOT_IMPLEMENTED
	t5mqz:  NOT_IMPLEMENTED
	t5mrz:  NOT_IMPLEMENTED
	t5msz:  NOT_IMPLEMENTED
	t5muz:  NOT_IMPLEMENTED
	t5sa:   (searchText, limit) ->
		get "/api/subreddit_autocomplete_v2", { q: searchText, include_over_18: true, limit }
	t5snz:  (limit, after) ->
		get "/subreddits/new", { limit, after }
	t5spz:  (limit, after) ->
		get "/subreddits/popular", { limit, after }
	t5sz:   (searchText, limit, after) ->
		get "/subreddits/search", { q: searchText, sort: 'relevance', limit, after }
	t5w:    (subredditName) ->
		get "/r/#{subredditName}/wiki/pages"
	t5we:   (subredditName, limit, after) ->
		get "/r/#{subredditName}/wiki/revisions", { limit, after }
	t5xi:   (userName, multiredditName) ->
		if userName is 'r'
			return Promise.resolve({})
		get "/api/multi/u/#{userName}/m/#{multiredditName}/description"
	t5xz:   (userName, multiredditName, sort, limit, after) ->
		endpoint =
			if userName is 'r'
				if multiredditName is 'home'
					"/#{sort.preHyphen}"
				else
					"/r/#{multiredditName}/#{sort.preHyphen}"
			else
				"/api/multi/u/#{userName}/m/#{multiredditName}/#{sort.preHyphen}"
		get endpoint, { t: sort.postHyphen, limit, after }
	t5z:    (subredditName, sort, limit, after) ->
		get "/r/#{subredditName}/#{sort.preHyphen}", { t: sort.postHyphen, limit, after }
	t6:     NOT_IMPLEMENTED

}