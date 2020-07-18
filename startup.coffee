url_path = window.location.pathname.split('/')
url_params = new URLSearchParams window.location.search[1...]
window.feed = {
    name: url_path[2] || ''
    ...(switch url_path[1]
        when 'u', 'user'
            type: 'u'
            rank_by:
                type: url_params.get('sort') || 'new'
                filter: url_params.get('t') || ''
        else
            type: 'r'
            rank_by:
                type: if url_path[2] then url_params.get('sort') || url_path[3] || 'hot' else 'best'
                filter: switch url_params.get('sort') || url_path[3]
                    when 'top'
                        url_params.get('t') || 'day'
                    else
                        url_params.get('geo_filter') || 'GLOBAL'
    )
    seen_count: url_params.get('count') || 0
    last_seen: url_params.get('after') || ''
    page_size: url_params.get('limit') || 10
    page_pending: []
    posts_pending: {}
    sources_pending: {}
    selected_post: {}
}

import { fetch_feed_page, fetch_post, fetch_feed_info } from './network.coffee'
window.feed.page_pending = fetch_feed_page(window.feed)
for post_pending in window.feed.page_pending
    post_pending.then (post) ->
        feed.posts_pending[post.id] = fetch_post post.id
        if post.type == 'reddit'
            window.feed.sources_pending[post.id] = fetch_post post.source.id, post.source.comment_id, post.source.context_level
window.feed.info_pending = fetch_feed_info(window.feed)