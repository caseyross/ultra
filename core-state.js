import { writable } from 'svelte/store'

export const chosen = writable({
    post: {
        id: '',
        replies: []
    }
})

export const dom = writable({
    post_reddit_comments: {},
    post_self_text: {},
    comments: {},
    minimap: {},
    minimap_field: {},
    minimap_cursor: {}
})

export const history = writable({
    previous_post_id: '',
    previous_comments_scrollheight: 0,
    read_posts: new Set()
})