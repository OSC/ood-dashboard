import RFB from '../core/rfb.js'

var rfb = new RFB(document.body, location.href + '/websockify')
var textToCopy = document.getElementById("noVNC_clipboard_text");

if (navigator.clipboard) {
	rfb.addEventListener('clipboard', function(e) {
		console.log("noVNC clipboard event")

	})

	console.log("Suppport detected.")
} else {
	console.log("No support detected.")
}
