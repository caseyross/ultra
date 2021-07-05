export default class Flair
	constructor: ({ text, color }) ->
		if typeof text is 'string'
			# Subreddit emojis in flairs (:emoji:) are generally used either
			# 1) as an auxiliary visual aid for the text, or
			# 2) as a "picture flair".
			# The API doesn't let us resolve subreddit emojis into their respective images without the requester being logged in, so in the general case, we can't display them as intended.
			# To mitigate this, remove subreddit emojis, EXCEPT if they are the only content in the flair text.
			# Case 1) above will fall back to the (generally canonical) text flair, while case 2) will fall back to the :emoji: code.
			emojiless_text = text.replace(/:.+: /g, '').replace(/ :.+:/g, '').replace(/:.+:/g, ' ').trim()
			@text = if emojiless_text.length then emojiless_text else text
		else
			@text = ''
		if typeof color is 'string' and color.length
			@color = color
		else
			@color = 'gray'