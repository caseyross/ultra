export matchCharactersToStrings = (chars, strings) ->
	matches = []
	for string in strings
		lowercaseString = string.toLowerCase()
		toMatch = [...chars].map (c) -> c.toLowerCase()
		matchedIndices = []
		if toMatch.length > 1
			fullMatchIndex = lowercaseString.indexOf(toMatch.join(''))
			if fullMatchIndex >= 0
				matches.push {
					string
					matchedIndices: toMatch.map (c, i) -> fullMatchIndex + i
					penalty: fullMatchIndex
				}
				continue
		for char, i in lowercaseString
			if char is toMatch[0]
				matchedIndices.push(i)
				toMatch.shift()
				if toMatch.length is 0
					matches.push {
						string
						matchedIndices
						penalty: 20 + matchedIndices.fold 0, (a, b) -> a + b
					}
					break
	matches.sort (a, b) -> a.penalty - b.penalty
	return matches