window.extAsyncInit = function() {
  // the Messenger Extensions JS SDK is done loading

  // check for supported features
  MessengerExtensions.getSupportedFeatures(
    function success(result) {
      let features = result.supported_features;
      console.log(features);
      features.includes('context') ? loginWithContext() : loginWithUserId();
    },
    errorLogger('supported features')
  );
};

function loginWithContext() {
  MessengerExtensions.getContext(app_id,
    function(thread_context) {
      console.log(thread_context);
      login(thread_context.psid);
    },
    errorLogger('context')
  );
}

function loginWithUserId() {
  MessengerExtensions.getUserID(function(user_ids){
    console.log(user_ids);
    login(user_ids.psid);
  }, errorLogger('userID'))
}

function login(psid) {
  window.location.replace('/users/'+psid+'/login');
}
