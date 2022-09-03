import ID from '../../ID.coffee'
import extract from '../extract.coffee'

export default (rawData) ->
	datasets = extract(rawData)
	datasets.main.data =
		comment_replies: datasets.sub.filter((x) -> ID.prefix(x.id) is 'comment'and x.data.type is 'comment_reply').map((x) -> ID.body(x.id)[0])
		post_replies: datasets.sub.filter((x) -> ID.prefix(x.id) is 'comment'and x.data.type is 'post_reply').map((x) -> ID.body(x.id)[0])
		private_messages: datasets.sub.filter((x) -> ID.prefix(x.id) is 'private_message').map((x) -> ID.body(x.id)[0])
		username_mentions: datasets.sub.filter((x) -> ID.prefix(x.id) is 'comment' and x.data.type is 'username_mention').map((x) -> ID.body(x.id)[0])
	return datasets