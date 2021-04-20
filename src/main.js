import './global.styl'

import './lib/prototype_extensions'
import './lib/API'
import './lib/Color'
import './lib/LazyPromise'
import './lib/Markdown'
import './lib/Statistics'

import App from './App.pug'

new App({ target: document.body })