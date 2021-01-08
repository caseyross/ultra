<script>

	export user = null
		
</script><template lang='pug'>

	a.user(href='/u/{user.name}')
		span.name {user.name}
		+if('user.flair.text')
			span.flair {user.flair.text}

</template><style>

	.user
		padding 0.5ch 1ch
		border-radius 1ch
		font-size 1.5rem
		color #999
	.flair
		margin-left 1ch
		color #666
		font-style italic

</style>