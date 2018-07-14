window.fbAsyncInit = function() {
    FB.init({
      appId            : '1145402942269454',
      autoLogAppEvents : true,
      xfbml            : true,
      version          : 'v3.0'
    });
  };

(function(d, s, id){
   var js, fjs = d.getElementsByTagName(s)[0];
   if (d.getElementById(id)) {return;}
   js = d.createElement(s); js.id = id;
   js.src = "https://connect.facebook.net/en_US/sdk/debug.js";
   fjs.parentNode.insertBefore(js, fjs);
 }(document, 'script', 'facebook-jssdk'));
