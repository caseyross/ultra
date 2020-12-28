<template lang='pug'>

	a.avatar(href='/u/{username}' ) 🎇

</template><style>

	.avatar
		flex 0 0 auto
		width 2.5ch
		height @width
		border 1px solid
		border-radius 100%
		background red
		margin-right 1ch
		position relative
		.distinguish-admin > &::before
		.distinguish-mod > &::before
		.distinguish-op > &::before
		.distinguish-special > &::before
			position absolute
			font-size 10px
			transform rotate(-10deg)
		.distinguish-admin > &::before
			content 'ADMIN'
			color orangered
		.distinguish-mod > &::before
			content 'MOD'
			color green
		.distinguish-op > &::before
			content 'OP'
			color blue
		.distinguish-special > &::before
			content '???'
			color purple

</style><script>

	export username = ''

</script>