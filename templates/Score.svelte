<template lang='pug'>

	span.stats
		span.stat-value(style!="color: {score === 0 ? 'gray' : score > 0 ? 'lightsalmon' : 'cornflowerblue'}") {scoreHidden ? '---' : score}

</template><style>

	.stats
		display flex
		align-items baseline
		justify-content flex-end
		width 9rem
		padding 0 1.25ch 0 1ch

</style><script>

	export score = 0
	export scoreHidden = false
		
</script>