<template lang='pug'>
	
	ol
		+each('objects as object')
			li(tabindex=0)
				table
					tr
						td.time-since {Time.relative(object.created_utc)}
						td
							a {object.author}
					tr
						td.flair {show_flair ? object.flair : object.subreddit}
						td
							a(href='{window.location.pathname}{window.location.search}#{object.id}')
								h2.headline {object.title}

</template><style>

	ol
		margin 0
		padding 0
		overflow auto
		will-change transform // https://bugs.chromium.org/p/chromium/issues/detail?id=514303
		list-style none
	table
		color gray
		a
			display block
	.flair
		width 16ch
		text-align right
		vertical-align top
		overflow hidden
		text-overflow ellipsis
		color white
	.time-since
		text-align right
		vertical-align top
	.headline
		margin 0
		width 32ch
		font-size 2rem
		font-weight normal
		color white

</style><script>

	export objects = []
	export show_flair = false
	
	content_type_icon = (object) -> switch object.content.type
		when 'html' then '≣'
		when 'image'
			if object.is_gallery then '⊟' else '⊡'
		when 'video' then '▶'
		else '↗'
		# ⍟ ⛏ ♬ ☣ ☢ ☠ ☄ ⚠ ⛞ ⛨ ⁑ ※ ∽ ⊹ ⊚ ⛶ ◇
	tag = (object) -> switch
		when object.is_sticky then 'STICKY'
		when object.over_18 then 'NSFW'
		when object.spoiler then 'SPOILER'
		when object.locked then 'LOCKED'
		when object.quarantine then 'QUARANTINED'
		else ''
		
</script>