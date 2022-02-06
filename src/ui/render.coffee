import GlobalNavigation from './GlobalNavigation.pug'

try
	new GlobalNavigation
		target: document.body
catch error
	alert(error)