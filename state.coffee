import { writable } from 'svelte/store'
import { sync_url } from './network.coffee'

default_selected = {
    post: {}
    comment: {}
    inspect_mode: ''
}
export selected = writable default_selected
export feed = (() ->
    { subscribe, set, update } = writable sync_url()
    {
        subscribe,
        go: (new_url) ->
            selected.set default_selected
            set sync_url(new_url)
    })()