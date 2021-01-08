<script>

	export name = ''

</script><template lang='pug'>

	a.subreddit(href='/r/{name}' ) 🎇 {name}

</template><style>

	.subreddit
		flex 0 0 auto
		height 2.5ch
		padding-right 1ch
		border 1px solid
		border-radius 1.25ch
		margin-right 1ch
		position relative
		font-size 1.5ch

</style>