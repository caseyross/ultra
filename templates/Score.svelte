<template lang='pug'>

	span.stats
		span.stat-icon(style!="color: {score === 0 ? 'gray' : score > 0 ? 'lightsalmon' : 'cornflowerblue'}") {scoreHidden ? '🞄' : score === 0 ? '🠶' : score > 0 ? '🠉' : '🠋'}
		span.stat-value(style!="color: {scoreHidden ? 'gray' : ''}") {scoreHidden ? 'hidden' : score}

</template><style>

	.stats
		display flex
		align-items baseline
		justify-content space-between
		width 9rem
		padding 0 1.25ch 0 1ch
		line-height 1.5
		background #333
	.stat-icon
		font-size 1.5rem
	.stat-value
		font-size 0.8rem

</style><script>

	export score = 0
	export scoreHidden = false
		
</script>