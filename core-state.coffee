import { writable } from 'svelte/store'

url_path = window.location.pathname.split('/')
url_params = new URLSearchParams window.location.search[1...]
variable_feed_config = switch url_path[1]
    when 'u', 'user'
        type: 'user'
        name: url_path[2] || ''
        rank_by:
            type: url_params.get('sort') || 'new'
            filter: url_params.get('t') || ''
    else
        type: 'subreddit'
        name: url_path[2] || 'popular'
        rank_by:
            type: url_params.get('sort') || url_path[3] || 'hot'
            filter: switch url_params.get('sort') || url_path[3]
                when 'top'
                    url_params.get('t') || 'day'
                else
                    url_params.get('geo_filter') || 'GLOBAL'
universal_feed_config =
    seen_count: url_params.get('count') || 0
    last_seen: url_params.get('after') || ''
    page_size: url_params.get('limit') || 10
    selected:
        id: ''
    previous_selected:
        id: ''
export feed = writable {
    ...variable_feed_config
    ...universal_feed_config
}

export promises = writable
    feed: []
    posts: {}
    source_posts: {}

export dom = writable
    post_reddit_comments: {}
    post_self_text: {}
    comments: {}
    minimap: {}
    minimap_field: {}
    minimap_cursor: {}