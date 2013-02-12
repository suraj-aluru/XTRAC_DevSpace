public with sharing class AuthController {
 public boolean authSuccess { get; set; }
 public boolean authDone { get; set; }
 public String message { get; set; }
 public String authUrl { get; set; }
 
 public AuthController(){
 	authDone = false;
 	authSuccess = false;
 	System.debug('Suraj -> 1 authUrl:'+ ApexPages.currentPage().getParameters().get('authUrl'));
 	
 	if(ApexPages.currentPage().getParameters().get('authUrl') !=null){
    authUrl = ApexPages.currentPage().getParameters().get('authUrl');
    ApexPages.currentPage().getParameters().remove('authUrl');
    System.debug('Suraj -> authUrl removed:'+ ApexPages.currentPage().getParameters().get('authUrl'));
  }
  else{
  	authDone = true;
  }
  System.debug('Suraj -> 2 authUrl:'+ ApexPages.currentPage().getParameters().get('authUrl'));
 }
 
 public PageReference completeAuthorization() {
  String token = ApexPages.currentPage().getParameters().get('oauth_token');
  String verifier='';
  if(token!=null){
   verifier = ApexPages.currentPage().getParameters().get('oauth_verifier');
   OAuth oa = new OAuth();
   authSuccess = oa.completeAuthorization(token,verifier);
   this.message = oa.message;
   if(authSuccess){
   	return new PageReference('/apex/authTest?oauth_token='+token+'&oauth_verifier='+verifier+'&message='+message);
   }
  }
  else {
   message = 'Invalid request. Missing parameter oauth_token';
   token='';
   verifier='';
   return new PageReference('/apex/authTest?oauth_token='+token+'&oauth_verifier='+verifier+'&message='+message);
  }
  return null;
 }
 
}