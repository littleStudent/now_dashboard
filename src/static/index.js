// pull in desired CSS/SASS files
require("./styles/main.scss");
var $ = (jQuery = require("../../node_modules/jquery/dist/jquery.js")); // <--- remove if Bootstrap's JS not needed
// require( '../../node_modules/tether/dist/js/tether.min.js' );
// require( '../../node_modules/bootstrap/dist/js/bootstrap.min.js' );   // <--- remove if Bootstrap's JS not needed

// inject bundled Elm app into div#main
var Elm = require("../elm/Main");
var main = Elm.Main.embed(document.getElementById("main"));

main.ports.trackPage.subscribe(function(page) {
  ga("set", "page", page);
  ga("send", "pageview");
});
main.ports.setToken.subscribe(function(state) {
  localStorage.setItem("token", state);
});
main.ports.startLoadToken.subscribe(function() {
  console.log("LOADING");
  main.ports.loadedToken.send(localStorage.getItem("token") || "");
});

main.ports.scrollTo.subscribe(function(elementId) {
  document.getElementById(elementId).scrollIntoView();
});
