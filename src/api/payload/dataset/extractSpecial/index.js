import post from './post.coffee'
import users from './users.coffee'

// Extractor functions for API routes that need data restructuring beyond what the general extractor can provide.
// NOTE: Expect side effects - in particular, input data modification - in all special extractors.
export default {
	post,
	users,
}