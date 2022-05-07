import post from './post.coffee'

# Extractor functions for API routes that need data restructuring beyond what the general extractor can provide.
# NOTE: Expect side effects - in particular, input data modification - in all extractors.
export default {

	post,

}