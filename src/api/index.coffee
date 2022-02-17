import '../lib/index.coffee'

export default {
	
	init: =>
		@downloads = new DownloadStore()
		@uploads = new UploadStore()

}