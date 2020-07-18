import { writable } from 'svelte/store'

export feed = writable window.feed
export inspector = writable
    mode: 'none'
    object: {}
    feed: {}