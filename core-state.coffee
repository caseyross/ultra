import { writable } from 'svelte/store'

export chosen = writable
    post:
        id: '',
        replies: []

export dom = writable
    post_reddit_comments: {}
    post_self_text: {}
    comments: {}
    minimap: {}
    minimap_field: {}
    minimap_cursor: {}

export load = writable
    posts: false

export memory = writable
    previous_post_id: ''
    previous_comments_scrollheight: 0
    read_posts: new Set()