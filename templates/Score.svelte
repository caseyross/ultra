<script>

	export score = 0
	export scoreHidden = false
		
</script><template lang='pug'>

	span.stat-value(style!="color: {score === 0 ? 'gray' : score > 0 ? 'lightsalmon' : 'cornflowerblue'}") {scoreHidden ? '---' : score}

</template><style>

</style>