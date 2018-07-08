// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

(function(d, s, id){
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) {return;}
  js = d.createElement(s); js.id = id;
  js.src = "https://connect.facebook.net/en_US/messenger.Extensions.js";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'Messenger'));

window.extAsyncInit = function() {
  // the Messenger Extensions JS SDK is done loading

  // check for supported features
  MessengerExtensions.getSupportedFeatures(
    function(result) {
      let features = result.supported_features;
      console.log(features);
    },
    errorLogger('supported features')
  );


  // bind to update function for manage community profile
  document.getElementById('update_profile').addEventListener('click', closeWebview)
};

function closeWebview(){
  MessengerExtensions.requestCloseBrowser(function() {
    // webview closed
    fetch('/users/logout');

    console.log('Closed!!!')
  }, errorLogger('close webview'));
}

function errorLogger(descriptor){
  return function(err) { console.log('Retrieve '+ descriptor + ' failed: Error ', err)}
}
