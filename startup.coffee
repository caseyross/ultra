url_path = window.location.pathname.split('/')
url_params = new URLSearchParams window.location.search[1...]
universal_feed_config =
    name: url_path[2] || ''
    seen_count: url_params.get('count') || 0
    last_seen: url_params.get('after') || ''
    page_size: url_params.get('limit') || 10
    selected:
        id: ''
    previous_selected:
        id: ''
    background_color: 'white'
    button_color: '#ddd'
variable_feed_config = switch url_path[1]
    when 'u', 'user'
        type: 'user'
        rank_by:
            type: url_params.get('sort') || 'new'
            filter: url_params.get('t') || ''
    else
        type: 'subreddit'
        rank_by:
            type: if url_path[2] then url_params.get('sort') || url_path[3] || 'hot' else 'best'
            filter: switch url_params.get('sort') || url_path[3]
                when 'top'
                    url_params.get('t') || 'day'
                else
                    url_params.get('geo_filter') || 'GLOBAL'

window.startup = {
    feed_config: {
        ...universal_feed_config
        ...variable_feed_config
    }
    promises:
        feed: []
        feed_meta: {}
        posts: {}
        source_posts: {}
}

import { load_feed, get_post_fragment, get_feed_meta } from './network.coffee'
startup.promises.feed = load_feed(startup.feed_config)
for promise in startup.promises.feed
    promise.then (post) ->
        startup.promises.posts[post.id] = get_post_fragment post.id
        if post.type == 'reddit'
            startup.promises.source_posts[post.id] = get_post_fragment post.source.id, post.source.comment_id, post.source.context_level
startup.promises.feed_meta = get_feed_meta(startup.feed_config)