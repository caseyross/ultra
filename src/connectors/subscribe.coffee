import { onDestroy } from 'svelte'
import datasets from '../api/datasets/store.coffee'

export default (id) ->
	unsubscribe = datasets.subscribe((value) -> dataset = value[id])
	if dataset == undefined
		datasets.load(id)
	onDestroy ->
		unsubscribe()