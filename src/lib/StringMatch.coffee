export default {

	match: (strings, chars) ->
		matches = []
		for string in strings
			indices = []
			score = 0
			streak_length = 0 # number of consecutive letters matched as a run
			i = 0
			j = 0
			while i < string.length and j < chars.length
				if string[i].toLowerCase() == chars[j].toLowerCase()
					indices.push(i)
					i += 1
					j += 1
					streak_length = if indices.at(-1) == indices.at(-2) + 1 then streak_length + 1 else 0
					score += 1
					score += 3 * streak_length
					if i == 1 then score += 4 # matched first letter in string
					if /[A-Z0-9]/.test(string[i - 2]) == false and /[A-Z0-9]/.test(string[i - 1]) then score += 3 # matched first letter after word boundary
				else
					i += 1
			if indices.length == chars.length
				matches.push({
					indices,
					score,
					string,
				})
		matches.sort((a, b) -> b.score - a.score)
		return matches

}