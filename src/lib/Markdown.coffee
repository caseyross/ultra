window.Markdown =
	to_HTML: (string) ->
		return string
		html = '<div class="md">'
		positions = []
		prev2 = ''
		prev1 = ''
		i = 0
		while i < string.length
			positions[i] = []
			switch string[i]
				when '['
					positions[i].push('s_link')
					positions[i].push('s_linktext')
				when ']'
					positions[i].push('e_linktext')
				when '('
					positions[i].push('s_linkurl')
				when ')'
					positions[i].push('e_linkurl')
					positions[i].push('e_link')
				when '*'
					positions[i].push('s_emphasis1')
					positions[i].push('e_emphasis1')
					if prev1 == '*'
						positions[i].push('s_emphasis2')
						positions[i].push('e_emphasis2')
						if prev2 == '*'
							positions[i].push('s_emphasis3')
							positions[i].push('e_emphasis3')
				when '#'
					positions[i].push('s_heading1')
					positions[i].push('e_heading1')
					if prev1 == '#'
						positions[i].push('s_heading2')
						positions[i].push('e_heading2')
						if prev2 == '#'
							positions[i].push('s_heading3')
							positions[i].push('e_heading3')
				when '^'
					positions[i].push('s_superscript')
				when '~'
					if prev1 == '~'
						positions[i].push('s_strikethrough')
						positions[i].push('e_strikethrough')
						if prev2 == '~'
							positions[i].push('s_codeblockB')
							positions[i].push('e_codeblockB')
				when '`'
					positions[i].push('s_code')
					positions[i].push('e_code')
					if prev1 == '`' and prev2 == '`'
						positions[i].push('s_codeblockA')
						positions[i].push('e_codeblockA')
				when '!'
					if prev1 == '>' then positions[i].push('s_spoiler')
				when '<'
					if prev1 == '!' then positions[i].push('e_spoiler')
				when '>'
					positions[i].push('s_quote')
				when '\\'
					positions[i].push('backquote')
				when '\n'
					positions[i].push('newline')
			prev2 = prev1
			prev1 = string[i]
			html += string[i]
			i += 1
		html += '</div>'
		return html