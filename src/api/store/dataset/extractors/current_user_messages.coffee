import ID from '../../../core/ID.coffee'
import extract from './extract.coffee'

export default (rawData) ->
	datasets = extract(rawData)
	datasets.main.data =
		comment_replies: datasets.sub.filter((x) -> ID.type(x.id) is 'comment'and x.data.type is 'comment_reply').map((x) -> ID.var(x.id, 1))
		post_replies: datasets.sub.filter((x) -> ID.type(x.id) is 'comment'and x.data.type is 'post_reply').map((x) -> ID.var(x.id, 1))
		private_messages: datasets.sub.filter((x) -> ID.type(x.id) is 'private_message').map((x) -> ID.var(x.id, 1))
		username_mentions: datasets.sub.filter((x) -> ID.type(x.id) is 'comment' and x.data.type is 'username_mention').map((x) -> ID.var(x.id, 1))
	return datasets