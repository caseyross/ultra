import { writable } from 'svelte/store'

export feed = writable window.startup.feed_config
export promises = writable window.startup.promises

export debug = writable
    inspector:
        mode: 'none'
        object: {}
        feed: {}