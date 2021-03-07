# parse:
# substitute references
# recursively split down and format up chunks

# convert a chunk of Markdown text into a single HTML tag (which may or may not contain other HTML tags recursively inside it)
parse_chunk = (chunk) ->
	# find subchunks
	sub_chunks = split_chunk(chunk)
	if sub_chunks.length is 1
		return 
	# join subchunk parses
	convert_to_tag(sub_chunks.map(parse).join())

class Chunk


parse_chunk = (chunk) ->
	subchunks = []
	next_subchunk =
		tag: 'p'
		text: ''
	for char in chunk
		next_subchunk += char
		if # next_subchunk is complete
			# set tag
			subchunks.push(next_subchunk)
			# reset next_subchunk

find_chunks = (string) ->
	chunks = []
	proposed_type = ''
	for char in string


# convert a chunk of Markdown text into a single HTML tag 
convert = (chunk, tag) ->
	tag = 'p' # default to <p> tag; if we discover a different one fits better, we 
	attributes = {}
	text = ''
	# do the actual markdown >>> html conversion
	# return opening tag with attributes + text + closing tag