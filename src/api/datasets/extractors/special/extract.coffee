import post from './post.coffee'
import user_info_bulk from './user_info_bulk.coffee'

# Extractor functions for API routes that need data restructuring beyond what the general extractor can provide.
# NOTE: Expect side effects - in particular, input data modification - in all extractors.
export default {

	post,
	user_info_bulk,

}