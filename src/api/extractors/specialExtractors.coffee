import t3 from './special/t3.coffee'

# Extractor functions for API routes that need data restructuring beyond what the general extractor can provide.
# NOTE: Expect side effects - in particular, input data modification - in all extractors.
export default
	t3: t3