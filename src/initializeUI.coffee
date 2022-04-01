import './ui/assets/global.styl'
import Post from './ui/components/post/Post.pug'

try
	new Post
		target: document.body
		props:
			id: 't3:tt4p8e'
catch error
	alert(error)