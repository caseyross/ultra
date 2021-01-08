<script>

	export spend = 0
		
</script><template lang='pug'>

	span
		span.stat-icon(style!="color: goldenrod") ●
		span.stat-value(style!="margin-left: 0.5ch") {spend}

</template><style>

	.stat-icon
		font-size 1.5rem
	.stat-value
		font-size 0.8rem

</style>