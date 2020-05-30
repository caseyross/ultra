import { writable } from 'svelte/store'

export feed = writable window.startup.feed_config
export promises = writable window.startup.promises 