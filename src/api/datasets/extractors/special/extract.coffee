import t3 from './t3.coffee'
import t3lic from './t3lic.coffee'

# Extractor functions for API routes that need data restructuring beyond what the general extractor can provide.
# NOTE: Expect side effects - in particular, input data modification - in all extractors.
export default
	t3: t3
	t3lic: t3lic